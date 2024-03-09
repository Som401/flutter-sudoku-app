import 'dart:io';

import 'sudoku_connections.dart';

import 'package:tuple/tuple.dart';
//import 'dart:convert';
//import 'package:http/http.dart' as http;

class SudokuBoard {
  List<List<int>> board;
  SudokuConnections sudokuGraph;
  List<List<int>> mappedGrid;

SudokuBoard(this.board)
      : mappedGrid = [],
        sudokuGraph = SudokuConnections() {
    sudokuGraph = SudokuConnections();
    mappedGrid = _getMappedMatrix();
  }
  // SudokuBoard()
  //     : board = [],
  //       mappedGrid = [],
  //       sudokuGraph = SudokuConnections() {
  //   getBoard().then((value) {
  //     board = value;
  //     sudokuGraph = SudokuConnections();
  //     mappedGrid = _getMappedMatrix();
  //   });
  // }

  List<List<int>> _getMappedMatrix() {
    List<List<int>> matrix = List.generate(9, (i) => List<int>.filled(9, 0));
    int count = 1;
    for (int rows = 0; rows < 9; rows++) {
      for (int cols = 0; cols < 9; cols++) {
        matrix[rows][cols] = count;
        count++;
      }
    }
    return matrix;
  }

  // Future<List<List<int>>> getBoard() {
  //   Future<List<List<int>>> board = fetchSudokuBoard();
  //   return board;
  // }

  void printBoard() {
  print("    1 2 3     4 5 6     7 8 9");
  for (int i = 0; i < board.length; i++) {
    if (i % 3 == 0) {
      print("  - - - - - - - - - - - - - - ");
    }
    String row = '';
    for (int j = 0; j < board[i].length; j++) {
      if (j % 3 == 0) {
        row += " |  ";
      }
      row += "${board[i][j]} ";
      if (j == 8) {
        row += " |  ${i + 1}";
      }
    }
    print(row);
  }
  print("  - - - - - - - - - - - - - - ");
}
  // Tuple2<int, int>? isBlank() {
  //   for (int row = 0; row < board.length; row++) {
  //     for (int col = 0; col < board[row].length; col++) {
  //       if (board[row][col] == 0) {
  //         return Tuple2(row, col);
  //       }
  //     }
  //   }
  //   return null;
  // }

  // bool isValid(int num, Tuple2<int, int> pos) {
  //   // ROW
  //   for (int col = 0; col < board[0].length; col++) {
  //     if (board[pos.item1][col] == num && pos.item1 != col) {
  //       return false;
  //     }
  //   }

  //   // COL
  //   for (int row = 0; row < board.length; row++) {
  //     if (board[row][pos.item2] == num && pos.item2 != row) {
  //       return false;
  //     }
  //   }

  //   // BLOCK
  //   int x = pos.item2 ~/ 3;
  //   int y = pos.item1 ~/ 3;

  //   for (int row = y * 3; row < y * 3 + 3; row++) {
  //     for (int col = x * 3; col < x * 3 + 3; col++) {
  //       if (board[row][col] == num && Tuple2(row, col) != pos) {
  //         return false;
  //       }
  //     }
  //   }

  //   return true;
  // }

  // bool solveItNaive() {
  //   var findBlank = isBlank();

  //   if (findBlank == null) {
  //     return true;
  //   } else {
  //     var row = findBlank.item1;
  //     var col = findBlank.item2;
  //     for (var i = 1; i < 10; i++) {
  //       if (isValid(i, Tuple2(row, col))) {
  //         board[row][col] = i;

  //         if (solveItNaive()) {
  //           return true;
  //         }
  //         board[row][col] = 0;
  //       }
  //     }
  //     return false;
  //   }
  // }

  Tuple2<List<int>, List<int>> graphColoringInitializeColor() {
    var color = List<int>.filled(sudokuGraph.graph.getTotalV() + 1, 0);
    var given = <int>[];

    for (var row = 0; row < board.length; row++) {
      for (var col = 0; col < board[row].length; col++) {
        if (board[row][col] != 0) {
          var idx = mappedGrid[row][col];
          color[idx] = board[row][col];
          given.add(idx);
        }
      }
    }
    return Tuple2(color, given);
  }

  Object solveGraphColoring({int m = 9}) {
    var colorAndGiven = graphColoringInitializeColor();
    var color = colorAndGiven.item1;
    var given = colorAndGiven.item2;

    if (graphColorUtility(m: m, color: color, v: 1, given: given) == false) {
      //print(":(");
      return false;
    }
    var count = 1;
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        board[row][col] = color[count];
        count++;
      }
    }
    return color;
  }

  bool graphColorUtility(
      {required int m,
      required List<int> color,
      required int v,
      required List<int> given}) {
    if (v == sudokuGraph.graph.getTotalV() + 1) {
      return true;
    }
    for (var c = 1; c <= m; c++) {
      if (isSafe2Color(v, color, c, given)) {
        color[v] = c;
        if (graphColorUtility(m: m, color: color, v: v + 1, given: given)) {
          return true;
        }
      }
      if (!given.contains(v)) {
        color[v] = 0;
      }
    }
    return false;
  }

  bool isSafe2Color(int v, List<int> color, int c, List<int> given) {
    if (given.contains(v) && color[v] == c) {
      return true;
    } else if (given.contains(v)) {
      return false;
    }

    for (var i = 1; i <= sudokuGraph.graph.getTotalV(); i++) {
      if (color[i] == c && sudokuGraph.graph.isNeighbour(v, i)) {
        return false;
      }
    }
    return true;
  }
}

// Future<List<List<int>>> fetchSudokuBoard() async {
//   final response = await http.get(Uri.parse(
//       'https://sudoku-api.vercel.app/api/dosuku?query={newboard(limit:1){grids{value}}}'));

//   if (response.statusCode == 200) {
//     // If the server returns a 200 OK response, parse the JSON.
//     var data = jsonDecode(response.body);
//     List<dynamic> rawBoard = data['newboard']['grids'][0]['value'];
//     List<List<int>> board = rawBoard
//         .map((row) => (row as List).map((item) => item as int).toList())
//         .toList();
//     print(board);
//     return board;
//   } else {
//     // If the server returns an unsuccessful response code, throw an exception.
//     throw Exception('Failed to load Sudoku board');
//   }
// }

// Future<void> sudokuSolve() async {
//   SudokuBoard s = SudokuBoard();
//   // Wait for the board to be ready
//   while (s.board.isEmpty) {
//     await Future.delayed(const Duration(milliseconds: 100));
//   }
//   print("BEFORE SOLVING ...\n\n");
//   s.printBoard();
//   print("\nSolving ...\n\n\nAFTER SOLVING ...\n\n");
//   s.solveGraphColoring(m: 9);
//   s.printBoard();
// }