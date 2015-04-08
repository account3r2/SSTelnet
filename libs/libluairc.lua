--[[========================================================================\\
  ||  serversquared LibLuaIRC - A library for IRC server creators.          ||
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

local eztcp = require("libs/eztcp")
local commands = {}

local irc = {}
irc.add = {}
irc.remove = {}
irc.send = {}

local version = "SSLibLuaIRC"
local serverHost = "127.0.0.1"
local serverName = "serversquared IRC"
local createDate = os.date("%a %d %b at %X (UTC -08:00)")

local clientMap = {}
local nickMap = {}
local channelMap = {}

local commands = {
	MOTD = function (client)
			irc.send.server(client, 375, ":- serversquared Message of the day -")
			irc.send.server(client, 372, ":- Welcome to serversquared IRC!")
			irc.send.server(client, 372, ":- This server is written in Lua, and in alpha!")
			irc.send.server(client, 372, ":- Try not to break it!")
			irc.send.server(client, 372, ":- Lua 5.1 code can be executed in channel #lua.")
			irc.send.server(client, 376, ":End of /MOTD command.")
		end,
	PING = function (client, message)
			irc.send.raw(client, "PONG " .. serverHost .. " " .. message)
		end,
	USERHOST = function (client, args)
		if not args then return end
		local _, _, nicks = args:find(":(.+)")
		if not nicks then return end
		local text = ""
		for nick in nicks:gfind('(.*) -') do
			local nickClient = nickMap[nick]
			if nickClient then
				local nickInfo = clientMap[nickClient]
				text = text .. nick .. "=+" .. nickClient.User .. "@" .. nickClient.Host .. " "
			end
		end
		irc.send.server(client, 302, ":" .. text)
	end,
	WHO = function (client, args)
		local _, _, channel = args:find("WHO (.*) (.*)$")
		if channel then
			handleClientWho(client, channel)
			return
		end
	end,
}

function irc.add.client(client)
	clientMap[client] = {
		client = client,
		registered = false,
		host = false,
		ip = false,
		port = false,
		nick = false,
		user = false,
		realName = false,
		channels = {},
	}
end

function irc.remove.client(client)
	clientMap[client] = nil
end

function irc.send.send(client, text)
	local bytes, err = client.client:send(text .. "\r\n")
	return bytes, err
end

function irc.send.raw(client, text)
	irc.send.send(client, ":" .. serverHost .. " " .. text)
end

function irc.send.server(client, code, text)
	code = tostring(code)
	if code:len() == 1 then
		code = "00" .. code
	elseif code:len() == 2 then
		code = "0" .. code
	end
	irc.send.send(client, ":" .. serverHost .. " " .. code .. " " .. client.nick .. " " .. text)
end

function irc.send.client(client, target, text, noSelf)
	local user = ":" .. client.nick .. "!" .. client.user .. "@" .. client.host
	if target:sub(1, 1) == "#" then
		local channel = channelMap[target]
		for _, user in pairs(channel.userList) do
			if not (noSelf and user.client == client) then
				irc.send.send(user.client, user .. " " .. text)
			end
		end
	else
		local target = clientMap[target]
		if target then
			irc.send.send(target.client, user .. " " .. text)
		end
	end
end

function irc.process(client, line)
	client = clientMap[client]

	if not line or line == "" then
		return
	end

	local _, _, line = line:find("%s*(.+)%s*")
	if not client.registered then
		local _, _, nick = line:find("NICK (.+)")
		if nick then
			if nickMap[nick] then
				irc.send.raw(client, "433 * " .. nick .. " :Nickname is already in use")
				return
			else
			client.nick = nick
			end
		end

		local _, _, user, mode, virtualHost, realName = line:find("USER (.*) (.*) (.*) :(.+)$")
		if user then
			client.user = user
			client.host = virtualHost
			client.ip, client.port = client.client:getpeername()
			client.realName = realName
		end

		if client.nick and client.user then
			client.registered = true
			irc.send.server(client, 001, "Welcome to " .. serverName .. " " .. client.nick .. "!" .. client.user .. "@" .. client.host)
			irc.send.server(client, 002, "Your host is " .. serverHost .. ", running version " .. version)
			irc.send.server(client, 003, "This server was created " .. createDate)
			irc.send.server(client, 004, serverHost .. " " .. version .. " aAbBcCdDeEfFGhHiIjkKlLmMnNopPQrRsStUvVwWxXyYzZ0123459*@ bcdefFhiIklmnoPqstv")
			nickMap[client.nick] = client

			commands.MOTD(client)
		end

	elseif client.registered then
		local _, _, command, args = line:find("^%s*([^ ]+) *(.*)%s*$")
		local command = command:upper()
		local command = commands[command]
		if type(command) == "function" then
			command(client, args)
		else
			irc.send.server(client, 421, line .. " :Unknown command")
		end
	end
end

return irc