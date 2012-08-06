import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.utils.Draw;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Spritemap;

class MyWorld extends World {
	public var allowedChanges:Int;
	public var changeCount:Text;
	public var text:Text;

	public var heart:Spritemap;

	public function new () {
		super();

		heart = new Spritemap("gfx/heart.png", 14, 14);
		heart.add("beat", [0, 1, 2, 3], 0.1, true);
		heart.play("beat");
		heart.centerOO();

		allowedChanges = 0;
	}

	public function addChangeCount () : Void {
		changeCount = new Text(Std.string("      "));
		addGraphic(changeCount).layer--;
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
