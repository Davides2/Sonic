PImage spriteSheet; // Hoja de sprites de Sonic
PImage backgroundImage; // Imagen de fondo (el mapa de colisiones)
int spriteWidth = 50; // Ancho de cada sprite
int spriteHeight = 49; // Alto de cada sprite

// Definir las animaciones con las posiciones correctas
int[][] walkFrames = { {4, 0}, {5, 0}, {6, 0}, {7, 0}, {8, 0} };  // Animación caminar
int[][] jumpFrames = { {0, 6}, {1, 3}, {2, 3}, {3, 3}, {1, 3}, {0, 0} };  // Animación de salto
int[][] idleFrames = { {0, 0}, {1, 0}, {2, 0} }; // Animación idle
int[][] ballHoldFrames = { {5, 3}, {6, 3}, {7, 3}, {8, 3} }; // Animación de bolita

int[][] currentAnimation = idleFrames; // Animación actual
int currentFrame = 0;
int frameDelay = 10;  // Velocidad de cambio de cuadro
int frameCounter = 0; // Contador de cuadros para la animación

// Variables físicas
int[][] collisionMap;
float worldX = 100; // Posición inicial de Sonic en el eje X
float worldY = 100; // Posición inicial en el eje Y
float charSize = 32; // Tamaño del personaje
float speedX = 0;
float speedY = 0;
float gravity = 0.5;
boolean isJumping = false;

boolean isBall = false;  // Indicador de si Sonic es una bolita

void setup() {
  size(720, 435); // Tamaño de la ventana

  // Cargar la hoja de sprites de Sonic
  spriteSheet = loadImage("D:/Usuarios/David Estrada/Documents/GitHub/Sonic_Public/App/Project/data/Resources/Sonic_Spritesheet.png");

  // Cargar el fondo (la imagen del mapa de colisiones) con su tamaño original
  backgroundImage = loadImage("D:/Usuarios/David Estrada/Documents/GitHub/Sonic_Public/App/Project/data/Resources/Map.png");

  // Cargar el mapa de colisiones
  loadCollisionMap("D:/Usuarios/David Estrada/Documents/GitHub/Sonic_Public/App/Project/data/Matriz.csv");
}

void draw() {
  background(255); // Limpia la pantalla

  // Dibujar el fondo del mapa en su tamaño original (3072x435)
  image(backgroundImage, 0, 0); // No redimensionar, dibujar con sus dimensiones originales

  // Actualizar la animación
  frameCounter++;
  if (frameCounter >= frameDelay) {
    frameCounter = 0;
    nextFrame();
  }

  // Dibujar el personaje con la animación
  drawCharacter();

  // Aplicar gravedad
  speedY += gravity;

  // Colisiones
  basicCollision();

  // Actualizar posición
  worldX += speedX;
  worldY += speedY;
}

// Función para cargar el mapa de colisiones desde un archivo CSV
void loadCollisionMap(String Matriz) {
  String[] lines = loadStrings(Matriz);
  collisionMap = new int[lines.length][]; 
  for (int i = 0; i < lines.length; i++) {
    String[] values = split(lines[i], ',');
    collisionMap[i] = new int[values.length];
    for (int j = 0; j < values.length; j++) {
      collisionMap[i][j] = int(values[j]);
    }
  }
}

// Dibuja el mapa de colisiones en pantalla para referencia
void drawCollisionMap() {
  for (int y = 0; y < collisionMap.length; y++) {
    for (int x = 0; x < collisionMap[y].length; x++) {
      if (collisionMap[y][x] == 1) {
        fill(0); // Negro para celdas sólidas
      } else {
        fill(200); // Gris claro para celdas vacías
      }
      rect(x * charSize, y * charSize, charSize, charSize);
    }
  }
}

// Función para dibujar al personaje
void drawCharacter() {
  int sx = currentAnimation[currentFrame][0] * spriteWidth; // Cuadro X
  int sy = currentAnimation[currentFrame][1] * spriteHeight; // Cuadro Y
  PImage frame = spriteSheet.get(sx, sy, spriteWidth, spriteHeight); // Obtener el cuadro de la hoja de sprites
  
  // Si Sonic es una bolita, dibujar con el tamaño más pequeño
  if (isBall) {
    image(frame, worldX - charSize / 2, worldY - charSize / 2, charSize * 0.7, charSize * 0.7); // Reducir tamaño para hacerlo más pequeño
  } else {
    image(frame, worldX - charSize / 2, worldY - charSize / 2, charSize, charSize); // Tamaño normal
  }
}

// Cambiar al siguiente cuadro de la animación
void nextFrame() {
  currentFrame = (currentFrame + 1) % currentAnimation.length;
}

// Cambiar la animación actual
void setAnimation(int[][] newAnimation) {
  if (currentAnimation != newAnimation) {
    currentAnimation = newAnimation;
    currentFrame = 0;
  }
}

void keyPressed() {
  // Movimiento horizontal
  if (key == 'a') {
    speedX = -5;  // Mover a la izquierda
    setAnimation(walkFrames);  // Cambiar a la animación de caminar
  } else if (key == 'd') {
    speedX = 5;  // Mover a la derecha
    setAnimation(walkFrames);  // Cambiar a la animación de caminar
  }

  // Salto
  if ((key == 'w' || key == ' ') && !isJumping) {  // Solo saltar si está en el suelo
    speedY = -40;  // Ajustado para que suba 40 píxeles
    isJumping = true;
    setAnimation(jumpFrames);  // Cambiar a la animación de salto
  }

  // Transformarse en bolita
  if (key == 's') {
    isBall = true;  // Sonic se hace bolita
    setAnimation(ballHoldFrames);  // Cambiar a la animación de bolita (asegúrate de que esté bien definida en la hoja de sprites)
  }
}

void keyReleased() {
  // Movimiento horizontal
  if (key == 'a' || key == 'd') {
    speedX = 0;  // Detener movimiento horizontal
    if (speedY == 0 && !isBall) {
      setAnimation(idleFrames);  // Volver a la animación de reposo si no se está saltando ni en bolita
    }
  }

  // Si se suelta la tecla 's', dejar de ser bolita
  if (key == 's') {
    isBall = false;  // Sonic deja de ser bolita
    if (speedY == 0) {
      setAnimation(idleFrames);  // Volver a la animación de reposo
    }
  }
}

// Función básica de colisión
void basicCollision() {
  // Chequeo de colisión con el suelo
  if (isSolid(worldX, worldY + charSize / 2)) {
    speedY = 0; // Detener el movimiento en Y si hay colisión
    isJumping = false;
  }

  // Chequeo de colisión en los lados izquierdo y derecho
  if (speedX > 0 && isSolid(worldX + charSize / 2, worldY)) { // Colisión derecha
    speedX = 0;
  } else if (speedX < 0 && isSolid(worldX - charSize / 2, worldY)) { // Colisión izquierda
    speedX = 0;
  }
}

// Función para verificar si una posición está en una celda sólida
boolean isSolid(float x, float y) {
  int mapX = int(x / charSize);
  int mapY = int(y / charSize);
  if (mapX >= 0 && mapX < collisionMap[0].length && mapY >= 0 && mapY < collisionMap.length) {
    return collisionMap[mapY][mapX] == 1;
  }
  return false;
}
