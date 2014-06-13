FROM orchardup/python:2.7
ENV PYTHONUNBUFFERED 1
RUN apt-get update -qq && apt-get install -y python-pip python-virtualenv python-psycopg2 postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 nodejs npm git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libgdbm-dev libncurses5-dev automake libtool bison libffi-dev libpq-dev
RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1.2"
RUN /bin/bash -l -c "rvm use 2.1.2 --default"
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
RUN echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
RUN /bin/bash -l -c "gem install rails --no-ri --no-rdoc"
RUN npm install --silent -g bower
RUN mkdir /code
WORKDIR /code
RUN mkdir -p /code/api
RUN mkdir -p /code/html
RUN mkdir -p /root/.ssh
ADD ./gitKey /root/.ssh/id_rsa
ADD ./gitKey.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa.pub
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN git clone git@bitbucket.org:teamawesomemcpants/api-repo.git /code/api
RUN git clone git@bitbucket.org:teamawesomemcpants/html-client.git /code/RPGThingWebClient
WORKDIR /code/RPGThingWebClient
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN which bower
RUN bower install --config.interactive=false -V --allow-root
WORKDIR /code/api
RUN /bin/bash -c "[ -e /code/api/rpgthing/settings/currentenv.py ] && rm /code/api/rpgthing/settings/currentenv.py || echo 'files does not exist';"
RUN ln -s /code/api/rpgthing/settings/smc.py /code/api/rpgthing/settings/currentenv.py
run git pull
RUN pip install -r requirements.txt
ENV PYTHONPATH $PYTHONPATH:/code/api:/code/api/rpgthing
RUN echo $PYTHONPATH
ENV DJANGO_SETTINGS_MODULE settings.currentenv
RUN /code/api/rpgthing/manage.py syncdb --noinput && /code/api/rpgthing/manage.py migrate player --noinput &&\
/code/api/rpgthing/manage.py migrate world --noinput && /code/api/rpgthing/manage.py migrate game --noinput && /code/api/rpgthing/manage.py migrate game --noinput && /code/api/rpgthing/manage.py migrate character --noinput && /code/api/rpgthing/manage.py migrate cortex --noinput
