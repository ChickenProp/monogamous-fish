import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Draw;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Spritemap;

class Editor extends MyWorld {
	public var panel:Panel;
	public var entToPlace:Entity;

	public var tiles:Array<Array<Entity>>;

	public function new () {
		super();
		tiles = [];
		width = 18;
		height = 13;
		for (x in 0...width) {
			tiles.push([]);
			for (y in 0...height) {
				var r = new Rock(30*x, 30*y);
				tiles[x].push(r);
				add(r);
			}
		}

		addChangeCount();

		panel = cast add(new Panel());
	}

	var hiddenTile:Entity;
	override public function update () : Void {
		super.update();

		var dc = (Input.pressed(187) ? 1 : 0) // plus (including equals)
			- (Input.pressed(189) ? 1 : 0); // minus
		allowedChanges += dc;
		if (allowedChanges < 0)
			allowedChanges = 0;

		var tx = pointToTile(mouseX);
		var ty = pointToTile(mouseY);

		if (hiddenTile != null)
			add(hiddenTile);

		if (0 <= tx && tx < width && 0 <= ty && ty < height) {
			hiddenTile = tiles[tx][ty];
			if (hiddenTile != null)
				remove(hiddenTile);

			if (entToPlace != null) {
				add(entToPlace);
				entToPlace.x = tx*30;
				entToPlace.y = ty*30;
			}

			if (Input.mouseDown) {
				swapTile(tx, ty, panel.addSelectedEntity(tx*30, ty*30));
				hiddenTile = null;
			}
		}
		else {
			if (entToPlace != null)
				remove(entToPlace);
			hiddenTile = null;
		}
	}

	public function swapTile (x:Int, y:Int, e:Entity) : Void {
		if (tiles[x][y] != null)
			remove(tiles[x][y]);
		tiles[x][y] = e;
	}

	public function pointToTile (p:Float) : Int {
		return Math.floor((p+15)/30);
	}

	override public function tilesToStr () : String {
		var lines:Array<String> = [];

		for (y in 0...height) {
			var l = "";
			for (x in 0...width)
				l += ent2char(tiles[x][y]);
			lines.push(l);
		}
		return lines.join("\n");
	}
}
