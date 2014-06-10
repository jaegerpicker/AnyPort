FROM ubuntu:14.04
MAINTAINER Shawn Campbell <jaegerpicker@gmail.com>
# Mercurial
RUN echo 'deb http://ppa.launchpad.net/mercurial-ppa/releases/ubuntu precise main' > /etc/apt/sources.list.d/mercurial.list
RUN echo 'deb-src http://ppa.launchpad.net/mercurial-ppa/releases/ubuntu precise main' >> /etc/apt/sources.list.d/mercurial.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 323293EE
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list
RUN apt-get -qq update
RUN apt-get -qqy install python ruby ruby-dev python-dev python-software-properties software-properties-common postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 mongodb-org node python-distribute python-pip curl git bzr mercurial memcached nginx openssh-server
#setup postgres server
USER postgres
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker
RUN /etc/init.d/postgresql start && psql --command "CREATE USER codeart WITH SUPERUSER PASSWORD 'code_art';" && createdb -O codeart rpg
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
EXPOSE 5432
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]
#back to root w00t!
USER root

#MongoDB setup
RUN mkdir -p /data/db
EXPOSE 27017
CMD ["mongod"]

#memcached setup
EXPOSE 11211
CMD ["memcached", "-m", "64"]

#nginx setup
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN mkdir /etc/nginx/ssl
ADD default /etc/nginx/sites-available/default
ADD default-ssl /etc/nginx/sites-available/default-ssl

EXPOSE 80

CMD ["nginx"]

#applications setup
RUN mkdir -p /app/api
RUN mkdir -p /app/html
RUN mkdir -p /app/serverSide
RUN mkdir -p /app/controlPanel
RUN mkdir -p /root/.ssh
ADD ./gitKey /root/.ssh/id_rsa
ADD ./gitKey.pub /root/.ssh/id_rsa.pub
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN ssh -v git@bitbucket.org
RUN git clone git@bitbucket.org:teamawesomemcpants/api-repo.git /app/api
RUN git clone git@bitbucket.org:teamawesomemcpants/html-client.git /app/html
RUN git clone git@bitbucket.org:teamawesomemcpants/game-server.git /app/serverSide
RUN apt-get -qqy install npm
RUN npm install --silent -g bower
WORKDIR /app/html
#RUN npm install
#### TODO: bower isn't working not sure why need to fix
#RUN bower --config.interactive=false -V --allow-root install
WORKDIR /app/api
RUN apt-get -qqy install libpq-dev
RUN pip install -r /app/api/requirements.txt
RUN pip install uwsgi
RUN /etc/init.d/postgresql start && /app/api/rpgthing/manage.py syncdb --noinput
RUN /etc/init.d/postgresql start && /app/api/rpgthing/manage.py migrate --noinput
CMD ["python", "/app/api/rpgthing/manage.py", "runserver"]
EXPOSE 8000
#Setup golang
RUN curl -s https://go.googlecode.com/files/go1.2.linux-amd64.tar.gz | tar -v -C /usr/local/ -xz
ENV PATH  /usr/local/go/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV GOPATH  /go
ENV GOROOT  /usr/local/go
ADD webapp /app/controlPanel
WORKDIR /app/serverSide
RUN go get
RUN go build
CMD ["./RPGThingServerSide", "--addr", ":8080"]
EXPOSE 8080
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' |chpasswd

EXPOSE 22
CMD    ["/usr/sbin/sshd", "-D"]
