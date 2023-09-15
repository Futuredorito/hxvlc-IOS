package hxvlc.flixel;

#if flixel
#if (!flixel_addons && macro)
#error 'Your project must use flixel-addons in order to use this class.'
#end
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import hxvlc.openfl.Video;
import sys.FileSystem;

class FlxVideoBackdrop extends FlxBackdrop
{
	public var bitmap(default, null):Video;

	public function new(repeatAxes = XY, spacingX = 0, spacingY = 0):Void
	{
		super(repeatAxes, spacingX, spacingY);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		bitmap = new Video();
		bitmap.alpha = 0;
		#if FLX_SOUND_SYSTEM
		bitmap.onOpening.add(function()
		{
			bitmap.mute = FlxG.sound.muted;
			bitmap.volume = Math.floor(FlxG.sound.volume * 100);
		});
		#end
		bitmap.onFormatSetup.add(() -> loadGraphic(bitmap.bitmapData));

		FlxG.game.addChild(bitmap);
	}

	public function play(location:String, shouldLoop:Bool = false):Bool
	{
		if (bitmap == null)
			return false;

		if (FlxG.autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		if (FileSystem.exists(Sys.getCwd() + location))
			return bitmap.play(Sys.getCwd() + location, shouldLoop);

		return bitmap.play(location, shouldLoop);
	}

	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	public function togglePaused():Void
	{
		if (bitmap != null)
			bitmap.togglePaused();
	}

	// Overrides
	public override function update(elapsed:Float):Void
	{
		#if FLX_SOUND_SYSTEM
		bitmap.mute = FlxG.sound.muted;
		bitmap.volume = Math.floor(FlxG.sound.volume * 100);
		#end

		super.update(elapsed);
	}

	public override function kill():Void
	{
		if (bitmap != null)
			bitmap.pause();

		super.kill();
	}

	public override function revive():Void
	{
		super.revive();

		if (bitmap != null)
			bitmap.resume();
	}

	public override function destroy():Void
	{
		if (FlxG.autoPause)
		{
			if (FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.remove(resume);

			if (FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.remove(pause);
		}

		super.destroy();

		if (bitmap != null)
		{
			bitmap.dispose();

			if (FlxG.game.contains(bitmap))
				FlxG.game.removeChild(bitmap);

			bitmap = null;
		}
	}
}
#end
