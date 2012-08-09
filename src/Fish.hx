import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;

class Fish extends Entity {
	public static var LEFT:Int = 1;
	public static var RIGHT:Int = 2;
	public static var UP:Int = 4;
	public static var DOWN:Int = 8;

	public var gender(getGender, setGender):Bool; // Male is false, female true.
	public var image:Spritemap;

	public var level(getLevel, null):Level;
	public var selected(getSelected, setSelected):Bool;
	public var loveDirections:Int;
	public var loveCount:Int;

	public function new (x:Float, y:Float, gender:Bool) {
		super();

		this.x = x;
		this.y = y;

		image = new Spritemap("gfx/fish.png", 30, 30);
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
		// Assumes a single unit in a cardinal direction.
		image.angle = -dx * 90 + (dy > 0 ? 180 : 0);

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
		var e:Entity;
		var d = 30;
		loveDirections = 0;
		loveCount = 0;

		e = collide("tile", x+1, y);
		if (loves(e)) fallInLove(RIGHT);
		e = collide("tile", x-1, y);
		if (loves(e)) fallInLove(LEFT);
		e = collide("tile", x, y+1);
		if (loves(e)) fallInLove(DOWN);
		e = collide("tile", x, y-1);
		if (loves(e)) fallInLove(UP);
	}

	public function fallInLove (dir:Int) {
		loveDirections |= dir;
		loveCount++;
	}

	override public function update () : Void {
		if (Input.mousePressed && collidePoint(x, y, world.mouseX, world.mouseY)) {
			selected = true;
		}

		findLove();
	}

	override public function render () : Void {
		super.render();
		var x = Std.int(x);
		var y = Std.int(y);
		if (selected) {
			Draw.circlePlus(x, y, 14, 0xFFFFFF, 1, false, 2);
		}
	}

	var _gender:Bool;
	function getGender () : Bool { return _gender; }
	function setGender (g:Bool) : Bool {
		image.setFrame(g ? 1 : 0, 0);
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
}
