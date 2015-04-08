--[[========================================================================\\
  ||  SSPTP Interpretor - A library to interpret SSPTP messages.            ||
  ||  Copyright (C) 2015 Niko Geil.                                         ||
  ||                                                                        ||
  ||  This program is free software: you can redistribute it and/or modify  ||
  ||  it under the terms of the GNU General Public License as published by  ||
  ||  the Free Software Foundation, either version 3 of the License, or     ||
  ||  (at your option) any later version.                                   ||
  ||                                                                        ||
  ||  This program is distributed in the hope that it will be useful,       ||
  ||  but WITHOUT ANY WARRANTY; without even the implied warranty of        ||
  ||  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          ||
  ||  GNU General Public License for more details.                          ||
  ||                                                                        ||
  ||  You should have received a copy of the GNU General Public License     ||
  ||  along with this program. If not, see <http://www.gnu.org/licenses/>.  ||
  \\========================================================================]]

local ssptp = {}

local codes = {
	-- General Status Codes.
	[000] = true,		-- Start untitled message stream.
	[001] = true,		-- Untitled message (after 000).
	[002] = true,		-- End untitled message stream.
	[003] = true,		-- Start untitled error message stream.
	[004] = true,		-- Untitled error message (after 003).
	[005] = true,		-- End untitled error message stream.
	[006] = true,		-- Start untitled warning message stream.
	[007] = true,		-- Untitled warning message (after 006).
	[008] = true,		-- End untitled warning message stream.
	[009] = true,		-- Ready for input.

	-- Join Codes.
	[100] = true,		-- Start connect message stream.
	[101] = true,		-- Connect message (after 100).
	[102] = true,		-- End connect message stream.
	[103] = true,		-- Start MOTD stream.
	[104] = true,		-- MOTD message (after 103).
	[105] = true,		-- End MOTD stream.
	[106] = true,		-- Send username (server is requesting for login).
	[107] = true,		-- Send password (server is requesting for login).
	[108] = true,		-- Bad username or password.

	-- Error Codes.
	-- Server Error Codes.
	[200] = true,		-- Internal server error.
	-- Client Error Codes.
	[250] = true,		-- Bad request.
}

function ssptp.decode(message)
	if codes[tonumber(message:sub(1, 3))] then
		return tonumber(message:sub(1, 3)), (message:sub(5) or "")
	else
		return 200, ""
	end
end

function ssptp.encode(code, message)
	if code < 10 then
		code = "00" .. tostring(code)
	elseif code < 100 then
		code = "0" .. tostring(code)
	end

	local message = tostring(code) .. (message and (" " .. message) or "")
	return message
end

return ssptp