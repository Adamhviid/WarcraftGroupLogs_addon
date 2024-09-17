local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Create the linkFrame
local linkFrame = CreateFrame("Frame", "LinkFrame", UIParent, "BasicFrameTemplateWithInset")
linkFrame.title = linkFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
linkFrame.title:SetPoint("CENTER", linkFrame.TitleBg, "CENTER", 5, 0)
linkFrame.title:SetText("Warcraft Group Logs")
linkFrame:SetSize(600, 200)
linkFrame:SetPoint("CENTER")
linkFrame:Hide()

table.insert(UISpecialFrames, "LinkFrame")

-- Create the linkEditBox
local linkEditBox = CreateFrame("EditBox", nil, linkFrame, "InputBoxTemplate")
linkEditBox:SetSize(500, 200)
linkEditBox:SetPoint("CENTER", linkFrame, "BOTTOM", 0, 70)
linkEditBox:SetAutoFocus(false)
linkEditBox:SetMultiLine(true)
linkEditBox:SetMaxLetters(99999)
linkEditBox:SetScript("OnEscapePressed", linkEditBox.ClearFocus)

local copiedText = linkFrame:CreateFontString(nil, "OVERLAY")
copiedText:SetFontObject("GameFontHighlight")
copiedText:SetPoint("TOP", linkEditBox, "BOTTOM", 0, -5)
copiedText:SetText("")
copiedText:Hide()

linkEditBox:SetScript("OnMouseDown", function()
    local link = linkEditBox:GetText()
    if link and link ~= "" then
        linkEditBox:HighlightText()
        copiedText:SetText("Press Ctrl+C to copy the link.")
        copiedText:Show()
        C_Timer.After(5, function()
            copiedText:Hide()
        end)
    end
end)

local descriptionText = linkFrame:CreateFontString(nil, "OVERLAY")
descriptionText:SetFontObject("GameFontHighlight")
descriptionText:SetPoint("BOTTOM", linkEditBox, "TOP", 0, 10)
descriptionText:SetText(
    "This addon will generate a link to a WarcraftLogs report for the current group or raid. \n \n" ..
        "Simply copy the link to your browser of choice \n")

local function showWindow()
    local members = {}
    local version = "sod"
    local zone
    local raidDifficulty = GetRaidDifficultyID()
    local dungeonDifficulty = GetDungeonDifficultyID()
    local difficulty

    local function trimName(name)
        return string.match(name, "^[^-]+")
    end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(i)
            if name and type(name) == "string" then
                name = trimName(name)
                table.insert(members, name)
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do
            local name = UnitName("party" .. i)
            if name and type(name) == "string" then
                name = trimName(name)
                table.insert(members, name)
            end
        end

        local playerName = UnitName("player")
        if playerName and type(playerName) == "string" then
            playerName = trimName(playerName)
            table.insert(members, playerName)
        end
    end

    local realm = GetRealmName()
    realm = realm:gsub(" ", "-")
    local region = ({"US", "KR", "EU", "TW", "CN"})[GetCurrentRegion()]

    if #members > 5 then
        if raidDifficulty == 14 then -- Normal Raid
            zone = 2009
            difficulty = 3
        elseif raidDifficulty == 15 then -- Heroic Raid
            zone = 38
            difficulty = 4
        elseif raidDifficulty == 16 then -- Mythic Raid
            zone = 38
            difficulty = 5
        else
            zone = 38 -- Default for other raid difficulties
        end
    end

    -- Create the URL
    local url = "https://warcraftgrouplogs.com/?version=" .. version .. "&server=" .. realm .. "&region=" .. region ..
                    "&zone=" .. zone .. "&difficulty=" .. difficulty .. "&characters=" .. table.concat(members, ", ")

    linkEditBox:SetText(url)
    linkFrame:Show()
    linkEditBox:HighlightText()
end

-- minimap button
local myBroker = LDB:NewDataObject("WarcraftGroupLogs", {
    type = "launcher",
    text = "Warcraft Group Logs",
    icon = "Interface\\Icons\\inv_scroll_11",
    OnClick = function(self, button)
        if button == "LeftButton" then
            showWindow()
        elseif button == "RightButton" then
            -- Add functionality for right button click
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Warcraft Group Logs")
        tooltip:AddLine("Left click: Show window", .8, .8, .8, 1)
    end
})

-- Register the data broker object with the icon library
LDBIcon:Register("WarcraftGroupLogs", myBroker, {})

-- Show the minimap button
LDBIcon:Show("WarcraftGroupLogs")

