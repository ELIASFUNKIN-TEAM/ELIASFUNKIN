package objects;

typedef AnimeSettings = {
    var startPos:Float;
    var endPos:Float;
    var duration:Float;
    var ?loop:Int;
}

typedef AnimeCallbacks = {
    var ?onStart:Void->Void;
    var ?onUpdate:Void->Void;
    var ?onMiddle:Void->Void;
    var ?onLoop:Void->Void;
    var ?onComplete:Void->Void;
}

class TrickalityFigure extends FlxSprite {
    public var figureName(default, null):String = 'bf';
    public var anime(default, null):TrickalityAnime;
// var control:Controls;

    public function new(figureName:String, x:Float, y:Float) {
        super(x, y);
        loadGraphic(Paths.image('figures/' + figureName + '-figure'));
        updateHitbox();
// control = new Controls();

        anime = new TrickalityAnime(this);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        anime.update(elapsed);

        // if (control.UI_UP_P) anime.doLongBopping(y);
        // if (control.UI_DOWN_P) anime.doConfused({startPos: x, endPos: 25, duration: 1});
    }
}

class TrickalityAnime {
    private var object:TrickalityFigure;
    private var elapsedTime:Float = 0;
    public var curAnime:String = 'null';
    private var animeSettings:AnimeSettings;
    private var animeCallbacks:AnimeCallbacks;
    public var animeMiddle(default, null):Bool = false;
    public var animeDone(default, null):Bool = false;

    public var exists:Bool = true;

    public function new(object:TrickalityFigure) {
        this.object = object;
        doIdle({startPos: 1, endPos: 1.07, duration: .67, loop: -1});
    }

    public function update(elapsed:Float) {
        if (exists) {
            switch (curAnime) {
                case 'idle':
                    idle(elapsed);
                case 'bopping':
                    bopping(elapsed);
                case 'confused':
                    confused(elapsed);
                default: // nothing. (not anything else here?)
            }
        }
    }

    /// public
    public function doIdle(animeSettings:AnimeSettings, ?animeCallbacks:AnimeCallbacks)
        if (exists) initDoFuncs('idle', animeSettings, animeCallbacks) else return;

    public function doBopping(animeSettings:AnimeSettings, ?animeCallbacks:AnimeCallbacks)
        if (exists) initDoFuncs('bopping', animeSettings, animeCallbacks) else return;

    public function doConfused(animeSettings:AnimeSettings, ?animeCallbacks:AnimeCallbacks)
        if (exists) initDoFuncs('confused', animeSettings, animeCallbacks) else return;

    // auto completes
    public function doShotBopping(startPos:Float, ?duration:Float, ?loop:Int, ?animeCallbacks:AnimeCallbacks)
        if (exists) initDoFuncs('bopping', {startPos: startPos, endPos: 10, duration: duration != null ? duration : 0.15, loop: loop}, animeCallbacks) else return;

    public function doLongBopping(startPos:Float, ?duration:Float, ?loop:Int, ?animeCallbacks:AnimeCallbacks)
        if (exists) initDoFuncs('bopping', {startPos: startPos, endPos: 30, duration: duration != null ? duration : 0.3, loop: loop}, animeCallbacks) else return;

    function initDoFuncs(animeName:String = 'idle', animeSettings:AnimeSettings, ?animeCallbacks:AnimeCallbacks) {
        this.animeSettings = animeSettings;
        this.animeCallbacks = animeCallbacks;

        curAnime = animeName;

        elapsedTime = 0;

        animeMiddle = false;
        animeDone = false;

        if (curAnime != 'idle')
            FlxTween.tween(this.object, {'scale.x': 1, 'scale.y': 1}, 0.05);

        if (this.animeCallbacks != null && this.animeCallbacks.onStart != null)
            this.animeCallbacks.onStart();
    }

    /// anime func
    function idle(elapsed:Float) {
        if (animeDone) return;

        elapsedTime += elapsed;
        var percent = elapsedTime / animeSettings.duration;

        if (percent > 1) {
            percent = 1;
            animeDone = true;
        }

        var realEndPos:Float = animeSettings.endPos - animeSettings.startPos;

        var highScaleX:Float = realEndPos * 2.3;
        var lowScaleX:Float = realEndPos / 2;

        var offset = FlxMath.fastSin(percent * 2 * Math.PI);
        var targetScaleX = FlxMath.lerp(animeSettings.startPos, animeSettings.startPos - highScaleX, offset);
        var targetScaleY = FlxMath.lerp(animeSettings.startPos, animeSettings.startPos + lowScaleX, offset);

        object.scale.set(targetScaleX, targetScaleY);

        if (animeDone)
            object.scale.set(animeSettings.startPos, animeSettings.startPos);

        var isCallbackExist:Bool = animeCallbacks != null;

        lastFuncHelper(
            percent,
            isCallbackExist ? animeCallbacks.onUpdate : null,
            isCallbackExist ? animeCallbacks.onLoop : null,
            isCallbackExist ? animeCallbacks.onMiddle : null,
            isCallbackExist ? animeCallbacks.onComplete : null
        );
    }

    function bopping(elapsed:Float) {
        if (animeDone) return;

        elapsedTime += elapsed;
        var percent = elapsedTime / animeSettings.duration;

        if (percent > 1) {
            percent = 1;
            animeDone = true;
        }

        var offset = FlxMath.fastSin(percent * Math.PI);
        var targetY = FlxMath.lerp(animeSettings.startPos, animeSettings.startPos - animeSettings.endPos, offset);
        object.y = targetY;

        if (animeDone)
            object.y = animeSettings.startPos;

        var isCallbackExist:Bool = animeCallbacks != null;

        lastFuncHelper(
            percent,
            isCallbackExist ? animeCallbacks.onUpdate : null,
            isCallbackExist ? animeCallbacks.onLoop : null,
            isCallbackExist ? animeCallbacks.onMiddle : null,
            isCallbackExist ? animeCallbacks.onComplete : null
        );
    }

    var boppingVar:TrickalityAnime;
    var boppingTimer:FlxTimer;
    function confused(elapsed:Float) {
        if (animeDone) return;

        elapsedTime += elapsed;
        var percent = elapsedTime / animeSettings.duration;

        if (percent > 1) {
            percent = 1;
            animeDone = true;
        }

        var offset:Float = 0;
        var targetX:Float = 0;

        offset = FlxMath.fastSin(percent * 2 * Math.PI);
        targetX = FlxMath.lerp(animeSettings.startPos, animeSettings.startPos + animeSettings.endPos, offset);

        if (percent * 3 <= 1) 
            object.flipX = false;
        else if (percent * 3 <= 2)
            object.flipX = true;
        else
            object.flipX = false;

        object.x = targetX;
        
        if (animeDone)
            object.x = animeSettings.startPos;

        if (boppingVar == null) {
            boppingVar = new TrickalityAnime(object);
            boppingVar.doShotBopping(object.y);
        }

        if (boppingVar.animeDone) {
            boppingTimer = new FlxTimer().start(0.05, function(_) {
                if (boppingVar == null)
                    boppingVar = new TrickalityAnime(object);

                boppingVar.doShotBopping(object.y);
            });
        }

        lastFuncHelper(
            percent,
            function() {
                if (this.animeCallbacks != null && animeCallbacks.onUpdate != null)
                    animeCallbacks.onUpdate();

                boppingVar.update(elapsed);
            },
            this.animeCallbacks != null ? animeCallbacks.onLoop : null,
            this.animeCallbacks != null ? animeCallbacks.onMiddle : null,
            function() {
                if (this.animeCallbacks != null && animeCallbacks.onComplete != null)
                    animeCallbacks.onComplete();

                boppingVar.destroy();
                boppingVar = null;

                if (boppingTimer != null)
                    boppingTimer.cancel();
            }
        );
    }

    function lastFuncHelper(percent:Float, ?onUpdate:Void->Void, ?onLoop:Void->Void, ?onMiddle:Void->Void, ?onComplete:Void->Void) {
        if (onUpdate != null)
            onUpdate();

        if ((animeSettings.loop != null && (animeSettings.loop > 0 || animeSettings.loop == -1)) && animeDone)
            new FlxTimer().start(0.01, function(_) {
                animeMiddle = false;
                animeDone = false;
                elapsedTime = 0;
                animeSettings.loop -= animeSettings.loop > 0 ? 1 : 0;
                if (onLoop != null)
                    onLoop();
            });
        else if (percent > 0.5 && !animeMiddle) {
            if (onMiddle != null)
                onMiddle();

            animeMiddle = true;
        }
        else if (animeDone) {
            if (onComplete != null)
                onComplete();

            if (curAnime != 'idle')
                new FlxTimer().start(0.01, function(_) {
                    doIdle({startPos: 1, endPos: 1.07, duration: .67, loop: -1});
                });
        }
    }

    public function cancel() {
        doIdle({startPos: 1, endPos: 1.07, duration: .67, loop: -1});

        if (boppingVar != null) {
            boppingVar.destroy();
            boppingVar = null;
        }
    }

    public function destroy() {
        object = null;
        curAnime = null;
        elapsedTime = 0;
        animeSettings = null;
        animeCallbacks = null;
        animeMiddle = false;
        animeDone = false;

        if (boppingVar != null) {
            boppingVar.destroy();
            boppingVar = null;
        }

        exists = false;
    }
}