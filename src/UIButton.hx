import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.tweens.misc.MultiVarTween;

class UIButton extends Entity {
	public static var UNDO:Int = 0;
	public static var REDO:Int = 1;
	public static var RESTART:Int = 2;

	var tooltip:Entity;
	var enableFn:Void->Bool;
	var clickFn:Void->Void;

	var mouseOver:Bool;
	var tween:MultiVarTween;

	public function new (x:Float, y:Float, tile:Int, tooltip:String,
	                     enable:Void->Bool, click:Void->Void)
	{
		super();

		this.x = x;
		this.y = y;
		graphic = new Spritemap("gfx/buttons.png", 20, 20);
		cast(graphic, Spritemap).frame = tile;
		cast(graphic, Spritemap).centerOO();
		graphic.scrollX = graphic.scrollY = 0;
		width = 20;
		height = 20;
		centerOrigin();
		type = "button";

		this.tooltip = new Tooltip(tooltip);
		enableFn = enable;
		clickFn = click;

		mouseOver = false;
		tween = new MultiVarTween();
	}

	override public function update () {
		var oldMo = mouseOver;
		mouseOver = collidePoint(x, y, Input.mouseX, Input.mouseY);

		if (Input.mousePressed
		    && mouseOver
		    && clickFn != null
		    && enabled())
		{
			clickFn();
		}

		if (mouseOver && !oldMo) {
			tween = HXP.tween(this, {}, 10,
			                  { complete: this.addTooltip });
		}

		if (!mouseOver && oldMo) {
			tween.active = false;
			world.remove(tooltip);
		}
	}

	override public function render () {
		var col:Int;
		if (! enabled())
			col = 0x808080;
		else if (mouseOver)
			col = 0xFFFF00;
		else
			col = 0x000000;

		cast(graphic, Spritemap).color = col;

		super.render();
	}

	public function enabled () : Bool {
		return enableFn == null || enableFn();
	}

	public function addTooltip () {
		tooltip.moveTo(Input.mouseX, Input.mouseY + 15);
		world.add(tooltip);
	}
}








