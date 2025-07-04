package states;

import flixel.FlxBasic;
import objects.WavyLetters;
import objects.TrickalityFigure;
import options.OptionsSubState;
import states.editors.MasterEditorMenu;

class MainMenuState extends MusicBeatState {
	public static var psychEngineVersion:String = '1.0.4'; // This is also used for Discord RPC
	public static var modVersion:String = 'Demo'; // This is also used for Discord RPC
	public static var curSelected:String = 'none';
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	private var bg:FlxSprite;

	private var cheek:FlxSprite;

	private var charItem:FlxSprite;
	private var achieveItem:FlxSprite;
	private var creditsItem:FlxSprite;
	private var goItem:FlxSprite;

	private var patchItem:FlxSprite;
	private var settingItem:FlxSprite;

	private var zoomandout:FlxTween;

	override function create() {
		super.create();

		var randomN = FlxG.random.int(1, 5);

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		var graphic = Paths.image('firstmainmenu/bg$randomN');

		bg = new FlxSprite().loadGraphic(graphic);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		cheek = new FlxSprite().loadGraphic(Paths.image('firstmainmenu/cheekf'));
		cheek.setPosition(25, 10);
		cheek.antialiasing = ClientPrefs.data.antialiasing;
		cheek.updateHitbox();
		add(cheek);

		var nametag:FlxSprite = new FlxSprite().loadGraphic(Paths.image('firstmainmenu/nametag'));
		nametag.setPosition(25, 10);
		nametag.antialiasing = ClientPrefs.data.antialiasing;
		nametag.updateHitbox();
		add(nametag);

		var lvl:FlxText = new FlxText(187, 58, 0, "LV.19", 16);
		lvl.antialiasing = ClientPrefs.data.antialiasing;
		lvl.setFormat(Paths.font("mobileone.ttf"), 16, FlxColor.WHITE);
		lvl.scrollFactor.set();
		add(lvl);

		var name:FlxText = new FlxText(335, 58, 0, "Boyfriend", 16);
		name.antialiasing = ClientPrefs.data.antialiasing;
		name.setFormat(Paths.font("mobileone.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		name.scrollFactor.set();
		add(name);

		charItem = createMenuItem('characters', 25, 560);
		achieveItem = createMenuItem('achievements', 175, 560);
		creditsItem = createMenuItem('credits', 325, 560);

		goItem = createMenuItem('go', FlxG.width - 30, 500);
		goItem.x -= goItem.width;

		patchItem = createSubMenuItem('patchnotes', FlxG.width - 120, 35);
		patchItem.x -= patchItem.width;

		settingItem = createSubMenuItem('settings', FlxG.width - 30, 35);
		settingItem.x -= settingItem.width;

		var text:WavyLetters = new WavyLetters(0, 640, "Characters", 24);
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.scrollFactor.set();
		text.x = charItem.x + charItem.width / 2 - text.width / 2;
		add(text);

		var text:WavyLetters = new WavyLetters(0, 640, "Achieve", 24);
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.scrollFactor.set();
		text.x = achieveItem.x + achieveItem.width / 2 - text.width / 2;
		add(text);

		var text:WavyLetters = new WavyLetters(0, 665, "ments", 24);
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.scrollFactor.set();
		text.x = achieveItem.x + achieveItem.width / 2 - text.width / 2;
		add(text);

		var text:WavyLetters = new WavyLetters(0, 640, "Credits", 24);
		text.antialiasing = ClientPrefs.data.antialiasing;
		text.scrollFactor.set();
		text.x = creditsItem.x + creditsItem.width / 2 - text.width / 2;
		add(text);

		var figure:TrickalityFigure = new TrickalityFigure('suil', FlxG.width / 2, FlxG.height / 2);
		figure.antialiasing = ClientPrefs.data.antialiasing;
		figure.scrollFactor.set();
		add(figure);

		// var emitter:TrickalityEmitter = new TrickalityEmitter(FlxG.width / 2, FlxG.height / 2, 0, 3.5).bringParticles();
		// emitter.start(false);
		// add(emitter);

		startZoomLoop();
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image('firstmainmenu/menu_$name', false));
		menuItem.setPosition(x, y);
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		menuItem.scrollFactor.set();

		add(menuItem);

		return menuItem;
	}

	function createSubMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image('firstmainmenu/submenu_$name', false));
		menuItem.setPosition(x, y);
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		menuItem.scrollFactor.set();

		add(menuItem);

		return menuItem;
	}

	var selectedSomethin:Bool = false;

	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		if (!selectedSomethin)
		{
			var allowMouse:Bool = allowMouse;
			var curSelected:String = curSelected;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				allowMouse = false;
				curSelected = 'none';
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				if(charItem != null && FlxG.mouse.overlaps(charItem)) {
					allowMouse = true;
					curSelected = 'characters';
				}

				if(achieveItem != null && FlxG.mouse.overlaps(achieveItem)) {
					allowMouse = true;
					curSelected = 'achievements';
				}

				if(creditsItem != null && FlxG.mouse.overlaps(creditsItem)) {
					allowMouse = true;
					curSelected = 'credits';
				}

				if(goItem != null && FlxG.mouse.overlaps(goItem)) {
					allowMouse = true;
					curSelected = 'go';
				}

				if(patchItem != null && FlxG.mouse.overlaps(patchItem)) {
					allowMouse = true;
					curSelected = 'patchnotes';
				}

				if(settingItem != null && FlxG.mouse.overlaps(settingItem)) {
					allowMouse = true;
					curSelected = 'settings';
				}
			}
			else {
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (FlxG.mouse.justPressed && allowMouse)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;

				switch (curSelected)
				{
					case 'characters':
						trace('Do not add features yet');
						selectedSomethin = false;

						// zoomandout.cancel();
						// MusicBeatState.switchState(new CharactersMenuState());

					case 'achievements':
						zoomandout.cancel();
						MusicBeatState.switchState(new AchievementsMenuState());

					case 'credits':
						zoomandout.cancel();
						MusicBeatState.switchState(new CreditsState());

					case 'go':
						zoomandout.cancel();
						MusicBeatState.switchState(new AdventureMainMenuState());

					case 'patchnotes':
						trace('Do not add features yet');
						selectedSomethin = false;

						// openSubState(new PatchnotesSubState());

					case 'settings':
						persistentUpdate = true;
						persistentDraw = true;

						openSubState(new OptionsSubState());
						OptionsSubState.onPlayState = false;
						if (PlayState.SONG != null) {
							PlayState.SONG.arrowSkin = null;
							PlayState.SONG.splashSkin = null;
							PlayState.stageUI = 'normal';
						}
					default:
						trace('Menu Item $curSelected doesn\'t do anything');
						selectedSomethin = false;
				}
			}
			
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		super.update(elapsed);
	}

	override function closeSubState()
	{
		super.closeSubState();

		resetSubState();

		FlxG.mouse.visible = true;
		selectedSomethin = false;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		ClientPrefs.saveSettings();
		ClientPrefs.loadPrefs();
		ClientPrefs.toggleVolumeKeys(true);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Main Menu", null);
		#end
	}

	override function destroy() {
		forEach(function(obj:FlxBasic) {
			if (obj != null)
				obj.destroy();
		});

		super.destroy();
	}

	function startZoomLoop():Void {
		zoomandout = FlxTween.tween(bg.scale, {x: 1.1, y: 1.1}, 5, {
			ease: FlxEase.quadOut,
			onUpdate: function(_) {
				bg.updateHitbox();
				bg.screenCenter();
			},
			onComplete: function(_) {
				new FlxTimer().start(3, function(_) {
					FlxTween.tween(bg.scale, {x: 1.0, y: 1.0}, 5, {
						ease: FlxEase.quadIn,
						onUpdate: function(_) {
							bg.updateHitbox();
							bg.screenCenter();
						},
						onComplete: function(_) {
							new FlxTimer().start(3, function(_) {
								startZoomLoop();
							});
						}
					});
				});
			}
		});
	}
}