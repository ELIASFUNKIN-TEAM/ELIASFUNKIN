function onEvent(name, value1, value2)

    if name == "Image Fade In" then
        image = tostring(value1)
        time = tonumber(value2)
        makeLuaSprite('newImg'..image, image, 0, 0)
        --setObjectCamera('newImg'..value1, 'game')
        callMethod('newImg'..image..'.set_camera', {instanceArg('camHUD')})
        setProperty('newImg'..image..'.alpha', 0)
        addLuaSprite('newImg'..image)
        doTweenAlpha('appearing'..image, 'newImg'..image, 1, time, 'linear')

    end
end