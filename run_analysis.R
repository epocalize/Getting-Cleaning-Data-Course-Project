## This R script does the following:
        ## 1. Merges the training and test sets to create one data set
        ## 2. Extracts only the measurements on the mean and standard deviation for each measurement
        ## 3. Uses descriptive activity names to name the activities in the data set.
        ## 4. Appropriately labels the data set with descriptive variable names. 
        ## 5. Creates a second, independent tidy data set with the average of each variable 
        ##    for each activity and each subject.

## Install required packages

if (!require("reshape2")) {
        install.packages("reshape2")
        require("reshape2")
}

## Load the necessary data sets
test_subject <- read.table("./test/subject_test.txt")
test_data <- read.table("./test/X_test.txt")
test_labels <- read.table("./test/Y_test.txt")

train_subject <- read.table("./train/subject_train.txt")
train_data <- read.table("./train/X_train.txt")
train_labels <- read.table("./train/Y_train.txt")

featuresList <- read.table("./features.txt", stringsAsFactors = FALSE)
activity_labels <- read.table("./activity_labels.txt")

## Combine test and training datasets 
data <- rbind(test_data, train_data)
colnames(data) <- features[, 2]

## Combine test and training subjects
subject <- rbind(test_subject, train_subject)
colnames(subject) <- "subject"

## Combine test and training labels
labels <- rbind(test_labels, train_labels)
activity <- merge(labels, activity_labels, by = 1)[, 2]

## Final merge
data <- cbind(subject, activity, data)

## Create dataset with only means and standard deviations
search <- grep("-mean|-std", colnames(data))
desired_data <- data[, c(1, 2, search)]

## Group by subject/label
melted = melt(desired_data, id.var = c("subject", "activity"))
tidy = dcast(melted, subject + activity ~ variable, mean)

## Apply descriptive variable names

headervalues <- names(tidy)

headervalues <- sub("^t", "Time", headervalues)
headervalues <- sub("^f","Frequency", headervalues)
headervalues <- sub("Acc","Accelerometer", headervalues)
headervalues <- sub("-mean..","Mean", headervalues)
headervalues <- sub("-X","Xaxis", headervalues)
headervalues <- sub("-Y","Yaxis", headervalues)
headervalues <- sub("-Z","Zaxis", headervalues)
headervalues <- sub("-std..","StandardDeviation", headervalues)
headervalues <- sub("Gyro","Gyroscope", headervalues)
headervalues <- sub("BodyBody","Body", headervalues)
headervalues <- sub("Mag","Magnitude", headervalues)
headervalues <- sub("Group.1","subject", headervalues)
headervalues <- sub("Group.2","activity", headervalues)

headervalues -> names(tidy)

## Save dataset
write.table(tidy, file="./tidy_data.txt", row.name = FALSE)
