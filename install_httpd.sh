#!/bin/bash

sudo su
sudo apt-get update
sudo apt-get install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo "<html><body><h1>WEB TIER </h1></body></html>" > /var/www/html/index.html