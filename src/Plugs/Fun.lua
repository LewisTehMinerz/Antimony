local Fun = {}

local MarketplaceService = game:GetService("MarketplaceService")

function Fun:register(antimony)
	local sound = Instance.new("Sound", game.Workspace)
	
	sound.Played:connect(function(soundId)
		local info = MarketplaceService:GetProductInfo(soundId:sub(14))
			
		antimony:globalSendChatMessage("You are now listening to: " .. info.Name, Color3.fromRGB(168, 192, 252))
	end)
	
	local playSoundPerm = antimony:registerPermission("fun", "play")
	local sparklesPerm = antimony:registerPermission("fun", "sparkles")
	local forcefieldPerm = antimony:registerPermission("fun", "forcefield")
	
	antimony:registerCommand("play", function(ply, args)
		if #args < 1 then
			antimony:sendChatMessage(ply, "Provide a sound ID to play! (" .. antimony.config.prefix .. "play <sound asset ID>)")
			return
		end
		
		if sound.Playing then
			sound:Stop()
		end
		
		sound.SoundId = "rbxassetid://" .. args[1]
		
		if not sound.IsLoaded then
			sound.Loaded:wait()
		end
		
		sound:Play()
	end, {
		help = "Plays a sound.",
		permission = playSoundPerm
	})
	
	antimony:registerCommand("stop", function(ply, args)
		sound:Stop()
	end, {
		help = "Stops playing sound.",
		permission = playSoundPerm
	})
	
	local function getTorso(ply)
		local r6Torso = ply.Character:FindFirstChild("Torso")
		local r15Torso = ply.Character:FindFirstChild("UpperTorso")
		
		if r6Torso then return r6Torso end
		if r15Torso then return r15Torso end
		
		return nil
	end
	
	antimony:registerCommand("sparkles", function(ply, args)
		if antimony:hasPermission(ply, sparklesPerm) then
			if #args > 0 then
				local plys = antimony:searchPlayers(ply, args[1])
				
				for i, _ply in ipairs(plys) do
					if not getTorso(_ply):FindFirstChild("Sparkles") then
						local sparkles = Instance.new("Sparkles", getTorso(_ply))
						sparkles.Enabled = true
					end
				end
			else
				if getTorso(ply):FindFirstChild("Sparkles") then return end
				
				local sparkles = Instance.new("Sparkles", getTorso(ply))
				sparkles.Enabled = true
			end
		else
			if getTorso(ply):FindFirstChild("Sparkles") then return end
			
			local sparkles = Instance.new("Sparkles", getTorso(ply))
			sparkles.Enabled = true
		end
	end, {
		help = "Gives you or another player sparkles.",
		permission = function(ply)
			return antimony:hasPermission(ply, sparklesPerm) or antimony:hasPremium(ply)
		end
	})
	
	antimony:registerCommand("unsparkles", function(ply, args)
		if antimony:hasPermission(ply, sparklesPerm) then
			if #args > 0 then
				local plys = antimony:searchPlayers(ply, args[1])
				
				for i, _ply in ipairs(plys) do
					local sparkles = getTorso(_ply):FindFirstChild("Sparkles")
					if sparkles then sparkles:Destroy() end
				end
			else
				local sparkles = getTorso(ply):FindFirstChild("Sparkles")
				if sparkles then sparkles:Destroy() end
			end
		else
			local sparkles = getTorso(ply):FindFirstChild("Sparkles")
			if sparkles then sparkles:Destroy() end
		end
	end, {
		help = "Removes your or another player's sparkles.",
		permission = function(ply)
			return antimony:hasPermission(ply, sparklesPerm) or antimony:hasPremium(ply)
		end
	})

	antimony:registerCommand("forcefield", function(ply, args)
		if antimony:hasPermission(ply, forcefieldPerm) then
			if #args > 0 then
				local plys = antimony:searchPlayers(ply, args[1])
				
				for i, _ply in ipairs(plys) do
					if not getTorso(_ply):FindFirstChild("ForceField") then
						local forcefield = Instance.new("ForceField", ply.Character)
					end
				end
			else
				if getTorso(ply):FindFirstChild("ForceField") then return end
				
				local forcefield = Instance.new("ForceField", ply.Character)
			end
		else
			if getTorso(ply):FindFirstChild("ForceField") then return end
			
			local forcefield = Instance.new("ForceField", ply.Character)
		end
	end, {
		help = "Gives you or another player a forcefield.",
		permission = function(ply)
			return antimony:hasPermission(ply, forcefieldPerm)
		end,
		aliases = { "ff" }
	})
	
	antimony:registerCommand("unforcefield", function(ply, args)
		if antimony:hasPermission(ply, forcefieldPerm) then
			if #args > 0 then
				local plys = antimony:searchPlayers(ply, args[1])
				
				for i, _ply in ipairs(plys) do
					local forcefield = ply.Character:FindFirstChild("ForceField")
					if forcefield then forcefield:Destroy() end
				end
			else
				local forcefield = ply.Character:FindFirstChild("ForceField")
				if forcefield then forcefield:Destroy() end
			end
		else
			local forcefield = ply.Character:FindFirstChild("ForceField")
			if forcefield then forcefield:Destroy() end
		end
	end, {
		help = "Removes your or another player's forcefield.",
		permission = function(ply)
			return antimony:hasPermission(ply, forcefieldPerm)
		end,
		aliases = { "unff" }
	})
end

return Fun