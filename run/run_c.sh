#! /bin/bash

if [ -n "$1" ]
then
iteration=$1
else
iteration=1
fi

seed=246347
echo seed: $seed, iteration: $iteration

  echo run log_$iteration.log
  echo seed $seed > ../log/log_$iteration.log
  docker run \
  --mount "type=bind,src=$(pwd)/seeman_1.sql,dst=/tmp/player1-solution.sql" \
  --mount "type=bind,src=$(pwd)/options.toml,dst=/tmp/options.toml" \
  --rm -it -e SEED=$seed ghcr.io/all-cups/it_one_cup_sql \
  --solution /tmp/player1-solution.sql \
  --dump-init /tmp/init.sql \
  --options /tmp/options.toml \
  --log info >> ../log/log_$iteration.log
    echo done log_$iteration.log
