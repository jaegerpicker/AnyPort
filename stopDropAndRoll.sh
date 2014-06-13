echo "finding all docker components running and stoping them..."
docker stop $(docker ps -a -q)
echo "kill'em all let the os sort them out"
docker rm $(docker ps -a -q)
echo "removed the docker images, next stop the boot2docker vm"
boot2docker stop
echo "drop the vm"
boot2docker delete
echo "roll out new one"
boot2docker init --hostip=192.168.59.105
echo "stand it up"
boot2docker up
echo "All done :)"
