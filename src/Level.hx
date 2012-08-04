import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Text;

class Level extends World {
	public var levelNumber:Int;
	public var selected:Fish;
	public var allowedChanges:Int;
	public var changeCount:Text;
	public var text:Text;

	public function new () {
		super();
	}

	public function load (n:Int) {
		levelNumber = n;
		var bytes = nme.Assets.getBytes(Std.format("levels/$n.txt"));

		if (bytes == null) {
			return;
		}
		var src = bytes.toString();

		var y = 0;
		var lines = src.split("\n");

		allowedChanges = Std.parseInt(lines.shift());
		if (allowedChanges > 0) {
			changeCount = new Text(Std.string(allowedChanges));
			addGraphic(changeCount);
		}

		if (lines[0].charAt(0) == '"')
			setText(lines.shift().substr(1));

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
				case 'M':
					var f = new Fish(x*30 + 15, y*30 + 15, false);
					selected = f;
					add(f);
				case 'F':
					var f = new Fish(x*30 + 15, y*30 + 15, true);
					selected = f;
					add(f);
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
		var dx = (Input.pressed(Key.RIGHT) ? 1 : 0)
			- (Input.pressed(Key.LEFT) ? 1 : 0);
		var dy = (Input.pressed(Key.DOWN) ? 1 : 0)
			- (Input.pressed(Key.UP) ? 1 : 0);

		if (selected != null) {
			if (!selected.inLove)
				selected.move(dx, dy);

			if (Input.pressed(Key.SPACE) && allowedChanges != 0) {
				selected.gender = !selected.gender;
				allowedChanges--;
				changeCount.text = Std.string(allowedChanges);
			}
		}

		super.update();

		if (Input.pressed(Key.N))
			nextLevel();
		if (Input.pressed(Key.P))
			prevLevel();
		if (Input.pressed(Key.R))
			reset();

		if (checkWin())
			nextLevel();
	}

	public function checkWin () : Bool {
		var fish = [];
		getClass(Fish, fish);
		for (f in fish)
			if (cast(f, Fish).loveCount != 1)
				return false;

		return true;
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

	public function setText (s:String) {
		text = new Text(s, 320, 460);
		text.centerOO();
		addGraphic(text).layer--;
	}
}
