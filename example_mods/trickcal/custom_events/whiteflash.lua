function onCreate()
  makeLuaSprite('whiteflash', '', -600, -400)
  makeGraphic('whiteflash', 6500, 1500, 'FFFFFF')
  setScrollFactor('whiteflash', 0, 0)
  addLuaSprite('whiteflash',true)
  setProperty('whiteflash.alpha', 0)
end
function onEvent(name, value1, value2)
  if name == 'whiteflash' then
    setProperty('whiteflash.alpha', 1)
    doTweenAlpha('whiteflashbye', 'whiteflash', 0, 1, 'linear')
  end
end
function onUpdate()
  haha = false
  if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.T') and not haha == true then
    setProperty('whiteflash.alpha', 1)
    doTweenAlpha('whiteflashbye', 'whiteflash', 0, 1, 'linear')
  end
end
