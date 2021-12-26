all: image
image:
	docker build -t autechgemz/named -f Dockerfile .
full:
	docker build --no-cache -t autechgemz/named -f Dockerfile .
push:
	docker push autechgemz/named
clean:
	docker-compose down
	docker rm -v named
distclean:
	docker-compose down -v
	docker rmi autechgemz/named-baseimage
	docker rmi autechgemz/named
