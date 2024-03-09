
import 'graph.dart';

class SudokuConnections {
  Graph graph;
  int rows;
  int cols;
  int total_blocks;
  List<int> allIds;

  SudokuConnections()
      : graph = Graph(),
        rows = 0,
        cols = 0,
        total_blocks = 0,
        allIds = [] {
    rows = 9;
    cols = 9;
    total_blocks = rows * cols;
    _generateGraph();
    connectEdges();
    allIds = graph.getAllNodesIds();
  }
  

  void _generateGraph() {
    for (int idx = 1; idx <= total_blocks; idx++) {
      graph.addNode(idx);
    }
  }

  void connectEdges() {
    List<List<int>> matrix = _getGridMatrix();
    Map<int, Map<String, List<int>>> head_connections = {};

    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        int head = matrix[row][col];
        Map<String, List<int>> connections = _whatToConnect(matrix, row, col);
        head_connections[head] = connections;
      }
    }

    _connectThose(head_connections);
  }

  void _connectThose(Map<int, Map<String, List<int>>> head_connections) {
    head_connections.forEach((head, connections) {
      connections.forEach((key, values) {
        for (var v in values) {
          graph.addEdge(head, v);
        }
      });
    });
  }

  Map<String, List<int>> _whatToConnect(List<List<int>> matrix, int rows, int cols) {
  Map<String, List<int>> connections = {
    "rows": [],
    "cols": [],
    "blocks": []
  };

  // ROWS
  for (int c = cols + 1; c < 9; c++) {
    connections["rows"]?.add(matrix[rows][c]);
  }

  // COLS
  for (int r = rows + 1; r < 9; r++) {
    connections["cols"]?.add(matrix[r][cols]);
  }

  // BLOCKS
  int blockRowStart = rows - rows % 3;
  int blockColStart = cols - cols % 3;

  for (int r = blockRowStart; r < blockRowStart + 3; r++) {
    for (int c = blockColStart; c < blockColStart + 3; c++) {
      if (r != rows && c != cols) {
        connections["blocks"]?.add(matrix[r][c]);
      }
    }
  }

  return connections;
}
  List<List<int>> _getGridMatrix() {
    List<List<int>> matrix = List.generate(this.rows, (i) => List<int>.filled(this.cols, 0), growable: false);
    int count = 1;
    for (int rows = 0; rows < 9; rows++) {
      for (int cols = 0; cols < 9; cols++) {
        matrix[rows][cols] = count;
        count++;
      }
    }
    return matrix;
  }
}