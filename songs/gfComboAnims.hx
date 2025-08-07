function onPlayerHit(e){
    if(combo == 49)
        gf.playAnim('combo50', true);
    if(combo == 199)
        gf.playAnim('combo200', true);
}

function onPlayerMiss(e){
    if(combo >= 70)
        gf.playAnim('drop70', true);
}