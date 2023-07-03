
-- Create the BossService module    -- start of module definition
local BossService = {}    -- initialize module variable as table

local RunService = game:GetService("RunService")    -- initialize a variable to use runservice in module
local Players = game:GetService("Players")    -- initialize a variable to use players service in module

-- create bosses    -- function createbosses start

local bosses = {    -- initialize a variable as table
    PumpKing = function(bossService, char)    -- definition of function pumpking
        -- Add a boss    -- comment
        local pumpking = bossService:AddBoss("PumpKing", "Idle")    -- adding a boss
        pumpking.character=char    -- set character value
        pumpking.humanoid=char.Humanoid    -- set humanoid value

        local flamesOn = false    -- initialize variable flameson as false

        local flameSound = char.Head.FlameSound    -- initialize a variable flamesound

        local flames = {}    -- initialize variable flames as table
        for _, f in ipairs(pumpking.character:GetChildren()) do    -- iterate through array
            if f.Name == "Flame" then    -- check condition
                table.insert(flames, f.Fire)    -- insert value into flames table
                f.Touched:Connect(function(hit)    -- function definition
                    if f.Fire.Enabled then    -- check condition
                    local humanoid = hit.Parent:FindFirstChild("Humanoid")    -- initialize a variable humanoid
                    if humanoid then    -- check condition
                        humanoid:TakeDamage(5)    -- execute function
                    end
                    end
                end)
            end
        end

        local function SetFlames(value)    -- function definition
            if value and not flamesOn then    -- check condition
                flameSound:Play()    -- execute function
            end
            flamesOn = value    -- set value of flameson variable
            for _, f in ipairs(flames) do    -- iterate through array
                f.Enabled = value    -- set value of f variable
            end
        end

        local humanoid = pumpking.character.Humanoid    -- initialize variable humanoid
        local lastHealth = humanoid.Health    -- initialize variable lasthealth
        local flametime
        local attackSpeed = 3    -- initialize variable attackspeed

        local function TookDamage()    -- function definition
            local currentHealth = humanoid.Health    -- initialize variable currenthealth
            if currentHealth < lastHealth then    -- check condition
                lastHealth = currentHealth    -- set value of lasthealth variable
                return true    -- return true
            end
            lastHealth = currentHealth    -- set value of lasthealth variable
        end

        pumpking:AddBehaviour("Idle", function()    -- function definition
            if not flametime then    -- check condition
                flametime = time() + attackSpeed    -- set value of flametime variable
            end
            SetFlames(false)    -- execute function
            if TookDamage() and (time() - flametime) > attackSpeed*2 then    -- check condition
                flametime = time()    -- set value of flametime variable
                pumpking:TransitionTo("Flaming")    -- execute function
            end
        end)

        pumpking:AddBehaviour("Flaming", function()    -- function definition
            if not flametime then    -- check condition
                flametime = time()    -- set value of flametime variable
            end
            SetFlames(true)    -- execute function
            if (time() - flametime) > attackSpeed then    -- check condition
                -- Flame out after three seconds of being on fire    -- comment
                SetFlames(false)    -- execute function
                pumpking:TransitionTo("Idle")    -- execute function
            end
        end)

        pumpking:TransitionTo("Flaming")    -- execute function
    end,

Yeti = function(bossService, char)    -- Defining function Yeti with parameters bossService and char
    -- Add a boss
    local yeti = bossService:AddBoss("Yeti", "Idle")    -- Defining local variable yeti with value bossService:AddBoss("Yeti", "Idle")
    yeti.character=char    -- Assign value of char to character property of yeti variable
    yeti.humanoid=char.Humanoid    -- Assign value of char.Humanoid to humanoid property of yeti variable

    local humanoid = yeti.character.Humanoid    -- Defining local variable humanoid with value yeti.character.Humanoid
    local lastHealth = humanoid.Health    -- Defining local variable lastHealth with value humanoid.Health
    local nearestCharacter

    local lastAttack = time()    -- Defining local variable lastAttack with value of time()
    local attackSpeed = 3    -- Defining local variable attackSpeed with value 3
    local attackRange = 20    -- Defining local variable attackRange with value 20
    local attackDamage = 30    -- Defining local variable attackDamage with value 30

    --anim
    local runAnim = humanoid.RunAnim    -- Defining local variable runAnim with value humanoid.RunAnim
    local runTrack
    local animTracks={}
    local runSound = char.HumanoidRootPart.Running    -- Defining local variable runSound with value char.HumanoidRootPart.Running
    local punchSound = char.HumanoidRootPart.Punch    -- Defining local variable punchSound with value char.HumanoidRootPart.Punch
    local growlSound = char.HumanoidRootPart.Growl    -- Defining local variable growlSound with value char.HumanoidRootPart.Growl
    runSound:Play()    -- Play the sound of runSound
    local lastGrowl = 0    -- Defining local variable lastGrowl with value 0
    local growlTime = 5    -- Defining local variable growlTime with value 5

    humanoid.Running:Connect(function(speed)    -- Connecting function to humanoid.Running
        if not runTrack then    -- Checking if runTrack is nil or not
            runTrack = humanoid:LoadAnimation(runAnim)    -- If nil then assigning runTrack with value humanoid:LoadAnimation(runAnim)
        end
        
        if speed < 2 then    -- Check if speed is less than 2
            runSound.Volume = 0    -- Set volume to 0
            runTrack:Stop()    -- Stop the runTrack
        elseif not runTrack.IsPlaying then    -- Else if runTrack is not playing
            runSound.Volume = 0.5    -- Set volume to 0.5
            runTrack:Play()    -- Play the runTrack
        end
    end)

    local function PlayAnim(animName, priority, lock, lockDelay)    -- Defining local function "PlayAnim"
        local track = animTracks[animName]    -- Defining local variable track with value animTracks[animName]
        if not track then    -- Check if track is nil or not
            track = humanoid:LoadAnimation(humanoid:FindFirstChild(animName))    -- If nil then assigning track with value humanoid:LoadAnimation(humanoid:FindFirstChild(animName))
            animTracks[animName] = track    -- Assign value track to animTracks[animName]
        end
        track.Priority=priority    -- Assign value of priority to track.Priority
        track:Play()    -- Play the track
        if lock then    -- Check if lock is true or not
            track.Looped = true    -- If true then set track.Looped to true
            local e
            e = track.DidLoop:Connect(function()    -- Connecting function to track.DidLoop
                e:Disconnect()    -- Disconnect the function
                if lockDelay then    -- Check if lockDelay is true or not
                    task.wait(lockDelay)    -- If true then wait for lockDelay
                end
                track:AdjustSpeed(0)    -- Adjust speed of track to 0
            end)
        end
    end
    --

    local function TookDamage()    -- Defining local function TookDamage
        local currentHealth = humanoid.Health    -- Defining local variable currentHealth with value humanoid.Health
        if currentHealth < lastHealth then    -- Check if currentHealth is less than lastHealth
            lastHealth = currentHealth    -- If true then assign value of currentHealth to lastHealth
            if (time() - lastGrowl) > growlTime then    -- Check if time() - lastGrowl is greater than growlTime or not
                lastGrowl = time()    -- If true then assign value of time() to lastGrowl
                growlSound:Play()    -- Play the growlSound
                growlTime = math.random(5, 15)    -- Assign value of math.random(5, 15) to growlTime 
            end
            return true    -- Return true
        end
        lastHealth = currentHealth    -- Assign value of currentHealth to lastHealth
    end

    local function getDistanceFromCurrentTarget()    -- Defining local function getDistanceFromCurrentTarget
        return nearestCharacter and (nearestCharacter.PrimaryPart.Position - char.PrimaryPart.Position).magnitude or 999    -- Return nearestCharacter and (nearestCharacter.PrimaryPart.Position - char.PrimaryPart.Position).magnitude or 999
    end

    local function findTarget()    -- Defining local function findTarget
        if nearestCharacter then    -- Checking if nearestCharacter is nil or not
            if not nearestCharacter.PrimaryPart or not nearestCharacter:FindFirstChild("Humanoid") or nearestCharacter.Humanoid.Health <= 0 then    -- Checking if nearestCharacter.PrimaryPart is nil or not and nearestCharacter:FindFirstChild("Humanoid") is nil or not and nearestCharacter.Humanoid.Health is less than or equal to 0 or not
                nearestCharacter = nil    -- If true then assigning nil to nearestCharacter
            end
        end
        if not nearestCharacter then    -- Checking if nearestCharacter is nil or not
            for _, p in pairs(Players:GetPlayers()) do    -- Looping through all players
                if p.Character and p.Character.PrimaryPart then    -- Check if p.Character is nil or not and p.Character.PrimaryPart is nil or not
                    local dist = (p.Character.PrimaryPart.Position - char.PrimaryPart.Position).magnitude    -- Defining local variable dist with value (p.Character.PrimaryPart.Position - char.PrimaryPart.Position).magnitude
                    if dist < 200 then    -- Checking if dist is less than 200 or not
                        nearestCharacter = p.Character    -- If true then assign value of p.Character to nearestCharacter
                    end
                end
            end
        elseif nearestCharacter.PrimaryPart then    -- Else if nearestCharacter.PrimaryPart is not nil
            humanoid:MoveTo(nearestCharacter.PrimaryPart.Position)    -- Move the humanoid to nearestCharacter.PrimaryPart.Position
        end
        TookDamage()    -- Calling TookDamage function
    end

    yeti:AddBehaviour("Idle", function()    -- Add behaviour to yeti variable with "Idle" name
        if TookDamage() then    -- Call TookDamage function and check if it's return value is true or not
            yeti:TransitionTo("Chase")    -- If true then transition yeti to "Chase"
        end
    end)

    yeti:AddBehaviour("Chase", function()    -- Add behaviour to yeti variable with "Chase" name
        findTarget()    -- Call findTarget function
        if nearestCharacter and nearestCharacter.PrimaryPart then    -- Check if nearestCharacter is nil or not and nearestCharacter.PrimaryPart is nil or not
            local dist = getDistanceFromCurrentTarget()    -- Defining local variable dist with value of getDistanceFromCurrentTarget()
            if dist < attackRange and (time() - lastAttack) > attackSpeed then    -- Checking if dist is less than attackRange and time() - lastAttack is greater than attackSpeed or not
                PlayAnim("Slash", Enum.AnimationPriority.Action)    -- If true then call function PlayAnim with parameters "Slash", Enum.AnimationPriority.Action
                punchSound:Play()    -- Play the punchSound
                nearestCharacter.Humanoid:TakeDamage((1 - dist/attackRange) * attackDamage)    -- Damage the nearestCharacter
                lastAttack = time()    -- Assign value of time() to lastAttack
            end
        end
    end)

    yeti:TransitionTo("Chase")    -- Transition yeti to "Chase"
end,
Ghost = function(bossService, char)    -- Defining function Ghost
    -- Add a boss
    local ghost = bossService:AddBoss("Ghost", "Idle")    -- Add ghost as boss
    ghost.character=char    -- assign character to ghost
    ghost.humanoid=char.Humanoid    -- assign humanoid to ghost
    
    local humanoid = ghost.character.Humanoid    -- assign humanoid to ghost character
    local lastHealth = humanoid.Health    -- assign lastHealth with humanoid health
    local nearestCharacter    -- initialize nearestCharacter variable
    
    local lastAttack = time()    -- initialize lastAttack with time
    local attackSpeed = 6    -- initialize attackSpeed with 6
    local attackRange = 50    -- initialize attackRange with 50
    local attackDamage = 30    -- initialize attackDamage with 30
    local lastDamage = time()    -- initialize lastDamage with time

    --anim
    local runSound = char.HumanoidRootPart.Running    -- assign runSound with HumanoidRootPart runnig
    local punchSound = char.HumanoidRootPart.Punch    -- assign punchSound with HumanoidRootPart punch
    local growlSound = char.HumanoidRootPart.Growl    -- assign growlSound with HumanoidRootPart growl
    runSound:Play()    -- play runSound
    local lastGrowl = 0    -- initialize lastGrowl with 0
    local growlTime = 5    -- initialize growlTime with 5
    --

    char.AttackBox.Touched:Connect(function(hit)    -- assign callback when AttackBox is touched
        if hit and hit.Parent:FindFirstChild("Humanoid") and (time() - lastDamage) > .5 then    -- Check if hit, hit.Parent and lastDamage
            lastDamage = time()    -- assign lastDamage with time
            hit.Parent.Humanoid:TakeDamage(attackDamage)    -- attack on hit.Parent Humanoid
        end
    end)

    local function TookDamage()    -- Defining TookDamage function
        local currentHealth = humanoid.Health    -- initialize currentHealth with humanoid health
        if currentHealth < lastHealth then    -- Check if currentHealth is less than lastHealth
            lastHealth = currentHealth    -- assign lastHealth with currentHealth
            if (time() - lastGrowl) > growlTime then    -- Check if lastGrowl and growlTime
                lastGrowl = time()    -- assign lastGrowl with time
                growlSound:Play()    -- play growlSound
                growlTime = math.random(5, 15)    -- assign random value to growlTime
            end
            return true    -- return true
        end
        lastHealth = currentHealth    -- assign lastHealth with currentHealth
    end

    local function getDistanceFromCurrentTarget()    -- Defining getDistanceFromCurrentTarget function
        return nearestCharacter and (nearestCharacter.PrimaryPart.Position - char.PrimaryPart.Position).magnitude or 999    -- return nearestCharacter or 999
    end

    local function findTarget()    -- Defining findTarget function
        if nearestCharacter then    -- Check if nearestCharacter exists or not
            if not nearestCharacter.PrimaryPart or not nearestCharacter:FindFirstChild("Humanoid") or nearestCharacter.Humanoid.Health <= 0 then    -- Check if nearestCharacter is not PrimaryPart or not humanoid or Humanoid health is lesser than 0
                nearestCharacter = nil    -- assign nil to nearestCharacter
            end
        end

        if not nearestCharacter then    -- Check if nearestCharacter exists or not
            for _, p in pairs(Players:GetPlayers()) do    -- Loop through Players
                if p.Character and p.Character.PrimaryPart then    -- Check if p.Character exists or not
                    local dist = (p.Character.PrimaryPart.Position - char.PrimaryPart.Position).magnitude    -- initialize dist with distance of p.Character and char
                    if dist < 200 then    -- Check if dist is lesser than 200
                        nearestCharacter = p.Character    -- assign nearestCharacter with p.Character
                    end
                end
            end
        else
            humanoid.WalkSpeed = 20    -- assign humanoid.WalkSpeed with 20
            humanoid:MoveTo(nearestCharacter.PrimaryPart.Position)    -- move humanoid to nearestCharacter.PrimaryPart.Position
        end
        TookDamage()    -- call TookDamage function
    end

    ghost:AddBehaviour("Idle", function()    -- Add Idle behaviour in ghost
        if TookDamage() then    -- Check if TookDamage
            ghost:TransitionTo("Chase")    -- transition ghost to Chase behaviour
        end
    end)

    ghost:AddBehaviour("Chase", function()    -- Add Chase behaviour in ghost
        if (time() - lastAttack) > 2 then    -- Check if lastAttack and 2
            findTarget()    -- call findTarget function
            if nearestCharacter and nearestCharacter.PrimaryPart then    -- check if nearestCharacter exists or not
                local dist = getDistanceFromCurrentTarget()    -- initialize dist with getDistanceFromCurrentTarget
                if dist < attackRange and (time() - lastAttack) > attackSpeed then    -- Check if dist is lesser than attackRange and lastAttack is lesser than attackSpeed
                    punchSound:Play()    -- play punchSound
                    lastAttack = time()    -- assign lastAttack with time
                    local vector = (nearestCharacter.PrimaryPart.Position - char.PrimaryPart.Position)    -- initialize vector with difference of nearestCharacter and char
                    humanoid:MoveTo(nearestCharacter.PrimaryPart.Position + vector)    -- move humanoid to nearestCharacter and vector
                    humanoid.WalkSpeed = 50    -- assign humanoid.WalkSpeed with 50
                end
            end
        end
    end)

    ghost:TransitionTo("Chase")    -- transition ghost to Chase behaviour
end
}

--[[
This code creates a boss service.
The code starts by defining the Boss class.
It then defines the "new" function that creates a new boss.
The code then defines a function called "AddTransition" that adds a transition to the boss.
The code then defines a function called "AddBehaviour" that adds a behaviour to the boss.
The code then defines a function called "TransitionTo" that transitions the boss to a new state.
The code then defines a function called "Action" that performs an action.
The code then defines a function called "CleanPlayerThread" that cleans up the player thread.
The code then defines a function called "BindPlayerThread" that binds a player thread to a player.
The code then defines the "new" function that creates a new boss service.
The code then defines a function called "AddBoss" that adds a boss to the boss service.
The code then defines a function called "GetBoss" that gets a boss from the boss service.
The code then defines a function called "Tick" that ticks the boss service.
The code then defines a function called "SummonBoss" that summons a boss.
The code then defines a variable called "elapsed" and sets it to 0.
The code then defines a variable called "heartbeat" and sets it to the result of the RunService.Heartbeat.Connect function.
The code then binds the heartbeat to the player.
The code then returns the boss service.
The code then defines a function called "CleanPlayerThread" and passes it a player.
The code then defines a variable called "key" and sets it to the result of calling the tostring function on the player user ID.
The code then checks if the runningThreads variable has a key with the given key as a key.
If the runningThreads variable does have a key with the given key as a key, the code will disconnect the heartbeat and set the runningThreads variable to nil.
The code then defines a function called "BindPlayerThread" and passes it a player and a thread.
The code then defines a variable called "key" and sets it to the result of calling the tostring function on the player user ID.
The code then sets the runningThreads variable to the given thread.
The code then defines a function that cleans up the player thread when the player leaves.
--]]

-- Define the Boss class
local Boss = {}
Boss.__index = Boss

function Boss.new(name, initialState)    -- Defining function "Boss.new"
    local self = setmetatable({}, Boss)    -- setmetatable function
    self.name = name    -- Initialize the name variable
    self.currentState = initialState    -- Initialize currentState variable
    self.transitions = { }    -- Initialize transitions variable
    self.behaviours = { }    -- Initialize behaviours variable
    return self    -- return the value of self
end

function Boss:AddTransition(fromState, toState, callback)    -- Defining function "Boss:AddTransition"
    self.transitions = self.transitions or {}    -- Initialize transitions variable
    self.transitions[fromState] = {toState = toState, callback = callback}    -- Store the value fromState, toState and callback
end

function Boss:AddBehaviour(behaviourName, callback)    -- Defining function "Boss:AddBehaviour"
    self.behaviours = self.behaviours or {}    -- Initialize behaviours variable
    self.behaviours[behaviourName] = callback    -- Store the value of behaviourName and callback
end

function Boss:TransitionTo(state)    -- Defining function "Boss:TransitionTo"
    local transition = self.transitions[self.currentState]    -- Initialize transition variable
    if transition and transition.toState == state then    -- check if transition and transition.toState are equal to state or not
        if transition.callback then    -- check if transition.callback is null or not
            transition.callback()    -- call transition.callback function
        end
    end
    self.currentState = state    -- Initialize currentState variable
end

function Boss:Action()    -- Defining function "Boss:Action"
    if self.busy then return end    -- check if busy is true or not
    self.busy = true    -- Initialize busy variable
    self.behaviours[self.currentState]()    -- call behaviours[self.currentState] function
    self.busy = false    -- Initialize busy variable
end

local runningThreads = {}    -- Initialize runningThreads variable

function BossService:CleanPlayerThread(player)    -- Defining function "CleanPlayerThread"
    local key = tostring(player.UserId)    -- Initialize key variable
    if runningThreads[key] then    -- Check if runningThreads[key] is null or not
        runningThreads[key]:Disconnect()    -- Disconnect runningThreads[key]
        runningThreads[key] = nil    -- Initialize runningThreads[key] variable
    end
end

function BossService:BindPlayerThread(player, thread)    -- Defining function "BindPlayerThread"
    local key = tostring(player.UserId)    -- Initialize key variable
    runningThreads[key] = thread    -- Initialize runningThreads[key] variable
end
function BossService.new(player)    -- Defining the function "new" of "BossService"
    BossService:CleanPlayerThread(player)    -- Clean up the thread for the player
    local new = {}    -- Create a new table "new"
    new.bosses = {}    -- Create a table "bosses" in table "new"

    local PlayerData = require(game.ServerScriptService.PlayerData)    -- Assign "PlayerData" table to "PlayerData" variable

    function new:AddBoss(name, initialState)    -- Define a function to add boss
        local boss = Boss.new(name, initialState)    -- Create a new boss
        self.bosses[name] = boss    -- Add the boss to "bosses" table
        return boss    -- Return the boss
    end
    
    function new:GetBoss(name)    -- Define a function to get a specific boss from the table
        return self.bosses[name]    -- Return the boss
    end
    
    function new:Tick()    -- Define a function "Tick" to perform some actions
        for name, boss in pairs(self.bosses) do    -- Loop through the bosses
           if boss.humanoid.Health <= 0 then    -- Check if the health of the boss is less than or equal to 0
            self.bosses[name] = nil    -- Set the boss to nil
            PlayerData:DefeatBoss(player, boss.character.Name)    -- Player has defeated the boss
            
            local explode = Instance.new("Explosion")    -- Create a new explosion
            explode.BlastPressure = 0    -- Set blast pressure to 0
            explode.Position = boss.character.PrimaryPart.Position    -- Set the position of the explosion to the position of the player
            explode.Parent = workspace    -- Set the parent of the explosion to workspace
            
            boss.character:Destroy()    -- Destroy the character of the boss
            
           else    -- else body if health of boss is not less than or equal to 0
            boss:Action()    -- Perform the action of boss
           end    -- End the if-else block
        end    -- End the loop
    end

    function new:SummonBoss(boss)    -- Define a function "SummonBoss"
        bosses[boss.Name](self, boss)    -- Call the function with the name of boss
    end

    local elapsed = 0    -- Initialize variable elapsed to 0
    new.heartbeat = RunService.Heartbeat:Connect(function(dt)    -- Call function when heartbeat is triggered
        --add a cleanup to this    -- Add a cleanup to the heartbeat
        elapsed += dt    -- Increment elapsed by dt
        if elapsed > 0.5 then    -- Check if elapsed is greater than 0.5
            elapsed = 0    -- Set elapsed to 0
            new:Tick()    -- Call "Tick" function
        end
    end)

    BossService:BindPlayerThread(player, new.heartbeat)    -- Bind the player thread to boss service

    return new    -- Return "new"
end

Players.PlayerRemoving:Connect(function(player)    -- Call the function when player is removed
    BossService:CleanPlayerThread(player)    -- Clean the player thread
end)

return BossService    -- Return "BossService"
