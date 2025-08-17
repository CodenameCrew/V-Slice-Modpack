importScript('data/scripts/dropshadow-effect');


function create() {
    for(i in [dad,gf,boyfriend]){
        var rim = getDropShadow(i);
        rim.setAdjustColor(-66, -10, 24, -23);
        rim.antialiasAmt = 0;
        rim.color = 0xFF52351d;
        rim.attachedSprite = i;
        rim.distance = 0;

        switch (i)
        {
            case boyfriend:
                //bf
                rim.angle = 90;
                boyfriend.shader = rim;

                rim.loadAltMask(Paths.image('stages/school/erect/masks/picoPixel_mask'));
                rim.maskThreshold = 1;
                rim.useAltMask = true;

                bf.animation.onFrameChange.add(function() {
                if (bf != null)
                {
                    rim.updateFrameInfo(bf.frame);
                }
                });
            case gf:
                //gf
                rim.angle = 90;
                gf.shader = rim;

                rim.loadAltMask(Paths.image('stages/school/erect/masks/nenePixel_mask'));
                rim.maskThreshold = 1;
                rim.useAltMask = true;

                gf.animation.onFrameChange.add(function() {
                if (gf != null)
                {
                    rim.updateFrameInfo(gf.frame);
                }
                });
            case dad:
                //dad
                rim.angle = 90;
                dad.shader = rim;

                rim.loadAltMask(Paths.image('stages/school/erect/masks/senpai_mask'));
                rim.maskThreshold = 1;
                rim.useAltMask = true;

                dad.animation.onFrameChange.add(function() {
                if (dad != null)
                    {
                        rim.updateFrameInfo(dad.frame);
                    }
                });
        }
    }
}