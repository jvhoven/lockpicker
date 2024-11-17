---@diagnostic disable: inject-field

local addonName, addonTable = ...;

Lockpicker                  = LibStub("AceAddon-3.0"):NewAddon("Lockpicker", "AceConsole-3.0", "AceEvent-3.0")

local HBD                   = LibStub("HereBeDragons-2.0")
local HBDPins               = LibStub("HereBeDragons-Pins-2.0")

local minimap_icon          = LibStub("LibDBIcon-1.0")

local db
local options               = {
	type = "group",
	name = "Lockpicker",
	handler = Lockpicker,
	args = {
		status = {
			type = "toggle",
			order = 1,
			name = "Enable Lockpicker",
			width = "full",
			get = 'GetEnabled',
			set = 'SetEnabled',
			disabled = false
		}
	}
}

local defaults              = {
	profile = {
		enabled = true,
		minimap = {
			hide = false
		},
		debugMode = false
	},
	char = {
		faction = nil,
		lockpicking = nil,
		race = nil,
	}
}

function Lockpicker:OnInitialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Lockpicker", options)
	self.db = LibStub("AceDB-3.0"):New("LockpickerDB", defaults)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Lockpicker", "Lockpicker")
	local icon = ""

	if self.db.profile.enabled then
		icon = "Interface\\Icons\\INV_Misc_Key_03"
	else
		icon = "Interface\\Icons\\INV_Misc_Key_01"
	end

	---@diagnostic disable-next-line: missing-fields
	local bunnyLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Lockpicker", {
		type = "data source",
		text = "Lockpicker",
		icon = icon,

		-- listen for right click
		OnClick = function(_self, button)
			if button == "LeftButton" then
				self:Toggle()
			end
		end,

		onMouseUp = function(_self, button)
			self:Toggle()
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("Lockpicker")
			tooltip:AddLine("Left-click to toggle Lockpicker")
		end,
	})

	addonTable.bunnyLDB = bunnyLDB
	minimap_icon:Register("Lockpicker", bunnyLDB, self.db.profile.minimap)
end

function Lockpicker:Toggle()
	if self.db.profile.enabled then
		self:Disable()
	else
		self:Enable()
	end
end

function Lockpicker:OnEnable()
	if self.db.profile.enabled then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "InitializeModule")
	end
end

function Lockpicker:InitializeModule()	
	if UnitClass("player") ~= "Rogue" then
		return
	end

	self:SaveCharacterInfo()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Lockpicker:Enable()
	self.db.profile.enabled = true
	addonTable.bunnyLDB.icon = "Interface\\Icons\\Inv_Misc_Key_03"

	-- TODO: redraw boxes
end

function Lockpicker:Disable()
	self.db.profile.enabled = false
	addonTable.bunnyLDB.icon = "Interface\\Icons\\Inv_Misc_Key_01"
	HBDPins:RemoveAllMinimapIcons("Lockpicker")
end

function Lockpicker:SaveCharacterInfo()
	local numLines = GetNumSkillLines()
	for i = 0, numLines, 1 do
		skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription =
			GetSkillLineInfo(i);
		if (skillName == "Lockpicking") then
			self.db.char.lockpicking = skillRank
			break
		end
	end

	local race, raceFile = UnitRace("player")
    local faction, factionFile = UnitFactionGroup("player")

	self.db.char.race = raceFile
	self.db.char.faction = factionFile
end
