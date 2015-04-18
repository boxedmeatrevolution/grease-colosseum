void setup () {
  size(600, 400);
}

void draw () {
  if(audioFilesLoaded < 1) {
    text("Files loaded " + audioFilesLoaded, 100, 100);
    loadAudio("helloworld", "assets/music.ogg"); 
  } else {
    ellipse(295, 155, 10, 10);
    playSound("helloworld");
  }
}


