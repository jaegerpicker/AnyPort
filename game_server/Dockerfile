FROM ubuntu:14.04
MAINTAINER Shawn Campbell <jaegerpicker@gmail.com>
RUN apt-get update -qq && apt-get install -y libpq-dev python python-pip python-virtualenv nodejs npm git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
RUN mkdir -p /code/serverSide
#RUN ln -s $HOME /code/serverSide
RUN mkdir -p /root/.ssh
ADD ./gitKey /root/.ssh/id_rsa
ADD ./gitKey.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa.pub
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN ssh -v git@bitbucket.org
RUN git clone git@bitbucket.org:teamawesomemcpants/game-server.git /code/serverSide/src/game_server
RUN ls -al /code/serverSide && ls -al /code/serverSide/src
RUN curl -s https://go.googlecode.com/files/go1.2.linux-amd64.tar.gz | tar -v -C /usr/local/ -xz
ENV PATH  /usr/local/go/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV GOPATH  /go:/app:/code/serverSide
RUN mkdir -p /go/bin && mkdir -p /go/pkg && mkdir -p /go/src && mkdir -p /code/serverSide/bin && mkdir -p /code/serverSide/pkg
ENV GOROOT  /usr/local/go
#RUN mkdir -p /code/serverSide
WORKDIR /code/serverSide/
RUN /bin/echo $GOPATH
RUN pwd && ls -al && /bin/echo $GOPATH && /bin/echo $GOROOT
RUN go get game_server
RUN go build game_server
RUN cp /code/serverSide/src/game_server/home.html /code/serverSide/home.html
#CMD ["game_server", "--addr", ":8080", "--assets", "/code/serverSide"]
VOLUME ["/code/serverSide"]
