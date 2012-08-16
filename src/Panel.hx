import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;

typedef Button = {
	var ent:Entity;
	var type:String;
};

class Panel extends Entity {
	public var buttons:Array<Button>;
	public var editor:Editor;
	public var selectedButton:Button;

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
		editor = cast world;
		addButton(0, "empty");
		addButton(1, "rock");
		addButton(2, "male");
		addButton(3, "female");
		selectButton(buttons[0]);
	}

	public function addButton(frame:Int, type:String) : Void {
		var i = 0;
		var b = new Entity();
		b.x = x;
		b.y = y + 30*buttons.length;
		b.width = b.height = 30;

		var s = new Spritemap("gfx/tiles.png", 30, 30);
		s.frame = frame;
		s.scrollX = s.scrollY = 0;
		b.graphic = s;
		b.layer--;

		buttons.push({ ent: b, type: type});
		world.add(b);
	}

	public function createEntity (type:String) : Entity {
		switch (type) {
		case "male": return new Fish(0, 0, false);
		case "female": return new Fish(0, 0, true);
		case "rock": return new Rock(0, 0);
		default: return null;
		}
	}

	public function addSelectedEntity (x:Float, y:Float) : Entity {
		var e = createEntity(selectedButton.type);
		if (e != null) {
			world.add(e);
			e.x = x;
			e.y = y;
		}
		return e;
	}

	public function selectButton (b:Button) {
		selectedButton = b;

		if (editor.entToPlace != null)
			world.remove(editor.entToPlace);

		editor.entToPlace = createEntity(b.type);

		if (editor.entToPlace != null)
			world.add(editor.entToPlace);
	}

	override public function update () : Void {
		var mx = Input.mouseX;
		var my = Input.mouseY;

		if (Input.mousePressed) {
			for (b in buttons) {
				if (b.ent.collidePoint(b.ent.x, b.ent.y, mx,my))
					selectButton(b);
			}
		}
	}
}
