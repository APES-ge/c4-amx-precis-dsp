--[[=============================================================================
    Command sender for AMX PRECIS DSP

    Copyright 2021 AP Engineering LLC
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
===============================================================================]]
function SendToTransport(command)
    LogTrace("SendToTransport(), command = " .. command)
    C4:SendToSerial(SERIAL_BINDING_ID, command .. "\n")
end

function PollStatus()
    for i = 1, IO_COUNT, 1 do
		GET_INPUT(i)
        GET_GAIN_LEVEL(i)
        GET_VOLUME_LEVEL(i)
        GET_TREBLE_LEVEL(i)
        GET_BASS_LEVEL(i)
        GET_BALANCE_LEVEL(i)
        GET_EQ_LEVEL(i)
	end
end
