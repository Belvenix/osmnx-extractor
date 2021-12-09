import argparse

import networkx as nx
import osmnx as ox


def get_graph(city: str, output: str) -> None:
    ox.utils.config(
        nominatim_endpoint='http://localhost:8080',
    #    overpass_endpoint='http://localhost:12345/api',
    )

    print('Looking for city ' + str(city))
    G = ox.graph_from_place(city, network_type="drive")
    print('Saving city ' + str(city))
    ox.save_graphml(G, filepath=output)



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", '--city', type=str, required=True,
            help= "Which city to get the graph")
    parser.add_argument("-o", '--output', type=str, required=True,
            help= "Graphml output path")
    args = parser.parse_args()

    get_graph(args.city, args.output)
