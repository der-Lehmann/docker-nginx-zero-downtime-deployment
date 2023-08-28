docker build -t php1 -f ./dockerfiles/php1.dockerfile .;
docker build -t php2 -f ./dockerfiles/php2.dockerfile .;

export APP_IMAGE=php1;

docker compose -f ../docker-compose.yml up -d;
# The compose project is now running the php1 image and is accessible under localhost


# Start the load test and wait 5 seconds so that artillery had enough time to start up
cmd="artillery run --output load-test-report.json ./load-test.yml;";
eval "${cmd}" &>/dev/null & disown;
sleep 5;

# Update the image to be used by docker compose and deploy the new image
export APP_IMAGE=php2;
bash ../deploy.sh;

# Waiting for load test to finish
sleep 5;

docker compose -f ../docker-compose.yml down -v;