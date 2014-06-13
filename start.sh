echo "Starting 3rd party servers"
fig up -d db memcache
fig ps
echo "Started 3rd party servers"
echo "Staring web and api server"
docker run -P -p 8000:8000 --name webserver -d api_web python /code/api/rpgthing/manage.py runserver 0.0.0.0:8000
docker ps
echo "Started web and api server"
echo "Starting game server"
docker run -P -p 8080:8080 --name gameserver -d api_gameserver /code/serverSide/game_server --addr :8080 --assets /code/serverSide
docker ps
echo "Started game server"
echo "Creating data volumes server...."
docker run -v /home --volumes-from webserver --volumes-from gameserver --name home-vol busybox true
echo "Creating file server...."
boot2docker ssh "docker run --rm --name sambaserver -v $(which docker):/docker -v /var/run/docker.sock:/docker.sock -e DOCKER_HOST svendowideit/samba home-vol"
echo "Mounting file shares...."
mkdir -p /Volumes/docker-dev
mount_smbfs //192.168.59.103/ /Volumes/docker-dev
ls -al /Volumes/docker-dev
echo "You should be good to go your code is in /Volumes/docker-dev"
