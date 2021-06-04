#!/bin/bash
base_image="bldrtech/filewcount:latest"
echo "Checking for docker"
DOCKER_BIN=$(which docker)
if [ -x "$DOCKER_BIN" ]; then echo "WE HAVE DOCKER!"
else
echo "Trying to yum install docker"
sudo yum install -y docker
fi
sudo systemctl enable docker
sudo systemctl start docker
if [ $? -eq 0 ];then echo "Docker is ready"; fi
echo "Start service default latest on default port 80"
sudo docker run -d -p 8080:80 ${base_image}
