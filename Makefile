all: image
image:
	docker build -t autechgemz/named .
push:
	docker push autechgemz/named
clean:
	docker-compose down
	docker rm -v named
distclean:
	docker-compose down -v
	docker rmi autechgemz/named
