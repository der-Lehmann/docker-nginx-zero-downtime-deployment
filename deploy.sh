reload_nginx() {
    docker compose exec web nginx -s reload
}

zero_downtime_deploy() {
    SERVICE=app
    BACKUP_SERVICE=app_backup

    OLD_CONTAINER_ID=$(docker compose ps $SERVICE -q | tail -n1)

    # Bring a new container online, running new code
    # (nginx continues routing to the old container only)
    docker compose up -d --no-deps --scale $SERVICE=2 --no-recreate $SERVICE

    # Wait so that the new container is ready to accept connections. A healthcheck could be used instead.
    sleep 5s

    # Start routing requests to the new container (as well as the old)
    reload_nginx

    # Take the old container offline.
    # From here on, requests could hit the stopped container until the nginx config has been reloaded.
    # If a request would hit the stopped container nginx would forward the request to the app_backup service after the time specified in the fastcgi_connect_timeout directive.
    docker stop $OLD_CONTAINER_ID

    # Stop routing requests to the old container
    reload_nginx

    # Remove old container
    docker rm $OLD_CONTAINER_ID

    docker compose up -d --no-deps --scale $SERVICE=1 --no-recreate $SERVICE

    # Now requests will only hit the new container.
    # We can therefore safely update the app_backup service so it has the latest image for the next time it will handle requests during a deployment.
    docker compose up -d --no-deps $BACKUP_SERVICE
}

zero_downtime_deploy
