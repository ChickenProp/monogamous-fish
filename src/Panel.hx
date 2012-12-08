import com.haxepunk.Entity;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Draw;

typedef Button = {
	var ent:Entity;
	var type:String;
	var replace:Bool;
};

class Panel extends Entity {
	public var buttons:Array<Button>;
	public var editor:Editor;
	public var selectedButton:Button;
	public var buttonHilight:Image;

	public function new () {
		super();
		buttons = [];
	}

	override public function added () : Void {
		editor = cast world;
		addButton(0, "empty");
		addButton(1, "rock");
		addButton(2, "male");
		addButton(3, "female");
		addButton(5, "select");
		buttons[4].replace = false;
		selectButton(buttons[0]);

		setupImage();
	}

	public function setupImage () : Void {
		var gl = new Graphiclist();
		gl.scrollX = gl.scrollY = 0;

		var numbuttons = buttons.length;

		var border = Image.createRect(34, numbuttons*30 + 4, 0x000000);
		border.x = border.y = -2;
		gl.add(border);
		gl.add(Image.createRect(30, numbuttons*30, Main.kClearColor));

		buttonHilight = Image.createRect(30, 30, 0xFFFFFF);
		buttonHilight.relative = false;
		buttonHilight.alpha = 0.5;
		gl.add(buttonHilight);

		graphic = gl;
		layer++; // render hilight under the buttons.

		x = Main.kScreenWidth - 30;
		y = Main.halfHeight - numbuttons*15;

		for (i in 0...numbuttons) {
			buttons[i].ent.x = x;
			buttons[i].ent.y = y + 30*i;
		}
	}

	public function addButton(frame:Int, type:String) : Void {
		var i = 0;
		var b = new Entity();
		b.width = b.height = 30;

		var s = new Spritemap("gfx/tiles.png", 30, 30);
		s.frame = frame;
		s.scrollX = s.scrollY = 0;
		b.graphic = s;
		b.layer--;

		buttons.push({ ent: b, type: type, replace: true});
		world.add(b);
	}

	public function createEntity (type:String) : Entity {
		switch (type) {
		case "male": return new Fish(0, 0, false);
		case "female": return new Fish(0, 0, true);
		case "rock": return new Rock(0, 0);
		case "select": return new Selector(0, 0);
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

	override public function render () : Void {
		buttonHilight.x = selectedButton.ent.x;
		buttonHilight.y = selectedButton.ent.y;

		super.render();
	}
}
