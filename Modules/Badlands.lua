local Lockpicker = LibStub("AceAddon-3.0"):GetAddon("Lockpicker")
local Badlands   = Lockpicker:NewModule("Badlands", "AceEvent-3.0", "AceConsole-3.0")
local HBD        = LibStub("HereBeDragons-2.0")
local HBDPins    = LibStub("HereBeDragons-Pins-2.0")

Badlands.config = {
    instructions = {
        title = "Badlands (%s - %s)",
        text = [[
1. Travel to Angor Fortress.
2. Locate and interact with the lockboxes.

Open the Battered Footlocker until 175, these are found on every level but the lowest one. After 175 you can also open the Dented Footlockers on the lowest level indicated by the red minimap icon.
The Dented Footlockers go yellow once you hit 200.

Be aware that Angor Fortress is filled with mobs ranging from level 38 to 41, so be careful. The lower level contais a level 42 elite.

|cFFFF0000Most of the Dented Lockers are near the level 42 elite, which will require killing the elite to lockpick them.|r
    ]],
        frameHeight = 320
    },
    continentId = 0,
    uiMapId = 1418,
    levelBracket = { 150, 225 },
    locations = {
        { 39.66, 27.75 },
        { 40.2,  27.4 },
        { 40.2,  28.6 },
        { 40.3,  26.7 },
        { 40.4,  28.0 },
        { 40.7,  25.7 },
        { 40.8,  26.6 },
        { 40.8,  27.5 },
        { 40.9,  29.2 },
        { 41.41, 26.38 },
        { 41.4,  29.8 },
        { 41.9,  27.8 },
        { 41.9,  29.3 },
        { 42.1,  30.9 },
        { 42.2,  28.7 },
        { 42.3,  27.4 },
        { 42.4,  29.6 },
        { 43.3,  28.6 },
        -- > 170 boxes
        { 39.7,  27.6,  "Interface\\Icons\\INV_Box_02" },
        { 40.7,  28.7,  "Interface\\Icons\\INV_Box_02" },
        { 40.8,  28.1,  "Interface\\Icons\\INV_Box_02" },
        { 41.2,  27.4,  "Interface\\Icons\\INV_Box_02" },
        { 41.8,  29.1,  "Interface\\Icons\\INV_Box_02" },
        { 42.0,  27.3,  "Interface\\Icons\\INV_Box_02" },
        { 42.2,  28.3,  "Interface\\Icons\\INV_Box_02" },
        { 42.07, 29.3,  "Interface\\Icons\\INV_Box_02" },
        { 41.48, 28.01, "Interface\\Icons\\INV_Box_02" },
        { 41.91, 26.84, "Interface\\Icons\\INV_Box_02" },
        { 42.10, 27.19, "Interface\\Icons\\INV_Box_02" },
        { 41.55, 27.25, "Interface\\Icons\\INV_Box_02" },
        { 42.32, 28.88, "Interface\\Icons\\INV_Box_02" },
        { 42.41, 28.64, "Interface\\Icons\\INV_Box_02" },
    }
}

function Badlands:OnEnable()
    Lockpicker.activeModule = self


    print("Badlands: enabled")

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "InitializeModule")
    -- TODO
    -- self:RegisterMessage("LOCKPICKING_LEVEL_UPDATED", "OnLevelUp")
end

function Badlands:InitializeModule()
    -- TODO only load if actually in the zone and it should respond to skill changes
    for i, lockbox in ipairs(self.config.locations) do
        local pin = CreateFrame("Frame", nil, UIParent)
        pin:SetSize(10, 10) -- Pin size
        pin.texture = pin:CreateTexture(nil, "BACKGROUND")
        pin.texture:SetAllPoints(pin)
        pin.texture:SetTexture(lockbox[3] and lockbox[3] or "Interface\\Icons\\INV_Box_01")

        HBDPins:AddMinimapIconMap("Lockpicker", pin, self.config.uiMapId, lockbox[1] / 100, lockbox[2] / 100, true)
    end

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Badlands:DrawPins(locations, icon)
    for i, lockbox in ipairs(locations) do
        local pin = CreateFrame("Frame", nil, UIParent)
        pin:SetSize(10, 10)
        pin.texture = pin:CreateTexture(nil, "BACKGROUND")
        pin.texture:SetAllPoints(pin)
        pin.texture:SetTexture(icon and icon or "Interface\\Icons\\INV_Box_01")

        HBDPins:AddMinimapIconMap("Lockpicker", pin, self.config.uiMapId, lockbox[1] / 100, lockbox[2] / 100, true)
    end
end

function Badlands:ShouldEnableModule()
    local lockpickingLevel = Lockpicker.db.char.lockpicking
    local race = Lockpicker.db.char.race
    local faction = Lockpicker.db.char.faction

    -- Check lockpicking skill
    if lockpickingLevel < self.config.levelBracket[1] or lockpickingLevel >= self.config.levelBracket[2] then
        print("Badlands: lockpicking skill not within bracket")
        return false
    end

    -- Check proximity toBadlands
    local x, y, instanceID = HBD:GetPlayerWorldPosition()

    if instanceID ~= self.config.continentId then
        print("Badlands: currently on the wrong continent")
        return false
    end

    return true
end

function Badlands:Disable()
    if Lockpicker.activeModule == self then
        Lockpicker.activeModule = nil
    end

    print("Badlands: disabled")
end
