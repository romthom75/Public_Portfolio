-- ==================================== --
-- MSc in DSAIS 
-- 2023-2024
-- SQL group exercise 
-- ==================================== --
-- You will work here on the movies database. 
-- You will focus on the table metadata but what we will see is applicable to 
-- the other tables as well.


-- Write down your names here: Group 5
-- Team mate 1: Ata AVLAR
-- Team mate 2: Braxton HARPER
-- Team mate 3: Valentin KAVIANI
-- Team mate 4: Romain THOMAS
-- (if needed Team mate 5:) 
-- 
USE movies;
DESCRIBE metadata;
SELECT * FROM metadata;


-- ==================================== --
-- PART ONE: Evaluate data imperfection
-- ==================================== --

-- Exercice 1: Dealing with NULL and N/A
-- We want to be able to study the evolution of the duration of the films through the years. 
-- But first we need to make sure there are no missing values.
-- Focus on columns : movie_title, duration, title_year
-- 1) Write a query to know if there are missing values in those columns (be careful about how they are represented!)
-- Qualify them
-- 2) How many records are concerned? Make sure to have your result as a proportion of the total nb of records.
-- 3) Select all the data, excluding the rows with missing values.

# 1) Write a query to know if there are missing values in those columns (be careful about how they are represented!)
-- Qualify them
SELECT 
    COUNT(*) AS total_number_of_rows,
    SUM(CASE WHEN md.movie_title = "" THEN 1 ELSE 0 END) AS empty_movie_title,
    SUM(CASE WHEN md.movie_title IS NULL THEN 1 ELSE 0 END) AS missing_movie_title,
    SUM(CASE WHEN md.duration = "" THEN 1 ELSE 0 END) AS empty_duration,
    SUM(CASE WHEN md.duration IS NULL THEN 1 ELSE 0 END) AS missing_duration,
    SUM(CASE WHEN md.title_year = "" THEN 1 ELSE 0 END) AS empty_title_year,
    SUM(CASE WHEN md.title_year IS NULL THEN 1 ELSE 0 END) AS missing_title_year
FROM 
    metadata md;

# 2) How many records are concerned? Make sure to have your result as a proportion of the total nb of records.
SELECT 
    COUNT(*) AS total_number_of_rows,
    SUM(CASE WHEN md.duration = "" OR md.title_year = "" THEN 1 ELSE 0 END) AS number_rows_with_empty_values,
    SUM(CASE WHEN md.duration = "" OR md.title_year = "" THEN 1 ELSE 0 END) / COUNT(*) *100 AS percentage_rows_with_empty_values
FROM 
    metadata md;

# 3) Select all the data, excluding the rows with missing values.
SELECT *
FROM metadata md
WHERE (md.duration != "" AND md.title_year != "")
;

-- -----------
-- Exercice 2: Dealing with Duplicate Records - Removing them
-- (On the table metadata from the movies database).
-- We still want to be able to study the evolution of the duration of the films through the years. But first we need to make sure there are no duplicates.
-- Focus on the same columns: movie_title, duration, title_year,
-- Plus we add director_name to know wether they are real duplicates or movies with the same name
 
-- 1) Write a query to know whether there is duplicates in those columns.
-- 2) Select the duplicates and try to understand why we have duplicates.
-- 3) How many records are concerned? Make sure to have your result as a proportion of the total nb of records.
-- 4) Select all the data, excluding the rows with missing values and the duplicates.

# 1) Write a query to know whether there is duplicates in those columns.
# 2) Select the duplicates and try to understand why we have duplicates.
SELECT 
    md.movie_title, md.duration, md.title_year, md.director_name, COUNT(*) AS number_of_duplicates
FROM 
    metadata md
GROUP BY 
    md.movie_title, md.duration, md.title_year, md.director_name
HAVING 
    number_of_duplicates > 1;

# for example
SELECT * FROM metadata md
WHERE md.movie_title = 'King Kong ';
# => there are duplicates because for example the facebook likes and number of voted users are updated hence it can create duplicates.
# => While updating, the previous records should have been deleted but the user maybe forgot to delete it.

# 3) How many records are concerned? Make sure to have your result as a proportion of the total nb of records. 

# => 124 rows to be removed, 2.4589% of the total records 
SELECT COUNT(movie_title), SUM(number_of_duplicates),
 SUM(number_of_duplicates)-COUNT(movie_title) AS number_of_duplicates,
 (SUM(number_of_duplicates)-COUNT(movie_title))/(SELECT COUNT(*) FROM metadata)*100 AS proportion_of_duplicates
FROM(
SELECT 
    md.movie_title, md.duration, md.title_year, md.director_name, COUNT(*) AS number_of_duplicates
FROM 
    metadata md
GROUP BY 
    md.movie_title, md.duration, md.title_year, md.director_name
HAVING 
    number_of_duplicates > 1
 ) AS sq ;

# 4) Select all the data, excluding the rows with missing values and the duplicates.
 
WITH RankedRows AS (
    SELECT
        md.*,
        ROW_NUMBER() OVER(PARTITION BY md.movie_title, md.duration, md.title_year, md.director_name ORDER BY md.movie_title) AS RowNum
    FROM
        metadata md
    WHERE
        md.movie_title IS NOT NULL AND md.movie_title != '' 
        AND md.duration IS NOT NULL AND md.duration != '' 
        AND md.title_year IS NOT NULL AND md.title_year != ''
)
SELECT
    rr.*
FROM
    RankedRows rr
WHERE
    rr.RowNum = 1;

-- -----------
-- Exercise 3 
-- 1) Explore carefully the table, do you notice anything?
-- Try to identify a maximum of issues on metadata design :
-- You can write down here your comments as well as your queries that 
-- helped you to identify those issues
-- 2) Try to select the problematic rows and to understand the problem.
-- 3) How many records are concerned? Make sure to have your result as a proportion of the total nb of records.
-- 4) Select all the data, excluding the rows with missing values, duplicates AND corrupted data.

-- 1) Explore carefully the table, do you notice anything?
-- Try to identify a maximum of issues on metadata design :
-- You can write down here your comments as well as your queries that 
-- helped you to identify those issues
SELECT * FROM metadata;

# a lot of columns are VARCHAR whereas INT might be a better choice (exemple: duration, budget)
DESCRIBE metadata;

# Several rows have column shifted
# 61 rows have column shifted from 1 column
SELECT * FROM metadata
WHERE num_user_for_reviews LIKE 'http%';

# 2 rows have column shifted from 2 columns
SELECT * FROM metadata
WHERE country LIKE 'http%';

# Some titles start with a quotation mark and it seems they are not complete 
SELECT movie_title FROM metadata WHERE movie_title LIKE '"%';

SELECT DISTINCT(country) FROM metadata;



-- 2) Try to select the problematic rows and to understand the problem
-- We found that there is 69 rows that have been shifted by different number of columns. 
SELECT *
FROM metadata
WHERE movie_imdb_link NOT LIKE 'http://www.imdb.com%';

-- 3) How many records are concerned? Make sure to have your result as a proportion of the total nb of records.

# ==> 69 records are concerned. 1.3682% of the total records.
SELECT 
COUNT(*) AS Number_Of_Rows,
COUNT(*)/5043*100 AS Percentage_Shifted
FROM metadata
WHERE movie_imdb_link NOT LIKE 'http://www.imdb.com%';

-- 4) Select all the data, excluding the rows with missing values, duplicates AND corrupted data.
WITH RankedRows AS (
    SELECT
        md.*,
        ROW_NUMBER() OVER(PARTITION BY md.movie_title, md.duration, md.title_year, md.director_name ORDER BY md.movie_title) AS RowNum
    FROM
        metadata md
    WHERE
        md.movie_title != '' 
        AND md.duration != '' 
        AND md.title_year != ''
        AND movie_imdb_link LIKE 'http://www.imdb.com%'
)
SELECT
    rr.*
FROM
    RankedRows rr
WHERE
    rr.RowNum = 1;


-- ==================================== --
-- PART TWO: Make ambitious table junction
-- ==================================== --
-- The database “movies” contains two kind of ratings. 
-- One “rating” is in the table “ratings” and is link to a “movieId”. 
-- The other, “imdb_score”, is in the “metadata” table. 
-- What we want here is to make an ambitious junction between the two table and get, per movie, the two kind of ratings available in this database.
-- Why ambitious? 
-- Because as you can see there is no common key or even common attribute between the two tables. 
-- In fact, there is no perfectly identic attributes but there is one eventually common value : the movie title.
-- Here, the issue here is how formate/clean your table’s data so you could make a proper join.
-- ====== --
SELECT title FROM movies;
SELECT movie_title FROM metadata;

-- Step 1:
-- What is the difference between the two attributes metadata.movie_title and movies.title ?
-- Only comment here

# ==>  Answer:
# ==> In movies table, title contains the year of the movies. But in metadata table, it only contains the title of the movie.
# ==> In movies table, the articles are at the end and separated with a comma (Postman, The). But in the metadata table, it is in front of the title. (The Postman)

# ==> In movies table, there are extra information between brackets in the title field
# ==> In metadata table, movie titles have a useless space at the end


-- ====== --
-- Step 2:
-- How to cut out some unwanted pieces of a string ? 
-- Use the function SUBSTR() but you will also need another function : CHAR_LENGTH().
-- From the movies table, 
-- Try to get a query returning the movies.title, considering only the correct title of each movie.

#This query removes the year at the end.
SELECT m.movieId,SUBSTR(m.title, 1, CHAR_LENGTH(m.title) -7) AS title_new FROM movies m;

#This query moves the articles to the front of the movie title.
SELECT nm.movieId,
CASE 
	WHEN LOWER(SUBSTR(nm.title_new, -5))=', The' THEN CONCAT('The ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 5))
	WHEN LOWER(SUBSTR(nm.title_new, -3)) = ', A' THEN CONCAT('A ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 3))
	WHEN LOWER(SUBSTR(nm.title_new, -4)) = ', An' THEN CONCAT('An ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 4))
    WHEN LOWER(SUBSTR(nm.title_new, -5)) = ', Les' THEN CONCAT('Les ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 5))
		ELSE nm.title_new 
	END AS standardized_title
FROM(SELECT m.movieId,SUBSTR(m.title, 1, CHAR_LENGTH(m.title) -7) AS title_new FROM movies m) nm;

-- And then also include the aggregation of the average rating for each movie
-- joining the ratings table

SELECT nm.movieId,
CASE 
	WHEN LOWER(SUBSTR(nm.title_new, -5))=', The' THEN CONCAT('The ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 5))
	WHEN LOWER(SUBSTR(nm.title_new, -3)) = ', A' THEN CONCAT('A ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 3))
	WHEN LOWER(SUBSTR(nm.title_new, -4)) = ', An' THEN CONCAT('An ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 4))
    WHEN LOWER(SUBSTR(nm.title_new, -5)) = ', Les' THEN CONCAT('Les ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 5))
		ELSE nm.title_new 
	END AS standardized_title,
    ROUND(AVG(r.rating),2) AS Average_Rating
FROM(SELECT m.movieId,SUBSTR(m.title, 1, CHAR_LENGTH(m.title) -7) AS title_new FROM movies m) nm
JOIN ratings r ON nm.movieId=r.movieId
GROUP BY nm.movieId,standardized_title;


-- ====== --
-- Step 3:
-- Now that we have a good request for cleaned and aggregated version of movies/ratings, 
-- you need to also have a clean request from metadata.
-- Make a query returning aggregated metadata.imdb_score for each metadata.movie_title.
-- excluding the corrupted rows 

SELECT
    rr.movie_title,AVG(rr.imdb_score) AS Average_IMDB
FROM
    (
    SELECT
        md.*,
        ROW_NUMBER() OVER(PARTITION BY md.movie_title, md.duration, md.title_year, md.director_name ORDER BY md.movie_title) AS RowNum
    FROM
        metadata md
    WHERE
        md.movie_title != '' 
        AND md.duration != '' 
        AND md.title_year != ''
        AND movie_imdb_link LIKE 'http://www.imdb.com%'
) AS rr
WHERE
    rr.RowNum = 1
GROUP BY rr.movie_title,rr.director_name ;
#==> Note: For 2 movies that have the same names (The Host, Out Of The Blue) we added director name to the group by statement.


-- ====== --
-- Step 4:
-- It is time to make a JOIN! Try to make a request merging the result of Step 2 and Step 3. 
-- You need to use your previous as two subqueries and join on the movie title.
-- What is happening ? What is the result ? This request can take time to return.

# ==> we also did a join on the date (splitting title column in movies dataframe) with title_year of metadata dataframe
# ==> by doing so we prevent false jonction for movies with the same title but not the same year (at least 4 movies)
# ==> we have to use year because director is only in metadata dataframe

SELECT
    rr.movie_title,
    AVG(rr.imdb_score) AS Average_IMDB,
	rr.title_year,
    movie_rating.standardized_title,
    movie_rating.Average_Rating,
    movie_rating.year_date

FROM
    (
        SELECT
            md.*,
            ROW_NUMBER() OVER(PARTITION BY md.movie_title, md.duration, md.title_year, md.director_name ORDER BY md.movie_title) AS RowNum
        FROM
            metadata md
        WHERE
            md.movie_title != '' 
            AND md.duration != '' 
            AND md.title_year != ''
            AND movie_imdb_link LIKE 'http://www.imdb.com%'
    ) AS rr
JOIN
    (
        SELECT
            nm.movieId,
            nm.year_date,
            CASE 
                WHEN LOWER(SUBSTR(nm.title_new, -5))=', The' THEN CONCAT('The ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 5))
                WHEN LOWER(SUBSTR(nm.title_new, -3)) = ', A' THEN CONCAT('A ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 3))
                WHEN LOWER(SUBSTR(nm.title_new, -4)) = ', An' THEN CONCAT('An ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 4))
                WHEN LOWER(SUBSTR(nm.title_new, -5)) = ', Les' THEN CONCAT('Les ', SUBSTR(nm.title_new, 1, CHAR_LENGTH(nm.title_new) - 5))
                ELSE nm.title_new 
            END AS standardized_title,
            ROUND(AVG(r.rating), 2) AS Average_Rating
        FROM
            (
            SELECT 
				m.movieId,
				SUBSTR(m.title, 1, CHAR_LENGTH(m.title) - 7) AS title_new,
                SUBSTR(m.title, CHAR_LENGTH(m.title)-4, 4) AS year_date
            FROM movies m
            ) AS nm
        JOIN
            ratings r ON nm.movieId = r.movieId
        GROUP BY nm.movieId, standardized_title, nm.year_date
    ) AS movie_rating 
    ON CONCAT(movie_rating.standardized_title, ' ') = rr.movie_title
		AND movie_rating.year_date = rr.title_year
WHERE
    rr.RowNum = 1
GROUP BY rr.movie_title, rr.director_name, movie_rating.movieId, movie_rating.standardized_title, movie_rating.Average_Rating, movie_rating.year_date, rr.title_year;

    
    
 



SELECT * FROM movies;
SELECT * FROM metadata;

-- ====== --
-- Step 5:
-- There is a possibility that your previous query doesn't work for apparently no reasons, 
-- despite of the join condition being respected on some rows 
-- (check by yourself on a specific film of your choice by adding a simple WHERE condition).
-- Try to find out what could go wrong 
-- And try to query a workable join
-- Tip: Think about spaces or blanks 

# we figured it out before reaching this question :)



-- For final version of the output, 
-- Also include the count of ratings used to compute the average.





-- ------------------
-- Well done ! 
-- Congratulations !
-- ------------------

