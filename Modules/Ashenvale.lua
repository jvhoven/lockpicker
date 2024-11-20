local Lockpicker = LibStub("AceAddon-3.0"):GetAddon("Lockpicker")
local Ashenvale  = Lockpicker:NewModule("Ashenvale", "AceEvent-3.0", "AceConsole-3.0")
local HBD        = LibStub("HereBeDragons-2.0")
local HBDPins    = LibStub("HereBeDragons-Pins-2.0")

Ashenvale.config = {
    instructions = {
        title = "Ashenvale (%s-%s)",
        text = [[
    1. Travel to the Zoram Strand in Ashenvale.
    2. Locate and interact with the lockboxes.
        ]],
    },
    instanceId = 1,
    uiMapId = 63,
    levelBracket = { 70, 110 },
    locations = {
        { 10.9, 30.1 },
        { 11.7, 29 },
        { 11.9, 30.1 },
        { 13.1, 26.1 },
        { 13.1, 29.5 },
        { 13.3, 28.7 },
        { 13.5, 14.9 },
        { 14,   19.9 },
        { 14.1, 16.2 },
        { 14.4, 23 },
        { 14.5, 23 },
        { 14.9, 25.1 },
        { 15,   17.1 },
        { 15.3, 22.1 },
        { 15.6, 18.9 }

    }
}

function Ashenvale:OnEnable()
    Lockpicker.activeModule = self

    print("Ashenvale: enabled")

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "InitializeModule")
end

function Ashenvale:InitializeModule()
    for i, lockbox in ipairs(self.config.locations) do
        local pin = CreateFrame("Frame", nil, UIParent)
        pin:SetSize(10, 10)
        pin.texture = pin:CreateTexture(nil, "BACKGROUND")
        pin.texture:SetAllPoints(pin)
        pin.texture:SetTexture("Interface\\Icons\\INV_Box_01")

        HBDPins:AddMinimapIconMap("Lockpicker", pin, self.config.uiMapId, lockbox[1] / 100, lockbox[2] / 100, true)
    end

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Ashenvale:ShouldEnableModule()
    local lockpickingLevel = Lockpicker.db.char.lockpicking
    local race = Lockpicker.db.char.race
    local faction = Lockpicker.db.char.faction

    -- Check lockpicking skill
    if lockpickingLevel < self.config.levelBracket[1] or lockpickingLevel >= self.config.levelBracket[2] then
        print("Ashenvale: lockpicking skill not within bracket")
        return false
    end

    -- Check race or faction conditions
    if not (race == "NIGHTELF" or faction == "Alliance") then
        print("Ashenvale: not a night elf or Alliance")
        return false
    end

    -- Check proximity to Ashenvale
    local x, y, instanceID = HBD:GetPlayerWorldPosition()

    if instanceID ~= self.config.instanceId then
        print("Ashenvale: currently on the wrong continent")
        return false
    end

    local distance = HBD:GetWorldDistance(self.config.uiMapId, x, y, 15.2, 22.4)

    if distance > 5000 then
        print("Ashenvale: distance above 5000 yards")
        return false
    end

    return true
end

function Ashenvale:Disable()
    if Lockpicker.activeModule == self then
        Lockpicker.activeModule = nil
    end

    print("Ashenvale: disabled")
end
