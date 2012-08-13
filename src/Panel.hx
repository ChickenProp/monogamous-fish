import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;

class Panel extends Entity {
	public var buttons:Array<Entity>;

	public function new () {
		super();

		var gl = new Graphiclist();
		gl.scrollX = gl.scrollY = 0;

		var border = Image.createRect(34, 124, 0x000000);
		border.x = border.y = -2;
		gl.add(border);
		gl.add(Image.createRect(30, 120, Main.kClearColor));
		graphic = gl;

		x = Main.kScreenWidth - 30;
		y = Main.halfHeight-60;

		buttons = [];
	}

	override public function added () : Void {
		addButton(0);
		addButton(1);
		addButton(2);
		addButton(3);
	}

	public function addButton(frame:Int) : Void {
		var i = 0;
		var b = new Entity();
		b.x = x;
		b.y = y + 30*buttons.length;

		var s = new Spritemap("gfx/tiles.png", 30, 30);
		s.frame = frame;
		s.scrollX = s.scrollY = 0;
		b.graphic = s;
		b.layer--;

		buttons.push(b);
		world.add(b);
	}
}
