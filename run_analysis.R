# load libraries
library(readr)
library(stringr)
library(dplyr)
library(tidyr)

# path to data
path_data <- "./UCI HAR Dataset/"
path_test <- paste0(path_data, "test/")
path_train <- paste0(path_data, "train/")

# load features names 
features_names <- read_delim(paste0(path_data,"features.txt"), 
                             delim = " ", 
                             col_names = c("number", "name"),
                             col_types = cols(
                               number = col_skip(),
                               name = col_character()
                             ))

# selecting columns indexes to extract with mean() and std() in name
extract_cols <- which(str_detect(features_names$name,"mean\\(\\)|std\\(\\)"))

# remove "-,()" characters
features_names <-
  features_names %>%
  mutate(name = gsub("-", "", name)) %>%
  mutate(name = gsub("[\\,\\(\\)]", "", name)) %>%
  mutate(name = gsub("mean", "Mean", name)) %>%
  mutate(name = gsub("std", "Std", name)) %>%
  mutate(name = gsub("^t", "time", name)) %>%
  mutate(name = gsub("^f", "freq", name)) 
  
# selecting columns names to extract
extract_names <- features_names$name[extract_cols]

# load activity labels
activity_labels <- read_delim(paste0(path_data,"activity_labels.txt"), 
                             delim = " ", 
                             col_names = c("number", "activity"),
                             col_types = cols(
                               number = col_skip(),
                               activity = col_character()
                             ))

# change chars to lower
activity_labels <-
  activity_labels %>%
  mutate(activity = tolower(activity)) %>%
  mutate(activity = gsub("upstairs", "Up", activity)) %>%
  mutate(activity = gsub("downstairs", "Down", activity)) %>%
  mutate(activity = gsub("_", "", activity))

# load test data
test_measuremants <- read_fwf(paste0(path_test, "X_test.txt"),
                       fwf_widths(rep(16, times = 561)),
                          #col_names = features_names$name
                          col_types = cols (.default = col_double())
                       )

# read test activity data
test_activity <- read_table(paste0(path_test, "y_test.txt"),
                            col_names = ("activity"),
                            cols(
                              activity = col_integer()
                            ))

# load test subject data
test_subject <- read_table(paste0(path_test, "subject_test.txt"),
                           col_names = ("subject"),
                           cols(
                             subject = col_integer()
                           ))

#load train data
train_measuremants <- read_fwf(paste0(path_train, "X_train.txt"),
                        fwf_widths(rep(16, times = 561)),
                        col_types = cols (
                          .default = col_double()
                        ))

# read train activity data
train_activity <- read_table(paste0(path_train, "y_train.txt"),
                            col_names = ("activity"),
                            cols(
                              activity = col_integer()
                            ))

# load train subject data
train_subject <- read_table(paste0(path_train, "subject_train.txt"),
                             col_names = ("subject"),
                             cols(
                               subject = col_integer()
                             ))

# bind test subject, activity measuremants data into one dataset
test_data <- bind_cols(test_subject, test_activity, test_measuremants)

# bind train subject, activity measuremants data into one dataset
train_data <- bind_cols(train_subject, train_activity, train_measuremants)

# bind data into one dataset
activity_data <- bind_rows(test_data, train_data)

# extract columns from test data first two and numeric variables to extract
activity_data_1 <- activity_data[,c(1, 2, extract_cols + 2)]

# label activities with names 
activity_data_2 <- 
  activity_data_1 %>%
  mutate(activity = activity_labels$activity[activity])

# set descriptive column names, first two and numeric variables to extract
colnames(activity_data_2)<-c("subject", "activity", extract_names)

# grouping by subject and activity
activity_data_2 <- group_by(activity_data_2, activity, subject )

# summarizing data to obtain avarage values
activity_sum <- summarize_all(activity_data_2, mean)

# write data do file
write.table(activity_sum, file = "activity_sum.csv", row.name=FALSE)