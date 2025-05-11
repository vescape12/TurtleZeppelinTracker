TurtleZeppelinTracker = TurtleZeppelinTracker or {}

local addonName = "TurtleZeppelinTracker"
local frame = CreateFrame("Frame")
print("Main frame created: " .. tostring(frame))

-- Register events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("WORLD_MAP_UPDATE")
print("Registered events: ADDON_LOADED, WORLD_MAP_UPDATE")

frame:SetScript("OnEvent", function(self, event, arg1)
    print("Event triggered: " .. event)
    if event == "ADDON_LOADED" and arg1 == addonName then
        print("Turtle Zeppelin Tracker v1.8 loaded successfully!")
        print("Minimap width: " .. Minimap:GetWidth() .. ", height: " .. Minimap:GetHeight())
        print("WorldMapFrame width: " .. WorldMapFrame:GetWidth() .. ", height: " .. WorldMapFrame:GetHeight())
        TurtleZeppelinTracker:Initialize()
    elseif event == "WORLD_MAP_UPDATE" then
        print("World map updated, visible: " .. tostring(WorldMapFrame:IsVisible()))
        TurtleZeppelinTracker:UpdateWorldMapIcons()
    end
end)

function TurtleZeppelinTracker:Initialize()
    -- Check if routes are loaded
    if not TurtleZeppelinTracker.Routes then
        print("Turtle Zeppelin Tracker: Error - routes.lua not loaded.")
        return
    end
    print("Turtle Zeppelin Tracker: Routes loaded.")
    print("Number of routes: " .. table.getn(TurtleZeppelinTracker.Routes))

    -- Create icons
    self.icons = {}
    for _, route in ipairs(TurtleZeppelinTracker.Routes) do
        print("Creating icons for route: " .. route.name)
        for i, point in ipairs(route.points) do
            local iconKey = route.id .. "_" .. i
            self.icons[iconKey] = self:CreateIcon(point, route.name)
        end
    end

    -- Create test icons
    local testMinimapIcon = self:CreateIcon({x = 50, y = 50}, "Test Minimap Icon")
    print("Test minimap icon created at center.")
    local testWorldIcon = self:CreateIcon({x = 50, y = 50}, "Test World Map Icon")
    testWorldIcon.worldFrame:SetPoint("CENTER", WorldMapFrame, "CENTER", 0, 0)
    print("Test world map icon created at center.")
end

function TurtleZeppelinTracker:CreateIcon(point, routeName)
    -- Minimap icon
    local icon = CreateFrame("Frame", nil, Minimap)
    print("Minimap frame created: " .. tostring(icon))
    icon:SetSize(32, 32)
    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    print("Minimap texture created: " .. tostring(icon.texture))
    icon.texture:SetAllPoints()
    icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    icon.texture:SetAlpha(1.0)
    icon:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
    icon:Show()
    print("Minimap icon for " .. routeName .. " at " .. point.zone .. ": created, shown=" .. tostring(icon:IsShown()))

    -- World map icon
    icon.worldFrame = CreateFrame("Frame", nil, WorldMapFrame)
    print("World map frame created: " .. tostring(icon.worldFrame))
    icon.worldFrame:SetSize(32, 32)
    icon.worldIcon = icon.worldFrame:CreateTexture(nil, "ARTWORK")
    print("World map texture created: " .. tostring(icon.worldIcon))
    icon.worldIcon:SetAllPoints()
    icon.worldIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    icon.worldIcon:SetAlpha(1.0)
    icon.worldFrame:SetPoint("CENTER", WorldMapFrame, "CENTER", 0, 0)
    icon.worldFrame:Hide()
    print("World map icon for " .. routeName .. " at " .. point.zone .. ": created")

    -- Tooltips
    icon:SetScript("OnEnter", function()
        GameTooltip:SetOwner(icon, "ANCHOR_RIGHT")
        GameTooltip:SetText(routeName or "Unknown Route")
        GameTooltip:AddLine("Zone: " .. (point.zone or "Unknown"))
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    icon.worldFrame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(icon.worldFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(routeName or "Unknown Route")
        GameTooltip:AddLine("Zone: " .. (point.zone or "Unknown"))
        GameTooltip:Show()
    end)
    icon.worldFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return icon
end

function TurtleZeppelinTracker:UpdateWorldMapIcons()
    if not self.icons then return end
    print("Updating world map icons, map visible: " .. tostring(WorldMapFrame:IsVisible()))
    for iconKey, icon in pairs(self.icons) do
        if WorldMapFrame:IsVisible() then
            icon.worldFrame:Show()
            print("Showing world map icon: " .. iconKey .. ", shown=" .. tostring(icon.worldFrame:IsShown()))
        else
            icon.worldFrame:Hide()
        end
    end
end

-- Slash command
SLASH_TZTRACKER1 = "/tztracker"
SlashCmdList["TZTRACKER"] = function(msg)
    print("Turtle Zeppelin Tracker: Slash command working!")
    if not TurtleZeppelinTracker.Routes then
        print("No routes loaded.")
        return
    end
    print("Zeppelin routes found:")
    for _, route in ipairs(TurtleZeppelinTracker.Routes) do
        print(route.name .. ": " .. route.points[1].zone .. " to " .. route.points[2].zone)
    end
end