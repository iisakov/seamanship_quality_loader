#! /bin/bash
sudo systemctl start docker

docker run \
  -p 2345:5432 \
  -p 3345:5433 \
  -p 4345:5434 \
  --mount "type=bind,src=$(pwd)/seeman_1.sql,dst=/tmp/player1-solution.sql" \
  --mount "type=bind,src=$(pwd)/seeman_2.sql,dst=/tmp/player2-solution.sql" \
  --mount "type=bind,src=$(pwd)/options.toml,dst=/tmp/options.toml" \
  --rm -it -e SEED=$(($RANDOM)) ghcr.io/all-cups/it_one_cup_sql \
  --solution /tmp/player1-solution.sql \
  --solution /tmp/player2-solution.sql \
  --dump-init /tmp/init.sql \
  --options /tmp/options.toml \
  --log info \
  --leave-running


# --mount "type=bind,src=$(pwd)/seeman_2.sql,dst=/tmp/player2-solution.sql" \
#     --solution /tmp/player2-solution.sql \
