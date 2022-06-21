package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
//import sys.io.File;
//import sys.FileSystem;

using StringTools;	

class StrumNote extends FlxSprite
{
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var daStyle = 'normal';
	public var pixelNotes:Array<String> = ['pixel', 'neon', 'pixel-corrupted', 'pixel-combined', 'guitar']; //guitar notes also have zero offsets
	
	private var player:Int;

	public var modifiedByLua:Bool = false;
	public var modAngle:Float = 0; // The angle set by modcharts
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		reloadNote(value);
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int, style:String) {
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		this.daStyle = style;
		super(x, y);

		scrollFactor.set();

		loadNoteAnims(style, true);
	}

	public function reloadNote(style:String)
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;
		PlayState.instance.bfStrumStyle = style;

		loadNoteAnims(style);
		updateHitbox();

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function loadNoteAnims(style:String, ?first:Bool = false)
	{
		daStyle = style;
		
		var suf:String = "";
		
		switch (style)
		{
			case 'pixel':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
				animation.add('green', [6]);
				animation.add('red', [7]);
				animation.add('blue', [5]);
				animation.add('purplel', [4]);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

				switch (Math.abs(noteData))
				{
					case 2:
						animation.add('static', [2]);
						animation.add('pressed', [6, 10], 12, false);
						animation.add('confirm', [14, 18], 12, false);
					case 3:
						animation.add('static', [3]);
						animation.add('pressed', [7, 11], 12, false);
						animation.add('confirm', [15, 19], 24, false);
					case 1:
						animation.add('static', [1]);
						animation.add('pressed', [5, 9], 12, false);
						animation.add('confirm', [13, 17], 24, false);
					case 0:
						animation.add('static', [0]);
						animation.add('pressed', [4, 8], 12, false);
						animation.add('confirm', [12, 16], 24, false);
				}
			
				case 'normal':
					frames = Paths.getSparrowAtlas('NOTE_assets');
					animation.addByPrefix('green', 'arrowUP');
					animation.addByPrefix('blue', 'arrowDOWN');
					animation.addByPrefix('purple', 'arrowLEFT');
					animation.addByPrefix('red', 'arrowRIGHT');
	
					antialiasing = true;
					setGraphicSize(Std.int(width * 0.7));
	
					switch (Math.abs(noteData))
					{
						case 0:
							animation.addByPrefix('static', 'arrowLEFT');
							animation.addByPrefix('pressed', 'left press', 24, false);
							animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							animation.addByPrefix('static', 'arrowDOWN');
							animation.addByPrefix('pressed', 'down press', 24, false);
							animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							animation.addByPrefix('static', 'arrowUP');
							animation.addByPrefix('pressed', 'up press', 24, false);
							animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							animation.addByPrefix('static', 'arrowRIGHT');
							animation.addByPrefix('pressed', 'right press', 24, false);
							animation.addByPrefix('confirm', 'right confirm', 24, false);
						}

				default:
					frames = Paths.getSparrowAtlas('NOTE_assets');
					animation.addByPrefix('green', 'arrowUP');
					animation.addByPrefix('blue', 'arrowDOWN');
					animation.addByPrefix('purple', 'arrowLEFT');
					animation.addByPrefix('red', 'arrowRIGHT');

					antialiasing = true;
					setGraphicSize(Std.int(width * 0.7));

					switch (Math.abs(noteData))
					{
						case 0:
							animation.addByPrefix('static', 'arrowLEFT');
							animation.addByPrefix('pressed', 'left press', 24, false);
							animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							animation.addByPrefix('static', 'arrowDOWN');
							animation.addByPrefix('pressed', 'down press', 24, false);
							animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							animation.addByPrefix('static', 'arrowUP');
							animation.addByPrefix('pressed', 'up press', 24, false);
							animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							animation.addByPrefix('static', 'arrowRIGHT');
							animation.addByPrefix('pressed', 'right press', 24, false);
							animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
		}

		updateHitbox();
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}

	override function update(elapsed:Float) {

		if (modifiedByLua)
			angle = modAngle;

		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		//if(animation.curAnim != null){ //my bad i was upset
		if(animation.curAnim.name == 'confirm' && !pixelNotes.contains(daStyle)) {
			centerOrigin();
		//}
		}	

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if(animation.curAnim == null || animation.curAnim.name == 'static') 
		{
		
		} 
		else 
		{
			if(animation.curAnim.name == 'confirm' && !pixelNotes.contains(daStyle))
				centerOrigin();
		}
	}
}
