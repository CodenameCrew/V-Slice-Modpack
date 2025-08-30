// the purpose of this is for every global cutscenes like double pico's one  - Nex

public var globalCutscenePath:String = null;

public function freeplayCutscene(path:String)
{
    playCutscenes = !inCutscene;
    return startCutscene("", Paths.script("data/scripts/global-cutscenes/" + path), disableGlobalCutscene, true);
}

public function disableGlobalCutscene()
{
    disableScript();
    startCountdown();
}

function create()
{
    if (boyfriend.curCharacter == "pico" && dad.curCharacter == "pico") globalCutscenePath = "doppleganger-pico";
    else if(curSong == 'stress' && PlayState.variation =='pico') globalCutscenePath = "startStressPicoCut";
    //else // Add other global cutscenes here!
}

function postCreate()
    if (globalCutscenePath != null) freeplayCutscene(globalCutscenePath);

function onStartCountdown(e) if (globalCutscenePath != null)
{
    _startCountdownCalled = false;
    e.cancelled = true;
}