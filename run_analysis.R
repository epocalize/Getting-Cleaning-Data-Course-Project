## This R script does the following:
        ## 1. Merges the training and test sets to create one data set
        ## 2. Extracts only the measurements on the mean and standard deviation for each measurement
        ## 3. Uses descriptive activity names to name the activities in the data set.
        ## 4. Appropriately labels the data set with descriptive variable names. 
        ## 5. Creates a second, independent tidy data set with the average of each variable 
        ##    for each activity and each subject.

## Install required packages
if (!require("dplyr")) {
        install.packages("dplyr")
        require("dplyr")
}
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

features <- read.table("./features.txt")
activity_labels <- read.table("./activity_labels.txt")

## Merge the test and training subject datasets
subject <- rbind(test_subject, train_subject)
colnames(subject) <- "subject"

## Merge and label the test and training labels
label <- rbind(test_labels, train_labels)
label <- merge(label, activity_labels, by = 1)[, 2]

## Merge and label test and training datasets 
data <- rbind(test_data, train_data)
colnames(data) <- features[, 2]

## Final merge
data <- cbind(subject, label, data)

## Create dataset with only means and standard deviations
search <- grep("-mean|-std", colnames(data))
desired_data <- data[, c(1, 2, search)]

## Group by subject/label
melted = melt(desired_data, id.var = c("subject", "label"))
tidy = dcast(melted, subject + label ~ variable, mean)

## Save dataset
write.table(tidy, file="./tidy_data.txt")
