import com.haxepunk.HXP;
import com.haxepunk.Sfx;

class Audio {
	public static var kiss:Sfx;
	public static var canPlayKiss:Int;

	public static var bubbles:Sfx;

	public static function init () : Void {
		kiss = new Sfx("sfx/kiss.mp3");
		canPlayKiss = 1;

		bubbles = new Sfx("sfx/bubbles.mp3");
	}
	public static function playKiss() : Void {
		if (canPlayKiss == 1) {
			kiss.play();
			canPlayKiss = 0;
			HXP.tween(Audio, {canPlayKiss: 1}, 3);
		}
	}

	public static function playBubbles() : Void {
		bubbles.play();
	}
}
