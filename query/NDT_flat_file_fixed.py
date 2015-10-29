"""
* Software Name: 

  * Version: 01

  *Copyright: 8/2015 Jordan Hamilton, UNSW

  *-----------------------------------------------------

  * File Name : NDT_household.py

  * Created   : 8/2015

  * Author(s) : Jordan Hamilton

  * Description : This script searches through the NDT data and produces a CSV file for each ISP per month.
                  This CSV contains each IP address that conducted a search within that ISP and the maxiumum download speed obtained by that IP address

  *Usage of this file:
    *To run program just type 'python NDT_household.py' into command line
    *No other results will be dispalyed

  *Input Files:
    *Place all files containing NDT data into folder named 'NDT_JSON_files'

  *Output Files:
    *In folder 'ISP_household' csv files for each ISP are created
    *Format of file create (ISP)_(Year)_(Month)_NDT.csv

  *Functions:
    *writeHousehold(data,address) - writes the list "data" into a CSV file located at address, address format - "folder/filename.csv"
    *collectJSONdata(path) - collects all JSON files located at path ("folder/*") and returns it as a variable
    *checkRecordsNDT(year,month,day,hour) - for all data in NDT_data that matches the dates entered (year,month,day,hour) it collects to ISP and saves the result to ISP_household
    *addToList(a,ISP,telstra_NDT,optus_NDT,dodo_NDT,iinet_NDT,exetel_NDT,internode_NDT,tpg_NDT,vodafone_NDT) - sorts data in a into lists depending on ISP of a

  * ----------------------------------------------------


"""

import json
import glob
import csv
from pprint import pprint
from collections import defaultdict
from ipwhois import IPWhois
from ipwhois import (IPDefinedError, ASNLookupError,
                      ASNRegistryError, WhoisLookupError, HostLookupError)
import xlwt
import numpy
from netaddr import *
import os


IP_file_bittorrent=[]
ISP_classified_bittorrent=[]
IP_file_dash=[]
ISP_classified_dash=[]
IP_to_ISP=[]
IP_file_NDT=[]
ISP_classified_NDT=[]

ISP_household=[]


telstra_NDT=[]
optus_NDT=[]
dodo_NDT=[]
internode_NDT=[]
exetel_NDT=[]
iinet_NDT=[]
tpg_NDT=[]
vodafone_NDT=[]

with open('IP_to_ISP.txt') as data_file:
    IP_to_ISP = json.load(data_file)

NDT_data=[]



pathstart = 'neubot_data_extracted/' 




################################################################################
################################################################################
################################################################################

def checkRecordsNDT(year,month,day,hour):
    #print "NDT - collecting"
    type='NDT'
    
    error=0
    count=0
    
    for a in NDT_data:
        found=0
        match=0
        count+=1
        #print(count)
        if a['year']==year:
            if a['month']==month:
                        
                        for b in ISP_household:
                            found=0
                            if (a['IP_address']) == (b['IP_address']):
                                b['test_count']=b['test_count']+1
                                downloadSpeed= float(a['download_speed'])
                                if downloadSpeed > b['max_speed']:
                                    b['max_speed']= downloadSpeed
                                match=1
                                break
                            
                        if match == 0:
                            error=0
                            for n in IP_to_ISP:
                                if IPAddress(a['IP_address']) >= IPAddress(n['range_low']) and IPAddress(a['IP_address']) <= IPAddress(n['range_high']):
                                    ISP=n['ISP']
                                    found=1
                                    break
                            if found == 0:
                                
                                try:
                                    string=''
                                    obj = IPWhois(a['IP_address'])
                                    results = obj.lookup()
                                    #pprint(results)
                                    ISP=results['nets'][0]['description']
                                    if ISP == None:
                                        ISP=" "
                                    ISP=ISP.replace('\n'," ")
                                    ISP=ISP.split(" ")[0]
                                    
                                    string=' '.join(results['nets'][0]['range'].split())
                                    
                                    if IPNetwork(string.split(' ')[0]).network != IPNetwork(string.split(' ')[0]).broadcast:
                                        
                                        IP_to_ISP.append({'ISP':ISP,'IP_address':a['IP_address'],'range_low':str(IPNetwork(string.split(' ')[0]).network),'range_high':str(IPNetwork(string.split(' ')[0]).broadcast)})
                                    else:
                                        
                                        IP_to_ISP.append({'ISP':ISP,'IP_address':a['IP_address'],'range_low':string.split(' ')[0],'range_high':string.split(' ')[2]})
                            
                                    json_data = json.dumps(IP_to_ISP)
                                
                                    with open('IP_to_ISP.txt', 'w') as IP_to_ISP_file:
                                        json.dump(IP_to_ISP, IP_to_ISP_file)
                                except IndexError:
                                    ISP = " "
                                    error = 1
                                    IP_to_ISP.append({'ISP':ISP,'IP_address':a['IP_address'],'range_low':a['IP_address'],'range_high':a['IP_address']})
                                except WhoisLookupError:
                                    ISP = " "
                                    error = 1
                                    IP_to_ISP.append({'ISP':ISP,'IP_address':a['IP_address'],'range_low':a['IP_address'],'range_high':a['IP_address']})
                                
                            
                            downloadSpeed= float(a['download_speed'])
                
                            ISP_household.append({'IP_address':a['IP_address'],'max_speed':downloadSpeed,'ISP':ISP.lower(),'month':a['month'],'year':a['year'],'data_type':type,'test_count':1})
    return ISP_household                    
################################################################################
################################################################################
################################################################################
def addToList(a):
    for b in a:
        ISP=b['ISP']
        speed=b['download_speed']
        string='telstra'
        if ISP.lower() == string.lower():
            telstra_NDT.append(speed)
        string='optus'
        if ISP.lower() == string.lower():
            optus_NDT.append(speed)
        string='internode'
        if ISP.lower() == string.lower():
            internode_NDT.append(speed)
        string='dodo'
        if ISP.lower() == string.lower():
            dodo_NDT.append(speed)
        string='exetel'
        if ISP.lower() == string.lower():
            exetel_NDT.append(speed)
        string='iiNet'
        if ISP.lower() == string.lower():
            iinet_NDT.append(speed)
        string='tpg'
        if ISP.lower() == string.lower():
            tpg_NDT.append(speed)
        string='vodafone'
        if ISP.lower() == string.lower():
            vodafone_NDT.append(speed)

    
################################################################################
################################################################################
################################################################################



def writeHousehold(data,address):
    
    
    if len(data)!= 0:
        f=open(address, 'w')
        
        csv_file =csv.writer(f)
        csv_file.writerow(data[0].keys())
        for item in data:
            csv_file.writerow(item.values())
        f.close()


################################################################################
################################################################################
################################################################################


def collectJSONdata(path):
    data=[]
    files=glob.glob(path)
        
    for filename in files:
        with open(filename) as data_file:
            tempData = json.load(data_file)
            data=data+tempData
    return data


###############################################################################
################################################################################
################################################################################

if not os.path.exists('NDT_flat_file'):
    os.makedirs('NDT_flat_file')

print("Processing NDT data")
NDT_data=collectJSONdata('NDT_JSON_files/*')

NDT=[]


year=int(raw_input('Enter the start year:'))
end_year=int(raw_input('Enter the end year:'))


while year <= end_year:
    month=1
    while month <= 12:
        print('Year-'+str(year)+' Month-'+str(month))
        ISP_household=[]
        ISP_household=checkRecordsNDT(str(year),str(month),'*','*')
                
        #print("Normalising")
        for a in NDT_data:
            for b in ISP_household:
                if b['IP_address']==a['IP_address']:
                    if a['month']==str(month) and a['year']==str(year):
                        #if b['test_count'] >= 10:    
                            
                            a.update({'ISP':b['ISP']})
                            a.update({'download_speed_normalised_month':float(a['download_speed'])/float(b['max_speed'])})
                            a.update({'IP_test_count_month':b['test_count']})
                            a.update({'download_speed_max_month':b['max_speed']})
                            
                            
                            NDT.append(a)
                    
                        
                    break
            
        
        
        print('\n')
        month=month+1
    year=year+1




print("Printing results to files")
writeHousehold(NDT,'NDT_flat_file/NDT_data.csv')


json_data = json.dumps(NDT)
with open('NDT_flat_file/NDT_data.txt', 'w') as NDT_results_file:
    json.dump(NDT, NDT_results_file)



#pprint(IP_to_ISP)
json_data = json.dumps(IP_to_ISP)
with open('IP_to_ISP.txt', 'w') as IP_to_ISP_file:
    json.dump(IP_to_ISP, IP_to_ISP_file)





