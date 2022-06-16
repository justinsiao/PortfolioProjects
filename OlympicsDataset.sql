DROP TABLE IF EXISTS olympics_hist;
CREATE TABLE olympics_hist(
	id INT,
	name VARCHAR,
	sex	VARCHAR,
	age	VARCHAR,
	height VARCHAR,
	weight VARCHAR,
	team VARCHAR,
	noc VARCHAR,
	games VARCHAR,
	year INT,
	season VARCHAR,
	city VARCHAR,
	sport VARCHAR,
	event VARCHAR,
	medal VARCHAR
);

DROP TABLE IF EXISTS olympics_hist_noc_regions;
CREATE TABLE olympics_hist_noc_regions(
	noc VARCHAR,
	region VARCHAR,
	notes VARCHAR
);

SELECT *
FROM olympics_hist;

SELECT *
FROM olympics_hist_noc_regions

-- How many olympics games have been held?
SELECT count(distinct(games)) as total_olympic_games
FROM olympics_hist;

-- List down all Olympics games held so far.
SELECT DISTINCT year, season, city
FROM olympics_hist
ORDER BY year;

-- Mention the total no of nations who participated in each olympics game?
WITH all_countries as (
	SELECT games, nr.region
	FROM olympics_hist oh
	JOIN olympics_hist_noc_regions nr
	ON nr.noc = oh.noc
	GROUP BY games, nr.region)
SELECT games, count(1) as total_countries
FROM all_countries
GROUP BY games
ORDER BY games;

-- Which year saw the highest and lowest no of countries participating in olympics?
WITH all_countries as
		(SELECT games, nr.region
		FROM olympics_hist oh
		JOIN olympics_hist_noc_regions nr
		ON oh.noc = nr.noc
		GROUP BY games, nr.region),
	tot_countries as
		(SELECT games, count(*) as total_countries
		FROM all_countries
		GROUP BY games)
SELECT distinct concat(FIRST_VALUE(games) OVER(ORDER BY total_countries), ' - ', 
					   FIRST_VALUE(total_countries) OVER(ORDER BY total_countries)) as lowest_countries,
				concat(FIRST_VALUE(games) OVER(ORDER BY total_countries DESC), ' - ',
					   FIRST_VALUE(total_countries) OVER(ORDER BY total_countries DESC)) as highest_countries
FROM tot_countries;

-- Which nation has participated in all of the olympic games?
WITH tot_games as
		(SELECT count(distinct games) as total_games
		 FROM olympics_hist),
	 countries as
	 	(SELECT games, nr.region as country
		 FROM olympics_hist oh
		 JOIN olympics_hist_noc_regions nr
		 ON oh.noc = nr.noc
		 GROUP by games, nr.region),
	 countries_participated as
	 	(SELECT country, count(*) as total_participated_games
		 FROM countries
		 GROUP BY country)
SELECT cp.*
FROM countries_participated cp
JOIN tot_games tg
ON cp.total_participated_games = tg.total_games
ORDER BY 1;

-- Identify the sport which was played in all summer olympics.
WITH t1 as (
		SELECT count(distinct(games)) as total_summer_games
		FROM olympics_hist
		WHERE season = 'Summer'),
	t2 as (
		SELECT distinct sport, games
		FROM olympics_hist
		WHERE season = 'Summer'
		ORDER BY games),
	t3 as (
		SELECT sport, count(games) as no_of_games
		FROM t2
		GROUP BY sport)
SELECT *
FROM t3
JOIN t1
ON t1.total_summer_games = t3.no_of_games;

-- Which Sports were just played only once in the olympics?
WITH t1 as (
		SELECT distinct sport, games
		FROM olympics_hist),
	t2 as (
		SELECT sport, count(*) as tot_played
		FROM t1
		GROUP BY sport)
SELECT *
FROM t2
WHERE tot_played = 1
ORDER BY 1;

-- Fetch the total no of sports played in each olympic games.
WITH t1 as (
		SELECT distinct games, sport
		FROM olympics_hist),
	t2 as (
		SELECT games, count(sport) as total_sports
		FROM t1
		GROUP BY games) 
SELECT *
FROM t2
ORDER BY 2 DESC;

-- Fetch details of the oldest athletes to win a gold medal.
WITH t1 as (
		SELECT name, sex, CAST(CASE WHEN age = 'NA' THEN '0' ELSE age END as INT), team, games, city, sport, event, medal
		FROM olympics_hist),
	ranking as (
		SELECT *, RANK() OVER(ORDER BY age DESC) as rnk
		FROM t1
		WHERE medal = 'Gold')
SELECT *
FROM ranking
WHERE rnk = 1;
	
-- Find the Ratio of male and female athletes participated in all olympic games.
WITH t1 as (
		SELECT sex, count(*) as cnt
		FROM olympics_hist
		GROUP by sex),
	t2 as (
		SELECT *, ROW_NUMBER() OVER(ORDER BY cnt) as rn
		FROM t1),
	min_cnt as (
		SELECT cnt
		FROM t2
		WHERE rn = 1),
	max_cnt as (
		SELECT cnt
		FROM t2
		WHERE rn =2)
SELECT CONCAT('1: ', ROUND(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
FROM min_cnt, max_cnt