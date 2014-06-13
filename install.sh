echo "Docker, boot2docker (mac OS X and windows only), and fig are required if you haven't installed them this will fail"
echo "trying to build the web server container, this might take awhile...."
fig up -d db
fig build web
fig stop db
echo "changing to the games_server dir and building the game server, this might take awhile..."
fig build gameserver
echo "running start.sh"
chmod +x start.sh
./start.sh
