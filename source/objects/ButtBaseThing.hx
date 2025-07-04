package objects;

import flixel.ui.FlxButton;
import flixel.graphics.FlxGraphic;

/**
 * ButtBaseThing class for my convenience.
 * You(and I) can add "extends" to another class
 * @author suil
 */
class ButtBaseThing extends FlxTypedButton<FlxText> {
    /**
     * default checked graphic, don't change it!
     */
    private var default_ckedGraphic(default, never):FlxGraphic = Paths.image('options/checked-button');
	
    /**
     * default unchecked graphic, don't change it!
     */
    private var default_unckedGraphic(default, never):FlxGraphic = Paths.image('options/button');

	/**
     * set your(and my) custom checked FlxGraphic.
     */
    public var ckedGraphic:FlxGraphic;
	
    /**
     * set your(and my) custom unchecked FlxGraphic.
     */
    public var unckedGraphic:FlxGraphic;

    /**
     * text have getter and setter method.
     * getter returns this.label.text.
     * setter do initLabel(txt) or this.label.text = txt.
     */
    public var text(get, set):String;

    /**
     * why (pretty self explanatory huh)
     * getter returns this.isChecked (default lol)
     * setter do box graphic tweens
     */
	public var isChecked(default, set):Bool = false;

    /**
     * clicking callback
     */
	public var onClickingCallback(never, set):Void->Void;

    /**
     * clicked and up callback
     */
	public var onClickedUpCallback(never, set):Void->Void;

    /**
     * overlap callback
     */
	public var onOverlapCallback(never, set):Void->Void;

    /**
     * out callback
     */
	public var onOutCallback(never, set):Void->Void;

    /**
     * isChecked?
     */
	public var checkedCondition:Void->Void;

    /**
     * custom update label
     */
	public var customUpdateLabelPosition:FlxSprite->Void;

    /**
     * color tween like (pretty self explanatory huh)
     */
	public var colorTween:FlxTween;

    /**
     * scale tween like (pretty self explanatory huh)
     */
	public var scaleTween:FlxTween;

    /**
	 * Creates a new ButtThing.
	 *
	 * @param	X 			        x Position
	 * @param	Y 		            y Position
	 * @param	Text				this label's text
	 * @param	PhraseName			PhraseName gg
	 */
    public function new(
			X:Float = 0,
			Y:Float = 0,
			Text:String,
			PhraseName:String,
		) {
		ckedGraphic = default_ckedGraphic;
		unckedGraphic = default_unckedGraphic;

		checkedCondition = function() isChecked = true;

		super(X, Y, function() {});

		loadGraphic(isChecked ? default_ckedGraphic : default_unckedGraphic);

		colorTween = FlxTween.tween(this, {color: 0xFFFFFFF}, 0);
		color = 0xFFFFFFFF;

		initLabel(Language.getPhrase(PhraseName, Text));

		updateHitbox();
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function resetHelpers():Void {
		super.resetHelpers();

		if (label != null) {
			label.fieldWidth = label.frameWidth = Std.int(width);
			label.size = label.size; // Calls set_size(), don't remove!
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function updateStatusAnimation():Void
		return; // hmm, this class haven't updateStatusAnimation

	override function updateLabelPosition() {
		if (_spriteLabel != null) { // Label positioning
			if (customUpdateLabelPosition != null) {
				customUpdateLabelPosition(_spriteLabel);
				return;
			}
			_spriteLabel.x = (pixelPerfectPosition ? Math.floor(x) : x) + labelOffsets[status].x;
			_spriteLabel.y = pixelPerfectPosition ? Math.floor(y + labelOffsets[status].y / 2) : y + labelOffsets[status].y / 2;
		}
	}

	/**
	 * Init your(and my) label
	 * @param Text				this label's text
	 */
	private function initLabel(Text:String):Bool {
		try {
			label = new FlxText(0, 0, width, Text, 12);
			label.setFormat(Paths.font("mobileone.ttf"), 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			label.setPosition(x + width / 2 - label.width / 2, y + height / 2 - label.height / 2);
			label.drawFrame(true);

			return true;
		}
		catch(e) {
			trace('Text is null (' + e + ')');
			return false;
		}
	}

    // getters
    inline function get_text():String return (label != null) ? label.text : null;

    // setters
	inline function set_onClickingCallback(func:Void->Void):Void->Void {
		return onDown.callback = function()
			if (func != null) func();
	}

	inline function set_onClickedUpCallback(func:Void->Void):Void->Void {
		return onUp.callback = function() {
            if (!isChecked) {
				colorTween.cancel();
                color = 0xFFFFFFFF;

                if (func != null) func();

                checkedCondition();
            }
        }
	}

	inline function set_onOverlapCallback(func:Void->Void):Void->Void {
		return onOver.callback = function()
			if (func != null) func();
	}

	inline function set_onOutCallback(func:Void->Void):Void->Void {
		return onOut.callback = function() {
			colorTween.cancel();
			color = 0xFFFFFFFF;

			if (func != null) func();
		}
	}

	inline function set_text(Text:String):String {
		if (label == null) 
			initLabel(Text);
		else 
			label.text = Text;

		return Text;
	}

	inline function set_isChecked(bool:Bool):Bool {
		color = 0xFFFFFFFF;

		loadGraphic(bool ? ckedGraphic : unckedGraphic);

        return isChecked = bool;
	}
}