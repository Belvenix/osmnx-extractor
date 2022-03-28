# osmnx-extractor
_osmnx-extractor_ is a pipeline for extracting bicycle road graphs from Openstreetmaps for a given year. Pipeline extracts historical data from [geofabick](https://www.geofabrik.de). Pipeline next extracts osm maps from historical data for a given interval of time with a given yearly step. Next program based on osm data converts information to graph and saves it in `graphml_files` directory.

### Usage
We provide a simple bash script `extract.sh` where you provide csv `cities_data.csv` with data beginning year, end year and interval for extracking. For example
```
# ./extract.sh -d <csv file with data> -i <interval> -b <begin year> -e <end year>
sudo ./extract.sh -d cities_data.csv -i 1 -b 2012 -e 2022
```

### Before preparation
Before you run pipeline for extracting data you need to prepare two things:
- Polygon files in polys folder
- `cities_data.csv` with data for geofabrick and polys folder

Our approach is based on geometry polygons of cities we want to extract so we need to have those polygons prepared before we start. In the file `prepare_data_polygon.ipynb` there are instructions on how to do it.

One of parameters our pipeline needs is `cities_data.csv` csv file with data for geofabrick and polygon. We extract country/regions maps from where we extract cities. We try to get the smallest region that geofabrick gives us to extract our cities data. So in our request we need to provide: continent, country and subregion for given city. Remember geofabick not always provide regions and also names must be exact that geofabrick uses becouse we use their API to communicate. Last column is the name of the city we are creating graph and it should be the same as the name of it polygon so `cities_data.csv` looks like this:

| Continent | Country     | Subregion | City   |
|-----------|-------------|-----------|--------|
| europe    | germany     | berlin    | Berlin |
| europe    | switzerland | _         | Bern   |

We already provided some polys and data for `cities_data.csv` but feel free to add your own data

### File structure
- `extract.sh`: pipeline file
- `clean_graph.py`: file for cleaning redundant graphs where there is no temporar changes within one city
- `save_graph.py`: file for creating graphs from nominatim and overpass
- `oauth_cookie_client.py`: creates a cookie file based on `settings.json` where your credentials are stored to geofabrick(more precisely to OpenStreetMaps), you need to have an account there.
- `cities_data.csv`: file with city data for pipeline
- `prepare_data_polygon.ipynb`: file for prepering polygons for pipeline
- `show_dif.ipynb`: file for exploring and visualization of extracted graphs
- `graphml_files`: directory with extracted graphs
- `osm_files`: directory with osm files


### Visualization with Opensteetmaps
We can also inspect our osm data with [Opensteetmaps](https://github.com/openstreetmap/openstreetmap-website/blob/master/DOCKER.md).

The first step is to fork/clone the repo to your local machine:

    git clone https://github.com/openstreetmap/openstreetmap-website.git

Now change working directory to the `openstreetmap-website`:

    cd openstreetmap-website

## Initial Setup

### Storage

    cp config/example.storage.yml config/storage.yml

### Database

    cp config/docker.database.yml config/database.yml

## Prepare local settings file

    touch config/settings.local.yml

## Installation

To build local Docker images run from the root directory of the repository:

    docker-compose build

If this is your first time running or you have removed cache this will take some time to complete. Once the Docker images have finished building you can launch the images as containers.

To launch the app run:

    docker-compose up -d

This will launch one Docker container for each 'service' specified in `docker-compose.yml` and run them in the background. There are two options for inspecting the logs of these running containers:

### Migrations

Run the Rails database migrations:

    docker-compose run --rm web bundle exec rake db:migrate

### Tests

Run the test suite by running:

    docker-compose run --rm web bundle exec rails test:all

### Loading an OSM extract

You need to copy your EXAMPLE.osm.pbf file in the directory for the visualization process. You can now use Docker to load this extract into your local Docker-based OSM instance:

    docker-compose run --rm web osmosis \
        -verbose    \
        --read-pbf EXAMPLE.osm.pbf \
        --log-progress \
        --write-apidb \
            host="db" \
            database="openstreetmap" \
            user="openstreetmap" \
            validateSchemaVersion="no"

Once you have data loaded you should be able to navigate to [`http://localhost:3000`](http://localhost:3000) to begin working with your local instance.

### Changing OSM file
There is no convenient way to change to another osm file to do this you need to 
    
    docker-compose down

And next remove all volumes

    docker volume rm openstreetmap-website_web-traces openstreetmap-website_web-images openstreetmap-website_db-data

Now you can start again from Installation section
