"""
* Software Name: 

  * Version: 01

  *Copyright: 8/2015 Jordan Hamilton, UNSW

  *-----------------------------------------------------

  * File Name : query_big_query.py

  * Created   : 8/2015

  * Author(s) : Jordan Hamilton

  * Description : This script performs a query to the big query service and saves the results

  *Usage of this file:
    *To run program just type 'python query_big_query.py' into command line
    *Once the query is completed a prompt will ask for the name of the query to create the file

  *Input Files:
    *A test file named 'ndt_query.txt' containing the query to perform

  *Output Files:
    *In folders 'NDT_query_results_CSV' and 'NDT_query_results_JSON'
    *Format of file create (file name selected).csv and (file name selected).txt in the appropriate folders

  *Functions:
    *run_asynchronous_query(project_id, authenticated_service, query_string, batch_mode = False) - starts query
    *retrieve_job_data(authenticated_service,project_id, job_id, timeout = 0) - waits for results and then downloads them


  * ----------------------------------------------------


"""

import httplib2
from pprint import pprint
import sys
import logging
import datetime
import time
import os

import json
import glob
import csv

from apiclient.discovery import build
from apiclient.errors import HttpError

from ssl import SSLError


from oauth2client.client import OAuth2WebServerFlow
from oauth2client.client import AccessTokenRefreshError
from oauth2client.client import flow_from_clientsecrets
from oauth2client.file import Storage
from oauth2client.tools import run_flow
from oauth2client import tools

from httplib import ResponseNotReady



# Enter your Google Developer Project number
PROJECT_NUMBER = '754187384106'

FLOW = flow_from_clientsecrets('client_secrets.json',
                               scope='https://www.googleapis.com/auth/bigquery')


def main():

  storage = Storage('bigquery_credentials.dat')
  credentials = storage.get()

  if credentials is None or credentials.invalid:
    # Run oauth2 flow with default arguments.
    credentials = tools.run_flow(FLOW, storage, tools.argparser.parse_args([]))

  http = httplib2.Http()
  http = credentials.authorize(http)

  bigquery_service = build('bigquery', 'v2', http=http)

  #query='SELECT YEAR(FORMAT_UTC_USEC(web100_log_entry.log_time*1000000)) AS year, MONTH(FORMAT_UTC_USEC(web100_log_entry.log_time*1000000)) AS month, DAY(FORMAT_UTC_USEC(web100_log_entry.log_time*1000000)) as day, HOUR(FORMAT_UTC_USEC(web100_log_entry.log_time*1000000)) as hour, web100_log_entry.connection_spec.remote_ip AS IP_address FROM [plx.google:m_lab.2015_03.all] WHERE DAY(FORMAT_UTC_USEC(web100_log_entry.log_time*1000000)) > 0 AND DAY(FORMAT_UTC_USEC(web100_log_entry.log_time*1000000)) < 10 AND connection_spec.client_geolocation.country_code = "AU" AND connection_spec.server_geolocation.country_code = "AU" AND project =0 LIMIT 100;'
  with open("ndt_query.txt") as myfile:
    query=myfile.read()
    
  project_id=PROJECT_NUMBER
  service=bigquery_service
  
  
  
  job_id=run_asynchronous_query(project_id, service, query, batch_mode = False)
  results=retrieve_job_data(service,project_id, job_id, timeout = 0)
  
  
  user_file_name=raw_input('Enter the name of the file to be created containing the query results:')
  
  
  if not os.path.exists('big_query_results_JSON'):
    os.makedirs('big_query_results_JSON')
    
  if not os.path.exists('big_query_results_CSV'):
    os.makedirs('big_query_results_CSV')
    
    if not os.path.exists('NDT_JSON_files'):
        os.makedirs('NDT_JSON_files')
  
  json_data = json.dumps(results)
  with open('big_query_results_JSON/'+user_file_name+'.txt', 'w') as NDT_results_file:
    json.dump(results, NDT_results_file)
    print("File created - "+"big_query_results_JSON/"+user_file_name+".txt")
  
  
  f=open('big_query_results_CSV/'+user_file_name+'.csv', 'w')
        
  csv_file =csv.writer(f)
  csv_file.writerow(results[0].keys())
  for item in results:
    csv_file.writerow(item.values())
  f.close()
  print("File created - "+"big_query_results_CSV/"+user_file_name+".csv")
  
  
  
  
  
def run_asynchronous_query(project_id, authenticated_service, query_string, batch_mode = False):
    job_reference_id = None

    if project_id is None:
      print('Cannot continue since I have not found a project id.')
      return None

    try:
      job_collection = authenticated_service.jobs()
      job_definition = {'configuration': {'query': { 'query': query_string }}}

      if batch_mode is True:
        job_definition['configuration']['query']['priority'] = 'BATCH'

      job_collection_insert = job_collection.insert(projectId = project_id, body = job_definition).execute()
      job_reference_id = job_collection_insert['jobReference']['jobId']
    except (HttpError, ResponseNotReady) as caught_http_error:
      print('HTTP error when running asynchronous query: {error}'.format(
          error = caught_http_error.resp))
    except (Exception, httplib2.ServerNotFoundError) as caught_generic_error:
      print('Unknown error when running asynchronous query: {error}'.format(
          error = caught_generic_error))

    return job_reference_id



def retrieve_job_data(authenticated_service,project_id, job_id, timeout = 0):
    max_results_per_get = 100000
    job_data_to_return = []
    job_collection = authenticated_service.jobs()

    query_request = {'projectId': project_id,
                      'jobId': job_id,
                      'maxResults':  max_results_per_get,
                      'timeoutMs': timeout}
    time_count=0
    while True:
      try:
        query_results_response = job_collection.getQueryResults(**query_request).execute()

        assert query_results_response['jobComplete'] == True, 'IncompleteBigQuery'

        if int(query_results_response['totalRows']) == 0:
          print('BigQuery Report Job Completed, but no rows found. This ' +
                            'is likely due to no data being present for site, ' +
                            'client and time combination. Believing that, I will ' +
                            'produce an empty file. The life of measurement is ' +
                            'solitary, poor, nasty, brutish, and short.')
          break
        else:
          fieldnames = [field['name'] for field in query_results_response['schema']['fields']]

          for results_row in query_results_response['rows']:
            new_results_row = dict(zip(fieldnames, [result_value['v'] for result_value in results_row['f']]))
            job_data_to_return.append(new_results_row)

          if query_results_response.has_key('pageToken'):
            query_request['pageToken'] = query_results_response['pageToken']
            print("Large result, have found {count} iterating with new page token.".format(
                count = len(job_data_to_return)))
          else:
            print("\nComplete, found {count}.".format(count = len(job_data_to_return)))
            break
      except (SSLError, HttpError, ResponseNotReady) as caught_error:
        if caught_error.resp.status == 404:
          raise TableDoesNotExist()
        elif caught_error.resp.status in [403, 500, 503]:
          raise QueryFailure(caught_error.resp.status, caught_error)
        else:
          """print(('Encountered error ({caught_error}) retrieving ' +
                            '{notification_identifier} results, could be temporary, ' +
                            'not bailing out.').format(caught_error = caught_error,
                                                      notification_identifier = job_id))"""
          string="Results not ready... waiting for "+str(time_count)+" seconds"
          print('\r'+string),
          sys.stdout.flush()
        time.sleep(10)
        time_count=time_count+10
      except (Exception, AttributeError, httplib2.ServerNotFoundError) as caught_error:
          string="Results not ready... waiting for "+str(time_count)+" seconds"
          print('\r'+string),
          sys.stdout.flush()
          """print(('Encountered error ({caught_error}) retrieving ' +
                            '{notification_identifier} results, could be temporary, ' +
                            'not bailing out.').format(caught_error = caught_error,
                                                      notification_identifier = job_id))"""

          time.sleep(10)
          time_count=time_count+10
    return job_data_to_return
  
  


if __name__ == '__main__':
  main()