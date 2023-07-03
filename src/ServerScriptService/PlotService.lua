local PlotService = {}    -- PlotService is an empty table

local ReplicatedStorage = game:GetService("ReplicatedStorage")    -- Get the ReplicatedStorage service
local ServerScriptService = game:GetService("ServerScriptService")    -- Get the ServerScriptService service
local Players = game:GetService("Players")    -- Get the Players service
local PadService = require(ServerScriptService.PadService)    -- Require PadService module
local PortalService = require(ServerScriptService.PortalService)    -- Require PortalService module

local currentPlots = {}    -- Declare currentPlots table
local availableAreas = {}    -- Declare availableAreas table

local plots = workspace.Plots    -- Get the plots folder from workspace
local originalTemplate = plots.PlotTemplate    -- Get the PlotTemplate folder from plots
local plotTemplate = Instance.new("Model")    -- Create a new model and store it in plotTemplate

function PlotService:Initialize() -- run once    -- Create a new function Initialize
    plotTemplate.Parent = game.ReplicatedStorage--migrate folder to model    -- Set plotTemplate's parent to ReplicatedStorage
    for _, child in ipairs(originalTemplate:GetChildren()) do    -- For loop to iterate over all the children of originalTemplate
        child.Parent =  plotTemplate -- we need to move the folder to a model to use MoveTo    -- Set child's parent to plotTemplate
        --, but we need the folder to make studio editing easier    -- Do nothing
    end
    originalTemplate:Destroy() -- all children migrated to model    -- Destroy originalTemplate

-- For loop to iterate over all the available areas
    for i = 1, Players.MaxPlayers do
        availableAreas[i] = true
    end
end

local function GetFirstAvailableArea()    -- Create a new function GetFirstAvailableArea
    for i = 1, #availableAreas do    -- For loop to iterate over all the available areas
        if availableAreas[i] then    -- Check if an area is available at index i
            return i    -- Return i
        end
    end
    return #availableAreas + 1 -- overflow    -- Return the total number of available areas + 1
end

local function ClaimArea()    -- Create a new function ClaimArea
    local id = GetFirstAvailableArea()    -- Get the first available area
    availableAreas[id] = false    -- Set availableAreas[id] to false
    return id    -- Return id
end

local function FreeArea(id)    -- Create a new function FreeArea
    availableAreas[id] = true    -- Set availableAreas[id] to true
end

function PlotService:CreatePlot(player)    -- Create a new function CreatePlot
    local area = ClaimArea()    -- Get the area where the plot is going to be placed
    local newPlot = plotTemplate    -- newPlot is the plotTemplate

-- Create a new variable "backup" and set it to a clone of plotTemplate
    local backup = plotTemplate:Clone()
    plotTemplate = backup

-- Set newPlot's Player to player
    newPlot.Player.Value = player
    newPlot.Name = tostring(player.UserId)    -- Set newPlot's name to player's userId

-- Move newPlot to the previously acquired area
    newPlot:PivotTo(newPlot:GetPivot() * CFrame.new((area-1) * 800, 0, 0))
    newPlot.Parent = plots    -- Set newPlot's parent to plots

-- Set player's RespawnLocation to newPlot's SpawnLocation
    player.RespawnLocation = newPlot.SpawnLocation

-- Store area and newPlot in currentPlots table using player's userId as the key
    currentPlots[tostring(player.userId)] = {newPlot, area}

-- Initialize PadService and PortalService for the new plot
    PadService:InitializePlot(newPlot, player)
    PortalService:InitializePlot(newPlot)
end

function PlotService:DestroyPlot(player)    -- Create a new function DestroyPlot
    local key = tostring(player.userId)    -- key is player's userId
    if currentPlots[key] then    -- Check if there is a plot at the key index
        local plot = currentPlots[key][1]    -- plot is the plot stored at the key index
        local area = currentPlots[key][2]    -- area is the area stored at the key index
        local temp = ReplicatedStorage.PlotTemp:FindFirstChild(key)    -- Find any children of ReplicatedStorage.PlotTemp with the key name
        plot:Destroy()    -- Destroy plot
        FreeArea(area)    -- Free the plot area
        if temp then    -- Check if temp exists
            temp:Destroy()    -- Destroy temp
        end
        currentPlots[key] = nil    -- Set currentPlots[key] to nil
    end
end

function PlotService:ReloadPlot(player)    -- Create a new function ReloadPlot
    self:DestroyPlot(player)    -- Destroy the plot for player
    self:CreatePlot(player)    -- Create a new plot for player
end

PlotService:Initialize()    -- Call the Initialize function

local function PlayerAdded(player)    -- Create a new function PlayerAdded
    local objectValue = Instance.new("ObjectValue")    -- Create a new ObjectValue
    objectValue.Name="TutorialTarget"    -- Set objectValue's name to "TutorialTarget"
    objectValue.Parent = player    -- Set objectValue's parent to player
    
-- Set player's RespawnLocation to workspace.GlobalSpawn
    player.RespawnLocation = workspace.GlobalSpawn
    PlotService:CreatePlot(player)    -- Create plot for player
end

local function PlayerRemoving(player)    -- Create a new function PlayerRemoving
    PlotService:DestroyPlot(player)    -- Destroy plot for player
end

for _, currentPlayers in ipairs(game.Players:GetPlayers()) do
    PlayerAdded(currentPlayers) -- ensure all players get loaded even if initalization took long    -- Call PlayerAdded for each currently online player
end

Players.PlayerAdded:Connect(PlayerAdded)    -- Call PlayerAdded when a player joins
Players.PlayerRemoving:Connect(PlayerRemoving)    -- Call PlayerRemoving when a player leaves

return PlotService    -- Return PlotService table
