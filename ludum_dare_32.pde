var filesLoaded = 0;

var mySound;

void setup () {
  size(600, 400);
}

void draw () {
  if(((int) filesLoaded) < 1) {
    text("Files loaded " + ((int) filesLoaded), 100, 100);
    mySound = loadAudio("assets/music.ogg"); 
  } else {
    ellipse(295, 155, 10, 10);
    mySound.play();
  }
}

function loadAudio(var uri)
{
    var audio = new Audio();
    audio.addEventListener("canplaythrough", fileLoaded, false); // It works!!
    audio.src = uri;
    return audio;
}

function fileLoaded()
{
    filesLoaded++;
}
