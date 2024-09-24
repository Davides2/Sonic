import ddf.minim.*;

float x = 40; // x coord for character image
float y = 560; // y coord for character image
int size = 160; // sprite size
float charX = 100; // Character's X position
float charY = 520; // Character's Y position (starts at ground level)
float speed = 30; // Movement speed (increased)
float runSpeed = 200; // Running speed (increased)
int direction = 0;
int speedJump = 80; // Character jump force
int backgroundMax = 2; // Background Frame count
int groundLevel = 520; // Ground Level
PImage sonic, obstaculo;
PImage[] fondo = new PImage[2];
PImage[] img = new PImage[4];
PImage walkAnim, idleAnim, runAnim, pushAnim, ballStartAnim, ballFinishAnim;

// Sprite sheet details
int walkCols = 5;
int idleCols = 5;
int runCols = 4;
int pushCols = 4;
int BallStartCols = 5;
int BallFinishCols = 4;
int idleFrameWidth = 50;
int idleFrameHeight = 44;
int walkFrameWidth = 50;
int walkFrameHeight = 44;
int runFrameWidth = 50;
int runFrameHeight = 44;
int pushFrameWidth = 50;
int pushFrameHeight = 44;
int BallstartWidth = 50;
int BallstartHeight = 44;
int BallfinishWidth = 50;
int BallfinishHeight = 44;
int currentFrame = 0;
int frameDelay = 2;
int frameCounter = 0;

boolean isMoving = false, onGround = true, jump = false, isRunning = false;
int ii = 0;
int gravity = 10;
int k = 0;
AudioPlayer player;
Minim minim;

// Scale factor for resizing sprites
float spriteScale = 4.5; // You can adjust this to make sprites larger or smaller

void setup() {
  size(1280, 720);
  
  minim = new Minim(this);
  
  walkAnim = loadImage("Resources/Walk_Sonic.png");
  idleAnim = loadImage("Resources/Idle_Sonic.png");
  pushAnim = loadImage("Resources/Push_Sonic.png");
  runAnim = loadImage("Resources/Run_Sonic.png");
  ballStartAnim = loadImage("Resources/Sonic_Ball_Start.png");
  ballFinishAnim = loadImage("Resources/Sonic_Ball_Finish.png");

  checkImage(walkAnim, "Walk_Sonic.png");
  checkImage(idleAnim, "Idle_Sonic.png");
  checkImage(pushAnim, "Push_Sonic.png");
  checkImage(runAnim, "Run_Sonic.png");
  checkImage(ballStartAnim, "Sonic_Ball_Start.png");
  checkImage(ballFinishAnim, "Sonic_Ball_Finish.png");
  
  for (int i = 0; i < backgroundMax; i++) {
    fondo[i] = loadImage("Resources/fondo" + i + ".jpg");
    checkImage(fondo[i], "fondo" + i + ".jpg");
  }

  player = minim.loadFile("Resources/Musichero.mp3");
  if (player == null) {
    println("Error loading audio file.");
  } else {
    player.play();
  }
  
  frameRate(60); // Set frame rate for smoother animation
}

void draw() {
  if (fondo[k] != null) {
    image(fondo[k], 0, 0, width, height); 
  } else {
    println("Background image is null.");
  }
  
  moveCharacter();
  
  frameCounter++;
  
  if (isRunning) {
    if (frameCounter % frameDelay == 0) {
      currentFrame = (currentFrame + 1) % runCols;
    }
    int x = currentFrame * runFrameWidth;
    int y = direction * runFrameHeight;
    PImage animFrame = runAnim.get(x, y, runFrameWidth, runFrameHeight);
    if (animFrame != null) {
      image(animFrame, charX - (runFrameWidth * spriteScale) / 2, charY - (runFrameHeight * spriteScale),
            runFrameWidth * spriteScale, runFrameHeight * spriteScale); // Resized running animation
    } else {
      println("Running animation frame is null.");
    }
  } else if (isMoving) {
    if (frameCounter % frameDelay == 0) {
      currentFrame = (currentFrame + 1) % walkCols;
    }
    int x = currentFrame * walkFrameWidth;
    int y = direction * walkFrameHeight;
    PImage animFrame = walkAnim.get(x, y, walkFrameWidth, walkFrameHeight);
    if (animFrame != null) {
      image(animFrame, charX - (walkFrameWidth * spriteScale) / 2, charY - (walkFrameHeight * spriteScale),
            walkFrameWidth * spriteScale, walkFrameHeight * spriteScale); // Resized walking animation
    } else {
      println("Walking animation frame is null.");
    }
  } else {
    if (frameCounter % frameDelay == 0) {
      currentFrame = (currentFrame + 1) % idleCols;
    }
    int x = currentFrame * idleFrameWidth;
    int y = direction * idleFrameHeight;
    PImage animFrame = idleAnim.get(x, y, idleFrameWidth, idleFrameHeight);
    if (animFrame != null) {
      image(animFrame, charX - (idleFrameWidth * spriteScale) / 2, charY - (idleFrameHeight * spriteScale),
            idleFrameWidth * spriteScale, idleFrameHeight * spriteScale); // Resized idle animation
    } else {
      println("Idle animation frame is null.");
    }
  }
  
  if (jump && onGround) {
    charY -= speedJump;
    onGround = false;
    jump = false;
  }
  
  if (!onGround) {
    charY += gravity;
  }
  
  if (charY >= groundLevel) {
    charY = groundLevel;
    onGround = true;
  }
  
  if (img[ii] != null) {
    image(img[ii], charX, charY, size, size);
  } else {
    println("Character image is null.");
  }

  x = charX;
  y = charY;
  
  if (x > 1100) {
    k = (k + 1) % backgroundMax;
    charX = 40;
  }
  
  x = constrain(x, 0, width - size);
  y = constrain(y, 0, height - size);

  isMoving = (charX != 0 || charY != 0);
  if (isMoving) {
    ii = (ii + 1) % img.length;
  }
}

void moveCharacter() {

  if (keyPressed) {
    if (keyCode == UP || key == 'w' || key == 'W') {
      jump = true;
      isMoving = true;
    }
    if (keyCode == LEFT || key == 'a' || key == 'A') {
      charX -= (isRunning) ? runSpeed : speed;
      isMoving = true;
    }
    if (keyCode == RIGHT || key == 'd' || key == 'D') {
      isRunning = keyPressed && keyCode == 'z';
      charX += (isRunning) ? runSpeed : speed;
      isMoving = true;
    }
  } else {
    isMoving = false;
  }
}

void checkImage(PImage img, String fileName) {
  if (img == null) {
    println("Error loading image: " + fileName);
  }
}