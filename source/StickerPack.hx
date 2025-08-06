
import funkin.backend.system.Logs;

class StickerPack {

	public var id:String;

	public var _data:Dynamic;

	public function new(id:String) {
		this.id = id;

		var rawPath:String = Paths.json('stickerpacks/' + id);
		var packContent:String = null;

		if(Assets.exists(rawPath))
		{
			packContent = Assets.getText(rawPath);
		}

		if(packContent == null)
		{
			Logs.trace('Sticker Pack "' + id + '" couldn\'t be found. Using default...', 2);

			id = 'default';
			rawPath = Paths.json('stickerpacks/default');

			if(Assets.exists(rawPath)) {
				packContent = Assets.getText(rawPath);
			}

			if(packContent == null) {
				throw 'Default sticker pack "default" was null! This should not happen!';
			}
		}

		_data = Json.parse(packContent);
	}

	public function getStickerPackName() {
		return _data.name;
	}

	public function getStickerPackArtist() {
		return _data.artist;
	}

	public function getStickers() {
		return _data.stickers;
	}

	public function getRandomStickerPath() {
		return getRandomString(getStickers());
	}

	public function getRandomString(array:Array<String>) {
		return array[FlxG.random.int(0, array.length - 1)];
	}
}