function onCreatePost()
    setCameraScroll(getCameraFollowX(), getCameraFollowY())
end

time = 0
function onUpdate(elapsed)
    time = time + elapsed
    setProperty('light.angle', 4 * math.sin(time))
    setProperty('light.x', getProperty('light.angle') * -1 * 2 - 405)
end