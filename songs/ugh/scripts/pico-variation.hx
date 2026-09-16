import funkin.backend.utils.XMLUtil;
import animate.FlxAnimateFrames;
if (PlayState.variation != 'pico') return disableScript();

function create() {
    if (dad.curCharacter == 'tankman') {
        dad.frames = FlxAnimateFrames._combineAtlas(dad.frames, Paths.getFrames('characters/tankman/extra-animations'));
        // readd anims (maybe make this an util function later???)
        for(node in dad.xml.elements()) {
			if (node.nodeName == 'anim') {
                if (dad.defaultAimFPS != 24){
                    if (node.get("fps") == null) {
                        node.set('fps', Std.string(dad.defaultAimFPS));
                    } 
                    
                }
                if (node.get("isAnimate") == null) {
                    node.set('isAnimate', 'false');
                }

                XMLUtil.addXMLAnimation(dad, node);
			}
		}
        for (i in ['beat it', 'laugh', 'argh']) {
            dad.anim.addByFrameLabel(i, i, 24, false, true /* WHYYY do i have to flip it */);
            dad.addOffset(i, 210, 95);
        }

        dad.postStageMatrixApply = false; // otherwise he teleports very far
        dad.fixChar(dad.__switchAnims, dad.xml.get('interval') == null);
        dad.dance();

        dad.x -= 100; // why does he do that
    }
}