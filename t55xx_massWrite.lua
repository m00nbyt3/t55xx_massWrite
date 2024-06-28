local cmds = require('commands')
local getopt = require('getopt')
local bin = require('bin')
local utils = require('utils')
local ansicolors = require('ansicolors')

local format = string.format
local floor = math.floor

copyright = ''
author = "m00nbyt3"
version  = 'v1.0.0'
desc =[[
This script will program a T55x7 TAG with a configuration and seven blocks of data.

lf t55xx wipe
lf t55xx detect
lf t55xx write -b 1 -d 00000000
lf t55xx write -b 2 -d ffffffff
lf t55xx write -b 3 -d 80000000
lf t55xx write -b 4 -d 00000001
]]

local function detect()
	print('Detecting card')
	local res,msg = core.t55xx_detect()
	if not res then
		print('Card not detected!')
		--oops("Can't detect modulation :((")
		--core.console('rem [ERR:DETECT:WIPED] Failed to detect after wipe')
		--maybe try with testing option
		return false
	else
		return true
	end
end

local function  main(args)
	-- body
	--vars
	local blocks = {"00150060", "7fd44041", "05005545", "41000000", "7f843214"}

	core.clearCommandBuffer();

	if not detect() then
		return;
	end

	print('Wiping card')
	core.console('lf t55xx wipe')

	if not detect() then
		return;
	end

	local command
	for i = 1, 5
	do
		command = string.format('lf t55xx write -b %d -d %s', (i-1), blocks[i])
		core.console(command)
		--core.console('lf t55xx write -b 0 -d %x', blocks[i])
	end
	print('Checking if data was written correctly...')
	core.console('lf t55xx detect')
	core.console('lf t55xx dump')
end
main(args)