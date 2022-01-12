import os
import argparse
import pickle

import networkx as nx
import osmnx as ox


def get_graph(city: str, output: str) -> None:
    poly_load_filename = os.path.join("polys", city)
    with open(poly_load_filename, "rb") as poly_file:
        polygon = pickle.load(poly_file)

    ox.utils.config(
        nominatim_endpoint='http://nominatim:8080',
        overpass_endpoint='http://overpass:12345',
    )
    
    graphml_filename = os.path.join("graphml_files", output) 
    G = ox.graph_from_polygon(polygon, network_type="bike")
    G.name = output
    ox.save_graphml(G, filepath=graphml_filename)



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", '--city', type=str, required=True,
            help= "city")
    parser.add_argument("-o", '--output', type=str, required=True,
            help= "Graphml output path")
    args = parser.parse_args()

    get_graph(args.city, args.output)
