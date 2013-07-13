import 'dart:html';
import 'dart:math';
import 'dart:async';
import 'dart:collection';

const int HORIZONTAL_TILES = 40;
const int VERTICAL_TILES = 40;
const int TILE_WIDTH = 15;
const String CANVAS_BACKGROUND="#EEE";
const int SPEED = 100; // in milliseconds
const String FRUIT_COLOR = "black";
const String SNAKE_COLOR = "green";
const int INIT_SNAKE_SIZE = 6;

var canvas = query('#canvas');
var ctx = canvas.getContext('2d');

Tile fruit;
Snake snake;
Direction snakeDirection;
Random randomGenerator = new Random();
Timer timer;


void main() {
  canvas.width=HORIZONTAL_TILES*TILE_WIDTH;
  canvas.height=VERTICAL_TILES*TILE_WIDTH;
  ctx.fillStyle = CANVAS_BACKGROUND;
  ctx.fillRect(0, 0, HORIZONTAL_TILES*TILE_WIDTH, VERTICAL_TILES*TILE_WIDTH);
  
  snake = new Snake(INIT_SNAKE_SIZE);
  snakeDirection = Direction.DOWN;
  
  initTimer();
  initKeyBoardListener();
  generateFruit();
}


void initTimer(){
  void moveSnake(Timer timer){
    bool hasMoved = true;
    switch (snakeDirection) {
      case Direction.RIGHT:
        hasMoved = snake.moveRight(); break;
      case Direction.LEFT:
        hasMoved = snake.moveLeft(); break;
      case Direction.UP:
        hasMoved = snake.moveUp(); break;
      case Direction.DOWN:
        hasMoved =  snake.moveDown(); break;
    }
    if(!hasMoved){ timer.cancel(); }
  }
  timer = new Timer.periodic(const Duration(milliseconds: SPEED), moveSnake);
}

void initKeyBoardListener(){
  void processKeyEvent(Direction direction, Direction opposite){
    if(snakeDirection != opposite) 
      snakeDirection = direction;
  }
  void keyboardListener(Event event){
    if(event is KeyboardEvent){ 
      KeyboardEvent kEvent = event as KeyboardEvent;    
      switch(kEvent.$dom_keyIdentifier){
        case "Up":
          processKeyEvent(Direction.UP, Direction.DOWN); break;
        case "Down":
          processKeyEvent(Direction.DOWN, Direction.UP); break;
        case "Left":
          processKeyEvent(Direction.LEFT, Direction.RIGHT); break;
        case "Right":
          processKeyEvent(Direction.RIGHT, Direction.LEFT); break;
      }
    }
  }
  window.onKeyDown.listen(keyboardListener);
}


void generateFruit(){
  int x = randomGenerator.nextInt(HORIZONTAL_TILES);
  int y = randomGenerator.nextInt(VERTICAL_TILES);
  fruit = new Tile(x, y);
  fruit.paint(FRUIT_COLOR);
}





/* --------------------
 * SNAKE CLASS
 * -------------------- */

class Snake {
  
  var queue = new Queue<Tile>();
  
  Snake(int initSize){
    int x = randomGenerator.nextInt(HORIZONTAL_TILES-initSize*2);
    int y = randomGenerator.nextInt(VERTICAL_TILES);
    for(int i=0; i<initSize; i++){
      Tile tile = new Tile(x, y);
      tile.paint(SNAKE_COLOR);
      queue.add(tile);
      x++;
    }
  }
  
  bool checkCollision(Tile head){
    for(Tile tile in queue){
      if(tile.equals(head))
        return true;
    }
    return false;
  }
  
  bool verifyNewHead(Function wallBeingHit, Function calculateNewHead){
    Tile oldHead = queue.last;
    if(wallBeingHit(oldHead)){ return false; }
    Tile newHead = calculateNewHead(oldHead);
    bool hasNotCollided = !checkCollision(newHead);
    if(hasNotCollided){
      newHead.paint(SNAKE_COLOR);
      queue.add(newHead);
      if(!newHead.equals(fruit)){
        Tile tail = queue.removeFirst();
        tail.clear();
      } else {
        generateFruit();
      }
    }
    return hasNotCollided; 
  }
  
  bool moveRight(){
    var wallBeingHit = (Tile head){ return head.xpos == HORIZONTAL_TILES-1; };
    var calculateNewHead = (Tile oldHead){
      int newXpos = oldHead.xpos+1;
      int newYpos = oldHead.ypos;
      return new Tile(newXpos, newYpos);
    };
    return verifyNewHead(wallBeingHit, calculateNewHead);
  }
  
  bool moveLeft(){
    var wallBeingHit = (Tile head){ return head.xpos == 0; };
    var calculateNewHead = (Tile oldHead){
      int newXpos = oldHead.xpos-1;
      int newYpos = oldHead.ypos;
      return new Tile(newXpos, newYpos);
    };
    return verifyNewHead(wallBeingHit, calculateNewHead);
  }
  
  bool moveUp(){
    var wallBeingHit = (Tile head){ return head.ypos == 0; };
    var calculateNewHead = (Tile oldHead){
      int newXpos = oldHead.xpos;
      int newYpos = oldHead.ypos-1;
      return new Tile(newXpos, newYpos);
    };
    return verifyNewHead(wallBeingHit, calculateNewHead);
  }
  
  bool moveDown(){
    var wallBeingHit = (Tile head){ return head.ypos == VERTICAL_TILES-1; };
    var calculateNewHead = (Tile oldHead){
      int newXpos = oldHead.xpos;
      int newYpos = oldHead.ypos+1;
      return new Tile(newXpos, newYpos);
    };
    return verifyNewHead(wallBeingHit, calculateNewHead);  
  }
  
  
}



/* --------------------
 * TILE CLASS
 * -------------------- */

class Tile{
  
  int xpos;
  int ypos;
  
  Tile(int xpos, int ypos){
    this.xpos = xpos;
    this.ypos = ypos;
  }
  
  bool equals(Object obj){
    if(obj is Tile){
      return obj.xpos == this.xpos && obj.ypos == this.ypos;
    }
    return false;
  }
  
  void paint(String color){
    ctx.fillStyle = color;
    ctx.fillRect(xpos*TILE_WIDTH, ypos*TILE_WIDTH, TILE_WIDTH, TILE_WIDTH);
    ctx.strokeStyle = "white";
    ctx.strokeRect(xpos*TILE_WIDTH, ypos*TILE_WIDTH, TILE_WIDTH, TILE_WIDTH);
  }
  
  void clear(){
    ctx.fillStyle = CANVAS_BACKGROUND;
    ctx.fillRect(xpos*TILE_WIDTH-1, ypos*TILE_WIDTH-1, TILE_WIDTH+2, TILE_WIDTH+2);
  }
  
}


/* --------------------
 * DIRECTIONS ENUM CLASS
 * -------------------- */
// Dart currently does not support a nice way of expressing enums

class Direction {
  static const LEFT = const Direction._(0);
  static const RIGHT = const Direction._(1);
  static const UP = const Direction._(2);
  static const DOWN = const Direction._(3);

  static get values => [LEFT, RIGHT, UP, DOWN];

  final int value;

  const Direction._(this.value);
}



