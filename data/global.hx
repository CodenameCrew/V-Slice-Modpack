import funkin.backend.system.framerate.Framerate;

import haxe.io.Path;
import Type;

var modInitialized:Bool = false;

import funkin.options.PlayerSettings;
var controls = PlayerSettings.solo.controls;

function initialize() {
	// Initialize Handle of hxvlc so it doesn't crash on loading the videos.
	try {
		import hxvlc.util.Handle;
		Handle.init([]);
	}
	catch(e:Any) {trace(e);}
}

function checkInitialize() {
	if (modInitialized) return;
	modInitialized = true;
	initialize();
}

function new() if (Framerate.instance != null) checkInitialize();

function preStateSwitch() {
	checkInitialize();
}

public static var freeplayCurCharacter = 'bf';

/*
 * gets all addon overrides of a file (idk how 2 explain it)
 * rn only meant for text/data files
 * please credit if used outside of this project ok thx
 */
import funkin.backend.assets.ModsFolder;
public static function getAddonFileContents(path:String, ?options) {
	options ??= {baseFirst: true};
	var contents = [];
	var array = ModsFolder.getLoadedMods();
	if (options.noBase || options.baseFirst) {
		array.remove(ModsFolder.currentModFolder, true);
		if (options.baseFirst) array.insert(0, ModsFolder.currentModFolder);
	}
	if (options.reverse) array.reverse();
	for (i in array) {
		var p = Path.withoutExtension(path);
		var e = Path.extension(path);
		var libPath = p + '/LIB_' + i + (e.length > 0 ? ('.' + e) : '');
		if (Assets.exists(libPath)) {
			//trace('exists', libPath);
			contents.push(Assets.getText(libPath));
		}
	}
	return contents;
}

function destroy() {
	modInitialized = false;
}

// DEBUG AREA CODES ONLY
import funkin.backend.scripting.GlobalScript;
import funkin.backend.system.Logs;
import funkin.backend.system.MainState;
import funkin.backend.MusicBeatState;

function onScriptCreated(script:Script, type:String) {
	/*Logs.traceColored([
		Logs.logText('SCRIPT CREATED: ', 9),
		Logs.logText(type + ", " + script.path)
	]);*/
}

var restart;
function update() {
	if (FlxG.keys.justPressed.F6) Options.autoPause = FlxG.autoPause = !FlxG.autoPause;
	if (controls.DEV_RELOAD && FlxG.keys.pressed.CONTROL && !FlxG.keys.pressed.SHIFT) {
		restart = true;
		GlobalScript._lastAllow_Reload = MusicBeatState.ALLOW_DEV_RELOAD;
		MusicBeatState.ALLOW_DEV_RELOAD = false;
		FlxG.switchState(new MainState());
	}
}

function postUpdate() {
	if (restart) {
		restart = false;
		MusicBeatState.ALLOW_DEV_RELOAD = GlobalScript._lastAllow_Reload;
	}
}

