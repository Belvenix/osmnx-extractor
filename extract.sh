#!/bin/bash

echo "Usage ./extract.sh -C <continent> -c <country> -p <city> -i <interval for updating osm> -t <timestamp>"
while getopts C:c:p:i:t: flag
do
    case "${flag}" in
	C) continet=${OPTARG};;
        c) city=${OPTARG};;
        p) place=${OPTARG};;
	i) timesr=${OPTARG};;
	t) timestampe=${OPTARG};;
    esac
done

echo "Parameters continent=${continet} country=${city} city=${place} interval=${timesr} timestamp=${timestampe}"
if [ ! -f ./osh_files/${continet}_${city}-complete.osh.pbf ]
then
	if [ ! -f ./osh_files/${continet}_${city}.osh.pbf ]
	then
		curl -b 'gf_download_oauth="login|2018-04-12|wPJcv7mDmOjzS0gGNYthWEbaNckSPUTK7-Ll8GLwdmkvW-uMsa6_msfS0lYU4Erg69HAYBg7FovYfVf0n9qBBAZCnrhGtQ9aXfY7joTVrqFxaJRKIm-DKDhwbR7zd7H6tDAAagS-bTkidIsSWoK2ydKQ8m8FaDyemfvxWdJgQDGnaWVOjJQcdxK7nkEtVWE0evHg9ORDjSwNG1HM1o6XjccPcOlypVQ1J_sHC8mcVRiNSbzViuv-VAZcYFtoZNXZJuWjU2o4WIGN1oWbiQ=="' https://osm-internal.download.geofabrik.de/${continet}/${city}-internal.osh.pbf --output ./osh_files/${continet}_${city}.osh.pbf

		curl -b 'gf_download_oauth="login|2018-04-12|wPJcv7mDmOjzS0gGNYthWEbaNckSPUTK7-Ll8GLwdmkvW-uMsa6_msfS0lYU4Erg69HAYBg7FovYfVf0n9qBBAZCnrhGtQ9aXfY7joTVrqFxaJRKIm-DKDhwbR7zd7H6tDAAagS-bTkidIsSWoK2ydKQ8m8FaDyemfvxWdJgQDGnaWVOjJQcdxK7nkEtVWE0evHg9ORDjSwNG1HM1o6XjccPcOlypVQ1J_sHC8mcVRiNSbzViuv-VAZcYFtoZNXZJuWjU2o4WIGN1oWbiQ=="' https://osm-internal.download.geofabrik.de/${continet}/${city}.poly --output ./osh_polies/${continet}_${city}.poly
	else
		echo "Reausing file ./osh_files/${continet}_${city}.osh.pbf"
	fi

	echo "Updating osm with ${timesr} timestamp"
	osmupdate --keep-tempfiles --${timesr} -t=./template_diff/${continet}_${city} ./osh_files/${continet}_${city}.osh.pbf ./changes/${continet}_${city}.osc.gz
	osmium extract -p ./osh_polies/${continet}_${city}.poly -s simple ./changes/${continet}_${city}.osc.gz -O -o ./changes/${continet}_${city}.local.osc.gz
	osmium apply-changes -H ./osh_files/${continet}_${city}.osh.pbf ./changes/${continet}_${city}.local.osc.gz -O -o ./osh_files/${continet}_${city}-complete.osh.pbf
else
	echo "Reusing complete ./osh_files/${continet}_${city}-complete.osh.pbf"
fi

echo "Converting osh to osm"
osmium time-filter -o ./osm_files/${continet}_${city}_${timestampe}.osm.pbf ./osh_files/${continet}_${city}-complete.osh.pbf ${timestampe}
osmconvert ./osm_files/${continet}_${city}_${timestampe}.osm.pbf -B=./osh_polies/${continet}_${city}.poly -o=./osm_files/${continet}_${city}_${timestampe}.osm
bzip2 -k ./osm_files/${continet}_${city}_${timestampe}.osm

#echo "Runing grafml extractor"
#python3 ./save_graph.py --city ${place}  --output ./graphml_files/${continet}_${city}_${place}_${timestampe}

echo "Cleaning"
rm -rf ./changes/* ./template_diff/* ./osm_files/* ./osmupdate_temp ./cache ./overpass_db/* ./osh_files/${continet}_${city}.osh.pbf 

echo "Done"
