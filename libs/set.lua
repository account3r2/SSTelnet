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

local set = {}

setmetatable(set, {
	__index = {
		insert = function (set, client)
			table.insert(set, client)
		end,
		insertServer = function (set, server)
			if not set["server"] then
				set["server"] = server
			else
				return false, "Server already exists!"
			end
		end,
		remove = function (set, client)
			for k, v in pairs(set) do
				if v == client then
					table.remove(set, k)
					break
				end
			end
		end,
	}
})

return set