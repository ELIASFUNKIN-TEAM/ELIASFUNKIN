package options.objects;

import options.Option;
import options.OptionsSubState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;

class HateSlider extends FlxSpriteGroup {
    public var option:Option;

	var curBarWidth:Float = 0;

	public var body:FlxSprite;
	public var bar:FlxSprite;
	public var handle:FlxSprite;
	public var valueLabel:FlxText;
	public var valueBG:FlxSprite;
	public var value:Float;
	public var minValue:Float;
	public var maxValue:Float;
	public var decimals:Int = 0;
	public var callback:Void->Void = null;
	public var setVariable:Bool = true;
	public var expectedPos(get, never):Float;
	public var relativePos(get, never):Float;
	public var varString(default, set):String;

	var _bounds:FlxSprite;
	var _width:Int;
	var _height:Int;
	var _color:FlxColor;
	var _barColor:FlxColor;
	var _handleColor:FlxColor;
	var _handleLineColor:FlxColor;
	var _lastPos:Float;
	var _justHovered:Bool = false;

	public var onUpdate(default, null):Void->Void;

	public var name:String;
	public var broadcastToFlxUI:Bool = true;
	public static inline var CHANGE_EVENT:String = "change_slider";

	public function new(x:Float, y:Float, option:Option, onUpdate:Void->Void, cam:FlxCamera) {
		super();
		this.x = x;
		this.y = y;
		this.option = option;
		this.value = option.value;
		this.antialiasing = ClientPrefs.data.antialiasing;
		this.callback = option.onChange;
		this.onUpdate = onUpdate;

		decimals = option.decimals;
		minValue = option.minValue;
		maxValue = option.maxValue;
		varString = option.variable;
		_width = 500;
		_height = 19;
		_color = 0xFFE0E8B7;
		_barColor = 0xFFCBEA84;
		_handleColor = 0xFFE9F5CF;
		_handleLineColor = 0xFFAFD195;

		camera = cam;

		createSlider();
	}

	function createSlider():Void {
		offset.set(7, 8);
		_bounds = new FlxSprite(x, y).makeGraphic(_width, _height);

		body = new FlxSprite(offset.x, offset.y).makeGraphic(_width, _height, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRoundRect(body, 0, 0, body.width, body.height, 25, 25, _color);

		bar = new FlxSprite(offset.x, offset.y);
		bar.makeGraphic(_width, _height, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawRoundRect(bar, 0, 0, 0, _height, 25, 25, _barColor);

		handle = new FlxSprite(0, 0).makeGraphic(46, 46, FlxColor.TRANSPARENT);
		handle.setPosition(expectedPos, offset.y - 13);
		FlxSpriteUtil.drawRoundRect(handle, 0, 0, 46, 46, 27, 27, _handleLineColor);
		FlxSpriteUtil.drawRoundRect(handle, 7, 7, 32, 32, 15, 15, _handleColor);

		var textOffset:Float = _width + offset.x + 28;
		valueBG = new FlxSprite(textOffset, -6).makeGraphic(165, 48, FlxColor.TRANSPARENT);
		FlxSpriteUtil.drawRoundRect(valueBG, 0, 0, valueBG.width, valueBG.height, 16, 16, _color);
		valueLabel = new FlxText(0, 0, valueBG.width, "", 19);
		valueLabel.setFormat(Paths.font("mobileone.ttf"), 19, FlxColor.BLACK, CENTER);
		valueLabel.setPosition(valueBG.x + valueBG.width / 2 - valueLabel.width / 2, valueBG.y + valueBG.height / 2 - valueLabel.height / 2);
		valueLabel.scrollFactor.set();

		add(body);
		add(bar);
		add(handle);
		add(valueBG);
		add(valueLabel);
	}

	override public function update(elapsed:Float):Void {
		final viewX = FlxG.mouse.screenX - camera.x;

		if (onUpdate != null) onUpdate();
		decimals = option.decimals;
		minValue = option.minValue;
		maxValue = option.maxValue;

		if (value > maxValue) {
			handle.x = x + offset.x + _width - handle.width;
			updateValue();
		}

		if (FlxG.mouse.pressed && FlxG.mouse.overlaps(_bounds, camera)) {
			var pos = FlxMath.bound(viewX - x - offset.x, 0, _width - handle.width);
			handle.x = x + offset.x + pos;
			updateValue();
			OptionsSubState.sliderHanding = true;
		}
		else {
			OptionsSubState.sliderHanding = false;
		}

		if (curBarWidth != expectedPos) {
			updateBarFill();
			handle.x = expectedPos;
		}

		valueLabel.text = formatText(FlxMath.roundDecimal(value, decimals));
		super.update(elapsed);
	}

	function updateValue():Void {
		var percent = (handle.x - x - offset.x) / (_width - handle.width);
		percent = FlxMath.bound(percent, 0, 1);
		var newValue = minValue + (maxValue - minValue) * percent;
		newValue = Math.round(newValue / option.changeValue) * option.changeValue;

		if (newValue == value)
			return;

		value = newValue;

		if (setVariable && varString != null) {
			if (Std.isOfType(option, GameplayOption))
				cast(option, GameplayOption).value = value;
			else
				option.value = value;

			if (callback != null)
				callback();
		}
	}

	function formatText(value:Dynamic) {
		var text:String = option.displayFormat;
		if(option.type == PERCENT) value *= 100;
		return text.replace('%v', value);
	}

	function updateBarFill():Void {
        bar.pixels.fillRect(bar.pixels.rect, 0);
        FlxSpriteUtil.drawRoundRect(bar, 0, 0, expectedPos - x - offset.x + handle.width / 2, _height, 25, 25, _barColor);
        bar.dirty = true;
        curBarWidth = expectedPos;
    }

	function get_expectedPos():Float {
		var percent = (value - minValue) / (maxValue - minValue);
		return x + offset.x + percent * (_width - handle.width);
	}

	function get_relativePos():Float {
		return (handle.x - x - offset.x) / (_width - handle.width);
	}

	function set_varString(Value:String):String {
		try {
			if (Std.isOfType(option, GameplayOption))
				cast(option, GameplayOption).saveData.get(Value);
			else
				Reflect.getProperty(option.saveData, Value);
			varString = Value;
		} catch (e:Dynamic) {
			FlxG.log.error("Could not create HateSlider - '" + Value + "' is not a valid field");
			varString = null;
		}
		return Value;
	}

	override function set_x(value:Float):Float {
		super.set_x(value);
		updateBounds();
		return value;
	}

	override function set_y(value:Float):Float {
		super.set_y(value);
		updateBounds();
		return value;
	}

	inline function updateBounds() {
		if (_bounds != null) {
			_bounds.destroy();
			_bounds = new FlxSprite(x, y).makeGraphic(_width, _height);
		}
	}

	override public function destroy():Void {
		body = FlxDestroyUtil.destroy(body);
		bar = FlxDestroyUtil.destroy(bar);
		handle = FlxDestroyUtil.destroy(handle);
		valueLabel = FlxDestroyUtil.destroy(valueLabel);
		valueBG = FlxDestroyUtil.destroy(valueBG);
		_bounds = FlxDestroyUtil.destroy(_bounds);
		super.destroy();
	}
}