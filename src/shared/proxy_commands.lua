--[[=============================================================================
    Command processing from proxy to serial transport for AMX PRECIS DSP

    Copyright 2021 AP Engineering LLC
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
===============================================================================]]


function SET_INPUT(idBinding, output, input, input_id, class, output_id, bSwitchSeparate, bVideo, bAudio)
	 if (gAVSwitchProxy._PreviouslySelectedInput[output] == input) then return end
	ROUTE(input, output)
end 

function ROUTE(input, output)
	local command;
	gOutputToInputMap[output] = input
	command = "CL2I"..string.format( "%d",input ).."O".. string.format( "%d", output).."T"
	SendToTransport(command)
	proxyFeedbackRoutingState(3000 + input,4000 + output)
end

function MUTE_OFF(output)
	local command
	command = "CL2O"..tostring(output).."VUT"
	SendToTransport(command)
	gOutputMute[output]=false
	GET_VOLUME_LEVEL(output)
end

function MUTE_ON(output)
	local command
	command = "CL2O"..tostring(output).."VMT"
	SendToTransport(command)		
	gOutputMute[output]=true
	GET_VOLUME_LEVEL(output)
end

function MUTE_TOGGLE(output)
	if (gOutputMute[output]) then			
		MUTE_OFF(output)
	else
		MUTE_ON(output)
	end 
end

function SET_GAIN_LEVEL(input, c4VolumeLevel)
	local minDeviceLevel = MIN_GAIN_LEVEL
	local maxDeviceLevel = MAX_GAIN_LEVEL
	local deviceGainLevel = ConvertVolumeToDevice(c4VolumeLevel, minDeviceLevel, maxDeviceLevel)*10
	LogInfo('deviceGainLevel: ' .. deviceGainLevel)
	local command = "CL2I".. tostring(input).."VA"..tostring(deviceGainLevel).."T"
	SendToTransport(command)
end
function GET_GAIN_LEVEL(input)
	local command = "SL2I".. tostring(input).."VT"
	SendToTransport(command)
end

function SetVolumeCommand(output, volume)
    return "CL2O".. tostring(output).."VA"..tostring(volume*10).."T"
end

function SET_VOLUME_LEVEL(output, c4VolumeLevel)
	local minDeviceLevel = MIN_DEVICE_LEVEL
	local maxDeviceLevel = MAX_DEVICE_LEVEL
	local deviceVolumeLevel = ConvertVolumeToDevice(c4VolumeLevel, minDeviceLevel, maxDeviceLevel) 	 
	LogInfo('deviceVolumeLevel: ' .. deviceVolumeLevel)
	local command = SetVolumeCommand(output,deviceVolumeLevel)
	SendToTransport(command)
end
function GET_VOLUME_LEVEL(output)
	local command = "SL2O"..tostring(output).."VT"
	SendToTransport(command)
end

function SET_VOLUME_LEVEL_DEVICE(output, deviceVolumeLevel)
	local command =  SetVolumeCommand(output,deviceVolumeLevel)
	SendToTransport(command)
end

function PULSE_VOL_DOWN(output)
	local command = "CL2O"..tostring(output).."VS-T"
	SendToTransport(command)
	GetDeviceVolumeStatus(output)
end

function PULSE_VOL_UP(output)
	local command = "CL2O"..tostring(output).."VS+T"	
	SendToTransport(command)
	GetDeviceVolumeStatus(output)
end

function GetDeviceVolumeStatus(output)
    LogTrace("GetDeviceVolumeStatus(), output = " .. output)
	local command = "SL2O"..tostring(output).."VT"
	SendToTransport(command)
end

function GET_INPUT(output)
    SendToTransport("GET_INPUT", "SL2O".. string.format( "%d", output).."T")
end

function SET_BASS_LEVEL(output, c4Level)
	local minDeviceLevel = MIN_EQ_LEVEL
	local maxDeviceLevel = MAX_EQ_LEVEL
	local deviceEqLevel = ConvertVolumeToDevice(c4Level, minDeviceLevel, maxDeviceLevel) / 2
	LogTrace('deviceEqLevel: ' .. deviceEqLevel)
	local command = "CL2O"..tostring(output).."F1G"..tostring(deviceEqLevel).."T"
	SendToTransport(command)
end

function GET_BASS_LEVEL(output)
	local command = "SL2O"..tostring(output).."F1T"
	SendToTransport(command)
end

function SET_TREBLE_LEVEL(output, c4Level)
	local minDeviceLevel = MIN_EQ_LEVEL
	local maxDeviceLevel = MAX_EQ_LEVEL
	local deviceEqLevel = ConvertVolumeToDevice(c4Level, minDeviceLevel, maxDeviceLevel) / 2
	LogTrace('deviceEqLevel: ' .. deviceEqLevel)
	local command = "CL2O"..tostring(output).."F3G"..tostring(deviceEqLevel).."T"
	SendToTransport(command)
end

function GET_TREBLE_LEVEL(output)
	local command = "SL2O"..tostring(output).."F3T"
	SendToTransport(command)
end

function SET_BALANCE_LEVEL(output, c4Level)
	local minDeviceLevel = MIN_BALANCE_LEVEL
	local maxDeviceLevel = MAX_BALANCE_LEVEL
	local deviceBalanceLevel = ConvertVolumeToDevice(c4Level, minDeviceLevel, maxDeviceLevel) 
	LogTrace('deviceBalanceLevel: ' .. deviceBalanceLevel)
	local command = "CL2O"..tostring(output).."P"..tostring(deviceBalanceLevel).."T"
	SendToTransport(command)
end

function GET_BALANCE_LEVEL(output)
	local command = "SL2O"..tostring(output).."PT"
	SendToTransport(command)
end

function GET_BALANCE_LEVEL(output)
	local command = "SL2O"..tostring(output).."PT"
	SendToTransport(command)
end

function SET_EQ_LEVEL(output, bands)
	local deviceEqLevel = ""
	for i = 1,10,1 do
		deviceEqLevel = deviceEqLevel .. tostring(bands[i] * 10) .. " "
	end
	LogTrace('deviceEqLevel: ' .. deviceEqLevel)
	local command = "CL2O"..tostring(output).."E1 2 3 4 5 6 7 8 9 10G"..deviceEqLevel.."T"
	SendToTransport(command)
end

function GET_EQ_LEVEL(output)
	local command = "SL2O"..tostring(output).."E1 2 3 4 5 6 7 8 9 10T"
	SendToTransport(command)
end

function REBOOT()
	SendToTransport("~app!")
end