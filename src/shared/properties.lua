--[[=============================================================================
    Composer properties handler

    Copyright 2021 AP Engineering LLC
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
===============================================================================]]

function utils_Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

gSelectedEqOutput = -1
gEqLevels = {}
eqNames =
	{
		"32 Hz","64 Hz","125 Hz","250 Hz","500 Hz","1 kHz","2 kHz","4 kHz","8 kHz","16 kHz"
	}
eqProperties = utils_Set(eqNames)
gSelectedGainInput = -1
gGainLevels = {}

function UpdateProperty(propertyName, propertyValue)
	LogTrace ("UpdateProperty(" .. propertyName .. ") to: " .. propertyValue)
	if (Properties[propertyName] ~= nil) then
		C4:UpdateProperty(propertyName, propertyValue)
	end
end

function OnPropertyChanged(sProperty)
	LogTrace ("OnPropertyChanged(" .. sProperty .. ") changed to: " .. Properties[sProperty])
	local propertyValue = Properties[sProperty]
	local trimmedProperty = string.gsub(sProperty, " ", "")
	if (ON_PROPERTY_CHANGED[sProperty] ~= nil and type(ON_PROPERTY_CHANGED[sProperty]) == "function") then
		ON_PROPERTY_CHANGED[sProperty](propertyValue)
		return
	elseif (ON_PROPERTY_CHANGED[trimmedProperty] ~= nil and type(ON_PROPERTY_CHANGED[trimmedProperty]) == "function") then
		ON_PROPERTY_CHANGED[trimmedProperty](propertyValue)
		return
	elseif (eqProperties[sProperty] or eqProperties[trimmedProperty]) then
		SetEqGain()
		return
	end
end

function ON_PROPERTY_CHANGED.OutputEQ(propertyValue)
	local output = tonumber(tOutputCommandMap[propertyValue] % 1000) - 1
	LogTrace("EQ for ".. propertyValue .. "[" .. output .. "]" .. " was selected")
	gSelectedEqOutput = output
	GET_EQ_LEVEL(output)
	UpdateEqGainProperties()
end

function UpdateEqGainProperties()
	if(gSelectedEqOutput == -1) then return end
	if(gEqLevels[gSelectedEqOutput] ~= nil) then
		for key, value in ipairs(gEqLevels[gSelectedEqOutput]) do
			if(key ~= nil) then
				UpdateProperty(eqNames[key], value)
			end
		end
	end
end
function SetEqGain()
	if(gSelectedEqOutput == -1) then return end
	local vals = {}
	for key, value in ipairs(eqNames) do vals[key]=tonumber(Properties[value]) end
	SET_EQ_LEVEL(gSelectedEqOutput, vals)
end

function ON_PROPERTY_CHANGED.InputGain(propertyValue)
	local input = tonumber(tInputCommandMap[propertyValue] % 1000) - 1
	LogTrace("Gain for ".. propertyValue .. "[" .. input .. "]" .. " was selected")
	gSelectedGainInput = input
	GET_GAIN_LEVEL(input)
	UpdateInputGainProperties()
end
function UpdateInputGainProperties()
	LogTrace("UpdateInputGainProperties for ".. "[" .. gSelectedGainInput .. "]")
	if(gSelectedGainInput == -1) then return end
	if(gGainLevels[gSelectedGainInput] ~= nil) then
		UpdateProperty("Gain", gGainLevels[gSelectedGainInput])
	else 
		gGainLevels[gSelectedGainInput] = 0
		UpdateProperty("Gain", 0)
	end
end

function ON_PROPERTY_CHANGED.Gain(propertyValue)
	LogTrace("Gain for ".. "[" .. gSelectedGainInput .. "]" .. " was changed to ".. propertyValue)
	if(gSelectedGainInput == -1) then return end
	SET_GAIN_LEVEL(gSelectedGainInput, tonumber(propertyValue))
end
