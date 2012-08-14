import com.haxepunk.HXP;
import com.haxepunk.World;
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

	public function new () {
		super();

		moves = [];
		undoIndex = -1;
		readyToMove = true;
	}

	public function load (n:Int) {
		levelNumber = n;
		var bytes = nme.Assets.getBytes(Std.format("levels/$n.txt"));

		if (bytes == null) {
			return;
		}
		var src = bytes.toString();

		var lines = src.split("\n");

		allowedChanges = Std.parseInt(lines.shift());
		if (allowedChanges > 0)
			addChangeCount();

		if (lines[0].charAt(0) == '"')
			setText(lines.shift().substr(1));

		if (lines[lines.length - 1] == "")
			lines.pop();

		loadTileString(lines.join("\n"));
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

		if (readyToMove && selected != null) {
			if (selected.loveCount == 0 && (dx != 0 || dy != 0))
				doMove(Move(dx, dy));
			else if (Input.pressed(Key.SPACE) && allowedChanges !=0)
				doMove(Swap);
			else if (Input.check(Key.Z))
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
		if (Input.pressed(Key.E))
			HXP.world = new Editor();
		if (Input.pressed(Key.TAB)) {
			if (Input.check(Key.SHIFT))
				selPrev();
			else
				selNext();
		}

		if (checkWin())
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
		var fish = [];
		getClass(Fish, fish);
		for (f in fish)
			if (cast(f, Fish).loveCount != 1)
				return false;

		if (fish.length == 0) // no fish == final level, don't win
			return false;

		return true;
	}

	public function undo () {
		if (undoIndex == -1)
			return;

		selected = moves[undoIndex].fish;
		undoFishMove(selected, moves[undoIndex].move);
		undoIndex--;
	}

	public function redo () {
		undoIndex++;
		if (undoIndex < moves.length) {
			selected = moves[undoIndex].fish;
			doFishMove(selected, moves[undoIndex].move);
		}
		else
			undoIndex--;
	}

	public function reset () {
		HXP.world = loadNew(levelNumber);
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
}
