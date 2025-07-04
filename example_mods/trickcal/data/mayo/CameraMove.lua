
function onCreatePost()
    setPropertyFromClass("flixel.FlxG", "mouse.visible", true)
end

function onDestroy()
    setPropertyFromClass("flixel.FlxG", "mouse.visible", false)
end

function onUpdatePost(elapsed)
    if getMouseX('other') + 1 >= screenWidth or getMouseY('other') + 1 >= screenHeight or 
    getMouseX('other') == 0 or getMouseY('other') == 0 then
        if mustHitSection then
            cameraSetTarget('bf')
        else
            cameraSetTarget('dad')
        end
    else
        local center = {800, 700}
        setCameraFollowPoint((getMouseX('other') - screenWidth / 2) / 4 + center[1], (getMouseY('other') - screenWidth / 2) / 6 + center[2])
    end
end