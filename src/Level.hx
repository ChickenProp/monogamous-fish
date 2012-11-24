import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Draw;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Spritemap;

enum FishMove {
	Swap;
	Move(dx:Int, dy:Int);
}

typedef PlayerMove = {
	var fish:Fish;
	var move:FishMove;
};

typedef MoveList = Array<PlayerMove>;

class Level extends MyWorld {
	public var levelNumber:Int;

	public var moves:MoveList;
	public var undoIndex:Int;
	public var resetting:Bool;

	public var lastUndoSwap:Int;

	public function new () {
		super();

		moves = [];
		undoIndex = -1;
		readyToMove = true;
		lastUndoSwap = 0;
	}

	public function load (n:Int) {
		var levels = nme.Assets.getBytes("levels.txt").toString().split("\n\n");

		if (n < 0)
			n = 0;
		if (n >= levels.length)
			n = levels.length - 1;
		levelNumber = n;

		loadString(levels[n]);

		if (numFish != 0)
			addUI();
	}

	public static function loadNew (n:Int) {
		var l = new Level();
		l.load(n);
		return l;
	}

	override public function update () {
		var dx = (Input.check(Key.RIGHT) ? 1 : 0)
			- (Input.check(Key.LEFT) ? 1 : 0);
		var dy = (Input.check(Key.DOWN) ? 1 : 0)
			- (Input.check(Key.UP) ? 1 : 0);
		if (dx != 0)
			dy = 0;

		if (resetting && readyToMove) {
			Fish.moveTime /= 3;
			undo();
			Fish.moveTime *= 3;
			resetting = canUndo();
		}

		if (readyToMove && selected != null) {
			if (selected.loveCount == 0 && (dx != 0 || dy != 0))
				doMove(Move(dx, dy));
			else if (Input.pressed(Key.SPACE) && allowedChanges !=0)
				doMove(Swap);
			else if (Input.pressed(Key.Z))
				undo();
			else if (Input.check(Key.Z) && lastUndoSwap < frame-10)
				undo();
			else if (Input.check(Key.Y))
				redo();
		}

		super.update();

		if (Input.pressed(Key.N))
			nextLevel();
		if (Input.pressed(Key.P))
			prevLevel();
		if (Input.pressed(Key.R))
			reset();
		if (Input.pressed(Key.E)) {
			var ed = new Editor();
			ed.loadTileString(tileString);
			HXP.world = ed;
		}
		if (Input.pressed(Key.TAB)) {
			if (Input.check(Key.SHIFT))
				selPrev();
			else
				selNext();
		}

		if (checkWin() && readyToMove)
			nextLevel();
	}

	public function doMove (m:FishMove) : Void {
		if (! doFishMove(selected, m))
		        return;

		moves.splice(undoIndex + 1, moves.length - undoIndex - 1);
		moves.push({fish: selected, move: m});
		undoIndex++;
	}

	public function doFishMove (f:Fish, m:FishMove) : Bool {
		switch (m) {
		case Swap:
			f.gender = !f.gender;
			allowedChanges--;
			return true;
		case Move(dx, dy):
			return selected.move(dx, dy);
		}
	}

	public function undoFishMove (f:Fish, m:FishMove) : Void {
		switch (m) {
		case Swap:
			f.gender = !f.gender;
			allowedChanges++;
			lastUndoSwap = frame;
		case Move(dx, dy):
			selected.move(-dx, -dy);
		}
	}

	// The order fishes() returns them in, next seems to work best with
	// going to the previous index. Vice-versa for prev.
	public function selNext () : Void {
		var fs = fishes();
		var l = fs.length;
		for (i in 0...l) {
			if (fs[i] == selected) {
				selected = fs[(i+l-1)%l];
				return;
			}
		}
	}

	public function selPrev () : Void {
		var fs = fishes();
		var l = fs.length;
		for (i in 0...l) {
			if (fs[i] == selected) {
				selected = fs[(i+1)%l];
				return;
			}
		}
	}

	public function checkWin () : Bool {
		var fs = fishes();
		if (fs.length == 0) // no fish == final level, don't win
			return false;

		for (f in fs)
			if (f.loveCount != 1)
				return false;

		return true;
	}

	public function canUndo () : Bool {
		return undoIndex != -1;
	}

	public function undo () {
		if (! canUndo())
			return;

		selected = moves[undoIndex].fish;
		undoFishMove(selected, moves[undoIndex].move);
		undoIndex--;
	}

	public function canRedo () : Bool {
		return undoIndex < moves.length - 1;
	}

	public function redo () {
		if (! canRedo())
			return;

		undoIndex++;
		selected = moves[undoIndex].fish;
		doFishMove(selected, moves[undoIndex].move);
	}

	public function reset () {
		resetting = true;
	}

	public function nextLevel () {
		HXP.world = loadNew(levelNumber+1);
	}

	public function prevLevel () {
		HXP.world = loadNew(levelNumber-1);
	}

	public static function reverseFishMove (m:FishMove) : FishMove {
		switch (m) {
		case Swap: return Swap;
		case Move(dx, dy): return Move(-dx, -dy);
		}
	}

	var rocksHidden:Bool;
	override public function render () {
		// render sometimes gets called before update (I thought always,
		// but maybe not?), so we need this here. Can't just test for
		// frame=0, because if update gets called first, we're on frame
		// 1, so use a var to only call hideRocks once (it's slow).
		if (!rocksHidden)
			hideRocks();
		rocksHidden = true;

		super.render();
	}

	public function addUI() {
		add(UIButton.fromButtonsPng(20, 20, UIButton.UNDO, "undo (Z)",
		                            this.undo, this.canUndo));
		add(UIButton.fromButtonsPng(40, 20, UIButton.REDO, "redo (Y)",
		                            this.redo, this.canRedo));
		add(UIButton.fromButtonsPng(60, 20, UIButton.RESTART,
		                            "restart (R)",
		                            this.undo, this.canUndo));
	}

	public function hideRocks () {
		var rocks:Array<Entity> = [];
		getClass(Rock, rocks);
		for (r in rocks) {
			if (!cast(r, Rock).shouldBeVisible())
				r.visible = false;
		}
	}
}
