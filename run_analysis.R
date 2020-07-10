library(dplyr)

if(!file.exists("getdata_projectfiles_UCI HAR Dataset.zip")){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url,"getdata_projectfiles_UCI HAR Dataset.zip",method="curl")
  unzip("getdata_projectfiles_UCI HAR Dataset.zip")
}

past <- "UCI HAR Dataset"

valor <- paste(past, "features.txt", sep = "/")
feat <- read.table(valor, col.names = c("n","functions"))

valor <- paste(past, "train/X_train.txt", sep = "/")
xTrain <- read.table(valor, col.names = feat$functions)

valor <- paste(past, "test/X_test.txt", sep = "/")
xTest <- read.table(valor, col.names = feat$functions)

valor <- paste(past, "activity_labels.txt", sep = "/")
act <- read.table(valor, col.names = c("code", "activity"))

valor <- paste(past, "test/subject_test.txt", sep = "/")
subjecTest <- read.table(valor, col.names = "subject")

valor <- paste(past, "train/subject_train.txt", sep = "/")
subjecTrain <- read.table(valor, col.names = "subject")

valor <- paste(past, "train/y_train.txt", sep = "/")
yTrain <- read.table(valor, col.names = "code")

valor <- paste(past, "test/y_test.txt", sep = "/")
yTest <- read.table(valor, col.names = "code")

# Merges the training and the test sets to create one data set.
merged <- cbind(rbind(subjecTrain, subjecTest), rbind(yTrain, yTest), rbind(xTrain, xTest))

# Extracts only the measurements on the mean and standard deviation for each measurement.
tidy <- merged %>% select(subject, code, contains("mean"), contains("std"))

# Uses descriptive activity names to name the activities in the data set.
tidy$code <- act[tidy$code, 2]

# Appropriately labels the data set with descriptive variable names.
names(tidy)[2] = "activity"
names(tidy)<-gsub("^t", "Time", names(tidy))
names(tidy)<-gsub("^f", "Frequency", names(tidy))
names(tidy)<-gsub("angle", "Angle", names(tidy))
names(tidy)<-gsub("gravity", "Gravity", names(tidy))
names(tidy)<-gsub("Acc", "Accelerometer", names(tidy))
names(tidy)<-gsub("Gyro", "Gyroscope", names(tidy))
names(tidy)<-gsub("Mag", "Magnitude", names(tidy))
names(tidy)<-gsub("tBody", "TimeBody", names(tidy))
names(tidy)<-gsub("-mean()", "Mean", names(tidy), ignore.case = TRUE)
names(tidy)<-gsub("-std()", "StandarDeviation", names(tidy), ignore.case = TRUE)

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
data <- tidy %>% group_by(subject, activity) %>% summarise_all(funs(mean))

# Create the result.
write.table(data, "data.txt", row.name=FALSE)