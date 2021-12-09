#!/bin/bash

echo "Usage ./extract.sh -C <continent> -c <country> -i <year interval for updating osm> -b <begin year> -e <end year>"
while getopts C:c:i:b:e: flag
do
    case "${flag}" in
	C) continet=${OPTARG};;
        c) country=${OPTARG};;
	i) interval=${OPTARG};;
	b) begin=${OPTARG};;
	e) end=${OPTARG};;
    esac
done

mkdir -p ./osh_files
mkdir -p ./osm_files
mkdir -p ./overpass_db
mkdir -p ./graphml_files

if [ ! -f ./output_cookie.txt ]
then
	python3 ./oauth_cookie_client.py -o output_cookie.txt -s settings.json
fi

if [ ! -f ./osh_files/${continet}_${country}.osh.pbf ]
then
	echo "Downloading file ${continet}_${country}.osh.pbf"
	curl -b $(cat output_cookie.txt | cut -d ';' -f 1) https://osm-internal.download.geofabrik.de/${continet}/${country}-internal.osh.pbf --output ./osh_files/${continet}_${country}.osh.pbf
else
	echo "Reausing file ./osh_files/${continet}_${country}.osh.pbf"
fi

if [ -s ./osh_files/${continet}_${country}.osh.pbf ]
then
	echo "Converting osh to osm"
	for ((year = $begin ; year <= $end ; year++ ))
	do
		echo "Creating osm for timestamp ${year}-01-01T00:00:00Z"
		osmium time-filter -o ./osm_files/${continet}_${country}_${year}_01_01.osm.pbf ./osh_files/${continet}_${country}.osh.pbf ${year}-01-01T00:00:00Z
		osmconvert ./osm_files/${continet}_${country}_${year}_01_01.osm.pbf -o=./osm_files/${continet}_${country}_${year}_01_01.osm
		bzip2 -k ./osm_files/${continet}_${country}_${year}_01_01.osm

		echo "Copying file ${continet}_${country}_${year}_01_01"
		export OSMNX_DOCKER_FILENAME=${continet}_${country}_${year}_01_01

		cp ./osm_files/${continet}_${country}_${year}_01_01.osm.pbf /my_data/${continet}_${country}_${year}_01_01.osm.pbf
		cp ./osm_files/${continet}_${country}_${year}_01_01.osm.bz2 /my_data/${continet}_${country}_${year}_01_01.osm.bz2
		# docker-compose up -d
		# sleep 30

		# #echo "Running grafml extractor"
		# #python3 ./save_graph.py --city "Monte carlo" --output ./graphml_files/${continet}_${city}_${place}_${year}
	
		# echo "Tests"
		# curl http://localhost:8080/search.php?q=Monte%20Carlo
		# curl -g 'http://localhost:12345/api/interpreter?data=[out:json];area[name="Monte Carlo"];out;'

		# echo "Cleaning"
		# docker-compose down
		# rm -rf ./osm_files/* ./overpass_db/*
	done

	rm -rf ./osh_files/${continet}_${country}.osh.pbf
	echo "Done"
else
	rm -rf ./osh_files/${continet}_${country}.osh.pbf
	echo "Could not download file maybe your cookies are wrong or your connection is bad"
fi
