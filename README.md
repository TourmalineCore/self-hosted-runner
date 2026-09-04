# self-hosted-runner

## Getting started
1. Clone repository to your server
```bash
git clone https://github.com/TourmalineCore/self-hosted-runner --depth 1
```
2. Copy `inner-circle-prod-ssh`(without .pub) file that was created in [inner-circle-cloud](https://github.com/TourmalineCore/inner-circle-cloud) repo folder to the `DockerImage` folder.
3. Copy `.inner-circle-cluster-external-kubeconfig` file that was created in [inner-circle-env](https://github.com/TourmalineCore/inner-circle-env) repo folder at the VM to the `DockerImage` folder.

```
REPOSITORY_OWNER=TourmalineCore
REG_TOKEN=ATLGSKZGN2EN1SDTH11RUN5GOATX5
INNER_CIRCLE_CLOUD_VM_IP=192.54.219.45
INNER_CIRCLE_CLOUD_VM_USER=ubuntu
INNER_CIRCLE_CLOUD_CLUSTER_PORT=6443
INNER_CIRCLE_CLOUD_VM_PASSWORD=strongpassword
INNER_CIRCLE_CLOUD_PATH_TO_SSH=inner-circle-prod-ssh
INNER_CIRCLE_CLOUD_PATH_TO_KUBECONFIG=.inner-circle-cluster-external-kubeconfig
```
4. Add docker group identifier to .env
```bash
echo DOCKER_GID=$(stat -c '%g' /var/run/docker.sock) >> .env
```

5. Start runners by executing the following command:
```bash
make start
```

