######################################################################################################
####*****ESS-DIVE Auto-uploading functions. No Need to Modify.**************************##############
####*****Created by Huifen Zhou, *******************************************************##############
####*****Modified by Huiying Ren, 09/2021 **********************************************##############
####*****Contact: Amy E. Goldman(amy.goldman@pnnl.gov)**********************************##############
######################################################################################################

uploading_script = function(script_path,json_input,Author_Info,package_path,docx_file,API_website,author_file,zip_file,spatial_csv,spatial_header,spatial_coor_lat,spatial_coor_long){
  My<-jsonlite::fromJSON(json_input) 
  # My<-jsonlite::fromJSON("W:/ESSDIVE_Download_Test/Upload_Work/02_Data-Package_Rscript/SFA_Default.jsonld")
  Doc<-read_docx(docx_file)
  
  ## get index of feature
  Title_Index<-which(grepl("Title:",Doc)==T)
  Alter_Id_Index<-which(grepl("Alternative Identifiers:",Doc)==T)
  Abs_Index<-which(grepl("Abstract:",Doc)==T)
  Keywords_Index<-which(grepl("Keywords:",Doc)==T)
  Variable_Index<-which(grepl("Data variables:",Doc)==T)
  Pub_date_Index<-which(grepl("Pub date:",Doc)==T)
  Data_Usage_Index<-which(grepl("Data usage rights:",Doc)==T)
  Project_Index<-which(grepl("Project:",Doc)==T)
  Funder_Inder<-which(grepl("Funding org:",Doc)==T)
  Reference_Index<-which(grepl("Related reference:",Doc)==T)
  PI_Index<-which(grepl("Principal investigator:",Doc)==T) ## please check the name
  Contact_Name_Index<-which(grepl("Contact name:",Doc)==T)
  DOE_Contracts_Index<-which(grepl("DOE Contracts:",Doc)==T)
  Contact_Email_Index<-which(grepl("Contact email:",Doc)==T)
  Creator_Index<-which(grepl("Creators:",Doc)==T)
  Start_date_Index<-which(grepl("Start date:",Doc)==T)
  End_date_Index<-which(grepl("End date:",Doc)==T)
  Location_Index<-which(grepl("Location description:",Doc)==T)
  Coor_Index<-which(grepl("Coordinates:",Doc)==T)
  Measure_Index<-which(grepl("Methods:",Doc)==T)
  
  ###
  Paper_Title<-Doc[(Title_Index+1):(Alter_Id_Index-1)] # papere title
  Data_Abs<-Doc[(Abs_Index+1):(Keywords_Index-1)] # paper abstract
  data_keywords<-Doc[(Keywords_Index+1):(Variable_Index-1)] #keywords of the paper
  data_variables<-Doc[(Variable_Index+1):(Pub_date_Index-1)]
  Data_Start<-Doc[Start_date_Index+1] 
  Data_End<-Doc[End_date_Index+1]
  Technique_Measure<-Doc[(Measure_Index+1):length(Doc)]
  if((PI_Index-Reference_Index)==1){
    Refer<-"current unavailable"
  } else{
    Refer<-Doc[(Reference_Index+1):(PI_Index-1)]
  }
  
  DOE_Contacts<-Doc[(DOE_Contracts_Index+1):(Reference_Index-1)]
 

  ##DOI alternate identifier box
  
  Alter_Id_info<-Doc[(Alter_Id_Index+1):(Abs_Index-1)]
  
  if((Alter_Id_Index+1)==Abs_Index){
    Data_DOI<-"NA"
  } else {
    Data_DOI<-Alter_Id_info
  }
  
  if((Pub_date_Index+1)==Data_Usage_Index){
    Publish_date<-Sys.Date() 
  } else{
    Publish_date<-Doc[(Pub_date_Index+1):(Data_Usage_Index-1)]
  }
  
  Data_Usage<-Doc[(Data_Usage_Index+1):(Project_Index-1)]
  
  ### the information about creator
  Creators<-data.frame(Doc[(Creator_Index+1):(Start_date_Index-1)])
  
  data_creator<-data.frame()
  for(icr in 1: dim(Creators)[1]){
    all_n_part<-strsplit(Creators[icr,1]," ")[[1]]
    all_n_part =all_n_part[all_n_part != ""]
    if(length(all_n_part)==1){
      dc<-data.frame(NA,all_n_part[length(all_n_part)])
    } else{
      dc<-data.frame(all_n_part[1],all_n_part[length(all_n_part)])
    }
    
    colnames(dc)<-c("First","Last")
    data_creator<-rbind(data_creator,dc)
  }
  
  Data_Creator<-data.frame()
  for(irow in 1:dim(data_creator)[1]){
    First<-data_creator$First[irow]
    Last<-data_creator$Last[irow]
    
    if(is.na(First)==T){
      Index<-which(Author_Info$Last.Name==Last)
    }else{
      Index<-which(Author_Info$First.Name==First & Author_Info$Last.Name==Last)
    }
    if(length(Index)==0){
    
	tlk=tkmessageBox(title = "Error",
                   message = paste("Please check the author's last name",  Last," , if correct, update it in the Author list Excel file",author_file,sep="\n"), 
                   icon = "error", type = "ok")
	if(as.character(tlk)=='ok'){
	stop()
	}
    }else if(length(Index)>1){
      Name_Content<-paste("Author check: Last name", Last,"is not unique! ", paste(Author_Info$First.Name[which(Author_Info$Last.Name==Last)],
                                                                                   Last,sep=" ",collapse = " and "),
                          "Please update author's first name in *.doc file:", docx_file, sep='\n')
      tkmessageBox(title = "Error",
                   message =  Name_Content, 
                   icon = "error", type = "ok")
	if(as.character(tlk)=='ok'){
	stop()
	}
    }else if(length(Index)==1){
      
      if(is.na(Author_Info$ORCID[Index])==T){
        ORCID<-NA
      } else{
        ORCID<-paste("https://orcid.org/",Author_Info$ORCID[Index],sep="")
      }
      
      Institution<-Author_Info$Institution[Index]
      Email<-Author_Info$E.mail[Index]
      
      if(is.na(Author_Info$Middle.Name[Index])==T){
        First_M<-Author_Info$First.Name[Index]
      } else{
        First_M<-paste(Author_Info$First.Name[Index],Author_Info$Middle.Name[Index],sep=" ")
      }
      
      data_creator1<-data.frame(ORCID,First_M,Last,Institution,Email)
      Data_Creator<-rbind(Data_Creator,data_creator1)
    }
    
  }
  tlk =tkmessageBox(title = "Author List Confirmation",
               message = paste(apply(rbind(paste('Author',c(1:dim(Data_Creator)[1]),':',sep=''),do.call(rbind,(Data_Creator))),2, paste, collapse='\n'),collapse = "\n") ,
               icon = "info", type = "yesno")
  if(as.character(tlk)=='no'){
	stop()
  }
  colnames(Data_Creator)<-c("@id" ,  "givenName" ,  "familyName",  "affiliation", "email")
  Data_Creator_list<-Data_Creator #  %>% purrr::transpose()
  
  Contact_Name<-Doc[(Contact_Name_Index+1):(Contact_Email_Index-1)]
  Contact.Name.Index<-which(sapply(strsplit(Data_Creator_list$givenName," "),"[",1) %in% strsplit(Contact_Name," ")[[1]][1] & Data_Creator_list$ 
                              familyName %in% strsplit(Contact_Name," ")[[1]][length(strsplit(Contact_Name," ")[[1]])] )
  ## PI information 
  PI_info<-Doc[(PI_Index+1):(Contact_Name_Index-1)]
  Project_info<-Doc[(Project_Index+1):(Funder_Inder-1)]
  if(length(Project_info)==1){
    Project_Info=Project_info  #"River Corridor and Watershed Biogeochemistry SFA" #Project_info
  } else{
    Project_Info="River Corridor Hydro-biogeochemistry from Molecular to Multi-Basin Scales SFA" #paste(Project_info,sep="",collapse = "/")
  }

  PI_Name<- strsplit(PI_info," ") [[1]]
  PI_Name = PI_Name[PI_Name != ""]
  if(length(PI_Name)==1){
  	PI_last_name<-PI_Name
  	PI_name_index<-which(Author_Info$Last.Name ==PI_last_name)
  }else{
  	PI_first_name<-PI_Name[1]
  	PI_last_name<-PI_Name[length(PI_Name)]
  	PI_name_index<-which(Author_Info$First.Name== PI_first_name & Author_Info$Last.Name ==PI_last_name)

  }

  
  if(length(PI_name_index)==0){
    tlk=tkmessageBox(title = "Error",
                 message = paste("Please check the PI name in *.doc file or update in the Author list Excel file", PI_info,sep="\n"), 
                 icon = "error", type = "ok")
	if(as.character(tlk)=='ok'){
	stop()
	}
  }else if(length(PI_name_index)>1){
    Name_Content<-paste("Author check: Last name", PI_last_name,"is not unique! ", paste(Author_Info$First.Name[which(Author_Info$Last.Name==PI_last_name)],
                                                                                         PI_last_name,sep=" ",collapse = " and "),
                        "Please update author's first name in *.doc file:", docx_file, sep='\n')
    tlk=tkmessageBox(title = "Error",
                 message =  Name_Content, 
                 icon = "error", type = "ok")
	if(as.character(tlk)=='ok'){
	stop()
	}
    
  } else if (length(PI_name_index)==1){
    My$provider$name<-Project_Info
    My$provider$member$'@id'<-paste("https://orcid.org/",Author_Info$ORCID[PI_name_index],sep="")
    if(is.na(Author_Info$Middle.Name[PI_name_index])){
	    My$provider$member$givenName<-Author_Info$First.Name[PI_name_index]
    }else{
    	  My$provider$member$givenName<-paste(Author_Info$First.Name[PI_name_index],Author_Info$Middle.Name[PI_name_index],sep=" ")
    }
    My$provider$member$familyName<-Author_Info$Last.Name[PI_name_index]
    My$provider$member$email<-Author_Info$E.mail[PI_name_index]
    My$provider$member$jobTitle<-"Principal Investigator"
    My$provider$member$affiliation<-Author_Info$Institution[PI_name_index]  
  }
  
  
  # change project ID based on ptoject title
  if (!grepl('River Corridor Hydro-biogeochemistry from Molecular to Multi-Basin Scales SFA', My$provider$name, fixed = FALSE)){
    project_list <- gsheet2tbl('https://docs.google.com/spreadsheets/d/179SOyv42wXbP4owWZtUg3RqhW9dPOyENYcVYuUCcqwg/edit#gid=1921074133')
    project_id <-project_list$`Project ID`[grep(My$provider$name,project_list$`Project Title`)] 
    if (length(project_id)==0){
      Project_Content<-paste("Project Name :", My$provider$name,
                             "Didn't find project name in the list !",  sep='\n')
      tlk=tkmessageBox(title = "Error",
                       message =  Project_Content, 
                       icon = "error", type = "ok")
    }else{
      My$provider$identifier$value<-project_id
      
      Project_Content<-paste("Project Name :", My$provider$name,
                             "Please double check if project name is correct !",  sep='\n')
      tlk=tkmessageBox(title = "Double check Project Name",
                       message =  Project_Content, 
                       icon = "info", type = "ok")
      
    }
  }
  
  ### for spatial info
  Location_Info<-Doc[(Location_Index+1):(Coor_Index-1)]
  Coor_Info<-Doc[(Coor_Index+1):(Measure_Index-1)]

  if(all(tolower(Location_Info)=="refer to metadata spreadsheet" & tolower(Coor_Info) =="refer to metadata spreadsheet")==T){
    Spatial_File<-read.csv(spatial_csv,stringsAsFactors = F)
    Spatial_Header<-spatial_header
    
   
      Spatial_coor_lat<-spatial_coor_lat
      Spatial_coor_long<-spatial_coor_long
      
      Select_cols<-c(Spatial_Header,Spatial_coor_lat,Spatial_coor_long)
      if( all(Select_cols %in% colnames(Spatial_File) )==T){
        
        Spatial_Info<-Spatial_File[,Select_cols]
        Spatial_Info$Details<-apply(Spatial_File[,Spatial_Header],1,paste,collapse = ", ")
        Spatial_Info_1<-Spatial_Info[,c(Spatial_coor_lat,Spatial_coor_long,"Details")]
        
      } else{
        tlk =tkmessageBox(title = "Error",
                          message = paste("No column named",Spatial_Header[!Select_cols %in% colnames(Spatial_File)], "in spatial file:",spatial_csv,
                                          "Please update column name in JSON file:",json_input,
                                          sep='\n'), 
                          icon = "error", type = "ok")
        if(as.character(tlk)=='ok'){
          stop()
        }
        
      }
    
  } else{
    ####################################################################################
    ## Read spatial info from docx.
    if( all(grepl("LAT|LONG", toupper(Coor_Info)))==T ){
      lat.id = grep('LAT',toupper(Coor_Info))
      lon.id = grep('LONG',toupper(Coor_Info))
      
      Details_ori<-Location_Info
      Latitude_ori<-strsplit(Coor_Info,"=")[[lat.id]][2]
      Longitud_ori<-strsplit(Coor_Info,"=")[[lon.id]][2]
      
      if(length(Details_ori)>1){
        Details<-Details_ori[1:length(Details_ori)]
        Latitude<-strsplit(Latitude_ori,",")[[1]]
        Longitud<-strsplit(Longitud_ori,",")[[1]]
        
      }else{
        Details<-Location_Info
        Latitude<-strsplit(Coor_Info,"=")[[lat.id]][2]
        Longitud<-strsplit(Coor_Info,"=")[[lon.id]][2]
      }
      
      
      
      Spatial_Info<-data.frame(Latitude,Longitud,Details) 
      Spatial_Info_1<-Spatial_Info
      
    }else if( all(grepl("SOUTH|EAST|NORTH|WEST", toupper(Coor_Info)))==T){
      
      South.id = grep('SOUTH',toupper(Coor_Info))
      North.id = grep('NORTH',toupper(Coor_Info))
      East.id = grep('EAST',toupper(Coor_Info))
      West.id = grep('WEST',toupper(Coor_Info))
      Details_ori<-Location_Info
      
      South_ori<-strsplit(Coor_Info,"=")[[South.id]][2]
      North_ori<-strsplit(Coor_Info,"=")[[North.id]][2]
      East_ori<-strsplit(Coor_Info,"=")[[East.id]][2]
      West_ori<-strsplit(Coor_Info,"=")[[West.id]][2]
      
      if(length(Details_ori)>1){
        Details<-Details_ori[1:length(Details_ori)]
        South<-strsplit(South_ori,",")[[1]]
        North<-strsplit(North_ori,",")[[1]]
        East<-strsplit(East_ori,",")[[1]]
        West<-strsplit(West_ori,",")[[1]]
  
      }else{
        Details<-Location_Info
        South<-strsplit(Coor_Info,"=")[[South.id]][2]
        North<-strsplit(Coor_Info,"=")[[North.id]][2]
        East<-strsplit(Coor_Info,"=")[[East.id]][2]
        West<-strsplit(Coor_Info,"=")[[West.id]][2]
       
      }
      
      Spatial_Info<-data.frame(South,North,East,West,Details) 
      Spatial_Info_1<-Spatial_Info
      
      
      
      
    }
  }    
 
  tkmessageBox(title = "Spatial Information Confirmation",
               message = apply(rbind(paste('Location',c(1:dim(head(Spatial_Info_1))[1]),':',sep=''),do.call(rbind,(head(Spatial_Info_1)))),2, paste, collapse='\n'),
               icon = "info", type = "ok")

  Spatial_Feature<-list()
  for(irow in 1:dim(Spatial_Info_1)[1]){
    if(dim(Spatial_Info_1)[2]==5){
      spatial_info<-data.frame(name="Northwest",latitude=as.numeric(Spatial_Info_1[irow,2]),longitude=as.numeric(Spatial_Info_1[irow,4]))
      spatial_info[2,]<-c(name="Southeast",as.numeric(Spatial_Info_1[irow,1]),as.numeric(Spatial_Info_1[irow,3]))
    } else if(dim(Spatial_Info_1)[2]==3){
      spatial_info<-data.frame(name="Northwest",latitude=as.numeric(Spatial_Info_1[irow,1]),longitude=as.numeric(Spatial_Info_1[irow,2]))
      spatial_info[2,]<-c(name="Southeast",as.numeric(Spatial_Info_1[irow,1]),as.numeric(Spatial_Info_1[irow,2]))
    }
    spatial_info[,c(2,3)] <- data.frame(lapply(spatial_info[,c(2,3)], function(x) ifelse(!is.na(as.numeric(x)), as.numeric(x),  x)))
    geo<-spatial_info%>% purrr::transpose()
    geo<-list()
    geo<-c(geo,list(spatial_info%>% purrr::transpose()))
    names(geo)<-"geo"
    description<-data.frame(description=Spatial_Info_1[irow,3])
    Spa_description<-description%>% purrr::transpose()
    Spatial_Feature[[irow]]<-c( description,geo)
  }
  

  ## replace 
  My$ '@id'<-Data_DOI
  ##  2 options 1.reference doi or "blank"
  My$name<-Paper_Title
  
  #############
  
  My$description<-Data_Abs
  
  
  if(any(grepl("'",My$description))==T){
    My$description<- gsub("'", "'", My$description, ignore.case = TRUE)
  }
  
  if(any(grepl("'",My$measurementTechnique))==T){
    My$description<- gsub("'", "'", My$description, ignore.case = TRUE)
  }
  
  if(any(grepl("'",My$description))==T){
    My$description<- gsub("'", "'", My$description, ignore.case = TRUE)
  }
  
  if(any(grepl("'",My$description))==T){
    My$description<- gsub("'", "'", My$description, ignore.case = TRUE)
  }
 
  ######################
  My$creator<-Data_Creator_list
  My$datePublished<-Publish_date # blank or if you have the specific date
  My$keywords<-data_keywords
  My$variableMeasured<-data_variables
  My$temporalCoverage$startDate<-Data_Start
  My$temporalCoverage$endDate<-Data_End
  My$award<-DOE_Contacts
  ##################################
  My$measurementTechnique<-Technique_Measure
  
  if(any(grepl("'",My$measurementTechnique))==T){
    My$measurementTechnique<- gsub("'", "'", My$measurementTechnique, ignore.case = TRUE)
  }
  
  if(any(grepl("'",My$measurementTechnique))==T){
    My$measurementTechnique<- gsub("'", "'", My$measurementTechnique, ignore.case = TRUE)
  }
  
  if(any(grepl("'",My$measurementTechnique))==T){
    My$measurementTechnique<- gsub("'", "'", My$measurementTechnique, ignore.case = TRUE)
  }
  
  if(any(grepl("'",My$measurementTechnique))==T){
    My$measurementTechnique<- gsub("'", "'", My$measurementTechnique, ignore.case = TRUE)
  }
  

  #############################################
  My$citation<-Refer
  My$editor$givenName<-Data_Creator_list[Contact.Name.Index,"givenName"]
  My$editor$familyName<-Data_Creator_list[Contact.Name.Index,"familyName"]
  My$editor$affiliation<-Data_Creator_list[Contact.Name.Index,"affiliation"]
  My$editor$email<-Data_Creator_list[Contact.Name.Index,"email"]
  My$editor$"@id"<-Data_Creator_list[Contact.Name.Index,"@id"] 
  My$spatialCoverage<-Spatial_Feature

  if(grepl("Public", Data_Usage)==T){
    My$license<-"https://creativecommons.org/publicdomain/zero/1.0/"
  } else{
    My$license<-"http://creativecommons.org/licenses/by/4.0/"
  }
  
  
  #################################################################
  ## Push to server
  #################################################################
  # token="eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJodHRwOlwvXC9vcmNpZC5vcmdcLzAwMDAtMDAwMi0yMzcxLTgxNVgiLCJmdWxsTmFtZSI6Ikh1aWZlbiBaaG91IiwiaXNzdWVkQXQiOiIyMDIzLTA0LTI3VDExOjM0OjE5LjIxMiswMDowMCIsImNvbnN1bWVyS2V5IjoidGhlY29uc3VtZXJrZXkiLCJleHAiOjE2ODI2NjAwNTksInVzZXJJZCI6Imh0dHA6XC9cL29yY2lkLm9yZ1wvMDAwMC0wMDAyLTIzNzEtODE1WCIsInR0bCI6NjQ4MDAsImlhdCI6MTY4MjU5NTI1OX0.iB_C3fhZD8DVHGcE5yVgFa-SN7Tq153hqlt3DnYOVIUk-aKVuMAIi_wy6eh88gJsjJVxJ6_-l3FH5ahoZFtPVWwWT3cdBlgQtXkP1HF3Qa9lyLmq2bxsy_v8J9HbOJ7zryBtM1xmcruYuiWBZzKSZrMWCsMAlnGEixTUW7ZGPwe7VCPDA3XiKGs7GSPFCGggnIag8qjYyJ5mjLHjVzDrZ1Al-dm5Ays6ICujWQJ7k4AcadzZn6fS5Uh7AkbuS8f3_Fsm9mVCf7gg4albSeAunwqy7A3_-dJMpElLcphoyL9H4OT5lXuB_UnPLnnhAM6JIkDjrh0frDBKm67v4wv07w"
  header_authorization <- paste("bearer",token, sep=" ")
  endpoint <- "packages"
  
  Data_Path<-package_path
  UpFolder<-strsplit(Data_Path,"/")[[1]][length(strsplit(Data_Path,"/")[[1]])]
  
  ## The important thing:
  ## keep the total file path's characters are less than 255
  ## Data_Files<-list.files(Data_Path,pattern="*.*",full.names = TRUE,recursive = TRUE) 
  
  
  # Data_Files[which(nchar(Data_Files)>=255)] (https://stackoverflow.com/questions/31574761/r-doesnt-see-a-file-that-exists-on-a-disk)
  
  
  
  if(stringr::str_detect(Data_Path, '.zip')){
    
    Data_Files <- Data_Path
    
  } else{
    
    Data_Files <- dir( Data_Path, full.names = TRUE,recursive = TRUE)
    
  }

  # Check_File_char_length=length(which(nchar(Data_Files)>=255))
  # 
  # if((Check_File_char_length>0)==T & ((toupper(zip_file)=='NO')==T)){
  #   File_lists<-Data_Files[which(nchar(Data_Files)>=255)]
  #   tlk=tkmessageBox(title = "Error",
  #                message = paste("Please short your file path listed below, and keep the total characters less than 255",File_lists,collapse='\n'), 
  #                icon = "error", type = "ok")
  # 
  # } 
  #  if(length(Data_Files)==0){
  #     tkmessageBox(title = "Error",
  #                  message = paste("Please provide the uploading files are in ",Data_Path,collapse='\n'), 
  #                  icon = "error", type = "ok")
  # 
  #   } else{
  #     tkmessageBox(title = "Uploading Files Confirmation",
  #                  message = paste("All the folder under folder:",Data_Path,"will be uploaded to ESS-DIVE",collapse='\n'), 
  #                  icon = "info", type = "ok") 
  #   }
  
  Check_File_char_length=all((nchar(Data_Files)>=255))
  
  if(T %in% Check_File_char_length & ((toupper(zip_file)=='NO')==T)){
    File_lists<-Data_Files[which(nchar(Data_Files)>=255)]
    tlk=tkmessageBox(title = "Error",
                     message = paste("Please shorten your file path listed below, and keep the total characters less than 255",File_lists,collapse='\n'), 
                     icon = "error", type = "ok")
    
  } 
  if(length(Data_Files)==0){
    tkmessageBox(title = "Error",
                 message = paste("There are no files in ",Data_Path, ". Please provide the correct file path.", collapse='\n'), 
                 icon = "error", type = "ok")
    
  } else{
    tkmessageBox(title = "Uploading Files Confirmation",
                 message = paste("All the files in folder:",Data_Path,"will be uploaded to ESS-DIVE",collapse='\n'), 
                 icon = "info", type = "ok") 
  }
  
   
   ############# 
   ##
   #############
    # files2zip <- dir( Data_Path, full.names = TRUE)
  files2zip <- list.files(Data_Path, full.names = TRUE)
    #files2zip=files2zip[c(1,2,4,5,6)]
  
  if(any(stringr::str_detect(Data_Files, '.zip'))){
    
    up_Files<-str_subset(Data_Files, ".zip")
    
  } else if ((toupper(zip_file)=='YES')==T){
      zip::zipr(zipfile = paste(Data_Path,".zip",sep=""), files =files2zip ,include_directories = TRUE)
      up_Files<-paste(Data_Path,".zip",sep="")
      
    }else if((toupper(zip_file)=='NO')==T){

        
      up_Files<-Data_Files[which(nchar(Data_Files)>=255)]
        
        
	  if ((Check_File_char_length>0)==T ){
	  tlk=tkmessageBox(title = "Error",
                 message = paste("The file: ",File_lists,"is NOT uploaded",collapse='\n'), 
                 icon = "error", type = "ok")
	  }
     
      }else {
      tlk = tkmessageBox(title = "Error",
                   message = paste("Please select zip file or not in JSON file:", json_input,sep="\n"),
                   icon = "error", type = "ok")
 	if(as.character(tlk)=='ok'){
	 stop()
	}
    }
    

  ###########################################################################
  ###########################################################################
 #  API_website="https://api-sandbox.ess-dive.lbl.gov/"
  json_file<-as_json(My) 
  call_post_package <- paste(API_website,"/",endpoint,"/", sep="")
  
  params=list()
  for (file in up_Files) {
    params <- append(params, list(data= form_file(path = file)))
  }
  
  post_package = POST(call_post_package, 
                      body= list.prepend("json-ld"=json_file ,params ) ,
                      #  encode = "json", verbose(),
                      add_headers(Authorization=header_authorization, 
                                  "Content-Type"="multipart/form-data")
                      # "Content-Type"="application/json")              
  ) 
  #post_package
  #content(post_package)$viewUrl
  #print(content(post_package)$errors)
  
  return(post_package)
}

# //pnl/projects/sbr_sfa/00_Cross-SFA_ESSDIVE-Data-Package-Upload/02_Data-Package_Rscript//SFA_Default.jsonld

