# Assignment: Getting and Cleaning Data Course Project

# Check to see if folder exists
if(!file.exists("../data")){dir.create("../data")}

library(downloader)
###################################
#### 0. Read data
# Define data source location for the project:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
fileUrl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download(fileUrl, dest="dataset.zip", mode="wb") 
unzip ("dataset.zip", exdir = "../data")

###################################
#### 1. Merges the training and the test sets to create one data set for each of X, Y and subject.

tmp1 <- read.table("../data/UCI HAR Dataset/train/X_train.txt")
tmp2 <- read.table("../data/UCI HAR Dataset/test/X_test.txt")
# Concatenates the two files
X <- rbind(tmp1, tmp2)

tmp1 <- read.table("../data/UCI HAR Dataset/train/subject_train.txt")
tmp2 <- read.table("../data/UCI HAR Dataset/test/subject_test.txt")
# Concatenates the two files
S <- rbind(tmp1, tmp2)

tmp1 <- read.table("../data/UCI HAR Dataset/train/y_train.txt")
tmp2 <- read.table("../data/UCI HAR Dataset/test/y_test.txt")
# Concatenates the two files
Y <- rbind(tmp1, tmp2)

#### 2. Extracts only the measurements (rows) on the mean and standard deviation (cols) for each measurement.
# Look at the file named features.txt. 
# Here is a list with the variable names (columns) used originally in X_train and X_test tables.
# Remember you have added two columns (subject ids
# and activity names) to your new data set!

features <- read.table("../data/UCI HAR Dataset/features.txt")
# get indicies for columns that contain the string mean() or std()
indices_of_good_features <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
# take from X only the columns that correspond to these indicies
X <- X[, indices_of_good_features]

#create shortened file with only relevant rows
#featuresshort <- features[indices_of_good_features,]
# remove brackets
#featuresshort <- gsub("\\(|\\)", "", featuresshort[,2])
#str(featuresshort)
# Split column by delimiter
#out <- strsplit(featuresshort, "-",fixed=TRUE)
#str(out)

# Assign to X column names defined by good indicies
names(X) <- features[indices_of_good_features, 2]
# remove brackets from names
names(X) <- gsub("\\(|\\)", "", names(X))
# set all names to lower case - c.f.last slide of the lecture Editing Text Variables (week 4)
names(X) <- tolower(names(X))  

names(X) <- gsub("^f", "frequency", names(X))
names(X) <- gsub("^t", "time", names(X))
names(X) <- gsub("acc", "acceleration", names(X))
names(X) <- gsub("-y", "Y-axis", names(X))
names(X) <- gsub("-x", "X-axis", names(X))
names(X) <- gsub("-z", "Z-axis", names(X))

#### 3. Uses descriptive activity names to name the activities in the data set
activities <- read.table("../data/UCI HAR Dataset/activity_labels.txt")
# remove underscores
activities[, 2] = gsub("_", "", as.character(activities[, 2]))
# set all names to lower case - c.f.last slide of the lecture Editing Text Variables (week 4)
activities[, 2] = tolower(activities[, 2])

# apply activity names to Y
Y[,1] = activities[Y[,1], 2]
# give name to column in Y
names(Y) <- "activity"

#### 4. Appropriately labels the data set with descriptive activity names.
# give name to column in S
names(S) <- "subject"

# column bind S, Y and X
cleaned <- cbind(S, Y, X)
str(cleaned)
write.table(cleaned, "../data/merged_clean_data.txt",row.name=FALSE)

#### 5. Creates a 2nd, independent tidy data set with the average of each variable for each activity and each subject.
library(dplyr)

summaryaverages <- cleaned %>% group_by(activity,subject) %>% summarise_each(funs(mean))

dim(summaryaverages)

write.table(summaryaverages, "../data/summary_clean_data.txt",row.name=FALSE)
