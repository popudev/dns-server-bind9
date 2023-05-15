docker network create \
--driver macvlan \
--subnet 192.168.1.0/24 \
--gateway 192.168.1.1 \
--ip-range 192.168.1.80/28 \
--aux-address 'host=192.168.1.80' \
--opt parent=eth0 \
dns_net

docker stop ns1 && docker rm ns1

docker run --detach \
--network dns_net \
--ip 192.168.1.41 \
--name ns1 \
--env TZ=UTC \
--env BIND9_USER=root \
--volume /root/dns/config:/etc/bind \
--volume /root/dns/certificate:/etc/bind/ssl \
--restart=always \
ubuntu/bind9

globalchain@2023

Tạo CA certificate:
openssl genrsa -out ca.key 2048
openssl req -x509 -sha256 -new -nodes -days 3650 -key ca.key -out ca.crt

Tạo SSL Certificate Signing Request:
openssl genrsa -out localhost.key 2048
openssl req -new -key localhost.key -out localhost.csr

Nội dung file localhost.ext:
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
subjectAltName = @alt_names
[alt_names]
DNS.1 = portal.catp.globalchain.local

Ký SSL certificate:
openssl x509 -req -in localhost.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 365 -sha256 -extfile localhost.ext -out localhost.crt
