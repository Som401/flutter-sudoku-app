import 'package:flutter/material.dart';
import 'dart:math';

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
  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    var rng = Random();
    _solution =
        List.generate(9, (_) => List.generate(9, (_) => rng.nextInt(9) + 1));
    _puzzle = List.generate(9, (_) => List.generate(9, (_) => 0));
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (rng.nextDouble() < 0.5) {
          _puzzle[i][j] = _solution[i][j];
        }
      }
    }
  }

  void _checkComplete() {
    // Check if the puzzle is complete
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
        _checkComplete();
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
        toolbarHeight: 60,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('New Game'),
            onPressed: () {
              setState(() {
                _generatePuzzle();
                _selectedRow = -1;
                _selectedCol = -1;
                _isComplete = false;
              });
            },
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 9,
                childAspectRatio: 1.0,
                children: List.generate(81, (index) {
                  int row = index ~/ 9;
                  int col = index % 9;
                  bool isSameRow = row == _selectedRow;
                  bool isSameCol = col == _selectedCol;
                  bool isSameGrid = _isInSameGrid(row, col);
                  bool isSelected = _selectedRow == row && _selectedCol == col;
                  return GestureDetector(
                    onTap: () {
                      _selectCell(row, col);
                    },
                    child: Container(
                      constraints: const BoxConstraints.tightFor(height: 30.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: row % 3 == 0 ? Colors.black : Colors.grey,
                            width: row % 3 == 0 ? 2.0 : 1.0,
                          ),
                          left: BorderSide(
                            color: col % 3 == 0 ? Colors.black : Colors.grey,
                            width: col % 3 == 0 ? 2.0 : 1.0,
                          ),
                          right: BorderSide(
                            color:
                                (col + 1) % 3 == 0 ? Colors.black : Colors.grey,
                            width: (col + 1) % 3 == 0 ? 2.0 : 1.0,
                          ),
                          bottom: BorderSide(
                            color:
                                (row + 1) % 3 == 0 ? Colors.black : Colors.grey,
                            width: (row + 1) % 3 == 0 ? 2.0 : 1.0,
                          ),
                        ),
                        color: isSelected
                            ? const Color(0xFFBEDBFD)
                            : (isSameRow || isSameCol || isSameGrid)
                                ? const Color(0xFFF4F9FD)
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
              ),
            ),
          ),
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
              : const SizedBox(),
          const SizedBox(height: 20),
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
