# self-hosted-runner

## Getting started
1. Clone repository to your server
```bash
git clone https://github.com/TourmalineCore/self-hosted-runner --depth 1
```
2. Copy `inner-circle-prod-ssh`(without .pub) file that was created in [inner-circle-cloud](https://github.com/TourmalineCore/inner-circle-cloud) repo folder to the 'Docker Image' folder and rename it to `ssh-key`.
3. Copy `.inner-circle-cluster-external-kubeconfig` file that was created in [inner-circle-env](https://github.com/TourmalineCore/inner-circle-env) repo folder at the VM to the `Docker Image` folder and rename it to `kubeconfig`
3. Create a copy of `.env.example`, name it `.env` and write your variables like in the given example
```
REPO=TourmalineCore
REG_TOKEN=ATLGSKZGN2EN1SDTH11RUN5GOATX5
NAME=black-server-ubuntu-24.04-x64-01-runner
CLOUD_IP=192.54.219.45
CLOUD_USER=ubuntu
CLUSTER_PORT=6443
```
4. Add docker group identifier to .env
```bash
echo DOCKER_GID=$(stat -c '%g' /var/run/docker.sock) >> .env
```
5. Configure count of runner replicas and resources in `docker-compose.yml`

6. Start runners by executing the following command:
```bash
docker compose up --detach --build
```

