#Merges the training and the test sets to create one data set.
#Extracts only the measurements on the mean and standard deviation for each measurement. 
#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names. 
#Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

install.packages("dplyr")
require(dplyr)

#Download and unzip file
if(!file.exists("./data/samsung")){dir.create("./data/samsung")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile ="./data/samsung/samsung.zip"
download.file(fileUrl,destfile=destfile,method="curl")
unzip(destfile,exdir="./data/samsung/")

#Get variable names from features.txt and clean-up
myvars <- read.table("./data/samsung/UCI HAR Dataset/features.txt",header=FALSE)[,2]
myvars <- gsub("\\(|\\)|,","",myvars)
myvars <- gsub("-",".",myvars)
myvars <- sub("^t","time",myvars)
myvars <- sub("^f","frequency",myvars)

#Get train and test data sets
train <- read.table("./data/samsung/UCI HAR Dataset/train/X_train.txt",header=FALSE,col.names=myvars)
test <- read.table("./data/samsung/UCI HAR Dataset/test/X_test.txt",header=FALSE,col.names=myvars)

#Keep only mean and std measurements
varsinc <- myvars[grep("mean$|std$",myvars)]
test <- test[varsinc]
train <- train[varsinc]

#Add subjects to data frames
train$subject <- read.table("./data/samsung/UCI HAR Dataset/train/subject_train.txt",header=FALSE)[,1]
test$subject <- read.table("./data/samsung/UCI HAR Dataset/test/subject_test.txt",header=FALSE)[,1]

#Add activity to data frames
train$activity <- read.table("./data/samsung/UCI HAR Dataset/train/y_train.txt",header=FALSE)[,1]
test$activity <- read.table("./data/samsung/UCI HAR Dataset/test/y_test.txt",header=FALSE)[,1]

#Merge train and test data frames
all <- rbind( train, test)

#Use descriptive activity names to name the activities in the data set
activitycategories <- read.table("./data/samsung/UCI HAR Dataset/activity_labels.txt",header=FALSE,col.names=c("activity","activityname"))
all <- inner_join(all,activitycategories,"activity")

all$subject <- factor(all$subject)

#Create a second, independent tidy data set with the average of each variable for each activity and each subject

allaggregated <- (aggregate(all[varsinc], list(Activity = all$activityname, Subject = all$subject),mean))

write.table(allaggregated,file = "./tidy.out",col.names = TRUE,row.names=FALSE)

