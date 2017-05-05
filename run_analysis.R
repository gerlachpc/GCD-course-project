#-------Load Libraries-----
library(dplyr)

#--------Download Data-------
if(!dir.exists("./UCI HAR Dataset/") & !file.exists("project_files.zip")){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","project_files.zip")
}
unzip("project_files.zip")
if(file.exists("project_files.zip")){
  file.remove("project_files.zip")
}

#--------Read Tables--------
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
features <- read.table("./UCI HAR Dataset/features.txt")
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")

#------Combine Columns--------
allTrain <- cbind(subjectTrain,yTrain,xTrain)
allTest <- cbind(subjectTest,yTest,xTest)

#------Combine Rows(Test and Train)------
allData <- rbind(allTrain,allTest)

#------Add variable names--------
variables <- as.character(features[,2])
columnNames <- c("subject", "activity.id", variables) #adds subject and activity variables
colnames(allData) <- columnNames

#------Add activity names for each observation-------
colnames(activities) <- c("activity.id", "activity")
allData <- merge(activities, allData, by="activity.id")

#-----Subset out mean() and std() variables--------
meanColumns <- grep("mean\\(\\)|std\\(\\)", names(allData))
usefulColumns <- c(1,2,3,meanColumns) #include activity and subject columns
meanData <- allData[,usefulColumns]

#-----Clean column names--------
colnames(meanData) <- gsub("-", ".", gsub("\\)", "", gsub("\\(", "", colnames(meanData))))

#-----Find variable means by subject and activies using dplyr-----
tidyMeans <- meanData %>% group_by(activity.id,subject,activity) %>% summarize_all(mean)
tidyMeans <- as.data.frame(tidyMeans)

#-----Write output to text file---------
write.table(tidyMeans, "tidyMeans.txt", row.names = FALSE)
