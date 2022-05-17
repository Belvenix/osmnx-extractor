import os
import argparse
import pickle

import networkx as nx
import osmnx as ox


def get_graph(city: str, output: str, time: str) -> None:
    poly_load_filename = os.path.join("polys", city)
    graphml_filename = os.path.join("graphml_files", output) 
    graphml_filename += "_v3"
    with open(poly_load_filename, "rb") as poly_file:
        polygon = pickle.load(poly_file)

    useful_tags = ox.settings.useful_tags_way + ['cycleway']
    ox.config(use_cache=True, log_console=True, useful_tags_way=useful_tags)
    print(f'Downloading data from overpass from "{time}"')
    ox.utils.config(
                nominatim_endpoint='http://localhost:8080',
                overpass_settings=f'[out:json][timeout:200][date:"{time}"]')
    G = ox.graph_from_polygon(polygon, network_type="bike", simplify=False,  retain_all=True)
    G.name = output
    Gf = ox.utils_graph.remove_isolated_nodes(G.copy())
    Gf = ox.simplify_graph(Gf)
    ox.save_graphml(Gf, filepath=graphml_filename)

    graphml_filename += "_only_cycleway"
    non_cycleways = [(u, v, k) for u, v, k, d in G.edges(keys=True, data=True) if not ('cycleway' in d or d['highway']=='cycleway')]
    G.remove_edges_from(non_cycleways)
    G = ox.utils_graph.remove_isolated_nodes(G)
    G = ox.simplify_graph(G)
    ox.save_graphml(G, filepath=graphml_filename)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", '--city', type=str, required=True,
            help= "city")
    parser.add_argument("-o", '--output', type=str, required=True,
            help= "Graphml output path")
    parser.add_argument("-t", '--time', type=str, required=False,
            default="", help= "Time of overpass data to download")
    args = parser.parse_args()

    get_graph(args.city, args.output, args.time)
