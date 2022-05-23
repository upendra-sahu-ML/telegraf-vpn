FROM golang:1.18 AS build_base

RUN apt update && apt install -y git make gcc-multilib g++-multilib build-essential

WORKDIR /app


ENV GOPROXY=https://proxy.golang.org,direct

COPY telegraf .

RUN ls -l

RUN make build


FROM ubuntu:20.04

RUN apt-get update && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install apt-utils libxml2 kmod libglib2.0-dev ca-certificates libwebkit2gtk-4.0-37 xdotool -y
RUN apt-get install -y iputils-ping httperf net-tools curl vim

COPY --from=build_base /app/telegraf /usr/bin/telegraf

ADD anyconnect /tmp/anyconnect
RUN cd /tmp/anyconnect && echo "y" | sh vpn_install.sh
ADD anyconnect/AC_Client_Profile.xml /opt/cisco/anyconnect/profile/AC_Client_Profile.xml
ADD certs/* /usr/local/share/ca-certificates/
RUN update-ca-certificates
WORKDIR /home/cisco
ADD run.sh /home/cisco/run.sh
RUN chmod +x /home/cisco/run.sh

ENV PATH="/opt/cisco/anyconnect/bin/:$PATH"
#ENTRYPOINT ["sh", "-c", "/etc/init.d/vpnagentd restart"]
CMD /etc/init.d/vpnagentd restart && bash
