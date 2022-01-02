import argparse

import networkx as nx
import osmnx as ox
import overpy as op
import shapely.geometry as geometry

from shapely.ops import linemerge, unary_union, polygonize


def get_graph(relation: int, output: str) -> None:
    query = f"""[out:json][timeout:25];
    rel({relation});
    out geom;
    >;
    out skel qt; """
    api = op.Overpass()
    result = api.query(query)

    rel = result.get_relations()[0]
    lss = []
    for ii_w, way in enumerate(rel.members[1:]):
        ls_coords = []

        for node in way.geometry:
            ls_coords.append((node.lon, node.lat))

        lss.append(geometry.LineString(ls_coords))

    merged = linemerge([*lss])
    borders = unary_union(merged)
    polygons = list(polygonize(borders))

    city = polygons[0]

    ox.utils.config(
        nominatim_endpoint='http://nominatim:8080',
        overpass_endpoint='http://overpass:12345',
    )

    G = ox.graph_from_polygon(city, network_type="bike")
    ox.save_graphml(G, filepath=output)



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-r", '--relation', type=int, required=True,
            help= "Relation id of the city")
    parser.add_argument("-o", '--output', type=str, required=True,
            help= "Graphml output path")
    args = parser.parse_args()

    get_graph(args.relation, args.output)
