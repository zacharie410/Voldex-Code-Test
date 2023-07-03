if not game:IsLoaded() then    -- Check if game is loaded
    game.Loaded:Wait()    -- Wait for game to be loaded
end

local modules = {}    -- Initialize modules variable

local Scripts = script.Parent    -- Get parent of script

local function LoadModule(module)    -- Declare a function
    local mod = require(module)    -- Load a module
    mod.modules = modules    -- Set module's module variable
    modules[module.Name] = mod    -- Add module to modules table
end

LoadModule(Scripts:WaitForChild("PaycheckMachineHandler"))    -- Load PaycheckMachineHandler module
LoadModule(Scripts:WaitForChild("UiHandler"))    -- Load UiHandler module

modules.UiHandler:Initialize()    -- Initialize the UiHandler module
