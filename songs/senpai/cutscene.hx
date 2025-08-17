import funkin.game.PlayState;

function create() {
  if(PlayState.instance.boyfriend.curCharacter == 'pico-pixel'){
    PlayState.instance.startCutscene('pico-');
  }
}
function onSongStart(){
  seenCutscene = true; //just makin sure yk?
}