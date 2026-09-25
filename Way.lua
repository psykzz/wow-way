-- Way: a minimal /way command that drops a world/minimap waypoint pin,
-- using the same UiMapPoint / C_Map user-waypoint API that powers retail's
-- built-in map-pin feature. Only registers /way if no other addon
-- (e.g. TomTom) has already claimed that slash command.

local PREFIX = "|cff33ff99Way|r: "

-- Scan every existing SLASH_* global to see if something already owns /way.
local function IsSlashTaken(token)
    token = token:upper()
    for key, value in pairs(_G) do
        if type(key) == "string" and key:match("^SLASH_") and type(value) == "string" and value:upper() == token then
            return true
        end
    end
    return false
end

local function GetCurrentMapID()
    return C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
end

local function MakeMapPoint(mapID, x, y)
    if UiMapPoint and UiMapPoint.CreateFromCoordinates then
        return UiMapPoint.CreateFromCoordinates(mapID, x, y)
    end
    -- Fallback: build the raw table shape C_Map.SetUserWaypoint expects.
    return { uiMapID = mapID, position = { x = x, y = y } }
end

local function ParseCoords(msg)
    -- Accept "45.2,67.8" or "45.2 67.8"
    local x, y = msg:match("^(%d+%.?%d*)%s*,%s*(%d+%.?%d*)$")
    if not x then
        x, y = msg:match("^(%d+%.?%d*)%s+(%d+%.?%d*)$")
    end
    if not x or not y then
        return nil
    end
    x, y = tonumber(x), tonumber(y)
    if not x or not y then
        return nil
    end
    -- Accept either 0-1 fractions or 0-100 percentages.
    if x > 1 then x = x / 100 end
    if y > 1 then y = y / 100 end
    return x, y
end

local function HandleWay(msg)
    msg = strtrim(msg or "")

    if msg == "" or msg:lower() == "clear" or msg:lower() == "off" then
        if C_Map and C_Map.ClearUserWaypoint then
            C_Map.ClearUserWaypoint()
            print(PREFIX .. "waypoint cleared.")
        end
        return
    end

    local x, y = ParseCoords(msg)
    if not x then
        print(PREFIX .. "usage: /way x,y  (e.g. /way 45.2,67.8)")
        return
    end

    if not C_Map or not C_Map.SetUserWaypoint then
        print(PREFIX .. "this client does not support map waypoint pins.")
        return
    end

    local mapID = GetCurrentMapID()
    if not mapID then
        print(PREFIX .. "could not determine your current map.")
        return
    end

    local point = MakeMapPoint(mapID, x, y)
    C_Map.SetUserWaypoint(point)

    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end

    print(PREFIX .. string.format("waypoint set at %.1f, %.1f", x * 100, y * 100))
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    -- Wait until PLAYER_LOGIN so every other addon has had a chance to
    -- register its own /way (or equivalent) slash command first.
    if IsSlashTaken("/WAY") then
        return
    end
    SLASH_WAY1 = "/way"
    SlashCmdList["WAY"] = HandleWay
end)
