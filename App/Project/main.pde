import ddf.minim.*; //Librería musiquita

AudioPlayer song;
Minim minim;

PImage spriteSheet; // Hoja de sprites de Sonic
PImage backgroundImage; // Imagen de fondo
int spriteWidth = 50; // Ancho de cada sprite
int spriteHeight = 49; // Alto de cada sprite
int scene = 0;
PImage fondo;
Button botónjugar, botónsalir; //Botones de la UI
PFont fuenteSalir, fuenteJugar; //Fuentes de los botones

//Animaciones
int[][] walkFrames = { {4, 0}, {5, 0}, {6, 0}, {7, 0}, {8, 0} };  //Animación caminar
int[][] jumpFrames = { {0, 6}, {1, 3}, {2, 3}, {3, 3}, {1, 3}, {0, 0} };  //Animación saltar
int[][] idleFrames = { {0, 0}, {1, 0}, {2, 0} }; // Animación idle
int[][] ballFrames = { {5, 3}, {6, 3}, {7, 3}, {8, 3} }; //Animación bolita
int[][] sprintFrames = { {7, 1}, {8, 1}, {0, 2}, {1, 2} }; //Animación correr 
int[][] currentAnimation = idleFrames; //Animación actual
int currentFrame = 0;
int frameDelay = 10;  //Velocidad de cambio de frames
int frameCounter = 0; 

//Variables del mapa
int mapWidth = 3072;  
int mapHeight = 435;  
int mapSetX = 0;  //Desplazamiento horizontal del mapa
int mapSetY = 0; 
float mapSpeed = 1.5;  //Velocidad del mapa
float charSpeed = 1;  //Velocidad del Sonic

//Variables físicas
int[][] collisionMap;
float PiX = 100; //Posición inicial de Sonic en el eje X
float PiY = 100; //Posición inicial en el eje Y
float charSize = 32; //Tamaño del Sonic
float speedX = 0; 
float speedY = 0;
float gravedad = 0.5;
boolean isJumping = false;
boolean isBall = false;  //Si Sonic es una bolita

Enemy enemy;

void setup() {
  size(720, 435); 
  
  //Musiquita
  minim = new Minim(this);
  song = minim.loadFile("music.mp3");
  song.play();
  
  fondo = loadImage("fondomenu.png");
  fuenteJugar = createFont("Consolas", 24);
  fuenteSalir = createFont("Consolas", 24);
  
  botónjugar = new Button(width/2 - 50, height/2 - 30, 100, 40, "Jugar", fuenteJugar);
  botónsalir = new Button(width/2 - 50, height/2 + 70, 100, 40, "Salir", fuenteSalir);

  spriteSheet = loadImage("Sonic_Spritesheet.png");
  backgroundImage = loadImage("Map.png");
  loadCollisionMap("Mat.csv");
  
  enemy = new Enemy(300, 100);

}

void draw() {
  
  background(255);
  
  if (scene == 0) {
    menu();
  } else if (scene == 1) {
    game();
  }

  image(backgroundImage, -mapSetX, -mapSetY);

  //Actualizar animaciones
  frameCounter++;
  if (frameCounter >= frameDelay) {
    frameCounter = 0;
    nextFrame();
  }
  drawChar();
  speedY += gravedad;
  colisiones();

  //Scroll del mapa
  mapSetX += speedX * mapSpeed; 
  PiY += speedY;
  mapSetX = constrain(mapSetX, 0, mapWidth - width);  

  //Cositas
  if (speedX == 0 && speedY == 0 && !isJumping && !isBall) {
  setAnimation(idleFrames);
  }
  
  // Actualizar y dibujar al enemigo
  enemy.update();
  enemy.display();
  
}

void menu() {
  image(fondo, 0, 0, width, height);
  textAlign(CENTER);
  botónjugar.display();
  botónsalir.display();
}

void game() {
  background(255);
  image(backgroundImage, -mapSetX, 0);

  frameCounter++;
  if (frameCounter >= frameDelay) {
    frameCounter = 0;
    nextFrame();
  }
  drawChar();
  speedY += gravedad;
  mapSetX += speedX * mapSpeed;
  PiY += speedY;

  fill(255);
  textAlign(CENTER);
  textSize(16);
  text("Presiona 'M' para regresar al menú", width/2, height - 30);
}


void mousePressed() {
  if (scene == 0) {
    if (botónjugar.isMouseOver()) {
      scene = 1;
  } else if (botónsalir.isMouseOver()) {
      exit();
    }
  }
}


//Mapa de colisiones CSV
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
    float screenX = worldX - mapSetX;
    float screenY = worldY - mapSetY;
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

//Dibujar al personaje
void drawChar() {
  int sx = currentAnimation[currentFrame][0] * spriteWidth; 
  int sy = currentAnimation[currentFrame][1] * spriteHeight; 
  PImage frame = spriteSheet.get(sx, sy, spriteWidth, spriteHeight); //Obtener el frame de la spritesheet
  
  //Si Sonic es bolita, dibujar más pequeño
  if (isBall) {
    image(frame, PiX - charSize / 2, PiY - charSize / 2, charSize * 0.7, charSize * 0.7);
  } else {
    image(frame, PiX - charSize / 2, PiY - charSize / 2, charSize, charSize); // Tamaño normal
  }
}


void nextFrame() {
  currentFrame = (currentFrame + 1) % currentAnimation.length;
}

//Cambiar la animación actual
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
  if (key == 'a' || key == 'A') {
    speedX = -3;  
    setAnimation(walkFrames);
  } else if (key == 'd' || key == 'D') {
    speedX = 3;  
    setAnimation(walkFrames);
  }

  // Salto
  if ((key == ENTER) && !isJumping) {  //Que no siga saltando y no vuele
    speedY = -8;
    PiY = PiY - 50;
    isJumping = true;
    setAnimation(jumpFrames); 
  }

  //Bolita
  if (key == 's' || key == 'S') {
    isBall = true;  
    setAnimation(ballFrames);  
    
  //Correr
} else if (key == 'c' || key == 'C') {
    setAnimation(sprintFrames);
    speedX = 5;
}
}


void keyReleased() {  
  
  if (key == 'a' || key == 'A' || key == 'd' || key == 'D') {
    speedX = 0; 
    setAnimation(idleFrames);
    if (speedY == 0) {
      setAnimation(idleFrames);
    }
} else if (key == 'r' || key == 'R') {
    setAnimation(idleFrames);  
} else if (key == 's' || key == 'S') {
    isBall = false;
    setAnimation(idleFrames); 
} else if (key == 'c' || key == 'C') {
    setAnimation(idleFrames);  
    speedX = 0;
}
} 


void colisiones() {

  //Colisión con el suelo
  if (isSolid(PiX, PiY + charSize / 2)) {
    speedY = 0; 
    if (isJumping) {
      isJumping = false;
      setAnimation(idleFrames);
    }
  }
  //Colisión a los lados
  if (speedX > 0 && isSolid(PiX + charSize / 2, PiY)) { //Derecha
    speedX = 0;
  } else if (PiX < 0 && isSolid(PiX - charSize / 2, PiY)) { //Izquierda
    speedX = 0;
  }
}

boolean isSolid(float x, float y) {
  // Ajustar las coordenadas con el desplazamiento del mapa
  float adjustedX = x + mapSetX;
  float adjustedY = y + mapSetY;

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
