import networkx as nx
import osmnx as ox

ox.utils.config(nominatim_endpoint='nominatim')
G = ox.graph_from_place("Monte carlo", network_type="bike")
ox.save_graphml(G)