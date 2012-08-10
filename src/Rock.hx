import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;

class Rock extends Entity {
	public function new (x:Float, y:Float) {
		super();

		this.x = x;
		this.y = y;
		graphic = new Image("gfx/rock.png");
		cast(graphic, Image).centerOO();
		width = 30;
		height = 30;
		centerOrigin();
		type = "tile";
	}
}
