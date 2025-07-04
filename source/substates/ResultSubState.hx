package substates;

import flixel.util.FlxGradient;
import openfl.display.Shape;
import objects.Character;

class ResultSubState extends MusicBeatSubstate {
    public var boyfriend:Character;
    var boyName:String = 'bf';

    public var backCam:FlxCamera;
    public var boyCam:FlxCamera;
    public var itemCam:FlxCamera;
    public var frontCam:FlxCamera;

    public var leaveCallback:Void->Void = null;

    public function new(character:Character, callback:Void->Void) {
        super();

        boyName = character.curCharacter;
        leaveCallback = callback;
    }

    override function create() {
        #if DISCORD_ALLOWED
		if (PlayState.instance.autoUpdateRPC)
			DiscordClient.changePresence(PlayState.instance.detailsResultText, PlayState.SONG.song + " (" + PlayState.instance.storyDifficultyText + ")", PlayState.instance.iconP2.getCharacter());
		#end

        createUIs();
        settingCameras();
    }

    private function createUIs() {
        boyfriend = new Character(0, -225, boyName, false);
        boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
        boyfriend.scrollFactor.set();
        boyfriend.antialiasing = ClientPrefs.data.antialiasing;
	}

	private function settingCameras() {
        backCam = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		backCam.bgColor = 0x00000000;
		FlxG.cameras.add(backCam, false);

        boyCam = new FlxCamera(115, 100, 420, 420);
		boyCam.bgColor = 0x00000000;
		FlxG.cameras.add(boyCam, false);

        var mask = new Shape();
        mask.graphics.beginFill(0x00000000);
        mask.graphics.drawCircle(210, 210, 210);
        mask.graphics.endFill();

        boyCam.canvas.mask = mask;
        boyCam.canvas.addChild(mask);

		itemCam = new FlxCamera(630, 220, 630, 380);
		itemCam.bgColor = 0xFF000000;
		FlxG.cameras.add(itemCam, false);

		frontCam = new FlxCamera(0, 0, Std.int(FlxG.width), Std.int(FlxG.height));
		frontCam.bgColor = 0x00000000;
		FlxG.cameras.add(frontCam, false);

        var boyBackBG:FlxSprite = new FlxSprite().makeGraphic(420, 420, 0xFF3BA251);
        add(boyBackBG);
        add(boyfriend); // ugly adding
        boyBackBG.camera = boyCam;
        boyfriend.camera = boyCam;
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.ACCEPT) leaveCallback();
    }

    override function destroy():Void {
		super.destroy();

		FlxG.cameras.remove(backCam);
		FlxG.cameras.remove(boyCam);
		FlxG.cameras.remove(itemCam);
		FlxG.cameras.remove(frontCam);
	}
}