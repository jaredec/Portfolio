SELECT * 
FROM Portfolio.dbo.NetflixData

-- Remove leading 's' from show_id
UPDATE NetflixData
SET show_id = RIGHT(show_id, LEN(show_id) - 1)

-- Check for duplicates 
SELECT show_id, Occurence= COUNT(*)                                                                                                                                                                            
FROM NetflixData
GROUP BY show_id                                                                                                                                                                                            
HAVING COUNT(*) > 1
-- No duplicates 

-- Double check for duplicates using the description column
SELECT description, description_count = COUNT(*)                                                                                                                                                             
FROM NetflixData
GROUP BY description
HAVING COUNT(*) > 1
-- We see that there are instances where the show is the same but dubbed in another language
-- We will remove this as it will inflate results for that title

-- Delete the duplicates
WITH DupeCTE as
(
	SELECT *, ROW_NUMBER() OVER (PARTITION BY description ORDER BY description) 
	AS RowNumber FROM NetflixData
) 

DELETE
FROM DupeCTE
WHERE RowNumber > 1

-- Check for NULLs across columns
SELECT
(SELECT COUNT(*) FROM NetflixData WHERE show_id is NULL) as show_id_null,
(SELECT COUNT(*) FROM NetflixData WHERE type is NULL) as type_null,
(SELECT COUNT(*) FROM NetflixData WHERE title is NULL) as title_null,
(SELECT COUNT(*) FROM NetflixData WHERE director is NULL) as director_null,
(SELECT COUNT(*) FROM NetflixData WHERE cast is NULL) as cast_null,
(SELECT COUNT(*) FROM NetflixData WHERE country is NULL) as country_null,
(SELECT COUNT(*) FROM NetflixData WHERE date_added is NULL) as date_added_null,
(SELECT COUNT(*) FROM NetflixData WHERE release_year is NULL) as release_year_null,
(SELECT COUNT(*) FROM NetflixData WHERE rating is NULL) as rating_null,
(SELECT COUNT(*) FROM NetflixData WHERE duration is NULL) as duration_null,
(SELECT COUNT(*) FROM NetflixData WHERE listed_in is NULL) as listed_in_null,
(SELECT COUNT(*) FROM NetflixData WHERE description is NULL) as description_null
-- There are NULLs in 6 of our columns

-- Lets populate NULLS in country
-- We can fill the NULLs in country column where directors are tied to a specific country
SELECT * 
FROM NetflixData 
WHERE country IS NULL 
AND director IN(SELECT director
	FROM NetflixData
	GROUP BY director
	HAVING COUNT(DISTINCT country) = 1)
-- There are 123 rows that we can populate

WITH NullsCTE as
(
	SELECT * 
	FROM NetflixData 
	WHERE country IS NULL 
	AND director IN(SELECT director
	FROM NetflixData
	GROUP BY director
	HAVING COUNT(DISTINCT country) = 1)
),
	CountryCTE as
(	
	SELECT DISTINCT director, country 
	FROM NetflixData 
	WHERE country IS NOT NULL 
	AND director IN(SELECT director
	FROM NetflixData
	GROUP BY director
	HAVING COUNT(DISTINCT country) = 1
	AND COUNT(*) > 1)

)
UPDATE NullsCTE
SET NullsCTE.country = 
	(SELECT CountryCTE.country 
	FROM CountryCTE 
	WHERE NullsCTE.director = CountryCTE.director)

-- Treat all other NULLs
UPDATE NetflixData 
SET director = 'Not Listed'
WHERE director IS NULL

UPDATE NetflixData 
SET cast = 'Not Listed'
WHERE cast IS NULL

UPDATE NetflixData 
SET country = 'Not Listed'
WHERE country IS NULL

-- There are 10 NULLs in date_added column
-- We will delete these rows as it will not affect our analysis
DELETE
FROM NetflixData
WHERE show_id 
IN (SELECT show_id 
FROM NetflixData
WHERE date_added IS NULL)

-- We will do the same for rows with rating or duration NULLs
DELETE
FROM NetflixData
WHERE show_id
IN (SELECT show_id 
FROM NetflixData
WHERE rating IS NULL
OR duration IS NULL)

-- Standardize date format
UPDATE NetflixData
SET date_added = CONVERT(Date,date_added)

-- We don't need description column, delete it
ALTER TABLE NetflixData 
DROP COLUMN description

-- Also delete cast 
ALTER TABLE NetflixData 
DROP COLUMN cast

-- Fix the values in country that start with a comma ie: ' ,South Korea' and ',France, Algeria' 
UPDATE NetflixData
SET country = CASE
WHEN country LIKE ',%' THEN LTRIM(SUBSTRING(country, 2, LEN(country) - 1))
ELSE country 
END
FROM NetflixData

-- For rows with multiple countries listed, only take the primary country for our visualization
UPDATE NetflixData
SET country = CASE
WHEN CHARINDEX(',', country) > 0 THEN LTRIM(LEFT(country, CHARINDEX(',', country) - 1))
ELSE country
END 
FROM NetflixData

-- Since there are multiple genres, separate each genre and union all
-- This will be our final dataset to export to Tableau 
WITH RecursiveCTE AS (
    SELECT
        show_id,
        type,
        title,
        director,
        country,
        date_added,
        release_year,
        rating,
        duration,
        CASE
            WHEN CHARINDEX(',', listed_in) > 0 THEN LEFT(listed_in, CHARINDEX(',', listed_in) - 1)
            ELSE listed_in
        END AS genre,
        CASE
            WHEN CHARINDEX(',', listed_in) > 0 THEN RIGHT(listed_in, LEN(listed_in) - CHARINDEX(',', listed_in))
            ELSE ''
        END AS remaining_genres
    FROM NetflixData
    WHERE LEN(listed_in) > 0
	UNION ALL
	SELECT
        show_id,
        type,
        title,
        director,
        country,
        date_added,
        release_year,
        rating,
        duration,
        CASE
            WHEN CHARINDEX(',', remaining_genres) > 0 THEN LEFT(remaining_genres, CHARINDEX(',', remaining_genres) - 1)
            ELSE remaining_genres
        END AS genre,
        CASE
            WHEN CHARINDEX(',', remaining_genres) > 0 THEN RIGHT(remaining_genres, LEN(remaining_genres) - CHARINDEX(',', remaining_genres))
            ELSE ''
        END AS remaining_genres
    FROM RecursiveCTE
    WHERE LEN(remaining_genres) > 0
)
SELECT
    show_id,
    type,
    title,
    director,
    country,
    date_added,
    release_year,
    rating,
    duration,
    TRIM(genre) AS genre
FROM RecursiveCTE
-- Note: There are 19,208 rows when we union genres. 
-- In Tableau, count by Distinct show_id for other columns








