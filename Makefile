BIND_VERSION := 9.20.1

IMAGE_TAG    := latest
REGISTRY     := autechgemz
IMAGE_ID     := named

all: image
image:
	docker build --build-arg NAMED_VERSION=$(BIND_VERSION) -t $(REGISTRY)/$(IMAGE_ID) -f Dockerfile .
full:
	docker build --build-arg NAMED_VERSION=$(BIND_VERSION) -t $(REGISTRY)/$(IMAGE_ID) --no-cache -f Dockerfile .
push:
	docker push $(REGISTRY)/$(IMAGE_ID)
clean:
	docker rm -v $(IMAGE_ID)
distclean:
	docker rmi `docker images -f dangling=true -q` > /dev/null
	docker rmi $(REGISTRY)/$(IMAGE_ID)
