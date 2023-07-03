
local CombatService = {}    -- Declare a module CombatService

local Players = game:GetService("Players")    -- Get Players service
local Debris = game:GetService("Debris")    -- Get Debris service
local RunService = game:GetService("RunService")    -- Get RunService service

function CombatService:NewSword(Tool)    -- Define a function NewSword
    local Handle = Tool:WaitForChild("Handle")    -- Initialize Handle variable with the child of tool

    local Character, Player, Humanoid, Torso = nil, nil, nil, nil;    -- Declare local variables
    local buff = 0    -- Declare local variables

    local function Create(ty)    -- Define a local function Create with argument ty
        return function(data)    -- Return a function
            local obj = Instance.new(ty)    -- Initialize local variable obj with the instance of ty
            for k, v in pairs(data) do    -- Loop through data table
                if type(k) == 'number' then    -- Check if type of k is number or not
                    v.Parent = obj    -- Add v as a child of obj
                else
                    obj[k] = v    -- Assign value of v to obj[k]
                end
            end
            return obj    -- Return the value of obj
        end
    end

    local BaseUrl = "rbxassetid://"    -- Declare a local variable BaseUrl



    local DamageValues = {    -- Declare a local table type variable DamageValues
        BaseDamage = 5,    -- Assign 5 to BaseDamage
        SlashDamage = 10,    -- Assign 10 to SlashDamage
        LungeDamage = 30    -- Assign 30 to LungeDamage
    }

    --For R15 avatars
    local Animations = {    -- Declare a local table type variable Animations
        R15Slash = 522635514,    -- Assign 522635514 to R15Slash
        R15Lunge = 522638767    -- Assign 522638767 to R15Lunge
    }

    local Damage = DamageValues.BaseDamage    -- Assign value of BaseDamage to Damage

    local Grips = {    -- Declare a local table type variable Grips
        Up = CFrame.new(0, 0, -1.70000005, 0, 0, 1, 1, 0, 0, 0, 1, 0),    -- Assign CFrame value to Up
        Out = CFrame.new(0, 0, -1.70000005, 0, 1, 0, 1, -0, 0, 0, 0, -1)    -- Assign CFrame value to Out
    }

    local Sounds = {    -- Declare a local table type variable Sounds
        Slash = Handle:WaitForChild("SwordSlash"),    -- Assign child of Handle to Slash
        Lunge = Handle:WaitForChild("SwordLunge"),    -- Assign child of Handle to Lunge
        Unsheath = Handle:WaitForChild("Unsheath")    -- Assign child of Handle to Unsheath
    }

    local ToolEquipped = false    -- Declare a local variable ToolEquipped with false value

    --For Omega Rainbow Katana thumbnail to display a lot of particles.
    for _, v in ipairs(Handle:GetChildren()) do    -- Loop through children of Handle
        if v:IsA("ParticleEmitter") then    -- Check if v is a ParticleEmitter
            v.Rate = 20    -- Assign 20 to rate property of v
        end
    end

    Tool.Grip = Grips.Up    -- Assign Up to Grip property of Tool
    Tool.Enabled = true    -- Assign true to Enabled property of Tool

    local function IsTeamMate(Player1, Player2)    -- Define a local function IsTeamMate with arguments Player1 and Player2
        return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)    -- Return true if Player1 and Player2 are not neutral and Player1.TeamColor is equal to Player2.TeamColor
    end

    local function TagHumanoid(humanoid, player)    -- Define a local function TagHumanoid with arguments humanoid and player
        local Creator_Tag = Instance.new("ObjectValue")    -- Initialize Creator_Tag variable with ObjectValue instance
        Creator_Tag.Name = "creator"    -- Assign "creator" to Name property of Creator_Tag
        Creator_Tag.Value = player    -- Assign player to Value property of Creator_Tag
        Debris:AddItem(Creator_Tag, 2)    -- Add Creator_Tag to Debris with 2 seconds delay
        Creator_Tag.Parent = humanoid    -- Add Creator_Tag as a child of humanoid
    end

    local function UntagHumanoid(humanoid)    -- Define a local function UntagHumanoid with argument humanoid
        for _, v in ipairs(humanoid:GetChildren()) do    -- Loop through children of humanoid
            if v:IsA("ObjectValue") and v.Name == "creator" then    -- Check if v is a ObjectValue and Name property of v equals to "creator"
                v:Destroy()    -- Destroy v
            end
        end
    end

    local function CheckIfAlive()    -- Define a local function CheckIfAlive
        return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)    -- Return true if Player, Character, Humanoid, Torso and Humanoid.Health is greater than 0
    end

    local function Blow(Hit)    -- Define a local function Blow with argument Hit
        if not Hit or not Hit.Parent or (Hit.Name~="HitBox" and Hit.Transparency == 1) or Hit:GetAttribute("Immune") or not CheckIfAlive() or not ToolEquipped then    -- Check if Hit, Hit.Parent, Hit.Name, Hit.Transparency, Hit:GetAttribute("Immune"), CheckIfAlive and ToolEquipped return false
            return    -- Return from function
        end
        local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")    -- Initialize RightArm variable with Right Arm or RightHand
        if not RightArm then    -- Check if RightArm returns false
            return    -- Return from function
        end
        local RightGrip = RightArm:FindFirstChild("RightGrip")    -- Initialize RightGrip variable with RightGrip child of RightArm
        if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then    -- Check if RightGrip and RightGrip.Part0, RightGrip.Part1 return false
            return    -- Return from function
        end
        local character = Hit.Parent    -- Initialize character variable with Hit.Parent
        if character == Character then    -- Check if character is equal to Character
            return    -- Return from function
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")    -- Initialize humanoid variable with FindFirstChildOfClass("Humanoid") of character
        if not humanoid or humanoid.Health == 0 then    -- Check if humanoid or humanoid.Health return false
            return    -- Return from function
        end
        local player = Players:GetPlayerFromCharacter(character)    -- Initialize player variable with Players:GetPlayerFromCharacter(character)
        if player and (player == Player or IsTeamMate(Player, player)) then    -- Check if player is equal to Player or IsTeamMate returns true
            return    -- Return from function
        end
        UntagHumanoid(humanoid)    -- Call UntagHumanoid function
        TagHumanoid(humanoid, Player)    -- Call TagHumanoid function
        humanoid:TakeDamage(Damage + buff)    -- Call TakeDamage function on humanoid with Damage and buff
    end


    local function Attack()    -- defining function Attack
        Damage = DamageValues.SlashDamage    -- Assign the value of slash damage to Damage variable
        Sounds.Slash:Play()    -- Play slash sound

        if Humanoid then    -- Check if Humanoid exists or not
            if Humanoid.RigType == Enum.HumanoidRigType.R6 then    -- Check if RigType is R6
                local Anim = Instance.new("StringValue")    -- Create new StringValue instance
                Anim.Name = "toolanim"    -- Set the name of instance to toolanim
                Anim.Value = "Slash"    -- Set the value of instance to Slash
                Anim.Parent = Tool    -- Set the parent of instance to Tool
            elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then    -- Check if RigType is R15
                local Anim = Tool:FindFirstChild("R15Slash")    -- Find first child of Tool with name R15Slash
                if Anim then    -- Check if Anim exists or not
                    local Track = Humanoid:LoadAnimation(Anim)    -- Load animation of Anim to Track
                    Track:Play(0)    -- Play animation of Track
                end
            end
        end	
    end

    local function Lunge()    -- Defining function Lunge
        Damage = DamageValues.LungeDamage    -- Assign the value of lunge damage to Damage variable

        Sounds.Lunge:Play()    -- Play lunge sound
        
        if Humanoid then    -- Check if Humanoid exists or not
            if Humanoid.RigType == Enum.HumanoidRigType.R6 then    -- Check if RigType is R6
                local Anim = Instance.new("StringValue")    -- Create new StringValue instance
                Anim.Name = "toolanim"    -- Set the name of instance to toolanim
                Anim.Value = "Lunge"    -- Set the value of instance to Lunge
                Anim.Parent = Tool    -- Set the parent of instance to Tool
            elseif Humanoid.RigType == Enum.HumanoidRigType.R15 then    -- Check if RigType is R15
                local Anim = Tool:FindFirstChild("R15Lunge")    -- Find first child of Tool with name R15Lunge
                if Anim then    -- Check if Anim exists or not
                    local Track = Humanoid:LoadAnimation(Anim)    -- Load animation of Anim to Track
                    Track:Play(0)    -- Play animation of Track
                end
            end
        end
        
        task.wait(0.2)    -- wait for 0.2 seconds
        Tool.Grip = Grips.Out    -- Assign the value of Out to Grip variable
        task.wait(0.6)    -- wait for 0.6 seconds
        Tool.Grip = Grips.Up    -- Assign the value of Up to Grip variable

        Damage = DamageValues.SlashDamage    -- Assign the value of SlashDamage to Damage variable
    end

    Tool.Enabled = true    -- set the value of Enabled to true
    local LastAttack = 0    -- initialize variable LastAttack with 0

    local function Activated()    -- Defining function activated
        if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then    -- Check if Tool is enabled or not and ToolEquipped is false or not
            return
        end
        Tool.Enabled = false    -- set the value of Enabled to false
        local Tick = RunService.Stepped:Wait()    -- wait for Stepped run service
        if Tick - LastAttack < 0.2 then    -- Check if Tick - LastAttack is less than 0.2
            Lunge()    -- call Lunge function
        else
            Attack()    -- call Attack function
        end
        LastAttack = Tick    -- Set the value of Tick to LastAttack

        Damage = DamageValues.BaseDamage    -- Assign the value of BaseDamage to Damage variable
        local _ = (Tool:FindFirstChild("R15Slash") or Create("Animation"){    -- Create new Animation instance with name R15Slash in Tool
            Name = "R15Slash",
            AnimationId = BaseUrl .. Animations.R15Slash,
            Parent = Tool
        })
        
        local _ = (Tool:FindFirstChild("R15Lunge") or Create("Animation"){    -- Create new Animation instance with name R15Lunge in Tool
            Name = "R15Lunge",
            AnimationId = BaseUrl .. Animations.R15Lunge,
            Parent = Tool
        })
        Tool.Enabled = true    -- set the value of Enabled to true
    end


    local function Equipped()    -- Defining function Equipped
        Character = Tool.Parent    -- Assign the value of parent of tool to Character variable
        Player = Players:GetPlayerFromCharacter(Character)    -- Get the player from Character and assign it to Player variable
        if Player:GetAttribute("Strength") then    -- Check if Player has attribute Strength or not
            buff = Player:GetAttribute("Strength")    -- Assign the value of Strength to buff variable
        end
        Humanoid = Character:FindFirstChildOfClass("Humanoid")    -- Find first child of Humanoid class in Character and assign it to Humanoid variable
        Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("HumanoidRootPart")    -- Find first child with name "Torso" in Character or find first child with name "HumanoidRootPart"
        if not CheckIfAlive() then    -- Check if CheckIfAlive() is true or not
            return
        end
        ToolEquipped = true    -- set the value of ToolEquipped to true
        Sounds.Unsheath:Play()    -- Play sound of Unsheath
    end

    local function Unequipped()    -- Defining function Unequipped
        Tool.Grip = Grips.Up    -- Assign the value of Up to Grip variable
        ToolEquipped = false    -- set the value of ToolEquipped to false
    end

    Tool.Activated:Connect(Activated)    -- Connect Activated function to the Activated event of Tool
    Tool.Equipped:Connect(Equipped)    -- Connect Equipped function to the Equipped event of Tool
    Tool.Unequipped:Connect(Unequipped)    -- Connect Unequipped function to the Unequipped event of Tool

    Handle.Touched:Connect(Blow)    -- Connect Blow function to the Touched event of Handle
end

local function monitorBackpack(player)    -- Defining function monitorBackpack
    local function loadSword()    -- Defining function loadSword
        local newSword = game.ReplicatedStorage.Assets.Swords.ClassicSword:Clone()    -- Clone ClassicSword and assign it to newSword
        newSword.Parent = player.Backpack    -- Set the parent of newSword to player's backpack
        CombatService:NewSword(newSword)    -- call NewSword function on newSword
    end
    local function update()    -- Defining function update
        if player.Character and player.Character:FindFirstChild("Humanoid") then    -- Check if player has Character and Humanoid
            player.Character.Humanoid.WalkSpeed = 25 + (player:GetAttribute("Speed") or 0)    -- Set the walk speed of Humanoid
            player.Character.Humanoid.MaxHealth = 100 + (player:GetAttribute("Health") or 0)    -- Set the max health of Humanoid
        end
    end
    update()    -- call update function
    player.CharacterAdded:Connect(function()    -- Connect CharacterAdded event to the function
        update()    -- call update function
        loadSword()    -- call loadSword function

        player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth    -- Set the health of Humanoid to max health
    end)
    player:GetAttributeChangedSignal("Speed"):Connect(update)    -- Connect update function to Speed attribute change
    player:GetAttributeChangedSignal("Health"):Connect(update)    -- Connect update function to Health attribute change

end

for _, p in ipairs(game.Players:GetPlayers()) do    -- For loop on all players
    monitorBackpack(p)    -- call monitorBackpack function on each player
end
Players.PlayerAdded:Connect(monitorBackpack)    -- Connect monitorBackpack function to PlayerAdded event

return CombatService    -- return CombatService