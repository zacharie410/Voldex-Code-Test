local PaycheckMachineHandler = {}    -- Initialize PaycheckMachineHandler module

local Players = game:GetService("Players")    -- Get the reference of "Players" service from game engine
local RunService = game:GetService("RunService")    -- Get the reference of "RunService" service from game engine
local ReplicatedStorage = game:GetService("ReplicatedStorage")    -- Get the reference of "ReplicatedStorage" instance
local RequestPaycheck: RemoteFunction = ReplicatedStorage.Remotes.RequestPaycheck    -- Get the reference of "RequestPaycheck" remote function
local UpdatePaycheckMachines: RemoteEvent = ReplicatedStorage.Remotes.UpdatePaycheckMachines    -- Get the reference of "UpdatePaycheckMachines" remote event
local LocalPlayer = Players.LocalPlayer    -- Get the reference of local player

local plots = workspace.Plots    -- Get the reference of "plots" instance
local paycheckMachines = {}    -- Initialize paycheckMachines variable
local updateEvent

local nextPaymentValue = 0    -- Initialize nextPaymentValue variable with 0
local debouncer = 0    -- Initialize debouncer variable with 0

local function loadPlot(myPlot)    -- Define local function "loadPlot"
	local paycheckMachinesFolder = myPlot:WaitForChild("PaycheckMachines")    -- Get the reference of "PaycheckMachines" instance from myPlot
	paycheckMachines = paycheckMachinesFolder:GetChildren()    -- Get all the children of "PaycheckMachines" instance

	local ta = Instance.new("Attachment")    -- Create new instance of "Attachment"
	PaycheckMachineHandler.tutorialAttachment = ta    -- Assign the reference of "Attachment" instance to "tutorialAttachment"

	for _, paycheckMachine in ipairs(paycheckMachines) do    -- Loop through each "paycheckMachine"
		local pad: BasePart = paycheckMachine.PadComponents.Pad    -- Get the reference of "pad" instance from "paycheckMachine" instance
		ta.Parent = pad    -- Set the parent of "Attachment" instance to "pad" instance
		local prompt = Instance.new("ProximityPrompt")    -- create new instance of "ProximityPrompt"
		prompt.Parent = pad    -- Set the parent of "ProximityPrompt" instance to "pad" instance
		prompt.RequiresLineOfSight = false    -- Set the value of "RequiresLineOfSight" property to false
		prompt.ActionText = "Collect"    -- Set the value of "ActionText" property to "Collect"
		prompt.Triggered:Connect(function()    -- set the value of triggered property to function
			if os.time() - debouncer < 1 or nextPaymentValue == 0 then    -- check if the difference between os.time() and debouncer is less than 1 or nextPaymentValue is 0
				return    -- return
			end
			paycheckMachine.Particles.CashSound:Play()    -- Play "CashSound" particle
			paycheckMachine.Particles.Coins:Emit(nextPaymentValue*0.01)    -- Emit "Coins" with value of nextPaymentValue*0.01
			debouncer = os.time()    -- set the value of "debouncer" to os.time()
			--update ui locally
			PaycheckMachineHandler.modules.UiHandler:IncrementMoney(nextPaymentValue)    -- increment the value of money
			RequestPaycheck:InvokeServer(nextPaymentValue)    -- call remote function "RequestPaycheck"
		end)
	end

	if updateEvent then    -- check if updateEvent is null
		updateEvent:Disconnect()    -- disconnect the updateEvent
		updateEvent = nil    -- set the value of updateEvent to nil
	end

	updateEvent = UpdatePaycheckMachines.OnClientEvent:Connect(function(amount)    -- set the value of updateEvent to function
		nextPaymentValue = amount    -- set the value of nextPaymentValue to amount
		for _, paycheckMachine in ipairs(paycheckMachines) do    -- loop through each paycheckMachine
			local moneyLabel = paycheckMachine:FindFirstChild("MoneyLabel", true)    -- Get the reference of "MoneyLabel" instance from paycheckMachine
			moneyLabel.Text = tostring(amount)    -- Set the value of "Text" property to amount
		end
	end)
end

local currentPlot = plots:FindFirstChild(tostring(Players.LocalPlayer.UserId))    -- Get the reference of plot from "plots" instance
if currentPlot then    -- check if currentPlot is not null
	loadPlot(currentPlot)    -- call loadPlot function
end

plots.ChildAdded:Connect(function(child)    -- Connect "ChildAdded" event with function
	if child.Name == tostring(Players.LocalPlayer.UserId) then    -- check if the name of child is equal to "Players.LocalPlayer.UserId"
		loadPlot(child)    -- call loadPlot function
	end
end)

plots.ChildRemoved:Connect(function(child)    -- Connect "ChildRemoved" event with function
	if child.Name == tostring(Players.LocalPlayer.UserId) then    -- check if the name of child is equal to "Players.LocalPlayer.UserId"
		if updateEvent then    -- check if updateEvent is not null
			updateEvent:Disconnect()    -- disconnect the updateEvent
			updateEvent = nil    -- set the value of updateEvent to nil
		end
	end
end)

RunService.Heartbeat:Connect(function()    -- Connect "Heartbeat" of "RunService" with function
	if LocalPlayer:GetAttribute("Gamepass_Auto_Collect") and (os.time() - debouncer) > 10 then    -- check if "LocalPlayer" has attribute "Gamepass_Auto_Collect" and the difference between os.time() and debouncer is greater than 10
		debouncer = os.time()    -- set the value of "debouncer" to os.time()

		RequestPaycheck:InvokeServer(nextPaymentValue)    -- call remote function "RequestPaycheck"
	end
end)

return PaycheckMachineHandler    -- return PaycheckMachineHandler