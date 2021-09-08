# Control4 module for AMX PRECIS DSP

Precis DSP models support the following items from BCS command set:
## General Commands and Conditions
 - [ ] Executing and disconnecting switches (see page 9 and page 10)
    For example, the command string CL0I102O39T can be interpreted as follows: 
    [C] Change on [L0] Level 0, [I102] Input 102 to [O39]Output 39, [T] Take to execute the command.
 - [ ] Verifying signal status (see page 11)
## Special Commands and Conditions
 - [ ] If the Level “L” designation is omitted, the command is executed on the audio level. When entering BCS commands, either 
omit the Level designation or use Level 0 or Level 2 (Level 0 indicates all levels and the Precis DSP models only have one 
level)
 - [ ] Does not support global or local preset commands
 - [ ] Supports using a colon “:” to designate a range of destination numbers in multiple number entries 
## Audio Commands 
 - [ ] Supports full DSP functionality (see page 22) 
 - [ ] Digital output volume control – absolute, relative, and increment/decrement methods (see page 15)
 - [ ] Verifying volume status (see page 16)
 - [ ] Muting and un-muting outputs (see page 16)
 - [ ] Digital input gain control – absolute, relative, and increment/decrement methods (see page 17)
 - [ ] Verifying digital input gain status (see page 18)
## Diagnostic Commands
 - [ ] Precis DSP models display system information in their splash screens for diagnostic purposes. The information indicates the current status and well-being for some of the system components. For information on system diagnostics that includes the commands and applies to all systems that support diagnostic commands, see page 40.
## Component Settings
 - [ ] The Precis DSP supports six component identity number settings (i0 through i5) in the following table.
## Auxiliary Commands
 - [ ] The information in the below table is displayed when you enter ~scr! or ~scri0v0!

| Component | Identity Number | 
| --------- | --------------- |
| All Components| i0
|Enclosure | i1
|Storage Blocks | i2
|Communication Interfaces | i3
|Hardware / Boards | i4
|VM Configuration | i5

## Auxiliary Commands Supported by Precis DSP
 - [ ] To cause a warm reboot ~app!
 - [ ] To view a long splash screen with advanced system information ~scr!