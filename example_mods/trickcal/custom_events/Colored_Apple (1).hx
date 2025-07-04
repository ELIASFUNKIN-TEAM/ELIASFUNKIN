import psychlua.LuaUtils;

import flixel.tweens.FlxTween;

function onStartCountdown()
{
	game.gf.colorTransform.redOffset = 0;
	game.gf.colorTransform.blueOffset = 0;
	game.gf.colorTransform.greenOffset = 0;
	game.gf.colorTransform.redMultiplier = 0;
	game.gf.colorTransform.greenMultiplier = 0;
	game.gf.colorTransform.blueMultiplier = 0;

	game.dad.colorTransform.redOffset = 0;
	game.dad.colorTransform.greenOffset = 0;
	game.dad.colorTransform.blueOffset = 0;
	game.dad.colorTransform.redMultiplier = 0;
	game.dad.colorTransform.greenMultiplier = 0;
	game.dad.colorTransform.blueMultiplier = 0;

	game.boyfriend.colorTransform.redOffset = 0;
	game.boyfriend.colorTransform.greenOffset = 0;
	game.boyfriend.colorTransform.blueOffset = 0;
	game.boyfriend.colorTransform.redMultiplier = 0;
	game.boyfriend.colorTransform.greenMultiplier = 0;
	game.boyfriend.colorTransform.blueMultiplier = 0;
}

function ColorApple(target, R, G, B, time)
{
	//FlxTween.tween(game.boyfriend, {x : 100}, 1, {ease: FlxEase.linear});
	if (target == 'dad')
	{
		FlxTween.tween(game.dad.colorTransform, { redOffset: R, greenOffset: G, blueOffset: B, redMultiplier: 0, greenMultiplier: 0, blueMultiplier: 0 }, time);
	}
	else if (target == 'gf')
	{
		FlxTween.tween(game.gf.colorTransform, { redOffset: R, greenOffset: G, blueOffset: B, redMultiplier: 0, greenMultiplier: 0, blueMultiplier: 0 }, time);
	}
	if (target == 'boyfriend')
	{
		FlxTween.tween(game.boyfriend.colorTransform, { redOffset: R, greenOffset: G, blueOffset: B, redMultiplier: 0, greenMultiplier: 0, blueMultiplier: 0 }, time);
	}
}

function ColorClear(time)
{
	FlxTween.tween(game.dad.colorTransform, { redOffset: 0, greenOffset: 0, blueOffset: 0, redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1 }, time);
	FlxTween.tween(game.gf.colorTransform, { redOffset: 0, greenOffset: 0, blueOffset: 0, redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1 }, time);
	FlxTween.tween(game.boyfriend.colorTransform, { redOffset: 0, greenOffset: 0, blueOffset: 0, redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1 }, time);
}