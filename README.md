# MGetIt with the Alma Link Resolver, and Sinatra

## Docker-compose

Getting started for the first time. Or without a populated database schema.

Because ActiveRecord expects the database schema to be present on startup, you'll need to bring up the database and populate it before bringing up the webserver.

```bash
docker compose up --build --no-start
docker compose start mysql-web
docker compose run --rm web bundle install
docker compose run --rm web bundle exec rake db:migrate
docker compose run --rm web bundle exec rake assets:precompile
docker compose up
```

Getting started with a populated database schema

`docker compose up` or `docker compose start`



