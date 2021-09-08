--[[=============================================================================
    Command processing from proxy to serial transport for AMX PRECIS DSP

    Copyright 2021 AP Engineering LLC
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
===============================================================================]]

changeFormatErrorPattern =  "(.*?)"
changeGeneralErrorPattern =  "(.*X)"
errorPattern =  "(E%d*)"
warningPattern =  "(E%d*)"
readyPattern = "Ready"
setRoutingSucceedPattern =  "CL2I(%d*)O(%d*)T"
getRoutingSucceedPattern =  "SL2O(%d*)T%( (%d*) %)"
setVolumeSucceedPattern =  "CL2O(%d*)VA(-?%d*)T"
getVolumeSucceedPattern =  "SL2O(%d*)VT%( (-?%d*) %)"
getVolumeMutedPattern =  "SL2O(%d*)VT%( M %)"
setGainSucceedPattern =  "CL2I(%d*)VA(-?%d*)T"
getGainSucceedPattern =  "SL2I(%d*)VT%( (-?%d*) %)"
getEqPattern="SL2O(%d*)E1 2 3 4 5 6 7 8 9 10T%(%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s%)"
setEqPattern="CL2O(%d*)E1 2 3 4 5 6 7 8 9 10G(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)%s(-?%d*)T"
setBassPattern = "CL2O(%d*)F1G(-?%d*)T"
getBassPattern = "SL2O(%d*)F1T%( (-?%d*) %)"
setTreblePattern = "CL2O(%d*)F3G(-?%d*)T"
getTreblePattern = "SL2O(%d*)F3T%( (-?%d*) %)"
setPanPattern = "CL2O(%d*)P(-?%d*)T"
getPanPattern = "SL2O(%d*)P%( (-?%d*) )"

function ReceivedFromSerial(idBinding, strData)
    LogTrace("ReceivedFromSerial " .. idBinding .. " " .. strData)
    gReceiveBuffer = gReceiveBuffer .. strData
    ParsePacket()
end

function GetMessage()
	local message, pos
	local pattern = "^(.-)\n()"
	if (gReceiveBuffer:len() > 0) then
		message, pos = string.match(gReceiveBuffer, pattern)
		if (message == nil) then
			return ""
		end
		gReceiveBuffer = gReceiveBuffer:sub(pos)		
	end

	return message
	
end

function ParsePacket()
    local msg = GetMessage()
    while(msg ~= nil and msg ~= "") do
        HandleMessage(msg)
		msg = GetMessage()
	end
end

function HandleMessage(message)
	LogTrace("HandleMessage. Message is ==>%s<==", message)
	if(message:find(changeFormatErrorPattern)) then
		LogWarn("Command format error ".. message)
	elseif(message:find(changeGeneralErrorPattern)) then
		LogWarn("Command general error ".. message)
	elseif(message:find(readyPattern)) then
		PollStatus()
	elseif(message:find(setRoutingSucceedPattern)) then
		LogDebug("Found routing succeed pattern")
		local  i, o = message:match(setRoutingSucceedPattern)
		proxyFeedbackRoutingState(3000 + i, 4000 + o)
	elseif(message:find(getRoutingSucceedPattern)) then
		LogDebug("Found routing feedback pattern")
		local  i, o = message:match(getRoutingSucceedPattern)
		proxyFeedbackRoutingState(3000 + i, 4000 + o)
	elseif(message:find(setVolumeSucceedPattern)) then
		LogDebug("Found volume succeed pattern")
		local  o, v = message:match(setVolumeSucceedPattern)
		proxyFeedbackVolumeState(4000 + o, v)
	elseif(message:find(getVolumeMutedPattern)) then
		LogDebug("Found volume muted feedback pattern")
		local  o = message:match(getVolumeMutedPattern)
		proxyFeedbackVolumeMuted(o, true)
	elseif(message:find(getVolumeSucceedPattern)) then
		LogDebug("Found volume feedback pattern")
		local  o, v = message:match(getVolumeSucceedPattern)
		proxyFeedbackVolumeState(4000 + o, v)
	elseif(message:find(setGainSucceedPattern)) then
		LogDebug("Found gain succeed pattern")
		local  i, v = message:match(setGainSucceedPattern)
		proxyFeedbackGainState(i, v)
	elseif(message:find(getGainSucceedPattern)) then
		LogDebug("Found gain feedback pattern")
		local  i, v = message:match(getGainSucceedPattern)
		proxyFeedbackGainState(i, v)
	elseif(message:find(getEqPattern)) then
		LogDebug("Found EQ feedback pattern")
		local o, e32, e64, e125, e250,e500,e1k,e2k,e4k,e8k,e16k = message:match(getEqPattern)
		gEqLevels[tonumber(o)] = {tonumber(e32)/10, tonumber(e64)/10, tonumber(e125)/10, tonumber(e250)/10, tonumber(e500)/10, tonumber(e500)/10,tonumber(e1k)/10,tonumber(e2k)/10,tonumber(e4k)/10,tonumber(e8k)/10,tonumber(e16k) }
		UpdateEqGainProperties()
	elseif(message:find(setEqPattern)) then
		LogDebug("Found set EQ succeed pattern")
		local o, e32, e64, e125, e250,e500,e1k,e2k,e4k,e8k,e16k = message:match(setEqPattern)
		gEqLevels[tonumber(o)] = {tonumber(e32)/10, tonumber(e64)/10, tonumber(e125)/10, tonumber(e250)/10, tonumber(e500)/10, tonumber(e500)/10,tonumber(e1k)/10,tonumber(e2k)/10,tonumber(e4k)/10,tonumber(e8k)/10,tonumber(e16k) }
		if(gSelectedEqOutput == tonumber(o)) then
			UpdateEqGainProperties()
		end
	elseif(message:find(setBassPattern)) then
		LogDebug("Found set bass succeed pattern")
		local o, v = message:match(setBassPattern)
		proxyBassState(o,v)
	elseif(message:find(getBassPattern)) then
		LogDebug("Found set bass succeed pattern")
		local o, v = message:match(getBassPattern)
		proxyBassState(o,v)
	elseif(message:find(setTreblePattern)) then
		LogDebug("Found set treble succeed pattern")
		local o, v = message:match(setTreblePattern)
		proxyTrebleState(o,v)
	elseif(message:find(getTreblePattern)) then
		LogDebug("Found get treble succeed pattern")
		local o, v = message:match(getTreblePattern)
		proxyTrebleState(o,v)
	elseif(message:find(setPanPattern)) then
		LogDebug("Found set pan succeed pattern")
		local o, v = message:match(setPanPattern)
		proxyPanState(o,v)
	elseif(message:find(setPanPattern)) then
		LogDebug("Found get pan succeed pattern")
		local o, v = message:match(setPanPattern)
		proxyPanState(o,v)
	end
end

function proxyFeedbackRoutingState(input_id,output_id)
	gAVSwitchProxy:dev_InputOutputChanged(input_id, output_id)
end

function proxyFeedbackGainState(input_id, volume)
	local input_number = tonumber(input_id)
	LogDebug("proxyFeedbackGainState input " .. input_number .. " volume ".. volume)
	local scaledVolume = volume / 10
	gGainLevels[input_number] = scaledVolume
	LogDebug("gGainLevels [" .. input_number .. "] = " .. gGainLevels[input_number])
	if(gSelectedGainInput == input_number) then
		LogDebug("gSelectedGainInput equals input_number ")
		UpdateInputGainProperties()
	else
		LogDebug("gSelectedGainInput [".. gSelectedGainInput .."] [".. type(gSelectedGainInput) .."] not equal input_id [".. input_number.."] [".. type(input_number).."]")
	end
end

function proxyBassState(output_id, volume)
	local minDeviceLevel = MIN_EQ_LEVEL
	local maxDeviceLevel = MAX_EQ_LEVEL
	local scaledVolume = volume / 20
	local c4VolumeLevel = ConvertVolumeToC4(scaledVolume, minDeviceLevel, maxDeviceLevel) 	 
	gAVSwitchProxy:dev_BassLevelChanged(output_id, c4VolumeLevel)
end

function proxyTrebleState(output_id, volume)
	local minDeviceLevel = MIN_EQ_LEVEL
	local maxDeviceLevel = MAX_EQ_LEVEL
	local scaledVolume = volume / 20
	local c4VolumeLevel = ConvertVolumeToC4(scaledVolume, minDeviceLevel, maxDeviceLevel) 	 
	gAVSwitchProxy:dev_TrebleLevelChanged(output_id, c4VolumeLevel)
end

function proxyPanState(output_id, volume)
	local minDeviceLevel = MIN_BALANCE_LEVEL
	local maxDeviceLevel = MAX_BALANCE_LEVEL
	local scaledVolume = volume / 10
	local c4VolumeLevel = ConvertVolumeToC4(scaledVolume, minDeviceLevel, maxDeviceLevel) 	 
	gAVSwitchProxy:dev_BalanceLevelChanged(output_id, c4VolumeLevel)
end

function proxyFeedbackVolumeState(output_id, volume)
	local minDeviceLevel = MIN_DEVICE_LEVEL
	local maxDeviceLevel = MAX_DEVICE_LEVEL
	local scaledVolume = volume / 10
	local c4VolumeLevel = ConvertVolumeToC4(scaledVolume, minDeviceLevel, maxDeviceLevel) 	 
	gAVSwitchProxy:dev_VolumeLevelChanged(output_id, c4VolumeLevel, scaledVolume)
	proxyFeedbackVolumeMuted(output_id, false)
end

function proxyFeedbackVolumeMuted(output_id, state)
	gAVSwitchProxy:dev_MuteChanged(output_id, state)
end