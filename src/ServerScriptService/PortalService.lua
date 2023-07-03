local PortalService = {}
local Notify: RemoteEvent = game.ReplicatedStorage.Remotes.Notify    -- Create a remote event for Notify

function PortalService:InitializePlot(plotFolder)    -- Define function to initialize plot
    local portalHub = plotFolder.PortalHub    -- Initialize portalHub value from PortalHub in plotFolder
    local zones = plotFolder.Zones    -- Initialize zones value from Zones in plotFolder

    --handle_lava    -- Comment

    for _, z in ipairs(zones:GetChildren()) do    -- Iterate over all zones
        for _, child in pairs(z:GetChildren()) do    -- Iterate over all children of zone
            if child.Name == "Lava" then    -- Check if child name is "Lava"
                child.Touched:Connect(function(hit)    -- Connect child to Touched event
                    if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then    -- Check if hit has parent and humanoid
                        hit.Parent.Humanoid:TakeDamage(25)    -- Take damage of 25
                    end
                end)
            end
        end
    end

    for _, portal in ipairs(portalHub:GetChildren()) do    -- Iterate over all portals in portalHub
        local dependency = portal.Dependency.Value    -- Initialize dependency value from Dependency in portal
        local dependencyPassed = true

        local lastTravel = time();    -- Initialize lastTravel with current time
        local zone = zones:FindFirstChild(portal.Name)    -- Initialize zone value from zone name

        local portalSound1 = Instance.new("Sound")    -- Create new sound object
        portalSound1.SoundId = "rbxassetid://289556450"    -- set sound ID
        portalSound1.Parent = portal.Portal    -- set portalSound1 parent to portal
        local portalSound2 = portalSound1:Clone()    -- clone portalSound1 and assign it to portalSound2
        portalSound2.Parent = zone.Portal.Portal    -- set portalSound2 parent to zone.Portal.Portal

        local prompt1 = Instance.new("ProximityPrompt")    -- Create new proximity prompt object
        prompt1.Enabled = false    -- set enabled value to false
        prompt1.Parent = portal.Portal    -- set prompt1 parent to portal
        prompt1.ActionText = "Teleport"    -- set action text to "Teleport"
        prompt1.ObjectText = portal.Name    -- set object text to portal name
        prompt1.MaxActivationDistance = 24    -- set max activation distance to 24
        local prompt2 = prompt1:Clone()    -- Clone prompt1 and assign it to prompt2
        prompt2.Parent = zone.Portal.Portal    -- set prompt2 parent to zone.Portal.Portal
        
        if dependency then    -- check if dependency is not null
            dependencyPassed = false    -- set dependencyPassed to false
            local isBoss = dependency:GetAttribute("isBoss") 
            if not isBoss and dependency:GetAttribute("isFinished") or isBoss and dependency:GetAttribute("isDefeated") then    -- Check if isBoss and isDefeated or not isBoss and isFinished
                --dependency is finished    -- Comment
                prompt1.Enabled = true    -- set prompt1 enabled value to true
                prompt2.Enabled = true    -- set prompt2 enabled value to true
                dependencyPassed = true    -- set dependencyPassed to true
                portal.Portal.BrickColor = BrickColor.new("Bright blue")    -- set portal color to "Bright blue"
            else
                dependency:GetAttributeChangedSignal(isBoss and "isDefeated" or "isFinished"):Connect(function()    -- Connect dependency to attribute changed signal
                    prompt1.Enabled = true    -- set prompt1 enabled value to true
                    prompt2.Enabled = true    -- set prompt2 enabled value to true
                    dependencyPassed = true    -- set dependencyPassed to true
                    portal.Portal.BrickColor = BrickColor.new("Bright blue")    -- set portal color to "Bright blue"
                    Notify:FireClient(plotFolder.Player.Value, "New portal", "Now available: " .. portal.Name .. " portal")    -- Fire client with "New portal" message
                end)
            end
        else
            portal.Portal.BrickColor = BrickColor.new("Bright blue")    -- set portal color to "Bright blue"
        end

        prompt1.Triggered:Connect(function(player)    -- Connect prompt1 to Triggered event
            if dependencyPassed and (time() - lastTravel) > 1 then -- teleport to zone    -- check if dependencyPassed is true and enough time has passed
                lastTravel = time();    -- Update lastTravel value to current time
                player.Character.PrimaryPart.CFrame = (CFrame.new((zone.Portal.Portal.CFrame).p + Vector3.new(10, 0, 0)))    -- Teleport to zone
                portalSound2:Play()    -- Play portalSound2
            end
        end)
        prompt2.Triggered:Connect(function(player)    -- Connect prompt2 to Triggered event
            if (time() - lastTravel) > 1 then -- teleport back to hub    -- check if enough time has passed
                lastTravel = time();    -- Update lastTravel value to current time
                player.Character.PrimaryPart.CFrame = (CFrame.new((portal.Portal.CFrame).p - Vector3.new(10, 0, 0)))    -- Teleport to hub
                portalSound1:Play()    -- Play portalSound1
            end
        end)
    end
end

return PortalService    -- Return PortalService
