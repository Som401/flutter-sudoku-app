import 'sudoku_connections.dart';

void testConnections() {
  SudokuConnections sudoku = SudokuConnections();
  sudoku.connectEdges();
  print("All node Ids : ");
  print(sudoku.graph.getAllNodesIds());
  print("\n");
  for (var idx in sudoku.graph.getAllNodesIds()) {
    print('$idx Connected to-> ${sudoku.graph.allNodes[idx]?.getConnections()}');
  }
}

void test() {
  testConnections();
}