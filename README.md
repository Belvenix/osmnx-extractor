# osmnx-extractor

## Check services

### Overpass

Based on monaco test data - enter in browser

http://localhost:12345/api/interpreter?data=node(642295507);%20out%20geom;

### Nominatim

Based on monaco test data - enter in browser

http://localhost:8080/search.php?q=Monte%20carlo


Usage
./extract_with_docker.sh -C "europe" -c "monaco" -p "Monte carlo" -i "day" -t "2020-08-01T00:00:00Z"
