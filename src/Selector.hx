import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;

class Selector extends Entity {
	public function new (x:Float, y:Float) {
		super();

		this.x = x;
		this.y = y;
		graphic = new Spritemap("gfx/tiles.png", 30, 30);
		cast(graphic, Spritemap).frame = 5;
		cast(graphic, Image).centerOO();
		width = 30;
		height = 30;
		centerOrigin();
	}

	override public function update () : Void {
		// The only reason there's a Selector in the world is if we're
		// in the editor and the player has chosen to select. So we
		// don't need to worry about mouse position or anything like
		// that.
		if (Input.mouseDown) {
			var e = collide("tile", x, y);
			if (e != null && Std.is(e, Fish))
				cast(e, Fish).selected = true;
		}
	}

	override public function render () : Void {
		// If this is in update, it seems to take effect one frame late.
		// That's because Engine calls super.update() at the beginning,
		// so this calls update before it's moved by Engine.
		var e = collide("tile", x, y);
		if (e != null && Std.is(e, Fish))
			cast(graphic, Image).color = 0xFFFFFF;
		else
			cast(graphic, Image).color = 0xFF0000;

		super.render();
	}
}
