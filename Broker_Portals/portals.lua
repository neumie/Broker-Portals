if not LibStub then return end

local dewdrop = LibStub('Dewdrop-2.0', true)
local icon = LibStub('LibDBIcon-1.0')

local math_floor = math.floor

local CreateFrame = CreateFrame
local GetContainerItemCooldown = GetContainerItemCooldown
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetBindLocation = GetBindLocation
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetInventoryItemLink = GetInventoryItemLink
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetSpellName = GetSpellName
local SendChatMessage = SendChatMessage
local UnitInRaid = UnitInRaid
local GetNumPartyMembers = GetNumPartyMembers

local xpacLevel = GetAccountExpansionLevel() + 1;
local xpaclist = { "CLASSIC", "TBC", "WRATH" };
local expac = xpaclist[xpacLevel];

local addonName, addonTable = ...
local L = addonTable.L
local fac = UnitFactionGroup('player')


-- IDs of items usable for transportation
local items = {
  -- Dalaran rings
  40586, -- Band of the Kirin Tor
  48954, -- Etched Band of the Kirin Tor
  48955, -- Etched Loop of the Kirin Tor
  48956, -- Etched Ring of the Kirin Tor
  48957, -- Etched Signet of the Kirin Tor
  45688, -- Inscribed Band of the Kirin Tor
  45689, -- Inscribed Loop of the Kirin Tor
  45690, -- Inscribed Ring of the Kirin Tor
  45691, -- Inscribed Signet of the Kirin Tor
  44934, -- Loop of the Kirin Tor
  44935, -- Ring of the Kirin Tor
  40585, -- Signet of the Kirin Tor
  51560, -- Runed Band of the Kirin Tor
  51558, -- Runed Loop of the Kirin Tor
  51559, -- Runed Ring of the Kirin Tor
  51557, -- Runed Signet of the Kirin Tor
  -- Engineering Gadgets
  30542, -- Dimensional Ripper - Area 52
  18984, -- Dimensional Ripper - Everlook
  18986, -- Ultrasafe Transporter: Gadgetzan
  30544, -- Ultrasafe Transporter: Toshley's Station
  48933, -- Wormhole Generator: Northrend
  -- Seasonal items
  37863, -- Direbrew's Remote
  21711, -- Lunar Festival Invitation
  -- Miscellaneous
  46874, -- Argent Crusader's Tabard
  32757, -- Blessed Medallion of Karabor
  35230, -- Darnarian's Scroll of Teleportation
  50287, -- Boots of the Bay
  52251, -- Jaina's Locket
}

-- IDs of items usable instead of hearthstone
local scrolls = {
  6948, -- Hearthstone
  1903515, -- Fel-Infused Gateway
  28585, -- Ruby Slippers
  44315, -- Scroll of Recall III
  44314, -- Scroll of Recall II
  37118 -- Scroll of Recall
}

-- Ascension: Stones of Retreat
local stones = {
  Kalimdor = {
    "Kalimdor",
    { 777023, "Neutral", "Unlocked", 1 }, -- Azshara
    { 777013, "Neutral", "Unlocked", 1 }, -- Cenarion Hold
    { 777007, "Neutral", "Unlocked", 1 }, -- Everlook
    { 777009, "Neutral", "Unlocked", 1 }, -- Gadgetzan
    { 777026, "Neutral", "Unlocked", 1 }, -- Gates of Ahn'Quiraj
    { 777012, "Neutral", "Unlocked", 1 }, -- Mudsprocket
    { 777027, "Neutral", "Unlocked", 1 }, -- Onyxia's Lair
    { 777010, "Neutral", "Unlocked", 1 }, -- Ratchet
    { 1777025, "Neutral", "Unlocked", 1 }, -- Feathermoon Stronghold
		{ 777015, "Alliance", "Locked", 1 }, -- The Exodar
    { 777004 , "Alliance", "Unlocked", 1 }, -- Darnassus
    { 1777044, "Alliance", "Unlocked", 1 }, -- Nijei's Point
    { 777000 , "Horde", "Locked", 1 }, -- Orgrimmar
    { 777002 , "Horde", "Unlocked", 1 }, -- Thunder Bluff
    { 777021 , "Horde", "Unlocked", 1 }, -- Bloodvenom Post
    { 1777024, "Horde", "Unlocked", 1 }, -- Camp Mojache
    { 1777043, "Horde", "Unlocked", 1 }, -- Shadowprey Village
  },

  EasternKingdoms = {
    "Eastern Kingdoms",
    { 777008, "Neutral", "Unlocked", 1 }, -- Booty Bay
    { 777025, "Neutral", "Unlocked", 1 }, -- Blackrock Mountain
    { 777020, "Neutral", "Unlocked", 1 }, -- Gurubashi Arena
    { 777006, "Neutral", "Unlocked", 1 }, -- Light's Hope
    { 777011, "Neutral", "Unlocked", 1 }, -- Thorium Point
    { 1777023, "Neutral", "Unlocked", 1 }, -- Yojamba Isle
    { 777024, "Neutral", "Unlocked", 1 }, -- Zul'Gurub
    { 777003 , "Alliance", "Locked", 1 },-- Stormwind
    { 777005 , "Alliance", "Unlocked", 1 },-- Ironforge
    { 1777036, "Alliance", "Unlocked", 1 }, -- Aerie Peak
    { 1777026, "Alliance", "Unlocked", 1 }, -- Nethergarde Keep
		{ 777014, "Horde", "Locked", 1 }, -- Silvermoon City 
    { 777001 , "Horde", "Unlocked", 1 }, -- Undercity
    { 1777037, "Horde", "Unlocked", 1 }, -- Revantusk Village
    { 1777027, "Horde", "Unlocked", 1 }, -- Stonard
  },

  Outlands = {
    "Outlands",
    { 777017, "Neutral", "Unlocked", 2 }, -- Area 52
    { 1175646, "Neutral", "Unlocked", 2 }, -- Altar of Sha'tar
    { 1175645, "Neutral", "Unlocked", 2 }, -- Sanctum of the Stars
    { 102182, "Neutral", "Unlocked", 2 }, -- Cenarion Refuge
    { 102186, "Neutral", "Unlocked", 2 }, -- Ogri'la
    { 102196, "Neutral", "Unlocked", 2 }, -- Stormspire
    { 102180, "Neutral", "Unlocked", 2 }, -- Cenarion Refuge
    { 777016, "Neutral", "Unlocked", 2 }, -- Shattrath
    { 102197, "Horde", "Unlocked", 2 }, -- Thrallmar
    { 102189, "Horde", "Unlocked", 2 }, -- Shadowmoon Village
    { 102184, "Horde", "Unlocked", 2 }, -- Garadar
    { 102190, "Horde", "Unlocked", 2 }, -- Stonebreaker Hold
    { 102201, "Horde", "Unlocked", 2 }, -- Zabra'jin
    { 102185, "Alliance", "Unlocked", 2 }, -- Honor Hold
    { 102193, "Alliance", "Unlocked", 2 }, -- Telaar
    { 102178, "Alliance", "Unlocked", 2 }, -- Allerian Stronghold
    { 102187, "Alliance", "Unlocked", 2 }, -- Orebor Harborage
    { 102200, "Alliance", "Unlocked", 2 }, -- Wildhammer Stronghold
  }

}

  -- Ascension: Runes of Retreat
local runes = {
  979807, -- Flaming
  80133,  -- Frostforged
  979806, -- Arcane
  979808, -- Freezing
  979809, -- Dark Rune
  979810 -- Holy Rune
}

-- Ascension: Scrolls of Defense
local sod = {
  83126, -- Ashenvale
  83128 -- Hillsbrad Foothills
}

-- Ascension: Scrolls of Retreat
local sor = {
  Horde = 1175627, -- Orgrimmar
  Alliance = 1175626 -- Stormwind
}


obj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
  type = 'data source',
  text = L['P'],
  icon = 'Interface\\Icons\\INV_Misc_Rune_06',
})
local obj = obj
local methods = {}
local portals = {}
local frame = CreateFrame('frame')

frame:SetScript('OnEvent', function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('SKILL_LINES_CHANGED')

local function pairsByKeys(t)
  local a = {}
  for n in pairs(t) do
    table.insert(a, n)
  end
  table.sort(a)

  local i = 0
  local iter = function()
    i = i + 1
    if a[i] == nil then
      return nil
    else
      return a[i], t[a[i]]
    end
  end
  return iter
end

local function findSpell(spellName)
  local i = 1
  while true do
    local s = GetSpellName(i, BOOKTYPE_SPELL)
    if not s then
      break
    end

    if s == spellName then
      return i
    end

    i = i + 1
  end
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
local function hasItem(itemID)
  local item, found, id
  -- scan inventory
  for slotId = 1, 19 do
    item = GetInventoryItemLink('player', slotId)
    if item then
      found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
      if found and tonumber(id) == itemID then
          return true
      end
    end
  end
  -- scan bags
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      item = GetContainerItemLink(bag, slot)
      if item then
        found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
        if found and tonumber(id) == itemID then
          return true
        end
      end
    end
  end

  return false
end

local function SetupSpells()
  local spells = {
    Alliance = {
      { 3561 , false, 10059 }, -- TP:Stormwind
      { 3562 , false, 11416 }, -- TP:Ironforge
      { 3565 , false, 11419 }, -- TP:Darnassus
      { 32271, false, 32266 }, -- TP:Exodar
      { 49359, false, 49360 }, -- TP:Theramore
      { 33690, false, 33691 }, -- TP:Shattrath
      { 10059, true }, -- P:Stormwind
      { 11416, true }, -- P:Ironforge
      { 11419, true }, -- P:Darnassus
      { 32266, true }, -- P:Exodar
      { 49360, true }, -- P:Theramore
      { 33691, true }, -- P:Shattrath
    },
    Horde = {
      { 3563 , false, 11418 }, -- TP:Undercity
      { 3566 , false, 11420 }, -- TP:Thunder Bluff
      { 3567 , false, 11417 }, -- TP:Orgrimmar
      { 32272, false, 32267 }, -- TP:Silvermoon
      { 49358, false, 49361 }, -- TP:Stonard
      { 35715, false, 35717 }, -- TP:Shattrath
      { 11418, true }, -- P:Undercity
      { 11420, true }, -- P:Thunder Bluff
      { 11417, true }, -- P:Orgrimmar
      { 32267, true }, -- P:Silvermoon
      { 49361, true }, -- P:Stonard
      { 35717, true }, -- P:Shattrath
    }
  }

  local _, class = UnitClass('player')
  if expac == "WRATH" then
    tinsert(portals, { 53140 }) -- TP:Dalaran
    tinsert(portals, { 53142, true }) -- P:Dalaran
  end
  if class == 'HERO' then
    if IsSpellKnown(818045) then
      portals = spells[fac]
    else
      portals = {};
    end
    tinsert(portals, { 18960 }) -- TP:Moonglade
    tinsert(portals, { 556 }) -- Astral Recall
  end
  if class == 'MAGE' then
    portals = spells[fac]
  elseif class == 'DEATHKNIGHT' then
    portals = {
      { 50977 } -- Death Gate
    }
  elseif class == 'DRUID' then
    portals = {
      { 18960 }
    }
  elseif class == 'SHAMAN' then
    portals = {
      { 556 }
    }
  end
end

local function UpdateIcon(icon)
  obj.icon = icon
end

local function addFavorites(spellID, icon, type, mage, isPortal, xpac, fac, portalSpellID)
  if IsAltKeyDown() then
    if PortalsDB.favorites[spellID] and PortalsDB.favorites[spellID][1] then
      PortalsDB.favorites[spellID] = {false, type, mage, isPortal, xpac, fac, portalSpellID}
    else
      PortalsDB.favorites[spellID] = {true, type, mage, isPortal, xpac, fac, portalSpellID}
    end
  end
  UpdateIcon(icon)
end

local function setHeader(text, headerSet, noSpacer)
  if headerSet then return true end
  if not noSpacer then dewdrop:AddLine() end
  dewdrop:AddLine(
    'text', text,
    'isTitle', true
  )
  return true
end

local function getCooldown(ID, text, type)
  local startTime, duration
  if type == "item" then
    startTime, duration = GetItemCooldown(ID)
  else
    startTime, duration = GetSpellCooldown(text)
  end
  local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
  if cooldown > 0 then
    return text.." |cFF00FFFF("..cooldown.." ".. L['MIN'] .. ")"
  end
end

local function dewdropAdd(ID, name, icon, type, mage, isPortal, xpac, fac)
  local text = getCooldown(ID, name, type) or name
  local secure = {
    type1 = type,
    [type] = name,
  }
  dewdrop:AddLine(
    'text', text,
    'secure', secure,
    'icon', icon,
    'func', function() addFavorites(ID, icon, secure.type1, mage, isPortal, xpac, fac) end,
    'closeWhenClicked', true
  )
end

local function updateSpells()
  SetupSpells()
  local i = 0

  if portals then
    for _, v in ipairs(portals) do
      local spell, spellIcon, spellid
      if (PortalsDB.swapPortals and v[3] and (GetNumPartyMembers() > 0 or UnitInRaid("player"))) then
        spell, _, spellIcon = GetSpellInfo(v[3])
        spellid = findSpell(spell)
      else
        spell, _, spellIcon = GetSpellInfo(v[1])
        spellid = findSpell(spell)
      end

      if spellid and (not PortalsDB.favorites[v[1]] or not PortalsDB.favorites[v[1]][1]) then
        if not v[2] or (v[2] and not PortalsDB.showPortals and not PortalsDB.swapPortals) or (PortalsDB.showPortals and v[2] and not PortalsDB.swapPortals) and (GetNumPartyMembers() > 0 or UnitInRaid("player")) then
          methods[spell] = {
            spellid = spellid,
            spellID = v[1],
            text = spell,
            spellIcon = spellIcon,
            isPortal = v[2],
            portalSpellID = v[3],
            secure = {
              type1 = 'spell',
              spell = spell
            }
          }
          i = i + 1
        end
      end
    end
  end

  return i
end

local function GetHearthCooldown()
  local cooldown, startTime, duration

  if GetItemCount(6948) > 0 then
    startTime, duration = GetItemCooldown(6948)
    cooldown = duration - (GetTime() - startTime)
    if cooldown >= 60 then
      cooldown = math_floor(cooldown / 60)
      cooldown = cooldown .. ' ' .. L['MIN']
    elseif cooldown <= 0 then
      cooldown = L['READY']
    else
      cooldown = cooldown .. ' ' .. L['SEC']
    end
    return cooldown
  else
    return L['N/A']
  end
end

local function GetItemCooldowns()
  local cooldown, startTime, duration, cooldowns = nil, nil, nil, nil

  -- items
  for _, item in pairs(items) do
    if GetItemCount(item) > 0 then
      startTime, duration = GetItemCooldown(item)
      cooldown = duration - (GetTime() - startTime)
      if cooldown >= 60 then
        cooldown = math_floor(cooldown / 60)
        cooldown = cooldown .. ' ' .. L['MIN']
      elseif cooldown <= 0 then
        cooldown = L['READY']
      else
        cooldown = cooldown .. ' ' .. L['SEC']
      end
      local name = GetItemInfo(item)
      if cooldowns == nil then
        cooldowns = {}
      end
      cooldowns[name] = cooldown
    end
  end

  return cooldowns
end

--Hearthstone items and spells
local function ShowHearthstone()
  local text, secure, icon, name
  local headerSet = false
    
  for _, itemID in ipairs(scrolls) do
    if hasItem(itemID) and (not PortalsDB.favorites[itemID] or not PortalsDB.favorites[itemID][1]) then
      headerSet = setHeader("Hearthstone: "..GetBindLocation(), headerSet)
      name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
      dewdropAdd(itemID, name, icon, "item")
    end
  end

  local runeRandom = {}
  for _, spellID in ipairs(runes) do
    if IsSpellKnown(spellID) and (not PortalsDB.favorites[spellID] or not PortalsDB.favorites[spellID][1]) then
      tinsert(runeRandom, spellID)
    end
  end

  if #runeRandom > 0 then
    local spellID = runeRandom[math.random(1, #runeRandom)]
    local name, _, icon = GetSpellInfo(spellID)
    if findSpell(name) then
      dewdropAdd(spellID, name, icon, "spell")
    end
  end
end

--Stones of retreat
local function showStones(subMenu, spellCheck, noSpacer) --Kalimdor, true
  local headerSet, header = false, ""

  local function addStone(spellID, xpac)
    local name, _, icon = GetSpellInfo(spellID)
    if findSpell(name) and (not PortalsDB.favorites[spellID] or not PortalsDB.favorites[spellID][1]) then
      headerSet = setHeader(header, headerSet, noSpacer)
      dewdropAdd(spellID, name, icon, "spell", nil, nil, xpac, fac)
    end
  end

  local function tableSort(zone, xpac)
    local sorted = {}
      for _,v in ipairs(stones[zone]) do
        if type(v) == "string" then
          headerSet = false
          header = v 
        elseif type(v) == "table" then
					if not (v[3] == "Locked" and v[2] ~= fac ) and not (xpacLevel < v[4]) then --xpacLevel and locked cities check
						if PortalsDB.showEnemy or (v[2] == fac or v[2] == "Neutral") then --faction or showEnemy check
							local name = GetSpellInfo(v[1])
							if spellCheck and findSpell(name) then return true end
							if findSpell(name) then sorted[name] = v[1] end
						end
					end
        end
      end
      table.sort(sorted)
      for _,v in pairsByKeys(sorted) do
        addStone(v, xpac)
      end
  end
	
	local function addTable(zone)
		local spellCheck = tableSort(zone)
		if spellCheck then return true end
	end

	if subMenu == "All" then
		for continent, _ in pairs(stones) do
			addTable(continent);
		end
	else
		return addTable(subMenu);
	end

end

local function ShowScrolls()
  local secure, text
  local i = 0
  local headerSet = false

  for n,spellID in ipairs(sod) do
    local name, _, icon = GetSpellInfo(spellID)
    if findSpell(name) and (not PortalsDB.favorites[spellID] or not PortalsDB.favorites[spellID][1]) then
      headerSet = setHeader("Scrolls Of Defense", headerSet)
      dewdropAdd(spellID, name, icon, "spell")
      i = i + 1
    end
  end

  if hasItem(sor[fac]) and (not PortalsDB.favorites[sor[fac]] or not PortalsDB.favorites[sor[fac]][1]) then
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(sor[fac])
    dewdropAdd(sor[fac], name, icon, "item")
    i = i + 1
  end

  return i
end

local function ShowOtherItems()
  local i = 0
  local secure, icon, name

  for _, itemID in ipairs(items) do
    if hasItem(itemID) and (not PortalsDB.favorites[itemID] or not PortalsDB.favorites[itemID][1]) then
      name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
      dewdropAdd(itemID, name, icon, "item")
      i = i + 1
    end
  end

  return i
end

local function ToggleMinimap()
  local hide = not PortalsDB.minimap.hide
  PortalsDB.minimap.hide = hide
  if hide then
    icon:Hide('Broker_Portals')
  else
    icon:Show('Broker_Portals')
  end
end

local function showFavorites()
  if PortalsDB.favorites then
    local secure, header
    local headerSet = false

    local function addStone(ID, type, mage, isPortal, swapPortal)
      local name, icon, startTime, duration
      if type == "item" then
        name, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)
      elseif (PortalsDB.swapPortals and swapPortal and (GetNumPartyMembers() > 0 or UnitInRaid("player"))) then
        name, _, icon = GetSpellInfo(swapPortal)
      else
        name, _, icon = GetSpellInfo(ID)
      end
      if (mage and not isPortal and IsSpellKnown(818045) and findSpell(name)) or
      (mage and isPortal and PortalsDB.showPortals and not PortalsDB.swapPortals and IsSpellKnown(818045) and findSpell(name) and ((GetNumPartyMembers() > 0 or UnitInRaid("player")))) or
       (not mage and findSpell(name)) or hasItem(ID) then
        headerSet = setHeader("Favorites", headerSet)
        dewdropAdd(ID, name, icon, type)
      end
    end

    local sorted = {}
    for ID ,v in pairs(PortalsDB.favorites) do
      if v[1] then
        local name
        if v[2] == "item" then
          name = GetItemInfo(ID)
        else
          name = GetSpellInfo(ID)
        end
        if findSpell(name) or hasItem(ID) then
          sorted[name] = {ID, v[2], v[3], v[4], v[5], v[6], v[7]}
        end
      end
    end
    table.sort(sorted)
    for _,v in pairsByKeys(sorted) do
      if (not v[5] and not v[6]) or (v[5] == expac and v[6] == fac) or v[6] == fac or v[5] == expac then
        addStone(v[1], v[2], v[3], nil, v[7])
      end
    end
  end
end

local function UpdateMenu(level, value)
  if level == 1 then
    local chatType = PortalsDB.announceType
    if PortalsDB.announceType == "PARTYRAID" then
      chatType = (UnitInRaid("player") and "RAID") or (GetNumPartyMembers() > 0 and "PARTY")
    end
    dewdrop:AddLine(
      'text', 'Broker_Portals',
      'isTitle', true
    )
    showFavorites()
    
    if PortalsDB.stonesSubMenu then
      local mainHeaderSet = false
      --set main header if player knows any stones
      if not mainHeaderSet then
        dewdrop:AddLine()
        dewdrop:AddLine(
          'text', "Stones Of Retreat",
          'isTitle', true
        )
        mainHeaderSet = true
      end
      --Adds menu if any stone in that category has been learned
			for continent, _ in pairs(stones)
			do
				if showStones(continent, true) then
        dewdrop:AddLine(
        'text', continent,
        'hasArrow', true,
        'value', continent
        )
				end
			end
    else
      showStones("All")
    end

    methods = {}
    if updateSpells() > 0 then
      dewdrop:AddLine()
      dewdrop:AddLine(
      'text', 'Mage Portals',
      'isTitle', true
    )
    for _, v in pairsByKeys(methods) do
      if v.secure and GetSpellCooldown(v.text) == 0 and (not PortalsDB.favorites[v.spellID] or not PortalsDB.favorites[v.spellID][1]) then
        dewdrop:AddLine(
          'text', v.text,
          'secure', v.secure,
          'icon', v.spellIcon,
          'func', function()
            addFavorites(v.spellID, v.spellIcon, v.secure.type1, true, v.isPortal, nil, nil, v.portalSpellID)
            if v.isPortal and chatType and PortalsDB.announce then
              SendChatMessage(L['ANNOUNCEMENT'] .. ' ' .. v.text, chatType)
            end
          end,
          'closeWhenClicked', true
        )
      end
    end
    end

    ShowHearthstone()

    if PortalsDB.showItems then
      ShowScrolls()
      ShowOtherItems()
    end

    dewdrop:AddLine()
    dewdrop:AddLine(
      'text', L['OPTIONS'],
      'hasArrow', true,
      'value', 'options'
    )

    dewdrop:AddLine(
      'text', CLOSE,
      'tooltipTitle', CLOSE,
      'tooltipText', CLOSE_DESC,
      'closeWhenClicked', true
    )
  elseif level == 2 and value == 'Kalimdor' then
    showStones("Kalimdor", nil, true)
  elseif level == 2 and value == 'EasternKingdoms' then
    showStones("EasternKingdoms", nil, true)
  elseif level == 2 and value == 'Outlands' then
    showStones("Outlands", nil, true)
  elseif level == 2 and value == 'options' then
    dewdrop:AddLine(
      'text', L['SHOW_ITEMS'],
      'checked', PortalsDB.showItems,
      'func', function() PortalsDB.showItems = not PortalsDB.showItems end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['SHOW_ITEM_COOLDOWNS'],
      'checked', PortalsDB.showItemCooldowns,
      'func', function() PortalsDB.showItemCooldowns = not PortalsDB.showItemCooldowns end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['ATT_MINIMAP'],
      'checked', not PortalsDB.minimap.hide,
      'func', function() ToggleMinimap() end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['ANNOUNCE'],
      'checked', PortalsDB.announce,
      'func', function() PortalsDB.announce = not PortalsDB.announce end,
      'closeWhenClicked', true
    )
    if PortalsDB.announce then
      dewdrop:AddLine(
        'text', 'Announce in',
        'hasArrow', true,
        'value', 'announce'
      )
    end
    dewdrop:AddLine(
      'text', 'Show portals only in Party/Raid',
      'checked', PortalsDB.showPortals,
      'func', function() PortalsDB.showPortals = not PortalsDB.showPortals end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', 'Swap teleport to portal spells in Party/Raid',
      'checked', PortalsDB.swapPortals,
      'func', function() PortalsDB.swapPortals = not PortalsDB.swapPortals end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', 'Show Stones Of Retreats As Menus',
      'checked', PortalsDB.stonesSubMenu,
      'func', function() PortalsDB.stonesSubMenu = not PortalsDB.stonesSubMenu end,
      'closeWhenClicked', true
    )
		dewdrop:AddLine(
      'text', 'Show enemy faction Stones of Retreats',
      'checked', PortalsDB.showEnemy,
      'func', function() PortalsDB.showEnemy = not PortalsDB.showEnemy end,
      'closeWhenClicked', true
    )
  elseif level == 3 and value == 'announce' then
    dewdrop:AddLine(
      'text', 'Say',
      'checked', PortalsDB.announceType == 'SAY',
      'func', function() PortalsDB.announceType = 'SAY' end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', '|cffff0000Yell|r',
      'checked', PortalsDB.announceType == 'YELL',
      'func', function() PortalsDB.announceType = 'YELL' end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', '|cff00ffffParty|r/|cffff7f00Raid',
      'checked', PortalsDB.announceType == 'PARTYRAID',
      'func', function() PortalsDB.announceType = 'PARTYRAID' end,
      'closeWhenClicked', true
    )
  end
end

function frame:PLAYER_LOGIN()
  if (not PortalsDB) then
    PortalsDB = {}
    PortalsDB.minimap = {}
    PortalsDB.minimap.hide = false
    PortalsDB.showItems = true
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
  end
  if PortalsDB.announceType == nil then
    PortalsDB.announceType = 'PARTYRAID'
  end
  if PortalsDB.showPortals == nil then
    PortalsDB.showPortals = false
  end
	if PortalsDB.showEnemy == nil then
		PortalsDB.showEnemy = false
	end
  if not PortalsDB.favorites then PortalsDB.favorites = {} end
  if icon then
    icon:Register('Broker_Portals', obj, PortalsDB.minimap)
  end

  self:UnregisterEvent('PLAYER_LOGIN')
end

function frame:SKILL_LINES_CHANGED()
  updateSpells()
end

-- All credit for this func goes to Tekkub and his picoGuild!
local function GetTipAnchor(frame)
  local x, y = frame:GetCenter()
  if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
  local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
  local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
  return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function obj.OnClick(self, button)
  GameTooltip:Hide()
  if button == 'RightButton' then
    dewdrop:Open(self, 'children', function(level, value) UpdateMenu(level, value) end)
  end
end

function obj.OnLeave()
  GameTooltip:Hide()
end

function obj.OnEnter(self)
  GameTooltip:SetOwner(self, 'ANCHOR_NONE')
  GameTooltip:SetPoint(GetTipAnchor(self))
  GameTooltip:ClearLines()

  GameTooltip:AddLine('Broker Portals')
  GameTooltip:AddDoubleLine(L['RCLICK'], L['SEE_SPELLS'], 0.9, 0.6, 0.2, 0.2, 1, 0.2)
  GameTooltip:AddLine(' ')
  GameTooltip:AddDoubleLine(L['HEARTHSTONE'] .. ': ' .. GetBindLocation(), GetHearthCooldown(), 0.9, 0.6, 0.2, 0.2, 1,
    0.2)

  if PortalsDB.showItemCooldowns then
    local cooldowns = GetItemCooldowns()
    if cooldowns ~= nil then
      GameTooltip:AddLine(' ')
      for name, cooldown in pairs(cooldowns) do
        GameTooltip:AddDoubleLine(name, cooldown, 0.9, 0.6, 0.2, 0.2, 1, 0.2)
      end
    end
  end

  GameTooltip:Show()
end

-- slashcommand definition
SlashCmdList['BROKER_PORTALS'] = function() ToggleMinimap() end
SLASH_BROKER_PORTALS1 = '/portals'
