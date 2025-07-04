function onEvent(name, value1, value2)

        if name == "Image Fade Out" then
        image2 = tostring(value1)
        time2 = tonumber(value2)
        doTweenAlpha('disappearing'..image2, 'newImg'..image2, 0, time2, 'linear')
    end
end

function onTweenCompleted(tag)
    if tag == "disappearing"..image2 then
        removeLuaSprite('newImg'..image)
    end
end