"Getting and Cleaning Data" Course Project
==========================================
Coursera course "Getting and Cleaning Data" by Johns Hopkins University

# Assignment overview
Goal of assignment is to analyze given data and to obtain as described resultant tidy data, along with code book, file with saved dataset containing tidy data itself and readme file describing analysis.

# Files provided as result
1. README.md - this file, describes set of analysis files
2. Codebook.md - describes the variables, the data, and work performed
3. run_analiysis.R - contains R scripts preforming analysis and saving resultant tidy dataset into file
3. activity_sum.txt - contains tidy required as result of work

Result dataset has titles and can be loaded with command `read.table("activity_sum.txt")`

# How to perform analysis using submitted files
1. Prepare empty directory as working directory, and set that directory as the working directory in R
2. Download the source dataset described in assignment text, or using link:
<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>, and place it in the working directory
4. Unpack it into the working directory with subdirectories -- after unpacking there should be one directory named "UCI HAR Dataset" with directories and files inside
3. Place submitted file "run_analysis.R" into the working directory
4. Run script `run_analysis.R`
5. Observe tidy dataset in new file "activity_sum.txt"

Datasets, variables, and analysis steps are described in CodeBook.md file.

Script "run_analysis.R" leaves intermediate datasets in memory allowing to inspect
intermediate data and process step by step. Detailed description of process is
placed in the CodeBook.md file.
