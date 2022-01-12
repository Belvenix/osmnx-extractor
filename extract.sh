#!/bin/bash

echo "Usage ./extract.sh -d csv_file -i <year interval for updating osm> -b <begin year> -e <end year>"
while getopts d:i:b:e: flag
do
    case "${flag}" in
        d) csv_file=${OPTARG};;
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

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while IFS="," read -r continet country city
do
	echo "Scrapping ${continet} ${country} ${city}"
	if [ ! -f ./osh_files/${continet}_${country}.osh.pbf ]
	then
        	curl -b $(cat output_cookie.txt | cut -d ';' -f 1) https://osm-internal.download.geofabrik.de/${continet}/${country}-internal.osh.pbf --output ./osh_files/${continet}_${country}.osh.pbf
	else
        	echo "Reausing file ./osh_files/${continet}_${country}.osh.pbf"
	fi

	if [ -s ./osh_files/${continet}_${country}.osh.pbf ]
	then
        	echo "Converting osh to osm"
        	for ((year = $begin ; year <= $end ; year = year + ${interval} ))
        	do
                	echo "Creating osm for timestamp ${year}-01-01T00:00:00Z"
                	osmium time-filter -o ./osm_files/${continet}_${country}_${year}_01_01.osm.pbf ./osh_files/${continet}_${country}.osh.pbf ${year}-01-01T00:00:00Z
                	osmconvert ./osm_files/${continet}_${country}_${year}_01_01.osm.pbf -o=./osm_files/${continet}_${country}_${year}_01_01.osm
                	bzip2 -k ./osm_files/${continet}_${country}_${year}_01_01.osm

                	echo "Starting docker-compose"
                	export OSMNX_DOCKER_FILENAME=${continet}_${country}_${year}_01_01
                	docker-compose up -d
                	sleep 60

                	echo "Running grafml extractor"
                	python3 ./save_graph.py --city ${city} --output ${continet}_${country}_${city}_${year}

                	#echo "Tests"
                	#curl http://localhost:8080/search.php?q=Monte%20Carlo
                	#curl -g 'http://localhost:12345/api/interpreter?data=[out:json];area[name="Monte Carlo"];out;'

                	echo "Cleaning"
                	docker-compose down
                	rm -rf ./osm_files/* ./overpass_db/*
        	done

        	echo "Done"
	else
        	echo "Could not download file maybe your cookies are wrong or your connection is bad"
	fi

done < ${csv_file}
rm -rf ./osh_files/*
