import ddf.minim.*;
import java.io.*;

PImage backgroundImage;     // Imagen de fondo
PImage spriteSheet;         // Sprite sheet del personaje

AudioPlayer song;
Minim minim;

// Variables para el mapa
int mapWidth = 3072;  // Ancho total del mapa
int mapHeight = 435;  // Altura total del mapa
int mapOffsetX = 0;  // Desplazamiento horizontal del mapa
int mapOffsetY = 0;  // Desplazamiento vertical del mapa

// Variables para el personaje
float worldX = 100;
float worldY = 0;
float charSize = 35;
float speedX = 0;
float speedY = 0;
float gravity = 0.5;
float jumpStrength = -20;
float groundLevel = 240;
boolean isJumping = false;

// Animaciones del personaje
int[][] jumpFrames = { {0, 6}, {1, 3}, {2, 3}, {3, 3}, {1, 3}, {0, 0} };
int[][] walkFrames = { {4, 0}, {5, 0}, {6, 0}, {7, 0}, {8, 0} };
int[][] ballHoldFrames = { {5, 3}, {6, 3}, {7, 3}, {8, 3} };
int[][] idleFrames = { {0, 0}, {1, 0}, {2, 0} };

// Variables para animaciones
int[][] currentAnimation = idleFrames;
int currentFrame = 0;
int frameDelay = 10;
int frameCounter = 0;

// Variables para el mapa de colisiones
int[][] collisionMap; // Array 2D para el mapa de colisiones

void setup() {
  size(720, 435);

  // Cargar las imágenes
  backgroundImage = loadImage("D:/Usuarios/David Estrada/Documents/GitHub/Sonic_Public/App/Project/data/Resources/Map.png");
  spriteSheet = loadImage("D:/Usuarios/David Estrada/Documents/GitHub/Sonic_Public/App/Project/data/Resources/Sonic_Spritesheet.png");

  if (backgroundImage == null || spriteSheet == null) {
    println("Error al cargar las imágenes.");
    exit();
  }

  // Cargar el archivo CSV para el mapa de colisiones
  loadCollisionMap("D:/Usuarios/David Estrada/Documents/GitHub/Sonic_Public/App/Project/data/Matriz.csv");

  worldX = 100;
  worldY = groundLevel;

  // Música
  minim = new Minim(this);
  song = minim.loadFile("D:/Usuarios/David Estrada/Documents/GitHub/Sonic_Public/App/Project/data/Resources/music.mp3");
  song.play();
}

void draw() {
  background(255);
  println("X: " + worldX + " Y: " + worldY);

  // Mover el mapa
  mapOffsetX += speedX * 1.5;
  mapOffsetX = constrain(mapOffsetX, 0, mapWidth - width);
  mapOffsetY = constrain(int(worldY - height / 2) + 100, 0, mapHeight - height);

  if (backgroundImage != null) {
    image(backgroundImage, -mapOffsetX, -mapOffsetY, mapWidth, mapHeight);
  }

  drawCharacter();

  frameCounter++;
  if (frameCounter >= frameDelay) {
    frameCounter = 0;
    nextFrame();
  }

  updatePhysics();
}

void loadCollisionMap(String Matriz) {
  // Leer el archivo CSV
  String[] lines = loadStrings(Matriz);
  collisionMap = new int[lines.length][];
  
  // Convertir las líneas del archivo CSV a un array 2D de enteros
  for (int i = 0; i < lines.length; i++) {
    String[] values = split(lines[i], ',');
    collisionMap[i] = new int[values.length];
    for (int j = 0; j < values.length; j++) {
      collisionMap[i][j] = int(values[j]);
    }
  }
}

boolean isSolid(float x, float y) {
  int mapX = int(x / charSize);  // Convertir las coordenadas en el mapa
  int mapY = int(y / charSize);
  // Verificar si está dentro de los límites del mapa
  if (mapX >= 0 && mapX < collisionMap[0].length && mapY >= 0 && mapY < collisionMap.length) {
    return collisionMap[mapY][mapX] == 1;  // Devuelve true si hay colisión
  }
  return false;  // Si está fuera del mapa, asumimos que no hay colisión
}

void updatePhysics() {
  // Aplicar gravedad
  speedY += gravity;
  float newY = worldY + speedY;

  // Verificar colisión con el suelo al caer
  if (speedY > 0 && isSolid(worldX, newY + charSize / 2)) {
    speedY = 0;
    worldY = floor(worldY / charSize) * charSize;
    isJumping = false;
  } else if (speedY < 0 && isSolid(worldX, newY - charSize / 2)) {
    speedY = 0;
    newY = ceil(worldY / charSize) * charSize + charSize / 2;
  } else {
    worldY = newY;
    isJumping = true;
  }

  // Colisión horizontal
  float newX = worldX + speedX;
  if (speedX > 0 && isSolid(newX + charSize / 2, worldY)) {
    speedX = 0;
    worldX = floor(worldX / charSize) * charSize + charSize / 2;
  } else if (speedX < 0 && isSolid(newX - charSize / 2, worldY)) {
    speedX = 0;
    worldX = ceil(worldX / charSize) * charSize - charSize / 2;
  } else {
    worldX = newX;
  }
}

void drawCharacter() {
  int sx = currentAnimation[currentFrame][0] * 50;
  int sy = currentAnimation[currentFrame][1] * 49;
  PImage frame = spriteSheet.get(sx, sy, 50, 49);
  image(frame, worldX - charSize / 2, worldY - charSize / 2, charSize, charSize);
}

void nextFrame() {
  currentFrame = (currentFrame + 1) % currentAnimation.length;
}

void setAnimation(int[][] newAnimation) {
  if (currentAnimation != newAnimation) {
    currentAnimation = newAnimation;
    currentFrame = 0;
  }
}

void keyPressed() {
  if (key == 'a') {
    speedX = -5;
    setAnimation(walkFrames);
  } else if (key == 'd') {
    speedX = 5;
    setAnimation(walkFrames);
  }

  if (key == 'w' && !isJumping) {
    speedY = jumpStrength;
    setAnimation(jumpFrames);
  }
}

void keyReleased() {
  if (key == 'a' || key == 'd') {
    speedX = 0;
    if (speedY == 0) {
      setAnimation(idleFrames);
    }
  } else if (key == 'w' && speedY == 0) {
    setAnimation(idleFrames);
  }
}
