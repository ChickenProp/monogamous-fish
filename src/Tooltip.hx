import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.tweens.misc.MultiVarTween;

class Tooltip extends Entity {
	var entity:Entity;
	var mouseOver:Bool;
	var tween:MultiVarTween;

	public function new (ent:Entity, text:String) {
		super();

		entity = ent;
		// If ent has already been added, being on the same level will
		// make the tooltip draw on top. It seems a reasonable default.
		layer = ent.layer;
		visible = false;
		mouseOver = false;
		tween = new MultiVarTween();

		var gl = new Graphiclist();
		gl.scrollX = gl.scrollY = 0;
		var textG = new Text(text);
		textG.color = 0x000000;
		var bg = Image.createRect(textG.width, textG.height, 0x0090c2);
		gl.add(bg);
		gl.add(textG);
		graphic = gl;
	}

	override public function update () {
		super.update();

		var oldMo = mouseOver;
		mouseOver = entity.collidePoint(entity.x, entity.y,
		                                Input.mouseX, Input.mouseY);

		if (mouseOver && !oldMo) {
			tween = HXP.tween(this, {}, 10,
			                  { complete: this.show });
		}

		if (!mouseOver && oldMo) {
			tween.active = false;
			visible = false;
		}
	}

	public function show () {
		var offset = Main.kScreenHeight - Input.mouseY < 31 ? -15 : 15;
		moveTo(Input.mouseX, Input.mouseY + offset);
		visible = true;
	}
}
