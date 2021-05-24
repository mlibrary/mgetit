# MGetIt with Umlaut, with 360Link

## Setup

1. `git clone https://github.com/mlibrary/mgetit`
2. `bundle install --path .bundle`
3. add a `config/database.yml` example:

    ```yaml
    default: &default
      host: YOUR_HOST_HERE
      adapter: mysql2
      encoding: utf8
      pool: 5
      username: YOUR_USERNAME_HERE
      password: YOUR_PASSWORD_HERE
      database: YOUR_DATABASE_HERE
    development:
      <<: *default
    test:
      <<: *default
    production:
      <<: *default
    ```
4. Add a `config/umlaut_services.yml` file.
5. Add a `config/360link.yml` file.
6. If needed, adjust `config/application.rb`

    ```ruby
    config.relative_url_root = "/path/to/application"
    config.action_controller.relative_url_root = "/path/to/application"
    ```
    
7. `bundle exec rake db:migrate`
8. `bundle exec rackup`

## To clear
`bundle exec rake umlaut:clear`

## Docker-compose

```bash
docker-compose up --build
docker-compose run web bundle install
docker-compose run web bundle exec rake db:migrate
docker-compose run web bundle exec rake assets:precompile
```
