import funkin.backend.utils.XMLUtil;
import animate.FlxAnimateFrames;
if (PlayState.variation != 'pico') return disableScript();

function postCreate() {
    if (dad.curCharacter == 'tankman') {
		// have to do this (make whole new frames) otherwise it crashes on restart song
        dad.frames = Paths.getMultiFrames([
            'characters/tankman',
            'characters/tankman/extra-animations'
        ], false, true); // readd anims (maybe make this an util function later???)
        for(node in dad.xml.elements()) {
			if (node.nodeName == 'anim') {
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