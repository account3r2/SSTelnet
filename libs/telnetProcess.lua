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

local function process(client, set)
	if client == set[1] then		-- set[1] MUST be the server object.
		local client, err = client:accept()		-- Let the new client connect to the server as an object.
		if client then
			local ip, _ = client:getpeername()
			io.write(ip .. ": Connected.\n")
			set:insert(client)
			return true, client, "connected"
		else
			io.write("Error processing new client: " .. tostring(err) .. "\n")		-- Print an error message if we couldn't process the client.
			return false, "Error processing new client: " .. tostring(err)
		end
	else
		local ip, _ = client:getpeername()
		local line, err, part = client:receive()		-- Get client message.
		if err and err == "closed" then		-- If the client has closed their connection.
			io.write(ip .. ": Disconnecting...\n")
			set:remove(client)
			return true, nil, "disconnected"
		elseif err then
			io.write(ip .. ": Network Error: " .. tostring(err) .. "\n")
			set:remove(client)
			client:close()
			return false, "Network Error: " .. tostring(err)
		else
			io.write(ip .. " -> " .. tostring(line) .. "\n")
			return true, line		-- Return true followed by the client line for further processing.
		end
	end
end

return process