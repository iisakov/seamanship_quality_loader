#! /bin/bash
sudo systemctl start docker

docker run \
  -p 2345:5432 \
  -p 3345:5433 \
  --mount "type=bind,src=$(pwd)/seeman_v2.0.0.sql,dst=/tmp/player1-solution.sql" \
  --mount "type=bind,src=$(pwd)/seeman_v1.1.1.sql,dst=/tmp/player2-solution.sql" \
  --mount "type=bind,src=$(pwd)/init.sql,dst=/tmp/init.sql" \
  --mount "type=bind,src=$(pwd)/options.toml,dst=/tmp/options.toml" \
  --rm -it -e SEED=1234567 ghcr.io/all-cups/it_one_cup_sql \
  --solution /tmp/player1-solution.sql \
  --solution /tmp/player2-solution.sql \
  --dump-init /tmp/init.sql \
  --options /tmp/options.toml \
  --log INFO \
  --leave-running
