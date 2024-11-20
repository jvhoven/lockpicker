local Lockpicker          = LibStub("AceAddon-3.0"):GetAddon("Lockpicker")
local HillsbradFoothills  = Lockpicker:NewModule("HillsbradFoothills", "AceEvent-3.0", "AceConsole-3.0")
local HBD                 = LibStub("HereBeDragons-2.0")
local HBDPins             = LibStub("HereBeDragons-Pins-2.0")

HillsbradFoothills.config = {
    instructions = {
        title = "Hillsbrad Foothills (%s-%s)",
        text = [[
    1. Travel to Durnholde Keep.
    2. Locate and interact with the lockboxes.

    It is advisable to stick to the lower part near the jails as this area contains more lockboxes than the castle ruins.

    The castle ruins lockboxes stay yellow until 170.
        ]],
    },
    continentId = 0,
    uiMapId = 1424,
    levelBracket = { 110, 150 },
    locations = {
        { 75.1,  40.1 },
        { 75.2,  41.7 },
        { 75.2,  43.8 },
        { 75.5,  40 },
        { 76,    41.9 },
        { 76.3,  40.8 },
        { 76.6,  40.6 },
        { 77,    42.1 },
        { 77.5,  44.2 },
        { 78.3,  44.7 },
        { 78.9,  44.7 },
        { 78.9,  45.8 },
        { 79.1,  46.5 },
        { 79.5,  46 },
        { 79.6,  46.6 },
        { 75.92, 42.97 },
        { 80,    41.6 },
        { 80.1,  45.1 },
        { 80.5,  40.6 },
        { 80.7,  44.2 },
        { 80.7,  46.1 },
        { 81.1,  46.8 },
        { 81.6,  45.7 },
        { 81.8,  45.4 },
        { 81.9,  41.7 },
        { 82,    44.2 },
        { 82.8,  42.5 },
        { 83,    44.1 }
    }
}

function HillsbradFoothills:OnEnable()
    Lockpicker.activeModule = self
    print("HillsbrandFoothills: enabled")

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "InitializeModule")
end

function HillsbradFoothills:InitializeModule()
    for i, lockbox in ipairs(self.config.locations) do
        local pin = CreateFrame("Frame", nil, UIParent)
        pin:SetSize(10, 10) -- Pin size
        pin.texture = pin:CreateTexture(nil, "BACKGROUND")
        pin.texture:SetAllPoints(pin)
        pin.texture:SetTexture("Interface\\Icons\\INV_Box_01")

        HBDPins:AddMinimapIconMap("Lockpicker", pin, self.config.uiMapId, lockbox[1] / 100, lockbox[2] / 100, true)
    end

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function HillsbradFoothills:ShouldEnableModule()
    local lockpickingLevel = Lockpicker.db.char.lockpicking

    -- Check lockpicking skill
    if lockpickingLevel < self.config.levelBracket[1] or lockpickingLevel >= self.config.levelBracket[2] then
        print("HillsbradFoothills: lockpicking skill not within bracket")
        return false
    end

    -- Check proximity to Hillsbrad Foothills
    local x, y, instanceID = HBD:GetPlayerWorldPosition()

    if instanceID ~= self.config.continentId then
        print("Hillsbrad Foothills: currently on the wrong continent")
        return false
    end

    return true
end

function HillsbradFoothills:Disable()
    if Lockpicker.activeModule == self then
        Lockpicker.activeModule = nil
    end

    -- Module-specific cleanup
    print("HillsbradFoothills: disabled")
end
