Lockpicker.defaults = {
    enabled = false,
    faction = nil,
    lockpicking = -1,
}

function Lockpicker:Initialise()
    local className = UnitClass("player")

    if (className == "Rogue") then
        print("Initialising Lockpicker...")
        self.defaults.lockpicking = GetLockpickSkillLevel()
        self.defaults.enabled = true
        self.defaults.faction = UnitFactionGroup("player")

        print("Your current skill is " .. self.defaults.lockpicking)

        Overlay = CreateFrame("Frame", "MiniMapOverlay", UIParent)
        Overlay:SetSize(1, 1)
        Overlay:SetPoint("CENTER")

        local Line = Overlay:CreateLine("MiniMapLine", "OVERLAY")
        Overlay.Line = Line
        Line:Show()
        Line:SetThickness(1)
        Line:SetStartPoint('CENTER', Minimap, 0, 0)
        Line:SetEndPoint('CENTER', Overlay, 0, 0)

        Overlay:HookScript("OnShow", function()
            Overlay:Show()
        end)
    end
end

