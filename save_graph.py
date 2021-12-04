import networkx as nx
import osmnx as ox

ox.utils.config(nominatim_endpoint='nominatim', overpass_endpoint='overpass')
G = ox.graph_from_place("Monte carlo", network_type="bike")
ox.save_graphml(G)