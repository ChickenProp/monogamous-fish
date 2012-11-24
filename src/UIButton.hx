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
	var entity:Entity;
	var needToAddEnt:Bool;

	var mouseOver:Bool;

	public function new (entity:Entity, tooltip:String, click:Void->Void,
	                     enable:Void->Bool, ?hover:Bool->Void)
	{
		super();
		this.entity = entity;
		this.tooltip = new Tooltip(entity, tooltip);
		needToAddEnt = false;

		this.hover = hover;
		this.enabled = enable;
		this.clicked = click;
	}

	public static function fromButtonsPng (x:Float, y:Float, tile:Int,
	                    tooltip:String, click:Void->Void, enable:Void->Bool)
	{
		var e = new Entity();
		e.x = x;
		e.y = y;
		var graphic = new Spritemap("gfx/buttons.png", 20, 20);
		cast(graphic, Spritemap).frame = tile;
		cast(graphic, Spritemap).centerOO();
		graphic.scrollX = graphic.scrollY = 0;
		e.graphic = graphic;
		e.width = 20;
		e.height = 20;
		e.centerOrigin();
		e.type = "button";

		var b = new UIButton(e, tooltip, click, enable);
		b.needToAddEnt = true;

		b.hover = function (h:Bool) : Void {
			var col:Int;
			if (! b.enabled())
				col = 0x808080;
			else if (h)
				col = 0xFFFF00;
			else
				col = 0x000000;

			cast(graphic, Spritemap).color = col;
		}

		return b;
	}

	override public function added () {
		if (needToAddEnt)
			world.add(entity);
		world.add(tooltip);
	}

	override public function update () {
		mouseOver = entity.collidePoint(entity.x, entity.y,
		                                Input.mouseX, Input.mouseY);

		if (hover != null)
			hover(mouseOver);

		if (Input.mousePressed && mouseOver && enabled())
			clicked();
	}

	override public function render () {

		super.render();
	}

	dynamic public function enabled () : Bool {
		return true;
	}

	dynamic public function clicked () : Void {}
	dynamic public function hover (h:Bool) : Void {}
}








