echo "Starting 3rd party servers"
fig up -d db mongo memcache
fig ps
echo "Started 3rd party servers"
echo "Staring web and api server"
docker run -P -p 8000:8000 -d webserver python /code/api/rpgthing/manage.py runserver 0.0.0.0:8000
docker ps
echo "Started web and api server"
echo "Starting game server"
docker run -P -p 8080:8080 -d game_server /code/serverSide/game_server --addr :8080 --assets /code/serverSide
docker ps
echo "Started game server"
