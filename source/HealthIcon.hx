package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	 public var char:String = 'bf';
	 public var isPlayer:Bool = false;
	 public var isOldIcon:Bool = false;
	 public var hasWinning:Bool = false;
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		
		this.char = char;
		this.isPlayer = isPlayer;

		isPlayer = isOldIcon = false;
		changeIcon(char);
		scrollFactor.set();
	}

	public function changeIcon(char:String)
		{
			var file:Dynamic = Paths.image('icons/icon-'+char);
			var fileSize:FlxSprite = new FlxSprite().loadGraphic(file);
	
			loadGraphic(file, true, 150, 150);
		
			if (char.startsWith('senpai') || char.contains('pixel') || char.startsWith('spirit'))
				antialiasing = false;
			else
				antialiasing = true;
	
			if (fileSize.width == 450) //now with winning icon support
			{
				animation.add(char, [0, 1, 2], 0, false, isPlayer);
				hasWinning = true;
			}
			else
			{
				if (fileSize.width == 150)
					animation.add(char, [0], 0, false, isPlayer);
				else
					animation.add(char, [0, 1], 0, false, isPlayer);
				
				hasWinning = false;
			}
				
			animation.play(char);
		}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
