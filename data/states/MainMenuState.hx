import flixel.FlxObject;

function postCreate() {
    for(bg in [bg,magenta]){
        bg.scrollFactor.x = 0; 
        bg.scrollFactor.y = 0.17;
        bg.setGraphicSize(Std.int(FlxG.width * 1.2));
        bg.updateHitbox();
        bg.screenCenter();
    }
    
    camFollow = new FlxObject(camFollow, 0, 1, 1);

    var spacing = 160;
    var top = (FlxG.height - (spacing * (menuItems.length - 1))) / 2;
    for (i in 0...menuItems.length)
    {
      var menuItem = menuItems.members[i];
      menuItem.x = FlxG.width / 2;
      menuItem.y = top + spacing * i;
      menuItem.scrollFactor.x = 0;
      menuItem.scrollFactor.y = 0.4;

      if (i == 1)
      {
        camFollow.setPosition(menuItem.getGraphicMidpoint().x, menuItem.getGraphicMidpoint().y);
      }
    }
    camFollow.y = bg.getGraphicMidpoint().y;
    FlxG.camera.follow(camFollow, null, 0.06);

}