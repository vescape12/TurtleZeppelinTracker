TurtleZeppelinTracker = TurtleZeppelinTracker or {}

local addonName = "TurtleZeppelinTracker"
local frame = CreateFrame("Frame")
print("TZT: Main frame created: " .. tostring(frame))

-- Register events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("WORLD_MAP_UPDATE")
print("TZT: Registered events: ADDON_LOADED, WORLD_MAP_UPDATE")

frame:SetScript("OnEvent", function(self, event, arg1)
    print("TZT: Event triggered: " .. event)
    if event == "ADDON_LOADED" and arg1 == addonName then
        print("Turtle Zeppelin Tracker v1.9 loaded successfully!")
        TurtleZeppelinTracker:Initialize()
    elseif event == "WORLD_MAP_UPDATE" then
        print("TZT: World map updated, visible: " .. tostring(WorldMapFrame:IsVisible()))
        TurtleZeppelinTracker:UpdateWorldMapIcon()
    end
end)

function TurtleZeppelinTracker:Initialize()
    print("TZT: Initializing...")
    if not TurtleZeppelinTracker.Routes then
        print("TZT: Error - routes.lua not loaded.")
        return
    end
    print("TZT: Routes loaded, count: " .. table.getn(TurtleZeppelinTracker.Routes))

    -- Set up slash command
    print("TZT: Setting up slash command /tztracker")
    SLASH_TZTRACKER1 = "/tztracker"
    SlashCmdList["TZTRACKER"] = function(msg)
        print("TZT: Slash command executed!")
        if not TurtleZeppelinTracker.Routes then
            print("TZT: No routes loaded.")
            return
        end
        print("TZT: Zeppelin routes found:")
        for _, route in ipairs(TurtleZeppelinTracker.Routes) do
            print(route.name .. ": " .. route.points[1].zone .. " to " .. route.points[2].zone)
        end
    end
end

function TurtleZeppelinTracker:UpdateWorldMapIcon()
    if not WorldMapFrame:IsVisible() then
        if self.testIcon then
            self.testIcon:Hide()
        end
        print("TZT: World map not visible, hiding icon")
        return
    end

    -- Create test icon if not exists
    if not self.testIcon then
        print("TZT: Creating world map test icon")
        self.testIcon = CreateFrame("Frame", nil, WorldMapFrame)
        print("TZT: Test icon frame created: " .. tostring(self.testIcon))
        self.testIcon:SetSize(48, 48) -- Large for visibility
        self.testIcon.texture = self.testIcon:CreateTexture(nil, "ARTWORK")
        print("TZT: Test icon texture created: " .. tostring(self.testIcon.texture))
        self.testIcon.texture:SetAllPoints()
        self.testIcon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        self.testIcon.texture:SetAlpha(1.0)
        self.testIcon:SetPoint("CENTER", WorldMapFrame, "CENTER", 0, 0)
        self.testIcon:Show()

        -- Tooltip
        self.testIcon:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.testIcon, "ANCHOR_RIGHT")
            GameTooltip:SetText("Test Zeppelin Icon")
            GameTooltip:AddLine("Zone: Test")
            GameTooltip:Show()
        end)
        self.testIcon:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    else
        self.testIcon:Show()
    end
    print("TZT: Test icon shown, visible=" .. tostring(self.testIcon:IsVisible()) .. ", shown=" .. tostring(self.testIcon:IsShown()))
end
