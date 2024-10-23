#!/bin/bash

# Configuration
INPUT_FILE="input.txt"           # Your local input file
STOP_WORDS_FILE="stopwords.txt"  # Your local stop words file
HADOOP_INPUT="/wordcount/input"  # HDFS input directory
HADOOP_OUTPUT="/wordcount/output" # HDFS output directory
JAR_NAME="wordcount.jar"         # Name of the compiled JAR
MAIN_CLASS="org.apache.pig.test.utils.WordCount" # Main class name

# Create necessary directories
echo "Creating directories..."
hadoop fs -mkdir -p /wordcount

# Remove output directory if exists
echo "Cleaning up previous output..."
hadoop fs -rm -r -f $HADOOP_OUTPUT

# Compile the Java code
echo "Compiling Java code..."
mkdir -p classes
javac -cp $(hadoop classpath) -d classes WordCount.java
jar cvf $JAR_NAME -C classes .

# Check if input file exists
if [ ! -f $INPUT_FILE ]; then
    echo "Error: Input file $INPUT_FILE not found!"
    exit 1
fi

# Upload input file to HDFS
echo "Uploading input data to HDFS..."
hadoop fs -put -f $INPUT_FILE $HADOOP_INPUT

# Run the Hadoop job
echo "Running WordCount job..."
if [ -f $STOP_WORDS_FILE ]; then
    echo "Using stop words file..."
    hadoop jar $JAR_NAME $MAIN_CLASS $HADOOP_INPUT $HADOOP_OUTPUT $STOP_WORDS_FILE
else
    echo "Running without stop words..."
    hadoop jar $JAR_NAME $MAIN_CLASS $HADOOP_INPUT $HADOOP_OUTPUT
fi

# Check if job was successful
if [ $? -eq 0 ]; then
    echo "Job completed successfully!"
    
    # Create local output directory
    mkdir -p output
    
    # Get results from HDFS
    echo "Retrieving results..."
    hadoop fs -get $HADOOP_OUTPUT/* output/
    
    echo "Results have been saved to the output directory"
    
    # Display first few results
    echo "Sample results:"
    head output/part-r-00000
else
    echo "Job failed!"
    exit 1
fi