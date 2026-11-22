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

local Player = Players.LocalPlayer
local getgenv = getgenv or function() return _G end

--================ CONFIG ================--
local Config = {
    TweenSpeed = 360,          -- studs/sec, thoda fast but still safe for most executors
    ChestOpenWait = 0.25,      -- wait after reaching chest
    AfterChestWait = 0.35,     -- wait before next chest
    NoChestWait = 2.5,         -- wait before server hop when no chest found
    IslandCheckWait = 0.6,     -- wait after moving to island anchor
    LongDistance = 600,        -- isse zyada door ho toh seedha warp (fast claim)
    ProbeDistance = 500,       -- island anchor ke around itne studs check karega
    FarmButtonName = "Auto Chest Farm",
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
local DarkArenaCF = CFrame.new(3876.00366, 24.6882591, -3820.21777) -- Darkbeard/Dark Arena area
local CastleOnSeaCF = CFrame.new(-5074.45556640625, 314.5155334472656, -2991.054443359375)
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

--================ PROBE POINTS (6 per island) ================--
local ProbeOffsets = {
    Vector3.new(0, 0, 0),
    Vector3.new(Config.ProbeDistance, 0, 0),
    Vector3.new(-Config.ProbeDistance, 0, 0),
    Vector3.new(0, 0, Config.ProbeDistance),
    Vector3.new(0, 0, -Config.ProbeDistance),
    Vector3.new(Config.ProbeDistance, 0, Config.ProbeDistance),
}

--================ STATE ================--
local farming = false
local visitedChests = {}
local islandAnchors = {}
local islandIndex = 1
local probeIndex = 1
local islandTourDone = false
local activeTween = nil
local statusLabel = nil
local farmButton = nil

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

local function tweenTo(cf)
    local hrp = getHRP()
    if not hrp or not cf then return false end
    local dist = (hrp.Position - cf.Position).Magnitude
    if dist < 4 then return true end
    if dist > Config.LongDistance then
        updateStatus("Long distance chest: " .. math.floor(dist) .. " studs")
    end

    setNoclip(true)
    local duration = math.max(dist / Config.TweenSpeed, 0.1)
    if activeTween then
        pcall(function() activeTween:Cancel() end)
    end

    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        CFrame = cf,
    })
    activeTween = tween
    tween:Play()

    local finished = false
    local conn
    conn = tween.Completed:Connect(function()
        finished = true
        if conn then conn:Disconnect() end
    end)

    while not finished and farming do
        if hasTargetItem() then
            pcall(function() tween:Cancel() end)
            break
        end
        if not hrp.Parent then break end
        task.wait(0.05)
    end

    if activeTween == tween then
        activeTween = nil
    end
    setNoclip(false)
    return finished and farming
end

local function travelToCF(cf)
    local hrp = getHRP()
    if not hrp or not cf then return false end
    local dist = (hrp.Position - cf.Position).Magnitude
    if dist < 4 then return true end

    -- Door ke chests/islands ke liye direct warp taaki claim miss na ho
    if dist > Config.LongDistance then
        updateStatus("Warping far: " .. math.floor(dist) .. " studs")
        setNoclip(true)
        warpTo(cf)
        setNoclip(false)
        task.wait(0.15)
        return farming
    end

    return tweenTo(cf)
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
            end
            if cf then
                local isFar = true
                for _, ex in ipairs(islandAnchors) do
                    if (cf.Position - ex.CFrame.Position).Magnitude < 1200 then
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
            visitedChests[chest] = true
            local cf = getChestCFrame(chest)
            if cf then
                updateStatus("Chest: " .. chest.Name)
                travelToCF(cf)
                -- Agar travel ke baad bhi chest ke paas nahi pahunche toh skip (loop na lage)
                local hrp = getHRP()
                if hrp and (hrp.Position - cf.Position).Magnitude > 150 then
                    task.wait(0.2)
                end
                if hasTargetItem() then
                    local got = hasTargetItem()
                    stopFarmForItem(got)
                    break
                end
                openChest(chest)
                task.wait(Config.AfterChestWait)
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
                -- Island/probe hop ke liye direct warp taaki doosre island pe jaaye
                warpTo(probeCF)
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
                    return child.CFrame + Vector3.new(0, 10, 0)
                elseif child:IsA("Model") then
                    local ok, piv = pcall(function() return child:GetPivot() end)
                    if ok then return piv + Vector3.new(0, 10, 0) end
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
    updateStatus("Teleporting to Dark Arena...")
    if currentSea() ~= 2 then
        travelToSea(2)
        if currentSea() ~= 2 then
            updateStatus("Could not travel to Sea 2")
            return
        end
    end
    local cf = findLocationCF({ "Dark Arena", "DarkArea", "Arena" }) or DarkArenaCF
    warpTo(cf)
    notify("Teleported to Dark Arena")
end

local function teleportCastleOnSea()
    updateStatus("Teleporting to Castle on the Sea...")
    if currentSea() ~= 3 then
        travelToSea(3)
        if currentSea() ~= 3 then
            updateStatus("Could not travel to Sea 3")
            return
        end
    end
    local cf = findLocationCF({ "Castle on the Sea", "Castle On The Sea", "Sea Castle", "Castle" }) or CastleOnSeaCF
    warpTo(cf)
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
    local zone = nearestSafeZoneCF()
    if zone then
        warpTo(zone.CFrame + Vector3.new(0, 8, 0))
        notify("Safe zone: " .. zone.Name)
    else
        notify("No safe zone found for this sea")
    end
end

--================ SERVER HOP ================--
local function httpGet(url)
    if syn and syn.request then
        local res = syn.request({ Url = url, Method = "GET" })
        return res and res.Body
    end
    if http and http.request then
        local res = http.request({ Url = url, Method = "GET" })
        return res and res.Body
    end
    if http_request then
        local res = http_request({ Url = url, Method = "GET" })
        return res and res.Body
    end
    return game:HttpGet(url)
end

function serverHop()
    farming = false
    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end
    setNoclip(false)
    if farmButton then
        farmButton.Text = "Auto Chest Farm: OFF"
        farmButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
    updateStatus("Server hopping...")

    -- Restricted area se bachne ke liye hop se pehle safe zone mein jao
    local hopZone = nearestSafeZoneCF()
    if hopZone then
        updateStatus("Safe zone before hop...")
        warpTo(hopZone.CFrame + Vector3.new(0, 8, 0))
        task.wait(0.8)
    end

    local servers = {}
    pcall(function()
        local cursor = nil
        local guard = 0
        repeat
            guard += 1
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
            if cursor and cursor ~= "null" then
                url = url .. "&cursor=" .. cursor
            end
            local body = httpGet(url)
            if not body then break end
            local data = HttpService:JSONDecode(body)
            for _, s in ipairs(data.data or {}) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(servers, tostring(s.id))
                end
                if #servers >= 25 then break end
            end
            cursor = data.nextPageCursor
        until not cursor or cursor == "null" or #servers >= 25 or guard >= 3
    end)

    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen, Player)
        end)
        if not ok then
            pcall(function()
                TeleportService:Teleport(game.PlaceId, Player)
            end)
        end
    else
        pcall(function()
            TeleportService:Teleport(game.PlaceId, Player)
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
    frame.Size = UDim2.new(0, 280, 0, 300)
    frame.Position = UDim2.new(0.5, -140, 0.5, -150)
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

    farmButton = makeButton("Auto Chest Farm: OFF", 228, Color3.fromRGB(220, 60, 60), function()
        farming = not farming
        if farming then
            visitedChests = {}
            islandTourDone = false
            islandIndex = 1
            probeIndex = 1
            farmButton.Text = "Auto Chest Farm: ON"
            farmButton.BackgroundColor3 = Color3.fromRGB(60, 200, 90)
            updateStatus("Chest farm started")
            task.spawn(chestFarmLoop)
        else
            farmButton.Text = "Auto Chest Farm: OFF"
            farmButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            updateStatus("Chest farm stopped")
            if activeTween then
                pcall(function() activeTween:Cancel() end)
                activeTween = nil
            end
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

--================ BOOT ================--
buildGUI()
updateStatus("Script loaded - press Auto Chest Farm")
notify("Blox Fruits mod menu loaded")
