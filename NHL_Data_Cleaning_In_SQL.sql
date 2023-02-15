SELECT *
FROM NHL_Project.dbo.Draft_data



--Deleting columns that will not be used for the analysis
ALTER TABLE NHL_Project.dbo.Draft_data
DROP COLUMN goalie_games_played, goalie_wins, goalie_losses, goalie_ties_overtime, save_percentage, goals_against_average, point_shares



--Deleting rows realted to goalkeeper data, as this analysis is only concerned with skaters
DELETE FROM NHL_Project.dbo.Draft_data
WHERE position = 'G'



--Changing the nationality column to display a full country name
UPDATE NHL_Project.dbo.Draft_data
SET nationality = CASE WHEN nationality = 'CA' THEN 'Canada'
			WHEN nationality = 'US' THEN 'United States'
			WHEN nationality = 'SE' THEN 'Sweden'
			WHEN nationality = 'RU' THEN 'Russia'
			WHEN nationality = 'CZ' THEN 'Czech Republic'
			WHEN nationality = 'FI' THEN 'Finland'
			WHEN nationality = 'SK' THEN 'Slovakia'
			WHEN nationality = 'DE' THEN 'Germany'
			WHEN nationality = 'CH' THEN 'Switzerland'
			WHEN nationality = 'LV' THEN 'Latvia'
			WHEN nationality = 'DK' THEN 'Denmark'
			WHEN nationality = 'NO' THEN 'Norway'
			ELSE 'Rest of the World'
			END

SELECT nationality, COUNT(nationality) AS count_nationality
FROM NHL_Project.dbo.Draft_data
GROUP BY nationality
ORDER BY count_nationality DESC --Checking the results



--Splitting the amateur_team column to extract the name of the league in which a player was playing
SELECT amateur_team, SUBSTRING(amateur_team, CHARINDEX('(', amateur_team) +1, LEN(amateur_team))
FROM NHL_Project.dbo.Draft_data



--Creting a new column called amateur_league and populating it with results from the previous query
ALTER TABLE Draft_data
ADD amateur_league Nvarchar(250)

UPDATE NHL_Project.dbo.Draft_data
SET amateur_league = SUBSTRING(amateur_team, CHARINDEX('(', amateur_team) +1, LEN(amateur_team))



--Removing a parenthisis in the amateur league column
SELECT amateur_league, REPLACE(amateur_league, ')','')
FROM NHL_Project.dbo.Draft_data

UPDATE NHL_Project.dbo.Draft_data
SET amateur_league = REPLACE(amateur_league, ')','')



--Updating the amateur_team column to only show the team name
SELECT amateur_team, SUBSTRING(amateur_team, 1, CHARINDEX('(', amateur_team) -1)
FROM NHL_Project.dbo.Draft_data

UPDATE NHL_Project.dbo.Draft_data
SET amateur_team = SUBSTRING(amateur_team, 1, CHARINDEX('(', amateur_team) -1)



--Cleaning the position column - replacing some symbols  and updating the position column to only display a primary position
SELECT position
FROM NHL_Project.dbo.Draft_data
GROUP BY position

UPDATE NHL_Project.dbo.Draft_data
SET position = REPLACE(position, ';','/')

UPDATE NHL_Project.dbo.Draft_data
SET position = REPLACE(position, 'Centr','C')



--Updating pdating the position column to only display a primary position
SELECT position, CASE WHEN position LIKE 'C%' THEN 'C'
					  WHEN position LIKE 'R%' THEN 'RW'
					  WHEN position LIKE 'D%' THEN 'D'
					  WHEN position LIKE 'L%' THEN 'LW'
					  ELSE position
					  END
FROM NHL_Project.dbo.Draft_data
GROUP BY position

UPDATE NHL_Project.dbo.Draft_data
SET position = CASE WHEN position LIKE 'C%' THEN 'C'
					WHEN position LIKE 'R%' THEN 'RW'
					WHEN position LIKE 'D%' THEN 'D'
					WHEN position LIKE 'L%' THEN 'LW'
					ELSE position
					END


--Deleting null records and postions tha can't be accurately specified from the position column
DELETE FROM NHL_Project.dbo.Draft_data
WHERE position IN ('W', 'F')

DELETE FROM NHL_Project.dbo.Draft_data
WHERE position IS NULL



--Populatiing replacing null values in games_played, goals, assits, points plus_minus and penalties_minutes columns with 0
UPDATE NHL_Project.dbo.Draft_data
SET games_played = ISNULL(games_played, 0)

UPDATE NHL_Project.dbo.Draft_data
SET goals = ISNULL(goals, 0)

UPDATE NHL_Project.dbo.Draft_data
SET assists = ISNULL(assists, 0)

UPDATE NHL_Project.dbo.Draft_data
SET points = ISNULL(points, 0)

UPDATE NHL_Project.dbo.Draft_data
SET plus_minus = ISNULL(plus_minus, 0)

UPDATE NHL_Project.dbo.Draft_data
SET penalties_minutes = ISNULL(penalties_minutes, 0)



--Creating a column years_played_in_NHL and populating it with values and replacing nulls with 0
ALTER TABLE Draft_data
ADD years_played_in_NHL int

SELECT (to_year - year)
FROM NHL_Project.dbo.Draft_data

UPDATE NHL_Project.dbo.Draft_data
SET years_played_in_NHL = to_year - year

UPDATE NHL_Project.dbo.Draft_data
SET years_played_in_NHL = ISNULL(years_played_in_NHL, 0)



--Creating the same name for the Russian leagues in the amateur_league column
SELECT DISTINCT(amateur_league), CASE WHEN amateur_league LIKE '%Russia%' THEN 'Russia'
									  WHEN amateur_league LIKE '%Soviet%' THEN 'Russia'
									  ELSE amateur_league
									  END
FROM NHL_Project.dbo.Draft_data
WHERE amateur_league LIKE '%Russia%'
OR amateur_league LIKE '%Soviet%'

UPDATE NHL_Project.dbo.Draft_data
SET amateur_league = CASE WHEN amateur_league LIKE '%Russia%' THEN 'Russia'
						  WHEN amateur_league LIKE '%Soviet%' THEN 'Russia'
						  ELSE amateur_league
						  END


--Creating a column round_selected and populating it with the data
ALTER TABLE Draft_data
ADD round_selected int

SELECT year, max(overall_pick) as op
from NHL_Project.dbo.Draft_data
group by year
order by op desc

SELECT overall_pick, CASE WHEN overall_pick BETWEEN 1 AND 30 THEN 1
						  WHEN overall_pick BETWEEN 31 AND 65 THEN 2
						  WHEN overall_pick BETWEEN 66 AND 96 THEN 3
						  WHEN overall_pick BETWEEN 97 AND 130 THEN 4
						  WHEN overall_pick BETWEEN 131 AND 167 THEN 5
						  WHEN overall_pick BETWEEN 168 AND 197 THEN 6
						  WHEN overall_pick BETWEEN 198 AND 229 THEN 7
						  WHEN overall_pick BETWEEN 230 AND 261 THEN 8
						  WHEN overall_pick BETWEEN 262 AND 293 THEN 9
						  END
FROM NHL_Project.dbo.Draft_data


UPDATE NHL_Project.dbo.Draft_data
SET round_selected = CASE WHEN overall_pick BETWEEN 1 AND 30 THEN 1
						  WHEN overall_pick BETWEEN 31 AND 65 THEN 2
						  WHEN overall_pick BETWEEN 66 AND 96 THEN 3
						  WHEN overall_pick BETWEEN 97 AND 130 THEN 4
						  WHEN overall_pick BETWEEN 131 AND 167 THEN 5
						  WHEN overall_pick BETWEEN 168 AND 197 THEN 6
						  WHEN overall_pick BETWEEN 198 AND 229 THEN 7
						  WHEN overall_pick BETWEEN 230 AND 261 THEN 8
						  WHEN overall_pick BETWEEN 262 AND 293 THEN 9
						  END