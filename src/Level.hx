import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

class Level extends World {
	public var levelNumber:Int;
	public var selected:Fish;
	public var allowedChanges:Int;

	public function new () {
		super();
	}

	public function load (n:Int) {
		levelNumber = n;
		var src = nme.Assets.getBytes(Std.format("levels/$n.txt")).toString();

		var y = 0;
		var lines = src.split("\n");
		allowedChanges = Std.parseInt(lines.shift());
		var width = 0;
		var height = lines.length;
		for (l in lines) {
			var x = 0;
			var chars = l.split("");
			for (c in chars) {
				switch (c) {
				case '#': add(new Rock(x*30 + 15, y*30 + 15));
				case 'm': add(new Fish(x*30 + 15, y*30 + 15, false));
				case 'f': add(new Fish(x*30 + 15, y*30 + 15, true));
				}
				x++;
			}
			if (width < x)
				width = x;
			y++;
		}
	}

	public static function loadNew (n:Int) {
		var l = new Level();
		l.load(n);
		return l;
	}

	override public function update () {
		super.update();

		var dx = (Input.pressed(Key.RIGHT) ? 1 : 0)
			- (Input.pressed(Key.LEFT) ? 1 : 0);
		var dy = (Input.pressed(Key.DOWN) ? 1 : 0)
			- (Input.pressed(Key.UP) ? 1 : 0);

		if (selected != null) {
			selected.move(dx, dy);
			if (Input.pressed(Key.SPACE) && allowedChanges != 0) {
				selected.gender = !selected.gender;
				allowedChanges--;
			}
		}

		if (Input.pressed(Key.N))
			nextLevel();
		if (Input.pressed(Key.P))
			prevLevel();
		if (Input.pressed(Key.R))
			reset();
	}

	public function reset () {
		HXP.world = loadNew(levelNumber);
	}

	public function nextLevel () {
		HXP.world = loadNew(levelNumber+1);
	}

	public function prevLevel () {
		HXP.world = loadNew(levelNumber-1);
	}
}
