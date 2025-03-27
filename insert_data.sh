#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Skip the first line (header) and process the rest of the CSV
tail -n +2 games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Remove any potential quotes from the fields
  year=$(echo "$year" | tr -d '"')
  round=$(echo "$round" | tr -d '"')
  winner=$(echo "$winner" | tr -d '"')
  opponent=$(echo "$opponent" | tr -d '"')
  winner_goals=$(echo "$winner_goals" | tr -d '"')
  opponent_goals=$(echo "$opponent_goals" | tr -d '"')

  # Insert into teams table for winner
  WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT (name) DO NOTHING")

  # Insert into teams table for opponent
  OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT (name) DO NOTHING")

  # Get winner_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")

  # Get opponent_id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")

  # Insert into games table
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)")

  # Optional: Add some logging or error checking
  echo "Processed game: $year, $round, $winner vs $opponent, Score: $winner_goals-$opponent_goals"
done