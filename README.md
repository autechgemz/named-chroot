# named-chroot Docker Container

## Overview

The `named-chroot` container provides a secure environment for running the BIND DNS server (`named`) within a chroot jail. This setup enhances security by restricting the DNS server's access to the filesystem, reducing potential attack surfaces.

## Features

- Runs `named` in a chroot environment for improved security
- Configurable via environment variables and mounted volumes
- Supports master and slave DNS configurations
- Can also function as a caching DNS server
- Lightweight and efficient container
- Uses Docker's logging mechanism

## Getting Started

### Prerequisites

- Docker installed on your system
- Basic knowledge of DNS server configurations

### Pulling the Image

```sh
docker pull autechgemz/named-chroot
```

### Running the Container

To start a caching DNS server instance of `named-chroot`:

```sh
docker run -d --name named -p 53:53/tcp -p 53:53/udp autechgemz/named-chroot
```

If you want to use your own configuration, start the container as follows:

```sh
docker run -d --name named \
  -p 53:53/tcp -p 53:53/udp \
  -v $(pwd)/named.conf:/etc/named.conf:ro \
  -v $(pwd)/zones:/var/named:rw \
  autechgemz/named-chroot
```

### Configuration

Mount your BIND configuration files into the container:
- **`/etc/named.conf`**: Main BIND configuration file (read-only recommended)
- **`/var/named`**: Directory containing DNS zone files
- **`/etc/named`**: Additional configuration files such as keys and ACLs

#### Example Configuration (`named.conf`)

```conf
options {
    directory "/var/named";
    allow-query { any; };
    recursion yes;
    forwarders { 8.8.8.8; 8.8.4.4; };
};

zone "example.com" {
    type master;
    file "example.com.zone";
};
```

## Logs and Debugging

To check logs:

```sh
docker logs -f named
```

To open an interactive shell inside the container:

```sh
docker exec -it named /bin/sh
```

## Stopping and Removing the Container

```sh
docker stop named && docker rm named
```

## License

This project is licensed under the MIT License.

## Contributing

Pull requests are welcome. Please ensure your contributions follow the project's coding style and guidelines.

## Issues and Support

If you encounter any issues, please open an issue on GitHub:
[https://github.com/autechgemz/named-chroot/issues](https://github.com/autechgemz/named-chroot/issues)

## Author

Maintained by [autechGemz](https://github.com/autechgemz).

