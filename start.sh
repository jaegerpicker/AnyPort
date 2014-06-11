su postgres
/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf 
mongod
memcached -m 64
nginx
python /app/api/rpgthing/manage.py runserver
cd /app/serverSide/ && ./RPGThingServerSide --addr :8080
/usr/sbin/sshd -D
