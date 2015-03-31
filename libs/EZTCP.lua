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

local eztcp = {}

eztcp.set = require("libs/set")
local process = require("libs/telnetProcess")

function eztcp.createServer(set, bindTo, bindToPort, timeout)
	local server = assert(socket.bind(bindTo, bindToPort))
	server:settimeout(timeout)
	set:insert(server)
	return server
end

function eztcp.send(client, message)
	local ip, _ = client:getpeername()
	client:send(message .. "\n")
	io.write(ip, " <- " .. message .. "\n")
end

function eztcp.process(set)
	local readable, _, err = socket.select(set)
	for _, input in ipairs(readable) do
		local complete, msg, status = process(input, set)
		return input, complete, msg, status
	end
end

return eztcp