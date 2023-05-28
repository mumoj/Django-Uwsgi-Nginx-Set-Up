# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:bionic

MAINTAINER mumoj

ARG DEBIAN_FRONTEND=noninteractive

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted" | tee -a /etc/apt/sources.list.d/bionic-updates.list

RUN apt-get update

# Extra dependancies
RUN apt-get update && apt-get install -y --no-install-recommends \
		apt-utils \
	&& rm -rf /var/lib/apt/lists/


# install required packages
RUN apt-get update &&  apt-get install -y python3.8 python3.8-dev python3-setuptools software-properties-common
RUN apt-get install -y sqlite3
RUN apt-get install -y supervisor

# ADD nginx stable ppa
RUN add-apt-repository -y ppa:nginx/stable
# update packages after adding nginx repository
RUN apt-get update
# install latest stable nginx
RUN apt-get install -y nginx

# install pip
RUN apt-get install -y python3-pip
# update packages

# install uwsgi now because it takes a little while
RUN pip3 install uwsgi

RUN apt-get install -y curl

# create the user direory and copy the source code their home directory
RUN addgroup exporter && \
		adduser exporter --ingroup exporter --home /home/exporter \
		--gecos '' --disabled-password

ADD ./   /home/exporter/

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /home/exporter/infra-configs/nginx-app.conf /etc/nginx/sites-enabled/
RUN ln -s /home/exporter/infra-configs/supervisor-app.conf /etc/supervisor/conf.d/

# RUN pip install
RUN pip3 install -r /home/exporter/requirements.txt

# Define app user and run Django app
ENV APP_HOME=/home/exporter

#Define the Prometheus Directory and the Enviroment Variable
RUN mkdir -p /tmp/PROMETHEUS_METRICS

RUN chown -R exporter:exporter $APP_HOME

WORKDIR $APP_HOME


ENV PYTHONUNBUFFERED 1

RUN python3 manage.py makemigrations && python3 manage.py migrate

#Populate metrics
RUN python3 populate_db.py

#Expose port
EXPOSE 80

CMD ["supervisord", "-n"]
