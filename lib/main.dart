import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
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
      home: const MyHomePage(),
    );
  }
}

class MyObject {
  int row;
  int col;

  MyObject(this.row, this.col);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<List<int>> board = List.generate(4, (_) => List.filled(4, 0));
  bool failed = false;
  int score = 0;
  bool isWinner = false;
  bool isSoundEnabled = true;
  late ConfettiController _controllerTopCenter;
  // late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 9000),
    // );
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    highestScore();
    fillCells(empty: true);
  }

  @override
  void dispose() {
    _controllerTopCenter.dispose();
    super.dispose();
  }

  void toggleSound() {
    setState(() {
      isSoundEnabled = !isSoundEnabled;
    });
  }

  Future<void> playSound(String path) async {
    AudioPlayer currentPlayer = AudioPlayer();
    await currentPlayer.play(AssetSource(path));
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
      if (board[i].contains(2048)) {
        setState(() {
          score = 2048;
          isWinner = true;
        });
        playSound("audio/Game-show-winning.mp3");
        _controllerTopCenter.play();
        return true;
      }
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
    if (flag) {
      setState(() {
        failed = true;
      });
    }
    return flag;
  }

  void reset() {
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        board[i][j] = 0;
      }
    }
    setState(() {
      failed = false;
    });
    fillCells(empty: true);
  }

  void moveRight() {
    if (failed || isWinner) return;
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
    if (checkWinner()) return;
    if (checkFailed()) {
      playSound("audio/Game-over-ident.mp3");
    }
    fillCells(empty: false);
  }

  void moveLeft() {
    if (failed || isWinner) return;
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
    if (checkWinner()) return;
    if (checkFailed()) {
      playSound("audio/Game-over-ident.mp3");
    }
    fillCells(empty: false);
  }

  void moveDown() {
    if (failed || isWinner) return;
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
    if (checkWinner()) return;
    if (checkFailed()) {
      playSound("audio/Game-over-ident.mp3");
    }
    fillCells(empty: false);
  }

  void moveUp() {
    if (failed || isWinner) return;
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
    if (checkWinner()) return;
    if (checkFailed()) {
      playSound("audio/Game-over-ident.mp3");
    }
    fillCells(empty: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => toggleSound(),
              icon: isSoundEnabled
                  ? const Icon(
                      Icons.volume_up_outlined,
                      size: 30,
                    )
                  : const Icon(Icons.volume_off_outlined, size: 30),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100,
                  height: 95,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    color: const Color.fromARGB(255, 89, 161, 223),
                    child: const Center(
                      child: Text(
                        '2048',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 95,
                  child: Container(
                    color: const Color.fromARGB(255, 142, 155, 166),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'score',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          Text(
                            score.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 95,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 142, 155, 166),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                    onPressed: () => reset(),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New',
                            style: TextStyle(
                                color: Color.fromARGB(255, 246, 243, 243),
                                fontSize: 15),
                          ),
                          Text(
                            'Game',
                            style: TextStyle(
                                color: Color.fromARGB(255, 246, 243, 243),
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                              childAspectRatio: 1,
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
                                        0.5,
                                      ).toColor(),
                                margin: const EdgeInsets.all(10),
                                alignment: Alignment.center,
                                child: Text(
                                  '${board[row][col]}',
                                  style: board[row][col] == 0
                                      ? const TextStyle(
                                          color: Color.fromARGB(
                                              255, 170, 182, 191))
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
                                if (isSoundEnabled && !failed) {
                                  playSound("audio/Air-gun-sound-effect.mp3");
                                }
                              }
                            },
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity != 0) {
                                if (details.primaryVelocity! > 0) {
                                  moveRight();
                                } else {
                                  moveLeft();
                                }
                                if (isSoundEnabled && !failed) {
                                  playSound("audio/Air-gun-sound-effect.mp3");
                                }
                              }
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConfettiWidget(
                            confettiController: _controllerTopCenter,
                            blastDirection: pi / 2,
                            maxBlastForce: 5,
                            minBlastForce: 2,
                            emissionFrequency: 0.05,
                            numberOfParticles: 50,
                            gravity: 1,
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
      ),
    );
  }
}
