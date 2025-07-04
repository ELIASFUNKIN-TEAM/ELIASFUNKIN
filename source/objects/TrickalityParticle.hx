package objects;

import flixel.math.FlxRandom;
import flixel.effects.particles.FlxParticle;
import flixel.util.helpers.FlxRange;

class TrickalityParticle extends FlxParticle implements ITrickalityParticle {
    public var randomScaleX:Float;
    public var randomScaleY:Float;
    
    public var particleType(default, set):TrickalityParticleType;
    public var particleColorArray:Array<FlxColor> = [];
    
	public function new(particleType:TrickalityParticleType = CRUSHEDHEART) {
		super();

        var randomF:FlxRandom = new FlxRandom();
        randomScaleX = randomF.float(0.5);
        randomScaleY = randomF.float(0.5);

        this.particleType = particleType;
        this.scale.set(0, 0);
        
        if (particleType == ROUNDEDSTAR) {
            particleColorArray = [0xFFDAE7B6, 0xFFFCFDE1, 0xFFDFF9D8, 0xFFDDF699, 0xFFDEFACC];
            angularVelocityRange = new FlxRange<Float>(36 * Math.PI);
            accelerationRange = new FlxRange<FlxPoint>(FlxPoint.get(), FlxPoint.get(0, 300));
        }
        else {
            particleColorArray = [0xFFFFA49B, 0xFFFFC816, 0xFF76BF68, 0xFFE0AEF4, 0xFFCAF04F];
            dragRange = new FlxRange<FlxPoint>(FlxPoint.get(), FlxPoint.get(300, 300));
        }

        this.scale.set(randomScaleX, randomScaleY);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

        if (particleType == ROUNDEDSTAR) {
            angle += elapsed * 150 * Math.PI;

            if (age > lifespan / 2)
                y += elapsed * 250;
        }
	}

    override public function kill()
        FlxTween.tween(this, {'scale.x': 0, 'scale.y': 0}, 0.5, {onComplete: onTweenComplete});

    function onTweenComplete(tween:FlxTween) 
        super.kill();

	override public function onEmit():Void {
        FlxTween.tween(this, {'scale.x': randomScaleX, 'scale.y': randomScaleY}, 0.3);

        var randomI:Int = FlxG.random.int(0, 4);
        color = particleColorArray[randomI];
    }

    // setters
    function set_particleType(type:TrickalityParticleType):TrickalityParticleType {
        loadGraphic(Paths.image('particles/$type'));

        return particleType = type;
    }
}

enum abstract TrickalityParticleType(String) {
    var CRUSHEDHEART = "crushedHeart";
    var ROUNDEDSTAR = "roundedStar";
}

interface ITrickalityParticle extends IFlxParticle{
    public var randomScaleX:Float;
    public var randomScaleY:Float;
    
    public var particleType(default, set):TrickalityParticleType;
}