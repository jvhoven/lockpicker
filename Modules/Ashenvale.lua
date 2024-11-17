local Lockpicker = LibStub("AceAddon-3.0"):GetAddon("Lockpicker")
local Ashenvale = Lockpicker:NewModule("Ashenvale", "AceEvent-3.0", "AceConsole-3.0")
local HBD                   = LibStub("HereBeDragons-2.0")

local uiMapId = 63
local eligibleInstanceId = 1
local boxLocations = {
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

function Ashenvale:OnEnable()
    if not self:ShouldEnableModule() then
        self:SetEnabledState(false)
        return
    end

    print("Ashenvale: loaded")
end

function Ashenvale:ShouldEnableModule()
    local lockpickingLevel = Lockpicker.db.char.lockpicking
    local race = Lockpicker.db.char.race
    local faction = Lockpicker.db.char.faction

    -- Check lockpicking skill
    if lockpickingLevel >= 70 then
        print("Ashenvale: lockpicking skill too high")
        return false
    end

    -- Check race or faction conditions
    if not (race == "NIGHTELF" or faction == "Alliance") then
        print("Ashenvale: not a night elf or Alliance")
        return false
    end

    -- Check proximity to Ashenvale
    local x, y, instanceID = HBD:GetPlayerWorldPosition()

    if instanceID ~= 1 then
        print("Ashenvale: currently on the wrong continent")
        return false
    end

    local distance = HBD:GetWorldDistance(1, x, y, 15.2, 22.4)

    if distance > 5000 then
        print("Ashenvale: distance above 5000 yards")
        return false
    end

    return true
end
