import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;

class Rock extends Entity {
	public function new (x:Float, y:Float) {
		super();

		this.x = x;
		this.y = y;
		graphic = new Spritemap("gfx/tiles.png", 30, 30);
		cast(graphic, Spritemap).frame = HXP.choose([1,6,11,16]);
		cast(graphic, Image).centerOO();
		width = 30;
		height = 30;
		centerOrigin();
		type = "tile";
	}

	public function shouldBeVisible () : Bool {
		for (dx in [-30, 0, 30]) {
			for (dy in [-30, 0, 30]) {
				if (testDxDy(dx, dy))
					return true;
			}
		}
		return false;
	}

	function testDxDy (dx:Int, dy:Int) : Bool {
		if (dx == 0 && dy == 0)
			return false;

		var level = cast(world, MyWorld);
		if (HXP.clamp(x+dx, 0, 30 * (level.width-1)) != x+dx)
			return false;
		if (HXP.clamp(y+dy, 0, 30* (level.height-1)) != y+dy)
			return false;

		var e = collide("tile", x + dx, y + dy);
		if (Std.is(e, Rock))
			return false;

		return true;
	}
}
