package states;

import objects.WavyLetters;
import states.editors.MasterEditorMenu;


class AdventureMainMenuState extends MusicBeatState {
	public static var psychEngineVersion:String = '1.0.4'; // This is also used for Discord RPC
	static var modVersion:String = 'Demo'; // This is also used for Discord RPC
	public static var curSelected:String = 'none';
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	private var bg:FlxSprite;

	private var storyItem:FlxSprite;
	private var freeItem:FlxSprite;

	override function create() {
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Adventure Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('secondmainmenu/bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		storyItem = createMenuItem('storyfigure', 1020, 220);
		freeItem = createMenuItem('freeplaydoor', 580, 10);

		var text:WavyLetters = new WavyLetters(504, 484, "Story Mode", 28, FlxColor.fromRGB(75, 75, 75, 1));
		text.antialiasing = ClientPrefs.data.antialiasing;
		add(text);

		var text:WavyLetters = new WavyLetters(326, 260, "Freeplay", 28, FlxColor.fromRGB(245, 194, 76, 1));
		text.antialiasing = ClientPrefs.data.antialiasing;
		add(text);
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image('secondmainmenu/$name', false));
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

				if(storyItem != null && FlxG.mouse.overlaps(storyItem)) {
					allowMouse = true;
					curSelected = 'story_mode';
				}

				if(freeItem != null && FlxG.mouse.overlaps(freeItem)) {
					allowMouse = true;
					curSelected = 'freeplay';
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
				MusicBeatState.switchState(new MainMenuState());
			}

			if (FlxG.mouse.justPressed && allowMouse)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				selectedSomethin = true;
				FlxG.mouse.visible = false;

				switch (curSelected)
				{
					case 'story_mode':
						MusicBeatState.switchState(new StoryMenuState());
					case 'freeplay':
						MusicBeatState.switchState(new FreeplayState());
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
}
