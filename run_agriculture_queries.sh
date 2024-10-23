#!/bin/bash
# run_agriculture_queries.sh - Script to run agriculture dataset queries

# Check if files exist
if [ ! -f "crop_production.csv" ]; then
    echo "Error: crop_production.csv not found!"
    exit 1
fi

# Create PIG script file
cat > agriculture_queries.pig << 'EOL'
-- Load the agriculture dataset
agriculture = LOAD 'crop_production.csv' USING PigStorage(',') AS (
    State_Name:chararray, 
    District_Name:chararray,
    Crop_Year:int, 
    Season:chararray, 
    Crop:chararray, 
    Area:int,
    Production:int
);

-- Group by state
grouped_by_state = GROUP agriculture BY State_Name;

-- Calculate highest produced crops per state
grouped_by_state_crop = GROUP agriculture BY (State_Name, Crop);
state_crop_production = FOREACH grouped_by_state_crop 
    GENERATE FLATTEN(group) AS (State_Name, Crop),
    SUM(agriculture.Production) AS Total_Production;
grouped_by_state_max = GROUP state_crop_production BY State_Name;
max_production_per_state = FOREACH grouped_by_state_max 
    GENERATE group AS State_Name,
    MAX(state_crop_production.Total_Production) AS Max_Production;
highest_produced_crops = JOIN max_production_per_state BY (State_Name, Max_Production),
    state_crop_production BY (State_Name, Total_Production);

-- Store results
STORE highest_produced_crops INTO 'data_top.txt' USING PigStorage(',');
EOL

# Run PIG script in local mode
pig -x local agriculture_queries.pig

# Move results to HDFS
hadoop fs -put data_top.txt /user/$USER/

echo "Agriculture queries completed successfully!"