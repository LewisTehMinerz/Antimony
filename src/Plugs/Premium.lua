-- this plug only provides the premium purchase command and the notification, it does not have any premium commands,
-- those are written in other plugs.
local Premium = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

function Premium:register(antimony)
	game.Workspace.AllowThirdPartySales = true
	
	antimony:registerCommand("premium", function(ply, args)
		if MarketplaceService:UserOwnsGamePassAsync(ply.UserId, antimony.premiumGamepass) then
			antimony:sendChatMessage(ply, "You are already Antimony Premium! Thank you! 💖", Color3.new(0, 1, 0))
		else
			MarketplaceService:PromptGamePassPurchase(ply, antimony.premiumGamepass) 
		end
	end, {
		help = "Purchase Antimony Premium.",
		permission = function() return true end -- disables permission check, however you can put logic in that function (e.g. checking permissions + marketplace service check)
	})
	
	Players.PlayerAdded:connect(function(ply)
		if MarketplaceService:UserOwnsGamePassAsync(ply.UserId, antimony.premiumGamepass) then
			antimony:sendChatMessage(ply, "Thanks for supporting Antimony! 💖 You can use Antimony Premium commands.", Color3.new(0, 1, 0))
		end
	end)
end

return Premium