import os

import networkx as nx
import osmnx as ox


def clean_graph(first, second) -> bool:
    print(f"Comment --------- Chaking difference of {second.name} in {first.name}")
    
    dif_nodes = set(second) - set(first)
    if len(dif_nodes) == 0:
        print("Comment --------- There are no new nodes but still checking")
    
    dif_edges = set(second.edges()) - set(first.edges())
    if len(dif_edges) != 0:
        return False
        
    print("Comment --------- There are no new edges so checking edge data")
    
    for edge in set(second.edges()):
        for x in second.edges([edge[0], edge[1]], data=True):
            save=True
            x_values = x[2]
            x_values.pop('osmid', None)
            x_values.pop('name', None)
            for y in first.edges([edge[0], edge[1]], data=True):
                y_values = y[2]
                y_values.pop('osmid', None)
                y_values.pop('name', None)
                if x_values == y_values:
                    save=False
                
            if save:
                print("Comment --------- We found some new edge data so saving it")
                return False
        
    return True


def main():
    files = os.listdir('./graphml_files')
    values = set(map(lambda x: '_'.join(x.split('_')[:-1]), files))
    files_group = [[y for y in files if x in y] for x in values]

    for group in files_group:
        first = None
        group.sort()
        for file_ext in group:
            full_path = os.path.join('graphml_files', file_ext)
            if first is None:
                first = ox.io.load_graphml(full_path)
            else:
                second = ox.io.load_graphml(full_path)
                result = clean_graph(first, second)
                if result == True:
                    print(f"Removing {full_path} !!!!!!!!!!!!!!!!")
                    os.remove(full_path)
                else:
                    first = second


if __name__ == '__main__':
    main()

