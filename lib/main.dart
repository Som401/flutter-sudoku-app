import 'package:flutter/material.dart';
import 'dart:math';
import 'sudoku_solve.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const SudokuApp());

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku',
      home: SudokuScreen(),
    );
  }
}

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SudokuScreenState createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> {
  List<List<int>> _puzzle = [];
  List<List<int>> _solution = [];
  int _selectedRow = -1;
  int _selectedCol = -1;
  bool _isComplete = false;
  bool _isLoading = true;
  int _mistakes = 0; // Add this line

  @override
  void initState() {
    super.initState();
    fetchSudokuBoard().then((board) {
      setState(() {
        _puzzle = [...board]; // Deep copy of board
      });
      solveSudoku(board.map((list) => [...list]).toList()).then((solvedBoard) {
        // Deep copy of board
        setState(() {
          _solution = solvedBoard; // Set _solution to the solved board
          _isLoading = false;
          print(_puzzle);
        });
      });
    });
  }

  Future<List<List<int>>> fetchSudokuBoard() async {
    final response = await http.get(Uri.parse(
        'https://sudoku-api.vercel.app/api/dosuku?query={newboard(limit:1){grids{value}}}'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> rawBoard = data['newboard']['grids'][0]['value'];
      List<List<int>> board = rawBoard
          .map((row) => (row as List).map((item) => item as int).toList())
          .toList();
      return board;
    } else {
      throw Exception('Failed to load Sudoku board');
    }
  }

  Future<List<List<int>>> solveSudoku(List<List<int>> board) async {
    SudokuBoard s = SudokuBoard(board);
    print("BEFORE SOLVING ...\n\n");
    s.printBoard();
    print("\nSolving ...\n\n\nAFTER SOLVING ...\n\n");
    s.solveGraphColoring(m: 9);
    s.printBoard();
    return s.board;
  }

  void _checkComplete() {
    _isComplete = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_puzzle[i][j] == 0) {
          _isComplete = false;
          return;
        }
        if (_puzzle[i][j] != _solution[i][j]) {
          _isComplete = false;
        }
      }
    }
  }

  void _selectCell(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _enterNumber(int number) {
  if (_selectedRow != -1 && _selectedCol != -1) {
    setState(() {
      _puzzle[_selectedRow][_selectedCol] = number;
      if (_solution[_selectedRow][_selectedCol] != number) {
        _mistakes++; // Increment the mistakes counter if the entered number is wrong
      }
      _checkComplete();
      if (_mistakes == 3) {
        // Start a new game if the mistakes counter is 3
        fetchSudokuBoard().then((board) {
          solveSudoku(board.map((list) => [...list]).toList()).then((solvedBoard) {
            setState(() {
              _puzzle = board;
              _solution = solvedBoard;
              _selectedRow = -1;
              _selectedCol = -1;
              _isComplete = false;
              _mistakes = 0; // Reset the number of mistakes
            });
          });
        });
      }
    });
  }
}

  bool _isInSameGrid(int row, int col) {
    int gridRow = _selectedRow ~/ 3;
    int gridCol = _selectedCol ~/ 3;
    return row ~/ 3 == gridRow && col ~/ 3 == gridCol;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Sudoku',
          style: TextStyle(
            fontSize: 35,
            color: Color.fromARGB(255, 8, 62, 105),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 80,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Text(
                  'New Game',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  fetchSudokuBoard().then((board) {
                    solveSudoku(board.map((list) => [...list]).toList()).then((solvedBoard) {
                      setState(() {
                        _puzzle = board;
                        _solution = solvedBoard;
                        _selectedRow = -1;
                        _selectedCol = -1;
                        _isComplete = false;
                        _mistakes = 0; 
                      });
                    });
                  });
                },
              ),
              Text(
            '$_mistakes/3',
            style: const TextStyle(fontSize: 21, color: Colors.red),
          ),
          TextButton(
            child: const Text(
              'Give Up',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              setState(() {
                _puzzle = _solution.map((list) => [...list]).toList();
              });
            },
          ),
            ],
          ),
          Container(
              margin: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.46,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 8, 62, 105),
                    ))
                  : GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 9,
                      children: List.generate(81, (index) {
                        int row = index ~/ 9;
                        int col = index % 9;
                        bool isSameRow = row == _selectedRow;
                        bool isSameCol = col == _selectedCol;
                        bool isSameGrid = _isInSameGrid(row, col);
                        bool isSelected =
                            _selectedRow == row && _selectedCol == col;
                        return GestureDetector(
                          onTap: () {
                            _selectCell(row, col);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color:
                                      row % 3 == 0 ? Colors.black : Colors.grey,
                                  width: row % 3 == 0 ? 2.0 : 1.0,
                                ),
                                left: BorderSide(
                                  color:
                                      col % 3 == 0 ? Colors.black : Colors.grey,
                                  width: col % 3 == 0 ? 2.0 : 1.0,
                                ),
                                right: BorderSide(
                                  color: (col + 1) % 3 == 0
                                      ? Colors.black
                                      : Colors.grey,
                                  width: (col + 1) % 3 == 0 ? 2.0 : 1.0,
                                ),
                                bottom: BorderSide(
                                  color: (row + 1) % 3 == 0
                                      ? Colors.black
                                      : Colors.grey,
                                  width: (row + 1) % 3 == 0 ? 2.0 : 1.0,
                                ),
                              ),
                              color: isSelected
                                  ? const Color.fromARGB(255, 174, 209, 250)
                                  : (isSameRow || isSameCol || isSameGrid)
                                      ? const Color.fromARGB(255, 228, 241, 251)
                                      : Colors.white,
                            ),
                            child: Text(
                              _puzzle[row][col] == 0
                                  ? ''
                                  : _puzzle[row][col].toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _puzzle[row][col] == _solution[row][col]
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                          ),
                        );
                      }),
                    )),
          const SizedBox(height: 16),
          _isComplete
              ? const Text(
                  'Congratulations! You solved the puzzle!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 8, 62, 105),
                  ),
                )
              : const SizedBox(height: 29,),
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildNumberButton(1),
              _buildNumberButton(2),
              _buildNumberButton(3),
              _buildNumberButton(4),
              _buildNumberButton(5),
              _buildNumberButton(6),
              _buildNumberButton(7),
              _buildNumberButton(8),
              _buildNumberButton(9),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return GestureDetector(
      onTap: () {
        _enterNumber(number);
      },
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 50,
          color: Colors.blue,
        ),
      ),
    );
  }
}
