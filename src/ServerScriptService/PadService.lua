
local PadService = {}    -- Initialize a PadService variable

local ServerScriptService = game:GetService("ServerScriptService")    -- Get the ServerScriptService
local ReplicatedStorage = game:GetService("ReplicatedStorage")    -- Get the ReplicatedStorage
local MarketplaceService = game:GetService("MarketplaceService")    -- Get the MarketplaceService

local PlayerData = require(ServerScriptService.PlayerData)    -- Get the PlayerData
local Notify: RemoteEvent = game.ReplicatedStorage.Remotes.Notify    -- Get the RemoteEvent Notify
local BossService = require(ServerScriptService.BossService)    -- Get the BossService

function PadService:BuildPad(plotFolder, pad, player, bossService)    -- Defining function BuildPad
	local buildTarget = pad.Target.Value    -- Initialize variable buildTarget with value of Target of pad
	if buildTarget then    -- Check if buildTarget exists or not
		local parts = {}    -- Initialize variable parts as empty array
		for _, p in pairs(buildTarget:GetDescendants()) do    -- Iterate over the descendants of buildTarget
			if p:IsA("BasePart") then    -- Check if p is of type BasePart
				table.insert(parts, {p, p.Transparency})    -- Store the value of p and transparency of p in parts
				p.Transparency = 1    -- Make the part invisible
			end
		end
		buildTarget.Parent = plotFolder    -- Set the Parent of buildTarget to plotFolder

		coroutine.resume(coroutine.create(function()    -- coroutine
			for i = 1, 0, -0.1 do    -- Iterate over parts
				for _, p in pairs(parts) do    -- Iterate over parts
					p[1].Transparency = math.max(p[2], i)    -- Make parts visible with transparency
				end
				task.wait()    -- Wait for a task to complete
			end
		end))

		if buildTarget:GetAttribute("isBoss") then    -- Check if buildTarget is boss
			local isDefeated = false    -- Initialize variable isDefeated as false
			for _, d in ipairs(PlayerData:GetDefeatedBosses(player)) do    -- Iterate over defeated bosses of player
				if d == buildTarget.Name then    -- Check if defeated bosses is equal to name of buildTarget
					isDefeated = true    -- Change the value of isDefeated to true
					pad:SetAttribute("isDefeated", true)    -- Set the attribute of pad to true
					break    -- break the loop
				end
			end
			if not isDefeated then    -- Check if isDefeated is false
				bossService:SummonBoss(buildTarget)    -- Call the SummonBoss function of bossService
				if pad:FindFirstChild("Music") then    -- Check if pad has Music child
					local musicSource = pad.Music.Value    -- Initialize variable musicSource with value of Music of pad
					if musicSource then    -- Check if musicSource exists or not
						musicSource.Ambient:Stop()    -- Stop the Ambient of musicSource
						musicSource.Boss:Play()    -- Play the Boss sound of musicSource
					end
				end
			else
				buildTarget:Destroy()    -- Destroy the buildTarget
			end
		end
	end

	pad.Skin:Destroy()    -- Destroy the Skin of pad
	pad.Pad:Destroy()    -- Destroy the Pad of pad
end

function PadService:PurchasePad(player, pad, sound)    -- Defining function PurchasePad
	local paymentSuccessful = PlayerData:SubtractMoney(player, pad:GetAttribute("Price"))    -- Initialize variable paymentSuccessful with value of SubtractMoney function of PlayerData
	if paymentSuccessful then    -- Check if paymentSuccessful is true
		PlayerData:PurchasePad(player, pad.Name)    -- Call the PurchasePad function of PlayerData
		sound:Play()    -- Play the sound

		pad:SetAttribute("isFinished", true)    -- Set the attribute of pad to true

		if player and pad.Name == "Rebirth" then    -- Check if pad name is Rebirth
			--attempt rebirth
			PlayerData:Rebirth(player)    -- Call the Rebirth function of PlayerData
		end
	end
end

function PadService:InitializePlot(plotFolder, player)    -- Defining function InitializePlot

	local bossService = BossService.new(player)    -- Initialize variable bossService with BossService

	local padsFolder = plotFolder.Pads    -- Initialize variable padsFolder with value of Pads of plotFolder
	local pads = padsFolder:GetChildren()    -- Initialize variable pads with value of children of padsFolder

	local market = plotFolder.Market    -- Initialize variable market with value of Market of plotFolder

	local upgradesFolder = plotFolder.Upgrades    -- Initialize variable upgradesFolder with value of Upgrades of plotFolder
	local upgrades = upgradesFolder:GetChildren()    -- Initialize variable upgrades with value of children of upgradesFolder
	local currentUpgrades = PlayerData:GetUpgrades(player)    -- Initialize variable currentUpgrades with value of GetUpgrades function of PlayerData

	for _, pad in ipairs(upgrades) do    -- Iterate over upgrades
		local touchingArea = pad.Pad    -- Initialize variable touchingArea with value of Pad of pad
		local bb=ReplicatedStorage.Assets.Billboards.Purchase:Clone()    -- Initialize variable bb with the clone of Purchase of Billboards
		bb.Adornee = touchingArea    -- Set the Adornee of bb to touchingArea
		bb.Parent = touchingArea    -- Set the parent of bb to touchingArea
		bb.Frame.TitleLabel.Text = pad.Name ..": ".. currentUpgrades[pad.Name]    -- Set text of TitleLabel of bb
		bb.Frame.BottomFrame.OuterBottomFrame.InnerBottomFrame.BottomLabel.Text = "$"..pad:GetAttribute("Price")    -- Set text of BottomLabel of bb
		local sound = Instance.new("Sound")    -- Initialize variable sound with Instance of new Sound
		sound.Parent = pad.PreviewArea    -- Set the parent of sound to PreviewArea of pad
		sound.SoundId = "rbxassetid://10066947742"    -- Set the SoundId of sound
		local prompt = Instance.new("ProximityPrompt")    -- Initialize variable prompt with Instance of new ProximityPrompt
		prompt.Parent = touchingArea    -- Set the parent of prompt to touchingArea
		prompt.RequiresLineOfSight = false    -- Set RequiresLineOfSight of prompt to false
		prompt.ActionText = "Upgrade"    -- Set ActionText of prompt to Upgrade

		local lastTrigger = time()    -- Initialize variable lastTrigger with value of time
		prompt.Triggered:Connect(function(ply)    -- Connect to Triggered function of prompt
			if (time() - lastTrigger) > 0.2 and ply == player then    -- Check if ply is equal to player
				lastTrigger = time()    -- Set lastTrigger to time
				local success = PlayerData:PurchaseUpgrade(player, pad.Name, pad:GetAttribute("Price"))    -- Initialize variable success with value of PurchaseUpgrade function of PlayerData
				if success then    -- Check if success is true
					currentUpgrades = success    -- Set currentUpgrades to success
					sound:Play()    -- Play sound
					bb.Frame.TitleLabel.Text = pad.Name ..": ".. currentUpgrades[pad.Name]    -- Set text of TitleLabel of bb
				end
			end
		end)
	end

	-- purchase pads
	for _, pad in ipairs(market:GetChildren()) do    -- Iterate over the market
		local touchingArea = pad.Pad    -- Initialize touchingArea variable with value of pad.Pad

		local prompt = Instance.new("ProximityPrompt")    -- Create a new ProximityPrompt
		prompt.Parent = touchingArea    -- Assign proximity prompt to touching area
		prompt.RequiresLineOfSight = false    -- Set Line of sight property to false
		prompt.ActionText = "Upgrade"    -- Set ActionText property

		local lastTrigger = time()    -- Initialize lastTrigger variable with current time
		prompt.Triggered:Connect(function(ply)    -- On trigger event
			if (time() - lastTrigger) > 0.5 and ply == player then    -- Check if time difference is greater than 0.5 and player is equal to ply
				lastTrigger = time()    --
				if pad:GetAttribute("Gamepass") then    -- Check if pad has attribute Gamepass
					MarketplaceService:PromptGamePassPurchase(player, pad:GetAttribute("ID"))    -- Prompt the game pass purchase
				elseif pad:GetAttribute("Product") then    -- Check if pad has attribute Product
					MarketplaceService:PromptProductPurchase(player, pad:GetAttribute("ID"))    -- Prompt the product purchase
				end
			end
		end)
	end

	-- building pads

	local buildingsFolder = plotFolder.Buildings    -- Initialize buildingsFolder with value of plotFolder.Buildings
	buildingsFolder.Parent = ReplicatedStorage.PlotTemp    -- Assign the parent of buildingsFolder to PlotTemp
	buildingsFolder.Name = plotFolder.Name    -- Assign the Name property of buildingsFolder to plotFolder.Name
	for _, pad in ipairs(pads) do    -- Iterate over the pads
		local clearArea = pad:FindFirstChild("AreaToClear")--area to clear    -- Initialize clearArea with value of pad.AreaToClear
		if clearArea then    -- Check if clearArea is not nil
			clearArea.Parent = plotFolder    -- Assign the parent of clearArea to plotFolder
		end

		if pad:GetAttribute("isFinished") then    -- Check if pad has attribute isFinished
			if clearArea then    -- Check if clearArea is not nil
				clearArea:Destroy()    -- Destroy clearArea
			end
			self:BuildPad(plotFolder, pad, player, bossService)    -- Call the BuildPad function
		else    -- else body
			local touchingArea: BasePart = pad.Pad    -- Initialize touchingArea with value of pad.Pad
			local title = pad.Name
	
			local isTutorial = plotFolder.Tutorial:FindFirstChild(pad.Name)    -- Check if isTutorial is not nil
			local tutorialAttachment
			if isTutorial then    -- If isTutorial is not nil
				tutorialAttachment = Instance.new("Attachment")    -- Create a new Attachment
				tutorialAttachment.Parent = touchingArea    -- Assign tutorialAttachment as child of touchingArea
			end
	
			pad:GetAttributeChangedSignal("isFinished"):Connect(function()    -- On pad attribute isFinished changed
				if clearArea then    -- Check if clearArea is not nil
					clearArea:Destroy()    -- Destroy clearArea
				end
				if not isTutorial then    -- If isTutorial is nil
					player.TutorialTarget.Value = nil    -- Assign the value of player.TutorialTarget as nil
				end
				self:BuildPad(plotFolder, pad, player, bossService)    -- Call the BuildPad function
			end)
	
			local dependency = pad.Dependency.Value
	
			if dependency and not dependency:GetAttribute("isFinished") then    -- Check if dependency is not nil and isFinished
				pad.Parent = ReplicatedStorage    -- Assign pad as child of ReplicatedStorage
				dependency:GetAttributeChangedSignal("isFinished"):Connect(function()    -- On dependency attribute isFinished changed
					if isTutorial then    -- Check if isTutorial is not nil
						player.TutorialTarget.Value = tutorialAttachment    -- Set the value of player.TutorialTarget as tutorialAttachment
					end
					pad.Parent = padsFolder    -- Assign pad as child of padsFolder
					Notify:FireClient(player, "Unlocked", "Now available: " .. title .. " for $" .. pad:GetAttribute("Price"))
	
				end)
			elseif isTutorial then    -- Check if isTutorial is not nil
				player.TutorialTarget.Value = tutorialAttachment    -- Set the value of player.TutorialTarget as tutorialAttachment
			end
	
			if pad.Target.Value then    -- Check if pad.Target is not nil
				title = pad.Target.Value:GetAttribute("Title") or ""    -- Assign title as pad.Target.Value:GetAttribute("Title") or ""
			end
	
			local bb=ReplicatedStorage.Assets.Billboards.Purchase:Clone()    -- Clone the billboards.Purchase
			bb.Adornee = touchingArea    -- Set the Adornee property of bb as touchingArea
			bb.Parent = touchingArea    -- Assign bb as child of touchingArea
			bb.Frame.TitleLabel.Text = title    -- Set title as text of bb.Frame.TitleLabel
			bb.Frame.BottomFrame.OuterBottomFrame.InnerBottomFrame.BottomLabel.Text = "$"..pad:GetAttribute("Price")    -- Set the text of bb.Frame.BottomFrame.OuterBottomFrame.InnerBottomFrame.BottomLabel as "$"..pad:GetAttribute("Price")
			local sound = Instance.new("Sound")    -- Create new sound
			sound.Parent = pad.PreviewArea    -- Assign sound as child of pad.PreviewArea
			sound.SoundId = "rbxassetid://10066947742"    -- Set the sound ID property of sound
			local prompt = Instance.new("ProximityPrompt")    -- Create new ProximityPrompt
			prompt.Parent = touchingArea    -- Assign prompt as child of touchingArea
			prompt.RequiresLineOfSight = false    -- Set RequiresLineOfSight property of prompt to false
			prompt.ActionText = "Purchase"    -- Set ActionText property of prompt to "Purchase"
	
			local lastTrigger = time()    -- Initialize lastTrigger variable with current time
			prompt.Triggered:Connect(function(ply)    -- On prompt triggered
				if (time() - lastTrigger) > 3 and ply == player and dependency and dependency:GetAttribute("isFinished") or not dependency then    -- Check if time difference is greater than 3 and ply is equal to player and dependency is not nil and dependency:GetAttribute("isFinished") is true or dependency is nil
					lastTrigger = time()    -- Set the value of lastTrigger as current time
					self:PurchasePad(player, pad, sound, title)    -- Call the PurchasePad function
				end
			end)
		end
	end
end

return PadService    -- Return the module PadService
