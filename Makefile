start:
	rm -rf /home/runner/actions-runner/externals \
	&& mkdir -p /home/runner/actions-runner/externals \
	&& chmod 777 -R /home/runner/actions-runner/externals

	rm -rf /home/runner/actions-runner/_work \
	&& mkdir -p /home/runner/actions-runner/_work \
	&& chmod 777 -R /home/runner/actions-runner/_work

	docker compose build

	docker create --name runner-copy self-hosted-runner-runner:latest

	docker cp runner-copy:/home/runner/actions-runner/externals/. /home/runner/actions-runner/externals/

	docker rm runner-copy

	docker compose up -d --force-recreate