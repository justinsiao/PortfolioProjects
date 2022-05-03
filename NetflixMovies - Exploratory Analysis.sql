SELECT *
FROM netflixtable;

-- TV Shows VS Movies

SELECT type, COUNT(type)
FROM netflixtable
GROUP BY type;

-- Show what date has the highest number of movies/series added.

SELECT date_added, COUNT(date_added)
FROM netflixtable
GROUP BY date_added
ORDER BY COUNT(date_added) DESC;

-- Top directors with highest number of movies/series produced.

SELECT director, COUNT(director)
FROM netflixtable
GROUP BY director
ORDER BY COUNT(director) DESC;

-- What country has maximum number of movies and series

SELECT country, COUNT(country)
FROM netflixtable
WHERE type = 'Movie'
GROUP BY country
ORDER BY COUNT(country) DESC;

SELECT country, COUNT(country)
FROM netflixtable
WHERE type = 'TV Show'
GROUP BY country
ORDER BY COUNT(country) DESC;

-- Determine what month has the highest movies produced.

SELECT EXTRACT(MONTH FROM date_added) as month_num, COUNT(EXTRACT(MONTH FROM date_added)) as count_per_month
FROM netflixtable
GROUP BY EXTRACT(MONTH FROM date_added)
ORDER BY count_per_month DESC;

-- Top actors on netflix with the most number of movies in the Philippines

WITH cast_characters AS 
(
	SELECT UNNEST(string_to_array(cast_char, ', ')) as each_cast
	FROM netflixtable
	WHERE country = 'Philippines'
	)
SELECT each_cast, COUNT(each_cast) as count_each_cast
FROM cast_characters
GROUP BY each_cast
ORDER BY count_each_cast DESC;

-- List of all movies from top actors with the most number of movies in the Philippines

WITH cast_characters AS 
(
	SELECT UNNEST(string_to_array(cast_char, ', ')) as each_cast, title
	FROM netflixtable
	WHERE country = 'Philippines'
	)
SELECT each_cast, title
FROM cast_characters
GROUP BY each_cast, title
ORDER BY COUNT(each_cast) OVER (PARTITION BY each_cast) DESC, each_cast ASC;

-- Top actors globally based on movies that they are in

WITH cast_characters AS 
(
	SELECT UNNEST(string_to_array(cast_char, ', ')) as each_cast
	FROM netflixtable
	--WHERE country = 'Philippines'
	)
SELECT each_cast, COUNT(each_cast) as count_each_cast
FROM cast_characters
GROUP BY each_cast
ORDER BY count_each_cast DESC;

-- Top number of movie genres produced GLOBALLY

SELECT genres, COUNT(genres) as count_genres
FROM (SELECT UNNEST(string_to_array(listed_in, ', ')) as genres, country
	  FROM netflixtable) as netflixtable_new
WHERE genres NOT IN ('International Movies', 'Independent Movies', 'International TV Shows')
--WHERE country = 'Philippines' AND genres NOT IN ('International Movies', 'Independent Movies', 'International TV Shows')
GROUP BY genres
ORDER BY count_genres DESC;

