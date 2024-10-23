#!/bin/bash
# run_music_queries.sh - Script to run music dataset queries

# Check if files exist
if [ ! -f "music_genre.csv" ]; then
    echo "Error: music_genre.csv not found!"
    exit 1
fi

# Create PIG script file
cat > music_queries.pig << 'EOL'
-- Load the music dataset
music_data = LOAD 'music_genre.csv' USING PigStorage(',') AS (
    Artist_Name:chararray, 
    Track_Name:chararray, 
    Popularity:int,
    danceability:float, 
    energy:float, 
    key:int, 
    loudness:float, 
    mode:int,
    speechiness:float, 
    acousticness:float, 
    instrumentalness:float,
    liveness:float, 
    valence:float, 
    tempo:float,
    duration:float, 
    time_signature:int
);

-- Group by artist
grouped_by_artist = GROUP music_data BY Artist_Name;

-- Find most popular tracks per artist
max_popularity_per_artist = FOREACH (GROUP music_data BY Artist_Name)
    GENERATE group AS Artist_Name,
    MAX(music_data.Popularity) AS Max_Popularity;
most_popular_tracks = JOIN max_popularity_per_artist BY (Artist_Name, Max_Popularity),
    music_data BY (Artist_Name, Popularity);

-- Sort by popularity
sorted_by_popularity = ORDER music_data BY Popularity DESC;

-- Extract artist and track names
artist_tracks = FOREACH sorted_by_popularity GENERATE Artist_Name, Track_Name;

-- Store results
STORE artist_tracks INTO 'music_results.txt' USING PigStorage(',');
EOL

# Run PIG script in local mode
pig -x local music_queries.pig

echo "Music queries completed successfully!"


This script isnt working properly and the outputs are not stored properly.