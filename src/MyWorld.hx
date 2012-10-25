import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
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

	public var width:Int;
	public var height:Int;

	public var frame:Int;

	public var readyToMove:Bool;

	public var numFish:Int;
	public var tiles:Array<Array<Entity>>;
	public var tileString:String;

	public function new () {
		super();

		heart = new Spritemap("gfx/heart.png", 14, 14);
		heart.add("beat", [0, 1, 2, 3], 0.1, true);
		heart.play("beat");
		heart.centerOO();

		allowedChanges = 0;
		frame = 0;

		numFish = 0;
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
		if (allowedChanges > 0)
			addChangeCount();

		tileString = ba.readUTF();
		loadTileString(tileString);
	}

	public function loadTileString (str:String) : Void {
		var lines = str.split("\n");
		width = 0;
		height = lines.length;
		width = lines[0].length;
		tiles = [];

		var y = 0;
		for (l in lines) {
			var x = 0;
			var chars = l.split("");
			for (c in chars) {
				if (y == 0)
					tiles.push([]);

				tiles[x].push(addTileByChar(x, y, c));
				x++;
			}
			y++;
		}
	}

	public function tilesToStr () : String {
		var lines:Array<String> = [];
		var ents:Array<Entity> = [];

		for (y in 0...height) {
			var l = "";
			for (x in 0...width)
				l += ent2char(collidePoint("tile", x*30, y*30));
			lines.push(l);
		}
		return lines.join("\n");
	}

	public function worldToStr () : String {
		var ba:ByteArray = new ByteArray();
		ba.writeByte(0); //version
		ba.writeByte(allowedChanges);
		ba.writeUTF(tilesToStr());
		ba.compress();
		return Base64.encode(ba);
	}

	public function ent2char (e:Entity) : String {
		if (e == null)
			return " ";
		else if (Std.is(e, Rock))
			return "#";
		else if (Std.is(e, Fish)) {
			var f:Fish = cast e;
			if (f.gender)
				return f.selected ? "F" : "f";
			else
				return f.selected ? "M" : "m";
		}
		else
			return "";
	}

	public function addTileByChar(x:Int, y:Int, c:String) : Entity {
		var e:Entity = (switch (c.toLowerCase()) {
		        case '#': cast(new Rock(x*30, y*30));
		        case 'm': cast(new Fish(x*30, y*30, false));
		        case 'f': cast(new Fish(x*30, y*30, true));
		        default: null;
		});

		if (e == null)
			return null;

		if (Std.is(e, Fish))
			numFish++;

		add(e);

		// Select the first fish we add, to ensure there's always a fish
		// selected. Also select if it's upper-case.
		if (~/[FM]/.match(c) || (~/[fm]/.match(c) && selected == null))
			selected = cast e;

		return e;
	}

	public function addChangeCount () : Void {
		changeCount = new Text(Std.string("      "));
		changeCount.color = 0x000000;
		changeCount.scrollX = changeCount.scrollY = 0;
		changeCount.x = 30;
		changeCount.y = Main.kScreenHeight - 30;
		addGraphic(changeCount).layer--;

		var swapFish = new Spritemap("gfx/tiles.png", 30, 30);
		swapFish.frame = 8;
		swapFish.scrollX = 0; swapFish.scrollY = 0;

		var sfEnt = addGraphic(swapFish);
		sfEnt.layer--;
		sfEnt.width = sfEnt.height = 30;
		sfEnt.y = Main.kScreenHeight - 35;
		add(new Tooltip(sfEnt, "change sex (space)"));
	}

	public function setText (s:String) {
		text = new Text(s, 320, 460);
		text.color = 0x000000;
		text.centerOO();
		text.scrollX = text.scrollY = 0;
		addGraphic(text).layer--;
	}

	public function adjustCamera () : Void {
		HXP.camera.x = 15 * width - Main.halfWidth - 15;
		HXP.camera.y = 15 * height - Main.halfHeight - 15;
	}

	override public function update () : Void {
		super.update();
		heart.update();

		if (changeCount != null)
			changeCount.text = Std.string(allowedChanges);

		if (Input.pressed(Key.F5))
			HXP.console.enable();

		frame++;
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
		adjustCamera();
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
