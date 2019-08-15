PREFIX = digitalroute
IMAGE = inlets-helper
TAG = 0.0.4

build:
	docker build --pull -t $(PREFIX)/$(IMAGE):$(TAG) $(DOCKER_ARGS) .

push: build
	docker tag $(PREFIX)/$(IMAGE):$(TAG) $(PREFIX)/$(IMAGE):latest
	docker push $(PREFIX)/$(IMAGE):$(TAG)
	docker push $(PREFIX)/$(IMAGE):latest
