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
		for (x in 0...18) {
			for (y in 0...13) {
				add(new Rock(30*x + 65, 30*y + 60));
			}
		}
		selX = 305;
		selY = 240;

		addChangeCount();
	}

	override public function update () : Void {
		super.update();

		var dx = (Input.pressed(Key.RIGHT) ? 1 : 0)
			- (Input.pressed(Key.LEFT) ? 1 : 0);
		var dy = (Input.pressed(Key.DOWN) ? 1 : 0)
			- (Input.pressed(Key.UP) ? 1 : 0);
		selX += dx*30;
		selY += dy*30;
		selX = Std.int(HXP.clamp(selX, 65, 575));
		selY = Std.int(HXP.clamp(selY, 60, 420));

		if (Input.check(Key.SPACE))
			removeAtPoint(selX, selY);
		if (Input.check(Key.R)) {
			removeAtPoint(selX, selY);
			add(new Rock(selX, selY));
		}
		if (Input.check(Key.M)) {
			removeAtPoint(selX, selY);
			add(new Fish(selX, selY, false));
		}
		if (Input.check(Key.F)) {
			removeAtPoint(selX, selY);
			add(new Fish(selX, selY, true));
		}

		var dc = (Input.pressed(187) ? 1 : 0) // plus (including equals)
			- (Input.pressed(189) ? 1 : 0); // minus
		allowedChanges += dc;
		if (allowedChanges < 0)
			allowedChanges = 0;
	}

	public function removeAtPoint(x:Int, y:Int) : Void {
		var ents:Array<Entity> = [];
		collidePointInto("tile", x, y, ents);
		for (e in ents)
			remove(e);
	}

	override public function render () : Void {
		super.render();

		Draw.circlePlus(selX, selY, 14, 0xFFFFFF, 1, false, 2);
	}
}
