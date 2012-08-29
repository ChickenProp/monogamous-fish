import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.HXP;
import flash.ui.ContextMenu;
import flash.events.Event;
import flash.events.MouseEvent;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Data;
import flash.system.System;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;

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

		HXP.world = Level.loadNew(0);

		contextMenu = new ContextMenu();
                contextMenu.clipboardMenu = true;
                contextMenu.clipboardItems.copy = true;
                contextMenu.clipboardItems.paste = true;
                contextMenu.clipboardItems.clear = true;

                addEventListener(Event.COPY, copyHandler);
                addEventListener(Event.PASTE, pasteHandler);
                addEventListener(Event.CLEAR, clearHandler);
	}

	public static function main()
	{
		new Main();
	}

	public static function copyHandler (e:Event) {
		var level = cast(HXP.world, MyWorld);
		System.setClipboard(level.worldToStr());
	}

	public static function pasteHandler (e:Event) {
                var fmt = ClipboardFormats.TEXT_FORMAT;
                var clip:String = Clipboard.generalClipboard.getData(fmt);

		var lvl = new Level();
		lvl.loadString(clip);
		HXP.world = lvl;
	}
	public static function clearHandler (e:Event) {}

}
