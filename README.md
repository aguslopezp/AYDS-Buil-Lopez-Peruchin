# AYDS-Buil-Lopez-Peruchin

## Useful commands

# Run the server & container
``` sudo aa-remove-unknown ```
``` sudo chmod 666 /var/run/docker.sock ```
``` sudo docker compose build ```
``` sudo docker compose up app ```

# Check if rake is working 
``` docker compose exec app bundle exec rake -T ```

# Create DB
``` docker compose exec app bundle exec rake db:create ```

# Create a migration to create the table
``` sudo docker compose exec app bundle exec rake db:create_migration NAME=create_question ```

# Run the migration
``` docker compose exec app bundle exec rake db:migrate ```

# Stop runing the container
``` sudo docker compose down ```