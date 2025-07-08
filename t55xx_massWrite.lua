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
		return false
	else
		return true
	end
end

local function read_blocks(file)
	local blocks = {}
	local line;

	for i = 0, 11 do
		line = file:read("*l")
		blocks[i] = line:match(':%s*"([^"]+)"')
	end
	return blocks
end

local function open_file(args)
	local fp = 0
	for o, arg in getopt.getopt(args, 'f:') do
        if o == 'f' then fp = arg end
    end
    if fp == 0 then 
    	print("No file given") 
    	return 0
    end
	local file = io.open(fp, "r")
	if not file then
		print("File not found")
		return 0
	end
	return file
end

local function read_file(args)
	--Opens file by args
	local file = open_file(args)
	if (file == 0) then
		return false
	end

	--Skips unneccessary lines
	for i = 1, 7 do
		file:read("*l")
	end

	--Checks if file is correct
	if (file:read(7) ~= "    \"0\"") then
		print("Invalid .json file")
		return false
	end

	--Proceed to read blocks
	local blocks = read_blocks(file)
	file:close()
	return blocks
end

local function  main(args)
	local blocks = read_file(args)
	if not blocks() then
		print('Invalid file.\nUsage: run script t55xx_massWrite -f filename.json')
		return
	end

	core.clearCommandBuffer()

	if not detect() then
		print('Couldnt detect t55xx card.')
		return
	end

	print('Wiping card')
	core.console('lf t55xx wipe')

	if not detect() then
		return
	end

	local command
	for i = 0, 11
	do
		command = string.format('lf t55xx write -b %d -d %s', (i), blocks[i])
		core.console(command)
	end
	print('Checking if data was written correctly...')
	core.console('lf t55xx detect')
	core.console('lf t55xx dump --ns')
end
main(args)
