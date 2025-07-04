package objects;

import openfl.Lib;
import openfl.display.Stage;
import lime.ui.Window;

class ShakingWindows {
    public var shakeIntensity:Int = 8;
    public var shakeDuration:Float = 0.5;
    var shakeTime:Float = 0;
    var originalWindowX:Int = 0;
    var originalWindowY:Int = 0;
    var originalWindowWidth:Int = 0;
    var originalWindowHeight:Int = 0;
    public var shaking:Bool = false;

    public function new(intensity:Int = 2, duration:Float = 0.005) {
        var window:Window = Lib.application.window;
        originalWindowX = window.x;
        originalWindowY = window.y;
        originalWindowWidth = window.width;
        originalWindowHeight = window.height;
        shakeTime = shakeDuration = duration;
    }
    
    public inline function startWindowShake() {
        shaking = true;
        var window:Window = Lib.application.window;
        originalWindowX = window.x;
        originalWindowY = window.y;
        originalWindowWidth = window.width;
        originalWindowHeight = window.height;
        shakeTime = shakeDuration;
    }
    
    public function updateShake(elapsed:Float) {
        if (!shaking) return;
    
        var window:Window = Lib.application.window;
        shakeTime -= elapsed;
        if ((originalWindowWidth != window.width) || (originalWindowHeight != window.height)) {
            originalWindowX = window.x;
            originalWindowY = window.y;
            originalWindowWidth = window.width;
            originalWindowHeight = window.height;
        }
        if (shakeTime > 0) {
            window.x = originalWindowX + FlxG.random.int(-shakeIntensity, shakeIntensity);
            window.y = originalWindowY + FlxG.random.int(-shakeIntensity, shakeIntensity);
        }
        else {
            window.x = originalWindowX;
            window.y = originalWindowY;
            shaking = false;
        }
    }
}