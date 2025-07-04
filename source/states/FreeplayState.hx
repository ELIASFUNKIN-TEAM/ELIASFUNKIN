package states;

import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import objects.HealthIcon;
import objects.WavyLetters;
import substates.ResetScoreSubState;

class FreeplayState extends MusicBeatState {
	var allowMouse:Bool = true;

	var floatTimer:Float = 0;
	var floatSpeed:Float = 2.0;
	var floatRange:Float = 15.0;
	var angleRange:Float = 7.5;

	var char1BaseY:Float = 275;
	var char2BaseY:Float = 50;

	var cdAngle:Float = 0;
	var cdSpeed:Float = 0.5;
	var cdTargetSpeed:Float = 3.0;
	var cdAccel:Float = 0.05;
	var isResetting:Bool = false;
	var canSpin:Bool = true;

	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	private var freeboxArray:Array<FlxSprite> = [];

	var freedot:FlxSprite;
	var freelight:FlxSprite;
	var freecd:FlxSprite;
	
	var freeEasy:FlxSprite;
	var freeNormal:FlxSprite;
	var freeHard:FlxSprite;
	
	var freeSongArrowU:FlxSprite;
	var freeSongArrowD:FlxSprite;

	var freechar1:FlxSprite;
	var freechar2:FlxSprite;

	var freechar1alp:FlxTween;
	var freechar2alp:FlxTween;
	var freechar1y:FlxTween;
	var freechar2y:FlxTween;
	var freechar1float:FlxTween;
	var freechar2float:FlxTween;
	var freechar1angle:FlxTween;
	var freechar2angle:FlxTween;

	private var diffArray:Array<String> = [
		'easy',
		'normal',
		'hard'
	];

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var stopMusicPlay:Bool = false;
	var timeNotMoving:Float = 0;
	var change:Int = -1;
	var holdTime:Float = 0;

	var camZooming:Bool = true;
	var camZoomingMult:Float = 1.0;
	var camZoomingDecay:Float = 1.0;
	var playbackRate:Float = 1.0;
	var defaultCamZoom:Float = 1.0;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				addSong(song[0], i, song[1]);
			}
		}
		Mods.loadTopMod();

		var freeback:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/freeback'));
		var freebg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));

		freelight = new FlxSprite();
		freelight.frames = Paths.getSparrowAtlas('freeplay/freelight');
		freelight.animation.addByPrefix('idle', 'freelight idle', 24, true);
		freelight.animation.play('idle');
		freelight.setGraphicSize(freelight.width / 2.5, freelight.height / 2.5);
		freelight.updateHitbox();
		freelight.setPosition(-180, FlxG.height - freelight.height + 190);

		freedot = new FlxSprite();
		freedot.frames = Paths.getSparrowAtlas('freeplay/freedot');
		freedot.animation.addByPrefix('idle', 'freedot idle', 24, true);
		freedot.animation.play('idle');
		freedot.setGraphicSize(freedot.width / 2.2, freedot.height / 2.2);
		freedot.updateHitbox();
		freedot.setPosition(FlxG.width - freedot.width + 100, FlxG.height - freedot.height + 310);

		freeback.antialiasing = ClientPrefs.data.antialiasing;
		freebg.antialiasing = ClientPrefs.data.antialiasing;
		freelight.antialiasing = ClientPrefs.data.antialiasing;
		freedot.antialiasing = ClientPrefs.data.antialiasing;

		freeback.scrollFactor.set();
		freebg.scrollFactor.set();
		freelight.scrollFactor.set();
		freedot.scrollFactor.set();

		freecd = new FlxSprite().loadGraphic(Paths.image('freeplay/freecd'));
		freecd.setGraphicSize(freecd.width / 1.8, freecd.height / 1.8);
		freecd.updateHitbox();
		freecd.setPosition(440, 78);
		freecd.centerOffsets();
		freecd.antialiasing = ClientPrefs.data.antialiasing;
		freecd.scrollFactor.set();

		grpSongs = new FlxTypedGroup<Alphabet>();

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.targetY = i;
			songText.setScale(.45, .95);
			songText.updateHitbox();
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			var freebox = new FreeboxFuck();
			freebox.setGraphicSize(songText.width + 88, songText.height + 35);
			freebox.updateHitbox();
			freebox.sprTracker = songText;

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.flipX = true;
			icon.setGraphicSize(icon.width / 1.5, icon.height / 1.5);
			icon.sprTracker = songText;
			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;
			freebox.visible = freebox.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			// me too
			freeboxArray.push(freebox);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		WeekData.setDirectoryFromWeek();

		var titleWText:WavyLetters = new WavyLetters(7, 10, "Freeplay", 48);
		titleWText.antialiasing = ClientPrefs.data.antialiasing;
		titleWText.scrollFactor.set();

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		freeSongArrowU = new FlxSprite().loadGraphic(Paths.image('freeplay/freeSongArrow', true));
		freeSongArrowD = new FlxSprite().loadGraphic(Paths.image('freeplay/freeSongArrow', true));

		freeSongArrowD.flipY = true;

		freeSongArrowU.antialiasing = ClientPrefs.data.antialiasing;
		freeSongArrowD.antialiasing = ClientPrefs.data.antialiasing;
		freeSongArrowU.scrollFactor.set();
		freeSongArrowD.scrollFactor.set();

		freeSongArrowU.setPosition(FlxG.width - 420, 270);
		freeSongArrowD.setPosition(FlxG.width - 420, 390);
		freeSongArrowU.x -= freeSongArrowU.width;
		freeSongArrowD.x -= freeSongArrowD.width;

		if(curSelected >= songs.length) curSelected = 0;
		freechar1 = new FlxSprite().loadGraphic(Paths.image('freeplay/char/' + songs[curSelected].player1 + '-freeplay', true));
		freechar2 = new FlxSprite().loadGraphic(Paths.image('freeplay/char/' + songs[curSelected].player2 + '-freeplay', true));
		freechar1.setGraphicSize(freechar1.width / 2.5, freechar1.height / 2.5);
		freechar2.setGraphicSize(freechar2.width / 2.5, freechar2.height / 2.5);
		freechar1.updateHitbox();
		freechar2.updateHitbox();
		freechar1.antialiasing = ClientPrefs.data.antialiasing;
		freechar2.antialiasing = ClientPrefs.data.antialiasing;
		freechar1.setPosition(35, -200);
		freechar2.setPosition(175, -425);
		freechar1.centerOffsets();
		freechar2.centerOffsets();
		freechar1.alpha = 0;
		freechar2.alpha = 0;
		freechar1alp = FlxTween.tween(freechar1, {alpha: 0}, 0, {ease: FlxEase.quadOut});
		freechar2alp = FlxTween.tween(freechar2, {alpha: 0}, 0, {ease: FlxEase.quadOut});
		freechar1y = FlxTween.tween(freechar1, {y: 375}, 0, {ease: FlxEase.quadOut});
		freechar2y = FlxTween.tween(freechar2, {y: 150}, 0, {ease: FlxEase.quadOut});
		freechar1float = FlxTween.tween(freechar1, {y: 250}, 0, {ease: FlxEase.quadOut});
		freechar2float = FlxTween.tween(freechar2, {y: 25}, 0, {ease: FlxEase.quadOut});
		freechar1angle = FlxTween.tween(freechar1, {angle: 550}, 0, {ease: FlxEase.quadOut});
		freechar2angle = FlxTween.tween(freechar2, {angle: 350}, 0, {ease: FlxEase.quadOut});
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("mobileone.ttf"), 32, FlxColor.WHITE, RIGHT);

		freeEasy = new FlxSprite().loadGraphic(Paths.image('freeplay/diffcut/easy'));
		freeEasy.antialiasing = ClientPrefs.data.antialiasing;
		freeEasy.scrollFactor.set();

		freeEasy.setGraphicSize(freeEasy.width / 1.5, freeEasy.height / 1.5);
		freeEasy.updateHitbox();

		freeEasy.setPosition(FlxG.width - 415, 605);
		freeEasy.x -= freeEasy.width;

		freeNormal = new FlxSprite().loadGraphic(Paths.image('freeplay/diffcut/normal'));
		freeNormal.antialiasing = ClientPrefs.data.antialiasing;
		freeNormal.scrollFactor.set();

		freeNormal.setGraphicSize(freeNormal.width / 1.5, freeNormal.height / 1.5);
		freeNormal.updateHitbox();

		freeNormal.setPosition(FlxG.width - 215, 605);
		freeNormal.x -= freeNormal.width;

		freeHard = new FlxSprite().loadGraphic(Paths.image('freeplay/diffcut/hard'));
		freeHard.antialiasing = ClientPrefs.data.antialiasing;
		freeHard.scrollFactor.set();

		freeHard.setGraphicSize(freeHard.width / 1.5, freeHard.height / 1.5);
		freeHard.updateHitbox();

		freeHard.setPosition(FlxG.width - 15, 605);
		freeHard.x -= freeHard.width;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 42, 0xFF000000);
		scoreBG.alpha = 0.6;

		add(freeback);
		add(freebg);
		add(freelight);
		add(titleWText);
		add(freechar2);
		add(freechar1);
		add(freecd);
		add(freedot);
		for (freebox in freeboxArray) add(freebox);
		add(grpSongs);
		for (icon in iconArray) add(icon);
		add(freeSongArrowU);
		add(freeSongArrowD);
		add(scoreBG);
		add(scoreText);
		changeSelection();
		updateTexts();
		super.create();
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;

	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
			return;

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		scoreText.text = Language.getPhrase('personal_best', 'PERSONAL BEST: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
		positionHighscore();
		
		if(songs.length > 1)
		{
			if(FlxG.keys.justPressed.HOME)
			{
				curSelected = 0;
				changeSelection();
				holdTime = 0;	
			}
			else if(FlxG.keys.justPressed.END)
			{
				curSelected = songs.length - 1;
				changeSelection();
				holdTime = 0;	
			}
			if (controls.UI_UP_P)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.mouse.visible = true;
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
			}
		}
		
		if (allowMouse || ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
		{
			allowMouse = false;
			FlxG.mouse.visible = true;
			timeNotMoving = 0;

			if(freeEasy != null && FlxG.mouse.overlaps(freeEasy)) {
				allowMouse = true;
				change = 0;
			}
			else if(freeNormal != null && FlxG.mouse.overlaps(freeNormal)) {
				allowMouse = true;
				change = 1;
			}
			else if(freeHard != null && FlxG.mouse.overlaps(freeHard)) {
				allowMouse = true;
				change = 2;
			}
		}
		else {
			timeNotMoving += elapsed;
			if(timeNotMoving > 2) FlxG.mouse.visible = false;
		}

		if (FlxG.mouse.justPressed && allowMouse)
		{
			switch (change)
			{
				case 0:
					changeDiff(0);
					_updateSongLastDifficulty();

				case 1:
					changeDiff(1);
					_updateSongLastDifficulty();

				case 2:
					changeDiff(2);
					_updateSongLastDifficulty();

				default:
					trace('no');

			}
		}

		if (controls.UI_LEFT_P)
		{
			changeDiff(curDifficulty - 1);
			_updateSongLastDifficulty();
		}
		else if (controls.UI_RIGHT_P)
		{
			changeDiff(curDifficulty + 1);
			_updateSongLastDifficulty();
		}

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new AdventureMainMenuState());
		}
		
		else if (controls.ACCEPT)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			FlxG.mouse.visible = false;

			try
			{
				Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch(e:haxe.Exception)
			{
				trace('ERROR! ${e.message}');

				var errorStr:String = e.message;
				if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
				else errorStr += '\n\n' + e.stack;

				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.mouse.visible = true;

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			
			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
			#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
			stopMusicPlay = true;

			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if (canSpin && !isResetting) {
			cdSpeed = Math.min(cdSpeed + cdAccel * elapsed * 60, cdTargetSpeed);
			freecd.angle += cdSpeed;
		}

		if(freechar1y.finished) {
			floatTimer += elapsed * floatSpeed;
			
			var offsetY:Float = Math.sin(floatTimer * 0.75) * floatRange;
			freechar1.y = char1BaseY + offsetY;
			freechar2.y = char2BaseY + offsetY;
			
			var angleOffset:Float = Math.sin(floatTimer * 0.3) * angleRange;
			freechar1.angle = -angleOffset;
			freechar2.angle = angleOffset;
		}

		if (camZooming) {
			var decay:Float = Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate);
        	FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, decay);
		}

		Conductor.songPosition = FlxG.sound.music.time;

		updateTexts(elapsed);
		super.update(elapsed);
	}

	override function beatHit()
	{
		if (camZooming && ClientPrefs.data.camZooms)
			FlxG.camera.zoom += 0.025 * camZoomingMult;

		super.beatHit();
	}

	function changeDiff(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);

		curDifficulty = FlxMath.wrap(change, 0, Difficulty.list.length-1);
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty, false);

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);

		isResetting = true;
		canSpin = false;

		Conductor.bpm = 0;
		Conductor.songPosition = 0;

		FlxTween.angle(freecd, freecd.angle, 0, 0.5, {
			ease: FlxEase.cubeOut,
			onComplete: function(_) {
				new FlxTimer().start(1, function(_) {
					cdTargetSpeed = (songs[curSelected].speed / 2) * 1.0;
					cdSpeed = 0.5;
					isResetting = false;
					canSpin = true;
					Conductor.bpm = songs[curSelected].bpm;
					Conductor.songPosition = 0;
				});
			}
		});

		freeSongArrowU.visible = (curSelected > 0);
    	freeSongArrowD.visible = (curSelected < songs.length-1);

		freeSongArrowU.x = FlxG.width - 420 - grpSongs.members[curSelected].width / 2 + freeSongArrowU.width * 1.5;
		freeSongArrowD.x = FlxG.width - 420 - grpSongs.members[curSelected].width / 2 + freeSongArrowD.width * 1.5;

		floatTimer = 0;
		freechar1alp.cancel();
		freechar2alp.cancel();
		freechar1y.cancel();
		freechar2y.cancel();
		freechar2float.cancel();
		freechar1float.cancel();
		freechar2angle.cancel();
		freechar1angle.cancel();
		freechar1.loadGraphic(Paths.image('freeplay/char/' + songs[curSelected].player1 + '-freeplay', true));
		freechar2.loadGraphic(Paths.image('freeplay/char/' + songs[curSelected].player2 + '-freeplay', true));
		freechar1.setPosition(35, -200);
		freechar2.setPosition(175, -425);
		freechar1.alpha = 0;
		freechar2.alpha = 0;
		freechar1.angle = 0;
		freechar2.angle = 0;
		freechar1alp = FlxTween.tween(freechar1, {alpha: 1}, 2.0, {ease: FlxEase.quadOut});
		freechar2alp = FlxTween.tween(freechar2, {alpha: 1}, 2.0, {ease: FlxEase.quadOut});
		freechar1y = FlxTween.tween(freechar1, {y: 275}, 1.5, {ease: FlxEase.quadOut});
		freechar2y = FlxTween.tween(freechar2, {y: 50}, 1.5, {ease: FlxEase.quadOut});

		remove(freeEasy);
		remove(freeNormal);
		remove(freeHard);

		var diffs = [];

		if (Paths.fileExists('data/' + Paths.formatToSongPath(songs[curSelected].songName) + '/' + Paths.formatToSongPath(songs[curSelected].songName) + '-easy.json', TEXT)) diffs.push('easy');
		if (Paths.fileExists('data/' + Paths.formatToSongPath(songs[curSelected].songName) + '/' + Paths.formatToSongPath(songs[curSelected].songName) + '.json', TEXT)) diffs.push('normal');
		if (Paths.fileExists('data/' + Paths.formatToSongPath(songs[curSelected].songName) + '/' + Paths.formatToSongPath(songs[curSelected].songName) + '-hard.json', TEXT)) diffs.push('hard');

		if (diffs.length == 0) diffs.push('normal');

		for (diff in diffs) {
			switch (diff) {
				case 'easy':
					add(freeEasy);

				case 'normal':
					add(freeNormal);

				case 'hard':
					add(freeHard);

			}
		}

		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff(curDifficulty);
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty() songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = false;
			freeboxArray[i].visible = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			var offset:Float = item.targetY - lerpSelected;

			var waveX:Float = -(Math.pow(Math.abs(offset), 1.3) * 75);

			item.x = FlxG.width - 200 - waveX - item.width;
			item.y = ((item.targetY - lerpSelected) * item.distancePerItem.y) + item.startPosition.y;

			var icon:HealthIcon = iconArray[i];
			var freebox:FlxSprite = freeboxArray[i];
			icon.visible = icon.active = true;
			freebox.visible = freebox.active = true;
			_lastVisibles.push(i);
		}
	}

	override function destroy() {
		if (grpSongs != null)
			for (song in grpSongs.members)
				song.destroy();

		grpSongs = null;
		
		if (iconArray != null)
			for (icon in iconArray)
				icon.destroy();

		iconArray = null;

		if (freeboxArray != null)
			for (freebox in freeboxArray)
				freebox.destroy();

		freeboxArray = null;

		if (freeEasy != null) 
			freeEasy.destroy();

		if (freeNormal != null)
			freeNormal.destroy();

		if (freeHard != null)
			freeHard.destroy();

		if (freeSongArrowU != null)
			freeSongArrowU.destroy();

		if (freeSongArrowD != null)
			freeSongArrowD.destroy();

		if (freechar1 != null)
			freechar1.destroy();

		if (freechar2 != null)
			freechar2.destroy();
		
		super.destroy();
	}
}

class SongMetadata {
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var folder:String = "";
	public var lastDifficulty:String = null;
	public var player1:String = 'what1';
	public var player2:String = 'what2';
	public var bpm:Float = 100;
	public var speed:Float = 1;

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';

		var songLowercase:String = Paths.formatToSongPath(songName);
		var poop:String = Highscore.formatSong(songLowercase, 1);

		try {
			var gettingJsonFlie = Song.getChart(poop, songLowercase);
			player1 = gettingJsonFlie.player1;
			player2 = gettingJsonFlie.player2;
			speed = gettingJsonFlie.speed;
		}
	}
}

class FreeboxFuck extends FlxSprite {
	public var sprTracker:FlxSprite;

	public function new()
	{
		super();
		frames = Paths.getSparrowAtlas('freeplay/freebox');
		animation.addByPrefix('idle', 'freebox idle', 24, true);
		animation.play('idle');
		updateHitbox();
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x - 38, sprTracker.y - 15);
	}
}