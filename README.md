---
title: "README"
output: html_document
---
#The code is broken into the following sections:

##Load Libraries
Loads the dplyr library, which will be used in the final step before writing the text file.
```
library(dplyr)
```

##Download Data
First, it checks whether the data already exists. It then downloads, unzips, and removes the zip file.
```
if(!dir.exists("./UCI HAR Dataset/") & !file.exists("project_files.zip")){
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","project_files.zip")
}
unzip("project_files.zip")
if(file.exists("project_files.zip")){
  file.remove("project_files.zip")
}
```

##Read Tables
Each relevant text file is read in as a separate table.
```
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
features <- read.table("./UCI HAR Dataset/features.txt")
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")
```

##Combine Columns
The subjects ID column is combined with the Y data column (activity ID) and the X data columns (measurement variables) for both the training and test datasets.
```
allTrain <- cbind(subjectTrain,yTrain,xTrain)
allTest <- cbind(subjectTest,yTest,xTest)
```

##Combine Rows (Test and Train)
The training and test datasets are combined.
```
allData <- rbind(allTrain,allTest)
```

##Add variable names
The measurement variable names are read and then added as column names to the dataset.
```
variables <- as.character(features[,2])
columnNames <- c("subject", "activity.id", variables) #adds subject and activity variables
colnames(allData) <- columnNames
```

##Add activity names for each observation
The table linking the activity names and activity IDs is joined to the dataset.
```
colnames(activities) <- c("activity.id", "activity")
allData <- merge(activities, allData, by="activity.id")
```

##Subset out mean() and std() variables
The mean and standard deviation variables are retained, while all other measurement variables are removed.
```
meanColumns <- grep("mean\\(\\)|std\\(\\)", names(allData))
usefulColumns <- c(1,2,3,meanColumns) #include activity and subject columns
meanData <- allData[,usefulColumns]
```

##Clean column names
The column names are cleaned up to remove parentheses and hyphens.
```
colnames(meanData) <- gsub("-", ".", gsub("\\)", "", gsub("\\(", "", colnames(meanData))))
```

##Find variable means by subject and activies using dplyr
The dataset is grouped by activity and subject, and then the mean for each measurement variable is calculated for each group.
```
tidyMeans <- meanData %>% group_by(activity.id,subject,activity) %>% summarize_all(mean)
tidyMeans <- as.data.frame(tidyMeans)
```

##Write output to text file
The dataset is written to a text file.
```
write.table(tidyMeans, "tidyMeans.txt", row.names = FALSE)
```

