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
		bzip2=1.0.8-2 \
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

COPY ./monaco-latest.osm.pbf ./osm_files/current_file.osm.pbf
COPY ./save_graph.py .
COPY ./extract.sh .

CMD ["/bin/bash", "./extrac.sh", "-C", "europa", "-c", "france", "-p", "Paris", "-i", "day", "-t", "2020-08-01T00:00:00Z"]
