all: image config
image:
	packer build baseimage.json
config:
	packer build container.json
