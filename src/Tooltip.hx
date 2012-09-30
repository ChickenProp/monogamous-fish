import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Graphiclist;

class Tooltip extends Entity {
	public function new (text:String) {
		super();

		var gl = new Graphiclist();
		gl.scrollX = gl.scrollY = 0;
		var textG = new Text(text);
		textG.color = 0x000000;
		var bg = Image.createRect(textG.width, textG.height, 0x0090c2);
		gl.add(bg);
		gl.add(textG);
		graphic = gl;
	}
}
