if not game:IsLoaded() then    -- check if the game is loaded or not
    game.Loaded:Wait()    -- wait for the game to load
end

local RunService = game:GetService("RunService")    -- get the RunService object

local plots = workspace.Plots    -- get plots workspace

local function animatePortal(portal)    -- function to animate the portal
    return RunService.Heartbeat:Connect(function(dt)    -- rotate the portal on heartbeat event
        portal.Portal.CFrame = portal.Portal.CFrame * CFrame.Angles(dt, 0, 0)
    end)
end

local function animatePortalHub(plotFolder)    -- function to animate portal and zone
    local portalHub = plotFolder:WaitForChild("PortalHub")    -- get the portalHub
    local zones = plotFolder:WaitForChild("Zones")    -- get all zones
    local animationEvents = {}    -- empty list for storing animation events
    for _, portal in ipairs(portalHub:GetChildren()) do    -- iterate over all portals
        table.insert(animationEvents, animatePortal(portal))    -- animate all portals
    end

    for _, zone in ipairs(zones:GetChildren()) do    -- iterate over all zones
        table.insert(animationEvents, animatePortal(zone.Portal))    -- animate all zones
    end

    local removedEvent    -- remove event
    removedEvent = plots.ChildRemoved:Connect(function(child)    -- connect to childRemoved event
        if child.Name == plotFolder.Name then    -- if child is removed from plots
            removedEvent:Disconnect()    -- disconnect from the remove event
            --stop all animations
            for _, event in ipairs(animationEvents) do    -- iterate over all animation events
                event:Disconnect()    -- disconnect from the animation event
            end
            animationEvents = nil    -- empty the animation events list
            removedEvent = nil    -- remove the removedEvent variable
        end
    end)
end

plots.ChildAdded:Connect(function(plotFolder)    -- connect to ChildAdded event
    animatePortalHub(plotFolder)    -- animate the portalHub
end)
