-- Core functionality for Antimony
local Core = {}

function Core:register(antimony)
	local testCommandPerm = antimony:registerPermission("core", "test-command", true)
	
	antimony:registerCommand("test-command", function(ply, args)
		for i, player in pairs(antimony:searchPlayers(ply, args[1])) do
			antimony:sendChatMessage(ply, player.Name)
		end
	end, {
		help = "A testing command.",
		permission = testCommandPerm
	})
end

return Core