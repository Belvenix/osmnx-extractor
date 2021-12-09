FROM python:3.9-slim-buster

RUN apt-get update \
	&& apt-get install \ 
		--no-install-recommends \
		-y \ 
		curl=7.64.0-4+deb10u2 \ 
		osmctools=0.9-2 \
	&& apt install \
		--no-install-recommends \
		 -y \
		 osmium-tool=1.10.0-1 \
		bzip2 \
	&& pip3 install --no-cache-dir osmnx==1.1.2 \ 
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/osmnx_graph/changes \
	&& mkdir -p /opt/osmnx_graph/osh_files \
	&& mkdir -p /opt/osmnx_graph/osm_files \
	&& mkdir -p /opt/osmnx_graph/osh_polies \
	&& mkdir -p /opt/osmnx_graph/template_diff \
	&& mkdir -p /opt/osmnx_graph/graphml_files \ 
	&& mkdir -p /opt/osmnx_graph/overpass_db
WORKDIR /opt/osmnx_graph

COPY . .

RUN apt-get update && apt-get install dos2unix

RUN dos2unix ./extract.sh

CMD ["/bin/bash", "./extract.sh", "-C", "europe", "-c", "monaco", "-i", "1", "-b", "2009", "-e", "2021"]
