# Django, uWSGI and Nginx in a container

This Dockerfile allows you to build a Docker container with a fairly standard
and speedy setup for Django with uWSGI and Nginx.

uWSGI from a number of benchmarks has shown to be the fastest server 
for python applications and allows lots of flexibility.

Nginx has become the standard for serving up web applications and has the 
additional benefit that it can talk to uWSGI using the uWSGI protocol, further
elinimating overhead. 

This repo is largely based on https://github.com/baxeico/django-uwsgi-nginx, I made some modifications to have it run https://github.com/mumoj/Monitoring-a-Django-Multiprocessed-App out of the box


Feel free to clone this and modify it to your liking. And feel free to 
contribute patches.

### Build and run
* docker build -t webapp .
* docker run -d -p 80:80 webapp

### Test

`curl localhost`


