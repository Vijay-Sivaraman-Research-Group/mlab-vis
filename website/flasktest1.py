#!/usr/bin/python

#import gp
#from yourapplication import app as application
from flask import Flask, jsonify, abort, make_response, request
import base64
from pprint import pprint
import json
import csv
import os.path
import subprocess
from operator import itemgetter
try:
    from flask.ext.cors import CORS  # The typical way to import flask-cors
except ImportError:
    # Path hack allows examples to be run without installation.
    import os
    parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.sys.path.insert(0, parentdir)

    from flask.ext.cors import CORS

app = Flask(__name__)
CORS(app, resources=r'/*', headers='Content-Type')





@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)


######################################################################
## routines 
######################################################################



@app.route('/visualise', methods=['POST'])
def create_app1():
    
    status = False
    reason=""
    encoded_string=""
    error =False
    
    
    plotSettings = json.loads(request.json)
    #pprint(plotSettings)
    
    
    found=0
    for a in plotSettings[0]['ip'].values():
        if a != '':
            found+=1        
    if sum(plotSettings[0]['isp'].values()) == 0 and found == 0:
        error = True
        reason="Please select ISPs or IP addresses to plot"      
    if sum(plotSettings[0]['isp'].values()) != 0 and found != 0:
        error = True
        reason="Please select only ISPs or IP address, not both"
       
    
    
    
    

        
    
    
    if error == False:
        year=plotSettings[0]['year']
        month=plotSettings[0]['month']
        month=month.lower()
        day=plotSettings[0]['day']
        day=day.lower()
        
        aggregation=plotSettings[0]['aggregation']
        
        format=plotSettings[0]['format']
        
        parameter=plotSettings[0]['parameters']
        
        facet=plotSettings[0]['facet']
        
        isps=[]
        for a in plotSettings[0]['isp']:
            if plotSettings[0]['isp'][a] == True:
                isps.append(a)

        isps.sort(key=lambda x:x.lower())

        
        isp1=''
        isp2=''
        isp3=''
        isp4=''
        isp5=''
        isp6=''


        if len(isps)>=1:
            isp1=isps[0]
            isp1=isp1.split(" ")[0]
            isp1=isp1.lower()
        if len(isps)>=2:
            isp2=isps[1]
            isp2=isp2.split(" ")[0]
            isp2=isp2.lower()
        if len(isps)>=3:
            isp3=isps[2]
            isp3=isp3.split(" ")[0]
            isp3=isp3.lower()
        if len(isps)>=4:
            isp4=isps[3]
            isp4=isp4.split(" ")[0]
            isp4=isp4.lower()
        if len(isps)>=5:
            isp5=isps[4]
            isp5=isp5.split(" ")[0]
            isp5=isp5.lower()
        if len(isps)>=6:
            isp6=isps[5]
            isp6=isp6.split(" ")[0]
            isp6=isp6.lower()
        
        
        ip1=plotSettings[0]['ip']['IP1']
        ip2=plotSettings[0]['ip']['IP2']
        ip3=plotSettings[0]['ip']['IP3']
        ip4=plotSettings[0]['ip']['IP4']
        ip5=plotSettings[0]['ip']['IP5']
        


        if facet == True:
            #facet
            if format == 'norm':
                #normalised
                if sum(plotSettings[0]['isp'].values()) == 0:
                    #IP address
                    if aggregation == 'hour':
                        #hour
                        status=False
                        reason='That plot selection is not avaliable'
                            
                    elif aggregation == 'day':
                        #day
                        status=False
                        reason='That plot selection is not avaliable'
                    else:
                        #month
                        status=False
                        reason='That plot selection is not avaliable'
                else:
                    #ISP
                
                    if aggregation == 'hour':
                        #hour
                        path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__norm__facet(month,hour)_day_speed_IPaddress__'+isp1+'____.png'
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'ISP_facet_norm.R', year, month, isp1], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
                    elif aggregation == 'day':
                        #day
                        path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__norm__facet(month,day)_hour_speed_IPaddress__'+isp1+'____.png'
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'ISP_facet_norm.R', year,month,isp1], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
                    else:
                        #month
                        status=False
                        reason='That plot selection is not avaliable'
            else:
               #raw 
                if sum(plotSettings[0]['isp'].values()) == 0:
                    #IP address
                    if aggregation == 'hour':
                        #hour
                        path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__facet(month,hour)_day_speed_'+parameter+'__'+isp1+'__'+ip1+'.png'
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'IP_facet_raw.R', year, month, isp1,parameter], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
                    elif aggregation == 'day':
                        #day
                        path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__facet(month,day)_hour_speed_'+parameter+'__'+isp1+'__'+ip1+'.png'
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'IP_facet_raw.R', year,month,isp1,parameter], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
                    else:
                        #month
                        status=False
                        reason='That plot selection is not avaliable'
                else:
                    #ISP
                    if aggregation == 'hour':
                        #hour
                        path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__facet(month,hour)_day_speed_IPaddress__'+isp1+'____.png'
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'ISP_facet_raw.R', year, month, isp1], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
                    elif aggregation == 'day':
                        #day
                        path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__facet(month,day)_hour_speed_IPaddress__'+isp1+'____.png'
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'ISP_facet_raw.R', year,month,isp1], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
                    else:
                        #month
                        status=False
                        reason='That plot selection is not avaliable'
        else:
            #non-facet
            if format == 'norm':
                #normalised
                if sum(plotSettings[0]['isp'].values()) == 0:
                    #IP address
                    if aggregation == 'hour':
                        #hour
                        status=False
                        reason='That plot selection is not avaliable'
                            
                    elif aggregation == 'day':
                        #day
                        status=False
                        reason='That plot selection is not avaliable'
                    else:
                        #month
                        status=False
                        reason='That plot selection is not avaliable'
                else:
                    #ISP
                    if aggregation == 'hour':
                        #hour
                        if len(isps)==1:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__norm__hour_speed_ISPs__'+isp1+'____.png'
                        if len(isps)==2:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__norm__hour_speed_ISPs__'+isp1+'_'+isp2+'____.png'
                        if len(isps)==3:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__norm__hour_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'____.png'
                        if len(isps)==4:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__norm__hour_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'____.png'
                        if len(isps)==5:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__norm__hour_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'_'+isp5+'____.png'
                        if len(isps)==6:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__norm__hour_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'_'+isp5+'_'+isp6+'____.png'
                        
                        
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'ISP_nonfacet_norm_HourVsSpeed.R', year,month,isp1,isp2,isp3,isp4,isp5,isp6], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
                    elif aggregation == 'day':
                        #day
                        status=False
                        reason='That plot selection is not avaliable'
                    else:
                        #month
                        if len(isps)==1:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__norm__month_speed_ISPs__'+isp1+'____.png'
                        if len(isps)==2:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__norm__month_speed_ISPs__'+isp1+'_'+isp2+'____.png'
                        if len(isps)==3:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__norm__month_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'____.png'
                        if len(isps)==4:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__norm__month_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'____.png'
                        if len(isps)==5:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__norm__month_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'_'+isp5+'____.png'
                        if len(isps)==6:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__norm__month_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'_'+isp5+'_'+isp6+'____.png'
                        
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'ISP_nonfacet_norm_MonthVsSpeed.R', year,isp1,isp2,isp3,isp4,isp5,isp6], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
            else:
               #raw 
                if sum(plotSettings[0]['isp'].values()) == 0:
                    #IP address
                    if aggregation == 'hour':
                        #hour
                        status=False
                        reason='That plot selection is not avaliable'
                    elif aggregation == 'day':
                        #day
                        status=False
                        reason='That plot selection is not avaliable'
                    else:
                        #month
                        status=False
                        reason='That plot selection is not avaliable'
                else:
                    #ISP
                    if aggregation == 'hour':
                        #hour
                        if len(isps)==1:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__hour_speed_ISPs__'+isp1+'____.png'
                        if len(isps)==2:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__hour_speed_ISPs__'+isp1+'_'+isp2+'____.png'
                        if len(isps)==3:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__hour_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'____.png'
                        if len(isps)==4:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__hour_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'____.png'
                        if len(isps)==5:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__hour_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'_'+isp5+'____.png'
                        if len(isps)==6:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'_'+month+'__raw__hour_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'_'+isp5+'_'+isp6+'____.png'
                        
                        
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'ISP_nonfacet_raw_HourVsSpeed.R', year,month,isp1,isp2,isp3,isp4,isp5,isp6], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'
                    elif aggregation == 'day':
                        #day
                        status=False
                        reason='That plot selection is not avaliable'
                    else:
                        #month
                        if len(isps)==1:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__raw__month_speed_ISPs__'+isp1+'____.png'
                        if len(isps)==2:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__raw__month_speed_ISPs__'+isp1+'_'+isp2+'____.png'
                        if len(isps)==3:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__raw__month_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'____.png'
                        if len(isps)==4:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__raw__month_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'____.png'
                        if len(isps)==5:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__raw__month_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'_'+isp5+'____.png'
                        if len(isps)==6:
                            path='/home/research_sivaraman/public_html/R/Plot/plot__'+year+'__raw__month_speed_ISPs__'+isp1+'_'+isp2+'_'+isp3+'_'+isp4+'_'+isp5+'_'+isp6+'____.png'
                        
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            p = subprocess.call(['Rscript', 'ISP_nonfacet_raw_MonthVsSpeed.R', year,isp1,isp2,isp3,isp4,isp5,isp6], cwd='/home/research_sivaraman/public_html/R')
                        if os.path.exists(path):
                            with open(path, "rb") as image_file:
                                encoded_string = base64.b64encode(image_file.read())
                                status=True
                        else:
                            status=False
                            reason='That plot selection is not avaliable'

        """
        path='/home/research_sivaraman/public_html/R/Plot/'+year+'_'+month+'_norm_HourVsSpeed_ISP_mean_nonfacet.png'
        if os.path.exists(path):
            with open(path, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read())
                status=True
        else:
            p = subprocess.call(['Rscript', 'ISP_plots_norm_ISPs.R', '2015','3','exetel','tpg'], cwd='/home/research_sivaraman/public_html/R')
        if os.path.exists(path):
            with open(path, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read())
                status=True
        else:
            status=False
            reason='That plot selection is not avaliable'
        """
        
        
        
        
     
    return jsonify({'application': encoded_string,'status':status, 'reason':reason}), 200




@app.route('/isps', methods=['GET'])
def get_isps():
    #isps = [line.rstrip('\n') for line in open('isps.txt')]
    
    
    out=[]
    csvfile = open('/home/research_sivaraman/public_html/files/isps.csv', 'rU')
    fieldnames = ("country","isp")
    
    reader = csv.DictReader(csvfile,fieldnames)
    out = json.dumps( [ row for row in reader ] )
    out=json.loads(out)

    out=sorted(out, key=lambda k:(k['country'],k['isp'].lower())) 

    out = json.dumps(out)
    
    return jsonify({'isps': out}), 200



@app.route('/parameters', methods=['GET'])
def get_parameters():
    parameters = [line.rstrip('\n') for line in open('/home/research_sivaraman/public_html/files/parameters.txt')]
    return jsonify({'parameters': parameters}), 200


@app.errorhandler(500)
def internal_error(error):
    
    return "500 error"







## main function
if __name__=='__main__':
    app.run(host='0.0.0.0',port=5000,debug=True)

