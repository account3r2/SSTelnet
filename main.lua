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

local eztcp = require("libs/EZTCP")
local set = eztcp.set

local bindTo = "*"
local bindToPort = 2323

local function start()
	io.write("Opening server...\n")
	local server = eztcp.createServer(set, bindTo, bindToPort, 1)
	io.write("Waiting for clients...\n")

	while true do
		local client, complete, msg, status = eztcp.process(set)
		local ip, _ = client:getpeername()
		if not complete then
			io.write("Error: " .. tostring(msg) .. "\n")
		elseif complete and status then
			if status == "connected" then
				eztcp.send(msg, "Welcome to the serversquared Network!")
			end
		elseif complete and msg and not status then
			eztcp.send(client, msg)
		end
	end
end

start()