import com.haxepunk.Engine;
import com.haxepunk.HXP;

class Main extends Engine
{

	public static inline var kScreenWidth:Int = 640;
	public static inline var halfWidth:Int = 320;
	public static inline var kScreenHeight:Int = 480;
	public static inline var halfHeight:Int = 240;
	public static inline var kFrameRate:Int = 30;
	public static inline var kClearColor:Int = 0x00b0e2;
	public static inline var kProjectName:String = "HaxePunk";

	public function new()
	{
		super(kScreenWidth, kScreenHeight, kFrameRate, true);
	}

	override public function init()
	{
#if debug
	#if flash
		if (flash.system.Capabilities.isDebugger)
	#end
		{
			HXP.console.enable();
		}
#end
		HXP.screen.color = kClearColor;
		HXP.screen.scale = 1;

		HXP.world = Level.loadNew(1);
	}

	public static function main()
	{
		new Main();
	}

}
