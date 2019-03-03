-- Antimony Client-Side

print("[Antimony Client] Loaded.")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AntimonyEvents = ReplicatedStorage:WaitForChild("AntimonyEvents")
local StarterGui = game:GetService("StarterGui")

print("[Antimony Client] Connected to remote event.")

AntimonyEvents.OnClientEvent:connect(function(data)
	print("[Antimony Client] Received data.")
	if data.type == "message" then
		print("[Antimony Client] Received message data.")
		wait(0.0001) -- makes it so that the message appears after the command, just looks nicer
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = data.text,
			Color = data.color
		})
	end
end)