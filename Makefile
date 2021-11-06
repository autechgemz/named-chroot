all: image config
image:
	packer build baseimage.json
config:
	packer build container.json
push:
	docker push autechgemz/named
clean:
	docker-compose down
	docker rm -v named
distclean:
	docker-compose down -v
	docker rmi autechgemz/named-baseimage
	docker rmi autechgemz/named
