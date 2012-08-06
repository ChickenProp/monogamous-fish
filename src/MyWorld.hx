import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.utils.Draw;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Spritemap;
import nme.utils.ByteArray;
import de.polygonal.core.io.Base64;

class MyWorld extends World {
	public var allowedChanges:Int;
	public var changeCount:Text;
	public var text:Text;

	public var selected:Fish;

	public var heart:Spritemap;

	public function new () {
		super();

		heart = new Spritemap("gfx/heart.png", 14, 14);
		heart.add("beat", [0, 1, 2, 3], 0.1, true);
		heart.play("beat");
		heart.centerOO();

		allowedChanges = 0;
	}

	public function loadString (str:String) : Void {
		if (str.charAt(0) == '"') {
			var lines = str.split("\n");
			setText(lines[0].substr(1));
			str = lines[1];
		}

		var ba:ByteArray = Base64.decode(str);
		ba.uncompress();
		ba.readByte(); // version, currently ignored.
		allowedChanges = ba.readByte();
		var tiles = ba.toString();
		loadTileString(tiles);
	}

	public function loadTileString (str:String) : Void {
		var lines = str.split("\n");
		var width = 0;
		var height = lines.length;
		var y = 0;
		for (l in lines) {
			var x = 0;
			var chars = l.split("");
			for (c in chars) {
				addTileByChar(x, y, c);
				x++;
			}
			if (width < x)
				width = x;
			y++;
		}
	}

	public function addTileByChar(x:Int, y:Int, c:String) {
		switch (c) {
		case '#': add(new Rock(x*30 + 15, y*30 + 15));
		case 'm': add(new Fish(x*30 + 15, y*30 + 15, false));
		case 'f': add(new Fish(x*30 + 15, y*30 + 15, true));
		case 'M':
			var f = new Fish(x*30 + 15, y*30 + 15, false);
			selected = f;
			add(f);
		case 'F':
			var f = new Fish(x*30 + 15, y*30 + 15, true);
			selected = f;
			add(f);
		}
	}

	public function addChangeCount () : Void {
		changeCount = new Text(Std.string("      "));
		addGraphic(changeCount).layer--;
	}

	public function setText (s:String) {
		text = new Text(s, 320, 460);
		text.color = 0x000000;
		text.centerOO();
		addGraphic(text).layer--;
	}

	override public function update () : Void {
		super.update();
		heart.update();

		if (changeCount != null)
			changeCount.text = Std.string(allowedChanges);
	}

	public function fishes() : Array<Fish> {
		var es:Array<Entity> = [];
		var fs:Array<Fish> = [];
		getClass(Fish, es);
		for (e in es)
			fs.push(cast e);
		return fs;
	}

	override public function render () : Void {
		super.render();

		for (f in fishes()) {
			var x:Int = Std.int(f.x);
			var y:Int = Std.int(f.y);
			if (f.loveDirections & Fish.RIGHT != 0)
				Draw.graphic(heart, x+15, y);
			if (f.loveDirections & Fish.DOWN != 0)
				Draw.graphic(heart, x, y+16);
		}
	}
}
