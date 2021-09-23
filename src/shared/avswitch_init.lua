--[[=============================================================================
    Command processing from proxy to serial transport for AMX PRECIS DSP

    Copyright 2021 AP Engineering LLC
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
===============================================================================]]

PROTOCOL_DECLARATIONS = {}
gOutputMute={}
tInputCommandMap={}
tInputConnMapByID={}
tInputConnMapByName={}
tOutputCommandMap={}
tOutputConnMap={}
tInputIdByNum={}
tOutputIdByNum={}
tInputResponseMap={}
gOutputToInputMap={}
gOutputToInputAudioMap={}
gVideoProviderToRoomMap = {}
gAudioProviderToRoomMap = {}
gLastReportedAVPaths = {}
gAVPathType = {
	    [6] = "AUDIO",
	    [7] = "ROOM",
     }

function ReverseTable(a)
	local b = {}
	for k,v in pairs(a) do b[v] = k end
	return b
end

function ON_DRIVER_EARLY_INIT.avswitch_init()

end

function ON_DRIVER_INIT.avswitch_init()
	for k,v in pairs(PROTOCOL_DECLARATIONS) do
		if (PROTOCOL_DECLARATIONS[k] ~= nil and type(PROTOCOL_DECLARATIONS[k]) == "function") then
			PROTOCOL_DECLARATIONS[k]()
		end
	end	
end

function ON_DRIVER_INIT.avswitch_driver()
    
	
	for i = 1, IO_COUNT, 1 do
			gOutputToInputMap[i]=-1
			gOutputToInputAudioMap[i]=-1
			gOutputMute[i]=false
	end
    local  bProcessesDeviceMessages = false
    local bUsePulseCommandsForVolumeRamping = false
    gAVSwitchProxy = AVSwitchProxy:new(AVSWITCH_PROXY_BINDINGID, bProcessesDeviceMessages, tVolumeRamping, bUsePulseCommandsForVolumeRamping)
   
end

function ON_DRIVER_LATEINIT.avswitch_init()
	PollStatus()
end


function PROTOCOL_DECLARATIONS.CommandsTableInit_Serial()
	LogTrace("PROTOCOL_DECLARATIONS.CommandsTableInit_Serial()")
	CMDS = {}
	CMDS[AVSWITCH_PROXY_BINDINGID] = {}
	
end

function PROTOCOL_DECLARATIONS.InputOutputTableInit()
	LogTrace("PROTOCOL_DECLARATIONS.InputOutputTableInit() with I/O ".. IO_COUNT)
	----------------------------------------- [*COMMAND/RESPONSE HELPER TABLES*] -----------------------------------------
	for i = 1, IO_COUNT, 1 do
		tInputCommandMap[2999 + i] = tostring(i)
		tInputConnMapByID[2999 + i] = {Name = "Input "..tostring(i) ,BindingID = AVSWITCH_PROXY_BINDINGID,}
		tInputConnMapByName["Input "..tostring(i)] = {ID = 2999+i,BindingID = AVSWITCH_PROXY_BINDINGID,}
		tOutputCommandMap[3999 + i] = tostring(i)
		tOutputConnMap[3999 + i] = "Output "..tostring(i)
	end
	tInputIdByNum = ReverseTable(tInputCommandMap)
	tOutputIdByNum = ReverseTable(tOutputCommandMap)
	for i = 1, IO_COUNT, 1 do
		tInputCommandMap["Input "..tostring(i)] = tostring(i)
		tOutputCommandMap["Output "..tostring(i)] = tostring(i)
	end
	tInputResponseMap = ReverseTable(tInputCommandMap)
end	

