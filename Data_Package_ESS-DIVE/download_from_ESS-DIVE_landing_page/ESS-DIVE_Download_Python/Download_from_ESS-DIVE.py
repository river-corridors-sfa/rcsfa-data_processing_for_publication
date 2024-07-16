# -*- coding: utf-8 -*-
"""
Created on Sun Apr 16 15:32:41 2023

@author: zhou242
"""

import os

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
import json
import xmltojson
import xmltodict
from lxml.html import fromstring
import requests
import re
import pandas as pd
import time
import zipfile

## read the json file
f=open('W:/ESSDIVE_Download_Test/Script/Configuration_file.json')
file = json.load(f)

out= file['Data_package_Out'] # this is the outpath
Main_Name=file['Out_Folder'] # this is outfolder
Chrome_Driver_Path=''.join(file['Chrome_Driver_Path']) # get the Chrome driver from your local computer
Input_DOI=''.join(file['Input_DOI']) # get the DOI from ESS-DIVE

# create the output folder for the Datapackage
outer=''.join(out)+''.join(Main_Name)
isExist = os.path.exists(outer)
if not isExist:
    os.makedirs(outer)


# the function can help to read all the files from Data packages
def find_all(a_str, sub):
    start = 0
    while True:
        start = a_str.find(sub, start)
        if start == -1: return
        yield start
        start += len(sub) # use start += 1 to find overlapping matches
## active driver 
driver = webdriver.Chrome(Chrome_Driver_Path)
print(driver)

## the driver read the DOI
driver.get(Input_DOI)
time.sleep(20) ## sleep for 20 seconds

# html file is working on get the information from the link of Datapackage 
html=driver.page_source

# Download the data
Download_indexs=list(find_all(html, 'DataDownload'))
encodingFormat_index=list(find_all(html,'encodingFormat'))
contentUrl_index=list(find_all(html,'contentUrl'))
identifier_index=list(find_all(html,'identifier'))
#specicial_index=list(find_all(html,'["},{"@type":]'))

for index,val in enumerate(Download_indexs):
    Name_index_start=Download_indexs[index]
    Name_index_end=encodingFormat_index[index]
    Name=html[Name_index_start+22:Name_index_end-3]
    Start=contentUrl_index[index]+13
    end1=identifier_index[index]-5
    
    if (Start<end1) and (index<(len(Download_indexs)-1)):
        url=html[Start:end1]
    elif (Start>end1) and (index==(len(Download_indexs)-1)):
        end3=identifier_index[index+2]-5
        url=html[Start:end3]
    else:
        end2=Download_indexs[index+1]-13
        url=html[Start:end2]
    print(url)
    r = requests.get(url, allow_redirects=True, verify=False)
    open(outer+'/'+Name, "wb").write(r.content)

## unzip the file
for file in os.listdir(outer):
    if file.endswith(".zip"):
        print(f"{file} is a zip file.")
        with zipfile.ZipFile(outer+'/'+file, 'r') as zip_ref:
           zip_ref.extractall(outer)
    
print('Done')
## finish