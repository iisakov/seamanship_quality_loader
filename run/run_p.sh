#! /bin/bash
echo -ne '\007'
window=$1


file_nun=1
echo seed: $seed, window: $window

for (( i=1; i <= 1; i++ ))
do
  seed=$(($RANDOM))
  let "file_nun=$i+$window*100"
  echo run log_$file_nun.log
  echo seed $seed > ../log/log_$file_nun.log
  docker run \
  --mount "type=bind,src=$(pwd)/seeman_1.sql,dst=/tmp/player1-solution.sql" \
  --mount "type=bind,src=$(pwd)/options.toml,dst=/tmp/options.toml" \
  --mount "type=bind,src=$(pwd)/seeman_2.sql,dst=/tmp/player2-solution.sql" \
  --rm -it -e SEED=$seed ghcr.io/all-cups/it_one_cup_sql \
  --solution /tmp/player1-solution.sql \
  --solution /tmp/player2-solution.sql \
  --dump-init /tmp/init.sql \
  --options /tmp/options.toml \
  --log info >> ../log/log_$file_nun.log
    echo done log_$file_nun.log
done

echo -ne '\007'
