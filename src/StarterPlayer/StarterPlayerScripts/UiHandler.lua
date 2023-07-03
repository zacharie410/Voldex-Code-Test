local UiHandler = {}    -- Initalize Module

local StarterGui = game:GetService("StarterGui")    -- Get the StarterGui service
local ReplicatedStorage = game:GetService("ReplicatedStorage")    -- Get the ReplicatedStorage service
local Players = game:GetService("Players")    -- Get the Players service
local LocalPlayer = Players.LocalPlayer    -- Get the LocalPlayer
local TutorialTarget = LocalPlayer:WaitForChild("TutorialTarget")    -- Get the TutorialTarget object

local UpdateUI: RemoteEvent = ReplicatedStorage.Remotes.UpdateUI    -- Get the RemoteEvent
local Notify: RemoteEvent = ReplicatedStorage.Remotes.Notify    -- Get the Notify RemoteEvent

local PlayerGui = LocalPlayer:WaitForChild('PlayerGui')    -- Get the PlayerGui object
local ScreenGui = PlayerGui:WaitForChild("ScreenGui")    -- Get the ScreenGui object
local HUD = ScreenGui:WaitForChild("Frame")    -- Get the Frame object

local moneyLabel = HUD:WaitForChild("Money")    -- Get the Money object
local rebirthLabel = HUD:WaitForChild("Rebirths")    -- Get the Rebirths object

local currentMoney = 0    -- Initialize currentMoney with 0

local currentBeam

local function UpdateBeam()    -- Defining function UpdateBeam
	if currentBeam then    -- Check if currentBeam is not nil
		if currentMoney <= 1000 and TutorialTarget.Value then    -- Check if currentMoney is less than or equal to 1000 and TutorialTarget is not nil
			currentBeam.Attachment1 = UiHandler.modules.PaycheckMachineHandler.tutorialAttachment    -- Update the attachment of currentBeam with tutorialAttachment
		else    -- else body
			currentBeam.Attachment1 = TutorialTarget.Value    -- Update the attachment of currentBeam with TutorialTarget
		end
	end
end

local function HandleCharacter(char)    -- Defining function HandleCharacter
	local beam = char:WaitForChild("TutorialBeam")    -- Get the TutorialBeam object
	beam.Attachment0 = char.PrimaryPart.RootAttachment    -- Update the beam attachment with primaryPart root attachment
	currentBeam = beam    -- Update currentBeam variable
	UpdateBeam()    -- Call the UpdateBeam function
end

local function BonusMoneyEffect(amount)    -- Defining function BonusMoneyEffect
	local tl = Instance.new("TextLabel")    -- Initialize TextLabel object
	tl.Parent = ScreenGui    -- Set the parent of TextLabel object to ScreenGui
	tl.BackgroundTransparency = 1    -- Set the background transparency of TextLabel object to 1
	tl.Text = " + $" .. amount    -- Set the text of TextLabel object to " + $amount"
	tl.TextColor3 = BrickColor.new("Bright yellow").Color    -- Set the TextColor3 of TextLabel object to Bright yellow color
	tl.Position = UDim2.new(0, 0, 1, 0)    -- Set the position of TextLabel object
	tl.Size = UDim2.new(0.2, 0, 0.1, 0)    -- Set the size of TextLabel object
	tl.Font = 32    -- Set the font size of TextLabel object to 32
	tl.TextScaled = true    -- Set the TextScaled to true
	local function finish()    -- Defining function finish
		tl:Destroy()    -- Destroy the TextLabel object
	end
	tl:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1, false, finish)    -- Tween the TextLabel object to (0.5, 0)
end

local function updatePlayerData(playerData)    -- Defining function updatePlayerData
	local newMoney = playerData.money    -- Get the newMoney value from playerData
	if newMoney > currentMoney then    -- Check if newMoney is greater than currentMoney
		BonusMoneyEffect(newMoney-currentMoney)    -- Call BonusMoneyEffect function
	end
	currentMoney = newMoney    -- Update currentMoney variable
	moneyLabel.Text = "$"..tostring(newMoney)    -- Set the text of Money object to newMoney
	rebirthLabel.Text = tostring(playerData.rebirths)    -- Set the text of Rebirths object to playerData rebirths value
	rebirthLabel.Visible = playerData.rebirths > 0    -- Set the visibility of Rebirths object to true if playerData rebirths value is greater than 0
	UpdateBeam()    -- Call the UpdateBeam function
end

UpdateUI.OnClientEvent:Connect(updatePlayerData)    -- Update the player data on UpdateUI event

function UiHandler:IncrementMoney(amount)--local    -- Defining function UiHandler:IncrementMoney
	local newMoney = currentMoney + amount    -- Update the newMoney variable
	if newMoney > currentMoney then    -- Check if newMoney is greater than currentMoney
		BonusMoneyEffect(amount)    -- Call BonusMoneyEffect function
	end
	currentMoney = newMoney    -- Update the currentMoney variable
	moneyLabel.Text = "$"..tostring(newMoney)    -- Set the text of Money object to newMoney
end

function UiHandler:Initialize()    -- Defining function UiHandler:Initialize
	HandleCharacter(LocalPlayer.Character)    -- Call HandleCharacter function
	LocalPlayer.CharacterAdded:Connect(HandleCharacter)    -- Call HandleCharacter function on LocalPlayer CharacterAdded event
	TutorialTarget.Changed:Connect(UpdateBeam)    -- Call the UpdateBeam function on TutorialTarget Changed event
end

local function notification(title, text)    -- Defining function notification
	StarterGui:SetCore("SendNotification", {    -- Call SetCore function
		Title = title,    -- Set the Title to title
		Text = text,    -- Set the Text to text
		Duration = 5    -- Set the Duration to 5
	})
end
Notify.OnClientEvent:Connect(notification)    -- Call notification function on Notify event

return UiHandler    -- Return the UiHandler
