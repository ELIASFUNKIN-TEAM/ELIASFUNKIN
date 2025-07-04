package states;

import backend.Language;
import backend.MusicBeatSubstate;
import flixel.FlxG;

class PatchnotesSubState extends MusicBeatSubstate {
	/// Array
	private var patchListArray:Array<String> = [
		'Demo'
	];
	private var patchTextArray:Array<String> = [
		'Nothing',
		'if you see this,',
		'you have a very critcal error.',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'',
		'why',
	];

	/// sprites and others
	// most important things
	private var patchPopup:FlxSprite;
	private var patchBack:FlxSprite;
	private var patchClose:FlxSprite;
	private var patchText:FlxText;

	// not important things
	private var screenArea:FlxPoint = new FlxPoint(0, 0);

	/// tweens
	private var screenAreaTween:FlxTween;
	private var buttColorTween:FlxTween;
	private var ckboxColorTween:FlxTween;

	/// shortcut
	var opPopL:Float;
	var opPopR:Float;
	var opBckT:Float;
	var opBckB:Float;

	public function new() {
		super();
		screenArea.set(.75, .75);
	}

	override function create() {
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Patchnotes", null);
		#end

		var blackBlur:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBlur.alpha = 0.2;
		blackBlur.scrollFactor.set();
		blackBlur.antialiasing = ClientPrefs.data.antialiasing;
		blackBlur.updateHitbox();
		blackBlur.screenCenter();
		add(blackBlur);

		patchPopup = new FlxSprite().loadGraphic(Paths.image('options/popup'));
		patchPopup.scrollFactor.set();
		patchPopup.screenCenter();
		opPopL = patchPopup.x;
		opPopR = patchPopup.x + patchPopup.width;
		patchPopup.scale.set(screenArea.x, screenArea.y);
		patchPopup.updateHitbox();
		patchPopup.antialiasing = ClientPrefs.data.antialiasing;

		patchBack = new FlxSprite().loadGraphic(Paths.image('options/back'));
		patchBack.centerOffsets();
		patchBack.scrollFactor.set();
		patchBack.setPosition(opPopL + (patchPopup.width / 2) - (patchBack.width / 2), patchPopup.y + (130 * screenArea.y));
		opBckT = patchBack.y;
		opBckB = patchBack.y + patchBack.height;
		patchBack.scale.set(screenArea.x, screenArea.y);
		patchBack.updateHitbox();
		patchBack.antialiasing = ClientPrefs.data.antialiasing;

		add(patchBack);
		add(patchPopup);

		patchClose = new FlxSprite().loadGraphic(Paths.image('options/x'));
		patchClose.scale.set(screenArea.x, screenArea.y);
		patchClose.scrollFactor.set();
		patchClose.antialiasing = ClientPrefs.data.antialiasing;
		add(patchClose);

		patchText = new FlxText(0, 0, 0, Language.getPhrase("options_title", "Options"), 48);
		patchText.setFormat(Paths.font("mobileone.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		patchText.scrollFactor.set();
		patchText.setPosition(patchPopup.x + (patchPopup.width / 2) - (patchText.width / 2), patchPopup.y + 15);
		patchText.antialiasing = ClientPrefs.data.antialiasing;
		add(patchText);

		screenAreaTween = FlxTween.tween(screenArea, {x: 1.0, y: 1.0}, 0.3, {ease: FlxEase.backOut});

		// i hate cameras, but i like them (what the)
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		// and super.__init__() (not)
		super.create();
	}

	override function destroy()
	{
		super.destroy();
	}
}