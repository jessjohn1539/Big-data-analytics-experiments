# R Programming Experiments

## Experiment 7: Project Management DataFrame Analysis

### a) Creating Project DataFrame
```R
# Create DataFrame for project data
projects <- data.frame(
    ProjectId = c(1, 2, 3, 4, 5),
    ProjectName = c(
        "Website Redesign",
        "Mobile App Launch",
        "Data Migration",
        "AI Development",
        "Cybersecurity Audit"
    ),
    Budget = c(150000, 100000, 80000, 200000, 50000)
)

# Display the DataFrame
print(projects)
```

#### Expected Output:
```
  ProjectId        ProjectName Budget
1        1  Website Redesign 150000
2        2  Mobile App Launch 100000
3        3    Data Migration  80000
4        4    AI Development 200000
5        5 Cybersecurity Audit 50000
```

### b) Structure and Summary Statistics

```R
# Show structure of DataFrame
str(projects)

# Show summary statistics
summary(projects)
```

#### Structure Output:
```
'data.frame': 5 obs. of 3 variables:
 $ ProjectId  : num 1 2 3 4 5
 $ ProjectName: chr "Website Redesign" "Mobile App Launch" "Data Migration" "AI Development" ...
 $ Budget     : num 150000 100000 80000 200000 50000
```

#### Summary Statistics Output:
```
    ProjectId      ProjectName           Budget      
 Min.   :1.0   Length:5           Min.   : 50000  
 1st Qu.:2.5   Class :character   1st Qu.: 80000  
 Median :3.0   Mode  :character   Median :100000  
 Mean   :3.0                      Mean   :116000  
 3rd Qu.:4.0                      3rd Qu.:150000  
 Max.   :5.0                      Max.   :200000  
```

### c) Updating DataFrame with New Projects

```R
# Create DataFrame for new projects
new_projects <- data.frame(
    ProjectId = c(6, 7),
    ProjectName = c("Cloud Integration", "UX Research"),
    Budget = c(120000, 60000)
)

# Combine old and new DataFrames
updated_projects <- rbind(projects, new_projects)

# Display updated DataFrame
print(updated_projects)
```

#### Updated DataFrame Output:
```
  ProjectId        ProjectName Budget
1        1  Website Redesign  150000
2        2  Mobile App Launch 100000
3        3    Data Migration   80000
4        4    AI Development  200000
5        5 Cybersecurity Audit 50000
6        6 Cloud Integration  120000
7        7      UX Research    60000
```

## Experiment 8: Course Management DataFrame Analysis

### a) Creating Course DataFrame

```R
# Create DataFrame for course data
courses <- data.frame(
    CourseId = c(1, 2, 3, 4, 5),
    CourseName = c(
        "Introduction to R",
        "Data Science Essentials",
        "Machine Learning",
        "Web Development",
        "Digital Marketing"
    ),
    StartDate = as.Date(c(
        "2023-01-10",
        "2023-02-15",
        "2023-03-20",
        "2023-04-05",
        "2023-05-12"
    )),
    Duration_weeks = c(8, 10, 12, 6, 4),
    Fees = c(500, 750, 800, 600, 400)
)

# Display DataFrame
print(courses)
```

#### Expected Output:
```
  CourseId            CourseName  StartDate Duration_weeks Fees
1        1     Introduction to R 2023-01-10             8  500
2        2 Data Science Essentials 2023-02-15          10  750
3        3      Machine Learning 2023-03-20            12  800
4        4      Web Development 2023-04-05              6  600
5        5    Digital Marketing 2023-05-12              4  400
```

### b) Structure and Summary Statistics

```R
# Show structure
str(courses)

# Show summary statistics
summary(courses)
```

#### Structure Output:
```
'data.frame': 5 obs. of 5 variables:
 $ CourseId      : num 1 2 3 4 5
 $ CourseName    : chr "Introduction to R" "Data Science Essentials" "Machine Learning" ...
 $ StartDate     : Date, format: "2023-01-10" "2023-02-15" ...
 $ Duration_weeks: num 8 10 12 6 4
 $ Fees          : num 500 750 800 600 400
```

#### Summary Statistics Output:
```
    CourseId        CourseName         StartDate         Duration_weeks        Fees     
 Min.   :1.0   Length:5         Min.   :2023-01-10   Min.   : 4.0   Min.   :400  
 1st Qu.:2.5   Class :character 1st Qu.:2023-02-05   1st Qu.: 6.0   1st Qu.:500  
 Median :3.0   Mode  :character Median :2023-03-20   Median : 8.0   Median :600  
 Mean   :3.0                    Mean   :2023-03-20   Mean   : 8.0   Mean   :610  
 3rd Qu.:4.0                    3rd Qu.:2023-04-05   3rd Qu.:10.0   3rd Qu.:750  
 Max.   :5.0                    Max.   :2023-05-12   Max.   :12.0   Max.   :800  
```

### c) Extracting Specific Columns

```R
# Extract CourseName and Fees columns
selected_columns <- courses[, c("CourseName", "Fees")]
print(selected_columns)
```

#### Expected Output:
```
              CourseName Fees
1       Introduction to R  500
2 Data Science Essentials  750
3        Machine Learning  800
4        Web Development  600
5      Digital Marketing  400
```

### d) Filtering Courses by Duration

```R
# Extract courses with duration > 6 weeks
long_courses <- subset(courses, Duration_weeks > 6)
print(long_courses)
```

#### Expected Output:
```
  CourseId            CourseName  StartDate Duration_weeks Fees
1        1     Introduction to R 2023-01-10             8  500
2        2 Data Science Essentials 2023-02-15          10  750
3        3      Machine Learning 2023-03-20            12  800
```

### Shell Script to Run R Experiments

```bash
#!/bin/bash

# experiment7_8.sh
# Shell script to run both R experiments

echo "Running R Experiments..."

# Create R script file
cat > r_experiments.R << 'EOL'
# Experiment 7
cat("\n=== Experiment 7: Project Management ===\n")

# Create projects DataFrame
projects <- data.frame(
    ProjectId = c(1, 2, 3, 4, 5),
    ProjectName = c("Website Redesign", "Mobile App Launch", "Data Migration", 
                   "AI Development", "Cybersecurity Audit"),
    Budget = c(150000, 100000, 80000, 200000, 50000)
)

# Display initial DataFrame
cat("\nInitial Projects DataFrame:\n")
print(projects)

# Show structure and summary
cat("\nStructure of Projects DataFrame:\n")
str(projects)
cat("\nSummary of Projects DataFrame:\n")
print(summary(projects))

# Add new projects
new_projects <- data.frame(
    ProjectId = c(6, 7),
    ProjectName = c("Cloud Integration", "UX Research"),
    Budget = c(120000, 60000)
)
updated_projects <- rbind(projects, new_projects)

cat("\nUpdated Projects DataFrame:\n")
print(updated_projects)

# Experiment 8
cat("\n=== Experiment 8: Course Management ===\n")

# Create courses DataFrame
courses <- data.frame(
    CourseId = c(1, 2, 3, 4, 5),
    CourseName = c("Introduction to R", "Data Science Essentials", 
                  "Machine Learning", "Web Development", "Digital Marketing"),
    StartDate = as.Date(c("2023-01-10", "2023-02-15", "2023-03-20", 
                         "2023-04-05", "2023-05-12")),
    Duration_weeks = c(8, 10, 12, 6, 4),
    Fees = c(500, 750, 800, 600, 400)
)

cat("\nCourses DataFrame:\n")
print(courses)

cat("\nStructure of Courses DataFrame:\n")
str(courses)

cat("\nSummary of Courses DataFrame:\n")
print(summary(courses))

cat("\nSelected Columns (CourseName and Fees):\n")
print(courses[, c("CourseName", "Fees")])

cat("\nCourses longer than 6 weeks:\n")
print(subset(courses, Duration_weeks > 6))
EOL

# Run R script
Rscript r_experiments.R

echo "R Experiments completed!"
```

To run the experiments:
1. Save the shell script as `experiment7_8.sh`
2. Make it executable:
   ```bash
   chmod +x experiment7_8.sh
   ```
3. Run the script:
   ```bash
   ./experiment7_8.sh
   ```

The script will:
1. Create an R script containing both experiments
2. Run all the analyses
3. Display the results in a formatted manner
4. Save all output for future reference

Note: Make sure R is installed on your system before running the script:
```bash
sudo apt-get update
sudo apt-get install r-base
```
