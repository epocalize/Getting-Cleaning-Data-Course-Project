## This R script does the following:
## Step 1. Merges the training and test sets to create one data set
## Step 2. Extracts only the measurements on the mean and standard deviation for each measurement
## Step 3. Uses descriptive activity names to name the activities in the data set.
## Step 4. Appropriately labels the data set with descriptive variable names. 
## Step 5. Creates a second, independent tidy data set with the average of each variable 
##    for each activity and each subject.


## Load the necessary data sets
test_subject <- read.table("./test/subject_test.txt")
test_data <- read.table("./test/X_test.txt")
test_labels <- read.table("./test/Y_test.txt")

train_subject <- read.table("./train/subject_train.txt")
train_data <- read.table("./train/X_train.txt")
train_labels <- read.table("./train/Y_train.txt")

featuresList <- read.table("./features.txt", stringsAsFactors = FALSE)

activities <- read.table("./activity_labels.txt")

## Combine test and training datasets (step 1)
data <- rbind(test_data, train_data)

## Combine test and training subjects
subjects <- rbind(test_subject, train_subject)

## Combine test and training labels
labels <- rbind(test_labels, train_labels)

## Extract names from features list
features <- featuresList$V2

## Extract mean and standard deviation columns (step 2)
keepColumns <- grepl("-mean|-std[^F]", features, perl = TRUE)

## Rename
data <- data[, keepColumns]
names(data) <- features[keepColumns]

## Apply descriptive activity names (step 3)
activities[, 2] = gsub("_", "", tolower(as.character(activities[, 2])))
labels[, 1] = activities[labels[, 1], 2]
names(labels) <- "activity"
names(subjects) <- "subject"

## Create tidy data set
tidyData <- cbind(subjects, labels, data)

## Apply descriptive variable names (step 4)
headervalues <- names(tidyData)

headervalues <- sub("^t", "Time", headervalues)
headervalues <- sub("^f","Freq", headervalues)
headervalues <- sub("-mean..","Mean", headervalues)
headervalues <- sub("-X","Xaxis", headervalues)
headervalues <- sub("-Y","Yaxis", headervalues)
headervalues <- sub("-Z","Zaxis", headervalues)
headervalues <- sub("-std..","StdDev", headervalues)
headervalues <- sub("BodyBody","Body", headervalues)

headervalues -> names(tidyData)

## Create second tidy data set with average of each variable for each activity and each subject
## (step 5)
uS = unique(subjects)[, 1]
nS = length(uS)
nA = length(activities[, 1])
nC = length(names(tidyData))
td = tidyData[1:(nS*nA), ]

row = 1
for (s in 1:nS) {
        for (a in 1:nA) {
                td[row, 1] = uS[s]
                td[row, 2] = activities[a, 2]
                tmp <- tidyData[tidyData$subject==s & tidyData$activity==activities[a,2], ]
                td[row, 3:nC] <- colMeans(tmp[ ,3:nC])
                row = row + 1
        }
}

## Save tidy data set
write.table(td, file="./tidy_data.txt", row.name = FALSE)
