function onEvent(name, value1, value2)
if name == 'playVideo' then -- Change the name to your choice
makeVideoSprite('videoStart', value1, 0, 0, 'cam'..value2, false) -- value1 is the name of your video in mods/videos, value2 can be 'Game', 'HUD', or 'Other'
setObjectOrder('videoStart_video', 0) -- Do NOT remove the '_video', as it is necessary using the second script
setProperty('videoStart_video.alpha', 1) -- Once again, do NOT remove the '_video'
end
end