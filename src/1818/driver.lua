--[[=============================================================================
    Main driver for 18x18 DSP

    Copyright 2021 AP Engineering LLC
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
===============================================================================]]------------
require "shared.common.c4_driver_declarations"
require "shared.common.c4_common"
require "shared.common.c4_init"
require "shared.common.c4_property"
require "shared.common.c4_command"
require "shared.common.c4_notify"
require "shared.common.c4_network_connection"
require "shared.common.c4_serial_connection"
require "shared.common.c4_ir_connection"
require "shared.common.c4_utils"
require "shared.lib.c4_timer"
require "shared.actions"
require "shared.sender"
require "shared.receiver"
require "shared.avswitch_init"
require "shared.properties"
require "shared.proxy_commands"
require "shared.connections"
require "shared.avswitch.avswitch_proxy_class"
require "shared.avswitch.avswitch_proxy_commands"
require "shared.avswitch.avswitch_proxy_notifies"
require "shared.av_path"


AVSWITCH_PROXY_BINDINGID = 5001
MIN_GAIN_LEVEL = -10
MAX_GAIN_LEVEL = 10	
MIN_DEVICE_LEVEL = -70
MAX_DEVICE_LEVEL = 10	
MIN_EQ_LEVEL = -24
MAX_EQ_LEVEL = 24	
MIN_BALANCE_LEVEL = -100
MAX_BALANCE_LEVEL = 100
IO_COUNT = 18

function ON_DRIVER_EARLY_INIT.main()
	
end

function ON_DRIVER_INIT.main()

end

function ON_DRIVER_LATEINIT.main()
    C4:urlSetTimeout (20) 
    DRIVER_NAME = C4:GetDriverConfigInfo("name")
	SetLogName(DRIVER_NAME)
end

C4:AllowExecute(true)

gIsDevelopmentVersionOfDriver = true