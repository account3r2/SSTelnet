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

local eztcp = require("libs/eztcp")
local set = eztcp.create.set()

local bindTo = "*"
local bindToPort = 2323

local function start()
	io.write("Creating server...\n")
	eztcp.create.server(bindTo, bindToPort, set, 1)
	io.write("Waiting for clients...\n")

	while true do
		local client, msg, err, ip, port = eztcp.process(set)
		if err then
			io.write((ip or "Unknown") .. ": Error: " .. tostring(err) .. "\n")
		elseif msg == 0 then
			io.write((ip or "Unknown") .. ": Connected" .. (port and (" on port " .. port) or "") .. ".\n")
			eztcp.send.raw(client, "Welcome to the serversquared Network!")
		elseif msg == 1 then
			io.write((ip or "Unknown") .. ": Disconnected.\n")
		elseif msg == 2 then
			io.write((ip or "Unknown") .. ": Disconnected (timed out).\n")
		elseif msg then
			io.write((ip or "Unknown") .. " -> " .. msg .. "\n")
			eztcp.send.raw(client, msg)
			io.write((ip or "Unknown") .. " <- " .. msg .. "\n")
		else
			io.write((ip or "Unknown") .. ": Unknown error.\n")
		end
	end
end

start()