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

if [ ! -f ./osh_files/${continet}_${country}.osh.pbf ]
then
	python3 geofabrik_cookie/oauth_cookie_client.py -o geofabrik_cookie/output_cookie.txt -s geofabrik_cookie/settings.json
	curl -b ${cat geofabrik_cookie/output_cookie.txt | cut -d ';' -f 1} https://osm-internal.download.geofabrik.de/${continet}/${country}-internal.osh.pbf --output ./osh_files/${continet}_${country}.osh.pbf
	#curl -b 'gf_download_oauth="login|2018-04-12|wPJcv7mDmOjzS0gGNYthWEbaNckSPUTK7-Ll8GLwdmkvW-uMsa6_msfS0lYU4Erg69HAYBg7FovYfVf0n9qBBAZCnrhGtQ9aXfY7joTVrqFxaJRKIm-DKDhwbR7zd7H6tDAAagS-bTkidIsSWoK2ydKQ8m8FaDyemfvxWdJgQDGnaWVOjJQcdxK7nkEtVWE0evHg9ORDjSwNG1HM1o6XjccPcOlypVQ1J_sHC8mcVRiNSbzViuv-VAZcYFtoZNXZJuWjU2o4WIGN1oWbiQ=="' https://osm-internal.download.geofabrik.de/${continet}/${country}-internal.osh.pbf --output ./osh_files/${continet}_${country}.osh.pbf

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

		echo "Starting docker-compose"
		export OSMNX_DOCKER_FILENAME=${continet}_${country}_${year}_01_01
		docker-compose up -d
		sleep 30

		#echo "Running grafml extractor"
		#python3 ./save_graph.py --city "Monte carlo" --output ./graphml_files/${continet}_${city}_${place}_${year}
	
		echo "Tests"
		curl http://localhost:8080/search.php?q=Monte%20Carlo
		curl -g 'http://localhost:12345/api/interpreter?data=[out:json];area[name="Monte Carlo"];out;'

		echo "Cleaning"
		docker-compose down
		rm -rf ./osm_files/* ./overpass_db/*
	done

	rm -rf ./osh_files/${continet}_${country}.osh.pbf
	echo "Done"
else
	rm -rf ./osh_files/${continet}_${country}.osh.pbf
	echo "Could not download file maybe your cookies are wrong or your connection is bad"
fi
