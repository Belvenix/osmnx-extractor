import osmnx as ox

ox.utils.config(
    nominatim_endpoint='http://nominatim:8080',
#    data_folder='/osmnx_data/shared/',
#    overpass_endpoint='http://overpass/api',
)
G = ox.graph_from_place("Monte carlo", network_type="bike")
ox.save_graphml(G)

GG = ox.graph.graph_from_xml('/osmnx_data/shared/monaco-latest.osm')
ox.save_graphml(GG, 'monaco')