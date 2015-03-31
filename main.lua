#!/usr/bin/env lua5.1

--[[========================================================================\\
  ||  Copyright (C) 2015 Niko Geil.                                         ||
  ||                                                                        ||
  ||  This file is part of serversquared LuaTelnetD.                        ||
  ||                                                                        ||
  ||  serversquared LuaTelnetD is free software: you can redistribute it    ||
  ||  and/or modify it under the terms of the GNU General Public License    ||
  ||  as published by the Free Software Foundation, either version 3 of     ||
  ||  the License, or (at your option) any later version.                   ||
  ||                                                                        ||
  ||  serversquared LuaTelnetD is distributed in the hope that it will be   ||
  ||  but WITHOUT ANY WARRANTY; without even the implied warranty of        ||
  ||  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          ||
  ||  GNU General Public License for more details.                          ||
  ||                                                                        ||
  ||  You should have received a copy of the GNU General Public License     ||
  ||  along with serversquared LuaTelnetD. If not, see                      ||
  ||  <http://www.gnu.org/licenses/>.                                       ||
  \\========================================================================]]

local socket = require("socket")

local bindTo = "*"
local bindToPort = 2323

local set = require("libs/set")

local process = require("libs/telnetProcess")

local function start()
	io.write("Opening server...\n")
	server = assert(socket.bind(bindTo, bindToPort))
	server:settimeout(1)
	set:insertServer(server)
	io.write("Waiting for clients...\n")

	while true do
		local readable, _, error = socket.select(set)
		for _, input in ipairs(readable) do
			local complete, msg = process(input, set)
			local ip, _ = input:getpeername()
			if not complete then
				print("Error: " .. tostring(msg))
			elseif complete and msg then
				io.write(ip, " -> " .. msg .. "\n")
				input:send(msg)
				io.write(ip, " <- " .. msg .. "\n")
			end
		end
	end
end

start()