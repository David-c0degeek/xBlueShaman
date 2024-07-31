-- xBlueShaman
-- Author: xHaplo

local addonName, addon = ...

-- Create an addon frame to handle events
addon.frame = CreateFrame("Frame")

-- Define our new Shaman color (blue)
addon.NEW_SHAMAN_COLOR = CreateColor(0.0, 0.44, 0.87)

-- Function to replace Shaman color
function addon:ReplaceShamanColor(r, g, b, a)
    if select(2, UnitClass("player")) == "SHAMAN" then
        return self.NEW_SHAMAN_COLOR:GetRGBA()
    end
    return r, g, b, a
end

-- Hook the GetClassColor function
hooksecurefunc("GetClassColor", function(englishClass)
    if englishClass == "SHAMAN" then
        return addon.NEW_SHAMAN_COLOR:GetRGBA()
    end
end)

-- Hook SetVertexColor method for potential texture coloring
function addon:HookSetVertexColor(texture)
    local oldSetVertexColor = texture.SetVertexColor
    texture.SetVertexColor = function(self, r, g, b, a)
        r, g, b, a = addon:ReplaceShamanColor(r, g, b, a)
        oldSetVertexColor(self, r, g, b, a)
    end
end

-- Apply the hook to relevant frames
function addon:HookFrames()
    local frames = {PlayerFrame, TargetFrame}
    for _, frame in ipairs(frames) do
        if frame.portrait then
            self:HookSetVertexColor(frame.portrait)
        end
    end
end

-- Change chat color for Shamans
function addon:ChangeChatColor()
    -- Change the chat color for Shamans
    RAID_CLASS_COLORS["SHAMAN"] = self.NEW_SHAMAN_COLOR
    RAID_CLASS_COLORS["SHAMAN"].colorStr = self.NEW_SHAMAN_COLOR:GenerateHexColor()
    
    -- Update the chat config
    ChatConfigFrame_UpdateAvailableColorPresets()
    
    -- Force update all chat windows
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        FCF_SetWindowColor(chatFrame, chatFrame:GetR(), chatFrame:GetG(), chatFrame:GetB())
        FCF_SetWindowAlpha(chatFrame, chatFrame:GetAlpha())
    end
end

-- Initialize the addon
addon.frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        addon:HookFrames()
        addon:ChangeChatColor()
    end
end)

addon.frame:RegisterEvent("PLAYER_LOGIN")