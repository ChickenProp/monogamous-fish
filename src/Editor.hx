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

	public function new () {
		super();

		addChangeCount();
		panel = cast add(new Panel());
		add(UIButton.fromButtonsPng(15, Main.kScreenHeight - 51,
		                            3, "Increase (+)",
		                            function () { allowedChanges++; }));
		add(UIButton.fromButtonsPng(35, Main.kScreenHeight - 51,
		                            4, "Decrease (-)",
		                            function () {
						    allowedChanges--;
						    if (allowedChanges < 0)
							    allowedChanges = 0;
					    }));

		// We can't read the clipboard from outside a PASTE event, so
		// that doesn't work. Having copy without paste seems silly.
		//add(UIButton.fromButtonsPng(15, 15, 5, "Copy",
		//                            function(){Main.copyHandler();}));
		//add(UIButton.fromButtonsPng(35, 15, 6, "Paste",
		//                           function(){Main.pasteHandler();}));
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

		var replace = panel.selectedButton.replace;

		if (0 <= tx && tx < width && 0 <= ty && ty < height) {
			hiddenTile = tiles[tx][ty];
			if (hiddenTile != null && replace)
				remove(hiddenTile);

			if (entToPlace != null) {
				add(entToPlace);
				entToPlace.x = tx*30;
				entToPlace.y = ty*30;
			}

			if (Input.mouseDown && replace) {
				swapTile(tx, ty, panel.addSelectedEntity(tx*30, ty*30));
				hiddenTile = null;
			}
		}
		else {
			if (entToPlace != null)
				remove(entToPlace);
			hiddenTile = null;
		}

		if (Input.pressed(Key.E)) {
			var lvl = new Level();
			lvl.loadString(worldToStr());
			lvl.levelNumber = -1;
			HXP.world = lvl;
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
