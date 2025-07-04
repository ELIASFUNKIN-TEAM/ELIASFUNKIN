package options;

import objects.ButtBaseThing;
import backend.InputFormatter;
import backend.Language;
import backend.MusicBeatSubstate;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.util.FlxSpriteUtil;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.shapes.FlxShapeCircle;
import openfl.display.Shape;
import lime.system.Clipboard;
import objects.Character;
import objects.StrumNote;
import objects.Note;
import objects.NoteSplash;
import objects.Bar;
import options.Option;
import options.objects.*;
import substates.PauseSubState;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class OptionsSubState extends MusicBeatSubstate {
	/// Array
	private var outerOptions:Array<String> = [
		'Note Colors',
		'Controls',
		'Adjust Delay and Combo',
		'Graphics',
		'Visuals',
		'Gameplay'
		#if TRANSLATIONS_ALLOWED , 'Language' #end
	];
	private var innerOptions:Array<Option> = [];
	public var grpOptionButts:Array<ButtBaseThing> = []; // outer

	/// FlxTypedSpriteGroup
	private var visualedOptions:FlxSpriteGroup; // old innerOption

	/// selected
	public var oldSelected:Int = 0;
	public var curSelected:Int = 0;
	public var curInOp:Option;
	private var innerY:Array<Float> = [0, 0];
	private var curInnerY:Float = 0;

	/// static variable
	public static var onPlayState:Bool = false;
	public static var sliderHanding:Bool = false;

	/// copyright infringement (copyleft? idk)
	// originate from GraphicsSettingsSubState
	private var boyfriend:Character; // Friday Night Funkin's ugly and stupid blue-haired kid (why this kid is main protagonist? i hate this kid)

	// originate from VisualsSettingsSubState
	private var notes:FlxTypedGroup<StrumNote>;
	private var splashes:FlxTypedGroup<NoteSplash>;

	/// sprites and others
	// most important things
	private var optionPopup:FlxSprite;
	public var optionBack:FlxSprite;
	private var optionClose:FlxSprite;
	private var optionText:FlxText;

	// not important things
	public var doNotZooming:Bool = false;

	/// cams
	public var backCam:FlxCamera;
	public var optionCam:FlxCamera;
	public var frontCam:FlxCamera;

	// not important things
	public var otherCam:FlxCamera;

	/// shortcut
	var opPopL(get, never):Float;
	var opPopR(get, never):Float;
	var opBckT(get, never):Float;
	var opBckB(get, never):Float;

	public function new() {
		super();
		onPlayState = false;
	}

	override function create() {
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Options", null);
		#end

		if (!onPlayState) {
			otherCam = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
			otherCam.bgColor = 0x00000000;
			FlxG.cameras.add(otherCam, false);

			var blackBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBG.alpha = 0.2;
			blackBG.scrollFactor.set();
			blackBG.antialiasing = ClientPrefs.data.antialiasing;
			blackBG.updateHitbox();
			blackBG.screenCenter();
			add(blackBG);
			blackBG.camera = otherCam;
		}

		createUIs();
		settingCameras();
		changeOption(outerOptions[0]); // Trickal's option always first
		if (grpOptionButts != null && grpOptionButts[0] != null) grpOptionButts[0].isChecked = true;

		if (!doNotZooming) tweenUICams();

		// and super.__init__() (not)
		super.create();
	}

	private function createUIs() {
		optionPopup = new FlxSprite().loadGraphic(Paths.image('options/popup'));
		optionPopup.scrollFactor.set();
		optionPopup.screenCenter();
		optionPopup.updateHitbox();
		optionPopup.antialiasing = ClientPrefs.data.antialiasing;

		optionBack = new FlxSprite().loadGraphic(Paths.image('options/back'));
		optionBack.centerOffsets();
		optionBack.scrollFactor.set();
		optionBack.setPosition(opPopL + (optionPopup.width / 2) - (optionBack.width / 2), optionPopup.y + 100);
		optionBack.updateHitbox();
		optionBack.antialiasing = ClientPrefs.data.antialiasing;

		visualedOptions = new FlxSpriteGroup();

		add(optionBack);
		add(visualedOptions);
		add(optionPopup);

		optionClose = new FlxSprite().loadGraphic(Paths.image('x'));
		optionClose.setPosition(optionPopup.x + optionPopup.width - optionClose.width - 45, optionPopup.y + 15);
		optionClose.scrollFactor.set();
		add(optionClose);
		optionClose.visible = false;

		var xOffset:Float = opPopL;
		for (i in 0...outerOptions.length) {
			var butt = makeOuterButt(new ButtBaseThing(
				xOffset + 15,
				optionPopup.y + 80,
				outerOptions[i],
				'option_${outerOptions[i].replace(' ', '_').toLowerCase()}'
			));
			butt.onClickedUpCallback = makeNormallyOuterFunc(butt, i);
			add(butt);
			grpOptionButts.push(butt);

			xOffset += butt.width + 15;
		}

		optionText = new FlxText(0, 0, 0, Language.getPhrase("options_title", "Options"), 48);
		optionText.setFormat(Paths.font("mobileone.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		optionText.scrollFactor.set();
		optionText.setPosition(optionPopup.x + (optionPopup.width / 2) - (optionText.width / 2), optionPopup.y + 7);
		optionText.antialiasing = ClientPrefs.data.antialiasing;
		add(optionText);

		// originate from GraphicsSettingsSubState
		boyfriend = new Character(-20, 105, 'bf', false);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.65));
		boyfriend.updateHitbox();
		boyfriend.scrollFactor.set();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;
		add(boyfriend); // ugly adding

		// originate from VisualsSettingsSubState
		notes = new FlxTypedGroup<StrumNote>();
		splashes = new FlxTypedGroup<NoteSplash>();

		add(notes);
		add(splashes);
		notes.visible = false;
		splashes.visible = false;
		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(Math.round(12 + (490 / Note.colArray.length) * i), 290, i, 0);
			changeNoteSkin(note);
			notes.add(note);
			
			var splash:NoteSplash = new NoteSplash(0, 0, NoteSplash.defaultNoteSplash + NoteSplash.getSplashSkinPostfix());
			splash.inEditor = true;
			splash.babyArrow = note;
			splash.ID = i;
			splash.kill();
			splashes.add(splash);
		}

		comboObjects = new FlxSpriteGroup();
		comboObjects.visible = false;
		add(comboObjects);
	}

	private function settingCameras() {
		backCam = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		backCam.bgColor = 0x00000000;
		FlxG.cameras.add(backCam, false);

		optionCam = new FlxCamera(optionBack.x, optionBack.y + 40, Std.int(optionBack.width), Std.int(optionBack.height - 40));
		optionCam.bgColor = 0x00000000;
		FlxG.cameras.add(optionCam, false);

		frontCam = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		frontCam.bgColor = 0x00000000;
		FlxG.cameras.add(frontCam, false);

		optionBack.camera = backCam;
		visualedOptions.camera = optionCam;
		boyfriend.camera = optionCam;
		notes.camera = optionCam;
		splashes.camera = optionCam;
		optionPopup.camera = frontCam;
		optionText.camera = frontCam;
		for (butt in grpOptionButts) butt.camera = frontCam;
		optionText.camera = frontCam;
	}

	private function tweenUICams() {
		backCam.zoom = .75;
		optionCam.zoom = .75;
		frontCam.zoom = .75;

		FlxTween.tween(backCam, {zoom: 1}, .2, {ease: FlxEase.backOut});
		FlxTween.tween(optionCam, {zoom: 1}, .2, {ease: FlxEase.backOut});
		FlxTween.tween(frontCam, {zoom: 1}, .2, {ease: FlxEase.backOut});
	}

	/// moused
	var lastMouseX:Float = 0;
	var lastMouseY:Float = 0;
	var mouseClose:Float = 0;
	var timeNotMoving:Float = 0;
	var isDragging:Bool = false;
	var dragStartY:Float = 0;
	var dragStartOffset:Float = 0;

	/// keybinds
	var bindingKey:Bool = false;
	var bindingWhite:FlxSprite;
	var bindingText:FlxText;
	var bindingText2:FlxText;
	var holdingEsc:Float = 0;

	/// etc
	var scrollSpeed:Int = 1;
	var changedMusic:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.pressed.SHIFT) scrollSpeed = 2;
		else scrollSpeed = 1;

		visualedOptions.y = curInnerY;

		var popupOutedMouse:Bool = (!FlxG.mouse.overlaps(optionPopup, frontCam) && mouseClose >= 0.25);
		var overedCloseMouse:Bool = FlxG.mouse.overlaps(optionClose, frontCam);
		var isMouseClose:Bool = ((popupOutedMouse || overedCloseMouse) && FlxG.mouse.justPressed);
		if ((isMouseClose || (controls.BACK && !bindingKey)) && !onComboMenu) {
			if (outerOptions[curSelected] == 'Adjust Delay and Combo' && !onPlayState) FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
			if (curInOp != null) curInOp.notSelect();
			close();
			return;
		}

		handleInners(elapsed);

		updateMouseVisible(elapsed);

		if (mouseClose < 0.25) mouseClose += elapsed;
		else if (mouseClose > 0.25) mouseClose = 1;
	}

	override public function beatHit() {
		super.beatHit();

		if (outerOptions[curSelected] == 'Adjust Delay and Combo') beatHitAdjustOption();
	}

	/// handles for maintenance purposes
	function handleInners(elapsed:Float) {
		if (bindingKey) {
			updateBindingKey(elapsed);
			return;
		}
		else if (outerOptions[curSelected] == 'Note Colors') {
			updateNoteColorOption(elapsed);
			return;
		}
		else if (outerOptions[curSelected] == 'Adjust Delay and Combo') {
			updateAdjustOption(elapsed);
			return;
		}

		if (!sliderHanding) mouseMoving();
	}

	private function mouseMoving() {
		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(optionBack, backCam)) {
				isDragging = true;
				dragStartY = FlxG.mouse.y;
				dragStartOffset = curInnerY;
			}
		}
		else if (FlxG.mouse.justReleased) {
			isDragging = false;
		}
		else if (FlxG.mouse.overlaps(optionBack, backCam) && FlxG.mouse.wheel != 0) {
			curInnerY += FlxG.mouse.wheel * 40 * scrollSpeed;
			curInnerY = FlxMath.bound(curInnerY, innerY[1], innerY[0]);
		}

		if (isDragging) {
			curInnerY = dragStartOffset + (FlxG.mouse.y - dragStartY) * scrollSpeed;
			curInnerY = FlxMath.bound(curInnerY, innerY[1], innerY[0]);
		}
	}

	private function updateMouseVisible(elapsed:Float) {
		if ((FlxG.mouse.x != lastMouseX || FlxG.mouse.y != lastMouseY) || FlxG.mouse.justPressed) {
			timeNotMoving = 0;
			FlxG.mouse.visible = true;
			lastMouseX = FlxG.mouse.x;
			lastMouseY = FlxG.mouse.y;
		}
		else
		{
			timeNotMoving += elapsed;
			if (timeNotMoving > 2)
				FlxG.mouse.visible = false;
		}

		if (timeNotMoving > 2) FlxG.mouse.visible = false;
	}

	var tempSongPos:Float = 0;
	private function changeOption(str:String) {
		if (curInOp != null) curInOp.notSelect();

		deleteVisualOption();

		switch(str)
		{
			case 'Note Colors':
				makeVisualNoteColorOption();
				return;

			case 'Controls':
				innerOptions.push(new ControlOption('NOTES CONTROL', '', TITLE));
				innerOptions.push(new ControlOption('Note Left', 'note_left', KEYBIND));
				innerOptions.push(new ControlOption('Note Down', 'note_down', KEYBIND));
				innerOptions.push(new ControlOption('Note Up', 'note_up', KEYBIND));
				innerOptions.push(new ControlOption('Note Right', 'note_right', KEYBIND));

				innerOptions.push(new ControlOption('UI CONTROL', '', TITLE));
				innerOptions.push(new ControlOption('UI Left', 'ui_left', KEYBIND));
				innerOptions.push(new ControlOption('UI Down', 'ui_down', KEYBIND));
				innerOptions.push(new ControlOption('UI Up', 'ui_up', KEYBIND));
				innerOptions.push(new ControlOption('UI Right', 'ui_right', KEYBIND));

				innerOptions.push(new ControlOption('GAME CONTROL', '', TITLE));
				innerOptions.push(new ControlOption('Reset', 'reset', KEYBIND));
				innerOptions.push(new ControlOption('Accept', 'accept', KEYBIND));
				innerOptions.push(new ControlOption('Back', 'back', KEYBIND));
				innerOptions.push(new ControlOption('Pause', 'pause', KEYBIND));

				innerOptions.push(new ControlOption('VOLUME CONTROL', '', TITLE));
				innerOptions.push(new ControlOption('Mute', 'volume_mute', KEYBIND));
				innerOptions.push(new ControlOption('Volume Up', 'volume_up', KEYBIND));
				innerOptions.push(new ControlOption('Volume Down', 'volume_down', KEYBIND));

				innerOptions.push(new ControlOption('DEBUG CONTROL', '', TITLE));
				innerOptions.push(new ControlOption('Debug Key 1', 'debug_1', KEYBIND));
				innerOptions.push(new ControlOption('Debug Key 2', 'debug_2', KEYBIND));

			case 'Adjust Delay and Combo':
				makeVisualAdjustOption();
				return;

			case 'Graphics':
				innerOptions.push(new Option('GRAPHIC', '', TITLE));
				innerOptions.push(new Option('Low Quality', 'lowQuality', BOOL));

				var option:Option = new Option('Anti-Aliasing', 'antialiasing', BOOL);
				option.onSelect = function() {
					boyfriend.visible = true;
				}
				option.onChange = function() {
					for (sprite in members)
					{
						var sprite:FlxSprite = cast sprite;
						if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) sprite.antialiasing = ClientPrefs.data.antialiasing;
					}
				};
				option.onNotSelect = function() {
					boyfriend.visible = false;
				}
				innerOptions.push(option);

				innerOptions.push(new Option('Shaders', 'shaders', BOOL));
				innerOptions.push(new Option('GPU Caching', 'cacheOnGPU', BOOL));

				#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
				var option:Option = new Option('Framerate', 'framerate', INT);				
				option.minValue = 60;
				option.maxValue = 240;
				option.defaultValue = Std.int(FlxMath.bound(FlxG.stage.application.window.displayMode.refreshRate, option.minValue, option.maxValue));
				option.displayFormat = '%v FPS';
				option.onChange = function() {
					if(ClientPrefs.data.framerate > FlxG.drawFramerate)
					{
						FlxG.updateFramerate = ClientPrefs.data.framerate;
						FlxG.drawFramerate = ClientPrefs.data.framerate;
					}
					else
					{
						FlxG.drawFramerate = ClientPrefs.data.framerate;
						FlxG.updateFramerate = ClientPrefs.data.framerate;
					}
				};
				innerOptions.push(option);
				#end

			case 'Visuals':
				innerOptions.push(new Option('NOTES VISUAL', '', TITLE));
		
				var noteSkins:Array<String> = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
				if(noteSkins.length > 0)
				{
					if(!noteSkins.contains(ClientPrefs.data.noteSkin))
						ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; //Reset to default if saved noteskin couldnt be found

					noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); //Default skin always comes first
					var option:Option = new Option('Note Skins', 'noteSkin', STRING, noteSkins[0], noteSkins);
					innerOptions.push(option);
					option.onSelect = function() {
						notes.visible = true;
					}
					option.onChange = function() {
						notes.forEachAlive(function(note:StrumNote) {
							changeNoteSkin(note);
							note.centerOffsets();
							note.centerOrigin();
						});
					};
					option.onNotSelect = function() {
						notes.visible = false;
					}
				}
				
				var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
				if(noteSplashes.length > 0)
				{
					if(!noteSplashes.contains(ClientPrefs.data.splashSkin))
						ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved splashskin couldnt be found

					noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); //Default skin always comes first
					var option:Option = new Option('Note Splashes', 'splashSkin', STRING, noteSplashes[0], noteSplashes);
					innerOptions.push(option);
					option.onSelect = function() {
						notes.visible = true;
						splashes.visible = true;
					}
					option.onChange = function() {
						var skin:String = NoteSplash.defaultNoteSplash + NoteSplash.getSplashSkinPostfix();
						for (splash in splashes)
							splash.loadSplash(skin);

						playNoteSplashes();

						if(option.variable.startsWith('splash') && Math.abs(notes.members[0].y) < 25) playNoteSplashes();
					};
					option.onNotSelect = function() {
						notes.visible = false;
						splashes.visible = false;
					}
				}

				var option:Option = new Option('Note Splash Opacity', 'splashAlpha', PERCENT);
				option.scrollSpeed = 1.6;
				option.minValue = 0.0;
				option.maxValue = 1;
				option.changeValue = 0.1;
				option.decimals = 1;
				innerOptions.push(option);
				option.onSelect = function() {
					notes.visible = true;
					splashes.visible = true;
				}
				option.onChange = function() {
					splashes.forEachAlive(function(splash:NoteSplash) {
						splash.alpha = option.value;
					});
				};
				option.onNotSelect = function() {
					notes.visible = false;
					splashes.visible = false;
				}

				innerOptions.push(new Option('HUD VISUAL', '', TITLE));
				innerOptions.push(new Option('Hide HUD', 'hideHud', BOOL));
				innerOptions.push(new Option('Time Bar', 'timeBarType', STRING, 'Time Left', ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']));
				innerOptions.push(new Option('Health Bar Opacity', 'healthBarAlpha', PERCENT));

				innerOptions.push(new Option('DIALOGUE AND TEXT VISUAL', '', TITLE));
				innerOptions.push(new Option('Text Size', 'textSize', STRING, 'Middle', ['Small', 'Middle', 'Large', 'Very Large']));
				innerOptions.push(new Option('Text Speed', 'textSpeed', STRING, 'Fast', ['None', 'Slow', 'Middle', 'Fast']));
				innerOptions.push(new Option('Interaction', 'interaction', BOOL));

				innerOptions.push(new Option('ETC VISUAL', '', TITLE));

				#if !mobile
				var option:Option = new Option('FPS Counter', 'showFPS', BOOL, 60);
				innerOptions.push(option);
				option.onChange = function() {
					if(Main.fpsVar != null)
						Main.fpsVar.visible = ClientPrefs.data.showFPS;
				};
				#end

				innerOptions.push(new Option('Flashing Lights', 'flashing', BOOL));
				innerOptions.push(new Option('Camera Zooms', 'camZooms', BOOL));
				innerOptions.push(new Option('Score Text Grow on Hit', 'scoreZoom', BOOL));

				var option:Option = new Option('Pause Music', 'pauseMusic', STRING, 'This Is Awkward (Safahire Mix)', ['None', 'This Is Awkward (Safahire Mix)', 'Tea Time', 'Breakfast', 'Breakfast (Pico Mix)']);
				innerOptions.push(option);
				option.onChange = option.onSelect = function() {
					if(ClientPrefs.data.pauseMusic == 'None')
						FlxG.sound.music.volume = 0;
					else {
						if (onPlayState && PauseSubState.pauseMusic.playing) PauseSubState.pauseMusic.stop();
						FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));
					}
					changedMusic = true;
				};
				option.onNotSelect = function() {
					if(changedMusic && !onPlayState) FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
					else if (changedMusic && onPlayState) {
						FlxG.sound.music.stop();
						try {
							PauseSubState.pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
						}
						catch (e:Dynamic) {}
						PauseSubState.pauseMusic.play(false);
						if(ClientPrefs.data.pauseMusic != 'None') PauseSubState.pauseMusic.volume = .5;
					}
					changedMusic = false;
				}

				innerOptions.push(new Option('Discord Rich Presence', 'discordRPC', BOOL));

				var option:Option = new Option('Health Bar Opacity', 'healthBarAlpha', PERCENT);
				option.scrollSpeed = 1.6;
				option.minValue = 0.0;
				option.maxValue = 1;
				option.changeValue = 0.1;
				option.decimals = 1;
				innerOptions.push(option);

				innerOptions.push(new Option('Combo Stacking', 'comboStacking', BOOL));

			case 'Gameplay':
				innerOptions.push(new Option('GAMEPLAY', '', TITLE));
				innerOptions.push(new Option('Opponent Notes', 'opponentStrums', BOOL));
				innerOptions.push(new Option('Ghost Tapping', 'ghostTapping', BOOL));

				var option:Option = new Option('Auto Pause', 'autoPause', BOOL);
				innerOptions.push(option);
				option.onChange = function() {
					FlxG.autoPause = ClientPrefs.data.autoPause;
				};

				innerOptions.push(new Option('Disable Reset Button', 'noReset', BOOL));
				innerOptions.push(new Option('Sustains as One Note', 'guitarHeroSustains', BOOL));

				var option:Option = new Option('Hitsound Volume', 'hitsoundVolume', PERCENT);
				option.scrollSpeed = 1.6;
				option.minValue = 0.0;
				option.maxValue = 1;
				option.changeValue = 0.1;
				option.decimals = 1;
				innerOptions.push(option);
				option.onChange = function() {
					FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);
				};
				innerOptions.push(new Option('SCROLL', '', TITLE));
				innerOptions.push(new Option('Downscroll', 'downScroll', BOOL));
				innerOptions.push(new Option('Middlescroll', 'middleScroll', BOOL));
				innerOptions.push(new GameplayOption('INGAME', '', TITLE));
				innerOptions.push(new GameplayOption('Scroll Type', 'scrolltype', STRING, 'multiplicative', ['multiplicative', 'constant']));

				var option:GameplayOption = new GameplayOption('Scroll Speed', 'scrollspeed', FLOAT, 1);
				option.scrollSpeed = 2.0;
				option.minValue = 0.35;
				option.changeValue = 0.05;
				option.decimals = 2;
				if (innerOptions[innerOptions.length - 1].value != 'constant') {
					option.displayFormat = '%vX';
					option.maxValue = 3;
				}
				else {
					option.displayFormat = "%v";
					option.maxValue = 6;
				}
				innerOptions.push(option);

				#if FLX_PITCH
				var option:GameplayOption = new GameplayOption('Playback Rate', 'songspeed', FLOAT, 1);
				option.scrollSpeed = 1;
				option.minValue = 0.5;
				option.maxValue = 3.0;
				option.changeValue = 0.05;
				option.displayFormat = '%vX';
				option.decimals = 2;
				innerOptions.push(option);
				#end

				var option:GameplayOption = new GameplayOption('Health Gain Multiplier', 'healthgain', FLOAT);
				option.scrollSpeed = 2.5;
				option.minValue = 0;
				option.maxValue = 5;
				option.changeValue = 0.1;
				option.displayFormat = '%vX';
				innerOptions.push(option);

				var option:GameplayOption = new GameplayOption('Health Loss Multiplier', 'healthloss', FLOAT);
				option.scrollSpeed = 2.5;
				option.minValue = 0.5;
				option.maxValue = 5;
				option.changeValue = 0.1;
				option.displayFormat = '%vX';
				innerOptions.push(option);

				innerOptions.push(new GameplayOption('FC Mode', 'instakill', BOOL));
				innerOptions.push(new GameplayOption('Practice Mode', 'practice', BOOL));
				innerOptions.push(new GameplayOption('Botplay', 'botplay', BOOL));
				innerOptions.push(new Option('RATING', '', TITLE));

				var option:Option = new Option('Rating Offset', 'ratingOffset', INT);
				option.displayFormat = '%vms';
				option.scrollSpeed = 20;
				option.minValue = -30;
				option.maxValue = 30;
				innerOptions.push(option);

				var option:Option = new Option('Sick! Hit Window', 'sickWindow', FLOAT);
				option.displayFormat = '%vms';
				option.scrollSpeed = 15;
				option.minValue = 15.0;
				option.maxValue = 45.0;
				option.changeValue = 0.1;
				innerOptions.push(option);

				var option:Option = new Option('Good Hit Window', 'goodWindow', FLOAT);
				option.displayFormat = '%vms';
				option.scrollSpeed = 30;
				option.minValue = 15.0;
				option.maxValue = 90.0;
				option.changeValue = 0.1;
				innerOptions.push(option);

				var option:Option = new Option('Bad Hit Window', 'badWindow', FLOAT);
				option.displayFormat = '%vms';
				option.scrollSpeed = 60;
				option.minValue = 15.0;
				option.maxValue = 135.0;
				option.changeValue = 0.1;
				innerOptions.push(option);

				var option:Option = new Option('Safe Frames', 'safeFrames', FLOAT);
				option.scrollSpeed = 5;
				option.minValue = 2;
				option.maxValue = 10;
				option.changeValue = 0.1;
				innerOptions.push(option);

			case 'Language':
				var languages:Array<String> = []; // en-US
				var namedLanguages:Array<String> = []; // English (US)
				namedLanguages.push(Language.defaultLangName);
				languages.push(ClientPrefs.defaultData.language);

				var directories:Array<String> = Mods.directoriesWithFile(Paths.getSharedPath(), 'data/');
				for (directory in directories)
				{
					for (file in FileSystem.readDirectory(directory))
					{
						if(file.toLowerCase().endsWith('.lang'))
						{
							var langFile:String = file.substring(0, file.length - '.lang'.length).trim();
							if(!languages.contains(langFile))
							{
								languages.push(langFile);

								var path:String = '$directory/$file';
								#if MODS_ALLOWED 
								var txt:String = File.getContent(path);
								#else
								var txt:String = Assets.getText(path);
								#end

								var id:Int = txt.indexOf('\n');
								if(id > 0) //language display name shouldnt be an empty string or null
								{
									var name:String = txt.substr(0, id).trim();
									if(!name.contains(':')) namedLanguages.push(name);
								}
								else if(txt.trim().length > 0 && !txt.contains(':')) namedLanguages.push(txt.trim());
							}
						}
					}
				}

				innerOptions.push(new Option('LANGUAGE', '', TITLE));
				var option:Option = new Option('Language', 'language', STRING, namedLanguages[0], namedLanguages);
				option.onChange = function() {
					Language.reloadPhrases();
					return;
				};
				option.onNotSelect = function() {
					FlxG.resetState();
					FlxG.state.openSubState(this);
					return;
				};
				innerOptions.push(option);
		}

		makeVisualOption();
	}

	private function makeVisualOption() {
		innerY = [];
		var yOffset:Float = 0;
		innerY.push(yOffset);

		for (option in innerOptions) {
			var pos:Float = 0;
			if (option.type != TITLE) {
				var nameBG = new FlxSprite().makeGraphic(290, 34, FlxColor.TRANSPARENT);
				nameBG.updateHitbox();
				FlxSpriteUtil.drawRoundRect(nameBG, 0, 0, nameBG.width, nameBG.height, 16, 16, FlxColor.fromString('#CBEA84'));
				nameBG.scrollFactor.set();
				nameBG.setPosition(20, yOffset);
				visualedOptions.add(nameBG);

				var name = new FlxText(0, 0, nameBG.width, option.name, 23);
				name.setFormat(Paths.font("mobileone.ttf"), 24, FlxColor.fromString('#606560'), CENTER, FlxTextBorderStyle.NONE);
				name.setPosition(nameBG.x, yOffset);
				name.scrollFactor.set();
				name.updateHitbox();
				visualedOptions.add(name);

				pos = nameBG.width + 25 + (optionBack.width - nameBG.width) / 2;

				switch (option.type) {
					case INT | FLOAT | PERCENT:
						var onUpdate:Void->Void = null;

						if (option.unlanguaged_name == 'Scroll Speed') {
							var scrollType:GameplayOption = cast innerOptions[innerOptions.indexOf(option) - 1];
							onUpdate = function() {
								if (scrollType.value != 'constant') {
									option.displayFormat = '%vX';
									option.maxValue = 3;
								}
								else {
									option.displayFormat = "%v";
									option.maxValue = 6;
								}
							}
						}

						visualedOptions.add(new HateSlider(nameBG.width + 95, yOffset, option, onUpdate, optionCam));

					case STRING | BOOL:
						var tempBox = new FlxSprite().loadGraphic(Paths.image('options/checkbox'));
						var boxWidth:Float = tempBox.width + 20;
						tempBox.destroy();

						var len:Int = (option.options != null) ? option.options.length : 2;

						var totalWidth:Float = len * boxWidth;
						var startX:Float = pos - totalWidth / 2;

						for (i in 0...len) {
							var phraseName:String;
							var label:String;
							if (option.type == STRING) {
								phraseName = 'setting_${option.name}-${option.options[i]}';
								label = option.options[i];
							}
							else {
								phraseName = 'options_${i == 0 ? "on" : "off"}';
								label = i == 0 ? 'On' : 'Off';
							}

							var ckOption:Dynamic = option.type == STRING ? label : (i == 0 ? true : false);
							if (option.name == 'Language') {
								ckOption = i == 0 ? 'en-US' : 'ko-KR';
							}
							var gameplayOption:GameplayOption = null;

							if (Std.isOfType(option, GameplayOption))
								gameplayOption = cast(option, GameplayOption);

							var ckbox:ButtBaseThing = makeCheckButt(new ButtBaseThing(
								startX + i * boxWidth,
								yOffset + 1,
								label,
								phraseName
							));
							ckbox.onClickedUpCallback = makeCheckFunc(ckbox, option, ckOption, gameplayOption);
							if (gameplayOption != null)
								ckbox.isChecked = ckOption == gameplayOption.value;
							else
								ckbox.isChecked = ckOption == option.value;

							visualedOptions.add(ckbox);
							option.boxes.push(ckbox);
						}

					case KEYBIND:
						var keys = ClientPrefs.keyBinds.get(option.variable);

						var tempBox = new FlxSprite().loadGraphic(Paths.image('options/checkbox'));
						var boxWidth:Float = tempBox.width + 20;
						tempBox.destroy();

						var len:Int = 2;

						var totalWidth:Float = len * boxWidth;
						var startX:Float = pos - totalWidth / 2;

						for (i in 0...len) {
							var keyText = (i >= keys.length || keys[i] == NONE) ? 'None' : InputFormatter.getKeyName(keys[i]);

							var butt:ButtBaseThing = makeKeyButt(new ButtBaseThing(
								startX + i * boxWidth,
								yOffset + 1,
								keyText,
								'null'
							));
							butt.onClickedUpCallback = makeKeyFunc(butt, option);

							visualedOptions.add(butt);
							option.boxes.push(butt);
						}

					default:
				}
			}
			else {
				if (innerOptions.indexOf(option) != 1) yOffset += 55; // up space

				var nameBG = new FlxSprite().makeGraphic(1080, 37, FlxColor.TRANSPARENT);
				nameBG.updateHitbox();
				FlxSpriteUtil.drawRoundRect(nameBG, 0, 0, nameBG.width, nameBG.height, 16, 16, FlxColor.fromString('#E0F0A9'));
				nameBG.scrollFactor.set();
				nameBG.setPosition((optionBack.width - nameBG.width) / 2, yOffset);
				visualedOptions.add(nameBG);

				var name = new FlxText(0, 0, nameBG.width, option.name, 15);
				name.setFormat(Paths.font("mobileone.ttf"), 15, FlxColor.BLACK, CENTER, FlxTextBorderStyle.NONE);
				name.setPosition(nameBG.x, yOffset + name.height / 2);
				name.scrollFactor.set();
				name.updateHitbox();
				visualedOptions.add(name);
			}

			yOffset += 55;
		}
		innerY.push(-yOffset + 150);
		curInnerY = innerY[0];
	}

	private function deleteVisualOption() {
		if (visualedOptions == null) return;

		visualedOptions.forEach(function(spr:FlxSprite) {
			if (spr != null) spr.destroy();
		});
		visualedOptions.clear();

		comboObjects.forEach(function(spr:FlxSprite) {
			if (spr != null) spr.destroy();
		});
		comboObjects.clear();

		if (hudObjects.length > 0)
			for (obj in hudObjects)
				if (obj != null) obj.destroy();

		hudObjects = [];

		innerOptions = [];

		onModeColumn = true;
		curSelectedMode = 0;
		curSelectedNote = 0;
		onPixel = false;
		dataArray = null;
	}

	// ButtFuncs
	function makeNormallyOuterFunc(butt:ButtBaseThing, index:Int):Void->Void {
		return function() {
			if (!butt.isChecked && !onComboMenu) {
				for (butt in grpOptionButts)
					if (butt.isChecked)
						butt.isChecked = false;

				oldSelected = curSelected;
				if (outerOptions[oldSelected] == 'Adjust Delay and Combo' && onPlayState && ClientPrefs.data.pauseMusic != 'None') {
					FlxG.sound.music.stop();
					PauseSubState.pauseMusic.resume();
				}
				else if (outerOptions[oldSelected] == 'Adjust Delay and Combo' && !onPlayState) FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
				curSelected = index;

				if(zoomTween != null) zoomTween.cancel();
				if(beatTween != null) beatTween.cancel();
				optionCam.zoom = 1;

				changeOption(outerOptions[index]);
			}
		}
	}

	function makeOffsetModeOuterFunc(butt:ButtBaseThing):Void->Void {
		return function() {
			if (!offsetModeChangeButt.isChecked && !onComboMenu) {
				onComboMenu = true;
			}
		}
	}

	function makeCheckFunc(butt:ButtBaseThing, option:Option, ckOption:Dynamic, gameplayOption:GameplayOption = null):Void->Void {
		return function() {
			if (!butt.isChecked) {
				for (ckbox in option.boxes)
					if (ckbox.isChecked)
						ckbox.isChecked = false;

				if (curInOp != option) {
					if (curInOp != null) curInOp.notSelect();
					curInOp = option;
					curInOp.select();
				}

				if (gameplayOption != null)
					gameplayOption.value = ckOption;
				else
					option.value = ckOption;

				option.change();
			}
		}
	}

	function makeKeyFunc(butt:ButtBaseThing, option:Option):Void->Void {
		return function() {
			if (!butt.isChecked) {
				for (ckbox in option.boxes)
					if (ckbox.isChecked)
						ckbox.isChecked = false;

				if (curInOp != option) {
					if (curInOp != null) curInOp.notSelect();
					curInOp = option;
					curInOp.select();
				}

				startKeyBinding();
			}
		}
	}

	// ButtBaseThing
	function makeOuterButt(butt:ButtBaseThing):ButtBaseThing {
		butt.label.setFormat(Paths.font("mobileone.ttf"), butt.text.length < 9 ? 24 : 24 - Std.int(butt.text.length / 4), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		butt.label.setPosition(butt.x + butt.width / 2 - butt.label.width / 2, butt.y + butt.height / 2 - butt.label.height / 2);
		butt.label.drawFrame(true);
		butt.onClickingCallback = function() {
			if (!butt.isChecked && !onComboMenu) 
				butt.colorTween = FlxTween.color(butt, 0.03, butt.color, 0xFF444444);
		}
		butt.checkedCondition = function() {
			if (!onComboMenu)
				butt.isChecked = true;
		}
		butt.customUpdateLabelPosition = function(spr:FlxSprite) {
			var labelOffsetX = butt.labelOffsets[butt.status].x;
			var labelOffsetY = butt.labelOffsets[butt.status].y;
			spr.x = (spr.pixelPerfectPosition ? Math.floor(butt.x) : butt.x) + labelOffsetX;
			spr.y = spr.pixelPerfectPosition ? Math.floor(butt.y + labelOffsetY / 2) : butt.y + 10 + (butt.text.length < 9 ? 0 : Std.int(butt.text.length / 10));
		}
		butt.isChecked = false;
		return butt;
	}

	function makeCheckButt(butt:ButtBaseThing):ButtBaseThing {
		butt.label.setFormat(Paths.font("mobileone.ttf"), butt.text.length < 10 ? 18 : 18 - Std.int(butt.text.length / 4), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		butt.label.setPosition(butt.x + butt.width / 2 - butt.label.width / 2, butt.y + butt.height / 2 - butt.label.height / 2);
		butt.label.drawFrame(true);
		butt.ckedGraphic = Paths.image('options/checked-checkbox');
		butt.unckedGraphic = Paths.image('options/checkbox');
		butt.onClickingCallback = function() {
			if (!butt.isChecked)
				butt.colorTween = FlxTween.color(butt, 0.03, butt.color, 0xFF444444);
		}
		butt.customUpdateLabelPosition = function(spr:FlxSprite) {
			var labelOffsetX = butt.labelOffsets[butt.status].x;
			var labelOffsetY = butt.labelOffsets[butt.status].y;
			spr.x = (butt.pixelPerfectPosition ? Math.floor(butt.x) : butt.x) + labelOffsetX;
			spr.y = butt.pixelPerfectPosition ? Math.floor(butt.y + labelOffsetY / 2) : butt.y + labelOffsetY / 2 + (butt.text.length < 10 ? 4 : 4 + Std.int(butt.text.length / 9.5));
		}
		return butt;
	}

	function makeKeyButt(butt:ButtBaseThing):ButtBaseThing {
		butt.label.setFormat(Paths.font("mobileone.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		butt.label.setPosition(butt.x + butt.width / 2 - butt.label.width / 2, butt.y + butt.height / 2 - butt.label.height / 2);
		butt.label.drawFrame(true);
		butt.ckedGraphic = Paths.image('options/checked-keybutton');
		butt.unckedGraphic = Paths.image('options/keybutton');
		butt.onClickingCallback = function() {
			if (!butt.isChecked) 
				butt.colorTween = FlxTween.color(butt, 0.03, butt.color, 0xFF444444);
		}
		butt.isChecked = false;
		return butt;
	}

	// originate from NotesColorSubState (NotesColorSubState's new function and etc)
	var colorgrid:FlxBackdrop;
	var onModeColumn:Bool = true;
	var curSelectedMode:Int = 0;
	var curSelectedNote:Int = 0;
	var onPixel:Bool = false;
	var dataArray:Array<Array<FlxColor>>;
	var copyButton:FlxSprite;
	var pasteButton:FlxSprite;
	var colorGradient:FlxSprite;
	var colorGradientSelector:FlxSprite;
	var colorPalette:FlxSprite;
	var colorWheel:FlxSprite;
	var colorWheelSelector:FlxSprite;
	var alphabetR:FlxText;
	var alphabetG:FlxText;
	var alphabetB:FlxText;
	var alphabetHex:FlxText;
	var modeBG:FlxSprite;
	var notesBG:FlxSprite;
	var tipTxt1:FlxText;
	var tipTxt2:FlxText;
	var colorbg1:FlxSprite;
	var colorbg2:FlxSprite;
	var ctrltext:FlxText;

	private function makeVisualNoteColorOption() {
		innerY = [0, 0];
		curInnerY = innerY[0];

		colorgrid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x45CBEA84, 0x0));
		colorgrid.velocity.set(40, 40);
		colorgrid.alpha = 0;
		FlxTween.tween(colorgrid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		visualedOptions.add(colorgrid);

		modeBG = new FlxSprite(215, 85).makeGraphic(315, 115, FlxColor.BLACK);
		modeBG.visible = false;
		modeBG.alpha = 0.4;
		visualedOptions.add(modeBG);

		notesBG = new FlxSprite(140, 190).makeGraphic(480, 125, FlxColor.BLACK);
		notesBG.visible = false;
		notesBG.alpha = 0.4;
		visualedOptions.add(notesBG);

		modeNotes = new FlxSpriteGroup();
		visualedOptions.add(modeNotes);

		myNotes = new FlxTypedSpriteGroup<StrumNote>();
		visualedOptions.add(myNotes);

		colorbg1 = new FlxSprite(580).makeGraphic(Std.int(optionBack.width - 580), Std.int(optionBack.height - 40), FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRoundRect(colorbg1, 0, 0, colorbg1.width, colorbg1.height, 50, 50, FlxColor.BLACK);
		colorbg1.alpha = 0.25;
		visualedOptions.add(colorbg1);

		colorbg2 = new FlxSprite(610, 100).makeGraphic(Std.int(optionBack.width - 640), 340, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRoundRect(colorbg2, 0, 0, colorbg2.width, colorbg2.height, 16, 16, FlxColor.BLACK);
		colorbg2.alpha = 0.25;
		visualedOptions.add(colorbg2);
		
		ctrltext = new FlxText(21, 55, 0, 'CTRL', 18);
		ctrltext.setFormat(Paths.font("mobileone.ttf"), 18, FlxColor.BLACK, CENTER, FlxTextBorderStyle.NONE);
		visualedOptions.add(ctrltext);

		copyButton = new FlxSprite().loadGraphic(Paths.image('noteColorMenu/copy'));
		copyButton.setGraphicSize(copyButton.width / 1.2, copyButton.height / 1.2);
		copyButton.updateHitbox();
		copyButton.setPosition(630, 25);
		copyButton.alpha = 0.6;
		visualedOptions.add(copyButton);

		pasteButton = new FlxSprite().loadGraphic(Paths.image('noteColorMenu/paste'));
		pasteButton.setGraphicSize(pasteButton.width / 1.2, pasteButton.height / 1.2);
		pasteButton.updateHitbox();
		pasteButton.setPosition(1020, 25);
		pasteButton.alpha = 0.6;
		visualedOptions.add(pasteButton);

		colorGradient = FlxGradient.createGradientFlxSprite(55, 200, [FlxColor.WHITE, FlxColor.BLACK]);
		colorGradient.setPosition(640, 130);
		visualedOptions.add(colorGradient);

		colorGradientSelector = new FlxSprite(635, 120).makeGraphic(65, 5, FlxColor.WHITE);
		colorGradientSelector.offset.y = 2;
		visualedOptions.add(colorGradientSelector);

		colorPalette = new FlxSprite().loadGraphic(Paths.image('noteColorMenu/palette', false));
		colorPalette.setGraphicSize(colorPalette.width * 20, colorPalette.height * 20);
		colorPalette.updateHitbox();
		colorPalette.setPosition(700, 358);
		colorPalette.antialiasing = false;
		visualedOptions.add(colorPalette);
		
		colorWheel = new FlxSprite().loadGraphic(Paths.image('noteColorMenu/colorWheel'));
		colorWheel.setGraphicSize(200, 200);
		colorWheel.updateHitbox();
		colorWheel.setPosition(770, 130);
		visualedOptions.add(colorWheel);

		colorWheelSelector = new FlxShapeCircle(0, 0, 8, {thickness: 0}, FlxColor.WHITE);
		colorWheelSelector.offset.set(8, 8);
		colorWheelSelector.alpha = 0.6;
		visualedOptions.add(colorWheelSelector);

		var txtX = 780;
		var txtY = 60;
		alphabetR = new FlxText(txtX - 70, txtY, Std.int((colorbg1.width - 120) / 3), '0', 18);
		alphabetR.setFormat(Paths.font("mobileone.ttf"), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		visualedOptions.add(alphabetR);
		alphabetG = new FlxText(txtX, txtY, Std.int((colorbg1.width - 120) / 3), '0', 18);
		alphabetG.setFormat(Paths.font("mobileone.ttf"), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		visualedOptions.add(alphabetG);
		alphabetB = new FlxText(txtX + 70, txtY, Std.int((colorbg1.width - 120) / 3), '0', 18);
		alphabetB.setFormat(Paths.font("mobileone.ttf"), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		visualedOptions.add(alphabetB);
		alphabetHex = new FlxText(optionBack.width - colorbg1.width, txtY - 35, Std.int(colorbg1.width), '000000', 24);
		alphabetHex.setFormat(Paths.font("mobileone.ttf"), 34, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		visualedOptions.add(alphabetHex);

		spawnNotes();
		updateNotes(true);

		var tipX = 20;
		var tipY = optionBack.height - 89;
		tipTxt1 = new FlxText(tipX, tipY, 0, Language.getPhrase('note_colors_tip', 'Press RESET to Reset the selected Note Part.'), 14);
		tipTxt1.setFormat(Paths.font("mobileone.ttf"), 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipTxt1.borderSize = 2;
		visualedOptions.add(tipTxt1);

		tipTxt2 = new FlxText(tipX, tipY + 22, 0, '', 14);
		tipTxt2.setFormat(Paths.font("mobileone.ttf"), 14, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipTxt2.borderSize = 2;
		visualedOptions.add(tipTxt2);
		updateTip();

		settingNoteColorOptionCameras();
	}

	function updateTip()
	{
		var key:String = Language.getPhrase('note_colors_shift', 'Shift');
		tipTxt2.text = Language.getPhrase('note_colors_hold_tip', 'Hold {1} + Press RESET key to fully reset the selected Note.', [key]);
	}

	function settingNoteColorOptionCameras() {
		colorgrid.camera = optionCam;
		modeBG.camera = optionCam;
		notesBG.camera = optionCam;
		modeNotes.camera = optionCam;
		myNotes.camera = optionCam;
		colorbg1.camera = optionCam;
		colorbg2.camera = optionCam;
		ctrltext.camera = optionCam;
		notesBG.camera = optionCam;
		copyButton.camera = optionCam;
		pasteButton.camera = optionCam;
		colorGradient.camera = optionCam;
		colorGradientSelector.camera = optionCam;
		colorPalette.camera = optionCam;
		colorWheel.camera = optionCam;
		colorWheelSelector.camera = optionCam;
		alphabetR.camera = optionCam;
		alphabetG.camera = optionCam;
		alphabetB.camera = optionCam;
		alphabetHex.camera = optionCam;
		modeNotes.camera = optionCam;
		tipTxt1.camera = optionCam;
		tipTxt2.camera = optionCam;
	}

	var _storedColor:FlxColor;
	var changingNote:Bool = false;
	var holdingOnObj:FlxSprite;
	function updateNoteColorOption(elapsed:Float) {
		if(FlxG.keys.justPressed.CONTROL)
		{
			onPixel = !onPixel;
			spawnNotes();
			updateNotes(true);
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		}

		// Copy/Paste buttons
		var generalMoved:Bool = FlxG.mouse.justMoved;
		var generalPressed:Bool = FlxG.mouse.justPressed;
		if(generalMoved)
		{
			copyButton.alpha = 0.6;
			pasteButton.alpha = 0.6;
		}

		if(FlxG.mouse.overlaps(copyButton, optionCam))
		{
			copyButton.alpha = 1;
			if(generalPressed)
			{
				Clipboard.text = getShaderColor().toHexString(false, false);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				trace('copied: ' + Clipboard.text);
			}
		}
		else if (FlxG.mouse.overlaps(pasteButton, optionCam))
		{
			pasteButton.alpha = 1;
			if(generalPressed)
			{
				var formattedText = Clipboard.text.trim().toUpperCase().replace('#', '').replace('0x', '');
				var newColor:Null<FlxColor> = FlxColor.fromString('#' + formattedText);
				//trace('#${Clipboard.text.trim().toUpperCase()}');
				if(newColor != null && formattedText.length == 6)
				{
					setShaderColor(newColor);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					_storedColor = getShaderColor();
					updateColors();
				}
				else //errored
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
			}
		}

		// Click
		if(generalPressed)
		{
			if (FlxG.mouse.overlaps(modeNotes, optionCam))
			{
				modeNotes.forEachAlive(function(note:FlxSprite) {
					if (curSelectedMode != note.ID && FlxG.mouse.overlaps(note, optionCam))
					{
						modeBG.visible = notesBG.visible = false;
						curSelectedMode = note.ID;
						onModeColumn = true;
						updateNotes();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					}
				});
			}
			else if (FlxG.mouse.overlaps(myNotes, optionCam))
			{
				myNotes.forEachAlive(function(note:StrumNote) {
					if (curSelectedNote != note.ID && FlxG.mouse.overlaps(note, optionCam))
					{
						modeBG.visible = notesBG.visible = false;
						curSelectedNote = note.ID;
						onModeColumn = false;
						bigNote.rgbShader.parent = Note.globalRgbShaders[note.ID];
						bigNote.shader = Note.globalRgbShaders[note.ID].shader;
						updateNotes();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					}
				});
			}
			else if (FlxG.mouse.overlaps(colorWheel, optionCam)) {
				_storedColor = getShaderColor();
				holdingOnObj = colorWheel;
			}
			else if (FlxG.mouse.overlaps(colorGradient, optionCam)) {
				_storedColor = getShaderColor();
				holdingOnObj = colorGradient;
			}
			else if (FlxG.mouse.overlaps(colorPalette, optionCam)) {
				setShaderColor(colorPalette.pixels.getPixel32(
					Std.int((FlxG.mouse.x - (optionBack.x + colorPalette.x)) / colorPalette.scale.x), 
					Std.int((FlxG.mouse.y - (optionBack.y + 40 + colorPalette.y)) / colorPalette.scale.y)));
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				updateColors();
			}
			else if (FlxG.mouse.overlaps(skinNote, optionCam))
			{
				onPixel = !onPixel;
				spawnNotes();
				updateNotes(true);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			else holdingOnObj = null;
		}
		// holding
		if(holdingOnObj != null)
		{
			if (FlxG.mouse.justReleased || controls.justReleased('accept'))
			{
				holdingOnObj = null;
				_storedColor = getShaderColor();
				updateColors();
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			else if (generalMoved || generalPressed)
			{
				if (holdingOnObj == colorGradient)
				{
					var newBrightness = 1 - FlxMath.bound((FlxG.mouse.y - (optionBack.y + 40 + colorGradient.y)) / colorGradient.height, 0, 1);
					_storedColor.alpha = 1;
					if(_storedColor.brightness == 0) //prevent bug
						setShaderColor(FlxColor.fromRGBFloat(newBrightness, newBrightness, newBrightness));
					else
						setShaderColor(FlxColor.fromHSB(_storedColor.hue, _storedColor.saturation, newBrightness));
					updateColors(_storedColor);
				}
				else if (holdingOnObj == colorWheel)
				{
					var center:FlxPoint = new FlxPoint((optionBack.x + colorWheel.x) + colorWheel.width/2, (optionBack.y + 40 + colorWheel.y) + colorWheel.height/2);
					var mouse:FlxPoint = FlxG.mouse.getScreenPosition();
					var hue:Float = FlxMath.wrap(FlxMath.wrap(Std.int(mouse.degreesTo(center)), 0, 360) - 90, 0, 360);
					var sat:Float = FlxMath.bound(mouse.dist(center) / colorWheel.width*2, 0, 1);
					//trace('$hue, $sat');
					if(sat != 0) setShaderColor(FlxColor.fromHSB(hue, sat, _storedColor.brightness));
					else setShaderColor(FlxColor.fromRGBFloat(_storedColor.brightness, _storedColor.brightness, _storedColor.brightness));
					updateColors();
				}
			} 
		}
		else if(controls.RESET)
		{
			if(FlxG.keys.pressed.SHIFT)
			{
				for (i in 0...3)
				{
					var strumRGB:RGBShaderReference = myNotes.members[curSelectedNote].rgbShader;
					var color:FlxColor = !onPixel ? ClientPrefs.defaultData.arrowRGB[curSelectedNote][i] :
													ClientPrefs.defaultData.arrowRGBPixel[curSelectedNote][i];
					switch(i)
					{
						case 0:
							getShader().r = strumRGB.r = color;
						case 1:
							getShader().g = strumRGB.g = color;
						case 2:
							getShader().b = strumRGB.b = color;
					}
					dataArray[curSelectedNote][i] = color;
				}
			}
			setShaderColor(!onPixel ? ClientPrefs.defaultData.arrowRGB[curSelectedNote][curSelectedMode] : ClientPrefs.defaultData.arrowRGBPixel[curSelectedNote][curSelectedMode]);
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
			updateColors();
		}
	}

	function changeSelectionMode(change:Int = 0) {
		curSelectedMode += change;
		if (curSelectedMode < 0)
			curSelectedMode = 2;
		if (curSelectedMode >= 3)
			curSelectedMode = 0;

		modeBG.visible = true;
		notesBG.visible = false;
		updateNotes();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	function changeSelectionNote(change:Int = 0) {
		curSelectedNote += change;
		if (curSelectedNote < 0)
			curSelectedNote = dataArray.length-1;
		if (curSelectedNote >= dataArray.length)
			curSelectedNote = 0;
		
		modeBG.visible = false;
		notesBG.visible = true;
		bigNote.rgbShader.parent = Note.globalRgbShaders[curSelectedNote];
		bigNote.shader = Note.globalRgbShaders[curSelectedNote].shader;
		updateNotes();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	// notes sprites functions
	var skinNote:FlxSprite;
	var modeNotes:FlxSpriteGroup;
	var myNotes:FlxTypedSpriteGroup<StrumNote>;
	var bigNote:Note;
	public function spawnNotes()
	{
		dataArray = !onPixel ? ClientPrefs.data.arrowRGB : ClientPrefs.data.arrowRGBPixel;
		if (onPixel) PlayState.stageUI = "pixel";

		// clear groups
		modeNotes.forEachAlive(function(note:FlxSprite) {
			note.kill();
			note.destroy();
		});
		myNotes.forEachAlive(function(note:StrumNote) {
			note.kill();
			note.destroy();
		});
		modeNotes.clear();
		myNotes.clear();

		if(skinNote != null)
		{
			visualedOptions.remove(skinNote);
			skinNote.destroy();
		}
		if(bigNote != null)
		{
			visualedOptions.remove(bigNote);
			bigNote.destroy();
		}

		// respawn stuff
		var res:Int = onPixel ? 160 : 17;
		skinNote = new FlxSprite(27, 14).loadGraphic(Paths.image('noteColorMenu/' + (onPixel ? 'note' : 'notePixel')), true, res, res);
		skinNote.antialiasing = ClientPrefs.data.antialiasing;
		skinNote.setGraphicSize(38);
		skinNote.updateHitbox();
		skinNote.animation.add('anim', [0], 24, true);
		skinNote.animation.play('anim', true);
		if(!onPixel) skinNote.antialiasing = false;
		visualedOptions.add(skinNote);
		skinNote.camera = optionCam;

		var res:Int = !onPixel ? 160 : 17;
		for (i in 0...3)
		{
			var newNote:FlxSprite = new FlxSprite(155 + (80 * i), 20).loadGraphic(Paths.image('noteColorMenu/' + (!onPixel ? 'note' : 'notePixel')), true, res, res);
			newNote.antialiasing = ClientPrefs.data.antialiasing;
			newNote.setGraphicSize(65);
			newNote.updateHitbox();
			newNote.animation.add('anim', [i], 24, true);
			newNote.animation.play('anim', true);
			newNote.ID = i;
			if(onPixel) newNote.antialiasing = false;
			modeNotes.add(newNote);
		}

		Note.globalRgbShaders = [];
		for (i in 0...dataArray.length)
		{
			Note.initializeGlobalRGBShader(i);
			var newNote:StrumNote = new StrumNote(75 + (400 / dataArray.length * i), 100, i, 0);
			newNote.useRGBShader = true;
			newNote.setGraphicSize(82);
			newNote.updateHitbox();
			newNote.ID = i;
			myNotes.add(newNote);
		}

		bigNote = new Note(0, 0, false, true);
		bigNote.setPosition(175, 185);
		bigNote.setGraphicSize(180);
		bigNote.updateHitbox();
		bigNote.rgbShader.parent = Note.globalRgbShaders[curSelectedNote];
		bigNote.shader = Note.globalRgbShaders[curSelectedNote].shader;
		for (i in 0...Note.colArray.length)
		{
			if(!onPixel) bigNote.animation.addByPrefix('note$i', Note.colArray[i] + '0', 24, true);
			else bigNote.animation.add('note$i', [i + 4], 24, true);
		}
		visualedOptions.add(bigNote);
		bigNote.camera = optionCam;
		_storedColor = getShaderColor();
		PlayState.stageUI = "normal";
	}

	function updateNotes(?instant:Bool = false)
	{
		for (note in modeNotes)
			note.alpha = (curSelectedMode == note.ID) ? 1 : 0.6;

		for (note in myNotes)
		{
			var newAnim:String = curSelectedNote == note.ID ? 'confirm' : 'pressed';
			note.alpha = (curSelectedNote == note.ID) ? 1 : 0.6;
			if(note.animation.curAnim == null || note.animation.curAnim.name != newAnim) note.playAnim(newAnim, true);
			if(instant) note.animation.curAnim.finish();
		}
		bigNote.animation.play('note$curSelectedNote', true);
		updateColors();
	}

	function updateColors(specific:Null<FlxColor> = null)
	{
		var color:FlxColor = getShaderColor();
		var wheelColor:FlxColor = specific == null ? getShaderColor() : specific;
		alphabetR.text = Std.string(color.red);
		alphabetR.color = FlxColor.fromRGB(color.red, 0, 0);
		alphabetG.text = Std.string(color.green);
		alphabetG.color = FlxColor.fromRGB(0, color.green, 0);
		alphabetB.text = Std.string(color.blue);
		alphabetB.color = FlxColor.fromRGB(0, 0, color.blue);
		alphabetHex.text = color.toHexString(false, false);
		alphabetHex.color = color;

		colorWheel.color = FlxColor.fromHSB(0, 0, color.brightness);
		colorWheelSelector.setPosition(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height/2);
		if(wheelColor.brightness != 0)
		{
			var hueWrap:Float = wheelColor.hue * Math.PI / 180;
			colorWheelSelector.x += Math.sin(hueWrap) * colorWheel.width/2 * wheelColor.saturation;
			colorWheelSelector.y -= Math.cos(hueWrap) * colorWheel.height/2 * wheelColor.saturation;
		}
		colorGradientSelector.y = colorGradient.y + colorGradient.height * (1 - color.brightness);

		var strumRGB:RGBShaderReference = myNotes.members[curSelectedNote].rgbShader;
		switch(curSelectedMode)
		{
			case 0:
				getShader().r = strumRGB.r = color;
			case 1:
				getShader().g = strumRGB.g = color;
			case 2:
				getShader().b = strumRGB.b = color;
		}
	}

	function setShaderColor(value:FlxColor) dataArray[curSelectedNote][curSelectedMode] = value;
	function getShaderColor() return dataArray[curSelectedNote][curSelectedMode];
	function getShader() return Note.globalRgbShaders[curSelectedNote];

	// originate from NoteOffsetState (NoteOffsetState's new function and etc)
	var boyfriendSecond:Character;
	var gf:Character;

	var coolText:FlxText;
	var rating:FlxSprite;
	var comboNums:FlxSpriteGroup;
	var dumbTexts:FlxTypedSpriteGroup<FlxText>;
	var comboObjects:FlxSpriteGroup;
	var hudObjects:Array<FlxSprite> = [];

	var barPercent:Float = 0;
	var delayMin:Int = -500;
	var delayMax:Int = 500;
	var timeBar:Bar;
	var timeTxt:FlxText;
	var beatText:Alphabet;
	var beatTween:FlxTween;

	var noteDelayText:FlxText;

	var offsetModeChangeButt:ButtBaseThing;

	function makeVisualAdjustOption() {
		innerY = [0, 0];
		curInnerY = innerY[0];
		optionCam.zoom = .85;
		
		if (onPlayState && ClientPrefs.data.pauseMusic != 'None') PauseSubState.pauseMusic.pause();

		colorgrid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x45CBEA84, 0x0));
		colorgrid.velocity.set(40, 40);
		colorgrid.alpha = 0;
		FlxTween.tween(colorgrid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		visualedOptions.add(colorgrid);

		// Characters
		gf = new Character(215, -105, 'gf');
		gf.setGraphicSize(gf.width * .7, gf.height * .7);
		gf.updateHitbox();
		gf.dance();
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		boyfriendSecond = new Character(500, -215, 'bf', true);
		boyfriendSecond.setGraphicSize(boyfriendSecond.width * .7, boyfriendSecond.height * .7);
		boyfriendSecond.updateHitbox();
		boyfriendSecond.dance();
		boyfriendSecond.x += boyfriendSecond.positionArray[0];
		boyfriendSecond.y += boyfriendSecond.positionArray[1];
		visualedOptions.add(gf);
		visualedOptions.add(boyfriendSecond);

		offsetModeChangeButt = makeOuterButt(new ButtBaseThing(
			opPopR - 200,
			opBckB - 90,
			'Go to Offset Option',
			'option_go_to_offset'
		));
		offsetModeChangeButt.onClickedUpCallback = makeOffsetModeOuterFunc(offsetModeChangeButt);
		insert(members.indexOf(comboObjects), offsetModeChangeButt);
		hudObjects.push(offsetModeChangeButt);

		// Note delay stuff
		beatText = new Alphabet(0, 0, Language.getPhrase('delay_beat_hit', 'Beat Hit!'), true);
		beatText.setScale(0.6, 0.6);
		beatText.x += 280;
		beatText.y -= 150;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		visualedOptions.add(beatText);
		
		timeTxt = new FlxText(optionBack.x, 530, optionBack.width, "", 18);
		timeTxt.setFormat(Paths.font("mobileone.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.borderSize = 2;

		barPercent = ClientPrefs.data.noteOffset;
		updateNoteDelay();
		
		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 3), 'healthBar', function() return barPercent, delayMin, delayMax);
		timeBar.screenCenter(X);
		timeBar.leftBar.color = FlxColor.LIME;

		insert(members.indexOf(comboObjects), timeBar);
		hudObjects.push(timeBar);
		insert(members.indexOf(comboObjects), timeTxt);
		hudObjects.push(timeTxt);

		var blackBox:FlxSprite = new FlxSprite(optionBack.x, optionBack.y + 40).makeGraphic(Std.int(optionBack.width), 30, FlxColor.BLACK);
		blackBox.alpha = 0.6;
		insert(members.indexOf(comboObjects), blackBox);
		hudObjects.push(blackBox);

		var str:String;
		str = Language.getPhrase('note_delay', 'Note/Beat Delay');

		noteDelayText = new FlxText(optionBack.x, optionBack.y + 42, blackBox.width, '< ${str.toUpperCase()} >', 22);
		noteDelayText.setFormat(Paths.font("mobileone.ttf"), 22, FlxColor.WHITE, CENTER);
		insert(members.indexOf(comboObjects), noteDelayText);
		hudObjects.push(noteDelayText);

		// Combo stuff
		coolText = new FlxText(0, 0, 0, '', 32);
		coolText.screenCenter();
		coolText.x = optionBack.width * 0.35;

		var comboBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		comboBG.alpha = .75;
		comboObjects.add(comboBG);
		comboObjects.camera = frontCam;

		rating = new FlxSprite().loadGraphic(Paths.image('sick'));
		rating.antialiasing = ClientPrefs.data.antialiasing;
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();
		comboObjects.add(rating);

		comboNums = new FlxSpriteGroup();
		comboObjects.add(comboNums);

		var seperatedScore:Array<Int> = [];
		for (i in 0...3)
		{
			seperatedScore.push(FlxG.random.int(0, 9));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite(43 * daLoop).loadGraphic(Paths.image('num' + i));
			numScore.camera = frontCam;
			numScore.antialiasing = ClientPrefs.data.antialiasing;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			comboNums.add(numScore);
			daLoop++;
		}

		dumbTexts = new FlxTypedSpriteGroup<FlxText>();
		comboObjects.add(dumbTexts);

		createTexts();

		repositionCombo();

		var blackBox:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 40, FlxColor.BLACK);
		blackBox.scrollFactor.set();
		blackBox.alpha = 0.6;
		comboObjects.add(blackBox);

		var str:String = Language.getPhrase('combo_offset', 'Combo Offset');
		var str2:String = Language.getPhrase('press_back', '(Press back key to go back)');
		var offsetText = new FlxText(0, 4, FlxG.width, '< ${str.toUpperCase()} ${str2.toUpperCase()} >', 32);
		offsetText.setFormat(Paths.font("mobileone.ttf"), 32, FlxColor.WHITE, CENTER);
		comboObjects.add(offsetText);

		///////////////////////
		
		settingAdjustOptionCameras();
		comboObjects.visible = onComboMenu;

		Conductor.bpm = 128.0;
		FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);
	}

	function settingAdjustOptionCameras() {
		colorgrid.camera = optionCam;
		rating.camera = frontCam;
		comboNums.camera = frontCam;
		dumbTexts.camera = frontCam;
		beatText.camera = optionCam;
		for (obj in hudObjects) obj.camera = frontCam;
	}

	var adJustHoldTime:Float = 0;
	public var onComboMenu:Bool = false;
	var holdingObjectType:Null<Bool> = null;

	var startMousePos:FlxPoint = new FlxPoint();
	var startComboOffset:FlxPoint = new FlxPoint();
	function updateAdjustOption(elapsed:Float)
	{
		var addNum:Int = 1;
		if(FlxG.keys.pressed.SHIFT)
		{
			if(onComboMenu)
				addNum = 10;
			else
				addNum = 3;
		}

		if(onComboMenu)
		{
			if(FlxG.keys.justPressed.ANY)
			{
				var controlArray:Array<Bool> = [
					FlxG.keys.justPressed.LEFT,
					FlxG.keys.justPressed.RIGHT,
					FlxG.keys.justPressed.UP,
					FlxG.keys.justPressed.DOWN,
				
					FlxG.keys.justPressed.A,
					FlxG.keys.justPressed.D,
					FlxG.keys.justPressed.W,
					FlxG.keys.justPressed.S
				];

				if(controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						if(controlArray[i])
						{
							switch(i)
							{
								case 0:
									ClientPrefs.data.comboOffset[0] -= addNum;
								case 1:
									ClientPrefs.data.comboOffset[0] += addNum;
								case 2:
									ClientPrefs.data.comboOffset[1] += addNum;
								case 3:
									ClientPrefs.data.comboOffset[1] -= addNum;
								case 4:
									ClientPrefs.data.comboOffset[2] -= addNum;
								case 5:
									ClientPrefs.data.comboOffset[2] += addNum;
								case 6:
									ClientPrefs.data.comboOffset[3] += addNum;
								case 7:
									ClientPrefs.data.comboOffset[3] -= addNum;
							}
						}
					}
					repositionCombo();
				}
			}

			// probably there's a better way to do this but, oh well.
			if (FlxG.mouse.justPressed)
			{
				holdingObjectType = null;

				FlxG.mouse.getScreenPosition(frontCam, startMousePos);

				if (startMousePos.x - comboNums.x >= 0 && startMousePos.x - comboNums.x <= comboNums.width &&
					startMousePos.y - comboNums.y >= 0 && startMousePos.y - comboNums.y <= comboNums.height)
				{
					holdingObjectType = true;
					startComboOffset.x = ClientPrefs.data.comboOffset[2];
					startComboOffset.y = ClientPrefs.data.comboOffset[3];
					//trace('yo bro');
				}
				else if (startMousePos.x - rating.x >= 0 && startMousePos.x - rating.x <= rating.width &&
						 startMousePos.y - rating.y >= 0 && startMousePos.y - rating.y <= rating.height)
				{
					holdingObjectType = false;
					startComboOffset.x = ClientPrefs.data.comboOffset[0];
					startComboOffset.y = ClientPrefs.data.comboOffset[1];
					//trace('heya');
				}
			}
			if(FlxG.mouse.justReleased) {
				holdingObjectType = null;
				//trace('dead');
			}

			if(holdingObjectType != null)
			{
				if(FlxG.mouse.justMoved)
				{
					var mousePos:FlxPoint = FlxG.mouse.getScreenPosition(frontCam);

					var addNum:Int = holdingObjectType ? 2 : 0;
					ClientPrefs.data.comboOffset[addNum + 0] = Math.round((mousePos.x - startMousePos.x) + startComboOffset.x);
					ClientPrefs.data.comboOffset[addNum + 1] = -Math.round((mousePos.y - startMousePos.y) - startComboOffset.y);
					repositionCombo();
				}
			}

			if(controls.RESET)
			{
				for (i in 0...ClientPrefs.data.comboOffset.length)
				{
					ClientPrefs.data.comboOffset[i] = 0;
				}
				repositionCombo();
			}
			else if (controls.BACK) {
				onComboMenu = false;
				offsetModeChangeButt.isChecked = false;
			}
		}
		else
		{
			if(controls.UI_LEFT_P)
			{
				barPercent = Math.max(delayMin, Math.min(ClientPrefs.data.noteOffset - 1, delayMax));
				updateNoteDelay();
			}
			else if(controls.UI_RIGHT_P)
			{
				barPercent = Math.max(delayMin, Math.min(ClientPrefs.data.noteOffset + 1, delayMax));
				updateNoteDelay();
			}

			var mult:Int = 1;
			if(controls.UI_LEFT || controls.UI_RIGHT)
			{
				adJustHoldTime += elapsed;
				if(controls.UI_LEFT) mult = -1;
			}

			if(controls.UI_LEFT_R || controls.UI_RIGHT_R) adJustHoldTime = 0;

			if(adJustHoldTime > 0.3)
			{
				barPercent += 100 * addNum * elapsed * mult;
				barPercent = Math.max(delayMin, Math.min(barPercent, delayMax));
				updateNoteDelay();
			}

			if(controls.RESET)
			{
				adJustHoldTime = 0;
				barPercent = 0;
				updateNoteDelay();
			}
		}

		comboObjects.visible = onComboMenu;
		Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;
	function beatHitAdjustOption()
	{
		if(lastBeatHit == curBeat)
		{
			return;
		}

		if(curBeat % 2 == 0)
		{
			boyfriendSecond.dance();
			gf.dance();
		}
		
		if(curBeat % 4 == 2)
		{
			optionCam.zoom = 1;

			if(zoomTween != null) zoomTween.cancel();
			zoomTween = FlxTween.tween(optionCam, {zoom: .85}, 1, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
				{
					zoomTween = null;
				}
			});

			beatText.alpha = 1;
			beatText.y = 170;
			beatText.velocity.y = -150;
			if(beatTween != null) beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween)
				{
					beatTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	function repositionCombo()
	{
		rating.screenCenter();
		rating.x = coolText.x - 40 + ClientPrefs.data.comboOffset[0];
		rating.y -= 60 + ClientPrefs.data.comboOffset[1];

		comboNums.screenCenter();
		comboNums.x = coolText.x - 90 + ClientPrefs.data.comboOffset[2];
		comboNums.y += 80 - ClientPrefs.data.comboOffset[3];
		reloadTexts();
	}

	function createTexts()
	{
		for (i in 0...4)
		{
			var text:FlxText = new FlxText(10, 48 + (i * 30), 0, '', 24);
			text.setFormat(Paths.font("mobileone.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			text.borderSize = 2;
			dumbTexts.add(text);

			if(i > 1)
			{
				text.y += 24;
			}
		}
	}

	function reloadTexts()
	{
		for (i in 0...dumbTexts.length)
		{
			switch(i)
			{
				case 0: dumbTexts.members[i].text = Language.getPhrase('combo_rating_offset', 'Rating Offset:');
				case 1: dumbTexts.members[i].text = '[' + ClientPrefs.data.comboOffset[0] + ', ' + ClientPrefs.data.comboOffset[1] + ']';
				case 2: dumbTexts.members[i].text = Language.getPhrase('combo_numbers_offset', 'Numbers Offset:');
				case 3: dumbTexts.members[i].text = '[' + ClientPrefs.data.comboOffset[2] + ', ' + ClientPrefs.data.comboOffset[3] + ']';
			}
		}
	}

	function updateNoteDelay()
	{
		ClientPrefs.data.noteOffset = Math.round(barPercent);
		timeTxt.text = Language.getPhrase('delay_current_offset', 'Current offset: {1} ms', [Math.floor(barPercent)]);
	}

	// originate from ControlsSubState
	private function startKeyBinding() {
		bindingWhite = new FlxSprite().makeGraphic(Math.round(optionBack.width), Math.round(optionBack.height), FlxColor.TRANSPARENT);
		bindingWhite.updateHitbox();
		FlxSpriteUtil.drawRoundRectComplex(bindingWhite, 0, 0, bindingWhite.width, bindingWhite.height, 0, 0, 100, 100, FlxColor.WHITE);
		bindingWhite.alpha = 0;
		FlxTween.tween(bindingWhite, {alpha: 0.85}, 0.15, {ease: FlxEase.linear});
		insert(members.indexOf(optionPopup), bindingWhite);

		bindingText = new FlxText(0, 0, 0, Language.getPhrase('controls_rebinding', 'Rebinding {0}', curInOp.name), 38);
		bindingText.setFormat(Paths.font("mobileone.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		bindingText.updateHitbox();
		bindingText.setPosition(optionBack.width / 2 - bindingText.width / 2, optionBack.height / 2 - 120);
		insert(members.indexOf(optionPopup), bindingText);

		bindingText2 = new FlxText(0, 0, 0, Language.getPhrase('controls_rebinding2', 'Hold ESC to Cancel\nHold Backspace to Delete'), 20);
		bindingText2.setFormat(Paths.font("mobileone.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		bindingText2.updateHitbox();
		bindingText2.setPosition(optionBack.width / 2 - bindingText2.width / 2, optionBack.height / 2 - 60);
		insert(members.indexOf(optionPopup), bindingText2);

		bindingWhite.camera = optionCam;
		bindingText.camera = optionCam;
		bindingText2.camera = optionCam;

		bindingKey = true;
		holdingEsc = 0;
		ClientPrefs.toggleVolumeKeys(false);
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	private function updateBindingKey(elapsed:Float)
	{
		if (curInOp == null) return;

		if(FlxG.keys.pressed.ESCAPE || outerOptions[curSelected] != 'Controls') {
			holdingEsc += elapsed;
			if(holdingEsc > 0.3 || outerOptions[curSelected] != 'Controls')
			{
				bindingKey = false;
				if (bindingWhite != null) bindingWhite.destroy();
				if (bindingText != null) bindingText.destroy();
				if (bindingText2 != null) bindingText2.destroy();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				ClientPrefs.toggleVolumeKeys(true);

				if (outerOptions[curSelected] == 'Controls') {
					for (butt in curInOp.boxes) {
						if (butt.isChecked)
							butt.isChecked = false;
					}
				}
			}
		}
		else if (FlxG.keys.pressed.BACKSPACE)
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.3)
			{
				if (Std.isOfType(curInOp, ControlOption)) {
					var controlOption:ControlOption = cast curInOp;
					trace(controlOption.keys);
					if (controlOption != null) {
						if (controlOption.alt) {
							controlOption.keys[1] = NONE;
							if (controlOption.boxes != null && controlOption.boxes[1] != null)
								controlOption.boxes[1].text = 'None';
						}
						else {
							controlOption.keys[0] = NONE;
							if (controlOption.boxes != null && controlOption.boxes[0] != null)
								controlOption.boxes[0].text = 'None';
						}
						controlOption.value = controlOption.keys;
					}
				}
				bindingKey = false;
				if (bindingWhite != null) bindingWhite.destroy();
				if (bindingText != null) bindingText.destroy();
				if (bindingText2 != null) bindingText2.destroy();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				ClientPrefs.toggleVolumeKeys(true);

				for (butt in curInOp.boxes) {
					if (butt.isChecked)
						butt.isChecked = false;
				}
			}
		}
		else
		{
			holdingEsc = 0;
			if (FlxG.keys.justPressed.ANY) {
				var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
				
				if(keyPressed != NONE && keyPressed != ESCAPE && keyPressed != BACKSPACE && Std.isOfType(curInOp, ControlOption)) {
					var controlOption:ControlOption = cast curInOp;
					if (controlOption != null) {
						if (controlOption.alt) {
							controlOption.keys[1] = keyPressed;
							if (curInOp.boxes != null && curInOp.boxes[1] != null)
								curInOp.boxes[1].text = InputFormatter.getKeyName(keyPressed);
						}
						else
						{
							controlOption.keys[0] = keyPressed;
							if (curInOp.boxes != null && curInOp.boxes[0] != null)
								curInOp.boxes[0].text = InputFormatter.getKeyName(keyPressed);
						}
						controlOption.value = controlOption.keys;
					}
					
					bindingKey = false;
					if (bindingWhite != null) bindingWhite.destroy();
					if (bindingText != null) bindingText.destroy();
					if (bindingText2 != null) bindingText2.destroy();
					ClientPrefs.toggleVolumeKeys(true);
					FlxG.sound.play(Paths.sound('scrollMenu'));

					for (butt in curInOp.boxes) {
						if (butt.isChecked)
							butt.isChecked = false;
					}
				}
			}
		}
	}

	/// originate from VisualsSettingsSubState
	function changeNoteSkin(note:StrumNote)
	{
		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		note.texture = skin; //Load texture and anims
		note.reloadNote();
		note.playAnim('static');
	}

	function playNoteSplashes()
	{
		var rand:Int = 0;
		if (splashes.members[0] != null && splashes.members[0].maxAnims > 1)
			rand = FlxG.random.int(0, splashes.members[0].maxAnims - 1); // For playing the same random animation on all 4 splashes

		for (splash in splashes)
		{
			splash.revive();

			splash.spawnSplashNote(0, 0, splash.ID, null, false);
			if (splash.maxAnims > 1)
				splash.noteData = splash.noteData % Note.colArray.length + (rand * Note.colArray.length);

			var anim:String = splash.playDefaultAnim();
			var conf = splash.config.animations.get(anim);
			var offsets:Array<Float> = [0, 0];

			var minFps:Int = 22;
			var maxFps:Int = 26;
			if (conf != null)
			{
				offsets = conf.offsets;

				minFps = conf.fps[0];
				if (minFps < 0) minFps = 0;

				maxFps = conf.fps[1];
				if (maxFps < 0) maxFps = 0;
			}

			splash.offset.set(10, 10);
			if (offsets != null)
			{
				splash.offset.x += offsets[0];
				splash.offset.y += offsets[1];
			}

			if (splash.animation.curAnim != null)
				splash.animation.curAnim.frameRate = FlxG.random.int(minFps, maxFps);
		}
	}
	
	// getters
	function get_opPopL():Float return optionPopup.x;
	function get_opPopR():Float return optionPopup.x + optionPopup.width;
	function get_opBckT():Float return optionBack.y;
	function get_opBckB():Float return optionBack.y + optionBack.height;

	override function destroy():Void {
		super.destroy();

		outerOptions = null;

		if (visualedOptions != null) {
			visualedOptions.destroy();
			visualedOptions = null;
		}
		if (grpOptionButts != null) 
			for (butt in grpOptionButts) butt.destroy();
		if (optionPopup != null) {
			optionPopup.destroy();
			optionPopup = null;
		}
		if (optionBack != null) {
			optionBack.destroy();
			optionBack = null;
		}
		if (optionClose != null) {
			optionClose.destroy();
			optionClose = null;
		}
		if (optionText != null) {
			optionText.destroy();
			optionText = null;
		}
		if (boyfriend != null) {
			boyfriend.destroy();
			boyfriend = null;
		}
		if (notes != null) {
			notes.destroy();
			notes = null;
		}
		if (splashes != null) {
			splashes.destroy();
			splashes = null;
		}

		if (otherCam != null) FlxG.cameras.remove(otherCam);
		FlxG.cameras.remove(backCam);
		FlxG.cameras.remove(optionCam);
		FlxG.cameras.remove(frontCam);

		innerOptions = [];
		grpOptionButts = [];
		Note.globalRgbShaders = [];

		curInOp = null;
		innerY = null;
		curInnerY = 0;

		onPlayState = false;
		sliderHanding = false;
		curSelected = 0;
	}
}