#!/bin/bash
current_path="$(dirname "$0")"
source "$current_path/functions.sh"

# Vars
container_manually_started=false # Has the container started manually or was it already started
image_name="wordpress:latest"
service_name="wordpress" 

# Ensure the build directory exists
create_build_directory

echo "Please wait while we're exporting the WordPress files..."

# Start the container if it hasn't started
start_container_if_not_started "$image_name" "$service_name"

# Get the container name
container_name=$(get_container_name $image_name)

# Spin up the browsersync service, build the files with the optimized settings
docker-compose run -e NODE_ENV=production browsersync node_modules/.bin/gulp build

# Run the Docker's COPY method to copy
docker cp $container_name:/var/www/html/ ./build
echo "Successfully exported the files."


# Remove the src files from the final build
cd $current_path
cd ../build/html/wp-content/themes
remove_src_directories_in_themes

# If manually started the container, then let's stop it
if [ "$container_manually_started" = true ] ; then
    docker-compose stop "$service_name" > /dev/null
    docker-compose stop mysql-wordpress > /dev/null
fi