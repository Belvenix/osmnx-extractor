# osmnx-extractor

## Check services

### Overpass

Based on monaco test data - enter in browser

http://localhost:12345/api/interpreter?data=node(642295507);%20out%20geom;

### Nominatim

Based on monaco test data - enter in browser

http://localhost:8080/search.php?q=Monte%20carlo


Usage
./extract.sh -C "europe" -c "monaco" -i 1 -b 2009 -e 2021


## Windows usage:
### Building image:

`docker build -t magisterka .`

### Running downloader and timestamp extractor
`docker run -v ${project_directory}/extracted:/my_data/ magisterka`

### Changing default city and other parameters
`docker run -v ${project_directory}/extracted:/my_data/ magisterka /bin/bash ./extract.sh -C europe -c malta -i 1 -b 2015 -e 2021`