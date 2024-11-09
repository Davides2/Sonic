import ddf.minim.*;

PImage backgroundImage;  // Imagen de fondo
PImage spriteSheet;  // Sprite sheet del personaje

AudioPlayer song;
Minim minim;

// Variables para el mapa
int mapWidth = 10420;  // Ancho total del mapa
int mapHeight = 1240;  // Altura total del mapa
int mapOffsetX = 0;  // Desplazamiento horizontal del mapa
int mapOffsetY = 0;  // Desplazamiento vertical del mapa

// Variables para el personaje
float worldX = 100;  // Posición inicial del personaje en el mapa (ahora empieza a 100px del borde)
float worldY = 0;  // Posición inicial del personaje en el mapa (empezará ligeramente por debajo de la altura media en Y)
float charSize = 55;  // Tamaño del personaje
float speedX = 0;  // Velocidad de movimiento horizontal del personaje
float speedY = 0;  // Velocidad vertical del personaje
float gravity = 0.5;  // Gravedad
float jumpStrength = -10; // Fuerza del salto
float groundLevel = 570; // Altura donde empieza el suelo
boolean isJumping = false;  // ¿El personaje está saltando?

// Animaciones del personaje (Las coordenadas X, Y en la hoja de sprites)
int[][] jumpFrames = { {0, 6}, {1, 3}, {2, 3}, {3, 3}, {1, 3}, {0, 0} };
int[][] walkFrames = { {4, 0}, {5, 0}, {6, 0}, {7, 0}, {8, 0} };
int[][] ballStartFrames = { {0, 3}, {1, 3}, {2, 3}, {3, 3}, {4, 3} };
int[][] ballHoldFrames = { {5, 3}, {6, 3}, {7, 3}, {8, 3} };
int[][] sprintFrames = { {7, 1}, {8, 1}, {0, 2}, {1, 2} };
int[][] idleFrames = { {0, 0}, {1, 0}, {2, 0} };
int[][] pushFrames = { {0, 4}, {1, 4}, {2, 4}, {3, 4} };

// Variables para animaciones
int[][] currentAnimation = idleFrames;  // Animación actual
int currentFrame = 0;  // Frame actual de la animación
int frameDelay = 5;   // Retardo entre frames
int frameCounter = 0;  // Contador de frames

// Variables para el mapa
int mapYOffset = 100;  // Desplazamiento adicional del mapa para moverlo hacia abajo
float mapSpeedFactor = 1.5;  // Factor de velocidad para que el mapa se mueva más rápido que el personaje
float ballSpeedFactor = 1;  // Factor de velocidad para que el personaje se mueva más lento que el mapa

void setup() {
  size(1240, 640);  // Tamaño de la ventana

  // Cargar la imagen de fondo y el sprite sheet de Sonic
  backgroundImage = loadImage("Sonic_Map_L1.png");
  spriteSheet = loadImage("Sonic_Spritesheet.png");

  if (backgroundImage == null || spriteSheet == null) {
    println("Error al cargar las imágenes.");
    exit();
  }

  // Colocar el personaje justo encima del nivel del suelo
  worldX = 100;  // En el borde izquierdo del mapa pero desplazado 100px
  worldY = groundLevel - charSize / 2;  // Colocar al personaje en el suelo, ajustado a su tamaño
  
  //Música
  minim = new Minim(this);
  song = minim.loadFile("music.mp3");
  song.play();
  
}

void draw() {
  background(255);

   // Mover el mapa solo cuando el personaje "intenta" moverse
  mapOffsetX += speedX * mapSpeedFactor;  // El mapa se mueve, no el personaje

  // Limitar el desplazamiento del mapa para que no se salga del borde
  mapOffsetX = constrain(mapOffsetX, 0, mapWidth - width);  // Mantener el mapa dentro de los límites
  mapOffsetY = constrain(mapOffsetY, 0, mapHeight - height); // Ajuste vertical del mapa

  // Dibujar solo la sección visible del fondo
  if (backgroundImage != null) {
    image(backgroundImage, -mapOffsetX, -mapOffsetY, mapWidth, mapHeight);
  }

  // Ajustar la posición vertical del mapa para moverlo 50px hacia abajo
  mapOffsetY = int(worldY - height / 2) + mapYOffset; // Centrar el mapa en el personaje (vertical) y moverlo hacia abajo

  // Limitar el desplazamiento del mapa para que no se salga del mapa
  mapOffsetX = constrain(mapOffsetX, 0, mapWidth - width);  // Evita que el mapa se desplace fuera del borde izquierdo/derecho
  mapOffsetY = constrain(mapOffsetY, 0, mapHeight - height); // Evita que el mapa se desplace fuera del borde superior/inferior

  // Dibujar solo la sección visible del fondo
  if (backgroundImage != null) {
    image(backgroundImage, -mapOffsetX, -mapOffsetY, mapWidth, mapHeight);
  }

  // Dibujar el personaje con la animación actual
  drawCharacter();

  // Actualizar la animación
  frameCounter++;
  if (frameCounter >= frameDelay) {
    frameCounter = 0;
    nextFrame();
  }

  // Actualizar la física del personaje (gravedad)
  updatePhysics();
}

void drawCharacter() {
  int sx = currentAnimation[currentFrame][0] * 50;  // X en la hoja de sprites
  int sy = currentAnimation[currentFrame][1] * 49;  // Y en la hoja de sprites
  PImage frame = spriteSheet.get(sx, sy, 50, 49);  // Obtener el frame actual del sprite sheet
  image(frame, worldX - charSize / 2, worldY - charSize / 2, charSize, charSize);  // Dibujar el sprite
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
  // Movimiento horizontal del personaje (cuando se presiona una tecla)
  if (key == 'a') {
    speedX = -5;  // Velocidad hacia la izquierda
    setAnimation(walkFrames);  // Cambiar a animación de caminar
  } else if (key == 'd') {
    speedX = 5;  // Velocidad hacia la derecha
    setAnimation(walkFrames);  // Cambiar a animación de caminar
  }

  // Movimiento vertical del personaje
  if (key == 'w') {
    if (worldY == groundLevel) {  // Solo saltar si está en el suelo
      speedY = jumpStrength;  // Aplicar la fuerza del salto inicial
      setAnimation(jumpFrames);  // Cambiar a animación de salto
    } else if (speedY < 0) {  // If Sonic is still rising, allow a boost
      speedY += jumpStrength / 2;  // Small boost for a higher jump
    }
  } else if (key == 's') {
    setAnimation(ballStartFrames);  // Animación de transformación a bolita
  } else if (key == 'r') {
    setAnimation(sprintFrames);  // Animación de sprint
  } else if (key == 'f') {
    setAnimation(ballHoldFrames);  // Animación de bolita mantenida
  } else if (key == 'p') {
    setAnimation(pushFrames);  // Animación de empuje
  }
}

void keyReleased() {
  // Detener el movimiento horizontal cuando se suelta la tecla
  if (key == 'a' || key == 'd') {
    speedX = 0;  // Detener el movimiento horizontal
    if (speedY == 0) {
      setAnimation(idleFrames);  // Cambiar a animación idle
    }
  } else if (key == 'w') {
    if (speedY == 0) {
      setAnimation(idleFrames);  // Regresar a la animación idle después de saltar
    }
  } else if (key == 'r') {
    setAnimation(idleFrames);  // Regresar a la animación idle
  } else if (key == 's') {
    setAnimation(idleFrames);  // Regresar a la animación idle
  } else if (key == 'f') {
    setAnimation(idleFrames);  // Regresar a la animación idle
  } else if (key == 'p') {
    setAnimation(idleFrames);  // Regresar a la animación idle
  }
}

void updatePhysics() {
  
  // Aplicar gravedad cuando el personaje está saltando
  if (worldY < groundLevel) {
    speedY += gravity;  // Aumentar la velocidad de caída por gravedad
    worldY += speedY;  // Actualizar la posición en Y
  } else {
    // El personaje toca el suelo
    worldY = groundLevel;  // Mantenerlo en el suelo
    speedY = 0;  // Detener la velocidad vertical
  }
}
