import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;

class Fish extends Entity {
	public static var blue:Int = 0x0000FF;
	public static var pink:Int = 0xFF8080;
	public var gender(getGender, setGender):Bool; // Male is false, female true.
	public var level(getLevel, null):Level;
	public var selected(getSelected, setSelected):Bool;
	public var inLove:Bool;
	public var loveCount:Int;

	public function new (x:Float, y:Float, gender:Bool) {
		super();

		this.x = x;
		this.y = y;
		graphic = Image.createCircle(15, 0xFFFFFF);
		cast(graphic, Image).centerOO();
		width = 30;
		height = 30;
		centerOrigin();
		this.gender = gender;
		type = "tile";
		inLove = false;
		loveCount = 0;
	}

	public function move (dx:Int, dy:Int) : Bool {
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
		inLove = false;
		loveCount = 0;

		e = collide("tile", x+d, y);
		if (loves(e)) fallInLove();
		e = collide("tile", x-d, y);
		if (loves(e)) fallInLove();
		e = collide("tile", x, y+d);
		if (loves(e)) fallInLove();
		e = collide("tile", x, y-d);
		if (loves(e)) fallInLove();
	}

	public function fallInLove () {
		inLove = true;
		if (level.allowedChanges == 0)
			selected = false;
		loveCount++;
	}

	override public function update () : Void {
		if (Input.mousePressed && collidePoint(x, y, Input.mouseX, Input.mouseY) && (!inLove || level.allowedChanges > 0)) {
			selected = true;
		}

		findLove();
	}

	override public function render () : Void {
		super.render();
		if (selected) {
			Draw.circlePlus(Std.int(x), Std.int(y), 14, 0xFFFFFF, 1, false, 2);
		}
		if (inLove)
			Draw.circlePlus(Std.int(x), Std.int(y), 14, 0xFF0000, 0.5);
	}

	var _gender:Bool;
	function getGender () : Bool { return _gender; }
	function setGender (g:Bool) : Bool {
		cast(graphic, Image).color = g ? pink : blue;
		_gender = g;
		return g;
	}

	function getLevel () : Level { return cast(world, Level); }

	function getSelected () : Bool { return level.selected == this; }
	function setSelected (s:Bool) : Bool {
		if (selected && !s)
			level.selected = null;
		else if (!selected && s)
			level.selected = this;

		return s;
	}
}
