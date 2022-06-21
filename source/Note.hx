package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:Int = 0;
	public var style:String = "";
	public var originalHeightForCalcs:Float = 6;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var earlyHitMult:Float = 1;
	public var lateHitMult:Float = 1;
	public var rawNoteData:Int = 0;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var hitCausesMiss:Bool = false;
	public var gfNote:Bool = false;
	public var ignoreNote:Bool = false;
	public var canMiss:Bool = false;
	public var noRating:Bool = false;
	public var downscroll:Bool = false; //just use false for upscroll

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var noteScale:Float;
	public static var scales:Array<Float> = [0.7, 0.6, 0.46, 0.66, 0.55];
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var distance:Float = 2000; //plan on doing scroll directions soon -bb
	public var noAnimation:Bool = false;

	public var noteYOff:Int = 0;
	public static var swidths:Array<Float> = [160, 120, 90, 140, 110];

	public var rating:String = "shit";

	public function resizeByRatio(ratio:Float) //haha funny twitter shit
		{
			if(isSustainNote && !animation.curAnim.name.endsWith('end'))
			{
				scale.y *= ratio;
				updateHitbox();
			}
		}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?noteType:Int = 0, style:String = 'normal')
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.noteType = noteType;
		isSustainNote = sustainNote;
		this.style = style;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		swagWidth = swidths[0] * 0.7; //factor not the same as noteScale
		noteScale = scales[0];

		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		//defaults if no noteStyle was found in chart
		var noteTypeCheck:String = 'normal';

		switch (style)
		{
			case 'pixel':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels','week6'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds','week6'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
			case 'normal':
				frames = Paths.getSparrowAtlas('NOTE_assets');
					
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
		
				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');
		
				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
		
				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');
				animation.addByPrefix('blueholdend', 'blue hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		switch (noteType)
		{
			case 2:// hurt note
				frames = Paths.getSparrowAtlas('notes/HURTNOTE_assets');
				playNoteAnim();
		}

		switch (noteData)
		{
		}
		var frameN:Array<String> = ['purple', 'blue', 'green', 'red'];
		x += swidths[0] * swagWidth * (noteData % 4);
		if (!isSustainNote)
			animation.play(frameN[noteData] + 'Scroll');

		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed, 2));

		if (isSustainNote && prevNote != null)
		{
			noteYOff = Math.round(-stepHeight + swagWidth * 0.5);
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
			}

			animation.play(frameN[noteData] + 'holdend');
			updateHitbox();

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
				}
				prevNote.animation.play(frameN[prevNote.noteData] + 'hold');
				prevNote.updateHitbox();

				prevNote.scale.y *= stepHeight / prevNote.height;
				prevNote.updateHitbox();
				
				if (antialiasing)
					prevNote.scale.y *= 1.0 + (1.0 / prevNote.frameHeight);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.save.data.downscroll && isSustainNote) 
			flipY = true;

		if (noteData == -1)
			this.kill(); //removes psych event arrows when porting charts from psych.

		if (mustPress)
		{
			switch (noteType)
			{
				default:
					if (isSustainNote)
						{
							if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
								&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
								canBeHit = true;
							else
								canBeHit = false;
						}
						else
						{
							if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
								&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
								canBeHit = true;
							else
								canBeHit = false;
						}
			}
		}
		else
		{
			canBeHit = false;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
	function playNoteAnim() {
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		animation.addByPrefix('purpleholdend', 'pruple end hold');
		animation.addByPrefix('greenholdend', 'green hold end');
		animation.addByPrefix('redholdend', 'red hold end');
		animation.addByPrefix('blueholdend', 'blue hold end');

		animation.addByPrefix('purplehold', 'purple hold piece');
		animation.addByPrefix('greenhold', 'green hold piece');
		animation.addByPrefix('redhold', 'red hold piece');
		animation.addByPrefix('bluehold', 'blue hold piece');

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}
}