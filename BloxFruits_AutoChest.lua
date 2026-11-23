-- Blox Fruits Auto Chest + Mod Menu
-- Executor script (Delta/Solara/Xeno/Fluxus etc.)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local getgenv = getgenv or function() return _G end

--================ CONFIG ================--
local Config = {
    TweenSpeed = 350,          -- studs/sec, safe for anti-cheat
    TeleportSpeed = 350,       -- manual teleport buttons ke liye safe tween speed (anti-cheat safe)
    ChestOpenWait = 0.4,       -- wait after reaching chest
    AfterChestWait = 0.5,      -- wait before next chest
    NoChestWait = 2.5,         -- wait before server hop when no chest found
    IslandCheckWait = 0.8,     -- wait after moving to island anchor
    LongDistance = 600,        -- isse zyada door ho toh fast travel (far chest)
    ProbeDistance = 700,       -- island anchor ke around itne studs check karega
    AnchorMergeDistance = 700, -- isse kam door wali location ko duplicate maanega
    ProbeSpeed = 350,          -- island probe tween speed (slow = anti-cheat safe)
    FarTravelSpeed = 360,      -- door ke chest tak ki max tween speed (anti-cheat safe)
    ChestArriveDistance = 120, -- itne se zyada door ho toh chest claim skip (retry allowed)
    MaxChestAttempts = 2,      -- ek chest ko max itni baar try karega
    FarmButtonName = "Auto Chest Farm",
    AutoHopInterval = 65,      -- auto server hop har itne seconds (fixed server-hop code)
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

local SeaPlaceMap = {
    [1] = 2753915549,
    [2] = 4442272183,
    [3] = 7449423635,
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

local noclipStates = {}
local function setNoclip(state)
    local char = Player.Character
    if not char then return end
    if state then
        noclipStates = {}
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                noclipStates[d] = d.CanCollide
                d.CanCollide = false
            end
        end
    else
        for part, old in pairs(noclipStates) do
            if part.Parent then
                part.CanCollide = old
            end
        end
        noclipStates = {}
    end
end

local function tweenTo(cf, speed, mustFinish)
    local hrp = getHRP()
    if not hrp or not cf then return false end
    local dist = (hrp.Position - cf.Position).Magnitude
    if dist < 4 then return true end
    if dist > Config.LongDistance and not mustFinish then
        updateStatus("Long distance chest: " .. math.floor(dist) .. " studs")
    end

    setNoclip(true)
    local duration = math.max(dist / (speed or Config.TweenSpeed), 0.1)
    if activeTween then
        pcall(function() activeTween:Cancel() end)
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

    while not finished do
        if not mustFinish then
            if hasTargetItem() then
                pcall(function() tween:Cancel() end)
                break
            end
            if not farming then
                break
            end
        end
        if not hrp.Parent then break end
        task.wait(0.05)
    end

    if activeTween == tween then
        activeTween = nil
    end
    setNoclip(false)
    return finished and completedOk and (mustFinish or farming)
end

local function travelToCF(cf)
    local hrp = getHRP()
    if not hrp or not cf then return false end
    local dist = (hrp.Position - cf.Position).Magnitude
    if dist < 4 then return true end

    -- Door ke chests/islands ke liye fast tween taaki claim miss na ho.
    -- Instant warp anti-cheat ko teleport lagta hai (position reset / restricted area),
    -- isliye frame-by-frame movement use karo.
    if dist > Config.LongDistance then
        updateStatus("Traveling far: " .. math.floor(dist) .. " studs")
        local speed = math.clamp(dist / 5, Config.TweenSpeed, Config.FarTravelSpeed)
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

    -- Anti-cheat safe cruise altitude & speed (350 studs/sec max)
    local safeSpeed = math.min(Config.TeleportSpeed or 350, 360)
    local cruiseY = math.max(startPos.Y, destPos.Y) + 200
    local ok = tweenTo(CFrame.new(startPos.X, cruiseY, startPos.Z), safeSpeed, true)
    if ok then
        ok = tweenTo(CFrame.new(destPos.X, cruiseY, destPos.Z), safeSpeed, true)
    end
    if ok then
        ok = tweenTo(cf, safeSpeed, true)
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
    if not hrp or not cf then return false end
    local dist = (hrp.Position - cf.Position).Magnitude
    if dist <= 15 then
        hrp.CFrame = cf
        return true
    end
    -- Over distance: use smooth tweenTo with noclip to prevent Blox Fruits anti-cheat rollback
    return tweenTo(cf, Config.TweenSpeed or 350, true)
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

--================ SERVER HOP HELPERS ================--

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

--================ SERVER HOP (FIXED V5 - ANTI 773 & ANTI ROLLBACK) ================--
local HOP_INTERVAL       = Config.AutoHopInterval or 65
local RETRY_DELAY        = 4
local FLOOD_RETRY_DELAY  = 8
local MAX_RETRIES        = 12
local LANDING_SETTLE     = 2
local CHAR_LOAD_TIMEOUT  = 30

local HOP_MARKER_FILE       = "bf_hop_marker.txt"
local HOP_MARKER_MAX_AGE    = 900
local VISITED_SERVERS_FILE  = "bf_visited_servers.json"

local isHopping          = false
local retryCount         = 0
local serverCandidates   = {}
local visitedServers     = {}
local isFetchingServers  = false
local currentHopJobId    = nil

local function writeHopMarker(farmFlag)
    pcall(function()
        if writefile then
            writefile(HOP_MARKER_FILE, tostring(os.time()) .. "|" .. (farmFlag and "1" or "0"))
        end
    end)
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

local function httpRequest(url)
    local fn = (syn and syn.request) 
        or (http and http.request) 
        or http_request 
        or (fluxus and fluxus.request) 
        or request
    if fn then
        local ok, res = pcall(fn, { Url = url, Method = "GET" })
        if ok and res and res.Body then
            return res.Body
        end
    end
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and res then
        return res
    end
    return nil
end

local function loadVisitedServers()
    pcall(function()
        if readfile and isfile and isfile(VISITED_SERVERS_FILE) then
            local data = HttpService:JSONDecode(readfile(VISITED_SERVERS_FILE))
            if type(data) == "table" then
                local now = os.time()
                for id, t in pairs(data) do
                    if (now - (tonumber(t) or 0)) < 1800 then
                        visitedServers[tostring(id)] = tonumber(t)
                    end
                end
            end
        end
    end)
    visitedServers[tostring(game.JobId)] = os.time()
end

local function saveVisitedServers()
    pcall(function()
        if writefile then
            writefile(VISITED_SERVERS_FILE, HttpService:JSONEncode(visitedServers))
        end
    end)
end

local function recordVisitedServer(jobId)
    if not jobId then return end
    visitedServers[tostring(jobId)] = os.time()
    saveVisitedServers()
end

loadVisitedServers()

local function fetchServers(placeId)
    if isFetchingServers then return false end
    isFetchingServers = true
    updateStatus("Fetching servers from API...")

    local candidates = {}
    local placeIdStr = tostring(placeId)
    local seaRootId = SeaPlaceMap and SeaPlaceMap[currentSea()]
    local idList = { placeIdStr }
    if seaRootId and tostring(seaRootId) ~= placeIdStr then
        table.insert(idList, tostring(seaRootId))
    end

    local endpoints = {
        "https://games.roproxy.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100",
        "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100",
        "https://games.roproxy.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100",
        "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100",
    }

    for _, targetId in ipairs(idList) do
        for _, endpointTemplate in ipairs(endpoints) do
            local url = string.format(endpointTemplate, targetId)
            local body = httpRequest(url)

            if body and body ~= "" then
                local parsed = nil
                pcall(function()
                    parsed = HttpService:JSONDecode(body)
                end)

                if parsed and parsed.data and #parsed.data > 0 then
                    for _, s in ipairs(parsed.data) do
                        local sId = tostring(s.id)
                        local playing = tonumber(s.playing) or 0
                        local maxP = tonumber(s.maxPlayers) or 12

                        if sId ~= game.JobId and playing > 0 and playing < maxP then
                            if not visitedServers[sId] then
                                table.insert(candidates, { id = sId, place = tonumber(targetId) or placeId })
                            end
                        end
                    end

                    if #candidates >= 10 then break end
                end
            end
        end
        if #candidates >= 10 then break end
    end

    if #candidates == 0 then
        updateStatus("Resetting visited cache & refreshing...")
        visitedServers = { [tostring(game.JobId)] = os.time() }
        saveVisitedServers()

        for _, targetId in ipairs(idList) do
            local url = string.format("https://games.roproxy.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100", targetId)
            local body = httpRequest(url)
            if not body or body == "" then
                url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100", targetId)
                body = httpRequest(url)
            end

            if body and body ~= "" then
                pcall(function()
                    local parsed = HttpService:JSONDecode(body)
                    if parsed and parsed.data then
                        for _, s in ipairs(parsed.data) do
                            local sId = tostring(s.id)
                            local playing = tonumber(s.playing) or 0
                            local maxP = tonumber(s.maxPlayers) or 12
                            if sId ~= game.JobId and playing > 0 and playing < maxP then
                                table.insert(candidates, { id = sId, place = tonumber(targetId) or placeId })
                            end
                        end
                    end
                end)
            end
            if #candidates > 0 then break end
        end
    end

    isFetchingServers = false
    serverCandidates = candidates
    return #candidates > 0
end

local function queueReExecution()
    local queueTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if queueTeleport then
        pcall(function()
            queueTeleport([[
                task.wait(1)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/vayuhub/vayuhub/main/BloxFruits_AutoChest.lua"))()
            ]])
        end)
    end
end

-- TeleportToPlaceInstance directly to public server instance
-- NEVER calls Teleport(game.PlaceId) to prevent Error 773 (Restricted place)
local function fireTeleport()
    if #serverCandidates == 0 then
        fetchServers(game.PlaceId)
    end

    if #serverCandidates == 0 then
        warn("[Hop] No candidate servers available")
        updateStatus("No servers found - retrying in 4s...")
        -- Reset isHopping so script doesn't stay permanently locked!
        task.delay(4, function()
            if isHopping then
                fetchServers(game.PlaceId)
                if #serverCandidates > 0 then
                    fireTeleport()
                else
                    isHopping = false
                    updateStatus("Hop retry failed - check internet")
                    pcall(function()
                        setProbeAnchor(false)
                        setNoclip(false)
                    end)
                end
            end
        end)
        return false
    end

    local randomIndex = math.random(1, #serverCandidates)
    local targetServer = table.remove(serverCandidates, randomIndex)
    local targetJobId = targetServer.id
    local targetPlaceId = targetServer.place or game.PlaceId

    currentHopJobId = targetJobId
    recordVisitedServer(targetJobId)
    updateStatus(string.format("Teleporting to server... (%d in queue)", #serverCandidates))

    queueReExecution()

    local oldJobId = game.JobId
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(targetPlaceId, targetJobId, Player)
    end)

    if not ok then
        warn("[Hop] TeleportToPlaceInstance call failed:", tostring(err))
        updateStatus("Teleport call failed - trying next server...")
        task.delay(2, function()
            if isHopping then
                fireTeleport()
            end
        end)
        return false
    end

    -- Watchdog: Agar 10s tak Roblox teleport na kare, next server try karo
    task.delay(10, function()
        if isHopping and game.JobId == oldJobId then
            warn("[Hop] Teleport timed out (stuck in same server), picking next...")
            retryCount += 1
            if retryCount <= MAX_RETRIES then
                updateStatus(string.format("Hop timed out - retry %d/%d...", retryCount, MAX_RETRIES))
                fireTeleport()
            else
                isHopping = false
                retryCount = 0
                clearHopMarker()
                notify("Hop failed after timeout retries")
                updateStatus("Ready")
                pcall(function()
                    setProbeAnchor(false)
                    setNoclip(false)
                end)
            end
        end
    end)

    return true
end

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult)
    if player ~= Player then return end

    local reason = tostring(teleportResult)
    warn("[Hop] Teleport failed:", reason)

    retryCount += 1

    if retryCount > MAX_RETRIES then
        isHopping = false
        retryCount = 0
        clearHopMarker()
        notify("Hop failed after " .. MAX_RETRIES .. " retries - next cycle mein try hoga")
        pcall(function()
            setProbeAnchor(false)
            setNoclip(false)
        end)
        return
    end

    local delay = RETRY_DELAY
    if teleportResult == Enum.TeleportResult.Flooded then
        delay = FLOOD_RETRY_DELAY
        updateStatus(string.format("Rate limited - retry %d/%d in %ds...", retryCount, MAX_RETRIES, delay))
    else
        updateStatus(string.format("Hop failed (%s) - retry %d/%d in %ds...", reason, retryCount, MAX_RETRIES, delay))
    end

    task.delay(delay, function()
        if not isHopping then return end
        updateStatus(string.format("Retrying hop... (%d/%d)", retryCount, MAX_RETRIES))
        fireTeleport()
    end)
end)

function serverHop()
    if isHopping then
        warn("[Hop] Already hopping, ignoring")
        return
    end
    isHopping = true
    retryCount = 0

    local wasFarming = farming
    farming = false

    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end

    if farmButton then
        farmButton.Text = "Auto Chest Farm: OFF"
        farmButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end

    updateStatus("Preparing hop...")

    -- Anti-cheat safe: anchor character in place with noclip (NO instant warping that causes rubberbanding!)
    pcall(function()
        setNoclip(true)
        setProbeAnchor(true)
    end)

    writeHopMarker(wasFarming)

    updateStatus("Hopping...")
    fireTeleport()
end

--================ AUTO SERVER HOP ================--
local autoHopEnabled = true
local autoHopButton = nil

local function updateAutoHopButton()
    if autoHopButton then
        autoHopButton.Text = autoHopEnabled and string.format("6. Auto Hop (%ds): ON", HOP_INTERVAL) or string.format("6. Auto Hop (%ds): OFF", HOP_INTERVAL)
        autoHopButton.BackgroundColor3 = autoHopEnabled and Color3.fromRGB(60, 200, 90) or Color3.fromRGB(220, 60, 60)
    end
end

local function autoHopLoop()
    local nextHopTime = os.time() + HOP_INTERVAL

    while true do
        if not autoHopEnabled then
            nextHopTime = os.time() + HOP_INTERVAL
            task.wait(1)
        else
            local remain = nextHopTime - os.time()
            if remain > 0 then
                if remain <= 10 then
                    updateStatus(string.format("Next hop in %ds...", remain))
                end
                task.wait(math.min(remain, 3))
            else
                nextHopTime = os.time() + HOP_INTERVAL

                if isHopping then
                    updateStatus("Previous hop still retrying - waiting...")
                    task.wait(5)
                else
                    updateStatus("Auto hop triggered!")
                    serverHop()
                    task.wait(HOP_INTERVAL)
                end
            end
        end
    end
end

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

    if not ts or (os.time() - ts) > HOP_MARKER_MAX_AGE then
        clearHopMarker()
        return
    end

    clearHopMarker()

    task.spawn(function()
        updateStatus("Loading character...")
        if not waitForCharacter(CHAR_LOAD_TIMEOUT) then
            updateStatus("Slow load - waiting more...")
            task.wait(5)
            if not waitForCharacter(15) then
                notify("Character load failed")
                return
            end
        end

        pcall(function() setProbeAnchor(true) end)
        pcall(function() setNoclip(true) end)
        task.wait(0.5)

        updateStatus("Settling in server...")
        task.wait(LANDING_SETTLE)

        pcall(function() setProbeAnchor(false) end)
        pcall(function() setNoclip(false) end)

        notify("Server joined!")
        updateStatus("Ready")
        isHopping = false

        if farmFlag == "1" then
            task.delay(2, function()
                if waitForCharacter(10) then
                    startChestFarm()
                end
            end)
        end
    end)
end
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
    makeButton("5. Server Hop", 228, Color3.fromRGB(200, 140, 40), serverHop)

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

    autoHopButton = makeButton("6. Auto Hop: ON", 310, Color3.fromRGB(60, 200, 90), function()
        autoHopEnabled = not autoHopEnabled
        updateAutoHopButton()
        updateStatus(autoHopEnabled and string.format("Auto hop ON - har %ds random server", HOP_INTERVAL) or "Auto hop OFF")
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
