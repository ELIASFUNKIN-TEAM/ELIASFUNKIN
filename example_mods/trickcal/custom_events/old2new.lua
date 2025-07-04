function onEvent(name, value1, value2)
	if name == 'old2new' then
removeLuaSprite('stageback');
removeLuaSprite('stagefront');
removeLuaSprite('stagelight_left');
removeLuaSprite('stagelight_right');
removeLuaSprite('stagecurtains');
addLuaScript('stages/stagereq')
loadScript('stagereq', true)
	end
end