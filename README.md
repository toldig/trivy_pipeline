### Trivy pipeline with custom image

Used debian parent image  
```
docker pull debian:latest
```

Create **app** directory, enter it, put everything here  
We will need to install these in the container:  
- custom scripts  
- download [trivy](https://github.com/aquasecurity/trivy/releases/download/v0.36.0/trivy_0.36.0_Linux-64bit.deb)  
- download [yq](https://launchpad.net/~rmescandon/+archive/ubuntu/yq)
- download [html template](https://github.com/aquasecurity/trivy/blob/main/contrib/html.tpl) for trivy report  
```
mkdir app
cd app
```

Custom scripts are:  
- [scan_dockerfile.sh](scan_dockerfile.sh): builds and scans image using a Dockerfile  
- [scan_dockercompose.sh](scan_dockercompose.sh): builds and scans images using a docker-compose.yml  
Both scripts will create report.zip with the scan results  

Run debian image and map the **app** directory within the container to /app  
```
docker run --privileged -it --rm -v "$(pwd):/app" debian:latest
```

Install trivy  
```
dpkg -i /app/trivy\_0.18.3\_Linux-64bit.deb
```

Install some tools we need  
```
apt update

apt install zip -y
```

Install docker following [this](https://docs.docker.com/engine/install/debian/)

Copy files to the /usr/bin directory  
```
cp /app/scan_dockerfile.sh /usr/bin/
cp /app/scan_dockercompose.sh /usr/bin/
cp /app/yq /usr/bin/
```

Put html temlate in root  
```
cp /app/html.tpl /
```

Do **NOT** close this terminal, open another one, and get the container ID  
```
docker ps
```

Commit the changes to a new image  
```
docker container commit 324d957b3f01 trivycustom:latest
```

Or if you have only one container running  
```
docker container commit $(docker ps -q) trivycustom:latest
```

Tag and push image to your repo  
```
docker image tag trivycustom:latest harbor.xxxxxxxxx.xxx/xxxx/trivycustom:latest
docker image push harbor.xxxxxxxxx.xxx/xxxx/trivycustom:latest
```

