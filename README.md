# NAME

rabbitmq-server-on - RPM which enables the RabbitMQ server and enables plugins for STOMP and the Management API

# BUILD

```
make rpm
```

# EXAMPLES

```
perl examples/perl-Net-RabbitMQ-Management-API-example.pl [host]
perl examples/perl-Net-STOMP-Client-subscribe.pl [host]
perl examples/perl-Net-STOMP-Client-producer.pl [host]
```

# COPYRIGHT AND LICENSE

MIT LICENSE

Copyright (C) 2022 by Michael R. Davis

# Install

For EL9 Rabbitmq RPM is available from https://www.rabbitmq.com/docs/install-rpm

```
vi /etc/yum.repos.d/rabbitmq.repo
```

then paste

```
[rabbitmq-el9-noarch]
name=rabbitmq-el9-noarch
baseurl=https://yum2.rabbitmq.com/rabbitmq/el/9/noarch
        https://yum1.rabbitmq.com/rabbitmq/el/9/noarch
repo_gpgcheck=1
enabled=0
# Cloudsmith's repository key and RabbitMQ package signing key
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key
       https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
autorefresh=1
type=rpm-md
```

Then

```
sudo yum install rabbitmq-server-on-{version}.rpm --enablerepo=rabbitmq-el9-noarch
```
