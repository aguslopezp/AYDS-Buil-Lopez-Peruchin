# Eco-Tree project
Integrantes: Buil Delfina, Lopez Agustin, Peruchin Ivan

# Useful commands

## Run the server & container
1. ``` sudo aa-remove-unknown ```
2. ``` sudo chmod 666 /var/run/docker.sock ```
3. ``` sudo docker compose build ```
4. ``` sudo docker compose up app ```

Check if rake is working: ``` sudo docker compose exec app bundle exec rake -T ```

Create DB: ``` sudo docker compose exec app bundle exec rake db:create ```

Create a migration to create the table: ``` sudo docker compose exec app bundle exec rake db:create_migration NAME=create_question ```

Run the migration: ``` sudo docker compose exec app bundle exec rake db:migrate ```

Run the seeds.rb: ``` sudo docker compose exec app bundle exec rake db:seed ```

Stop runing the container: ``` sudo docker compose down ```

## Commands for tests 
Run the migration for db test: ``` docker compose exec app bundle exec rake db:migrate RACK_ENV=test ```

``` sudo docker compose exec -e RACK_ENV=test app bundle exec rspec --format doc ```

Run test: ``` sudo docker compose exec app bundle exec rspec --require spec_helper.rb ```