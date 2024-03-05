class Node {
  int id;
  int data;
  Map<int, int> connectedTo;

  Node({
    required this.id,
    this.data = 0,
    Map<int, int>? connectedTo,
  }) : this.connectedTo = connectedTo ?? {};
  
  void addNeighbour(Node neighbour, {int weight = 0}) {
    if (!this.connectedTo.containsKey(neighbour.id)) {
      this.connectedTo[neighbour.id] = weight;
    }
  }

  void setData(int data) {
    this.data = data;
  }

  Iterable<int> getConnections() {
    return this.connectedTo.keys;
  }

  int getID() {
    return this.id;
  }

  int getData() {
    return this.data;
  }

  int getWeight(Node neighbour) {
    return this.connectedTo[neighbour.id] ?? 0;
  }

  @override
  String toString() {
    return '${this.data} Connected to: ${this.connectedTo.keys.toList()}';
  }
}

class Graph {
  static int totalV = 0;
  Map<int, Node> allNodes = {};

  void addNode(int idx) {
    if (allNodes.containsKey(idx)) {
      return;
    }
    totalV += 1;
    Node node = Node(id: idx);
    allNodes[idx] = node;
  }

  void addNodeData(int idx, dynamic data) {
    if (allNodes.containsKey(idx)) {
      Node node = allNodes[idx]!;
      node.setData(data);
    } else {
      print("No ID to add the data.");
    }
  }

  void addEdge(int src, int dst, [int wt = 0]) {
    allNodes[src]!.addNeighbour(allNodes[dst]!, weight: wt);
    allNodes[dst]!.addNeighbour(allNodes[src]!, weight: wt);
  }

  bool isNeighbour(int u, int v) {
    if (u >= 1 && u <= 81 && v >= 1 && v <= 81 && u != v) {
      if (allNodes[u]!.getConnections().contains(v)) {
        return true;
      }
    }
    return false;
  }

  void printEdges() {
    allNodes.forEach((idx, node) {
      node.getConnections().forEach((con) {
        print('${node.getID()} --> ${allNodes[con]!.getID()}');
      });
    });
  }

  Node? getNode(int idx) {
    return allNodes[idx];
  }

  List<int> getAllNodesIds() {
    return allNodes.keys.toList();
  }

  void DFS(int start) {
    List<bool> visited = List.filled(totalV, false);
    if (allNodes.containsKey(start)) {
      _DFSUtility(node_id: start, visited: visited);
    } else {
      print("Start Node not found");
    }
  }

  void _DFSUtility({int? node_id, required List<bool> visited}) {
    visited[node_id!] = true;
    print('${allNodes[node_id]!.getID()} ');
    allNodes[node_id]!.getConnections().forEach((i) {
      if (!visited[allNodes[i]!.getID()]) {
        _DFSUtility(node_id: allNodes[i]!.getID(), visited: visited);
      }
    });
  }

  void BFS(int start) {
    List<bool> visited = List.filled(totalV, false);
    if (allNodes.containsKey(start)) {
      _BFSUtility(node_id: start, visited: visited);
    } else {
      print("Start Node not found");
    }
  }

  void _BFSUtility({required int node_id, required List<bool> visited}) {
    List<int> queue = [];
    visited[node_id] = true;
    queue.add(node_id);
    while (queue.isNotEmpty) {
      int x = queue.removeAt(0);
      print('${allNodes[x]?.getID()} ');
      allNodes[x]?.getConnections().forEach((i) {
        int idx = allNodes[i]!.getID();
        if (!visited[idx]) {
          queue.add(idx);
          visited[idx] = true;
        }
      });
    }
  }
}