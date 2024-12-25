USE netflix_db;
-- 15 business problems

-- 1. Count the number of movies vs tv shows

SELECT 
	type,
    COUNT(*) AS count
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows

SELECT
	type,
	rating,
    COUNT(*) AS count,
    RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rating_rank
FROM netflix
GROUP BY 1, 2
ORDER BY 4 
LIMIT 2;
    
-- 3. List all movies released in a specific year (eg.2020)

SELECT
	release_year,
    title
FROM netflix
WHERE release_year = 2020
	AND
    type = 'Movie'
GROUP BY 1, 2
ORDER BY 1 DESC;
-- or just the were condition would do 

-- 4. Find the top 10 countries with the most content on Netflix

-- if country column has single countries
SELECT 
	country,
    COUNT(*) AS num_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
-- if country has multiple values comma seperated then in posgres unnest(string_to_array(column,','))
-- but in mysql we need to use recursive cte's
SET SESSION cte_max_recursion_depth = 5000;
WITH RECURSIVE split AS (
	SELECT 
		show_id, 
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS single_country,
        CASE
			WHEN remaining_country IS NOT NULL THEN TRIM(SUBSTRING_INDEX(country, ',', -1)) 
			ELSE NULL 
		END AS remaining_country
    FROM netflix
    
    UNION ALL
    
    SELECT 
		show_id,
        TRIM(SUBSTRING_INDEX(remaining_country, ',', 1)) AS single_country,
        CASE
			WHEN remaining_country LIKE '%,%' THEN TRIM(SUBSTRING_INDEX(remaining_country, ',', -1)) 
			ELSE NULL
		END AS remaining_country
	FROM split
    WHERE remaining_country IS NOT NULL
)
SELECT 
	single_country AS country,
    COUNT(*) AS num_content
FROM split
WHERE single_country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
-- if country column has entries with multiple countries grouped together
    
-- 5. Identify the longest movie

SELECT  
	title,
    duration
FROM netflix
WHERE 
	type = 'Movie'
    AND
    duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years

SELECT 
	title,
    date_added
FROM netflix 
WHERE DATE_FORMAT(STR_TO_DATE(date_added, '%M %d, %Y'), '%y-%m-%d') >= 
														DATE_SUB(CURRENT_DATE, INTERVAL 5 YEAR);

-- 7. Find all the movies/tv shows by director 'Rajiv Chilaka'

SELECT 
	type,
    title,
    director
FROM netflix
WHERE LOWER(director) LIKE LOWER('%Rajiv Chilaka%');

-- 8. List all tv shows with more than 5 seasons

SELECT
	title,
    duration
FROM netflix
WHERE type = 'TV Show'
	AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
    
-- 9. Count the number of content items in each genre

-- listed in (genre) has multiple comma seperated string values
SET SESSION cte_max_recursion_depth = 5000;
WITH RECURSIVE split_genre AS
	(
		SELECT 
			show_id,
            TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
            TRIM(SUBSTRING(listed_in, LOCATE(',', listed_in) + 1)) AS remaining_genre
		FROM netflix
        
        UNION ALL
        
        SELECT
			show_id,
            TRIM(SUBSTRING_INDEX(remaining_genre, ',', 1)) AS genre,
            CASE
				WHEN LOCATE(',', remaining_genre) > 0 THEN 
					TRIM(SUBSTRING(remaining_genre, LOCATE(',', remaining_genre) + 1)) 
				ELSE NULL
			END AS remaining_genre
		FROM split_genre
        WHERE remaining_genre IS NOT NULL
    )
SELECT
	genre,
    COUNT(*) AS num_content
FROM split_genre
WHERE genre IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

SET SESSION wait_timeout = 28800; -- default
SET SESSION max_execution_time = 600000; -- 10 mins default

-- 10. Find each year and the average number of content release by India on Netflix
-- return top 5 year with highest avg content release 

SET SESSION cte_max_recursion_depth = 5000;

WITH RECURSIVE split AS (
    -- Initial selection to split the first country
    SELECT 
        show_id, 
        date_added,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS single_country,
        TRIM(SUBSTRING(country, LOCATE(',', country) + 1)) AS remaining_country
    FROM netflix
    WHERE country IS NOT NULL

    UNION ALL

    -- Recursive selection to continue splitting remaining countries
    SELECT 
        show_id,
        date_added,
        TRIM(SUBSTRING_INDEX(remaining_country, ',', 1)) AS single_country,
        CASE
            WHEN LOCATE(',', remaining_country) > 0 THEN
                TRIM(SUBSTRING(remaining_country, LOCATE(',', remaining_country) + 1))
            ELSE NULL
        END AS remaining_country
    FROM split
    WHERE remaining_country IS NOT NULL AND remaining_country <> ''
)
SELECT 
    single_country AS country,
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year_added,
    COUNT(*) AS total_content_per_year,
    (COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'India')) * 100 AS avg_content_release
FROM split
WHERE single_country = 'India'
GROUP BY country, year_added;

-- 11. List all movies that are documentaries

SET SESSION cte_max_recursion_depth = 5000;
WITH RECURSIVE split_genre AS
	(
		SELECT
			title,
            TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
            CASE
				WHEN LOCATE(',', listed_in) > 0 THEN
						TRIM(SUBSTRING(listed_in, LOCATE(',', listed_in) + 1))
				ELSE NULL
			END AS remaining_genre
            FROM netflix
            WHERE listed_in IS NOT NULL
            
		UNION ALL
            
		SELECT
			title,
            TRIM(SUBSTRING_INDEX(remaining_genre, ',', 1)) AS genre,
            CASE 
				WHEN LOCATE(',', remaining_genre) > 0 THEN
					TRIM(SUBSTRING(remaining_genre, LOCATE(',', remaining_genre) + 1)) 
				ELSE NULL
			END AS remaining_genre
            FROM split_genre
            WHERE remaining_genre IS NOT NULL
    )
SELECT
	title
FROM split_genre
WHERE genre = 'Documentaries';

-- 12. Find all content without a director

SELECT
	show_id,
    title
FROM netflix
WHERE director = '' OR director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

-- cast column has multiple names comma seperated so
SET SESSION cte_max_recursion_depth = 5000;
WITH RECURSIVE split_cast AS
	(
		SELECT
			show_id,
            release_year,
            TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS cast,
            CASE
				WHEN LOCATE(',',cast) > 0 THEN
					TRIM(SUBSTRING(cast, LOCATE(',',cast) + 1))
                ELSE NULL
			END AS remaining_cast
		FROM netflix
        WHERE cast IS NOT NULL AND cast <> ''
        
        UNION ALL
        
        SELECT
			show_id,
            release_year,
            TRIM(SUBSTRING_INDEX(remaining_cast, ',', 1)) AS cast,
            CASE
				WHEN LOCATE(',',cast) > 0 THEN
					TRIM(SUBSTRING(cast, LOCATE(',',cast) + 1))
                ELSE NULL
			END AS remaining_cast
		FROM split_cast
        WHERE remaining_cast IS NOT NULL AND remaining_cast <> ''
    )
SELECT
	cast,
	COUNT(*) AS num_of_show_appeared
FROM split_cast
WHERE cast = 'Salman Khan'
	AND release_year >= YEAR(CURDATE()) - 10
GROUP BY 1;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

SET SESSION cte_max_recursion_depth = 5000;
WITH RECURSIVE split_cast AS
	(
		SELECT
			show_id,
            release_year,
            TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS cast,
            CASE
				WHEN LOCATE(',',cast) > 0 THEN
					TRIM(SUBSTRING(cast, LOCATE(',',cast) + 1))
                ELSE NULL
			END AS remaining_cast
		FROM netflix
        WHERE cast IS NOT NULL AND cast <> ''
        
        UNION ALL
        
        SELECT
			show_id,
            release_year,
            TRIM(SUBSTRING_INDEX(remaining_cast, ',', 1)) AS cast,
            CASE
				WHEN LOCATE(',',cast) > 0 THEN
					TRIM(SUBSTRING(cast, LOCATE(',',cast) + 1))
                ELSE NULL
			END AS remaining_cast
		FROM split_cast
        WHERE remaining_cast IS NOT NULL AND remaining_cast <> ''
    ),
split_country AS (
    -- Initial selection to split the first country
    SELECT 
        show_id, 
        date_added,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS single_country,
        TRIM(SUBSTRING(country, LOCATE(',', country) + 1)) AS remaining_country
    FROM netflix
    WHERE country IS NOT NULL

    UNION ALL

    -- Recursive selection to continue splitting remaining countries
    SELECT 
        show_id,
        date_added,
        TRIM(SUBSTRING_INDEX(remaining_country, ',', 1)) AS single_country,
        CASE
            WHEN LOCATE(',', remaining_country) > 0 THEN
                TRIM(SUBSTRING(remaining_country, LOCATE(',', remaining_country) + 1))
            ELSE NULL
        END AS remaining_country
    FROM split_country
    WHERE remaining_country IS NOT NULL AND remaining_country <> ''
)
SELECT
	cast,
    COUNT(*) AS num_show_appeared
FROM split_cast
JOIN split_country ON split_cast.show_id = split_country.show_id
WHERE single_country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description
-- field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many
-- items fall into each category