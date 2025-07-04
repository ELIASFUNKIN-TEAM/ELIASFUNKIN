function onEvent(name, value1, value2)
	if name == "Subtitles" then
		fade = 103
		setTextString('subtitle', value1)
		setTextColor('subtitle', value2)
        runTimer('subtitlefade', 1, 0)
    end
end

function onCreate()
	fade = 0
	makeLuaText('subtitle', '', 800, 250, 450)
	addLuaText('subtitle')
	setTextSize('subtitle', 35)
	setObjectCamera('subtitle', 'other');
end

function onUpdate()
	fade = fade + 1
	if fade > 200 then
		setTextString('subtitle', '')
    end
end