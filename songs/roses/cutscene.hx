import funkin.game.PlayState;

function create() {
  PlayState.instance.startCutscene('pico-');
}
function onSongStart(){
  seenCutscene = true; //just makin sure yk?
}