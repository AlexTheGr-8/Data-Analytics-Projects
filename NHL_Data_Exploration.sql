SELECT *
FROM NHL_Project.dbo.Draft_data

-- Total number of players selected each year
SELECT year, COUNT(player) AS Total_players_selected_each_year
FROM NHL_Project.dbo.Draft_data
GROUP BY year
ORDER BY year



-- Using CTE to find an average number of players drafted each year
WITH AvgPerYear (year, Total_players_selected_each_year)
AS 
(
SELECT year, COUNT(player) AS Total_players_selected_each_year
FROM NHL_Project.dbo.Draft_data
GROUP BY year
)

SELECT year, AVG(Total_players_selected_each_year) AS Avg_players_each_year
FROM AvgPerYear
GROUP BY year
ORDER BY year



-- Looking at the total number of players selected from each country
SELECT nationality, COUNT(player) AS Total_players_selected
FROM NHL_Project.dbo.Draft_data
GROUP BY nationality
ORDER BY Total_players_selected DESC

SELECT year, nationality, position, COUNT(player) AS Total_players_selected
FROM NHL_Project.dbo.Draft_data
GROUP BY year, nationality, position
ORDER BY year, Total_players_selected DESC



-- Using CTE to compute a running total for each nationality
WITH Rtot (year, nationality, Total_players_selected)
AS 
(
SELECT year, nationality, COUNT(player) AS Total_players_selected
FROM NHL_Project.dbo.Draft_data
GROUP BY year, nationality
)

SELECT year, nationality, Total_players_selected, SUM(Total_players_selected) OVER (PARTITION BY nationality ORDER BY nationality, year) AS Running_Total
FROM Rtot
ORDER BY nationality, year




-- Looking at the total number of players selected by position
SELECT position, COUNT(player) AS Total_players_selected_by_position
FROM NHL_Project.dbo.Draft_data
GROUP BY position
ORDER BY Total_players_selected_by_position DESC


SELECT year, position, COUNT(player) AS Total_players_selected_by_position
FROM NHL_Project.dbo.Draft_data
GROUP BY year, position
ORDER BY year, Total_players_selected_by_position DESC




-- Looking at an average number of years played by players selected in different rounds
SELECT round_selected, AVG(years_played_in_NHL) AS Average_number_of_years_played
FROM NHL_Project.dbo.Draft_data
WHERE year <> '2022'
GROUP BY round_selected
ORDER BY round_selected



-- Make CTE to find an average number of new players that have been able to remain in NHL each year
WITH AvgInNHL (year, Total_number_of_players_stayed_in_NHL)
AS 
(
SELECT year, COUNT(player) AS Total_number_of_players_stayed_in_NHL
FROM NHL_Project.dbo.Draft_data
WHERE years_played_in_NHL >= 1
GROUP BY year
)

SELECT year, AVG(Total_number_of_players_stayed_in_NHL) AS Average_number_of_players_stayed_in_NHL
FROM AvgInNHL
GROUP BY year
ORDER BY year


-- Looking at the performance of players selected in different rounds
SELECT AVG(games_played) -- to find the baseline for the WHERE clause in the next query
FROM NHL_Project.dbo.Draft_data

SELECT round_selected, AVG(points) AS Avg_points, AVG(goals) AS Avg_goals, AVG(assists) AS Avg_assits
FROM NHL_Project.dbo.Draft_data
WHERE games_played >= 137
GROUP BY round_selected
ORDER BY round_selected



-- Average games played by a player from each NHL team
SELECT team, AVG(games_played) AS Avg_games_played_by_team
FROM NHL_Project.dbo.Draft_data
GROUP BY team
ORDER BY Avg_games_played_by_team DESC



-- Looking at amateur leagues from which players were drafted
SELECT amateur_league, COUNT(player) AS Total_players_drafted_from_each_league
FROM NHL_Project.dbo.Draft_data
GROUP BY amateur_league
ORDER BY Total_players_drafted_from_each_league DESC



-- Creating a temp table and adding a grand total column
DROP TABLE IF EXISTS #Avg_pct
CREATE TABLE #Avg_pct
(amateur_league nvarchar(255),
Total_players int)

INSERT INTO #Avg_pct
SELECT amateur_league, COUNT(player) AS Total_players_drafted_from_each_league
FROM NHL_Project.dbo.Draft_data
GROUP BY amateur_league

SELECT SUM(Total_players)
FROM #Avg_pct

ALTER TABLE #Avg_pct
ADD Grand_total int

UPDATE #Avg_pct
SET Grand_total = ISNULL(Grand_total, 10944)


SELECT *
FROM #Avg_pct
ORDER BY Total_players DESC
