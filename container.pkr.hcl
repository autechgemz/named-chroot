packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

variable "image_from" {
  type    = string
  default = "autechgemz/named"
}

variable "named_version" {
  type    = string
  default = "9.18.29"
}

variable "named_confdir" {
  type    = string
  default = "/etc/named"
}

variable "named_datadir" {
  type    = string
  default = "/var/named"
}

variable "named_root" {
  type    = string
  default = "/chroot"
}

variable "named_user" {
  type    = string
  default = "named"
}

variable "timezone" {
  type    = string
  default = "Asia/Tokyo"
}

source "docker" "autogenerated_1" {
  image       = var.image_from
  pull        = false
  run_command = ["-dit", "{{ .Image }}", "/bin/ash"]
  export_path = "container.tar"
}

build {
  sources = ["source.docker.autogenerated_1"]

  provisioner "file" {
    source      = "files/"
    destination = "/tmp/ansible-local"
  }

  provisioner "ansible-local" {
    playbook_file = "container.yml"
    staging_directory = "/tmp/ansible-local"
    extra_arguments = [
      "-e timezone=${var.timezone}",
      "-e named_root=${var.named_root}",
      "-e named_user=${var.named_user}",
      "-e named_confdir=${var.named_confdir}",
      "-e named_datadir=${var.named_datadir}",
      "-e named_version=${var.named_version}",
      "-e ansible_python_interpreter=/usr/bin/python3"
    ]
  }

  provisioner "shell" {
    inline = [
      "apk del --no-cache ansible xz"
    ]
  }

  post-processor "docker-import" {
    repository = "autechgemz/named"
    tag        = "latest"
    changes    = [
      "ENV TZ=${var.timezone}",
      "ENV PATH=${var.named_root}/sbin:${var.named_root}/bin:/usr/sbin:/usr/bin:/sbin:/bin",
      "ENV GOPATH=${var.named_root}",
      "VOLUME ${var.named_root}/${var.named_confdir}",
      "VOLUME ${var.named_root}/${var.named_datadir}",
      "EXPOSE 53/tcp 53/udp",
      "ENTRYPOINT [ \"/usr/sbin/runsvdir\", \"-P\", \"/services/\" ]"
    ]
  }
}

