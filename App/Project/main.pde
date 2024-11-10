PImage spriteSheet; // Hoja de sprites de Sonic
PImage backgroundImage; // Imagen de fondo (el mapa de colisiones)
int spriteWidth = 50; // Ancho de cada sprite
int spriteHeight = 49; // Alto de cada sprite
int scene = 0;
PImage fondo;
Button botónjugar, botónopciones, botónsalir;
PFont fuentePrincipal, fuenteOpciones, fuenteSalir, fuenteJugar;

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

void setup() {
  size(720, 435); // Tamaño de la ventana
  
  fondo = loadImage("fondosonic.png");
  fuentePrincipal = createFont("Arial", 24);
  fuenteJugar = createFont("Arial", 24);
  fuenteOpciones = createFont("Arial", 24);
  fuenteSalir = createFont("Arial", 24);
  
  botónjugar = new Button(width/2 - 50, height/2 - 30, 100, 40, "Jugar", fuenteJugar);
  botónopciones = new Button(width/2 - 75, height/2 + 20, 150, 40, "Opciones", fuenteOpciones);
  botónsalir = new Button(width/2 - 50, height/2 + 70, 100, 40, "Salir", fuenteSalir);

  // Cargar la hoja de sprites de Sonic
  spriteSheet = loadImage("Sonic_Spritesheet.png");

  // Cargar el fondo (la imagen del mapa de colisiones) con su tamaño original
  backgroundImage = loadImage("Map.png");

  // Cargar el mapa de colisiones
  loadCollisionMap("Matriz.csv");
}

void draw() {
  background(255); // Limpia la pantalla
  
  if (scene == 0) {
    mainMenu();
  } else if (scene == 1) {
    gameScreen();
  } else if (scene == 2) {
    optionsScreen();
  }

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
  
}

void mainMenu() {
  image(fondo, 0, 0, width, height);
  textAlign(CENTER);
  drawTextWithOutline("¡Bienvenido al juego!", width/2, 120, color(255, 217, 47), color(26, 91, 203), 3);
  botónjugar.display();
  botónopciones.display();
  botónsalir.display();
}

void gameScreen() {
  background(255);
  image(backgroundImage, -mapOffsetX, 0);

  frameCounter++;
  if (frameCounter >= frameDelay) {
    frameCounter = 0;
    nextFrame();
  }
  drawCharacter();
  speedY += gravity;
  mapOffsetX += speedX * mapSpeedFactor;
  worldY += speedY;

  fill(255);
  textAlign(CENTER);
  textSize(16);
  text("Presiona 'M' para regresar al menú", width/2, height - 30);
}

void optionsScreen() {
  background(100, 100, 255);
  textAlign(CENTER);
  textSize(32);
  text("Opciones", width/2, height/2);
}

void mousePressed() {
  if (scene == 0) {
    if (botónjugar.isMouseOver()) {
      scene = 1;
    } else if (botónopciones.isMouseOver()) {
      scene = 2;
    } else if (botónsalir.isMouseOver()) {
      exit();
    }
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
  
  //Volver al menú
  if (key == 'm' || key == 'M') {
    scene = 0; 
  }
  
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

class Button {
  float x, y, w, h;
  String label;
  PFont fuente;

  Button(float tempX, float tempY, float tempW, float tempH, String tempLabel, PFont tempFuente) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    label = tempLabel;
    fuente = tempFuente;
  }

  void display() {
    if (isMouseOver()) {
      fill(200);
    } else {
      fill(150);
    }
    rect(x, y, w, h);
    fill(0);
    textAlign(CENTER, CENTER);
    textFont(fuente);
    text(label, x + w / 2, y + h / 2);
  }

  boolean isMouseOver() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}

void drawTextWithOutline(String txt, float x, float y, color textColor, color outlineColor, float outlineThickness) {
  textFont(fuentePrincipal);
  textAlign(CENTER);
  
  fill(outlineColor);
  for (float dx = -outlineThickness; dx <= outlineThickness; dx += 1) {
    for (float dy = -outlineThickness; dy <= outlineThickness; dy += 1) {
      text(txt, x + dx, y + dy);
    }
  }

  fill(textColor);
  text(txt, x, y);
}
