alreadyAppear = true

function onCreate()
	initLuaShader('rgbShader')
	--middscroll : 412, 524, 636, 748
	local StrumX = 437
	local ArrowThing = {'LEFT', 'DOWN', 'UP', 'RIGHT'}
	for i = 0, 3 do
		if downscroll then
			makeAnimatedLuaSprite('3rdStrumLine'..i, 'noteSkins/NOTE_assets'..noteSkinPostfix, StrumX -35, 530)
		elseif not downscroll then
			makeAnimatedLuaSprite('3rdStrumLine'..i, 'noteSkins/NOTE_assets'..noteSkinPostfix, StrumX -35, 10)
		end
		addAnimationByPrefix('3rdStrumLine'..i, 'static', 'arrow'..ArrowThing[i + 1], 24, false)
		addAnimationByPrefix('3rdStrumLine'..i, 'confirm', string.lower(ArrowThing[i + 1])..' confirm', 24, false)
		setSpriteShader('3rdStrumLine'..i, 'rgbShader')
		setShaderFloat('3rdStrumLine'..i, 'mult', 0)
		addLuaSprite('3rdStrumLine'..i, false)
		setProperty('3rdStrumLine'..i..'.alpha', 0)
		startTween('3rdStrumLine'..i..'tween', '3rdStrumLine'..i, { alpha = 1}, 1, {ease = 'circOut', startDelay = 0.5 + (0.2 * i)})
		playAnim('3rdStrumLine'..i, 'confirm', false)
		scaleObject('3rdStrumLine'..i, 0.65, 0.65)
		addToGroup('uiGroup', '3rdStrumLine'..i, 0)
		if not alreadyAppear then
			setProperty('3rdStrumLine'..i..'.x', -200)
		end
		StrumX = StrumX + 100
	end
	
	addOffset('3rdStrumLine0', 'static', 0, 0)
	addOffset('3rdStrumLine0', 'confirm', 23, 23)

	addOffset('3rdStrumLine1', 'static', 0, 0)
	addOffset('3rdStrumLine1', 'confirm', 23, 23)

	addOffset('3rdStrumLine2', 'static', 0, 0)
	addOffset('3rdStrumLine2', 'confirm', 23, 23)

	addOffset('3rdStrumLine3', 'static', 0, 0)
	addOffset('3rdStrumLine3', 'confirm', 23, 23)

	setShaderFloatArray('3rdStrumLine0', 'r', {194 / 255, 75 / 255, 153 / 255})
	setShaderFloatArray('3rdStrumLine0', 'g', {1, 1, 1})
	setShaderFloatArray('3rdStrumLine0', 'b', {60 / 255, 31 / 255, 86 / 255})

	setShaderFloatArray('3rdStrumLine1', 'r', {0, 255 / 255, 255 / 255})
	setShaderFloatArray('3rdStrumLine1', 'g', {1, 1, 1})
	setShaderFloatArray('3rdStrumLine1', 'b', {21 / 255, 66 / 255, 183 / 255})

	setShaderFloatArray('3rdStrumLine2', 'r', {18 / 255, 250 / 255, 5 / 255})
	setShaderFloatArray('3rdStrumLine2', 'g', {1, 1, 1})
	setShaderFloatArray('3rdStrumLine2', 'b', {10 / 255, 67 / 255, 71 / 255})

	setShaderFloatArray('3rdStrumLine3', 'r', {249 / 255, 57 / 255, 63 / 255})
	setShaderFloatArray('3rdStrumLine3', 'g', {1, 1, 1})
	setShaderFloatArray('3rdStrumLine3', 'b', {101 / 255, 16 / 255, 56 / 255})
end

function onCreatePost()
	for i=0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'GF Sing' then
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false)
			setPropertyFromGroup('unspawnNotes', i, 'visible', false)
			setPropertyFromGroup('unspawnNotes', i, 'x', 500)
		end
		setPropertyFromGroup('notes', i, 'visible', false)
	end

	if alreadyAppear then
		setPropertyFromGroup('strumLineNotes', 0, 'x', 0)
		setPropertyFromGroup('strumLineNotes', 1, 'x', 100)
		setPropertyFromGroup('strumLineNotes', 2, 'x', 200)
		setPropertyFromGroup('strumLineNotes', 3, 'x', 300)
		setPropertyFromGroup('strumLineNotes', 4, 'x', screenWidth - 400)
		setPropertyFromGroup('strumLineNotes', 5, 'x', screenWidth - 300)
		setPropertyFromGroup('strumLineNotes', 6, 'x', screenWidth - 200)
		setPropertyFromGroup('strumLineNotes', 7, 'x', screenWidth - 100)
	end

	if downscroll then
		makeLuaText('you', '', 0, getPropertyFromGroup('strumLineNotes', 5, 'x') + getPropertyFromGroup('strumLineNotes', 5, 'width') / 2, getPropertyFromGroup('strumLineNotes', 5, 'y') - 150)
		setTextString('you', 'YOU \n↓')
	elseif not downscroll then
		makeLuaText('you', '', 0, getPropertyFromGroup('strumLineNotes', 5, 'x') + getPropertyFromGroup('strumLineNotes', 5, 'width') / 2, getPropertyFromGroup('strumLineNotes', 5, 'y') + 150)
		setTextString('you', '↑\nYOU')
	end
	setTextAlignment('you', 'center')
	setTextSize('you', 50)
	
	addLuaText('you')
	if downscroll then
		doTweenY('you tween0', 'you', getProperty('you.y') - 50, 0.5, 'circOut')
	elseif not downscroll then
		doTweenY('you tween0', 'you', getProperty('you.y') - 50, 0.5, 'circIn')
	end
	runTimer('you disappear', 3)
	--makeLuaSprite('test', '')
	--makeGraphic('test', 100, 100, 'FFFFFF')
	--addToGroup('uiGroup', 'test', 0)
	--addLuaSprite('test', true)
end

note_id = 0
arrow = {'purple', 'blue', 'green', 'red'}
resetTime = {0, 0, 0, 0}
spawnedNotes = {}
spawnedSustain = {}

function onSpawnNote(index, noteData, noteType, isSustain, strumTime)
	if noteType == 'GF Sing' then
		if not isSustain then
			if downscroll then
				makeLuaSprite('3rdNote-'..note_id, 'noteSkins/NOTE_assets', 0, -2000)
			elseif not downscroll then
				makeLuaSprite('3rdNote-'..note_id, 'noteSkins/NOTE_assets', 0, -2000)
			end
			if noteData == 0 then
				setProperty('3rdNote-'..note_id..'._frame.frame.x', 795)
				setProperty('3rdNote-'..note_id..'._frame.frame.y', 234)
				setProperty('3rdNote-'..note_id..'._frame.frame.width', 154)
				setProperty('3rdNote-'..note_id..'._frame.frame.height', 157)
			elseif noteData == 1 then
				setProperty('3rdNote-'..note_id..'._frame.frame.x', 1854)
				setProperty('3rdNote-'..note_id..'._frame.frame.y', 1)
				setProperty('3rdNote-'..note_id..'._frame.frame.width', 157)
				setProperty('3rdNote-'..note_id..'._frame.frame.height', 154)
			elseif noteData == 2 then
				setProperty('3rdNote-'..note_id..'._frame.frame.x', 1854)
				setProperty('3rdNote-'..note_id..'._frame.frame.y', 156)
				setProperty('3rdNote-'..note_id..'._frame.frame.width', 157)
				setProperty('3rdNote-'..note_id..'._frame.frame.height', 154)
			elseif noteData == 3 then
				setProperty('3rdNote-'..note_id..'._frame.frame.x', 1)
				setProperty('3rdNote-'..note_id..'._frame.frame.y', 237)
				setProperty('3rdNote-'..note_id..'._frame.frame.width', 154)
				setProperty('3rdNote-'..note_id..'._frame.frame.height', 157)
			end
			scaleObject('3rdNote-'..note_id, getProperty('3rdStrumLine'..noteData..'.scale.x'), getProperty('3rdStrumLine'..noteData..'.scale.y'))
			addToGroup('uiGroup', '3rdNote-'..note_id, -1)
			addLuaSprite('3rdNote-'..note_id, true)
			setProperty('3rdNote-'..note_id..'.alpha', 1)
		elseif isSustain then
			if downscroll then
				makeLuaSprite('3rdNote-'..note_id, 'noteSkins/NOTE_assets', 0, -2000)
			elseif not downscroll then
				makeLuaSprite('3rdNote-'..note_id, 'noteSkins/NOTE_assets', 0, -2000)
			end
			addToGroup('uiGroup', '3rdNote-'..note_id, 4)
			setProperty('3rdNote-'..note_id..'.alpha', 0.6)
			if stringEndsWith(getPropertyFromGroup('notes', index, 'animation.curAnim.name'), 'hold') then
				setProperty('3rdNote-'..note_id..'._frame.frame.x', 1102)
				setProperty('3rdNote-'..note_id..'._frame.frame.y', 444)
				setProperty('3rdNote-'..note_id..'._frame.frame.width', 50)
				setProperty('3rdNote-'..note_id..'._frame.frame.height', 44)
				scaleObject('3rdNote-'..note_id, 0.65, getPropertyFromGroup('notes', index, 'scale.y'))
			elseif stringEndsWith(getPropertyFromGroup('notes', index, 'animation.curAnim.name'), 'end') then
				setProperty('3rdNote-'..note_id..'._frame.frame.x', 1051)
				setProperty('3rdNote-'..note_id..'._frame.frame.y', 444)
				setProperty('3rdNote-'..note_id..'._frame.frame.width', 50)
				setProperty('3rdNote-'..note_id..'._frame.frame.height', 64)
				if downscroll then
					scaleObject('3rdNote-'..note_id, 0.65, -1)
					setProperty('3rdNote-'..note_id..'.offset.y', 539)
				elseif not downscroll then
					scaleObject('3rdNote-'..note_id, 0.65, 1)
					setProperty('3rdNote-'..note_id..'.alpha', 0.6)
				end
			end
			addLuaSprite('3rdNote-'..note_id, false)
		end
		if not isSustain then
			callMethod('3rdNote-'..note_id..'.set_camera', {instanceArg('camHUD')})
			setSpriteShader('3rdNote-'..note_id, 'rgbShader')
			setShaderFloat('3rdNote-'..note_id, 'mult', 1)

			if noteData == 0 then
				setShaderFloatArray('3rdNote-'..note_id, 'r', {194 / 255, 75 / 255, 153 / 255})
				setShaderFloatArray('3rdNote-'..note_id, 'g', {1, 1, 1})
				setShaderFloatArray('3rdNote-'..note_id, 'b', {60 / 255, 31 / 255, 86 / 255})
			elseif noteData == 1 then
				setShaderFloatArray('3rdNote-'..note_id, 'r', {0, 255 / 255, 255 / 255})
				setShaderFloatArray('3rdNote-'..note_id, 'g', {1, 1, 1})
				setShaderFloatArray('3rdNote-'..note_id, 'b', {21 / 255, 66 / 255, 183 / 255})
			elseif noteData == 2 then
				setShaderFloatArray('3rdNote-'..note_id, 'r', {18 / 255, 250 / 255, 5 / 255})
				setShaderFloatArray('3rdNote-'..note_id, 'g', {1, 1, 1})
				setShaderFloatArray('3rdNote-'..note_id, 'b', {10 / 255, 67 / 255, 71 / 255})
			elseif noteData == 3 then
				setShaderFloatArray('3rdNote-'..note_id, 'r', {249 / 255, 57 / 255, 63 / 255})
				setShaderFloatArray('3rdNote-'..note_id, 'g', {1, 1, 1})
				setShaderFloatArray('3rdNote-'..note_id, 'b', {101 / 255, 16 / 255, 56 / 255})
			end
		elseif isSustain then
			callMethod('3rdNote-'..note_id..'.set_camera', {instanceArg('camHUD')})
			setSpriteShader('3rdNote-'..note_id, 'rgbShader')
			setShaderFloat('3rdNote-'..note_id, 'mult', 1)

			if noteData == 0 then
				setShaderFloatArray('3rdNote-'..note_id, 'r', {194 / 255, 75 / 255, 153 / 255})
				setShaderFloatArray('3rdNote-'..note_id, 'g', {1, 1, 1})
				setShaderFloatArray('3rdNote-'..note_id, 'b', {60 / 255, 31 / 255, 86 / 255})
			elseif noteData == 1 then
				setShaderFloatArray('3rdNote-'..note_id, 'r', {0, 255 / 255, 255 / 255})
				setShaderFloatArray('3rdNote-'..note_id, 'g', {1, 1, 1})
				setShaderFloatArray('3rdNote-'..note_id, 'b', {21 / 255, 66 / 255, 183 / 255})
			elseif noteData == 2 then
				setShaderFloatArray('3rdNote-'..note_id, 'r', {18 / 255, 250 / 255, 5 / 255})
				setShaderFloatArray('3rdNote-'..note_id, 'g', {1, 1, 1})
				setShaderFloatArray('3rdNote-'..note_id, 'b', {10 / 255, 67 / 255, 71 / 255})
			elseif noteData == 3 then
				setShaderFloatArray('3rdNote-'..note_id, 'r', {249 / 255, 57 / 255, 63 / 255})
				setShaderFloatArray('3rdNote-'..note_id, 'g', {1, 1, 1})
				setShaderFloatArray('3rdNote-'..note_id, 'b', {101 / 255, 16 / 255, 56 / 255})
			end
		end
		
		local tempArr = {}
		local distence = math.abs(getProperty('3rdNote-'..note_id..'.y')) + math.abs(getProperty('3rdStrumLine'..noteData..'.y') + 40)
		tempArr = {note_id, noteData, isSustain, getSongPosition(), strumTime - getSongPosition(), strumTime, getPropertyFromGroup('notes', index, 'offset.y')}
		if isSustain then
			spawnedSustain[#spawnedSustain + 1] = tempArr 
		elseif not isSustain then
			spawnedNotes[#spawnedNotes + 1] = tempArr 
		end

		note_id = note_id + 1
	end
end

function onEvent(event, value1, value2, strumTime)
	if event == '3rdStrumLine Event' then
		if value1 == 'test' then
			if downscroll then
				doTweenY('test0', '3rdStrumLine0', 430, 0.25, 'linear')
				doTweenY('test1', '3rdStrumLine1', 430, 0.25, 'linear')
				doTweenY('test2', '3rdStrumLine2', 430, 0.25, 'linear')
				doTweenY('test3', '3rdStrumLine3', 430, 0.25, 'linear')
			elseif not downscroll then
				doTweenY('test0', '3rdStrumLine0', 110, 0.25, 'linear')
				doTweenY('test1', '3rdStrumLine1', 110, 0.25, 'linear')
				doTweenY('test2', '3rdStrumLine2', 110, 0.25, 'linear')
				doTweenY('test3', '3rdStrumLine3', 110, 0.25, 'linear')
			end
		end
		if value1 == 'middle' then
			if downscroll then
				setProperty('3rdStrumLine0.x', 402)
				setProperty('3rdStrumLine1.x', 502)
				setProperty('3rdStrumLine2.x', 602)
				setProperty('3rdStrumLine3.x', 702)

				setProperty('3rdStrumLine0.y', 730)
				setProperty('3rdStrumLine1.y', 730)
				setProperty('3rdStrumLine2.y', 730)
				setProperty('3rdStrumLine3.y', 730)

				doTweenY('3rdStrumTween0', '3rdStrumLine0', 530, 1, 'sineOut')
				doTweenY('3rdStrumTween1', '3rdStrumLine1', 530, 1, 'sineOut')
				doTweenY('3rdStrumTween2', '3rdStrumLine2', 530, 1, 'sineOut')
				doTweenY('3rdStrumTween3', '3rdStrumLine3', 530, 1, 'sineOut')
			elseif not downscroll then
				setProperty('3rdStrumLine0.x', 402)
				setProperty('3rdStrumLine1.x', 502)
				setProperty('3rdStrumLine2.x', 602)
				setProperty('3rdStrumLine3.x', 702)

				setProperty('3rdStrumLine0.y', -190)
				setProperty('3rdStrumLine1.y', -190)
				setProperty('3rdStrumLine2.y', -190)
				setProperty('3rdStrumLine3.y', -190)

				doTweenY('3rdStrumTween0', '3rdStrumLine0', 10, 1, 'sineOut')
				doTweenY('3rdStrumTween1', '3rdStrumLine1', 10, 1, 'sineOut')
				doTweenY('3rdStrumTween2', '3rdStrumLine2', 10, 1, 'sineOut')
				doTweenY('3rdStrumTween3', '3rdStrumLine3', 10, 1, 'sineOut')
			end

			noteTweenX('strumTween0', 0, 0, 1, 'sineOut')
			noteTweenX('strumTween1', 1, 100, 1, 'sineOut')
			noteTweenX('strumTween2', 2, 200, 1, 'sineOut')
			noteTweenX('strumTween3', 3, 300, 1, 'sineOut')

			noteTweenX('strumTween4', 4, screenWidth - 400, 1, 'sineOut')
			noteTweenX('strumTween5', 5, screenWidth - 300, 1, 'sineOut')
			noteTweenX('strumTween6', 6, screenWidth - 200, 1, 'sineOut')
			noteTweenX('strumTween7', 7, screenWidth - 100, 1, 'sineOut')
		elseif value1 == 'left' then
			setProperty('3rdStrumLine0.x', -400)
			setProperty('3rdStrumLine1.x', -300)
			setProperty('3rdStrumLine2.x', -200)
			setProperty('3rdStrumLine3.x', -100)

			doTweenX('3rdStrumTween0', '3rdStrumLine0', -40, 1, 'sineOut')
			doTweenX('3rdStrumTween1', '3rdStrumLine1', 60, 1, 'sineOut')
			doTweenX('3rdStrumTween2', '3rdStrumLine2', 160, 1, 'sineOut')
			doTweenX('3rdStrumTween3', '3rdStrumLine3', 260, 1, 'sineOut')

		noteTweenX('strumTween0', 0, 440, 1, 'sineOut')
		noteTweenX('strumTween1', 1, 540, 1, 'sineOut')
		noteTweenX('strumTween2', 2, 640, 1, 'sineOut')
		noteTweenX('strumTween3', 3, 740, 1, 'sineOut')

		noteTweenX('strumTween4', 4, screenWidth - 400, 1, 'sineOut')
		noteTweenX('strumTween5', 5, screenWidth - 300, 1, 'sineOut')
		noteTweenX('strumTween6', 6, screenWidth - 200, 1, 'sineOut')
		noteTweenX('strumTween7', 7, screenWidth - 100, 1, 'sineOut')
		end
	end
end

function onUpdate(elapsed)
	for i = 0, 3 do
		if resetTime[i + 1] > 0 then
			resetTime[i + 1] = resetTime[i + 1] - elapsed
		elseif resetTime[i + 1] <= 0  and
		getProperty('3rdStrumLine'..i..'.animation.curAnim.name') == 'confirm' and getProperty('3rdStrumLine'..i..'.animation.curAnim.curFrame') >= 3 then
			playAnim('3rdStrumLine'..i, 'static', false)
			setShaderFloat('3rdStrumLine'..i, 'mult', 0)
			resetTime[i + 1] = 0
		end
	end
	for i = 1, #spawnedNotes do
		if spawnedNotes[i] == nil then
			break
		end

		if downscroll then
			UpdateNotePos(spawnedNotes[i][1], spawnedNotes[i][2], false, spawnedNotes[i][6], scrollSpeed / playbackRate)
			local time = (getSongPosition() - spawnedNotes[1][4]) / spawnedNotes[1][5] -- 0 = note spawned, 1 = note arrived strumline
			if time >= 1 then
				removeLuaSprite('3rdNote-'..spawnedNotes[1][1], true)
				for j = 1, #spawnedNotes do
					spawnedNotes[j] = spawnedNotes[j + 1]
				end
			end
		elseif not downscroll then
			UpdateNotePos(spawnedNotes[i][1], spawnedNotes[i][2], false, spawnedNotes[i][6], scrollSpeed / playbackRate)
			local time = (getSongPosition() - spawnedNotes[1][4]) / spawnedNotes[1][5] -- 0 = note spawned, 1 = note arrived strumline
			if time >= 1 then
				removeLuaSprite('3rdNote-'..spawnedNotes[1][1], true)
				for j = 1, #spawnedNotes do
					spawnedNotes[j] = spawnedNotes[j + 1]
				end
			end
		end
	end

	for i = 1, #spawnedSustain do
		if spawnedSustain[i] == nil then
			break
		end

		if downscroll then
			UpdateNotePos(spawnedSustain[i][1], spawnedSustain[i][2], true, spawnedSustain[i][6], scrollSpeed / playbackRate, spawnedSustain[i][7])
			NoteClip(spawnedSustain[i][1], spawnedSustain[i][2])
			local time = (getSongPosition() - spawnedSustain[1][4]) / spawnedSustain[1][5] -- 0 = note spawned, 1 = note arrived strumline
			if time >= 1.1 then
				removeLuaSprite('3rdNote-'..spawnedSustain[1][1], true)
				for j = 1, #spawnedSustain do
					spawnedSustain[j] = spawnedSustain[j + 1]
				end
			end
		elseif not downscroll then
			UpdateNotePos(spawnedSustain[i][1], spawnedSustain[i][2], true, spawnedSustain[i][6], scrollSpeed / playbackRate)
			NoteClip(spawnedSustain[i][1], spawnedSustain[i][2])
			local time = (getSongPosition() - spawnedSustain[1][4]) / spawnedSustain[1][5] -- 0 = note spawned, 1 = note arrived strumline
			if time >= 1.1 then
				removeLuaSprite('3rdNote-'..spawnedSustain[1][1], true)
				for j = 1, #spawnedSustain do
					spawnedSustain[j] = spawnedSustain[j + 1]
				end
			end
		end
	end
end

function UpdateNotePos(id, noteData, isSustain, strumTime, songSpeed, offset)
	local strumX = getProperty('3rdStrumLine'..noteData..'.x')
	local strumY = getProperty('3rdStrumLine'..noteData..'.y')
	local distance = (0.5 * (getSongPosition() - strumTime) * songSpeed)
	if not downscroll then
		distance = distance * -1
	end

	setProperty('3rdNote-'..id..'.y', distance + strumY + 40)
	if downscroll then
		if isSustain then
			setProperty('3rdNote-'..id..'.x', strumX + 78)
			if getProperty('3rdNote-'..id..'._frame.frame.x') == 1102 then --hold
				setProperty('3rdNote-'..id..'.y', offset * getProperty('3rdNote-'..id..'.scale.y') + getProperty('3rdNote-'..id..'.y'))
				setProperty('3rdNote-'..id..'.y', 18 * getProperty('3rdNote-'..id..'.scale.y') + getProperty('3rdNote-'..id..'.y'))
			elseif getProperty('3rdNote-'..id..'._frame.frame.x') == 1051 then --end

			end
		elseif not isSustain then
			setProperty('3rdNote-'..id..'.x', strumX + 40)
		end
	elseif not downscroll then
		if isSustain then
			setProperty('3rdNote-'..id..'.x', strumX + 78)
			if getProperty('3rdNote-'..id..'._frame.frame.x') == 1102 then --hold
				setProperty('3rdNote-'..id..'.y', getProperty('3rdNote-'..id..'.y') + 50)
			elseif getProperty('3rdNote-'..id..'._frame.frame.x') == 1051 then --end
				setProperty('3rdNote-'..id..'.y', getProperty('3rdNote-'..id..'.y') + 50)
			end
		elseif not isSustain then
			setProperty('3rdNote-'..id..'.x', strumX + 40)
		end
	end
end

function NoteClip(id, noteData)
	local center = getProperty('3rdStrumLine'..noteData..'.y') + 90
	if downscroll then
		if getProperty('3rdNote-'..id..'._frame.frame.x') == 1102 then --hold
			local y = getProperty('3rdNote-'..id..'.y')
			setProperty('3rdNote-'..id..'._frame.frame.height', (center - y) / getProperty('3rdNote-'..id..'.scale.y'))
			if getProperty('3rdNote-'..id..'._frame.frame.height') <= 0 then
				setProperty('3rdNote-'..id..'._frame.frame.height', 1)
				setProperty('3rdNote-'..id..'.alpha', 0)
			end
		elseif getProperty('3rdNote-'..id..'._frame.frame.x') == 1051 then --end
			local y = getProperty('3rdNote-'..id..'.y') + getProperty('3rdNote-'..id..'.offset.y') * getProperty('3rdNote-'..id..'.scale.y') + getProperty('3rdNote-'..id..'.height')
			if y >= center then
				setProperty('3rdNote-'..id..'._frame.frame.y', (y - center) + 444)
				setProperty('3rdNote-'..id..'.y', getProperty('3rdNote-'..id..'.y') - (y  - center))
			end
		end
	elseif not downscroll then
		if getProperty('3rdNote-'..id..'._frame.frame.x') == 1102 then --hold
			local y = getProperty('3rdNote-'..id..'.y')
			if y <= center then
				setProperty('3rdNote-'..id..'._frame.frame.y', (center - y) / getProperty('3rdNote-'..id..'.scale.y') + 444)
				setProperty('3rdNote-'..id..'.y', (center  - y) + getProperty('3rdNote-'..id..'.y'))
			end
		elseif getProperty('3rdNote-'..id..'._frame.frame.x') == 1051 then --end
			local y = getProperty('3rdNote-'..id..'.y')
			if y <= center then
				setProperty('3rdNote-'..id..'._frame.frame.y', (center - y) / getProperty('3rdNote-'..id..'.scale.y') + 444)
				setProperty('3rdNote-'..id..'.y', (center  - y) + getProperty('3rdNote-'..id..'.y'))
			end
		end
	end
end

function opponentNoteHitPre(index, noteData, noteType, isSustain)
	if noteType == 'GF Sing' then
		if isSustain then
			if stringEndsWith(getPropertyFromGroup('notes', index, 'animation.curAnim.name'), 'hold') then
			elseif stringEndsWith(getPropertyFromGroup('notes', index, 'animation.curAnim.name'), 'end') then
				setProperty('3rdStrumLine'..noteData..'.animation.curAnim.frameRate', 24)
			end
		elseif not isSustain then

		end
	end
end

function opponentNoteHit(index, noteData, noteType, isSustain)
	if noteType == 'GF Sing' then
		if not isSustain then
			playAnim('3rdStrumLine'..noteData, 'confirm', true)
		elseif isSustain then
			playAnim('3rdStrumLine'..noteData, 'confirm', true)
			setProperty('3rdStrumLine'..noteData..'.animation.curAnim.frameRate', 12)
		end
		setShaderFloat('3rdStrumLine'..noteData, 'mult', 1)
		resetTime[noteData + 1] = stepCrochet * 1.25 / 1000 / playbackRate
	end
end

function onTweenCompleted(tag)
	if tag == 'you tween0' then
		if downscroll then
			doTweenY('you tween1', 'you', getProperty('you.y') + 50, 0.5, 'circIn')
		elseif not downscroll then
			doTweenY('you tween1', 'you', getProperty('you.y') + 50, 0.5, 'circOut')
		end
	elseif tag == 'you tween1' then
		if downscroll then
			doTweenY('you tween0', 'you', getProperty('you.y') - 50, 0.5, 'circOut')
		elseif not downscroll then
			doTweenY('you tween0', 'you', getProperty('you.y') - 50, 0.5, 'circIn')
		end
	elseif tag== 'you disappear' then
		cancelTween('you tween0')
		cancelTween('you tween1')
		removeLuaText('you', true)
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'you disappear' then
		doTweenAlpha('you disappear', 'you', 0, 2, 'linear')
	end
end