.PHONY: default docker
default::
	pip install -e .
docker:
	docker compose -f docker_compose.yaml run --build mono_gs