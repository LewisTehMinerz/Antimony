--[[
	Antimony Admin
	
	An administration script by LewisTehMinerz.
--]]

local Antimony = {}

Antimony.config = require(script.Parent.Config)

Antimony.premiumGamepass = 5961614

Antimony.level = {
	info = "✅",
	warn = "⚠️",
	error = "❌",
	debug = "🐛"
}

Antimony.commands = {}
Antimony.permissions = {}
Antimony.groups = {}
Antimony.users = {}

local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")
local Marketplace = game:GetService("MarketplaceService")
local GroupStorage = DSS:GetDataStore("AntimonyGroups")
local UserStorage = DSS:GetDataStore("AntimonyUsers")

-- Logs something, can be used by plugs
function Antimony:log(level, msg)
	local logLine = "[Antimony] [" .. level .. "] " .. msg
	if level == Antimony.level.warn then
		warn(logLine)
	elseif level == Antimony.level.error then
		error(logLine)		
	elseif level == Antimony.level.debug then
		if Antimony.config.devMode then
			print(logLine)
		end	
	else
		print(logLine)
	end
end

-- load groups, shouldn't be used by plugs unless they need to reload groups for whatever
function Antimony:loadGroups()
	local groups
	
	local success, error = pcall(function()
		groups = GroupStorage:GetAsync("__INDEX__")
	end)
	
	if error then
		Antimony:log(Antimony.level.error, "Failed to load group index. " .. error)
	end
	
	if groups == nil then
		Antimony:log(Antimony.level.info, "No groups are present, creating two default groups.")

		local defaultPermissions = {}
		
		for permissionGroup, permissions in pairs(Antimony.permissions) do
			for permissionName, permission in pairs(permissions) do
				if permission then -- value is true/false depending if it's default or not
					table.insert(defaultPermissions, permissionGroup .. ":" .. permissionName)
					Antimony:log(Antimony.level.debug, "Permission " .. permissionGroup .. ":" .. permissionName .. " added to default group.")
				end
			end
		end

		-- default is a special group, all users are in it by, well, default
		Antimony.groups["default"] = defaultPermissions
		
		-- admin is also a special group, it gets all permissions no matter what
		Antimony.groups["admin"] = {}
		
		Antimony:saveGroups()
	else
		for i, group in ipairs(groups) do
			Antimony:log(Antimony.level.debug, "Load group " .. group)
			
			local permissions
			local success, error = pcall(function()
				permissions = GroupStorage:GetAsync(group)
			end)
			
			Antimony.groups[group] = permissions
		end	
	end
end

-- save groups, can be used by plugs if group permissions were edited
function Antimony:saveGroups()
	local groups = {}
	for groupName, permissions in pairs(Antimony.groups) do
		Antimony:log(Antimony.level.debug, "Save group " .. groupName)

		local success, error = pcall(function()
			GroupStorage:SetAsync(groupName, permissions)
			table.insert(groups, groupName)
		end)
		
		if error then
			Antimony:log(Antimony.level.error, "Failed to save groups. " .. error)
		end
	end
	
	Antimony:log(Antimony.level.debug, "Save index")

	local success, error = pcall(function()
		GroupStorage:SetAsync("__INDEX__", groups)
	end)
		
	if error then
		Antimony:log(Antimony.level.error, "Failed to save group index, this is very bad. " .. error)
	end
end

-- load user data, shouldn't be used by plugs unless they need to reload user data
function Antimony:loadUser(userId)
	Antimony:log(Antimony.level.debug, "Load user " .. userId)

	local userGroups
	local success, error = pcall(function()
		userGroups = UserStorage:GetAsync(userId)
	end)
	
	if error then
		Antimony:log(Antimony.level.error, "Failed to load user data for user ID " .. userId .. ". " .. error)
	end
	
	if userGroups == nil then
		if userId == game.CreatorId then
			Antimony:log(Antimony.level.info, "Adding user " .. userId .. " to admin and default user group (creator of game).")
		
			Antimony.users[userId] = { "admin", "default" }
		else
			Antimony:log(Antimony.level.info, "Adding user " .. userId .. " to default user group.")
		
			Antimony.users[userId] = { "default" }
		end
		
		Antimony:saveUser(userId)
	else
		Antimony.users[userId] = userGroups	
	end
end

-- saves user data, can be used by plugs if a user's group was updated
function Antimony:saveUser(userId)
	Antimony:log(Antimony.level.debug, "Save user " .. userId)

	local success, error = pcall(function()
		UserStorage:SetAsync(userId, Antimony.users[userId])
	end)
	
	if error then
		Antimony:log(Antimony.level.error, "Failed to save user data for user ID " .. userId .. ". " .. error)
	end
end

-- check permissions of user, can be used by plugs if extra permissions are required for commands or whatever
function Antimony:hasPermission(ply, permissionRequired)
	for i, group in ipairs(Antimony.users[ply.UserId]) do
		if group == "admin" then return true end -- admin has all permissions
		
		for i, permission in ipairs(Antimony.groups[group]) do
			if permission == permissionRequired then
				return true
			end
		end
	end
	
	return false
end

Antimony:log(Antimony.level.info, "Antimony is starting.")

Antimony:log(Antimony.level.debug, "Moving client script into StarterPlayerScripts")

script["Antimony Client"].Parent = game.StarterPlayer.StarterPlayerScripts

Antimony:log(Antimony.level.debug, "Creating remote event")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local antimonyEvents = Instance.new("RemoteEvent", ReplicatedStorage)
antimonyEvents.Name = "AntimonyEvents"

--[[
	Plug Utility Functions
--]]

-- Registers a permission with Antimony and returns an Antimony permission string, used by plugs.
function Antimony:registerPermission(group, permissionName, isDefault)
	if Antimony.permissions[group] == nil then Antimony.permissions[group] = {} end
	
	if Antimony.permissions[group][permissionName] ~= nil then
		Antimony:log(Antimony.level.error, "A plug has attempted to register permission " .. group .. ":" .. permissionName
			.. " when it already exists. This is not allowed. The permission has not been overwritten.")
		return
	end
	
	Antimony.permissions[group][permissionName] = isDefault
	
	local stringified = group .. ":" .. permissionName
	
	Antimony:log(Antimony.level.debug, "Registered permission " .. stringified)
	return stringified 
end

-- Registers a command with Antimony, used by plugs.
function Antimony:registerCommand(command, executor, info)
	if Antimony.commands[command] ~= nil then
		Antimony:log(Antimony.level.error, "A plug has attempted to register command " .. command .. " when it already exists." ..
			" This is not allowed. The command has not been overwritten.")
		return
	end
	
	Antimony.commands[command] = { execute = executor, info = info }
	
	if info.isAliasTo then
		Antimony:log(Antimony.level.debug, "Registered alias " .. command .. " for command " .. info.isAliasTo)
	else
		Antimony:log(Antimony.level.debug, "Registered command " .. command)
	end
	
	if info.aliases then
		for i, alias in ipairs(info.aliases) do
			Antimony:registerCommand(alias, executor, {
				help = info.help,
				permission = info.permission,
				isAliasTo = command
			})
		end
	end
end

-- Use in as a search parameter, or keyword.
function Antimony:searchPlayers(ply, input)
	if input == "all" or input == "everyone" then
		return Players:GetPlayers()
	end
	
	if input == "me" then
		return ply
	end

	if input == "others" then
		local plys = {}
		
		for i, player in ipairs(Players:GetPlayers()) do
			if player.UserId ~= ply.UserId then 
				table.insert(plys, player) 
			end	
		end
		
		return plys
	end
	
	local plys = {}
	
	for i, player in ipairs(Players:GetPlayers()) do
		if player.UserId == input then return player end -- return player if the input is their user id

		local playerMatch = player.Name:lower():sub(1, #input) == input:lower()
		
		if playerMatch then
			table.insert(plys, player)
		end
	end
	
	return plys
end

function Antimony:sendChatMessage(ply, message, color)
	if color == nil then color = Color3.fromRGB(255, 255, 243) end
	
	antimonyEvents:FireClient(ply, {
		type = "message",
		text = message,
		color = color
	})
end

function Antimony:globalSendChatMessage(message, color)
	for i, ply in ipairs(Players:GetPlayers()) do
		Antimony:sendChatMessage(ply, message, color)
	end
end

function Antimony:hasPremium(ply)
	return Marketplace:UserOwnsGamePassAsync(ply.UserId, Antimony.premiumGamepass)
end

function Antimony:commandExecutor(ply, msg)
	local prefixMatch = string.match(msg, "^" .. Antimony.config.prefix)
		
	if prefixMatch then
		Antimony:log(Antimony.level.debug, ply.UserId .. " sent a command message")
		
		local arguments = {}
		msg = msg.gsub(msg, prefixMatch, "", 1)
		
		for arg in string.gmatch(msg, "[^%s]+") do
			table.insert(arguments, arg)
		end
			
		local commandName = arguments[1]
		table.remove(arguments, 1)
		
		if Antimony.commands[commandName] ~= nil then
			Antimony:log(Antimony.level.debug, ply.UserId .. " is running command " .. commandName)
			local permission = false
					
			if type(Antimony.commands[commandName].info.permission) == "function" then
				if not Antimony.commands[commandName].info.permission(ply) then
					Antimony:sendChatMessage(ply, "You do not have permission to use this command.", Color3.new(1, 0, 0))
				else
					permission = true
				end
			elseif type(Antimony.commands[commandName].info.permission) == "string" then
				if not Antimony:hasPermission(ply, Antimony.commands[commandName].info.permission)  then
					Antimony:sendChatMessage(ply, "You do not have permission to use this command.", Color3.new(1, 0, 0))
				else
					permission = true
				end
			else
				Antimony:log(Antimony.level.error, "Command " .. commandName .. " has invalid permission pre-condition type (must be string or function)")
			end
			
			if permission then Antimony.commands[commandName].execute(ply, arguments) end
		end
	end
end

local plugs = script.Parent.Plugs:GetChildren()

Antimony:log(Antimony.level.info, "Loading plugs...")

-- Go through all plugs, load then, and register them.
for i, plug in ipairs(plugs) do
	if plug.Name:sub(1, 1) ~= "#" then
		Antimony:log(Antimony.level.debug, "Loading plug " .. plug.Name)
	
		local success, err = pcall(function() 
			local plugScript = require(plug)
			plugScript:register(Antimony)
		end)
	
		if err then
			Antimony:log(Antimony.level.warn, "Plug " .. plug.Name .. " failed to load: " .. err)
		else
			Antimony:log(Antimony.level.debug, "Plug " .. plug.Name .. " loaded.")
		end
	end
end

Players.PlayerAdded:connect(function(ply)
	Antimony:loadUser(ply.UserId)
	
	if ply.UserId == game.CreatorId and Antimony.config.devMode then
		Antimony:sendChatMessage(ply, "Antimony is running in development mode.", Color3.new(1, 0, 0))
	end

	ply.Chatted:connect(function(msg, rec)
		if not rec then
			Antimony:commandExecutor(ply, msg)
		end
	end)
end)

Antimony:log(Antimony.level.info, "Loading groups...")
Antimony:loadGroups()

spawn(function()
	while wait(60 * 5) do -- reload groups and users every 5 minutes to make sure they are synchronised (may have been updated)
		Antimony:log(Antimony.level.debug, "Reloading groups")
		Antimony:loadGroups()
	end
end)

Antimony:log(Antimony.level.info, "Antimony loaded ✨")