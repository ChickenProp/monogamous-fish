import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;

class Rock extends Entity {
	public function new (x:Float, y:Float) {
		super();

		this.x = x;
		this.y = y;
		graphic = new Spritemap("gfx/tiles.png", 30, 30);
		cast(graphic, Spritemap).frame = 1;
		cast(graphic, Image).centerOO();
		width = 30;
		height = 30;
		centerOrigin();
		type = "tile";
	}
}
