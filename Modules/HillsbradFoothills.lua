local Lockpicker         = LibStub("AceAddon-3.0"):GetAddon("Lockpicker")
local HillsbradFoothills = Lockpicker:NewModule("HillsbradFoothills", "AceEvent-3.0", "AceConsole-3.0")
local HBD                   = LibStub("HereBeDragons-2.0")
local HBDPins               = LibStub("HereBeDragons-Pins-2.0")

local uiMapId            = 1424
local boxLocations       = {
    { 75.1, 40.1 },
    { 75.2, 41.7 },
    { 75.2, 43.8 },
    { 75.5, 40 },
    { 76,   41.9 },
    { 76.3, 40.8 },
    { 76.6, 40.6 },
    { 77,   42.1 },
    { 77.5, 44.2 },
    { 78.3, 44.7 },
    { 78.9, 44.7 },
    { 78.9, 45.8 },
    { 79.1, 46.5 },
    { 79.5, 46 },
    { 79.6, 46.6 },
    { 80,   41.6 },
    { 80.1, 45.1 },
    { 80.5, 40.6 },
    { 80.7, 44.2 },
    { 80.7, 46.1 },
    { 81.1, 46.8 },
    { 81.6, 45.7 },
    { 81.8, 45.4 },
    { 82,   44.2 },
    { 82.8, 42.5 },
    { 83,   44.1 }
}

function HillsbradFoothills:OnEnable()
    if not self:ShouldEnableModule() then
        self:SetEnabledState(false)
        return
    end

    print("HillsbrandFoothills: loaded") 
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "InitializeModule")
end

function HillsbradFoothills:InitializeModule()
    for i, lockbox in ipairs(boxLocations) do
        local pin = CreateFrame("Frame", nil, UIParent)
        pin:SetSize(10, 10) -- Pin size
        pin.texture = pin:CreateTexture(nil, "BACKGROUND")
        pin.texture:SetAllPoints(pin)
        pin.texture:SetTexture("Interface\\Icons\\INV_Box_01")

        HBDPins:AddMinimapIconMap("Lockpicker", pin, uiMapId, lockbox[1] / 100, lockbox[2] / 100, true)
    end

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function HillsbradFoothills:ShouldEnableModule()
    local lockpickingLevel = Lockpicker.db.char.lockpicking
    local race = Lockpicker.db.char.race
    local faction = Lockpicker.db.char.faction

    -- Check lockpicking skill
    if lockpickingLevel >= 160 then
        print("HillsbradFoothills: lockpicking skill too high")
        return false
    end

    -- Check proximity to Hillsbrad Foothills
    local x, y, instanceID = HBD:GetPlayerWorldPosition()

    if instanceID ~= 0 then
        print("Hillsbrad Foothills: currently on the wrong continent")
        return false
    end

    local distance = HBD:GetWorldDistance(0, x, y, 74.22, 50.09)

    if distance > 5000 then
        print("Hillsbrad Foothills: distance above 5000 yards")
        return false
    end

    return true
end
