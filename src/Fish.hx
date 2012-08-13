import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
using Lambda;

class Fish extends Entity {
	public static var LEFT:Int = 1;
	public static var RIGHT:Int = 2;
	public static var UP:Int = 4;
	public static var DOWN:Int = 8;

	public var gender(getGender, setGender):Bool; // Male is false, female true.
	public var facing(getFacing, setFacing):Int;
	public var image:Spritemap;

	public var level(getLevel, null):Level;
	public var selected(getSelected, setSelected):Bool;
	public var loveDirections:Int;
	public var loveCount:Int;

	public function new (x:Float, y:Float, gender:Bool) {
		super();

		this.x = x;
		this.y = y;

		image = new Spritemap("gfx/tiles.png", 30, 30);
		image.centerOO();
		width = 30;
		height = 30;
		centerOrigin();

		graphic = image;
		this.gender = gender; // Sets frame of graphic.

		type = "tile";
		loveDirections = 0;
		loveCount = 0;
	}

	public function move (dx:Int, dy:Int) : Bool {
		facing = xy2dir(dx, dy);

		dx *= 30;
		dy *= 30;
		if (collide("tile", x + dx, y + dy) == null) {
			level.readyToMove = false;
			var complete = function () {
				level.readyToMove = true;
			};
			HXP.tween(this, {x: x+dx, y: y+dy}, 6,
			          { complete: complete });
			return true;
		}
		else
			return false;
	}

	public function loves (e:Entity) {
		return (Std.is(e, Fish) && cast(e, Fish).gender != gender);
	}

	public function findLove () {
		var newld = 0;
		var newlc = 0;
		var newdir = 0;

		var check = function (dir:Int) : Void {
			var e = collide("tile", x + dir2x(dir), y + dir2y(dir));
			if (loves(e)) {
				newld |= dir;
				newlc++;
				newdir = dir;
			}
		}

		check(UP);
		check(DOWN);
		check(LEFT);
		check(RIGHT);

		if (newld != loveDirections) {
			loveDirections = newld;
			if (loveCount == 0)
				facing = newdir;
			loveCount = newlc;
		}
	}

	public function cycleLove () : Void {
		var dirs = [UP, LEFT, DOWN, RIGHT].filter(function (d) {
		                return loveDirections & d != 0;
		        }).array();
		facing = dirs[(dirs.indexOf(facing) + 1) % dirs.length];
	}

	override public function update () : Void {
		if (Input.mousePressed && collidePoint(x, y, world.mouseX, world.mouseY)) {
			selected = true;
		}

		findLove();
		if (loveCount != 0 && level.frame % 15 == 0)
			cycleLove();
	}

	override public function render () : Void {
		super.render();
		var x = Std.int(x);
		var y = Std.int(y);
		if (selected) {
			Draw.circlePlus(x, y, 14, 0xFFFFFF, 1, false, 2);
		}
	}

	public static function dir2x (dir:Int) : Int {
		return (switch (dir) {
		        case LEFT: -1;
		        case RIGHT: 1;
		        default: 0;
		});
	}

	public static function dir2y (dir:Int) : Int {
		return (switch (dir) {
		        case UP: -1;
		        case DOWN: 1;
		        default: 0;
		});
	}

	public static function xy2dir (x:Int, y:Int) : Int {
		return (x > 0 ? RIGHT : 0) + (x < 0 ? LEFT : 0)
			+ (y < 0 ? UP : 0) + (y > 0 ? DOWN : 0);
	}

	var _gender:Bool;
	function getGender () : Bool { return _gender; }
	function setGender (g:Bool) : Bool {
		image.frame = g ? 3 : 2;
		_gender = g;
		return g;
	}

	function getLevel () : Level {
		return Std.is(world, Level) ? cast world : null;
	}

	function getSelected () : Bool {
		return level != null && level.selected == this;
	}
	function setSelected (s:Bool) : Bool {
		if (selected && !s)
			level.selected = null;
		else if (!selected && s)
			level.selected = this;

		return s;
	}

	public var _facing:Int;
	function getFacing () : Int { return _facing; }
	function setFacing (f:Int) : Int {
		image.angle = (switch (f) {
		        case LEFT: 90;
		        case RIGHT: -90;
		        case UP: 0;
		        case DOWN: 180;
		        default: 0;
		});

		_facing = f;
		return f;
	}
}
