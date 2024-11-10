import ddf.minim.*;

AudioPlayer song;
Minim minim;

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

int mapWidth = 3072;  // Ancho total del mapa
int mapHeight = 435;  // Altura total del mapa
int mapOffsetX = 0;  // Desplazamiento horizontal del mapa
int mapOffsetY = 0;  // Desplazamiento vertical del mapa
float mapSpeedFactor = 1.5;  // Factor de velocidad para que el mapa se mueva más rápido que el personaje
float ballSpeedFactor = 1;  // Factor de velocidad para que el personaje se mueva más lento que el mapa

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

//Instancia única de un enemigo
Enemy enemy;

void setup() {
  size(720, 435); // Tamaño de la ventana
  
  //Música
  minim = new Minim(this);
  song = minim.loadFile("music.mp3");
  song.play();

  // Cargar la hoja de sprites de Sonic
  spriteSheet = loadImage("Sonic_Spritesheet.png");

  // Cargar el fondo (la imagen del mapa de colisiones) con su tamaño original
  backgroundImage = loadImage("Map.png");

  // Cargar el mapa de colisiones
  loadCollisionMap("Matriz.csv");
  
    // Inicializar el enemigo en una posición inicial
  enemy = new Enemy(300, 100);
  
}

void draw() {
  background(255); // Limpia la pantalla

  // Dibujar el fondo del mapa en su tamaño original (3072x435)
  image(backgroundImage, -mapOffsetX, -mapOffsetY);

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

  // Mover el mapa 
  mapOffsetX += speedX * mapSpeedFactor;  // El mapa se mueve, no el personaje
  worldY += speedY;
  // Limitar el desplazamiento del mapa para que no se salga del borde
  mapOffsetX = constrain(mapOffsetX, 0, mapWidth - width);  // Mantener el mapa dentro de los límites
  mapOffsetY = constrain(mapOffsetY, 0, mapHeight - height); // Ajuste vertical del mapa
  
  // Actualizar y dibujar al enemigo
  enemy.update();
  enemy.display();
  
}

class Enemy {
  float worldX, worldY;  // Posición del enemigo en el mundo
  float width = 32;  // Ancho del enemigo
  float height = 32;  // Alto del enemigo
  float speedX = 2;  // Velocidad horizontal del enemigo
  float speedY = 0;  // Velocidad vertical del enemigo
  float gravity = 0.5;  // Gravedad aplicada al enemigo
  boolean isJumping = true;  // Indica si el enemigo está en el aire

  // Constructor para inicializar la posición inicial del enemigo
  Enemy(float startX, float startY) {
    worldX = startX;
    worldY = startY;
  }

  // Método para actualizar el estado del enemigo
  void update() {
    // Aplicar gravedad
    speedY += gravity;

    // Verificar colisiones y actualizar posición
    basicCollision();

    // Movimiento horizontal
    worldX += speedX;
    worldY += speedY;
  }

  // Método para dibujar al enemigo en función del desplazamiento del mapa
  void display() {
    // Ajustar la posición de renderizado según el desplazamiento del mapa
    float screenX = worldX - mapOffsetX;
    float screenY = worldY - mapOffsetY;
    fill(255, 0, 0);  // Color rojo para el enemigo
    rect(screenX - width / 2, screenY - height / 2, width, height);  // Dibujar el enemigo como un rectángulo
  }

  // Función básica de colisión del enemigo
  void basicCollision() {
    if (speedY > 0 && isSolid(worldX, worldY + charSize / 2 + speedY)) {
    speedY = 0; // Detener la velocidad en Y cuando haya colisión
    isJumping = false;
    // Ajustar la posición de Sonic para que se quede justo sobre el suelo
    worldY = (int((worldY + charSize / 2) / charSize)) * charSize - charSize / 2;
  } else {
    isJumping = true;
  }
    // Colisiones laterales
    if (speedX > 0 && isSolid(worldX + width / 2 + speedX, worldY)) {  // Colisión derecha
      speedX *= -1;  // Cambia de dirección
    } else if (speedX < 0 && isSolid(worldX - width / 2 + speedX, worldY)) {  // Colisión izquierda
      speedX *= -1;  // Cambia de dirección
    }
  }

  // Función para verificar si una posición está en una celda sólida
  boolean isSolid(float checkX, float checkY) {
    int mapX = int(checkX / charSize);
    int mapY = int(checkY / charSize);
    if (mapX >= 0 && mapX < collisionMap[0].length && mapY >= 0 && mapY < collisionMap.length) {
      return collisionMap[mapY][mapX] == 1;
    }
    return false;
  }
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
  if ((key == 'w' || key == 'W') && !isJumping) {  // Solo saltar si está en el suelo
    speedY = -8;
    worldY = worldY - 50;
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
  // Detener el movimiento horizontal cuando se suelta la tecla
  if (key == 'a' || key == 'd') {
    speedX = 0;  // Detener el movimiento horizontal     
    setAnimation(idleFrames);  // Cambiar a animación idle
      
  } else if (key == 'w') {
      if (speedY == 0) {
        setAnimation(idleFrames);  // Regresar a la animación idle después de saltar
      }
  } else if (key == 'r') {
      setAnimation(idleFrames);  // Regresar a la animación idle
  } else if (key == 's') {
      isBall = false;
      setAnimation(idleFrames);  // Regresar a la animación idle
  } else if (key == 'f') {
      setAnimation(idleFrames);  // Regresar a la animación idle
  } else if (key == 'p') {
      setAnimation(idleFrames);  // Regresar a la animación idle
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

boolean isSolid(float x, float y) {
  // Ajustar las coordenadas con el desplazamiento del mapa
  float adjustedX = x + mapOffsetX;
  float adjustedY = y + mapOffsetY;

  // Convertir las coordenadas ajustadas a índices de la matriz de colisiones
  int mapX = int(adjustedX / charSize);
  int mapY = int(adjustedY / charSize);

  // Comprobar si los índices están dentro del rango del mapa
  if (mapX >= 0 && mapX < collisionMap[0].length && mapY >= 0 && mapY < collisionMap.length) {
    return collisionMap[mapY][mapX] == 1;
  }
  return false;
}
