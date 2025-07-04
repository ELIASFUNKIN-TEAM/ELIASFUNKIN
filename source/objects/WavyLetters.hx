package objects;

class WavyLetters extends FlxTypedSpriteGroup<FlxText> {
    public var text(default, set):String;
    public var letters:Array<FlxText> = [];

    public var textSize:Int;
    public var textColor:FlxColor;
    public var waveSpeed:Float;
    public var waveHeight:Float;
    public var border:FlxTextBorderStyle;
    public var bordercolor:FlxColor;
    var baseY:Float;

    public function new(
        x:Float,
        y:Float,
        text:String,
        ?textSize:Int = 16,
        ?textColor:FlxColor = FlxColor.WHITE,
        ?waveSpeed:Float = 4.2,
        ?waveHeight:Float = 5.0,
        ?border:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE,
        ?bordercolor:FlxColor = FlxColor.BLACK
    ) {
        super(x, y);
        baseY = y;

        this.textSize = textSize;
        this.textColor = textColor;
        this.waveSpeed = waveSpeed;
        this.waveHeight = waveHeight;
        this.border = border;
        this.bordercolor = bordercolor;

        this.text = text;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        var time = FlxG.game.ticks / 1000;

        for (i in 0...letters.length) {
            var offset = FlxMath.fastSin((time * waveSpeed) + (i * 0.4));
            var targetY = FlxMath.lerp(baseY, baseY + offset * waveHeight, offset);
            letters[i].y = targetY;
        }
    }

    function set_text(txt:String):String {
        for (letter in letters) 
            remove(letter, true);

        letters = [];

        var xOffset:Float = 0;
        for (i in 0...txt.length) {
            var char = txt.charAt(i);
            var letter = new FlxText(x + xOffset, y, 0, char, textSize);
            letter.setFormat(Paths.font("mobileone.ttf"), textSize, textColor, border, bordercolor);
            letter.updateHitbox();
            xOffset += letter.width - 0.08 * textSize;
            letters.push(letter);
            add(letter);
        }

        return text = txt;
    }
}