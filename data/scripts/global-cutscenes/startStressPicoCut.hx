var timers:Array<FlxTimer> = [];

var game = PlayState.instance;

var tankStartCut, picoStartCut, speakerStartCut:FunkinSprite;

var camera = FlxG.camera;

var audio:FlxSound = FlxG.sound.load(Paths.sound('cutscenes/pico/stress_cutscene'));

var shaders:Array<Dynamic> = [];
var shaderCameras:Array<FlxCamera> = [];

function create(){
	  var dad = game.dad;
	  var boyfriend = game.boyfriend;
	  var gf = game.gf;

	  camera.followEnabled = false;

	  camera.scroll.set(gf.x - 150, gf.y - 50);
	  camera.zoom = 0.65;

      game.camHUD.visible = dad.visible = boyfriend.visible = gf.visible = false;
      tankStartCut = new FunkinSprite(dad.x - 50, dad.y + 165, Paths.image('stages/tank/erect/cutscene/stressStart/tankman'));
      tankStartCut.antialiasing = true;
      tankStartCut.animateAtlas.anim.addBySymbol("tankman cutscene", "tankman cutscene", 0, false);
      tankStartCut.playAnim("tankman cutscene");

      picoStartCut = new FunkinSprite(boyfriend.x - 289, boyfriend.y + 220, Paths.image('stages/tank/erect/cutscene/stressStart/pico'));
      picoStartCut.antialiasing = true;
      picoStartCut.animateAtlas.anim.addBySymbol("pico cutscene", "pico cutscene", 0, false);
      picoStartCut.playAnim("pico cutscene");

      speakerStartCut = new FunkinSprite(gf.x - 115, gf.y - 853, Paths.image('stages/tank/erect/cutscene/stressStart/speakers'));
      speakerStartCut.antialiasing = true;
      speakerStartCut.animateAtlas.anim.addBySymbol("speakers cutscene", "speakers cutscene", 0, false);
      speakerStartCut.playAnim("speakers cutscene");

	  for(thing in [tankStartCut, picoStartCut, speakerStartCut]){
		var dropShadow = getDropShadowScreenspace();
		var shaderCamera:FlxCamera = new FlxCamera();

		dropShadow.baseBrightness = -46;
    	dropShadow.baseHue = -38;
    	dropShadow.baseContrast = -25;
    	dropShadow.baseSaturation = -20;

		if(thing == tankStartCut){
    		dropShadow.angle = 45;
    		dropShadow.threshold = 0.3;
			dropShadow.color = 0xDFEF3C;
		} else if (thing == picoStartCut){
    		dropShadow.angle = 90;
    		dropShadow.threshold = 0.1;
			dropShadow.color = 0xDFEF3C;
		}

			thing.cameras = [shaderCamera];
			shaders.push(dropShadow);
			FlxG.cameras.insert(shaderCamera, 1, false);
    		shaderCamera.bgColor = 0x00FFFFFF;
			shaderCamera.addShader(dropShadow.shader);
			shaderCameras.push(shaderCamera);
	  }

      add(speakerStartCut);
      add(picoStartCut);
      add(tankStartCut);

	  audio.play();

	  camera.flash(FlxColor.BLACK, 9/24);

	  FlxTween.tween(camera, {zoom: 0.67}, 6.1);

	  var cameraStartPos:Array<Float> = [camera.scroll.x, camera.scroll.y];

	  timer(6.12, function(){
		FlxTween.tween(camera, {zoom: 1.05, "scroll.y": cameraStartPos[1] - 144, "scroll.x": cameraStartPos[0] + 16}, 1.16, {ease: FlxEase.quadOut});
	  });

	  timer(8.5, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - 10}, 0.48, {ease: FlxEase.quadOut});
	  });

	  timer(11.2, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - 40, "scroll.y": cameraStartPos[1] - 296, zoom: 0.9}, 0.6, {ease: FlxEase.quadIn});
	  });
	  timer(11.8, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - 48, "scroll.y": cameraStartPos[1] - 595, zoom: 0.73}, 0.5, {ease: FlxEase.quadOut});
	  });
	  timer(12.45, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - 2, "scroll.y": cameraStartPos[1] - 536}, 1);
	  });
	  timer(12.45 + 1/24 + 1, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] + 2, "scroll.y": cameraStartPos[1] - (501 - 47)}, 1/24);
		FlxTween.tween(camera, {zoom: 2}, 11/24, {ease: FlxEase.quadOut});
	  });
	  timer(12.45 + 2/24 + 1, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 977), "scroll.y": cameraStartPos[1] - (501 - 111)}, 1/24);
	  });
	  timer(12.45 + 3/24 + 1, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 1011), "scroll.y": cameraStartPos[1] - (501 - 259)}, 1/24);
	  });
	  timer(12.45 + 4/24 + 1, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 1053), "scroll.y": cameraStartPos[1] - (501 - 352)}, 1/24);
	  });
	  timer(12.45 + 5/24 + 1, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 1266), "scroll.y": cameraStartPos[1] - (501 - 480)}, 2/24);
	  });
	  timer(12.45 + 7/24 + 1, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 1366), "scroll.y": cameraStartPos[1] - (501 - 560)}, 2/24);
	  });
	  timer(12.45 + 9/24 + 1, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 1417), "scroll.y": cameraStartPos[1] - (501 - 595)}, 2/24);
	  });
	  timer(12.45 + 11/24 + 1, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 1417), "scroll.y": cameraStartPos[1] - (501 - 595)}, 2/24);
	  });

	  timer(579/24, function(){
		FlxTween.tween(camera, {zoom: 0.9}, 29/24, {ease: FlxEase.quadOut});
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 1353.35), "scroll.y": cameraStartPos[1] - (541.5 - 625.4)}, 5/24, {ease: FlxEase.quadIn, onComplete: function(){
			FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 1060.35), "scroll.y": cameraStartPos[1] - (541.5 - 606.95)}, 3/24, {onComplete: function(){
				FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 791.25), "scroll.y": cameraStartPos[1] - (541.5 - 564.35)}, 6/24, {ease: FlxEase.quadOut, onComplete: function(){
					FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 779.3), "scroll.y": cameraStartPos[1] - (541.5 - 562.45)}, 3/24, {onComplete: function(){
						FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 773.25), "scroll.y": cameraStartPos[1] - (541.5 - 561.55)}, 5/24);
					}});
				}});
			}});
		}});
	  });
	  
	  timer(668/24, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 763.25)}, 1/24, {onComplete: function(){
			FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 733.25)}, 1/24, {onComplete: function(){
				FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 743.25)}, 2/24, {onComplete: function(){
					FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 744.25)}, 2/24, {onComplete: function(){
						FlxTween.tween(camera, {"scroll.x": cameraStartPos[0] - (957 - 745.25)}, 3/24);
					}});
				}});
			}});
		}});
	  });

	 timer(733/24, function(){
		FlxTween.tween(camera, {"scroll.x": cameraStartPos[0], "scroll.y": cameraStartPos[1], zoom: 0.65}, 60/24, {ease: FlxEase.quadInOut});
	 });

	 timer(792/24, function(){
		camera.fade(FlxColor.BLACK, 20/24);
		timer(20/24, close);
	 });
}

function timer(duration:Float, callBack:Void->Void) {
	timers.push(new FlxTimer().start(duration, function(timer) {
		timers.remove(timer);
		FlxTween.globalManager.clear();
		callBack();
	}));
}

function update(elapsed:Float) {
	for(rimlightCamera in shaderCameras){
		if (rimlightCamera != null)
      	{
			rimlightCamera.scroll = camera.scroll;
        	rimlightCamera.zoom = camera.zoom;
			for(stuff in shaders)
			stuff.curZoom = camera.zoom;
      	}
	}
}
function destroy(){
	for(things in [tankStartCut, picoStartCut, speakerStartCut])
		things.destroy();

	var camHUD = game.camHUD;
	camHUD.visible = game.dad.visible = game.boyfriend.visible = game.gf.visible = true;
	camHUD.flash(FlxColor.BLACK, 1);
	camera._fxFadeAlpha = 0;
	camera.followEnabled = true;
	audio.volume = 0;
	camera.zoom = game.defaultCamZoom;
	for(timer in timers) timer.cancel();
	for(cam in shaderCameras) FlxG.cameras.remove(cam);
}