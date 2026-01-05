Name:           rabbitmq-server-on
Summary:        Enables the RabbitMQ server
Version:        0.10
Release:        1%{?dist}
License:        MIT
Group:          System Environment/Daemons
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       rabbitmq-server
Requires:       systemd
Requires:       firewalld
#Requires:       policycoreutils
#Requires:       policycoreutils-python

%description 
rabbitmq-server-on enables the RabbitMQ server and enables plugins for STOMP and the Management API

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT

%files
%defattr(0644,root,root,-)

%post
echo "rabbitmq-server: enable"
systemctl enable rabbitmq-server

echo "rabbitmq_stomp: enable"
/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_stomp

echo "rabbitmq_management: enable"
/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management

echo "firewall-cmd: add-port 61613"
firewall-cmd --permanent --add-port=61613/tcp
semanage port -a -t rabbitmq_port_t -p tcp 61613

echo "firewall-cmd: add-port 15672"
/usr/bin/firewall-cmd --permanent --add-port=15672/tcp

echo "firewall-cmd: reload"
/usr/bin/firewall-cmd --reload

echo "rabbitmq-server: start"
systemctl start rabbitmq-server

echo "RabbitMQ Control: Enable features"
/usr/sbin/rabbitmqctl enable_feature_flag all

true

%clean
rm -rf $RPM_BUILD_ROOT

%changelog
