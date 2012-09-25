import com.haxepunk.Entity;
import com.haxepunk.utils.Input;
import com.haxepunk.graphics.Spritemap;

class UIButton extends Entity {
	public static var UNDO:Int = 0;
	public static var REDO:Int = 1;
	public static var RESTART:Int = 2;

	var enableFn:Void->Bool;
	var clickFn:Void->Void;

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

		enableFn = enable;
		clickFn = click;
	}

	override public function update () {
		if (Input.mousePressed
		    && collidePoint(x, y, Input.mouseX, Input.mouseY)
		    && clickFn != null)
		{
			clickFn();
		}
	}
}








