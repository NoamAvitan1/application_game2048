import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyObject {
  int row;
  int col;

  MyObject(this.row, this.col);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<List<int>> board = List.generate(4, (_) => List.filled(4, 0));
  bool isMoving = false;
  bool failed = false;
  int score = 0;
  bool isSoundEnabled = true;
  // late AnimationController _controller;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 9000),
    // );
    highestScore();
    fillCells(empty: true);
  }

  void toggleSound() {
    setState(() {
      isSoundEnabled = !isSoundEnabled;
    });
  }

  Future<void> playSound() async {
    String audioPath = "audio/Air-gun-sound-effect.mp3";
    await player.play(AssetSource(audioPath));
  }

  void highestScore() {
    int max = 0;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] > max) {
          max = board[i][j];
        }
      }
    }
    setState(() {
      score = max;
    });
  }

  MyObject? rndCell({MyObject? cell}) {
    List<MyObject> nullz = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) {
          if (cell == null || i != cell.row || j != cell.col) {
            MyObject c = MyObject(i, j);
            nullz.add(c);
          }
        }
      }
    }
    if (nullz.isEmpty) {
      return null;
    }
    int rnd = Random().nextInt(nullz.length);
    return nullz[rnd];
  }

  void fillCells({bool empty = false}) {
    var a = rndCell();
    var b = null;
    if (empty) b = rndCell(cell: a);
    var newBoard = [...board];
    if (a != null) {
      newBoard[a.row][a.col] = Random().nextDouble() > 0.5 ? 2 : 4;
    }
    if (empty && b != null) newBoard[b.row][b.col] = 2;
    setState(() {
      board = newBoard;
    });
    highestScore();
  }

  bool checkWinner() {
    for (int i = 0; i < 4; i++) {
      if (board[i].contains(2048)) return true;
    }
    return false;
  }

  bool checkFailed() {
    bool flag = true;
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length - 1; j++) {
        if (!((board[j + 1][i] != 0 && board[j][i] != 0) &&
            board[j][i] != board[j + 1][i])) {
          flag = false;
        }
        if (!((board[i][j + 1] != 0 && board[i][j] != 0) &&
            board[i][j] != board[i][j + 1])) {
          flag = false;
        }
      }
    }
    return flag;
  }

  void reset() {
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        board[i][j] = 0;
      }
    }
    fillCells(empty: true);
  }

  void moveRight() {
    List<List<int>> newArr = [];
    for (int d = 0; d < 4; d++) {
      var arr = board[d];
      int i = 0;
      int index;
      for (i = 0; i < 3; i++) {
        index = 0;
        for (int j = 0, k = arr.length - i - 2; j < 1 + i; j++) {
          if (arr[k + 1 + index] == 0 && arr[k + index] != 0) {
            arr[k + 1 + index] = arr[k + index];
            arr[k + index] = 0;
          }
          if (arr[k + 1 + index] == arr[k + index] && arr[k + index] != 0) {
            arr[k + 1 + index] = arr[k + index] + arr[k + index];
            arr[k + index] = 0;
          }
          index++;
        }
      }
      newArr.add(arr);
    }
    setState(() {
      board = newArr;
    });
    if (checkFailed()) {
      print('failed');
    }
    fillCells(empty: false);
  }

  void moveLeft() {
    List<List<int>> newArr = [];
    for (int d = 0; d < 4; d++) {
      var arr = board[d];
      int i = 0;
      int index;
      for (i = 0; i < 3; i++) {
        index = 0;
        for (int j = 0, k = i + 1; j < 1 + i; j++) {
          index = index.abs();
          if (arr[k - 1 - index] == 0 && arr[k - index] != 0) {
            arr[k - 1 - index] = arr[k - index];
            arr[k - index] = 0;
          }
          if (arr[k - 1 - index] == arr[k - index] && arr[k - index] != 0) {
            arr[k - 1 - index] = arr[k - index] + arr[k - index];
            arr[k - index] = 0;
          }
          index *= -1;
          index--;
        }
      }
      newArr.add(arr);
    }
    setState(() {
      board = newArr;
    });
    if (checkFailed()) {
      print('failed');
    }
    fillCells(empty: false);
  }

  void moveDown() {
    var arr = [...board];
    int index;
    for (int i = 0; i < 4; i++) {
      for (int d = 0; d < 3; d++) {
        index = 0;
        for (int j = 0, k = 2 - d; j < d + 1; j++) {
          if (arr[k + 1 + index][i] == 0 && arr[k + index][i] != 0) {
            arr[k + 1 + index][i] = arr[k + index][i];
            arr[k + index][i] = 0;
          }
          if (arr[k + 1 + index][i] == arr[k + index][i] &&
              arr[k + index][i] != 0) {
            arr[k + 1 + index][i] = arr[k + index][i] + arr[k + index][i];
            arr[k + index][i] = 0;
          }
          index++;
        }
      }
    }
    setState(() {
      board = arr;
    });
    if (checkFailed()) {
      print('failed');
    }
    fillCells(empty: false);
  }

  void moveUp() {
    var arr = [...board];
    int index;
    for (int i = 0; i < 4; i++) {
      for (int d = 0; d < 3; d++) {
        index = 0;
        for (int j = 0, k = 1 + d; j < d + 1; j++) {
          index = index.abs();
          if (arr[k - 1 - index][i] == 0 && arr[k - index][i] != 0) {
            arr[k - 1 - index][i] = arr[k - index][i];
            arr[k - index][i] = 0;
          }
          if (arr[k - 1 - index][i] == arr[k - index][i] &&
              arr[k - index][i] != 0) {
            arr[k - 1 - index][i] = arr[k - index][i] + arr[k - index][i];
            arr[k - index][i] = 0;
          }
          index *= -1;
          index--;
        }
      }
    }
    setState(() {
      board = arr;
    });
    if (checkFailed()) {
      print('failed');
    }
    fillCells(empty: false);
  }

  void onPressed() {
    print("d");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                color: const Color.fromARGB(255, 89, 161, 223),
                child: const Text(
                  '2048',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              Container(
                width: 100,
                color: const Color.fromARGB(255, 142, 155, 166),
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      const Text(
                        'score',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      Text(
                        score.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => reset(),
                child: const Text('reset'),
              ),
            ],
          ),
          const SizedBox(
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color.fromARGB(255, 142, 155, 166),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final boxSize = constraints.maxWidth / board[0].length;
                  final gridHeight = boxSize * board.length;
                  return Stack(
                    children: [
                      Container(
                        height: gridHeight,
                        child: GridView.builder(
                          itemCount: board.length * board[0].length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: board[0].length,
                            childAspectRatio:
                                1, // Maintain aspect ratio for each box
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            int row = index ~/ board[0].length;
                            int col = index % board[0].length;
                            return Container(
                              height: boxSize,
                              color: board[row][col] == 0
                                  ? const Color.fromARGB(255, 170, 182, 191)
                                  : HSLColor.fromAHSL(
                                          1.0,
                                          (board[row][col] * 10) % 360,
                                          0.7,
                                          0.5)
                                      .toColor(),
                              margin: const EdgeInsets.all(10),
                              alignment: Alignment.center,
                              child: Text(
                                '${board[row][col]}',
                                style: board[row][col] == 0
                                    ? const TextStyle(
                                        color:
                                            Color.fromARGB(255, 170, 182, 191))
                                    : const TextStyle(
                                        color: Colors.white, fontSize: 28),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity != 0) {
                              if (details.primaryVelocity! > 0) {
                                moveDown();
                              } else {
                                moveUp();
                              }
                              if (isSoundEnabled) playSound();
                            }
                          },
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity != 0) {
                              if (details.primaryVelocity! > 0) {
                                moveRight();
                              } else {
                                moveLeft();
                              }
                              if (isSoundEnabled) playSound();
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
