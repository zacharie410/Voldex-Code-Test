local Players = game:GetService("Players")    -- Get the players service from game object
local PlayerData = require(script.Parent.PlayerData)    -- Get the PlayerData module
local RunService = game:GetService("RunService")    -- Get the RunService from game object

local RequestPaycheck: RemoteFunction = game.ReplicatedStorage.Remotes.RequestPaycheck    -- Get the remote function object from game object
local UpdatePaycheckMachines: RemoteEvent = game.ReplicatedStorage.Remotes.UpdatePaycheckMachines    -- Get the remote event object from game object

local PAYCHECK_UPDATE_INTERVAL = 1    -- Update interval for paycheck is 1
local PAYCHECK_INCREMENTAL_VALUE = 100    -- Incremental value of paycheck is 100

local playerRunService = {}    -- Initialize the playerRunService dictionary

local function onPlayerAdded(player)    -- Define the function onPlayerAdded
	local elapsed = 0    -- Initialize elapsed variable with 0
	playerRunService[player.Name] = RunService.Heartbeat:Connect(function(dt)    -- Heartbeat connection
		elapsed += dt    -- Add dt to elapsed
		if elapsed >= PAYCHECK_UPDATE_INTERVAL then    -- Check if elapsed is greater than or equal to update interval
			elapsed = 0    -- Reset the elapsed to 0
			local data = PlayerData:GetPlayerData(player)    -- Get the player data from PlayerData module
			local check = (PAYCHECK_INCREMENTAL_VALUE + (data.rebirths * 10))    -- Calculate the paycheck

			player:SetAttribute("Paycheck", check)    -- Set attribute Paycheck of player
			player:SetAttribute("Payrate", PAYCHECK_UPDATE_INTERVAL)    -- Set attribute Payrate of player

			PlayerData:SetPaycheckWithdrawAmount(player, PlayerData:GetPaycheckWithdrawAmount(player) + check)    -- Calculate the paycheck withdrawal amount
			UpdatePaycheckMachines:FireClient(player, PlayerData:GetPaycheckWithdrawAmount(player))    -- Update the paycheck withdrawal amount
		end
	end)
end

local function onPlayerRemoving(player)    -- Define the function onPlayerRemoving
	if playerRunService[player] then    -- Check if playerRunService contains player or not
		playerRunService[player]:Disconnect()    -- Disconnect the playerRunService
		playerRunService[player] = nil    -- Make playerRunService = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)    -- Connect to Players.PlayerAdded to onPlayerAdded function
Players.PlayerRemoving:Connect(onPlayerRemoving)    -- Connect to Players.PlayerRemoving to onPlayerRemoving function

RequestPaycheck.OnServerInvoke = function(player)	    -- Define the function RequestPaycheck.OnServerInvoke
	
	local amount = PlayerData:GetPaycheckWithdrawAmount(player)    -- Get paycheck withdrawal amount
	if amount > 0 then    -- Check if amount is greater than 0
		PlayerData:AddMoney(player, amount)    -- Add amount to player's money
		PlayerData:SetPaycheckWithdrawAmount(player, 0)    -- Make paycheck withdrawal amount of player = 0

		UpdatePaycheckMachines:FireClient(player, PlayerData:GetPaycheckWithdrawAmount(player))    -- Update paycheck withdrawal amount of player
	end
	return amount
end
