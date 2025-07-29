if (!Options.gameplayShaders)
{
    disableScript();
}

import funkin.backend.shaders.WiggleEffect;
import funkin.backend.shaders.WiggleEffect.WiggleEffectType;

var wiggle:WiggleEffect = new WiggleEffect();

function create()
{
    wiggle.waveSpeed = 2 * 0.8;
    wiggle.waveFrequency = 4 * 0.4;
    wiggle.waveAmplitude = 0.011;
    wiggle.effectType = WiggleEffectType.DREAMY;

    for (bg in stage.stageSprites)
    {
        bg.shader = wiggle.shader;
    }
}

function update(elapsed:Float)
{
    if (wiggle == null) return;
    wiggle.update(elapsed);
}