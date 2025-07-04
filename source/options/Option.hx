package options;

import backend.InputFormatter;
import objects.ButtBaseThing;
import options.objects.HateSlider;
import flixel.input.keyboard.FlxKey;

enum OptionType {
	BOOL;
	INT;
	FLOAT;
	PERCENT;
	STRING;
	KEYBIND;
	TITLE;
}

class Option {
	/// very cursetomizable variables
	public var onSelect:Void->Void;
	public var onChange:Void->Void;
	public var onNotSelect:Void->Void;

	/// just normal option's variables 
	public var name:String = 'Unknown';
	public var variable(default, null):String = null; //Variable from ClientPrefs.hx
	public var type:OptionType = BOOL;
	public var value(get, set):Dynamic;
	public var defaultValue:Dynamic;
	public var options:Array<String> = null; //Only used in string type

	public var selectable:Bool = true; // who hate this options?

	// i fucking hate languages
	public var languaged_name:String = 'Unknown';
	public var languaged_description:String = '';
	public var languaged_options:Array<String> = [];
	public var unlanguaged_name:String = 'Unknown';
	public var unlanguaged_description:String = '';
	public var unlanguaged_options:Array<String> = [];

	// change it, never mind.
	public var changeValue:Dynamic = 1; // why
	public var scrollSpeed:Float = 50; // holding
	public var minValue:Dynamic = null; //Only used in int/float/percent type
	public var maxValue:Dynamic = null; //Only used in int/float/percent type
	public var decimals:Int = 1; //Only used in float/percent type
	public var displayFormat:String = '%v'; //How String/Float/Percent/Int values are shown, %v = Current value, %d = Default value

	/// visualed option just like fucks
	public var boxes:Array<ButtBaseThing> = [];

	// shotcuts
	public var saveData(get, never):Dynamic;

	public function new(name:String, variable:String, type:OptionType = BOOL, defaultValue:Dynamic = 'null variable value', ?options:Array<String> = null, ?dontFindValue:Bool = false)
	{
		if(type == TITLE) this.languaged_name = Language.getPhrase('title_$name', name);
		else if(type != KEYBIND) this.languaged_name = Language.getPhrase('setting_$name', name);
		else if(type == KEYBIND) this.languaged_name = Language.getPhrase('setting_$variable', name);
		unlanguaged_name = name;

		this.name = languaged_name;

		this.variable = variable;
		this.type = type;
		this.defaultValue = defaultValue;

		if (options != null && options.length > 0) {
			for (text in options) {
				languaged_options.push(Language.getPhrase('setting_$name-$text', text));
			}
			unlanguaged_options = options.copy();
		}
			
		this.options = languaged_options.length > 0 ? languaged_options : options;

		try
		{
			if (type != TITLE && dontFindValue)
				if (value == null) 
					value = defaultValue;

			switch(type) {
				case BOOL: if(defaultValue == 'null variable value') this.defaultValue = false;
				case INT | FLOAT: if(defaultValue == 'null variable value') this.defaultValue = 0;
				case PERCENT:
					if(defaultValue == 'null variable value') this.defaultValue = 1;
					displayFormat = '%v%';
					changeValue = 0.01;
					minValue = 0;
					maxValue = 1;
					scrollSpeed = 0.5;
					decimals = 2;

				case STRING:
					changeValue = 1;
					if(options != null && options.length > 0) defaultValue = value;
					if(defaultValue == 'null variable value') this.defaultValue = '';

				case TITLE:
					selectable = false;
					this.variable = '';
			
				default:
			}
		}
		catch(e) trace('Option init failed: ' + e); // trace("fuuuuuuuuuuuuuuuuuuuuuuuuuuuuck");
	}

	// very customizable functions
	public function select():Void
		if (onSelect != null)
			onSelect();
	
	public function change():Void
		if (onChange != null)
			onChange();
	
	public function notSelect():Void
		if (onNotSelect != null)
			onNotSelect();
	
	// getters
	function get_value():Dynamic
		return Reflect.getProperty(ClientPrefs.data, variable);

	function get_saveData():Dynamic
		return ClientPrefs.data;

	// setters
	function set_value(value:Dynamic):Dynamic {
		if(variable == 'language') { // language is making a problem, so i made this
			if(value == 'English (US)') {
				value = 'en-US';
			}
			else if(value == '한국어 (Korea)') {
				value = 'ko-KR';
			}
		}
		Reflect.setProperty(ClientPrefs.data, variable, value);
		return value;
	}
}

class GameplayOption extends Option {
	public function new(name:String, variable:String, type:OptionType, defaultValue:Dynamic = 'null variable value', ?options:Array<String> = null)
	{
		switch(type)
		{
			case KEYBIND:
				trace('This Type is not supported in GameplayOption');
				return;
			default:
				super(name, variable, type, defaultValue, options, true);
				if (value == null) 
					value = defaultValue;
		}
	}

	override function get_value():Dynamic return ClientPrefs.data.gameplaySettings.get(variable);

	override function set_value(value:Dynamic):Dynamic {
		ClientPrefs.data.gameplaySettings.set(variable, value);
		return value;
	}

	override function get_saveData():Dynamic return ClientPrefs.data.gameplaySettings;
}

class ControlOption extends Option {
    public var keys:Array<FlxKey>;

	public var alt:Bool = false;

    public function new(name: String, variable:String, type:OptionType, defaultValue:Dynamic = 'null variable value', ?options:Array<String> = null)
    {
		switch(type)
		{
			case KEYBIND | TITLE:
				super(name, variable, type, defaultValue, options, true);
				if (ClientPrefs.keyBinds.get(variable) == null) {
					ClientPrefs.loadDefaultKeys();
					ClientPrefs.resetKeys();
					ClientPrefs.saveSettings();
				}
				keys = ClientPrefs.keyBinds.get(variable);
			default:
				trace('This Type is not supported in ControlOption');
				return;
		}
    }

    override function get_value():Dynamic
    {	
		var keys:Array<String> = [];

		for (i => option in ClientPrefs.keyBinds) {
			if(i == variable)
			{
				keys.push(InputFormatter.getKeyName(option[0]));
				keys.push(option.length > 1 ? InputFormatter.getKeyName(option[1]) : null);
				break;
			}
		}
		return keys;
    }

    override function set_value(value:Dynamic):Dynamic // haha value:Dynamic? fuck you bruh
    {
		if (keys == null) {
			keys = [NONE, NONE];
		}
		if (!Std.isOfType(value, Array)) {
			if (alt)
				keys[1] = value;
			else
				keys[0] = value;
		}
		else {
			keys = value;
		}

		ClientPrefs.keyBinds.set(variable, keys);
		ClientPrefs.saveSettings();
		return value;
    }

	public function resetAllKeys() {
		ClientPrefs.loadDefaultKeys();
		ClientPrefs.resetKeys();
		ClientPrefs.saveSettings();
	}

	override function get_saveData():Dynamic return ClientPrefs.keyBinds;
}