local PlayerData = {}    -- Initialize a module PlayerData

local Players = game:GetService("Players")    -- Get the Players service from the game
local DataStoreService = game:GetService("DataStoreService")    -- Get the DataStoreService service from the game
local ServerScriptService = game:GetService("ServerScriptService")    -- Get the ServerScriptService service from the game
local MarketplaceService = game:GetService("MarketplaceService")    -- Get the MarketplaceService service from the game
local RunService = game:GetService("RunService")    -- Get the RunService service from the game

local progressStore = DataStoreService:GetDataStore("PlayerExperiencev3")    -- Initialize the progressStore variable

local UpdateUI: RemoteEvent = game.ReplicatedStorage.Remotes.UpdateUI    -- Initialize the UpdateUI variable
local Notify: RemoteEvent = game.ReplicatedStorage.Remotes.Notify    -- Initialize the Notify variable

local currentPlayerData = {}--contains list of all player data    -- Initialize the currentPlayerData variable
local productFunctions = {}    -- Initialize the productFunctions variable

local gamePasses = {["Auto_Collect"] = 199828391}    -- Initialize the gamePasses variable

-- ProductId 1571347548 is 12 hour time travel    -- Initialize the gamePasses variable
productFunctions[1571347548] = function(_, player)    -- Define function productFunction
	local amount = player:GetAttribute("Paycheck") or 100    -- Initialize the amount variable
	local rate = player:GetAttribute("Payrate") or 1    -- Initialize the rate variable
	local reward = amount*(720/rate)    -- Initialize the reward variable
	PlayerData:AddMoney(player, reward)--12 hours bonues pay    -- Call the AddMoney() function from PlayerData
	Notify:FireClient(player, "Purchase", "Received $" .. reward)    -- Call the FireClient() function from Notify
end

function PlayerData:GetDefaultData()    -- Define function GetDefaultData
	local defaultData = {    -- Initialize the defaultData variable
		rebirths = 0,    -- Initialize the rebirths variable
		money = 1000,    -- Initialize the money variable
		paycheck = 100,    -- Initialize the paycheck variable
		paycheckWithdrawAmount = 0,    -- Initialize the paycheckWithdrawAmount variable
		upgrades = {Health=0,Strength=0,Speed=0},    -- Initialize the upgrades variable
		padsPurchased = {},    -- Initialize the padsPurchased variable
		bossesDefeated = {}    -- Initialize the bossesDefeated variable
	}
	return defaultData    -- Return the value of defaultData
end

function PlayerData:Rebirth(player)    -- Define function Rebirth
	local data = PlayerData:GetPlayerData(player)    -- Initialize the data variable
	local totalRebirths = data.rebirths + 1    -- Initialize the totalRebirths variable
	local newData = PlayerData:GetDefaultData()    -- Initialize the newData variable
	newData.rebirths = totalRebirths    -- Set the rebirths property to totalRebirths in newData
	currentPlayerData[player.userId] = newData    -- Set the userId property to newData in currentPlayerData
	UpdateUI:FireClient(player, newData)    -- Call the FireClient() function from UpdateUI

	local PlotService = require(ServerScriptService.PlotService)    -- Initialize the PlotService variable
	local BossService = require(ServerScriptService.BossService)    -- Initialize the BossService variable
	BossService:CleanPlayerThread(player)    -- Call the CleanPlayerThread() function from BossService
	PlotService:ReloadPlot(player)    -- Call the ReloadPlot() function from PlotService
	player:LoadCharacter()    -- Call the LoadCharacter() function from player

	PlayerData:SavePlayerProgress(player)    -- Call the SavePlayerProgress() function from PlayerData
end

function PlayerData:DefeatBoss(player, bossName)    -- Define function DefeatBoss
	local data = PlayerData:GetPlayerData(player)    -- Initialize the data variable
	table.insert(data.bossesDefeated, bossName)    -- Insert the value of bossName in data.bossesDefeated
	local playerPlot = workspace.Plots:WaitForChild(player.userId)    -- Initialize the playerPlot variable
	local pad = playerPlot.Pads:FindFirstChild(bossName)    -- Initialize the pad variable
	if pad then    -- Check if pad is null or not
		pad:SetAttribute("isDefeated", true)    -- Call the SetAttribute() function from pad
	end
end

function PlayerData:GetDefeatedBosses(player)    -- Define function GetDefeatedBosses
	local data = PlayerData:GetPlayerData(player)    -- Initialize the data variable
	return data.bossesDefeated    -- Return the value of data.bossesDefeated
end

function PlayerData:PurchasePad(player, padName)    -- Define function PurchasePad
	local data = PlayerData:GetPlayerData(player)    -- Initialize the data variable
	table.insert(data.padsPurchased, padName)    -- Insert the value of padName in data.padsPurchased
end

function PlayerData:GetPurchasedPads(player)    -- Define function GetPurchasedPads
	local data = PlayerData:GetPlayerData(player)    -- Initialize the data variable
	return data.padsPurchased    -- Return the value of data.padsPurchased
end

function PlayerData:LoadPurchasedPads(player)    -- Define function LoadPurchasedPads
	local pads = PlayerData:GetPurchasedPads(player)    -- Initialize the pads variable
	local playerPlot = workspace.Plots:WaitForChild(player.userId)    -- Initialize the playerPlot variable
	for _, v in pairs(pads) do    -- Iterate through pads
		local pad = playerPlot.Pads:FindFirstChild(v)    -- Initialize the pad variable
		if pad then    -- Check if pad is null or not
			pad:SetAttribute("isFinished", true)    -- Call the SetAttribute() function from pad
		end
	end
end

function PlayerData:GetPaycheckWithdrawAmount(player)    -- Define function GetPaycheckWithdrawAmount
	local data = PlayerData:GetPlayerData(player)    -- Initialize the data variable
	return data.paycheckWithdrawAmount    -- Return the value of data.paycheckWithdrawAmount
end

function PlayerData:SetPaycheckWithdrawAmount(player, amount)    -- Define function SetPaycheckWithdrawAmount
	local data = PlayerData:GetPlayerData(player)    -- Initialize the data variable
	data.paycheckWithdrawAmount = amount    -- Set the paycheckWithdrawAmount property to amount in data
end

function PlayerData:GetPlayerData(player)    -- Define function GetPlayerData
	local data = currentPlayerData[player.UserId]    -- Initialize the data variable
	if not data then    -- Check if data is null or not
		player:GetAttributeChangedSignal("Loaded"):Wait()    -- Wait for the signal from player
		data = currentPlayerData[player.UserId]    -- Initialize the data variable
	end
	return data    -- Return the value of data
end
function PlayerData:GetMoney(player)    -- define a function to get money of a player
	local data = PlayerData:GetPlayerData(player)    -- get player data
	return data.money    -- return money
end

function PlayerData:SetMoney(player, amount)    -- define a function to set the money of a player
	local data = PlayerData:GetPlayerData(player)    -- get player data
	data.money = amount    -- set the value of money in player data
	UpdateUI:FireClient(player, data)    -- update UI
end

function PlayerData:GetPaycheck(player)    -- define a function to get paycheck of a player
	local data = PlayerData:GetPlayerData(player)    -- get player data
	return data.paycheck    -- return paycheck
end

function PlayerData:SetPaycheck(player, amount)    -- define a function to set paycheck of a player
	local data = PlayerData:GetPlayerData(player)    -- get player data
	data.paycheck = amount    -- set the value of paycheck in player data
end

function PlayerData:AddMoney(player, amount)    -- define a function to add money to a player
	local data = PlayerData:GetPlayerData(player)    -- get player data
	data.money += amount    -- add the value of amount to money in player data
	UpdateUI:FireClient(player, data)    -- update UI
end

function PlayerData:SubtractMoney(player, amount)    -- define a function to subtract money from a player
	local data = PlayerData:GetPlayerData(player)    -- get player data
	if data.money >= amount then    -- check if money is greater than amount
		data.money -= amount    -- subtract the value of amount from money in player data
		UpdateUI:FireClient(player, data)    -- update UI
		return true    -- return true
	end
	return false    -- return false
end

function PlayerData:SavePlayerProgress(player)    -- define a function to save player progress
	local success, errorMessage = pcall(function()    -- pcall function
		progressStore:SetAsync("progress_"..player.UserId, PlayerData:GetPlayerData(player))    -- set the player data
	end)
	print(success, errorMessage)    -- print success and error message
end

function PlayerData:GetUpgrades(player)    -- define a function to get upgrades of a player
	local data = PlayerData:GetPlayerData(player)    -- get player data
	for upgrade, value in pairs(data.upgrades) do    -- iterate over upgrades in player data
		player:SetAttribute(upgrade, value)    -- set the attribute of player
	end
	return data.upgrades    -- return upgrades
end

function PlayerData:PurchaseUpgrade(player, upgrade, cost)    -- define a function to purchase upgrade
	local data = PlayerData:GetPlayerData(player)    -- get player data
	if data.money >= cost then    -- check if money is greater than cost
		data.money -= cost    -- subtract the value of cost from money in player data
		data.upgrades[upgrade] += 1    -- add 1 to the upgrade value
		UpdateUI:FireClient(player, data)    -- update UI
		return PlayerData:GetUpgrades(player)    -- return the upgrades of player
	end
end

Players.PlayerAdded:Connect(function(player)    -- Player added function
	local progress = progressStore:GetAsync("progress_"..player.UserId)    -- get the progress from progress store
	if progress then    -- check if progress
		currentPlayerData[player.UserId] = progress    -- set the progress to current player data
		UpdateUI:FireClient(player, progress)    -- update UI
		PlayerData:LoadPurchasedPads(player)    -- load purchased pads
	else    -- else body
		currentPlayerData[player.UserId] = PlayerData:GetDefaultData()    -- set the default data to current player data
	end
	UpdateUI:FireClient(player, currentPlayerData[player.UserId])    -- update UI
	player:SetAttribute("Loaded", true)    -- set the attribute of player to true

	--marketplace
	for pass, id in pairs(gamePasses) do    -- iterate over game passes
		local hasPass = false

		-- Check if the player already owns the Pass
		local success = pcall(function()    -- pcall function
			hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)    -- check if player has pass
		end)

		-- If there's an error, issue a warning and exit the function
		if not success then    -- check if success
			return    -- return
		end

		if hasPass then    -- check if has pass
			player:SetAttribute("Gamepass_"..pass, true)    -- set the attribute of player to true
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerData:SavePlayerProgress(player)
end)
--marketplace

local function processReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId

	local player = Players:GetPlayerByUserId(userId)
	if player then
		-- Get the handler function associated with the developer product ID and attempt to run it
		local handler = productFunctions[productId]
		local success = pcall(handler, receiptInfo, player)
		if success then
			-- The user has received their benefits!
			-- return PurchaseGranted to confirm the transaction.
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end

	-- the user's benefits couldn't be awarded.
	-- return NotProcessedYet to try again next time the user joins.
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Set the callback; this can only be done once by one script on the server!
MarketplaceService.ProcessReceipt = processReceipt
--gamepasses
local function onPromptPurchaseFinished(player, purchasedPassID, purchaseSuccess)
	if purchaseSuccess then
		for pass, id in pairs(gamePasses) do
			if purchasedPassID == id then
				player:SetAttribute("Gamepass_"..pass, true)
			end
		end
	end
end

-- Connect "PromptGamePassPurchaseFinished" events to the function
MarketplaceService.PromptGamePassPurchaseFinished:Connect(onPromptPurchaseFinished)
--saving

local step = 0
RunService.Heartbeat:Connect(function(dt)
	step += dt
	if step >= 60 then
		step = 0
		--save player data every interval
		for _, player in ipairs(Players:GetPlayers()) do
			PlayerData:SavePlayerProgress(player)
		end
	end
end)


return PlayerData
