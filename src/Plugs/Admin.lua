local Admin = {}

local Players = game:GetService("Players")
local DSS = game:GetService("DataStoreService")

local BanStorage = DSS:GetDataStore("AntimonyBans")

local bans = {}

function Admin:register(antimony)
    antimony:Log(antimony.levels.debug, "Loading bans from datastore")

    local bansData

    local success, error = pcall(function()
        bansData = BanStorage:GetAsync("__INDEX__")
    end)

    if error then
        antimony:Log(antimony.levels.error, "Error while loading bans: " .. error)
    end

    if bansData == nil then
        bansData = {}

        local success, error = pcall(function() 
            BanStorage:SetAsync("__INDEX__", bansData)
        end)
    else
        for i, userId in ipairs(bansData) do
            local success, error = pcall(function()
                bans[userId] = BanStorage:GetAsync(userId)
            end)

            if error then
                antimony:Log(antimony.levels.error, "Error while loading " .. userId .. "'s bans: " .. error)
            end
        end
    end

    local banPerm = antimony:registerPermission("admin", "ban")

    antimony:registerCommand("ban", function(ply, args)
        local playerToBan = antimony:searchPlayers(args[0])

        table.remove(args, 1)

        local reason = table.concat(args, " ")

        if #playerToBan > 0 then
            for i, player in ipairs(playerToBan) do
                for i, banInfo in ipairs(bans[player.UserId]) do
                    if banInfo.active then banInfo.active = false end
                end

                table.insert(bans[player.UserId], {
                    active = true,
                    reason = reason,
                    issuer = ply.Name,
                    time = os.time()
                })

                local success, error = pcall(function()
                    BanStorage:SetAsync(player.UserId, bans[player.UserId])

                    local index = BanStorage:GetAsync("__INDEX__")

                    local inIndex = false

                    for i, userId in ipairs(index) do
                        if userId == player.UserId then inIndex = true end
                    end

                    if not inIndex then
                        table.insert(index, player.UserId)
                        BanStorage:SetAsync("__INDEX__", index)
                    end
                end)

                if error then
                    antimony:sendChatMessage(ply, "An error occurred while saving ban data.", Color3.new(1, 0, 0))
                    antimony:Log(antimony.level.error, "An error occurred while saving ban data: " .. error)
                end

                player:Kick("You are banned from the game.\n\nReason: " .. bans[player.UserId].reason .. "\nIssued by: " .. bans[player.UserId].issuer)
            end
            
            antimony:sendChatMessage(ply, "User(s) have been banned.")
        end
    end,
    {
        info = "Ban a user.",
        permission = banPerm
    })

    Players.PlayerAdded:connect(function(ply)
        if bans[userId] then
            for i, banInfo in ipairs(bans[userId]) do
                if banInfo.active then
                    ply:Kick("You are banned from the game.\n\nReason: " .. banInfo.reason .. "\nIssued by: " .. banInfo.issuer)
                    return
                end
            end
        end
    end)
end

return Admin