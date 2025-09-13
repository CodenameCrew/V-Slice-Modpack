function create() {
	if(curStage == 'tank')
		importScript("data/scripts/tankmenRunNormal");
	else if (curStage == 'tank-erect')
		importScript("data/scripts/tankmenRunErect");
}