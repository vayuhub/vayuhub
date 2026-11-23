-- Blox Fruits Auto Chest + Mod Menu
-- Executor script (Delta/Solara/Xeno/Fluxus etc.)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local getgenv = getgenv or function() return _G end

--================ CONFIG ================--
local Config = {
    TweenSpeed = 310,          -- studs/sec, safe max for Blox Fruits anti-cheat (no rubberband)
    TeleportSpeed = 315,      -- manual teleport buttons safe speed (no rollback)
    ChestOpenWait = 0.4,       -- wait after reaching chest
    AfterChestWait = 0.5,      -- wait before next chest
    NoChestWait = 2.5,         -- wait before server hop when no chest found
    IslandCheckWait = 0.8,     -- wait after moving to island anchor
    LongDistance = 600,        -- isse zyada door ho toh fast travel (far chest)
    ProbeDistance = 700,       -- island anchor ke around itne studs check karega
    AnchorMergeDistance = 700, -- isse kam door wali location ko duplicate maanega
    ProbeSpeed = 310,          -- island probe tween speed (safe = anti-cheat safe)
    FarTravelSpeed = 315,      -- bahut door ke chest tak ki max tween speed (anti-cheat safe)
    ChestArriveDistance = 120, -- itne se zyada door ho toh chest claim skip (retry allowed)
    MaxChestAttempts = 2,      -- ek chest ko max itni baar try karega
    FarmButtonName = "Auto Chest Farm",
    MinServerHours = 4,        -- server hop sirf itne ghante purane (4h+) servers pe karega
    MaxHopAttempts = 12,       -- itne failed hops ke baad current server pe hi farm (no infinite hop)
    AutoHopInterval = 60,      -- auto server hop har itne seconds
    HopRetryDelay = 4,         -- teleport fail ho toh itne seconds mein retry
    MaxAutoHops = 34,          -- auto hop ka total limit
    AutoHopSessionReset = 2700,-- itne seconds baad hop counter reset (naya session)
}

--================ TARGET ITEMS ================--
local TargetItems = {
    ["Fist of Darkness"] = true,
    ["God's Chalice"] = true,
    ["Gods Chalice"] = true,
}

--================ SEA / PLACE IDS ================--
local SeaByPlace = {
    [2753915549] = 1,
    [4442272183] = 2,
    [7449423635] = 3,
    [85211729168715] = 1,
    [79091703265657] = 2,
    [100117331123089] = 3,
}
local TravelRemote = {
    [1] = "TravelMain",
    [2] = "TravelDressrosa",
    [3] = "TravelZou",
}

--================ COORDINATES (from public scripts/wiki) ================--
local DarkArenaCF = CFrame.new(3464.7700195313, 13.375151634216, -3368.90234375) -- Dark Area / Dark Arena island (Sea 2)
local CastleOnSeaCF = CFrame.new(-5498.0458984375, 313.79473876953, -2860.6022949219)
local HotAndColdCF = CFrame.new(-5600, 80, -5100) -- Hot and Cold island (Secret Laboratory / FOD)

local SafeZones = {
    [1] = {
        { Name = "Pirate Starter", CFrame = CFrame.new(979.79895019531, 16.516613006592, 1429.0466308594) },
        { Name = "Marine Starter", CFrame = CFrame.new(-2566.4296875, 6.8556680679321, 2045.2561035156) },
    },
    [2] = {
        { Name = "Cafe", CFrame = CFrame.new(-380.47927856445, 77.220390319824, 255.82550048828) },
    },
    [3] = {
        { Name = "Port Town Docks", CFrame = CFrame.new(-290.7376708984375, 6.729952812194824, 5343.5537109375) },
        { Name = "Castle on the Sea", CFrame = CastleOnSeaCF },
    },
}

local IslandRoutes = {
    [1] = {
        { Name = "WindMill", CFrame = CFrame.new(979.79895019531, 16.516613006592, 1429.0466308594) },
        { Name = "Marine", CFrame = CFrame.new(-2566.4296875, 6.8556680679321, 2045.2561035156) },
        { Name = "Middle Town", CFrame = CFrame.new(-690.33081054688, 15.09425163269, 1582.2380371094) },
        { Name = "Jungle", CFrame = CFrame.new(-1612.7957763672, 36.852081298828, 149.12843322754) },
        { Name = "Pirate Village", CFrame = CFrame.new(-1181.3093261719, 4.7514905929565, 3803.5456542969) },
        { Name = "Desert", CFrame = CFrame.new(944.15789794922, 20.919729232788, 4373.3002929688) },
        { Name = "Snow Island", CFrame = CFrame.new(1347.8067626953, 104.66806030273, -1319.7370605469) },
        { Name = "MarineFord", CFrame = CFrame.new(-4914.8212890625, 50.963626861572, 4281.0278320313) },
        { Name = "Colosseum", CFrame = CFrame.new(-1427.6203613281, 7.2881078720093, -2792.7722167969) },
        { Name = "Sky Island 1", CFrame = CFrame.new(-4869.1025390625, 733.46051025391, -2667.0180664063) },
        { Name = "Prison", CFrame = CFrame.new(4875.330078125, 5.6519818305969, 734.85021972656) },
        { Name = "Magma Village", CFrame = CFrame.new(-5247.7163085938, 12.883934020996, 8504.96875) },
        { Name = "Fountain City", CFrame = CFrame.new(5127.1284179688, 59.501365661621, 4105.4458007813) },
        { Name = "Mob Island", CFrame = CFrame.new(-2850.20068, 7.39224768, 5354.99268) },
    },
    [2] = {
        { Name = "The Cafe", CFrame = CFrame.new(-380.47927856445, 77.220390319824, 255.82550048828) },
        { Name = "Frist Spot", CFrame = CFrame.new(-11.311455726624, 29.276733398438, 2771.5224609375) },
        { Name = "Dark Arena", CFrame = DarkArenaCF },
        { Name = "Flamingo Mansion", CFrame = CFrame.new(-483.73370361328, 332.0383605957, 595.32708740234) },
        { Name = "Flamingo Room", CFrame = CFrame.new(2284.4140625, 15.152037620544, 875.72534179688) },
        { Name = "Green Zone", CFrame = CFrame.new(-2448.5300292969, 73.016105651855, -3210.6306152344) },
        { Name = "Hot and Cold", CFrame = HotAndColdCF },
        { Name = "Factory", CFrame = CFrame.new(424.12698364258, 211.16171264648, -427.54049682617) },
        { Name = "Colosseum", CFrame = CFrame.new(-1503.6224365234, 219.7956237793, 1369.3101806641) },
        { Name = "Zombie Island", CFrame = CFrame.new(-5622.033203125, 492.19604492188, -781.78552246094) },
        { Name = "Two Snow Mountain", CFrame = CFrame.new(753.14288330078, 408.23559570313, -5274.6147460938) },
        { Name = "Punk Hazard", CFrame = CFrame.new(-6127.654296875, 15.951762199402, -5040.2861328125) },
        { Name = "Ice Castle", CFrame = CFrame.new(6148.4116210938, 294.38687133789, -6741.1166992188) },
        { Name = "Forgotten Island", CFrame = CFrame.new(-3032.7641601563, 317.89672851563, -10075.373046875) },
        { Name = "Ussop Island", CFrame = CFrame.new(4816.8618164063, 8.4599885940552, 2863.8195800781) },
    },
    [3] = {
        { Name = "Port Town", CFrame = CFrame.new(-290.7376708984375, 6.729952812194824, 5343.5537109375) },
        { Name = "Great Tree", CFrame = CFrame.new(2681.2736816406, 1682.8092041016, -7190.9853515625) },
        { Name = "Castle on the Sea", CFrame = CastleOnSeaCF },
        { Name = "Hydra Island", CFrame = CFrame.new(5228.8842773438, 604.23400878906, 345.0400390625) },
        { Name = "Floating Turtle", CFrame = CFrame.new(-13274.528320313, 531.82073974609, -7579.22265625) },
        { Name = "Mansion", CFrame = CFrame.new(-12471.169921875, 374.94024658203, -7551.677734375) },
        { Name = "Haunted Castle", CFrame = CFrame.new(-9515.3720703125, 164.00624084473, 5786.0610351562) },
        { Name = "Ice Cream Island", CFrame = CFrame.new(-902.56817626953, 79.93204498291, -10988.84765625) },
        { Name = "Peanut Island", CFrame = CFrame.new(-2062.7475585938, 50.473892211914, -10232.568359375) },
        { Name = "Cake Island", CFrame = CFrame.new(-1884.7747802734375, 19.327526092529297, -11666.8974609375) },
        { Name = "Noname Island", CFrame = CFrame.new(231.742981, 25.3354111, -12199.0537) },
    },
}

--================ PROBE POINTS (9 per island: center + 3x3 grid) ================--
local D = Config.ProbeDistance
local ProbeOffsets = {
    Vector3.new(0, 0, 0),
    Vector3.new(D, 0, 0),
    Vector3.new(-D, 0, 0),
    Vector3.new(0, 0, D),
    Vector3.new(0, 0, -D),
    Vector3.new(D, 0, D),
    Vector3.new(-D, 0, D),
    Vector3.new(D, 0, -D),
    Vector3.new(-D, 0, -D),
}

--================ STATE ================--
local farming = false
local visitedChests = {}
local chestAttempts = {}
local islandAnchors = {}
local islandIndex = 1
local probeIndex = 1
local islandTourDone = false
local activeTween = nil
local statusLabel = nil
local farmButton = nil
local serverAgeLabel = nil

--================ HELPERS ================--
local function getHRP()
    local char = Player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function currentSea()
    return SeaByPlace[game.PlaceId]
end

local function updateStatus(text)
    if statusLabel then
        statusLabel.Text = text
    end
end

local function notify(text)
    updateStatus(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Blox Fruits Mod",
            Text = text,
            Duration = 3,
        })
    end)
end

local probeAnchorPrev = nil
local function setProbeAnchor(state)
    local hrp = getHRP()
    if not hrp then return end
    if state then
        if probeAnchorPrev == nil then
            probeAnchorPrev = hrp.Anchored
        end
        hrp.Anchored = true
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    else
        if probeAnchorPrev ~= nil then
            hrp.Anchored = probeAnchorPrev
            probeAnchorPrev = nil
        else
            hrp.Anchored = false
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
end

local function hasTargetItem()
    local containers = { Player.Backpack, Player.Character }
    for _, container in ipairs(containers) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if TargetItems[item.Name] then
                    return item.Name
                end
            end
        end
    end
    return nil
end

local function stopFarmForItem(itemName)
    farming = false
    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end
    setProbeAnchor(false)
    if farmButton then
        farmButton.Text = "Auto Chest Farm: OFF"
        farmButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
    notify("Got " .. itemName .. " - chest farm stopped, going safe zone")
    task.spawn(function()
        task.wait(0.4)
        local cf = nearestSafeZoneCF()
        if cf then
            warpTo(cf.CFrame + Vector3.new(0, 8, 0))
            notify("Safe zone: " .. cf.Name)
        end
    end)
end

local function stopFarmForTeleport()
    farming = false
    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end
    setProbeAnchor(false)
    if farmButton then
        farmButton.Text = "Auto Chest Farm: OFF"
        farmButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
end

local function isChestName(name)
    return name:lower():find("chest", 1, true) ~= nil
end

local function isExactChestName(name)
    return name:lower():match("^chest%d+$") ~= nil
end

local function hasChestInteraction(obj)
    if not obj:IsA("BasePart") then return false end
    return obj:FindFirstChild("TouchInterest") ~= nil
        or obj:FindFirstChildOfClass("ClickDetector") ~= nil
        or obj:FindFirstChildOfClass("ProximityPrompt") ~= nil
end

local function instanceHasChestInteraction(root)
    if hasChestInteraction(root) then return true end
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then
            return true
        end
        if hasChestInteraction(d) then
            return true
        end
    end
    return false
end

local function isChestTriggerPart(obj)
    return obj:IsA("BasePart") and isChestName(obj.Name) and hasChestInteraction(obj)
end

local function getChestPart(chest)
    if chest:IsA("BasePart") then
        return chest
    end
    if chest:IsA("Model") then
        for _, d in ipairs(chest:GetDescendants()) do
            if hasChestInteraction(d) then
                return d
            end
        end
        if chest.PrimaryPart then
            return chest.PrimaryPart
        end
        for _, d in ipairs(chest:GetDescendants()) do
            if d:IsA("BasePart") then
                return d
            end
        end
    end
    return nil
end

local function getChestCFrame(chest)
    local part = getChestPart(chest)
    if part then
        return part.CFrame + Vector3.new(0, 3, 0)
    end
    if chest:IsA("Model") then
        local ok, piv = pcall(function() return chest:GetPivot() end)
        if ok and piv then
            return piv + Vector3.new(0, 3, 0)
        end
    end
    return nil
end

local function getChests()
    local chests = {}
    local seen = {}
    local chestModels = Workspace:FindFirstChild("ChestModels")

    local function inChestModels(inst)
        if chestModels ~= nil and inst:IsDescendantOf(chestModels) then return true end
        local p = inst.Parent
        while p and p ~= Workspace do
            local n = p.Name:lower()
            if n == "chestmodels" or n == "chests" or n == "chest" then
                return true
            end
            p = p.Parent
        end
        return false
    end

    local function add(obj)
        if not obj or seen[obj] or visitedChests[obj] then return end
        if not getChestPart(obj) then return end
        seen[obj] = true
        table.insert(chests, obj)
    end

    -- Actual chest parts (Chest1/Chest2/Chest3 etc.) can be nested anywhere in Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isChestName(obj.Name) then
            if isExactChestName(obj.Name) or hasChestInteraction(obj) then
                add(obj)
            end
        elseif obj:IsA("Model") and isChestName(obj.Name) then
            local triggerCount = 0
            for _, d in ipairs(obj:GetDescendants()) do
                if isChestTriggerPart(d) then
                    triggerCount += 1
                end
            end
            if triggerCount <= 1 and (inChestModels(obj) or instanceHasChestInteraction(obj)) then
                add(obj)
            end
        end
    end

    -- Same chest ke model/part duplicates ko position se merge karo, trigger part prefer karo
    local function score(obj)
        if obj:IsA("BasePart") then return 3 end
        if instanceHasChestInteraction(obj) then return 2 end
        return 1
    end

    table.sort(chests, function(a, b)
        local sa, sb = score(a), score(b)
        if sa ~= sb then return sa > sb end
        return tostring(a) < tostring(b)
    end)

    local deduped = {}
    for _, obj in ipairs(chests) do
        local cf = getChestCFrame(obj)
        local duplicate = false
        if cf then
            for _, kept in ipairs(deduped) do
                local kcf = getChestCFrame(kept)
                if kcf and (cf.Position - kcf.Position).Magnitude <= 30 then
                    duplicate = true
                    break
                end
            end
        end
        if not duplicate then
            table.insert(deduped, obj)
        end
    end

    return deduped
end

local function getNearestChest()
    local hrp = getHRP()
    if not hrp then return nil end
    local chests = getChests()
    local nearest, best = nil, math.huge
    for _, chest in ipairs(chests) do
        local cf = getChestCFrame(chest)
        if cf then
            local dist = (hrp.Position - cf.Position).Magnitude
            if dist < best then
                best = dist
                nearest = chest
            end
        end
    end
    return nearest
end

local noclipConnection = nil
local function setNoclip(state)
    if state then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = Player.Character
                if char then
                    for _, d in ipairs(char:GetDescendants()) do
                        if d:IsA("BasePart") and d.CanCollide then
                            d.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = Player.Character
        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                    d.CanCollide = true
                end
            end
        end
    end
end

local function tweenTo(cf, speed, mustFinish)
    local hrp = getHRP()
    if not hrp or not cf then return false end
    local dist = (hrp.Position - cf.Position).Magnitude
    if dist < 4 then return true end
    if dist > Config.LongDistance and not mustFinish then
        updateStatus("Long distance: " .. math.floor(dist) .. " studs")
    end

    setNoclip(true)

    -- Blox Fruits safe speed limit (315 studs/s max to prevent 1-3s rubberband / rollback)
    local safeSpeed = math.clamp(speed or Config.TweenSpeed, 120, 315)
    local duration = math.max(dist / safeSpeed, 0.1)

    if activeTween then
        pcall(function() activeTween:Cancel() end)
    end

    -- Anti-gravity helper: holds player steady so server physics does not desync in air
    local bv = hrp:FindFirstChild("BF_AntiFall")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "BF_AntiFall"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
    end

    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        CFrame = cf,
    })
    activeTween = tween
    tween:Play()

    local finished = false
    local completedOk = false
    local conn
    conn = tween.Completed:Connect(function(state)
        finished = true
        completedOk = (state == Enum.PlaybackState.Completed)
        if conn then conn:Disconnect() end
    end)

    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    while not finished do
        -- Anti-cheat bypass: maintain Swimming state and zero out velocity while flying in air
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
        end

        if not mustFinish then
            if hasTargetItem() then
                pcall(function() tween:Cancel() end)
                break
            end
            if not farming then
                break
            end
        end
        if not hrp or not hrp.Parent then break end
        task.wait(0.05)
    end

    if activeTween == tween then
        activeTween = nil
    end

    local antiFall = hrp and hrp:FindFirstChild("BF_AntiFall")
    if antiFall then
        antiFall:Destroy()
    end
    if hrp and hrp.Parent then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    setNoclip(false)
    return finished and completedOk and (mustFinish or farming)
end

local function travelToCF(cf)
    local hrp = getHRP()
    if not hrp or not cf then return false end
    local dist = (hrp.Position - cf.Position).Magnitude
    if dist < 4 then return true end

    if dist > Config.LongDistance then
        updateStatus("Traveling far: " .. math.floor(dist) .. " studs")
        local speed = math.clamp(Config.TweenSpeed, 200, Config.FarTravelSpeed)
        tweenTo(cf, speed, true)
        task.wait(0.15)
        return farming
    end

    return tweenTo(cf)
end

local function teleportToCF(cf)
    local hrp = getHRP()
    if not hrp or not cf then return false end
    local startPos = hrp.Position
    local destPos = cf.Position
    if (startPos - destPos).Magnitude < 5 then return true end

    setProbeAnchor(false)
    updateStatus("Teleporting...")

    -- Smart altitude: safe height above ocean/obstacles (no excessive climb, smooth travel)
    local cruiseY = math.clamp(math.max(startPos.Y, destPos.Y) + 80, 120, 280)
    local ok = tweenTo(CFrame.new(startPos.X, cruiseY, startPos.Z), Config.TeleportSpeed, true)
    if ok then
        ok = tweenTo(CFrame.new(destPos.X, cruiseY, destPos.Z), Config.TeleportSpeed, true)
    end
    if ok then
        ok = tweenTo(cf, Config.TeleportSpeed, true)
    end
    return ok
end

local function openChest(chest)
    local hrp = getHRP()
    local part = getChestPart(chest)
    if hrp and part then
        pcall(function()
            if firetouchinterest then
                firetouchinterest(hrp, part, 0)
                firetouchinterest(part, hrp, 0)
            end
        end)
    end
    pcall(function()
        for _, d in ipairs(chest:GetDescendants()) do
            if d:IsA("ClickDetector") then
                pcall(function() fireclickdetector(d) end)
            elseif d:IsA("ProximityPrompt") then
                pcall(function() fireproximityprompt(d) end)
            end
        end
    end)
    task.wait(Config.ChestOpenWait)
end

local function refreshIslandAnchors()
    islandAnchors = {}
    local sea = currentSea()
    local hrp = getHRP()

    -- Pehle current sea ke known island routes use karo (saare islands cover hote hain)
    if sea and IslandRoutes[sea] then
        for _, a in ipairs(IslandRoutes[sea]) do
            table.insert(islandAnchors, { Name = a.Name, CFrame = a.CFrame })
        end
    end

    -- _WorldOrigin.Locations se sirf wo anchors add karo jo known islands se door hain
    local locations = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
    if locations then
        for _, child in ipairs(locations:GetChildren()) do
            local cf = nil
            if child:IsA("BasePart") then
                cf = child.CFrame
            elseif child:IsA("Model") then
                local ok, piv = pcall(function() return child:GetPivot() end)
                if ok then cf = piv end
            else
                for _, d in ipairs(child:GetDescendants()) do
                    if d:IsA("Model") then
                        local ok, piv = pcall(function() return d:GetPivot() end)
                        if ok and piv then
                            cf = piv
                            break
                        end
                    end
                end
                if not cf then
                    for _, d in ipairs(child:GetDescendants()) do
                        if d:IsA("BasePart") then
                            cf = d.CFrame
                            break
                        end
                    end
                end
            end
            if cf then
                local isFar = true
                for _, ex in ipairs(islandAnchors) do
                    if (cf.Position - ex.CFrame.Position).Magnitude < Config.AnchorMergeDistance then
                        isFar = false
                        break
                    end
                end
                if isFar then
                    table.insert(islandAnchors, { Name = child.Name, CFrame = cf })
                end
            end
        end
    end

    if hrp and #islandAnchors > 0 then
        table.sort(islandAnchors, function(a, b)
            return (hrp.Position - a.CFrame.Position).Magnitude < (hrp.Position - b.CFrame.Position).Magnitude
        end)
    end

    islandIndex = 1
    probeIndex = 1
    islandTourDone = false
end

local function getNextProbe()
    if #islandAnchors == 0 then
        refreshIslandAnchors()
    end
    if #islandAnchors == 0 then
        return nil
    end

    local island = islandAnchors[islandIndex]
    local off = ProbeOffsets[probeIndex]
    local label = island.Name .. " probe " .. probeIndex

    probeIndex += 1
    if probeIndex > #ProbeOffsets then
        probeIndex = 1
        islandIndex += 1
        if islandIndex > #islandAnchors then
            islandIndex = 1
            islandTourDone = true
        end
    end

    return CFrame.new(island.CFrame.Position + Vector3.new(off.X, 35, off.Z)), label
end

local function chestFarmLoop()
    refreshIslandAnchors()
    while farming do
        local item = hasTargetItem()
        if item then
            stopFarmForItem(item)
            break
        end

        local chest = getNearestChest()
        if chest then
            local cf = getChestCFrame(chest)
            if cf then
                updateStatus("Chest: " .. chest.Name)
                setProbeAnchor(false)
                travelToCF(cf)
                -- Agar travel ke baad bhi chest ke paas nahi pahunche toh retry counter badhao
                local hrp = getHRP()
                local dist = hrp and (hrp.Position - cf.Position).Magnitude or math.huge
                if dist > Config.ChestArriveDistance then
                    chestAttempts[chest] = (chestAttempts[chest] or 0) + 1
                    if chestAttempts[chest] >= Config.MaxChestAttempts then
                        visitedChests[chest] = true -- baar-baar fail ho toh skip
                    end
                    task.wait(0.3)
                else
                    visitedChests[chest] = true
                    chestAttempts[chest] = nil
                    if hasTargetItem() then
                        local got = hasTargetItem()
                        stopFarmForItem(got)
                        break
                    end
                    openChest(chest)
                    task.wait(Config.AfterChestWait)
                end
            else
                visitedChests[chest] = true -- CFrame nahi mila, dobara try mat karo
            end
        else
            if islandTourDone then
                updateStatus("No chests in server - hopping")
                task.wait(Config.NoChestWait)
                serverHop()
                break
            end

            local probeCF, probeName = getNextProbe()
            if probeCF then
                updateStatus("Checking: " .. probeName)
                -- Island/probe ke liye fast tween - instant warp anti-cheat reset kar deta hai.
                -- Probe ke time anchor rakho taaki paani/void mein girkar na mare.
                tweenTo(probeCF, Config.ProbeSpeed, true)
                setProbeAnchor(true)
                task.wait(Config.IslandCheckWait)
            else
                updateStatus("No island anchors - hopping")
                task.wait(Config.NoChestWait)
                serverHop()
                break
            end
        end
    end
end

--================ TELEPORT HELPERS ================--
function warpTo(cf)
    local hrp = getHRP()
    if hrp and cf then
        hrp.CFrame = cf
    end
end

local function findLocationCF(names)
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local locations = origin and origin:FindFirstChild("Locations")
    if not locations then return nil end
    for _, candidate in ipairs(names) do
        for _, child in ipairs(locations:GetChildren()) do
            if child.Name:lower():find(candidate:lower()) then
                if child:IsA("BasePart") then
                    return CFrame.new(child.CFrame.Position + Vector3.new(0, 10, 0))
                elseif child:IsA("Model") then
                    local ok, piv = pcall(function() return child:GetPivot() end)
                    if ok and piv then return CFrame.new(piv.Position + Vector3.new(0, 10, 0)) end
                end
            end
        end
    end
    return nil
end

local function travelToSea(sea)
    local remoteName = TravelRemote[sea]
    if not remoteName then return end
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer(remoteName)
    end)
    task.wait(2.5)
end

local function teleportDarkArena()
    stopFarmForTeleport()
    updateStatus("Teleporting to Dark Arena...")
    if currentSea() ~= 2 then
        travelToSea(2)
        if currentSea() ~= 2 then
            updateStatus("Could not travel to Sea 2")
            return
        end
    end
    local cf = findLocationCF({ "Dark Area", "Dark Arena", "DarkArea" }) or DarkArenaCF
    teleportToCF(cf)
    notify("Teleported to Dark Arena")
end

local function teleportCastleOnSea()
    stopFarmForTeleport()
    updateStatus("Teleporting to Castle on the Sea...")
    if currentSea() ~= 3 then
        travelToSea(3)
        if currentSea() ~= 3 then
            updateStatus("Could not travel to Sea 3")
            return
        end
    end
    local cf = findLocationCF({ "Castle on the Sea", "Castle On The Sea", "Sea Castle", "CastleOnTheSea" }) or CastleOnSeaCF
    teleportToCF(cf)
    notify("Teleported to Castle on the Sea")
end

function nearestSafeZoneCF()
    local sea = currentSea()
    local zones = sea and SafeZones[sea]
    local hrp = getHRP()
    if not zones or not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, zone in ipairs(zones) do
        local dist = (hrp.Position - zone.CFrame.Position).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = zone
        end
    end
    return best
end

local function teleportSafeZone()
    stopFarmForTeleport()
    local zone = nearestSafeZoneCF()
    if zone then
        teleportToCF(CFrame.new(zone.CFrame.Position + Vector3.new(0, 8, 0)))
        notify("Safe zone: " .. zone.Name)
    else
        notify("No safe zone found for this sea")
    end
end

--================ 4H+ SERVER HOP ================--
local HOP_MARKER_FILE = "bf_4h_server_hop.txt"
local HOP_MARKER_MAX_AGE = 900 -- marker 15 min se purana ho toh ignore (stale hop na chale)

local function getServerUptimeSeconds()
    local ok, t = pcall(function() return Workspace.DistributedGameTime end)
    if ok and type(t) == "number" then return t end
    return 0
end

local function formatUptime(seconds)
    seconds = math.floor(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%dh %dm %ds", h, m, s)
    elseif m > 0 then
        return string.format("%dm %ds", m, s)
    end
    return string.format("%ds", s)
end

-- Naye server pe character load hone ka wait karta hai (restricted area se bachne ke liye)
local function waitForCharacter(timeout)
    local elapsed = 0
    while elapsed < (timeout or 20) do
        if game:IsLoaded() and getHRP() then
            return true
        end
        task.wait(0.5)
        elapsed += 0.5
    end
    return game:IsLoaded() and getHRP() ~= nil
end

--================ SERVER AGE ESTIMATE ================--
-- Roblox client ko true server uptime nahi deta (DistributedGameTime = join time).
-- Isliye best estimate: JobId first-seen (persisted) + replicated start-time scan + join time.
local SERVER_SEEN_FILE = "bf_server_firstseen.txt"
local serverSeenCache = nil

local function loadServerSeen()
    if serverSeenCache then return serverSeenCache end
    serverSeenCache = {}
    pcall(function()
        if readfile and isfile and isfile(SERVER_SEEN_FILE) then
            for line in tostring(readfile(SERVER_SEEN_FILE)):gmatch("[^\r\n]+") do
                local id, ts = line:match("([^|]+)|(%d+)")
                if id and ts then
                    serverSeenCache[id] = tonumber(ts)
                end
            end
        end
    end)
    return serverSeenCache
end

local function recordServerSeen()
    local seen = loadServerSeen()
    local jobId = game.JobId
    if jobId == "" or seen[jobId] then return end
    seen[jobId] = os.time()
    pcall(function()
        if writefile then
            local lines = {}
            for id, ts in pairs(seen) do
                table.insert(lines, id .. "|" .. tostring(ts))
            end
            if #lines > 300 then
                table.sort(lines, function(a, b)
                    return tonumber(a:match("|(%d+)$")) > tonumber(b:match("|(%d+)$"))
                end)
                local trimmed = {}
                for i = 1, 300 do trimmed[i] = lines[i] end
                lines = trimmed
            end
            writefile(SERVER_SEEN_FILE, table.concat(lines, "\n"))
        end
    end)
end

local replicatedStartCache = nil
local function getReplicatedServerStart()
    if replicatedStartCache ~= nil then return replicatedStartCache end
    replicatedStartCache = false
    local now = os.time()
    local function plausible(v)
        return type(v) == "number" and v > 1.6e9 and v <= now + 60
            and (now - v) > 0 and (now - v) < 45 * 86400
    end
    local function checkAttrs(inst)
        local ok, attrs = pcall(function() return inst:GetAttributes() end)
        if ok and type(attrs) == "table" then
            for k, v in pairs(attrs) do
                local kl = tostring(k):lower()
                if plausible(v) and (kl:find("start") or kl:find("time") or kl:find("age") or kl:find("creat") or kl:find("boot") or kl:find("launch")) then
                    return v
                end
            end
        end
        return nil
    end
    local function checkValue(inst)
        if inst:IsA("NumberValue") or inst:IsA("IntValue") then
            local nl = inst.Name:lower()
            if plausible(inst.Value) and (nl:find("start") or nl:find("time") or nl:find("age") or nl:find("creat") or nl:find("boot") or nl:find("launch")) then
                return inst.Value
            end
        end
        return nil
    end
    local roots = { game, Workspace, ReplicatedStorage }
    local scanned = 0
    for _, root in ipairs(roots) do
        local s = checkAttrs(root)
        if s then replicatedStartCache = s return s end
        for _, child in ipairs(root:GetChildren()) do
            scanned += 1
            if scanned > 4000 then break end
            local v = checkAttrs(child) or checkValue(child)
            if v then replicatedStartCache = v return v end
        end
        if scanned > 4000 then break end
    end
    return false
end

local function getEstimatedServerAge()
    recordServerSeen()
    local best = getServerUptimeSeconds() -- join time (lower bound)
    local seen = loadServerSeen()
    local firstSeen = seen[game.JobId]
    if firstSeen then
        best = math.max(best, os.time() - firstSeen)
    end
    local rsStart = getReplicatedServerStart()
    if rsStart then
        best = math.max(best, os.time() - rsStart)
    end
    return best
end

local pendingHopCount = 0

-- Marker format: timestamp|farmFlag|hopCount|mode ("a" = any-server auto hop, no age check)
local function writeHopMarker(farmFlag, mode)
    pcall(function()
        if writefile then
            writefile(HOP_MARKER_FILE, tostring(os.time()) .. "|" .. (farmFlag and "1" or "0") .. "|" .. tostring(pendingHopCount) .. "|" .. (mode or ""))
        end
    end)
    pendingHopCount = 0
end

local function clearHopMarker()
    pcall(function()
        if delfile and isfile and isfile(HOP_MARKER_FILE) then
            delfile(HOP_MARKER_FILE)
        elseif writefile then
            writefile(HOP_MARKER_FILE, "")
        end
    end)
end

local function startChestFarm()
    farming = true
    visitedChests = {}
    chestAttempts = {}
    islandTourDone = false
    islandIndex = 1
    probeIndex = 1
    if farmButton then
        farmButton.Text = "Auto Chest Farm: ON"
        farmButton.BackgroundColor3 = Color3.fromRGB(60, 200, 90)
    end
    updateStatus("Chest farm started")
    task.spawn(chestFarmLoop)
end

--================ SERVER HOP ================--
local function httpGet(url)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok, res = pcall(function() return req({ Url = url, Method = "GET" }) end)
        if ok and res and res.Body then return res.Body end
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and body then return body end
    return nil
end

--================ SERVER HOP (FIXED FOR 773 & RESTRICTED SUB-PLACES) ================--
local VISITED_SERVERS_FILE = "bf_visited_servers.txt"
local visitedServers = {}
local isHopping = false

local function loadVisitedServers()
    pcall(function()
        if readfile and isfile and isfile(VISITED_SERVERS_FILE) then
            for line in tostring(readfile(VISITED_SERVERS_FILE)):gmatch("[^\r\n]+") do
                local id, ts = line:match("([^|]+)|?(%d*)")
                if id and id ~= "" then
                    local t = tonumber(ts) or 0
                    -- 20 minutes ke liye cache rakho
                    if os.time() - t < 1200 then
                        visitedServers[id] = true
                    end
                end
            end
        end
    end)
    visitedServers[game.JobId] = true
end

local function recordVisitedServer(jobId)
    visitedServers[jobId] = true
    pcall(function()
        if writefile then
            local lines = {}
            for id, _ in pairs(visitedServers) do
                table.insert(lines, id .. "|" .. tostring(os.time()))
            end
            writefile(VISITED_SERVERS_FILE, table.concat(lines, "\n"))
        end
    end)
end

local function fetchAvailableServers()
    loadVisitedServers()
    local servers = {}
    local placeIdStr = tostring(game.PlaceId) -- tostring used to avoid 32-bit integer overflow on large Place IDs

    -- Try Ascending first (avoids full servers, checks for healthy servers with open slots)
    local sortModes = { "Asc", "Desc" }
    for _, sortMode in ipairs(sortModes) do
        local cursor = nil
        local guard = 0
        repeat
            guard += 1
            local url = "https://games.roblox.com/v1/games/" .. placeIdStr .. "/servers/Public?sortOrder=" .. sortMode .. "&limit=100"
            if cursor and cursor ~= "null" and cursor ~= "" then
                url = url .. "&cursor=" .. tostring(cursor)
            end

            local body = httpGet(url)
            if not body then break end

            local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
            if not ok or not data or not data.data then break end

            for _, s in ipairs(data.data) do
                local sid = tostring(s.id)
                local playing = tonumber(s.playing) or 0
                local max = tonumber(s.maxPlayers) or 12

                -- ANTI-773 RULES:
                -- 1. Never current server
                -- 2. At least 3 players (1-2 player servers are often shutting down or restricted instances)
                -- 3. Room for at least 2 players (playing <= max - 2) so server is not full
                -- 4. Not in recently failed/visited blacklist
                if sid ~= game.JobId and not visitedServers[sid] then
                    if playing >= 3 and playing <= (max - 2) then
                        table.insert(servers, sid)
                    end
                end
                if #servers >= 30 then break end
            end

            cursor = data.nextPageCursor
        until not cursor or cursor == "null" or #servers >= 30 or guard >= 3

        if #servers >= 5 then break end
    end

    -- Fallback: Relaxed filter if no server matched strict conditions
    if #servers == 0 then
        local url = "https://games.roblox.com/v1/games/" .. placeIdStr .. "/servers/Public?sortOrder=Desc&limit=100"
        local body = httpGet(url)
        if body then
            local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
            if ok and data and data.data then
                for _, s in ipairs(data.data) do
                    local sid = tostring(s.id)
                    local playing = tonumber(s.playing) or 0
                    local max = tonumber(s.maxPlayers) or 12
                    if sid ~= game.JobId and not visitedServers[sid] then
                        if playing >= 2 and playing < max then
                            table.insert(servers, sid)
                        end
                    end
                    if #servers >= 20 then break end
                end
            end
        end
    end

    if #servers == 0 then
        visitedServers = { [game.JobId] = true }
    end

    return servers
end

function serverHop(anyServer)
    if isHopping then return end
    isHopping = true

    local wasFarming = farming
    farming = false
    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end
    setNoclip(false)
    setProbeAnchor(false)
    if farmButton then
        farmButton.Text = "Auto Chest Farm: OFF"
        farmButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
    if anyServer then
        updateStatus("Auto hop: finding valid server...")
    else
        updateStatus("Hopping for " .. Config.MinServerHours .. "h+ server...")
    end

    -- Restricted area se bachne ke liye hop se pehle safe zone mein jao
    local hopZone = nearestSafeZoneCF()
    if hopZone then
        updateStatus("Safe zone before hop...")
        warpTo(hopZone.CFrame + Vector3.new(0, 8, 0))
        task.wait(0.8)
    end

    writeHopMarker(wasFarming, anyServer and "a" or "")

    local servers = fetchAvailableServers()
    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        recordVisitedServer(chosen)
        updateStatus("Teleporting to server " .. chosen:sub(1, 8) .. "...")

        -- Queue script for auto execution upon joining
        pcall(function()
            local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
            if qot then
                qot([[loadstring(game:HttpGet("https://raw.githubusercontent.com/vayuhub/vayuhub/main/BloxFruits_AutoChest.lua"))()]])
            end
        end)

        -- ALWAYS use TeleportToPlaceInstance with valid JobId (NEVER Teleport(game.PlaceId))
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen, Player)
        end)

        -- In case TeleportToPlaceInstance gets stuck/fails silently, retry after timeout
        local oldJob = game.JobId
        task.delay(7, function()
            if game.JobId == oldJob and getHRP() then
                isHopping = false
                updateStatus("Hop timed out - trying another server...")
                task.wait(1)
                serverHop(anyServer)
            end
        end)
    else
        isHopping = false
        updateStatus("Searching servers again in 4s...")
        task.delay(4, function()
            serverHop(anyServer)
        end)
    end
end

-- TeleportInitFailed hook (handles any rejected teleport and immediately switches server)
pcall(function()
    TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        if player == Player then
            isHopping = false
            warn("[ServerHop] Teleport failed (" .. tostring(teleportResult) .. "): " .. tostring(errorMessage))
            updateStatus("Hop failed (" .. tostring(teleportResult) .. ") - retrying...")
            task.delay(1.5, function()
                serverHop(true)
            end)
        end
    end)
end)

-- Anti-773 CoreGui ErrorPrompt Auto-Dismiss & Recovery
pcall(function()
    local rpg = CoreGui:FindFirstChild("RobloxPromptGui")
    local promptOverlay = rpg and rpg:FindFirstChild("promptOverlay")
    if not promptOverlay then
        task.spawn(function()
            local gui = CoreGui:WaitForChild("RobloxPromptGui", 10)
            if gui then
                local overlay = gui:WaitForChild("promptOverlay", 10)
                if overlay then
                    overlay.ChildAdded:Connect(function(child)
                        if child.Name == "ErrorPrompt" then
                            task.wait(0.3)
                            isHopping = false
                            updateStatus("Error 773 detected - auto switching server...")
                            local btn = child:FindFirstChild("Button", true) or child:FindFirstChild("ConfirmButton", true)
                            if btn then
                                pcall(function()
                                    local vim = game:GetService("VirtualInputManager")
                                    if vim then
                                        local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
                                        vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                                        task.wait(0.05)
                                        vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                                    end
                                end)
                            end
                            task.delay(1, function()
                                serverHop(true)
                            end)
                        end
                    end)
                end
            end
        end)
    end
end)

--================ AUTO SERVER HOP (har 60s, koi bhi server) ================--
local AUTO_HOP_FILE = "bf_auto_hop.txt"
local autoHopEnabled = true
local autoHopButton = nil

local function updateAutoHopButton()
    if autoHopButton then
        autoHopButton.Text = autoHopEnabled and "6. Auto Hop (60s): ON" or "6. Auto Hop (60s): OFF"
        autoHopButton.BackgroundColor3 = autoHopEnabled and Color3.fromRGB(60, 200, 90) or Color3.fromRGB(220, 60, 60)
    end
end

local function loadAutoHopState()
    local count, last = 0, 0
    pcall(function()
        if readfile and isfile and isfile(AUTO_HOP_FILE) then
            local c, l = tostring(readfile(AUTO_HOP_FILE)):match("(%d+)|?(%d*)")
            count = tonumber(c) or 0
            last = tonumber(l) or 0
        end
    end)
    -- Purana session ho toh counter reset
    if os.time() - last > Config.AutoHopSessionReset then
        count = 0
    end
    return count, last
end

local function saveAutoHopState(count, last)
    pcall(function()
        if writefile then
            writefile(AUTO_HOP_FILE, tostring(count) .. "|" .. tostring(last))
        end
    end)
end

local function autoHopLoop()
    local count, lastHop = loadAutoHopState()
    if lastHop == 0 then
        lastHop = os.time() -- fresh session: pehla hop 60s baad
    end
    while true do
        task.wait(1)
        if autoHopEnabled then
            local remain = Config.AutoHopInterval - (os.time() - lastHop)
            if remain <= 0 then
                if count >= Config.MaxAutoHops then
                    notify("Auto hop limit (" .. Config.MaxAutoHops .. ") reached - auto hop OFF")
                    updateStatus("Auto hop limit reached")
                    autoHopEnabled = false
                    updateAutoHopButton()
                else
                    count += 1
                    lastHop = os.time()
                    saveAutoHopState(count, lastHop)
                    updateStatus("Auto hop " .. count .. "/" .. Config.MaxAutoHops .. "...")
                    serverHop(true)
                end
            end
        end
    end
end

-- Naye server pe script re-run hone ke baad: agar hum 4h+ hop ke beech mein the
-- toh uptime check karo; kam hai toh dobara hop, 4h+ hai toh (chahiye toh) farm resume.
local function checkServerHopMarker()
    local data
    pcall(function()
        if readfile and isfile and isfile(HOP_MARKER_FILE) then
            data = readfile(HOP_MARKER_FILE)
        end
    end)
    if not data or data == "" then return end

    local parts = {}
    for part in tostring(data):gmatch("[^|]+") do
        table.insert(parts, part)
    end
    local ts = tonumber(parts[1])
    local farmFlag = parts[2]
    local hopCount = tonumber(parts[3]) or 0
    local mode = parts[4]
    if not ts or (os.time() - ts) > HOP_MARKER_MAX_AGE then
        clearHopMarker()
        return
    end

    task.spawn(function()
        -- Pehle character fully load hone do; warna hop ke turant baad warp karne se
        -- game "restricted area" bhej deta hai
        if not waitForCharacter(25) then
            updateStatus("Character not loaded yet - waiting...")
        end
        task.wait(1.5)

        -- Spawn point restricted/unsafe area mein ho sakta hai - safe zone mein land karo
        local zone = nearestSafeZoneCF()
        if zone and getHRP() then
            warpTo(zone.CFrame + Vector3.new(0, 8, 0))
            task.wait(0.8)
        end

        -- Auto-hop ("a" mode): kisi bhi server pe land kiya - age check skip, bas settle karke farm resume
        if mode == "a" then
            clearHopMarker()
            notify("Joined server (auto hop)")
            updateStatus("Server joined")
            if farmFlag == "1" then
                task.delay(5, function()
                    if waitForCharacter(10) then
                        startChestFarm()
                    end
                end)
            end
            return
        end

        local age = getEstimatedServerAge()
        local minUptime = Config.MinServerHours * 3600
        if age >= minUptime or hopCount >= Config.MaxHopAttempts then
            clearHopMarker()
            if hopCount >= Config.MaxHopAttempts and age < minUptime then
                notify("Hop limit - is server pe farm kar rahe hain")
                updateStatus("Hop limit reached - farming here")
            else
                notify("Joined " .. math.floor(age / 3600) .. "h+ server")
                updateStatus("4h+ server joined")
            end
            if farmFlag == "1" then
                -- Anti-cheat settle hone ka time do, phir hi farm resume karo
                task.delay(5, function()
                    if waitForCharacter(10) then
                        startChestFarm()
                    else
                        updateStatus("Character load nahi hua - farm manually start karo")
                    end
                end)
            end
        else
            updateStatus("Server " .. math.floor(age / 60) .. "m old - hopping again...")
            pendingHopCount = hopCount + 1
            task.delay(3, function()
                if waitForCharacter(15) then
                    serverHop()
                end
            end)
        end
    end)
end

--================ FIST OF DARKNESS / SECRET LAB ================--
local function hasSpecificItem(itemName)
    for _, container in ipairs({ Player.Backpack, Player.Character }) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item.Name == itemName then
                    return true
                end
            end
        end
    end
    return false
end

local function findLabTarget()
    local map = Workspace:FindFirstChild("Map") or Workspace
    local keywords = { "secret", "order", "microchip", "core", "fist", "darkness", "cyborg", "pod", "tube" }
    local hrp = getHRP()
    local basePos = hrp and hrp.Position or Vector3.new()
    local best, bestName, bestDist = nil, nil, math.huge

    for _, d in ipairs(map:GetDescendants()) do
        if d:IsA("BasePart") or d:IsA("Model") then
            local n = d.Name:lower()
            local match = false
            for _, k in ipairs(keywords) do
                if n:find(k) then match = true break end
            end
            if match then
                local cf = nil
                if d:IsA("BasePart") then
                    cf = d.CFrame
                else
                    local ok, piv = pcall(function() return d:GetPivot() end)
                    if ok then cf = piv end
                end
                if cf then
                    local dist = (basePos - cf.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = cf
                        bestName = d:GetFullName()
                    end
                end
            end
        end
    end
    return best, bestName
end

local function findLabButton(centerCF)
    local map = Workspace:FindFirstChild("Map") or Workspace
    local radius = 90
    local keywords = { "button", "start", "raid", "order", "pod", "tube", "chamber", "green" }

    for _, d in ipairs(map:GetDescendants()) do
        local isDetector = d:IsA("ClickDetector")
        local isPrompt = d:IsA("ProximityPrompt")
        if isDetector or isPrompt then
            local part = d.Parent
            if part and not part:IsA("BasePart") then
                part = part.Parent
            end
            if part and part:IsA("BasePart") and centerCF and (part.Position - centerCF.Position).Magnitude <= radius then
                local path = d:GetFullName():lower()
                local match = true
                for _, k in ipairs(keywords) do
                    if path:find(k) then match = true break end
                end
                if match or isDetector then
                    return d, part
                end
            end
        end
    end
    return nil, nil
end

local function insertFistOfDarkness()
    stopFarmForTeleport()
    updateStatus("Fist of Darkness lab...")
    if currentSea() ~= 2 then
        travelToSea(2)
        if currentSea() ~= 2 then
            notify("Sea 2 required for Secret Laboratory")
            return
        end
    end

    if not hasSpecificItem("Fist of Darkness") then
        notify("Fist of Darkness inventory mein nahi hai")
        return
    end

    -- Secret Laboratory dhundo (runtime object search)
    local labCF, labName = findLabTarget()
    if not labCF then
        local hc = findLocationCF({ "Hot and Cold", "HotAndCold", "Secret Laboratory" }) or HotAndColdCF
        warpTo(hc + Vector3.new(0, 60, 0))
        task.wait(1.2)
        labCF, labName = findLabTarget()
    end

    if not labCF then
        notify("Secret Laboratory nahi mila - Hot and Cold pe manually check karo")
        return
    end

    warpTo(labCF + Vector3.new(0, 5, 0))
    task.wait(0.4)

    local detector, part = findLabButton(labCF)
    if part then
        warpTo(part.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.3)
    end

    -- Button dabane se pehle koi tool equipped na ho
    pcall(function()
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character.Humanoid:UnequipTools()
        end
    end)
    task.wait(0.2)

    if detector and detector:IsA("ClickDetector") then
        pcall(function() fireclickdetector(detector) end)
    elseif detector and detector:IsA("ProximityPrompt") then
        pcall(function() fireproximityprompt(detector) end)
    else
        notify("Lab button nahi mila - pod ke paas green button manually dabao")
        return
    end

    task.wait(1)
    if hasSpecificItem("Fist of Darkness") then
        notify("Fist abhi bhi hai - game message check karo")
    else
        notify("Fist processed! Ab Core Brain chahiye")
    end
end

--================ GUI ================--
local function buildGUI()
    local playerGui = Player:FindFirstChild("PlayerGui") or Player:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild("BloxFruitModMenu")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "BloxFruitModMenu"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 384)
    frame.Position = UDim2.new(0.5, -140, 0.5, -192)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 34)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    title.Text = "Blox Fruits Mod Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready"
    statusLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    local function makeButton(text, y, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 34)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = frame
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn
        btn.MouseButton1Click:Connect(function()
            task.spawn(callback)
        end)
        return btn
    end

    makeButton("1. Dark Arena (Sea 2)", 68, Color3.fromRGB(90, 90, 160), teleportDarkArena)
    makeButton("2. Castle on the Sea", 108, Color3.fromRGB(160, 90, 90), teleportCastleOnSea)
    makeButton("3. Safe Zone", 148, Color3.fromRGB(70, 140, 90), teleportSafeZone)
    makeButton("4. Fist of Darkness Lab", 188, Color3.fromRGB(140, 80, 160), insertFistOfDarkness)
    makeButton("5. Server Hop (4h+)", 228, Color3.fromRGB(200, 140, 40), serverHop)

    farmButton = makeButton("Auto Chest Farm: OFF", 268, Color3.fromRGB(220, 60, 60), function()
        if farming then
            farming = false
            farmButton.Text = "Auto Chest Farm: OFF"
            farmButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            updateStatus("Chest farm stopped")
            if activeTween then
                pcall(function() activeTween:Cancel() end)
                activeTween = nil
            end
            setProbeAnchor(false)
        else
            startChestFarm()
        end
    end)

    autoHopButton = makeButton("6. Auto Hop (60s): ON", 310, Color3.fromRGB(60, 200, 90), function()
        autoHopEnabled = not autoHopEnabled
        updateAutoHopButton()
        updateStatus(autoHopEnabled and "Auto hop ON - har 60s random server" or "Auto hop OFF")
    end)
    updateAutoHopButton()

    serverAgeLabel = Instance.new("TextLabel")
    serverAgeLabel.Size = UDim2.new(1, -20, 0, 16)
    serverAgeLabel.Position = UDim2.new(0, 10, 0, 352)
    serverAgeLabel.BackgroundTransparency = 1
    serverAgeLabel.Text = "Server Age: --"
    serverAgeLabel.TextColor3 = Color3.fromRGB(140, 220, 160)
    serverAgeLabel.Font = Enum.Font.Gotham
    serverAgeLabel.TextSize = 12
    serverAgeLabel.TextXAlignment = Enum.TextXAlignment.Left
    serverAgeLabel.Parent = frame

    task.spawn(function()
        while serverAgeLabel and serverAgeLabel.Parent do
            serverAgeLabel.Text = "Server Age: " .. formatUptime(getEstimatedServerAge()) .. " (est)"
            task.wait(1)
        end
    end)

    -- Drag support
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--================ MANUAL MOVEMENT OVERRIDE ================--
-- User khud move kare (air travel etc.) toh active tween cancel + probe anchor hatado,
-- warna tween player ko wapas apne target ki taraf kheenchta rehta hai.
local function releaseMovementControl()
    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end
    setProbeAnchor(false)
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode.W or kc == Enum.KeyCode.A or kc == Enum.KeyCode.S or kc == Enum.KeyCode.D
        or kc == Enum.KeyCode.Space or kc == Enum.KeyCode.LeftShift then
        releaseMovementControl()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Thumbstick1 and input.Position.Magnitude > 0.35 then
        releaseMovementControl()
    end
end)

--================ BOOT ================--
buildGUI()
task.spawn(autoHopLoop)
checkServerHopMarker()
updateStatus("Script loaded - press Auto Chest Farm")
notify("Blox Fruits mod menu loaded")
