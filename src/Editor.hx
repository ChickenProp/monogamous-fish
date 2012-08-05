import com.haxepunk.HXP;
import com.haxepunk.World;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Text;

class Editor extends World {
	public function new () {
		super();
		for (x in 0...20) {
			for (y in 0...14) {
				add(new Rock(30*x + 35, 30*y + 45));
			}
		}
	}
}
