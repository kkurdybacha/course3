Code Book for "Getting and Cleaning Data" Course Project
========================================================

This file describes datasets, variables and analysis performed in course project.

# Source data

Source data set was obtained using link given in assignment text: <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>.
Downloaded .zip archive contains one compressed directory, named "UCI HAR Dataset", with directories and files inside.

## Source data files
According source data readme file dataset includes following files (citation from README.txt):

>  - 'README.txt'
>  - 'features_info.txt': Shows information about the variables used on the feature vector.
>  - 'features.txt': List of all features.
>  - 'activity_labels.txt': Links the class labels with their activity name.
>  - 'train/X_train.txt': Training set.
>  - 'train/y_train.txt': Training labels.
>  - 'test/X_test.txt': Test set.
>  - 'test/y_test.txt': Test labels.

> The following files are available for the train and test data. Their descriptions are equivalent.

>  - 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample.
>    Its range is from 1 to 30. 
>  - 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X
>    axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for
>    the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 
>  - 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the
>    gravity from the total acceleration. 
>  - 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for
      each window sample. The units are radians/second. 

## Source data files inspection
Inspection of source data was performed before designing data processing and building R script.

### file README.txt
It describes data set revealing essence of experiment and explaining contents of files (citation from README.txt).

> The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. 
> Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
> wearing a smartphone (Samsung Galaxy S II) on the waist. 

We know from README file:
* signals are sensor data, some of them preprocessed by filtering out gravity signal
* signals are collected as 128 values window, and recorded one window in row 
* subject is volunteer, different volunteers participating in generating train and test data
* each record has 561 variables feature vector

### file activity_labels.txt
Each activity label has number. Activities are named as described in README.txt.
There are six activity labels. Each activity name consists of capital letters.

### file features_info.txt and features.txt
Features are variables derived from signals by processing collected values.

> * tBodyAcc-XYZ
> * tGravityAcc-XYZ
> * tBodyAccJerk-XYZ
> * tBodyGyro-XYZ
> * tBodyGyroJerk-XYZ
> * tBodyAccMag
> * tGravityAccMag
> * tBodyAccJerkMag
> * tBodyGyroMag
> * tBodyGyroJerkMag
> * fBodyAcc-XYZ
> * fBodyAccJerk-XYZ
> * fBodyGyro-XYZ
> * fBodyAccMag
> * fBodyAccJerkMag
> * fBodyGyroMag
> * fBodyGyroJerkMag

These signals are describing subject movement, part of feature name have meaning:

* first letter of the feature name "t" - time, "f" - frequency
* word "Gravity" or "Body" in feature name means itself
* part "Acc" denotes linear velocity
* part "Gyro" denotes angular velocity"
* part "Jerk" denotes linear or angular acceleration, respectively
* part "Mag" in the feature name denotes magnitude
* letter from set of "XYZ" denotes axis in space

From these signals where estimated variables:

> * mean(): Mean value
> * std(): Standard deviation
> * mad(): Median absolute deviation 
> * max(): Largest value in array
> * min(): Smallest value in array
> * sma(): Signal magnitude area
> * energy(): Energy measure. Sum of the squares divided by the number of values. 
> * iqr(): Interquartile range 
> * entropy(): Signal entropy
> * arCoeff(): Autorregresion coefficients with Burg order equal to 4
> * correlation(): correlation coefficient between two signals
> * maxInds(): index of the frequency component with largest magnitude
> * meanFreq(): Weighted average of the frequency components to obtain a mean frequency
> * skewness(): skewness of the frequency domain signal 
> * kurtosis(): kurtosis of the frequency domain signal 
> * bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
> * angle(): Angle between to vectors.

Name of feature consist of the name of signal and the name of variable.

According to assignment, only measurements on mean and standard deviation should be extracted.
This requirement points to features with "mean()" and "std()" in names.
There are features with "meanFreq()" but this weighted average, not mean, so these should be excluded from
resultant dataset.
There are features with word "Mean" in name (ex. "angle(tBodyGyroMean,gravityMean)" ), but these
are variables denoting angles not means themselves, so they should be excluded too. 

Examining values from file "features,txt" reveals:

* there are 561 feature names, consistently with README.txt
* parts of feature name are concatenated with hyphen (`-`)
* there are some duplicates among feature names, but all them should be excluded from final result 
* feature names contain characters not to be used in variable names: (),--
* significant parts of names begin with capital letter as in camelCase notation
* domain of feature is denoted by small letter as in Hungarian notation

### files train/X_train.txt, test/X_test.txt
Files contain 561 numbers in each row. Number of rows are different in each file.
Each number is written in 16 characters, files are fixed width format.

Conclusion: these files are storing values of variables to be processed in project.


### files train/y_train.txt, test/y_test.txt
According to README.txt these files store labels. Inspecting reveals that they have one value in each row, and values are from set of (1,2,3,4,5,6).
Each file has the same number of rows as corresponding X_train.txt/X_test.txt file.

Conclusion: these files are storing activity labels for each measurement.

### files train/subject_train.txt, test/subject_test.txt
According to README.txt each row of these files identifies subject, who performed experiment.
Each file has one values in each row, and it has the same number of rows as corresponding X_train.txt/X_test.txt file.

Conclusion: these files are storing subject identifiers for each measurement.

### files in directories "train/Inertial Signals/" and "test/Inertial Signals/"
According README.txt these files store signal values.
They contain 128 numeric values in each row, and they have the same number of rows as corresponding X_train.txt/X_test.txt file.
There are no labels for columns, because each file contains only one signal, so each column is not a variable,
but the same signal varying in time.

Conclusion: These files are not needed to complete assignment because they do not contain desirable values.

# Project requirements
There should be created script named "run_analysis.R" processing data to meet assignment requirements.
This chapter describes how these requirements will be met.

## Requirement 1: Merges the training and the test sets to create one data set
"train_data" dataset containing training data and "test_data" dataset containing test data are binded by bind_rows() into one dataset named "activity_data".

## Requirement 2: Extracts only the measurements on the mean and standard deviation for each measurement
List of features is common to training and test data. That list was analyzed together with its description.
In conclusion features with "mean()" and "std()" in name were specified as denoting desirable values. 
Assumption was made, that columns in source dataset are described by features list from left to right.
Resultant R script loads features list and it analyses which feature name contains above phrase. R script sets the vector "extract_cols" of column numbers and another vector "extract_names" with feature names for columns to be extracted. Vector "extract_cols" is then used to select proper columns from loaded source datasets.
There are 66 such columns.

## Requirement 3: Uses descriptive activity names to name the activities in the data set
Activity numbers loaded from "activity_labels.txt" into dataset "activity_labels" are converted to more readable labels as applying rules:

* All labels should be written in lowercase
* All labels should have similar length
* All labels and names should be written alike

All label where converted to lowercase. Second words of some labels where abbreviated and concatenated with first word using camelCase notation.

|  |  Original label  | New label       |
|-:|:----------------:|:---------------:|
|1.|      WALKING     |      walking    |
|2.| WALKING_UPSTAIRS |     walkingUp   |
|3.|WALKING_DOWNSTAIRS|    walkingDown  |
|4.|     SITTING      |      sitting    |
|5.|    STANDING      |     standing    |
|6.|     LAYING       |      laying     |

New labels were used to convert activity numbers in corresponding dataset.

## Requirement 4: Appropriately labels the data set with descriptive variable names.
Features names loaded from "features.txt" were analyzed after finding which feature names denotes desirable values. Based on selected feature names analysis, there were conceived rules to make them more readable by applying camelCase notation to all selected names. In that way variable names will look like before, but more coherently. This should facilitate recognition for reader familiar with source data set.

These rules where applied only to selected feature names.

* change Hungarian notation to camelCase notation by unwinding domain characters: t--time, f--freq
* remove characters "(),-" 
* capitalize first letter of word "mean" and "std" to "Mean" and "Std"

| Part of feature name |            meaning              |
|:--------------------:|:-------------------------------:|
|       time           |     value is from time domain   |
|       freq           |  value is from frequency domain |
|       Body           |     concerns body's movements    |
|      Gravity         |  concerns influence of gravity   |
|       Acc            |        linear velocity          |
|       Gyro           |       angular velocity          |
|       Jerk           |     velocity acceleration       |
|       Mag            |           magnitude             |
|       Mean           |             mean                |
|       Std            |      standard deviation         |
|        X             |             X axis              |
|        Y             |             Y axis              |
|        Z             |             Z axis              |


## Requirement 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each activity subject.
Script "run_analysis.R" creates one dataset for training and test data meeting requirements 1 to 4.
Column containing subject number is named "subject" and column containing activity labels is named "activity"
Then data in this dataset is grouped by columns "activity", "subject". 
After grouping "summarize" with function mean() is used od dataset to obtain mean values of each variable for
all values in group.

# Data transformation carried out during processing
1. transcoding features names
    * removing "--()," characters
    * change "mean" to "Mean"
    * change "std" to "Std"
    * change "t" at the name beginning to "time"
    * change "f" at the name beginning to "freq"
2. extracting feature names, which contained "mean()" or "std()" originally
3. transcoding activity labels
    * remove underscore
    * change letter to lower case
    * change "upstairs" to "Up"
    * change "downstairs" to "Down"
4. binding test subject number, activity number and measurements by columns into test dataset
5. binding training subject number, activity number and measurements by columns into training dataset
6. binding test and training dataset into activity dataset
7. selecting only variables wind mean() and () and saving it into separate dataset
8. converting activity number to activity labels according to table below

|activity number| activity label|
|:-------------:|:-------------:|
|       1       |    walking    |
|       2       |   walkingUp   |
|       3       |  walkingDown  |
|       4       |    sitting    |
|       5       |   standing    |
|       6       |    laying     |

9. naming variables using names extracted before (point 2)
10. grouping data by activity and subject
11. summarizing all values for grouped data using function mean()

# Resultant dataset description
Dataset contains mean values of measurements for each activity and each subject.

*Column description*
Columns 1 and 2 contain activity label and subject respectively.
Columns 3 to 68 are numeric in range [-1,1], all are mean values of measurements in the same range as source: [-1,1].
Table to recognize meaning of these variables is placed alter list of variables

 1. activity -- character string, performed activity label, 
      * "walking"     -- walking
      * "walkingUp"   -- walking upstairs
      * "walkingDown" -- walking downstairs
      * "sitting"     -- sitting
      * "standing"    -- standing
      * "laying"      -- laying
 2. subject -- integer in range from 1 to 30, identifier of volunteer taking part in experiment
 3. timeBodyAccMeanX           		-- mean value, numeric in range [-1, 1]
 4. timeBodyAccMeanY                -- mean value, numeric in range [-1, 1]
 5. timeBodyAccStdY                 -- mean value, numeric in range [-1, 1]
 6. timeGravityAccMeanY             -- mean value, numeric in range [-1, 1]
 7. timeGravityAccStdY              -- mean value, numeric in range [-1, 1]
 8. timeBodyAccJerkMeanY            -- mean value, numeric in range [-1, 1]
 9. timeBodyAccJerkStdY             -- mean value, numeric in range [-1, 1]
10. timeBodyGyroMeanY               -- mean value, numeric in range [-1, 1]
11. timeBodyGyroStdY                -- mean value, numeric in range [-1, 1]
12. timeBodyGyroJerkMeanY           -- mean value, numeric in range [-1, 1]
13. timeBodyGyroJerkStdY            -- mean value, numeric in range [-1, 1]
14. timeBodyAccMagStd               -- mean value, numeric in range [-1, 1]
15. timeBodyAccJerkMagMean          -- mean value, numeric in range [-1, 1]
16. timeBodyGyroMagStd              -- mean value, numeric in range [-1, 1]
17. freqBodyAccMeanX                -- mean value, numeric in range [-1, 1]
18. freqBodyAccStdX                 -- mean value, numeric in range [-1, 1]
19. freqBodyAccJerkMeanX            -- mean value, numeric in range [-1, 1]
20. freqBodyAccJerkStdX             -- mean value, numeric in range [-1, 1]
21. freqBodyGyroMeanX               -- mean value, numeric in range [-1, 1]
22. freqBodyGyroStdX                -- mean value, numeric in range [-1, 1]
23. freqBodyAccMagMean              -- mean value, numeric in range [-1, 1]
24. freqBodyBodyAccJerkMagStd       -- mean value, numeric in range [-1, 1]
25. freqBodyBodyGyroJerkMagMean     -- mean value, numeric in range [-1, 1]
26. timeBodyAccMeanZ                -- mean value, numeric in range [-1, 1]
27. timeBodyAccStdZ                 -- mean value, numeric in range [-1, 1]
28. timeGravityAccMeanZ             -- mean value, numeric in range [-1, 1]
29. timeGravityAccStdZ              -- mean value, numeric in range [-1, 1]
30. timeBodyAccJerkMeanZ            -- mean value, numeric in range [-1, 1]
31. timeBodyAccJerkStdZ             -- mean value, numeric in range [-1, 1]
32. timeBodyGyroMeanZ               -- mean value, numeric in range [-1, 1]
33. timeBodyGyroStdZ                -- mean value, numeric in range [-1, 1]
34. timeBodyGyroJerkMeanZ           -- mean value, numeric in range [-1, 1]
35. timeBodyGyroJerkStdZ            -- mean value, numeric in range [-1, 1]
36. timeGravityAccMagMean           -- mean value, numeric in range [-1, 1]
37. timeBodyAccJerkMagStd           -- mean value, numeric in range [-1, 1]
38. timeBodyGyroJerkMagMean         -- mean value, numeric in range [-1, 1]
39. freqBodyAccMeanY                -- mean value, numeric in range [-1, 1]
40. freqBodyAccStdY                 -- mean value, numeric in range [-1, 1]
41. freqBodyAccJerkMeanY            -- mean value, numeric in range [-1, 1]
42. freqBodyAccJerkStdY             -- mean value, numeric in range [-1, 1]
43. freqBodyGyroMeanY               -- mean value, numeric in range [-1, 1]
44. freqBodyGyroStdY                -- mean value, numeric in range [-1, 1]
45. freqBodyAccMagStd               -- mean value, numeric in range [-1, 1]
46. freqBodyBodyGyroMagMean         -- mean value, numeric in range [-1, 1]
47. freqBodyBodyGyroJerkMagStd      -- mean value, numeric in range [-1, 1]
48. timeBodyAccStdX                 -- mean value, numeric in range [-1, 1]
49. timeGravityAccMeanX             -- mean value, numeric in range [-1, 1]
50. timeGravityAccStdX              -- mean value, numeric in range [-1, 1]
51. timeBodyAccJerkMeanX            -- mean value, numeric in range [-1, 1]
52. timeBodyAccJerkStdX             -- mean value, numeric in range [-1, 1]
53. timeBodyGyroMeanX               -- mean value, numeric in range [-1, 1]
54. timeBodyGyroStdX                -- mean value, numeric in range [-1, 1]
55. timeBodyGyroJerkMeanX           -- mean value, numeric in range [-1, 1]
56. timeBodyGyroJerkStdX            -- mean value, numeric in range [-1, 1]
57. timeBodyAccMagMean              -- mean value, numeric in range [-1, 1]
58. timeGravityAccMagStd            -- mean value, numeric in range [-1, 1]
59. timeBodyGyroMagMean             -- mean value, numeric in range [-1, 1]
60. timeBodyGyroJerkMagStd          -- mean value, numeric in range [-1, 1]
61. freqBodyAccMeanZ                -- mean value, numeric in range [-1, 1]
62. freqBodyAccStdZ                 -- mean value, numeric in range [-1, 1]
63. freqBodyAccJerkMeanZ            -- mean value, numeric in range [-1, 1]
64. freqBodyAccJerkStdZ             -- mean value, numeric in range [-1, 1]
65. freqBodyGyroMeanZ               -- mean value, numeric in range [-1, 1]
66. freqBodyGyroStdZ                -- mean value, numeric in range [-1, 1]
67. freqBodyBodyAccJerkMagMean      -- mean value, numeric in range [-1, 1]
68. freqBodyBodyGyroMagStd          -- mean value, numeric in range [-1, 1]


| Part of variable name|            meaning              |
|:--------------------:|:-------------------------------:|
|       time           |     value is from time domain   |
|       freq           |  value is from frequency domain |
|       Body           |     concerns body's movements    |
|      Gravity         |  concerns influence of gravity   |
|       Acc            |        linear velocity          |
|       Gyro           |       angular velocity          |
|       Jerk           |     velocity acceleration       |
|       Mag            |           magnitude             |
|       Mean           |             mean                |
|       Std            |      standard deviation         |
|        X             |             X axis              |
|        Y             |             Y axis              |
|        Z             |             Z axis              |

# Data object created by script
Script "run_analysis.R" leaves intermediate datasets in memory allowing to inspect
intermediate data and process step by step.


|object            | assigned in step| description of contents                                               |
|:-----------------|:---------------:|:----------------------------------------------------------------------|
|activity_data     |  10             | one big dataset for all data before variable extraction               |
|activity_data_1   |  11             | activity data after extraction of desired variables                   |
|activity_data_2   |  12,13,14       | dataset grouped by activity and subject                               |
|activity_labels   |  1              | activity labels                                                       |
|activity_sum      |  15             | summarized data with mean of measurement                              |
|extract_cols      |  1              | vector of number of columns to be extracted from source dataset       |
|extract_names     |  1              | vector of names of columns to be extracted from source dataset        |
|features_names    |  1              | loaded source features name                                           |
|path_data         |  0              | path to source data                                                   |
|path_test         |  0              | path to test data                                                     |
|path_train        |  0              | path to training data                                                  |
|test_activity     |  3              | test activities                                                       |
|test_data         |  8              | whole test dataset                                                    |
|test_measuremants |  2              | test measurements                                                     |
|test_subject      |  4              | test subjects                                                         |
|train_activity    |  6              | training activities                                                    |
|train_data        |  8              | whole training dataset                                                 |
|train_measuremants|  5              | training measurements                                                  |
|train_subject     |  7              | training subjects                                                      |


# Processing data step by step
Processing order is little different than steps given in assignment.
This chapter describes that order and explains reasons why this order was applied.

Before actual processing of data script load needed libraries and prepares paths used later to load files.
There is only one script named according to assignment "run_analysis.R". It performs all the data processing.
Script assumes unpacked source data is placed in working directory.

## Step 1: processing common data -- names and labels
Feature names and activity labels are loaded and processed. In chapters above about requirement 2 and 4 there is description of feature names processing. Chapter regarding requirement 3 describes activity label processing.

In this step script prepares:

* vector of column numbers to extract from source dataset
* vector of names to be set as extracted variable names 
* table of activity labels to be used in conversion from activity numbers to label

## Step 2: processing test measurements
Script loads test measurements with 561 columns from X_test.txt file.

In this step script prepares:

* dataset with test data

## Step 3: processing test activities
Script loads test activities from y_test.txt file. Result is saved to new dataset with descriptive column name.

In this step script prepares:

* dataset with activity for each row of test measurements

## Step 4: processing test subject's data
Script load subject's identifiers from "subject_test.txt" file into dataset with descriptive column name.

In this step script prepares:

* dataset with subject identifier for each row of test measurements

## Step 5: processing training measurements
Script loads training measurements with 561 columns from X_train.txt file.

In this step script prepares:

* dataset with training data

## Step 6: processing training activities
Script loads training activities from y_train.txt file. Result is saved to new dataset with descriptive column name.

In this step script prepares:

* dataset with activity for each row of training measurements

## Step 7: processing training subject's data
Script load subject's identifiers from "subject_train.txt" file into dataset with descriptive column name.

In this step script prepares:

* dataset with subject identifier for each row of training measurements

## Step 8: preparing test dataset
Script get test's subject, activity and measurements datasets prepared in steps 2, 3, 4, and it binds them by columns using function bind_cols() into one test dataset.

In this step script prepares:

* dataset with test data containing measurement, subject and activity data

## Step 9: preparing training dataset
Script binds by columns training subject, activity and measurements datasets prepared in steps 5, 6, 7 using function bind_cols() into one training dataset.

In this step script prepares:

* dataset with training data containing measurement, subject and activity data

## Step 10: preparing one dataset
Scripts binds test and training dataset prepared in steps 8 and 9 into one activity dataset using bind_rows().

**That way requirements 1 is met.**

In this step script prepares:

* dataset with all variables, containing measurement, subject and activity with test and training data

## Step 11: extracting desired variables
Script extracts proper columns saving result to new dataset using vector with columns numbers prepared in step 1.

**That way requirements 2 is met.**

In this step script prepares:

* dataset containing extracted variables, subject and activity data

## Step 12: labeling activities with descriptive names
 Script gives new descriptive labels to activities using table of labels prepared in step 1.

**That way requirements 3 is met.**

In this step script prepares:

* dataset containing extracted variables, subject and activity data with descriptive activity names

## Step 13: naming variables with descriptive names
Script gives new descriptive names to extracted variables using vector of names prepared in step 1.

**That way requirements 4 is met.**

In this step script prepares:

* dataset containing extracted variables, subject and activity data

## Step 14: processing activity data
Script groups activity data by activity and subject and summarize() on grouped data to obtain average values saving it to new dataset.

**That way requirements 5 is met.**

In this step script prepares:

* dataset with test data containing measurement, subject and activity data with descriptive names

## Step 15: saving summarized data to the file
Scrip saves summarized data to file named "activity_sum.csv"


