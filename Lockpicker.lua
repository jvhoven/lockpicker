Lockpicker                = LibStub("AceAddon-3.0"):NewAddon("Lockpicker", "AceConsole-3.0", "AceEvent-3.0")
local AceGUI              = LibStub("AceGUI-3.0")
local LDB                 = LibStub("LibDataBroker-1.1")
local LDBIcon             = LibStub("LibDBIcon-1.0")
local LDD                 = LibStub("LibUIDropDownMenu-4.0");

local LOCKPICK_SPELL_ID   = 1804

local options             = {
	type = "group",
	name = "Lockpicker",
	handler = Lockpicker,
	args = {
	}
}

local defaults            = {
	profile = {
		enabled = true,
		minimap = {
			hide = false
		},
		debugMode = false,
		-- Log the lockpicking locations for improving lockbox positions
		logs = {}
	},
	char = {
		faction = nil,
		lockpicking = nil,
		race = nil,
	}
}

Lockpicker.activeModule   = nil
local pendingLockbox      = {}
local instructions        = nil

function Lockpicker:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("LockpickerDB", defaults)

	if UnitClass("player") ~= "Rogue" then
		return
	end

	for moduleName, module in self:IterateModules() do
		module:SetEnabledState(false)
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnWorldEnter")
	self:RegisterChatCommand("lp", "HandleChatCommand")
end

function Lockpicker:OnWorldEnter()
	if UnitClass("player") ~= "Rogue" then
		return
	end

	self:SaveCharacterInfo()
	self:ShowInstructions()
	self:AddMinimapMenu()

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	self:RegisterEvent("UNIT_SPELLCAST_SENT", "OnLockpickStart")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "OnLockpickSucceeded")
	self:RegisterEvent("CHAT_MSG_SKILL", "OnLockpickLevelUp")
end

function Lockpicker:InitializeMenu(frame, level, menuList)
	local menuFrame = LDD.Create_DropDownMenu("MyAddOn_DropDownMenu", UIParent);
	local menuList = {
		{ text = "TestTitle",  isTitle = true },
		{ text = "TestFunction", isNotRadio = true, notCheckable = false }
	};
	LDD.EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU");
end

function Lockpicker:AddMinimapMenu()
	local dataObject = LDB:NewDataObject("Lockpicker", {
		type = "data source",
		text = "Lockpicker",
		icon = "Interface\\Icons\\INV_Misc_Key_03", -- Example icon
		OnClick = function(_, button)
			if button == "LeftButton" then
				self:InitializeMenu()
			elseif button == "RightButton" then
				print("Right-clicked the minimap icon!")
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("Lockpicker")
			tooltip:AddLine("Left-Click: Open Module Menu")
			tooltip:AddLine("Right-Click: Other Action")
		end,
	})

	-- Register the minimap icon
	LDBIcon:Register("MyAddon", dataObject, self.db.profile.minimap)
end

function Lockpicker:SaveCharacterInfo()
	if self.activeModule then
		local numLines = GetNumSkillLines()
		for i = 0, numLines, 1 do
			skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription =
				GetSkillLineInfo(i);
			if (skillName == "Lockpicking") then
				self.db.char.lockpicking = skillRank
				break
			end
		end

		local _race, raceFile = UnitRace("player")
		local _faction, factionFile = UnitFactionGroup("player")

		self.db.char.race = raceFile
		self.db.char.faction = factionFile
	end
end

function Lockpicker:HandleChatCommand()
	self:ShowInstructions()
end

function Lockpicker:ShowInstructions()
	if instructions then
		instructions:Release()
	end

	if self.activeModule then
		instructions = AceGUI:Create("Frame")
		instructions:SetWidth(220)
		instructions:SetHeight(self.activeModule.config.instructions.frameHeight and
			self.activeModule.config.instructions.frameHeight or 220)
		instructions:SetTitle("Lockpicker")
		instructions:SetLayout("Flow")

		local heading = AceGUI:Create("Heading")
		heading:SetText(string.format(self.activeModule.config.instructions.title,
			self.activeModule.config.levelBracket[1], self.activeModule.config.levelBracket[2]))

		local label = AceGUI:Create("Label")
		label:SetText(self.activeModule.config.instructions.text)
		label:SetFullWidth(true)
		heading:SetFullWidth(true)

		instructions:AddChild(heading)
		instructions:AddChild(label)
	end
end

function Lockpicker:OnLockpickStart(event, unit, targetName, castGUID, spellID)
	if not self.activeModule then
		return
	end

	if unit == "player" and spellID == LOCKPICK_SPELL_ID then
		-- Store the lockbox name and player location
		pendingLockbox.name = targetName
		pendingLockbox.mapID = C_Map.GetBestMapForUnit("player")
		pendingLockbox.position = C_Map.GetPlayerMapPosition(pendingLockbox.mapID, "player")
	end
end

-- data saved in World of Warcraft\_classic_era_\WTF\Account\<ACCOUNT>\SavedVariables\Lockpicker.lua
function Lockpicker:OnLockpickSucceeded(event, unit, castGUID, spellID)
	if not self.activeModule then
		return
	end

	if unit == "player" and spellID == LOCKPICK_SPELL_ID and pendingLockbox.name then
		local x, y = pendingLockbox.position:GetXY()

		local logEntry = {
			name = pendingLockbox.name,
			mapID = pendingLockbox.mapID,
			x = x,
			y = y,
			timestamp = date("%Y-%m-%d %H:%M:%S")
		}

		table.insert(self.db.profile.logs, logEntry)

		pendingLockbox = {}
	end
end

function Lockpicker:OnLockpickLevelUp(event, message)
	if string.match(message, "Lockpicking") then
		local newLevel = string.match(message, "%d+")
		if newLevel then
			self.db.char.lockpicking = tonumber(newLevel)
			self:SendMessage("LOCKPICKING_LEVEL_UPDATED", newLevel)
		end
	end
end
