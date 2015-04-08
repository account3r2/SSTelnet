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

local startTime = os.date("%a %d %b at %X (UTC -08:00)")

local irc = require("libs/libluairc")

local ircMode = {}

local ssptp = require("libs/ssptpi")

local bindTo = "*"
local bindToPort = 2323

local function onClientConnect(client)
	eztcp.send.raw(client, ssptp.encode(100))
	eztcp.send.raw(client, ssptp.encode(101, "Welcome to the serversquared Network!"))
	eztcp.send.raw(client, ssptp.encode(102))

	eztcp.send.raw(client, ssptp.encode(103))
	eztcp.send.raw(client, ssptp.encode(104, "This server was created on " .. startTime))
	eztcp.send.raw(client, ssptp.encode(104, "This server is 100% experimental and not complete."))
	eztcp.send.raw(client, ssptp.encode(105))

	eztcp.send.raw(client, ssptp.encode(009, "Ready For Input."))
end

local function start()
	io.write("Creating server...\n")
	eztcp.create.server(bindTo, bindToPort, set, 1)
	io.write("Waiting for clients...\n")

	while true do
		local client, msg, err, ip, port = eztcp.process(set)
		ip = ip or "[Unknown]"
		port = port or "[Unknown]"
		if err then
			io.write(ip .. ": Error: " .. tostring(err) .. "\n")
		elseif msg == 0 then
			io.write(ip .. ": Connected on port " .. port .. ".\n")
			eztcp.send.raw(client, "NOTICE AUTH :serversquared-LuaTelnetD initialized.")
			eztcp.send.raw(client, "NOTICE * :**** If you are not an IRC Client, send \"join\" now! ****")
		elseif msg == 1 then
			io.write(ip .. ": Disconnected.\n")
		elseif msg == 2 then
			io.write(ip .. ": Disconnected (timed out).\n")
		elseif msg then
			if msg:find(string.char(27)) then
				io.write(ip .. ": Sent escape sequence, ignoring.\n")
				local msg = "Escape sequences are not allowed!"
				eztcp.send.raw(client, msg)
				io.write(ip .. " <- " .. msg .. "\n")
			else
				io.write(ip .. " -> " .. msg .. "\n")
				if ((msg:find("NICK") or msg:find("USER")) and ircMode[client] == nil) then
					ircMode[client] = true
					irc.add.client(client)
					irc.process(client, msg)
				elseif ircMode[client] then
					irc.process(client, msg)
				else
					ircMode[client] = false
				end
			end
		else
			io.write(ip .. ": Unknown error.\n")
		end
	end
end

start()