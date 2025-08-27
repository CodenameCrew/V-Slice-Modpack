function changeTankman(){
        importScript('data/scripts/dropshadow-effect');

        var index = members.indexOf(dad);

        remove(dad);
        dad = new Character(dad.x, dad.y, "tankman-bloody", false, true);
        dad.playAnim('redheads', true);
        var dropShadow = getDropShadow(dad);
	    dropShadow.color = 0xDFEF3C; // the color for your drop shadow
	    dropShadow.angle = 135; // the angle for your drop shadow
        dropShadow.baseBrightness = -46;
        dropShadow.baseHue = -38;
        dropShadow.baseContrast = -25;
        dropShadow.baseSaturation = -20;
        dropShadow.threshold = 0.3;
        dropShadow.loadAltMask(Paths.image("stages/tank/erect/masks/tankmanCaptainBloody_mask"));
        insert(index, dad);
}

function changeIcon()
    iconP2.setIcon("tankman-bloody");