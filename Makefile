all: pre image config

pre:
	packer plugins install github.com/hashicorp/docker

image:
	packer init baseimage.pkr.hcl
	packer build baseimage.pkr.hcl

config:
	packer init container.pkr.hcl
	packer build container.pkr.hcl

push:
	docker push autechgemz/named

clean:
	docker-compose down
	docker rm -v named

distclean:
	docker-compose down -v
	docker rmi autechgemz/named-baseimage
	docker rmi autechgemz/named

