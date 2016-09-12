# Coursera - Getting and Cleaning Data - final assignment

# script to create 2 tidy data sets from data collected from the accelerometers of
# Samsung Galaxy S smartphone

# in general this script does the following: 
# 1. - Downloads, unzips and reads desired files into R
# 2. - Merges the training and the test data sets along with subject and activity labels to create
#    one data set.
#    - Appropriately labels the data set with descriptive variable names.
#    - Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. - Uses descriptive activity names to name the activities in the data set
# 4. - From the data set in step 3, creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.
# 5. - views the resulting two tidy data sets
# 6. save the "tt_comb_sum" table as a csv file to be submitted 

library(data.table)
library(dplyr)

## 1. downloading and extracting all files into R

        # check to see if folder for data already exists if not create one 
        if (!file.exists("GCwk4assignment_data")) {
                dir.create("GCwk4assignment_data")
        }
        
        # set working directory to new data folder
        setwd("./GCwk4assignment_data")
        getwd()
        
        #download zip files (first checks to see if file exists already)
        if (!file.exists("smart_act.zip")) {
                zipfile<-download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                                       destfile = "smart_act.zip")
        }
        
        # Note when data was downloaded
        date_download<-date()
        
        # unzip file and return list of contained folders and files to determine what I want to extract
        zipfiles<-unzip("smart_act.zip", list = TRUE) # note - this does not actually unzip contents only creates a list of contents
        
        # unzip contents of zipped folder
        unzip("smart_act.zip")
        
        # reset working directory to create list of  "train" files to extract
        setwd("./UCI HAR Dataset/train")
        dir()
        train<-dir()[c(2,3,4)]
        
        # read txt files into R assigning each file to a new object with the same name as the file name
        for(i in train){
                assign(i, read.table(i))    
        }
        
        # reset working directory to create list of  "test" files to extract
        setwd("../")
        setwd("./test")
        dir()
        test<-dir()[c(2,3,4)]
        
        # read txt files into R assigning each file to a new object with the same name as the file name
        for(i in test){
                assign(i, read.table(i))    
        }
        
        # reset working directory to create list of info and label files to extract
        setwd("../")
        dir()
        info<-dir()[c(1,2,3,4)]
        
        # read txt files into R assigning each file to a new object with the same name as the file name
        for(i in info){
                assign(i, read.table(i))    
        }
        

## 2. Merging data, selecting mean and standard deviation and relabeling
        
        #combine test and train data sets
        test_train<-bind_rows(X_test.txt, X_train.txt)
        
        # rename all columns with feature.txt file
        colnames(test_train)<-features.txt[,2]
        
        # identify variables which contain "mean" or "std" in features.txt file
        tt_m_s_labels<-grep("mean|std", colnames(test_train))
        
        # select variables in test_train data set with "mean" and "std" in name
        tt_m_s<-test_train[,tt_m_s_labels]
        
        #combine test and train activity labels and change col name
        tt_act<-bind_rows(y_test.txt, y_train.txt)
        colnames(tt_act)<-"activity"
     
        #combine test and train subject labels and change col name
        tt_sub<-bind_rows(subject_test.txt, subject_train.txt)
        colnames(tt_sub)<-"subject"
        
        #combine subject and activity labels to combined test_train data 
        tt_comb<-bind_cols(tt_sub, tt_act, tt_m_s)
        
## 3. add names to factors in activity variable
        tt_comb$activity<-factor(tt_comb$activity)
        levels(tt_comb$activity)<-c("walking", "walking_upstairs", "walking_downstairs", "sitting", "standing", "laying")
        
# 4. From the data set in step 3, create a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.
        tt_comb_sum<-tt_comb %>% group_by(subject, activity) %>% summarise_each(funs(mean))
        
# 5. view final data sets to ensure that the script worked the way I planned
View(tt_comb)
View(tt_comb_sum)

# 6. save the "tt_comb_sum" table to be submitted 
setwd("../")
write.csv(tt_comb_sum, file = "summary_activity_data.csv")
