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
while IFS="," read -r continet country sub city
do
	if [ -f ./output_cookie.txt ];then
		rm ./output_cookie.txt
	fi

	echo "Scrapping ${continet} ${country} ${sub} ${city}"
	if [ ! -f ./osh_files/${continet}_${country}.osh.pbf ];then
		echo "Updating cookies file"
        	python3 ./oauth_cookie_client.py -o output_cookie.txt -s settings.json
		
		if [ "$sub" = "_" ];then
			curl -b $(cat output_cookie.txt | cut -d ';' -f 1) https://osm-internal.download.geofabrik.de/${continet}/${country}-internal.osh.pbf --output ./osh_files/${continet}_${country}.osh.pbf
		else
			echo "Using sub region https://osm-internal.download.geofabrik.de/${continet}/${country}/${sub}-internal.osh.pbf"
			curl -b $(cat output_cookie.txt | cut -d ';' -f 1) https://osm-internal.download.geofabrik.de/${continet}/${country}/${sub}-internal.osh.pbf --output ./osh_files/${continet}_${country}.osh.pbf
		fi
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
			
			attempt=0
			wait_time=10
			finished=0
			while [[ $attempt -le 6 && $finished -eq 0 ]];do
                		echo "Starting docker-compose for ${attempt}/6"
              			export OSMNX_DOCKER_FILENAME=${continet}_${country}_${year}_01_01
                		docker-compose up -d
				current_time=0
				while [[ $current_time -le $wait_time && $finished -eq 0 ]];do
					if [[ $(curl -s http://localhost:8080/search.php?q=${city} | wc -c) -gt 5 && $(curl -s -g 'http://localhost:12345/api/interpreter?data=[out:json];area[name="${city}"];out;' | wc -c) -gt 350 ]];then 
						finished=1
					fi
                			sleep 5m
					current_time=$(( $current_time + 5 ))
				done
				wait_time=$(($wait_time * 2 ))
				attempt=$(($attempt + 1))
				if [[ $finished -eq 0 ]];then
					docker-compose down
					rm -rf ./overpass_db/*
				fi
			done

			if [[ $finished -eq 1 ]];then
           			echo "Running grafml extractor"
                		python3 ./save_graph.py --city ${city} --output ${continet}_${country}_${city}_${year}
				docker-compose down
				rm -rf ./overpass_db/*
			else
				echo "Could not download ${continet}_${country}_${city}_${year} graph"
			fi

                	echo "Cleaning"
                	rm -rf ./cache #./osm_files/*
        	done

        	echo "Done"
	else
        	echo "Could not download file maybe your cookies are wrong or your connection is bad"
	fi
	rm -rf ./osh_files/*
	exit

done < ${csv_file}
echo "Cleaining graph process started"
python3 clean_graph.py
