import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Draw;
import com.haxepunk.graphics.Text;

class Editor extends MyWorld {
	public var selX:Int;
	public var selY:Int;

	public function new () {
		super();
		width = 18;
		height = 13;
		for (x in 0...width) {
			for (y in 0...height) {
				add(new Rock(30*x, 30*y));
			}
		}
		selX = 8;
		selY = 6;

		addChangeCount();
	}

	override public function update () : Void {
		super.update();

		var dx = (Input.pressed(Key.RIGHT) ? 1 : 0)
			- (Input.pressed(Key.LEFT) ? 1 : 0);
		var dy = (Input.pressed(Key.DOWN) ? 1 : 0)
			- (Input.pressed(Key.UP) ? 1 : 0);
		selX += dx;
		selY += dy;
		selX = Std.int(HXP.clamp(selX, 0, width - 1));
		selY = Std.int(HXP.clamp(selY, 0, height - 1));

		if (Input.check(Key.SPACE))
			removeTile(selX, selY);
		if (Input.check(Key.R)) {
			removeTile(selX, selY);
			add(new Rock(selX*30, selY*30));
		}
		if (Input.check(Key.M)) {
			removeTile(selX, selY);
			add(new Fish(selX*30, selY*30, false));
		}
		if (Input.check(Key.F)) {
			removeTile(selX, selY);
			add(new Fish(selX*30, selY*30, true));
		}

		var dc = (Input.pressed(187) ? 1 : 0) // plus (including equals)
			- (Input.pressed(189) ? 1 : 0); // minus
		allowedChanges += dc;
		if (allowedChanges < 0)
			allowedChanges = 0;
	}

	public function removeTile(x:Int, y:Int) : Void {
		var ents:Array<Entity> = [];
		collidePointInto("tile", x*30, y*30, ents);
		for (e in ents)
			remove(e);
	}

	override public function render () : Void {
		super.render();

		Draw.circlePlus(selX*30, selY*30, 14, 0xFFFFFF, 1, false, 2);
	}
}
