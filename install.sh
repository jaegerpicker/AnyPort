echo "Docker, boot2docker (mac OS X and windows only), and fig are required if you haven't installed them this will fail"
echo "trying to build the web server container, this might take awhile...."
docker build --rm -t webserver .
echo "changing to the games_server dir and building the game server, this might take awhile..."
cd game_server
docker build --rm -t game_server .
echo "all done going back to repo root dir, and running start.sh"
cd ..
chmod +x start.sh
./start.sh
