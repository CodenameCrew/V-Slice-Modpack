var self = this;
__script__.setParent(PlayState.instance);

function create() {
  if(PlayState.instance.boyfriend.curCharacter == 'pico-pixel'){
    self.close();
  }
}