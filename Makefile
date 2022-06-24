all: image
image:
	docker build -t autechgemz/named -f Dockerfile .
full:
	docker build --no-cache -t autechgemz/named -f Dockerfile .
push:
	docker push autechgemz/named
clean:
	docker rm -v named
distclean:
	docker rmi `docker images -f dangling=true -q` > /dev/null
	docker rmi autechgemz/named
