start:
	# Creating directory for dependencies which will be used by container in the GitHub Actions workflow
	rm -rf /home/runner/actions-runner/externals \
	&& mkdir -p /home/runner/actions-runner/externals \
	&& chmod 777 -R /home/runner/actions-runner/externals

	# Creating directory for repo source files which will be used by container in the GitHub Actions workflow
	rm -rf /home/runner/actions-runner/_work \
	&& mkdir -p /home/runner/actions-runner/_work \
	&& chmod 777 -R /home/runner/actions-runner/_work

	docker compose build

	docker create --name runner-copy self-hosted-runner-runner:latest

	# Copying dependencies from temp runner container copy
	# It`s needed to copy dependencies before starting the main runner container, otherwise dependencies directory will be empty
	docker cp runner-copy:/home/runner/actions-runner/externals/. /home/runner/actions-runner/externals/

	docker rm runner-copy

	docker compose up -d --force-recreate