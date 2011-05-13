--[[

]]

	local font = [[Interface\AddOns\PredatorArchy\media\accid__.ttf]]
	local textures = {
		['border'] = [[Interface\AddOns\PredatorArchy\media\border_generic]],
		['bar'] = [[Interface\AddOns\PredatorArchy\media\bar]],
		['solid'] = [[Interface\AddOns\PredatorArchy\media\solid]],
		['minimap'] = [[Interface\AddOns\PredatorArchy\media\button_minimap]],
		['button_back'] = [[Interface\AddOns\PredatorArchy\media\button_back]],
		['button_config'] = [[Interface\AddOns\PredatorArchy\media\button_config]],
		['button_hide'] = [[Interface\AddOns\PredatorArchy\media\button_hide]],
		['button_sleep'] = [[Interface\AddOns\PredatorArchy\media\button_sleep]],
		['button_statistics'] = [[Interface\AddOns\PredatorArchy\media\button_statistics]]
	}
	local artifactsWidth = 300
	local artifactsLineHeight = 28
	local digSitesWidth = 200
	local texts = {
		['noskill'] = 'no archaeology skill detected!',
		['notavailable'] = 'not available',
		['solvable'] = 'you can solve',
		['notsolvable'] = 'You do not have enough fragments!',
		['keystones'] = 'Keystones',
		['solving_with_keystones'] = 'Would you like to solve this artifact using your keystones?',
		['confirm_reset'] = 'Do you really want to reset the settings?',
		['stats'] = 'Statistics',
		['rare'] = 'rares',
		['max_solved'] = 'Most solved',
		['alwaysShowRareCaption'] = 'always show rares',
		['showMinimapButtonCaption'] = 'show Minimap button',
		['mode_caption'] = 'Mode',
		['mode_all'] = 'All',
		['mode_artifacts'] = 'Artifacts',
		['mode_fragments'] = 'Fragments',
		['mode_custom'] = 'Custom',
		['button_show'] = 'Show',
		['button_hide'] = 'Hide',
		['button_sleep'] = 'Sleep',
		['button_reset'] = 'Reset',
		['button_toggle'] = 'Toggle',
		['button_statistics'] = 'Statistics',
		['tooltip_showSkill'] = 'Show skill',
		['tooltip_openConfig'] = 'Open configuration dialogue',
		['tooltip_show'] = 'Show PredatorArchy windows',
		['tooltip_hide'] = 'Hide PredatorArchy windows',
		['tooltip_sleep'] = 'Send PredatorArchy to sleep',
		['tooltip_reset'] = 'Reset PredatorArchy settings',
		['tooltip_statistics'] = 'Show statistics',
		['tooltip_dig'] = 'Dig'
	}
	local artifactColors = {
		[0] = {0.7, 0.7, 0.7},							-- for normal, 'grey' artifacts
		[1] = {0, 0.3, 0.9}								-- for the exciting rare artifacts ;)
	}


-- *********************************************************************************
-- *** DON'T EDIT BEYOND THIS LINE!!! **********************************************
-- *********************************************************************************

	local numArchRaces = 10			-- made this static, so we don't have to wait for PLAYER_ALIVE on login
	local diggingSpellID = 80451
	local digRangeIndicator = {
		['green'] = 1,
		['yellow'] = 3,
	}

	--[[
		This table holds all information about the races, including their current active
		fragment count
	]]
	local PredatorArchy, PredatorArchyArtifacts, PredatorArchyDigSites, PredatorArchyMenu, PredatorArchyMinimapButton
	local currentSkill = 0
	local infoTable = {}
	local continentRaceTable = {
		[1] = {			-- Kalimdor
			[3] = true, 	-- Fossiles
			[4] = true,		-- Night Elves
			[7] = true,		-- Tol'vir
		},
		[2] = {			-- Eastern Kingdoms
			[1] = true,		-- Dwarf
			[3] = true, 	-- Fossiles
			[8] = true		-- Trolls
		},
		[3] = {			-- Outland
			[2] = true, 	-- Draenei
			[6] = true		-- Orcs
		},
		[4] = {			-- Northrend
			[4] = true,		-- Night Elves
			[5] = true,		-- Neruber
			[8] = true,		-- Trolls
			[9] = true		-- Vrykul
		}
	}
	local rareArtifactNums = {
		[1] = 4, 
		[2] = 2, 
		[3] = 5,
		[4] = 7, 
		[5] = 2, 
		[6] = 1, 
		[7] = 6,
		[8] = 3,
		[9] = 2,
		[10] = 0
	}
	local continentTable = {}
	local raceIDNameTable = {}
	local digSiteRaceTable = {
		[54097] = 1,	-- Ironband's Excavation Site 
		[54124] = 1,	-- Ironbeard's Tomb 
		[54126] = 1,	-- Whelgar's Excavation Site 
		[54127] = 3,	-- Greenwarden's Fossil Bank 
		[54129] = 1,	-- Thoradin's Wall 
		[54132] = 8,	-- Witherbark Digsite 
		[54133] = 1,	-- Thandol Span 
		[54134] = 1,	-- Dun Garok Digsite 
		[54135] = 3,	-- Southshore Fossil Field 
		[54136] = 1,	-- Aerie Peak Digsite 
		[54137] = 8,	-- Shadra'Alor Digsite 
		[54138] = 8,	-- Altar of Zul Digsite 
		[54139] = 8,	-- Jintha'Alor Lower City Digsite 
		[54140] = 8,	-- Jintha'Alor Upper City Digsite 
		[54141] = 8,	-- Agol'watha Digsite 
		[54832] = 1,	-- Hammertoe's Digsite 
		[54834] = 1,	-- Tomb of the Watchers Digsite 
		[54838] = 1,	-- Uldaman Entrance Digsite 
		[54862] = 8,	-- Sunken Temple Digsite 
		[54864] = 3,	-- Misty Reed Fossil Bank 
		[55350] = 4,	-- Twilight Grove Digsite 
		[55352] = 3,	-- Vul'Gol Fossil Bank 
		[55354] = 4,	-- Nazj'vel Digsite 
		[55356] = 4,	-- Zoram Strand Digsite 
		[55398] = 4,	-- Ruins of Ordil'Aran 
		[55400] = 4,	-- Ruins of Stardust 
		[55402] = 4,	-- Forest Song Digsite 
		[55404] = 4,	-- Stonetalon Peak
		[55406] = 4,	-- Ruins of Eldre'Thar 
		[55408] = 3,	-- Unearthed Grounds 
		[55410] = 1,	-- Bael Modan Digsite 
		[55412] = 4,	-- Ruins of Eldarath 
		[55414] = 4,	-- Ruins of Arkkoran 
		[55416] = 3,	-- Lakeridge Highway Fossil Bank 
		[55418] = 4,	-- Slitherblade Shore Digsite 
		[55420] = 4,	-- Ethel Rethor Digsite 
		[55422] = 3,	-- Valley of Bones 
		[55424] = 4,	-- Mannoroc Coven Digsite 
		[55426] = 3,	-- Kodo Graveyard 
		[55428] = 4,	-- Sargeron Digsite 
		[55434] = 3,	-- Red Reaches Fossil Bank 
		[55436] = 3,	-- Dreadmaul Fossil Field 
		[55438] = 1,	-- Grimsilt Digsite 
		[55440] = 1,	-- Pyrox Flats Digsite 
		[55442] = 1,	-- Western Ruins of Thaurissan 
		[55444] = 1,	-- Eastern Ruins of Thaurissan 
		[55446] = 3,	-- Terror Wing Fossil Field 
		[55448] = 8,	-- Zul'Mashar Digsite 
		[55450] = 4,	-- Quel'Lithien Lodge Digsite 
		[55452] = 3,	-- Infectis Scar Fossil Field 
		[55454] = 8,	-- Eastern Zul'Kunda Digsite 
		[55456] = 8,	-- Western Zul'Kunda Digsite 
		[55458] = 8,	-- Bal'lal Ruins Digsite 
		[55460] = 8,	-- Balia'mah Digsite 
		[55462] = 8,	-- Ziata'jai Digsite 
		[55464] = 8,	-- Eastern Zul'Mamwe Digsite 
		[55466] = 8,	-- Western Zul'Mamwe Digsite 
		[55468] = 3,	-- Savage Coast Raptor Fields 
		[55470] = 8,	-- Ruins of Aboraz 
		[55472] = 8,	-- Ruins of Jubuwal 
		[55474] = 8,	-- Gurubashi Arena Digsite 
		[55476] = 8,	-- Nek'mani Wellspring Digsite 
		[55478] = 3,	-- Felstone Fossil Field 
		[55480] = 3,	-- Northridge Fossil Filed 
		[55482] = 3,	-- Andorhal Fossil Bank 
		[55755] = 3,	-- Wyrmbog Fossil Field 
		[55757] = 3,	-- Quagmire Fossil Field 
		[56327] = 4,	-- Dire Maul Digsite 
		[56329] = 4,	-- Broken Commons Digsite 
		[56331] = 4,	-- Ravenwind Digsite 
		[56333] = 4,	-- Oneiros Digsite 
		[56335] = 4,	-- Solarsal Digsite 
		[56337] = 4,	-- Darkmist Digsite 
		[56339] = 4,	-- South Isildien Digsite 
		[56341] = 4,	-- North Isildien Digsite 
		[56343] = 4,	-- Constellas Digsite 
		[56345] = 4,	-- Morlos'Aran Digsite 
		[56347] = 4,	-- Jaedenar Digsite
		[56349] = 4,	-- Ironwood Digsite 
		[56351] = 4,	-- Lake Kel'Theril Digsite 
		[56354] = 4,	-- Owl Wing Thicket Digsite 
		[56356] = 4,	-- Frostwhisper Gorge Digsite 
		[56358] = 3,	-- Fields of Blood Fossil Bank 
		[56362] = 4,	-- Nightmare Scar Digsite 
		[56364] = 8,	-- Zul'Farrak Digsite 
		[56367] = 8,	-- Broken Pillar Digsite 
		[56369] = 8,	-- Eastmoon Ruins Digsite 
		[56371] = 8,	-- Southmoon Ruins Digsite 
		[56373] = 3,	-- Dunemaul Fossil Ridge 
		[56375] = 3,	-- Abyssal Sands Fossil Ridge 
		[56380] = 3,	-- Lower Lakkari Tar Pits 
		[56382] = 3,	-- Upper Lakkari Tar Pits 
		[56384] = 3,	-- Terror Run Fossil Field 
		[56386] = 3,	-- Screaming Reaches Fossil Field 
		[56388] = 3,	-- Marshlands Fossil Bank 
		[56390] = 4,	-- Southwind Village Digsite 
		[56392] = 6,	-- Gor'gaz Outpost Digsite 
		[56394] = 6,	-- Zeth'Gor Digsite 
		[56396] = 6,	-- Hellfire Basin Digsite 
		[56398] = 6,	-- Hellfire Citadel Digsite 
		[56400] = 2,	-- Sha'naar Digsite 
		[56402] = 2,	-- Boha'mu Ruins Digsite 
		[56404] = 2,	-- Twin Spire Ruins Digsite 
		[56406] = 2,	-- Ruins of Enkaat Digsite 
		[56408] = 2,	-- Arklon Ruins Digsite 
		[56410] = 2,	-- Ruins of Farahlon Digsite 
		[56412] = 6,	-- Ancestral Grounds Digsite 
		[56416] = 6,	-- Sunspring Post Digsite 
		[56418] = 6,	-- Laughing Skull Digsite 
		[56420] = 6,	-- Burning Blade Digsite 
		[56422] = 2,	-- Halaa Digsite 
		[56424] = 6,	-- Grangol'var Village Digsite 
		[56426] = 2,	-- Tuurem Digsite 
		[56428] = 6,	-- Bleeding Hollow Ruins Digsite 
		[56430] = 6,	-- Bonechewer Ruins Digsite 
		[56432] = 2,	-- Bone Wastes Digsite 
		[56434] = 2,	-- East Auchindoun Digsite 
		[56437] = 2,	-- West Auchindoun Digsite 
		[56439] = 2,	-- Illidari Point Digsite 
		[56441] = 2,	-- Coilskar Point Digsite 
		[56446] = 2,	-- Ruins of Baa'ri Digsite 
		[56448] = 2,	-- Eclipse Point Digsite 
		[56450] = 6,	-- Warden's Cage Digsite 
		[56455] = 6,	-- Dragonmaw Fortress 
		[56504] = 9,	-- Skorn Digsite 
		[56506] = 9,	-- Halgrind Digsite 
		[56508] = 9,	-- Wyrmskull Digsite 
		[56510] = 9,	-- Shield Hill Digsite 
		[56512] = 9,	-- Baleheim Digsite 
		[56514] = 9,	-- Nifflevar Digsite 
		[56516] = 9,	-- Gjalerbron Digsite 
		[56518] = 5,	-- Pit of Narjun Digsite 
		[56520] = 4,	-- Moonrest Gardens Digsite 
		[56522] = 5,	-- En'kilah Digsite 
		[56524] = 5,	-- Kolramas Digsite 
		[56526] = 4,	-- Riplash Ruins Digsite 
		[56528] = 4,	-- Violet Stand Digsite 
		[56530] = 4,	-- Ruins of Shandaral Digsite 
		[56533] = 8,	-- Altar of Sseratus Digsite 
		[56535] = 8,	-- Zim'Rhuk Digsite 
		[56537] = 8,	-- Zol'Heb Digsite 
		[56539] = 8,	-- Altar of Quetz'lun Digsite 
		[56541] = 5,	-- Talramas Digsite 
		[56543] = 9,	-- Voldrune Digsite 
		[56547] = 8,	-- Drakil'Jin Ruins Digsite 
		[56549] = 9,	-- Brunnhildar Village Digsite 
		[56551] = 9,	-- Sifreldar Village Digsite 
		[56553] = 9,	-- Valkyrion Digsite 
		[56555] = 5,	-- Scourgeholme Digsite 
		[56560] = 9,	-- Ymirheim Digsite 
		[56562] = 9,	-- Jotunheim Digsite 
		[56564] = 9,	-- Njorndar Village Digsite 
		[56566] = 4,	-- Ruins of Lar'donir Digsite 
		[56568] = 4,	-- Shrine of Goldrinn Digsite 
		[56570] = 4,	-- Grove of Aessina Digsite 
		[56572] = 4,	-- Sanctuary of Malorne Digsite 
		[56574] = 4,	-- Scorched Plain Digsite 
		[56576] = 4,	-- Quel'Dormir Gardens Digsite 
		[56578] = 4,	-- Nar'shola (Middle Tier) Digsite 
		[56580] = 4,	-- Biel'aran Ridge Digsite 
		[56583] = 1,	-- Dunwald Ruins Digsite 
		[56585] = 1,	-- Thundermar Ruins Digsite 
		[56587] = 1,	-- Humboldt Conflagration Digsite 
		[56589] = 1,	-- Grim Batol Digsite 
		[56591] = 7,	-- Khartut's Tomb Digsite 
		[56593] = 7,	-- Tombs of the Precursors Digsite 
		[56595] = 7,	-- Steps of Fate Digsite 
		[56597] = 7,	-- Neferset Digsite 
		[56599] = 7,	-- Orsis Digsite 
		[56601] = 7,	-- Ruins of Ammon Digsite 
		[56603] = 7,	-- Ruins of Khintaset Digsite 
		[56605] = 7,	-- Temple of Uldum Digsite 
		[56607] = 7,	-- Ruins of Ahmtul Digsite 
		[60350] = 7,	-- Ausgrabungsstätte am Flussdelta
		[60352] = 7,	-- Ausgrabungsstätte am Verfluchten Landeplatz
		[60354] = 7,	-- Ausgrabungsstätte am Kesetpass
		[60356] = 7, 	-- Ausgrabungsstätte der Felder von Akhenet
		[60358] = 7,	-- Ausgrabungsstätte am Obelisk der Sterne
		[60361] = 7,	-- Ausgrabungsstätte der Sahketwüste
		[60363] = 7,	-- Grabungsstätte bei Schnottz' Landeplatz
		[60442] = 5,	-- Ausgrabungsstätte des Schreckenstunnels
		[60444] = 5,	-- Ausbragungsstätte des Pestwaldes
	}
	local POIDigX1, POIDigX2, POIDigY1, POIDigY2 = WorldMap_GetPOITextureCoords(177)


	--[[
	
	]]
	local lib = {}
	local core = {}
	local ctrl = {}

	--[[ Popup for the confirmation of keystone-usage while solving an artifact
	
	]]
	StaticPopupDialogs['PREDATORARCHY_CONFIRM_SOLVE'] = {
		text = texts.solving_with_keystones,
		button1 = 'Ok',
		button2 = 'No',
		OnAccept = function()
			SolveArtifact()
		end,
		timeout = 0,
		whileDead = false,
		hideOnEscape = false,
	}

	--[[ Popup for the confirmation of reset
	
	]]
	StaticPopupDialogs['PREDATORARCHY_CONFIRM_RESET'] = {
		text = texts.confirm_reset,
		button1 = 'Ok',
		OnAccept = function()
			ctrl.Reset()
		end,
		timeout = 30,
		whileDead = false,
		hideOnEscape = false,
	}



	--[[ Debugging to ChatFrame
		VOID debugging(STRING text)
	]]
	lib.debugging = function(text)
		DEFAULT_CHAT_FRAME:AddMessage('|cffffd700PredatorArchy:|r |cffeeeeee'..text..'|r')
	end

	--[[ Debugging the whole InfoTable
		VOID DumpInfoTable()
	]]
	lib.DumpInfoTable = function()
	lib.debugging('Dump: '..numArchRaces)
		local i, race
		for i = 1, numArchRaces do
			race = GetArchaeologyRaceInfo(i)
			-- lib.debugging(race..':')
			lib.debugging(infoTable[race].name..', '..infoTable[race].keystoneID..', '..infoTable[race].frags..', '..infoTable[race].artifactFragsTotal)
		end
	end

	--[[ Creates a font-object
		FONTOBJECT CreateFontObject(FRAME parent, INT size, STRING font)
		Creates a font-object with the given 'parent' and 'size', using 'font'. Shadow and Outline are constant throughout the layout.
	]]
    lib.CreateFontObject = function(parent, size, font)
    	local fo = parent:CreateFontString(nil, 'OVERLAY')
    	fo:SetFont(font, size, 'OUTLINE')
    	fo:SetJustifyH('LEFT')
    	fo:SetShadowColor(0, 0, 0)
    	fo:SetShadowOffset(1, -1)
    	return fo
    end

	--[[
	
	]]
	lib.CreateBorder = function(frame)
		frame.tex[1] = frame:CreateTexture(nil, 'ARTWORK')
		frame.tex[1]:SetPoint('TOPLEFT', frame, 'TOPLEFT', -1, 1)
		frame.tex[1]:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', 0, 0)
		frame.tex[1]:SetTexture(textures.solid)
		frame.tex[1]:SetVertexColor(0, 0, 0, 1)
		frame.tex[2] = frame:CreateTexture(nil, 'ARTWORK')
		frame.tex[2]:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 1)
		frame.tex[2]:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 1, 0)
		frame.tex[2]:SetTexture(textures.solid)
		frame.tex[2]:SetVertexColor(0, 0, 0, 1)
		frame.tex[3] = frame:CreateTexture(nil, 'ARTWORK')
		frame.tex[3]:SetPoint('TOPLEFT', frame, 'TOPRIGHT', 0, 0)
		frame.tex[3]:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 1, -1)
		frame.tex[3]:SetTexture(textures.solid)
		frame.tex[3]:SetVertexColor(0, 0, 0, 1)
		frame.tex[4] = frame:CreateTexture(nil, 'ARTWORK')
		frame.tex[4]:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', -1, 0)
		frame.tex[4]:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, -1)
		frame.tex[4]:SetTexture(textures.solid)
		frame.tex[4]:SetVertexColor(0, 0, 0, 1)
	end

	--[[
	]]
	lib.CreateCtrlButton = function(parent, texture, caption)
		local tmp = CreateFrame('Button', nil, parent)
		tmp:SetSize(18, 18)
		tmp.tex = {}
		tmp.tex['icon'] = tmp:CreateTexture(nil, 'OVERLAY')
		tmp.tex['icon']:SetAllPoints(tmp)
		tmp.tex['icon']:SetTexture(texture)
		tmp.tex['icon']:SetVertexColor(0.7, 0.7, 0.7, 0.9)
		lib.CreateBorder(tmp)
		tmp:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)
		--[[
		tmp.caption = lib.CreateFontObject(tmp, 14, font)
		tmp.caption:SetPoint('CENTER')
		tmp.caption:SetText(caption)
		]]
		return tmp
	end

	--[[ Creates a StatusBar with border and text
		FRAME CreateStatusBar(FRAME parent)
	]]
	lib.CreateStatusBar = function(parent)
		local tmp = CreateFrame('StatusBar', nil, parent)
		tmp:SetHeight(20)
		tmp:SetStatusBarTexture(textures.bar)
		tmp:SetStatusBarColor(0.7, 0, 0)

		tmp.tex = {}
		tmp.tex['back'] = tmp:CreateTexture(nil, 'BACKGROUND')
		tmp.tex['back']:SetAllPoints(tmp)
		tmp.tex['back']:SetTexture(textures.bar)
		tmp.tex['back']:SetVertexColor(0.3, 0.3, 0.3, 1)

		tmp.text = lib.CreateFontObject(tmp, 14, font)
		tmp.text:SetPoint('LEFT', 5, 1)
		tmp.text:SetPoint('RIGHT', -15)
		tmp.text:SetJustifyH('LEFT')
		tmp.text:SetText('INIT')

		lib.CreateBorder(tmp)

		return tmp
	end


-- *********************************************************************************
-- ***** CORE FUNCTIONS ************************************************************
-- *********************************************************************************

	--[[ Updates the current archaeology skill
		VOID UpdateSkill(INT index)
		INT index is the index of the archaeology skill
	]]
	core.UpdateSkill = function(index)
		local name, _, current, max = GetProfessionInfo(index)
		currentSkill = current
		PredatorArchyArtifacts.Skill:SetMinMaxValues(0, max)
		PredatorArchyArtifacts.Skill:SetValue(current)
		PredatorArchyArtifacts.Skill.text:SetText(name..': '..current..'/'..max)
	end

	--[[ Updates the projects of the race
		VOID UpdateProject()
		Iterates over all (known) races, wheather or not they are currently shown.
		The function only updates the (internal) InfoTable, display is updated by UpdateArtifactWindow().
	]]
	core.UpdateProject = function()
		local i, raceName, raceFragsNeed, artifactName, artifactRarity, artifactIcon, artifactDesc, artifactKeystoneCount
		for i = 1, numArchRaces do
			raceName, _, _, _, raceFragsNeed = GetArchaeologyRaceInfo(i)
			artifactName, _, artifactRarity, artifactIcon, artifactDesc, artifactKeystoneCount = GetActiveArtifactByRace(i)
			if ( artifactName ) then
				-- lib.debugging(raceName..': '..artifactName)
				infoTable[raceName].artifactFragsTotal = raceFragsNeed
				infoTable[raceName].artifactName = artifactName
				infoTable[raceName].artifactRarity = artifactRarity
				infoTable[raceName].artifactIcon = artifactIcon
				infoTable[raceName].artifactDesc = artifactDesc
				infoTable[raceName].artifactKeystoneSlots = artifactKeystoneCount
			else 
				infoTable[raceName].artifactName = nil
			end
		end
	end

	--[[ Updates the artifact window (PredatorArchyArtifacts).
		VOID UpdateArtifactWindow()
	]]
	core.UpdateArtifactWindow = function()
		-- lib.debugging('UpdateArtifactWindow()')
		local i, race, raceFrags, line, lineCount
		lineCount = 1
		PredatorArchyArtifacts:SetHeight(330)
		for i = 1, numArchRaces do
			race, _, _, raceFrags = GetArchaeologyRaceInfo(i)
			infoTable[race].frags = raceFrags
			line = PredatorArchyArtifacts.Lines[lineCount]
			if ( (line) and (
				( core.CheckForSolvable(race) and infoTable[race].artifactFragsTotal > 0 ) or
				( PredatorArchyOptions.alwaysShowRare and infoTable[race].artifactRarity and ( infoTable[race].artifactRarity > 0 ) ) or
				( (PredatorArchyOptions.mode == texts.mode_custom) and PredatorArchyOptions.customMode[race] ) or
				( (PredatorArchyOptions.mode == texts.mode_fragments) and continentRaceTable[GetCurrentMapContinent()][i] ) or
				( (PredatorArchyOptions.mode == texts.mode_artifacts) and infoTable[race].artifactName ) or
				( PredatorArchyOptions.mode == texts.mode_all ) )
			) then
				line.race = race
				line:SetID(infoTable[race].ID)

				line.RaceButton.tex:SetTexture(infoTable[race].tex)
				line.ArtifactIcon.tex['icon']:SetTexture(infoTable[race].artifactIcon or nil)

				if ( infoTable[race].artifactName ) then
					line.Bar:SetMinMaxValues(0, infoTable[race].artifactFragsTotal)
					line.Bar:SetValue(infoTable[race].frags)
					line.Bar:SetStatusBarColor(unpack(artifactColors[infoTable[race].artifactRarity]))
					line.Bar.tex['back']:SetVertexColor(unpack(artifactColors[infoTable[race].artifactRarity]))
					line.Bar.tex['back']:SetAlpha(0.5)
					line.Bar.text:SetText(infoTable[race].frags..'/'..infoTable[race].artifactFragsTotal..' - '..infoTable[race].artifactName)
					if ( core.CheckForSolvable(race) ) then
						line.Bar.text:SetTextColor(0, 1, 0)
					else
						line.Bar.text:SetTextColor(1, 1, 1)
					end
					line.Bar:Show()
					line.ArtifactIcon:Show()
				else
					line.Bar:Hide()
					line.RaceButton.tex:SetDesaturated(true)
					line.ArtifactIcon:Hide()
				end
				line:Show()

				lineCount = lineCount + 1
			else
				PredatorArchyArtifacts:SetHeight(PredatorArchyArtifacts:GetHeight()-28)
			end
		end
		for i = lineCount, numArchRaces do
			line = PredatorArchyArtifacts.Lines[i]
			line:Hide()
			line.Bar:Hide()
			line.ArtifactIcon:Hide()
		end
	end

	--[[ Checks, if an artifact is solvable.
		BOOL CheckForSolvable(STRING race)
		
	]]
	core.CheckForSolvable = function(race)
		-- lib.debugging('CheckForSolvable()')
		if (
			( infoTable[race].frags >= infoTable[race].artifactFragsTotal ) or
			( ( infoTable[race].artifactKeystoneSlots ) and
			( (infoTable[race].frags + min(GetItemCount(infoTable[race].keystoneID), infoTable[race].artifactKeystoneSlots) * 12) >= infoTable[race].artifactFragsTotal ) )
		) then
			return true
		end
		return false
	end

	--[[ Triggers the solving of an artifact.
		VOID SolveArtifact(STRING race)
		If keystones must be used, a popup will be shown to confirm this, otherwise the solving is triggered.
	]]
	core.SolveArtifact = function(race)
		if ( not core.CheckForSolvable(race) ) then
			lib.debugging(texts.notsolvable)
			return
		end
		local i, raceIndex
		-- look for the race index (are dwarfes always 1?!?)
		for i = 1, numArchRaces do
			if ( race == GetArchaeologyRaceInfo(i) ) then
				raceIndex = i
			end
		end
		SetSelectedArtifact(raceIndex)
		local numFragsCollected, numFragmentsAdded, numFragsRequired = GetArtifactProgress()
		local keystoneAmount = ceil((numFragsRequired-numFragsCollected)/12)
		-- lib.debugging(keystoneAmount)
		for i = 1, keystoneAmount do
			SocketItemToArtifact()
		end
		if ( keystoneAmount > 0 ) then
			StaticPopup_Show('PREDATORARCHY_CONFIRM_SOLVE')
		else
			SolveArtifact()
		end
	end

	--[[ Populates the race InfoTable
		VOID BuildInfoTable()
	]]
	core.BuildInfoTable = function()
		local i, raceName, raceTex, raceKeystoneID, raceFrags, raceFragsNeed, artifactName, artifactRarity, artifactIcon, artifactDesc, artifactKeystoneCount
		for i = 1, numArchRaces do
			raceName, raceTex, raceKeystoneID, raceFrags, raceFragsNeed = GetArchaeologyRaceInfo(i)
			raceIDNameTable[i] = raceName
			infoTable[raceName] = {
				['name'] = raceName, 
				['tex'] = raceTex,
				['keystoneID'] = raceKeystoneID,
				['frags'] = raceFrags or 0,
				['artifactFragsTotal'] = raceFragsNeed or 0,
				['ID'] = i
			}
			artifactName, _, artifactRarity, artifactIcon, artifactDesc, artifactKeystoneCount = GetActiveArtifactByRace(i)
			if ( artifactName ) then
				infoTable[raceName].artifactName = artifactName
				infoTable[raceName].artifactRarity = artifactRarity
				infoTable[raceName].artifactIcon = artifactIcon
				infoTable[raceName].artifactDesc = artifactDesc
				infoTable[raceName].artifactKeystoneSlots = artifactKeystoneCount
			else 
				infoTable[raceName].artifactName = nil
			end
		end
	end

	--[[ Populates the continent table
		VOID BuildContinentTable()
	]]
	core.BuildContinentTable = function()
		local cid, cname
		for cid, cname in pairs{GetMapContinents()} do
			-- lib.debugging(cid..': '..cname..' ('..mapid..')')
			continentTable[cid] = {}
			for zid, zname in pairs{GetMapZones(cid)} do
				SetMapZoom(cid, zid)
				local mapid = GetCurrentMapAreaID()
				-- lib.debugging('_'..zid..': '..zname..' ('..mapid..')')
				continentTable[cid][mapid] = zname
			end
		end
	end

	--[[ Finds the dig sites on the current continent
		VOID FindDigSiteOnContinent()
		This function works by iterating through all zones of a continent.
		This way, it is possible to use just IDs, rather than names.
	]]
	core.FindDigSiteOnContinent = function()
		SetMapToCurrentZone()
		local cid = GetCurrentMapContinent()
		-- lib.debugging('Kontinent: '..cid)
		local zid, zname, numDigSites, blobID, i, line
		line = 1
		for zid, zname in pairs(continentTable[cid]) do
			-- lib.debugging('_'..zid..': '..zname)
			SetMapByID(zid)
			numDigSites = ArchaeologyMapUpdateAll()
			if ( numDigSites > 0 ) then
				for i = 1, numDigSites do
					blobID = ArcheologyGetVisibleBlobID(i)
					-- lib.debugging('found dig site '..blobID..' in '..zname)
					-- lib.debugging(raceIDNameTable[digSiteRaceTable[blobID]]..' in '..zname)
					if ( digSiteRaceTable[blobID] ) then
						PredatorArchyDigSites.Lines[line].tex:SetTexture(infoTable[raceIDNameTable[digSiteRaceTable[blobID]]].tex)
						PredatorArchyDigSites.Lines[line].text:SetText(zname)
						PredatorArchyDigSites.Lines[line]:SetID(zid)
					else
						PredatorArchyDigSites.Lines[line].tex:SetTexture()
						PredatorArchyDigSites.Lines[line].text:SetText('MISSING: '..blobID)
					end
					line = line + 1
				end
			end
		end
	end

	--[[ Displays the DigSites in the TaxiMap
		VOID FindDigSitesOnTaxiMap()
	]]
	core.FindDigSitesOnTaxiMap = function()
		-- lib.debugging('FindDigSitesOnTaxiMap()')
		local taxiFrame, taxiWidth, taxiHeight, worldWidth, i, lmName, lmTex, lmX, lmY, digSiteName, digSite
		local digSites = {}
		local mapBackup = GetCurrentMapAreaID()

		SetMapToCurrentZone()
		SetMapZoom(GetCurrentMapContinent())

		taxiFrame = _G['TaxiRouteMap']
		taxiWidth = taxiFrame:GetWidth()
		taxiHeight = taxiFrame:GetHeight()
		worldWidth = WorldMapFrame:GetWidth()

		for i = 1, GetNumMapLandmarks() do
			lmName, _, lmTex, lmX, lmY = GetMapLandmarkInfo(i)
			if ( lmTex == 177 ) then
				digSiteName = 'WorldMapFramePOIdigsite'..i
				digSite = _G[digSiteName]
				if ( not digSite ) then
					WorldMap_CreatePOI('digsite'..i)
					digSite = _G[digSiteName]
				end
				digSite:SetParent(taxiFrame)
				_G[digSiteName..'Texture']:SetTexCoord(POIDigX1, POIDigX2, POIDigY1, POIDigY2)

				digSite:EnableMouse(false)
				digSite:SetPoint('CENTER', taxiFrame, 'TOPLEFT', (taxiWidth/2)+((lmX*worldWidth)-worldWidth/2)*(630/1000), -lmY*taxiHeight)
				digSite:SetScale(1)
				digSite:Show()
			end
		end

		SetMapByID(mapBackup)
	end

	--[[
	
	]]
	core.DigPositionX = 0
	core.DigPositionY = 0
	core.UpdateDigRange = function(self, event, unit, _, _, _, spellID)
		if ( (unit ~= 'player') or (spellID~=diggingSpellID) ) then return end
		core.DigPositionX, core.DigPositionY = GetPlayerMapPosition('player')
		-- lib.debugging('digging@'..core.DigPositionX..'/'..core.DigPositionY)
		self.TimeSinceLastUpdate = 0
		self.StartOnUpdate = 0
		self:SetScript('OnUpdate', function(self, elapsed)
			self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
			self.StartOnUpdate = self.StartOnUpdate + elapsed
			if ( self.StartOnUpdate > 10 ) then
				lib.debugging('too late')
				self:SetScript('OnUpdate', nil)
				self:SetValue(0)
			end
			if ( self.TimeSinceLastUpdate > 0.5 ) then
				local x, y = GetPlayerMapPosition('player')
				-- local range = ((100*core.DigPositionX-100*x)*(100*core.DigPositionX-100*x))+((100*core.DigPositionY-100*y)*(100*core.DigPositionY-100*y))
				local xOff, yOff = core.DigPositionX-x, core.DigPositionY-y
				local range = sqrt((xOff*xOff)+(yOff*yOff))
				lib.debugging(xOff..'/'..yOff..' = '..range)
				if ( range < digRangeIndicator['green'] ) then
					self:SetStatusBarColor(0, 0.7, 0, 1)
					self:SetValue(range)
				elseif ( range < digRangeIndicator['yellow'] ) then
					self:SetStatusBarColor(0.7, 0.7, 0, 1)
					self:SetValue(range)
				else
					self:SetStatusBarColor(0.7, 0, 0, 1)
					self:SetValue(range)
				end
				self.TimeSinceLastUpdate = 0
			end
		end)
	end

	--[[ Prints statistics about your digging
		VOID PrintStatistics()
	]]
	core.PrintStatistics = function()
		local i, j, raceName, raceCount, raceRar, curName, curRar, curCount, maxName, maxCount
		RequestArtifactCompletionHistory()
		maxName = ''
		maxCount = 0
		lib.debugging(texts.stats)
		for i = 1, numArchRaces do
			raceName = GetArchaeologyRaceInfo(i)
			raceCount = 0
			raceRar = 0
			for j = 1, GetNumArtifactsByRace(i) do
				curName, _, curRar, _, _, _, _, _, curCount = GetArtifactInfoByRace(i, j)
				if ( curCount > maxCount ) then
					maxName = curName
					maxCount = curCount
				end
				if ( curRar == 1 ) then
					raceRar = raceRar + curCount
				end
				raceCount = raceCount + curCount
			end
			if ( raceCount > 0 ) then
				lib.debugging(raceName..': '..raceCount..' ('..raceRar..'/'..rareArtifactNums[i]..' '..texts.rare..')')
			end
		end
		lib.debugging(texts.max_solved..': '..maxName..' ('..maxCount..')')
	end


-- *********************************************************************************
-- ***** CONTROL FUNCTIONS *********************************************************
-- *********************************************************************************

	--[[
	
	]]
	ctrl.MinimapShapes = {
		['ROUND'] = {true, true, true, true},
		['SQUARE'] = {false, false, false, false},
		['CORNER-TOPLEFT'] = {true, false, false, false},
		['CORNER-TOPRIGHT'] = {false, false, true, false},
		['CORNER-BOTTOMLEFT'] = {false, true, false, false},
		['CORNER-BOTTOMRIGHT'] = {false, false, false, true},
		['SIDE-LEFT'] = {true, true, false, false},
		['SIDE-RIGHT'] = {false, false, true, true},
		['SIDE-TOP'] = {true, false, true, false},
		['SIDE-BOTTOM'] = {false, true, false, true},
		['TRICORNER-TOPLEFT'] = {true, true, true, false},
		['TRICORNER-TOPRIGHT'] = {true, false, true, true},
		['TRICORNER-BOTTOMLEFT'] = {true, true, false, true},
		['TRICORNER-BOTTOMRIGHT'] = {false, true, true, true},
	}

	--[[ Updates the Position of the Minimap button
		VOID SetMinimapButtonPos()
	]]
	ctrl.SetMinimapButtonPos = function()
		local angle = math.rad(PredatorArchyOptions.minimapButtonAngle)
		local x, y, q = math.cos(angle), math.sin(angle), 1
		if ( x < 0 ) then q = q+1 end
		if ( y > 0 ) then q = q+2 end
		local shape = GetMinimapShape() or 'ROUND'
		local quadTable = ctrl.MinimapShapes[shape]
		if ( quadTable[q] ) then
			x, y = x*80, y*80
		else
			local diagRad = 103.12308498985
			x = math.max(-80, math.min(x*diagRad, 80))
			y = math.max(-80, math.min(y*diagRad, 80))
		end
		PredatorArchyMinimapButton:SetPoint('CENTER', Minimap, 'CENTER', x, y)
	end

	--[[ Shows the frames and registers the events
		VOID Show()
	]]
	ctrl.Show = function()
		PredatorArchyOptions.state = true
		core.BuildInfoTable()
		PredatorArchyArtifacts:Show()
		PredatorArchyDigSites:Show()
		core.UpdateProject()
		core.UpdateArtifactWindow()
		core.FindDigSiteOnContinent()

		PredatorArchy:RegisterEvent('CHAT_MSG_CURRENCY')
		PredatorArchy:RegisterEvent('ARTIFACT_UPDATE')
		PredatorArchy:RegisterEvent('ARTIFACT_DIG_SITE_UPDATED')
		PredatorArchy:RegisterEvent('ZONE_CHANGED_NEW_AREA')
		PredatorArchy:RegisterEvent('TAXIMAP_OPENED')
	end

	--[[ Hides the frames
		VOID Hide()
	]]
	ctrl.Hide = function()
		PredatorArchyOptions.state = false
		PredatorArchyArtifacts:Hide()
		PredatorArchyDigSites:Hide()
	end

	--[[ Sends the addon to sleep and unregisters the events
		VOID Sleep()
	]]
	ctrl.Sleep = function()
		PredatorArchyOptions.state = false
		PredatorArchy:UnregisterEvent('PLAYER_ALIVE')
		PredatorArchy:UnregisterEvent('CHAT_MSG_CURRENCY')
		PredatorArchy:UnregisterEvent('ARTIFACT_UPDATE')
		PredatorArchy:UnregisterEvent('ARTIFACT_DIG_SITE_UPDATED')
		PredatorArchy:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
		PredatorArchy:UnregisterEvent('TAXIMAP_OPENED')
		ctrl.Hide()
	end

	--[[ Sets the default-values of the SavedVars
		VOID SetDefaults()
	]]
	ctrl.SetDefaults = function()
		PredatorArchyOptions = {}
		PredatorArchyOptions.state = true
		PredatorArchyOptions.mode = texts.mode_all
		PredatorArchyOptions.customMode = {}
		PredatorArchyOptions.PredatorArchyArtifacts = {
			['point'] = 'CENTER', 
			['relPoint'] = 'CENTER', 
			['x'] = 0,
			['y'] = 0
		}
		PredatorArchyOptions.PredatorArchyDigSites = {
			['point'] = 'CENTER', 
			['relPoint'] = 'CENTER', 
			['x'] = 0,
			['y'] = 0
		}
	end

	--[[ Resets all settings to default
		VOID Reset()
	]]
	ctrl.Reset = function()
		ctrl.SetDefaults()
		core.BuildInfoTable()
		core.UpdateArtifactWindow()
		PredatorArchyArtifacts:ClearAllPoints()
		PredatorArchyArtifacts:SetPoint(PredatorArchyOptions['PredatorArchyArtifacts'].point, UIParent, PredatorArchyOptions['PredatorArchyArtifacts'].relPoint, PredatorArchyOptions['PredatorArchyArtifacts'].x, PredatorArchyOptions['PredatorArchyArtifacts'].y)
		PredatorArchyDigSites:ClearAllPoints()
		PredatorArchyDigSites:SetPoint(PredatorArchyOptions['PredatorArchyDigSites'].point, UIParent, PredatorArchyOptions['PredatorArchyDigSites'].relPoint, PredatorArchyOptions['PredatorArchyDigSites'].x, PredatorArchyOptions['PredatorArchyDigSites'].y)
	end

	--[[ Toggles the windows between Show() and Sleep()
		VOID Toggle()
	]]
	ctrl.Toggle = function()
		if ( PredatorArchyOptions.state ) then
			ctrl.Sleep()
		else
			ctrl.Show()
		end
	end

	--[[ Controls what happens while using a slash-command
		VOID SlashCmdHandler(STRING msg, EDITBOX editbox)
		Remember that the SlashCmds are '/predatorarchy' and '/pa'
	]]
	ctrl.SlashCmdHandler = function(msg, editbox)
		local cmd, param = msg:match('^(%S*)%s*(.-)$')
		if ( cmd == 'show' ) then
			lib.debugging('Shows up...')
			ctrl.Show()
		elseif ( cmd == 'hide' ) then
			lib.debugging('Is now hidden...')
			ctrl.Hide()
		elseif ( cmd == 'sleep' ) then
			lib.debugging('Is now sleeping...')
			ctrl.Sleep()
		elseif ( cmd == 'toggle' ) then
			ctrl.Toggle()
		elseif ( cmd == 'reset' ) then
			StaticPopup_Show('PREDATORARCHY_CONFIRM_RESET')
		else
			lib.debugging('/pa [show | hide | sleep | reset]')
			lib.debugging('  show - shows the PredatorArchy windows')
			lib.debugging('  hide - hides the windows')
			lib.debugging('  sleep - sends the addon to sleep and hides the windows')
			lib.debugging('  reset - resets the settings')
		end
	end

	--[[
	
	]]
	ctrl.MinimapButtonHandler = function(frame, button)
		if ( button == 'LeftButton' ) then
			ctrl.Toggle()
		elseif ( button == 'RightButton' ) then
			ToggleDropDownMenu(1, nil, frame.DropDown, frame, 0, -5)
		end
	end


-- *********************************************************************************

PredatorArchy = CreateFrame('Frame', 'PredatorArchy', UIParent)
PredatorArchy:RegisterEvent('PLAYER_LOGIN')
PredatorArchy:SetScript('OnEvent', function(self)
	local _, _, hasArch = GetProfessions()
	if ( not hasArch ) then
		lib.debugging(texts.noskill)
		return
	end

	core.BuildInfoTable()

	core.UpdateArtifactWindow()
	core.UpdateSkill(hasArch)

	core.BuildContinentTable()
	core.FindDigSiteOnContinent()
	
	-- build the event handler
	if ( PredatorArchyOptions.state ) then
		self:RegisterEvent('PLAYER_ALIVE')
		self:RegisterEvent('CHAT_MSG_CURRENCY')
		self:RegisterEvent('ARTIFACT_UPDATE')
		self:RegisterEvent('ARTIFACT_DIG_SITE_UPDATED')
		self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
		self:RegisterEvent('TAXIMAP_OPENED')
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
		PredatorArchyArtifacts:Show()
		PredatorArchyDigSites:Show()
	end
	self:UnregisterEvent('PLAYER_LOGIN')
	self:SetScript('OnEvent', function(self, event)
		-- lib.debugging(event)
		if ( event == 'PLAYER_ALIVE' ) then
			core.BuildInfoTable()
			core.UpdateArtifactWindow()
			core.FindDigSiteOnContinent()
			self:UnregisterEvent('PLAYER_ALIVE')
		elseif ( event == 'CHAT_MSG_CURRENCY' ) then
			if ( currentSkill < 100 ) then
				core.UpdateSkill(hasArch)
			end
			core.UpdateArtifactWindow()
		elseif ( event == 'ARTIFACT_UPDATE' ) then
			core.UpdateSkill(hasArch)
			core.UpdateProject()
			core.UpdateArtifactWindow()
		elseif ( event == 'ARTIFACT_DIG_SITE_UPDATED' ) then
			core.FindDigSiteOnContinent()
		elseif ( event == 'ZONE_CHANGED_NEW_AREA' ) then
			core.FindDigSiteOnContinent()
		elseif ( event == 'TAXIMAP_OPENED' ) then
			core.FindDigSitesOnTaxiMap()
		elseif ( event == 'PLAYER_REGEN_ENABLED' ) then
			PredatorArchyArtifacts.Ctrl.DigIndicator:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
		elseif ( event == 'PLAYER_REGEN_DISABLED' ) then
			PredatorArchyArtifacts.Ctrl.DigIndicator:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
		end
	end)

end)


-- *********************************************************************************

local loader = CreateFrame('Frame')
loader:RegisterEvent('ADDON_LOADED')
loader:SetScript('OnEvent', function(self, event, addon)
	if ( addon ~= 'PredatorArchy' ) then
		return
	end

	local i, tmp

	--[[
		SAVED VARIABLES
	]]
	if ( not PredatorArchyOptions ) then
		ctrl.SetDefaults()
	else
		if ( not PredatorArchyOptions.state ) then
			PredatorArchyOptions.state = (PredatorArchyOptions.state and true) or false
		end
		if ( not PredatorArchyOptions.mode ) then
			PredatorArchyOptions.mode = texts.mode_all
		end
		if ( not PredatorArchyOptions.customMode ) then
			PredatorArchyOptions.customMode = {}
		end
		if ( not PredatorArchyOptions.alwaysShowRare ) then
			PredatorArchyOptions.alwaysShowRare = (PredatorArchyOptions.alwaysShowRare and true) or false
		end
		if ( not PredatorArchyOptions.showMinimapButton ) then
			PredatorArchyOptions.showMinimapButton = (PredatorArchyOptions.showMinimapButton and true) or false
		end
		if ( not PredatorArchyOptions.minimapButtonAngle ) then
			PredatorArchyOptions.minimapButtonAngle = 45
		end
		if ( not PredatorArchyOptions.PredatorArchyArtifacts ) then
			PredatorArchyOptions.PredatorArchyArtifacts = {
				['point'] = 'CENTER', 
				['relPoint'] = 'CENTER', 
				['x'] = 0,
				['y'] = 0
			}
		end
		if ( not PredatorArchyOptions.PredatorArchyDigSites ) then
			PredatorArchyOptions.PredatorArchyDigSites = {
				['point'] = 'CENTER', 
				['relPoint'] = 'CENTER', 
				['x'] = 0,
				['y'] = 0
			}
		end
	end

	--[[
		PREDATOR ARCHY ARTIFACTS
	]]
	if ( not PredatorArchyArtifacts ) then
		PredatorArchyArtifacts = CreateFrame('Frame', 'PredatorArchyArtifacts', UIParent)
		PredatorArchyArtifacts:SetBackdrop( {
			bgFile = textures.solid,
			edgeFile = textures.border,
			tile = false,
			edgeSize = 8,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		} )
		PredatorArchyArtifacts:SetBackdropColor(0, 0, 0, 0.7)
		PredatorArchyArtifacts:SetWidth(artifactsWidth)
		PredatorArchyArtifacts:SetHeight(330)
		PredatorArchyArtifacts:EnableMouse(true)
		PredatorArchyArtifacts:SetMovable(true)
		PredatorArchyArtifacts:RegisterForDrag('LeftButton')
		PredatorArchyArtifacts:SetScript('OnDragStart', function(self)
			if ( IsAltKeyDown() ) then
				self:StartMoving()
			end
		end)
		PredatorArchyArtifacts:SetScript('OnDragStop', function(self)
			self:StopMovingOrSizing()
			local point, _, relPoint, x, y = self:GetPoint(1)
			PredatorArchyOptions['PredatorArchyArtifacts'].point = point
			PredatorArchyOptions['PredatorArchyArtifacts'].relPoint = relPoint
			PredatorArchyOptions['PredatorArchyArtifacts'].x = x
			PredatorArchyOptions['PredatorArchyArtifacts'].y = y
		end)
		PredatorArchyArtifacts:ClearAllPoints()
		PredatorArchyArtifacts:SetPoint(PredatorArchyOptions['PredatorArchyArtifacts'].point, UIParent, PredatorArchyOptions['PredatorArchyArtifacts'].relPoint, PredatorArchyOptions['PredatorArchyArtifacts'].x, PredatorArchyOptions['PredatorArchyArtifacts'].y)

		PredatorArchyArtifacts.Skill = lib.CreateStatusBar(PredatorArchyArtifacts)
		PredatorArchyArtifacts.Skill:SetPoint('TOPLEFT', PredatorArchyArtifacts, 'TOPLEFT', 15, -10)
		PredatorArchyArtifacts.Skill:SetPoint('RIGHT', PredatorArchyArtifacts, 'RIGHT', -15, 0)
		PredatorArchyArtifacts.Skill:SetStatusBarColor(0, 0.7, 0)
		PredatorArchyArtifacts.Skill.text:ClearAllPoints()
		PredatorArchyArtifacts.Skill.text:SetPoint('CENTER', 0, 1)
		PredatorArchyArtifacts.Skill.text:SetJustifyH('CENTER')
		PredatorArchyArtifacts.Skill:EnableMouse(true)
		PredatorArchyArtifacts.Skill:SetScript('OnMouseUp', function(self)
			self:Hide()
			PredatorArchyArtifacts.Ctrl:Show()
		end)

		PredatorArchyArtifacts.Ctrl = CreateFrame('Frame', nil, PredatorArchyArtifacts)
		PredatorArchyArtifacts.Ctrl:SetPoint('TOPLEFT', PredatorArchyArtifacts.Skill, 'TOPLEFT', 0, -1)
		PredatorArchyArtifacts.Ctrl:SetPoint('BOTTOMRIGHT', PredatorArchyArtifacts.Skill)

		PredatorArchyArtifacts.Ctrl.ShowSkillButton = lib.CreateCtrlButton(PredatorArchyArtifacts.Ctrl, textures.button_back, '<')
		PredatorArchyArtifacts.Ctrl.ShowSkillButton:SetPoint('TOPLEFT')
		PredatorArchyArtifacts.Ctrl.ShowSkillButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_showSkill)
			GameTooltip:Show()
		end)
		PredatorArchyArtifacts.Ctrl.ShowSkillButton:SetScript('OnClick', function()
			PredatorArchyArtifacts.Ctrl:Hide()
			PredatorArchyArtifacts.Skill:Show()
		end)

		PredatorArchyArtifacts.Ctrl.OpenConfigButton = lib.CreateCtrlButton(PredatorArchyArtifacts.Ctrl, textures.button_config, 'C')
		PredatorArchyArtifacts.Ctrl.OpenConfigButton:SetPoint('TOPLEFT', PredatorArchyArtifacts.Ctrl.ShowSkillButton, 'TOPRIGHT', 15, 0)
		PredatorArchyArtifacts.Ctrl.OpenConfigButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_openConfig)
			GameTooltip:Show()
		end)
		PredatorArchyArtifacts.Ctrl.OpenConfigButton:SetScript('OnClick', function()
			InterfaceOptionsFrame_OpenToCategory(PredatorArchyMenu)
		end)

		PredatorArchyArtifacts.Ctrl.HideButton = lib.CreateCtrlButton(PredatorArchyArtifacts.Ctrl, textures.button_hide, '-')
		PredatorArchyArtifacts.Ctrl.HideButton:SetPoint('TOPLEFT', PredatorArchyArtifacts.Ctrl.OpenConfigButton, 'TOPRIGHT', 5, 0)
		PredatorArchyArtifacts.Ctrl.HideButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_hide)
			GameTooltip:Show()
		end)
		PredatorArchyArtifacts.Ctrl.HideButton:SetScript('OnClick', ctrl.Hide)

		PredatorArchyArtifacts.Ctrl.SleepButton = lib.CreateCtrlButton(PredatorArchyArtifacts.Ctrl, textures.button_sleep, '_')
		PredatorArchyArtifacts.Ctrl.SleepButton:SetPoint('TOPLEFT', PredatorArchyArtifacts.Ctrl.HideButton, 'TOPRIGHT', 5, 0)
		PredatorArchyArtifacts.Ctrl.SleepButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_sleep)
			GameTooltip:Show()
		end)
		PredatorArchyArtifacts.Ctrl.SleepButton:SetScript('OnClick', ctrl.Sleep)

		PredatorArchyArtifacts.Ctrl.StatisticsButton = lib.CreateCtrlButton(PredatorArchyArtifacts.Ctrl, textures.button_statistics, 'S')
		PredatorArchyArtifacts.Ctrl.StatisticsButton:SetPoint('TOPLEFT', PredatorArchyArtifacts.Ctrl.SleepButton, 'TOPRIGHT', 15, 0)
		PredatorArchyArtifacts.Ctrl.StatisticsButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_statistics)
			GameTooltip:Show()
		end)
		PredatorArchyArtifacts.Ctrl.StatisticsButton:SetScript('OnClick', core.PrintStatistics)

		PredatorArchyArtifacts.Ctrl.DigButton = lib.CreateCtrlButton(PredatorArchyArtifacts.Ctrl, textures.button_sleep, 'D')
		PredatorArchyArtifacts.Ctrl.DigButton:SetPoint('TOPRIGHT')
		PredatorArchyArtifacts.Ctrl.DigButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_dig)
			GameTooltip:Show()
		end)

		PredatorArchyArtifacts.Ctrl.DigIndicator = lib.CreateStatusBar(PredatorArchyArtifacts.Ctrl)
		PredatorArchyArtifacts.Ctrl.DigIndicator.text:Hide()
		PredatorArchyArtifacts.Ctrl.DigIndicator.text = nil
		PredatorArchyArtifacts.Ctrl.DigIndicator:SetMinMaxValues(0, 10)
		PredatorArchyArtifacts.Ctrl.DigIndicator:SetValue(0)
		PredatorArchyArtifacts.Ctrl.DigIndicator:SetPoint('TOPLEFT', PredatorArchyArtifacts.Ctrl.StatisticsButton, 'TOPRIGHT', 15, 0)
		PredatorArchyArtifacts.Ctrl.DigIndicator:SetPoint('BOTTOMRIGHT', PredatorArchyArtifacts.Ctrl.DigButton, 'BOTTOMLEFT', -15, 0)
		PredatorArchyArtifacts.Ctrl.DigIndicator:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
		PredatorArchyArtifacts.Ctrl.DigIndicator:SetScript('OnEvent', core.UpdateDigRange)

		PredatorArchyArtifacts.Ctrl:Hide()

		PredatorArchyArtifacts.Lines = {}
		for i = 1, numArchRaces do
			tmp = CreateFrame('Frame', nil, PredatorArchyArtifacts)
			tmp:SetHeight(artifactsLineHeight)
			tmp:SetPoint('TOPLEFT', PredatorArchyArtifacts.Skill, 'TOPLEFT', -5, (-i*artifactsLineHeight))
			tmp:SetPoint('RIGHT', PredatorArchyArtifacts.Skill, 'RIGHT', 2, 0)
			PredatorArchyArtifacts.Lines[i] = tmp

			-- Race Icon
			tmp = CreateFrame('Button', nil, PredatorArchyArtifacts.Lines[i])
			tmp:SetSize(24, 24)
			tmp:SetPoint('TOPLEFT')
			tmp.tex = tmp:CreateTexture(nil, 'OVERLAY')
			tmp.tex:SetAllPoints(tmp)
			tmp.tex:SetTexCoord(0, 0.6, 0, 0.6)
			tmp:SetScript('OnEnter', function(self)
				local race = self:GetParent().race
				GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
				GameTooltip:AddLine(race)
				GameTooltip:AddLine(texts.keystones..': '..GetItemCount(infoTable[race].keystoneID), 1, 1, 1, 1)
				GameTooltip:Show()
			end)
			tmp:SetScript('OnLeave', function()
				GameTooltip:Hide()
			end)
			tmp:SetScript('OnClick', function(self)
				ArchaeologyFrame_Show()
				ArchaeologyFrame_ShowArtifact(self:GetParent():GetID())
			end)
			PredatorArchyArtifacts.Lines[i].RaceButton = tmp

			-- Artifact Icon
			tmp = CreateFrame('Button', nil, PredatorArchyArtifacts.Lines[i])
			tmp:SetSize(20, 20)
			tmp:SetPoint('TOPRIGHT', 0, -4)
			tmp.tex = {}
			tmp.tex['icon'] = tmp:CreateTexture(nil, 'OVERLAY')
			tmp.tex['icon']:SetAllPoints(tmp)
			tmp.tex['icon']:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			lib.CreateBorder(tmp)
			tmp:SetScript('OnEnter', function(self)
				local race = self:GetParent().race
				GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
				GameTooltip:AddLine(infoTable[race].artifactName or '')
				GameTooltip:AddLine(infoTable[race].artifactDesc or '', 1, 1, 1, 1, 1)
				GameTooltip:SetWidth(200)
				GameTooltip:Show()
			end)
			tmp:SetScript('OnLeave', function()
				GameTooltip:Hide()
			end)
			tmp:SetScript('OnClick', function(self)
				core.SolveArtifact(self:GetParent().race)
			end)
			PredatorArchyArtifacts.Lines[i].ArtifactIcon = tmp

			-- Progress Bar
			tmp = lib.CreateStatusBar(PredatorArchyArtifacts.Lines[i])
			tmp:SetPoint('TOPLEFT', PredatorArchyArtifacts.Lines[i].RaceButton, 'TOPRIGHT', 5, -4)
			tmp:SetPoint('RIGHT', PredatorArchyArtifacts.Lines[i].ArtifactIcon, 'LEFT', -7, 0)
			PredatorArchyArtifacts.Lines[i].Bar = tmp
		end
	end

	--[[
		PREDATOR ARCHY DIG SITES
	]]
	if ( not PredatorArchyDigSites ) then
		PredatorArchyDigSites = CreateFrame('Frame', 'PredatorArchyDigSites', UIParent)
		PredatorArchyDigSites:SetBackdrop( {
			bgFile = textures.solid,
			edgeFile = textures.border,
			tile = false,
			edgeSize = 8,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		} )
		PredatorArchyDigSites:SetBackdropColor(0, 0, 0, 0.7)
		PredatorArchyDigSites:SetWidth(digSitesWidth)
		PredatorArchyDigSites:SetHeight(122)
		PredatorArchyDigSites:EnableMouse(true)
		PredatorArchyDigSites:SetMovable(true)
		PredatorArchyDigSites:RegisterForDrag('LeftButton')
		PredatorArchyDigSites:SetScript('OnDragStart', function(self)
			if ( IsAltKeyDown() ) then
				self:StartMoving()
			end
		end)
		PredatorArchyDigSites:SetScript('OnDragStop', function(self)
			self:StopMovingOrSizing()
			local point, _, relPoint, x, y = self:GetPoint(1)
			PredatorArchyOptions['PredatorArchyDigSites'].point = point
			PredatorArchyOptions['PredatorArchyDigSites'].relPoint = relPoint
			PredatorArchyOptions['PredatorArchyDigSites'].x = x
			PredatorArchyOptions['PredatorArchyDigSites'].y = y
		end)
		PredatorArchyDigSites:ClearAllPoints()
		PredatorArchyDigSites:SetPoint(PredatorArchyOptions['PredatorArchyDigSites'].point, UIParent, PredatorArchyOptions['PredatorArchyDigSites'].relPoint, PredatorArchyOptions['PredatorArchyDigSites'].x, PredatorArchyOptions['PredatorArchyDigSites'].y)

		PredatorArchyDigSites.Lines = {}
		for i = 1, 4 do
			tmp = CreateFrame('Button', nil, PredatorArchyDigSites)
			tmp:SetHeight(26)
			if ( i == 1 ) then
				tmp:SetPoint('TOPLEFT', PredatorArchyDigSites, 'TOPLEFT', 10, -10)
			else
				tmp:SetPoint('TOPLEFT', PredatorArchyDigSites.Lines[i-1], 'BOTTOMLEFT')
			end
			tmp:SetPoint('RIGHT', PredatorArchyDigSites, 'RIGHT', -10, 0)

			tmp.tex = tmp:CreateTexture(nil, 'OVERLAY')
			tmp.tex:SetSize(24, 24)
			tmp.tex:SetTexCoord(0, 0.6, 0, 0.6)
			tmp.tex:SetPoint('TOPLEFT', tmp)
			tmp.text = lib.CreateFontObject(tmp, 14, font)
			tmp.text:SetPoint('TOPLEFT', tmp.tex, 'TOPRIGHT', 5, -6)
			tmp.text:SetPoint('RIGHT', tmp)
			tmp.text:SetText('Init')
			tmp:SetScript('OnClick', function(self)
				ShowUIPanel(WorldMapFrame)
				SetMapByID(self:GetID())
				WorldMapFrame.blockWorldMapUpdate = nil
			end)

			PredatorArchyDigSites.Lines[i] = tmp
		end
	end

	--[[
		CONFIGURATION WINDOW
	]]
	do
		tmp = CreateFrame('Frame', 'PredatorArchyMenu', UIParent)
		tmp.name = 'PredatorArchy'
		tmp.title = tmp:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		tmp.title:SetPoint('TOPLEFT', 16, -16)
		tmp.title:SetText('PredatorArchy')

		tmp.ShowButton = CreateFrame('Button', 'PredatorArchyMenuShowButton', tmp, 'OptionsButtonTemplate')
		tmp.ShowButton:SetText(texts.button_show)
		tmp.ShowButton:SetPoint('TOPLEFT', tmp.title, 'BOTTOMLEFT', 0, -20)
		tmp.ShowButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_show)
			GameTooltip:Show()
		end)
		tmp.ShowButton:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)
		tmp.ShowButton:SetScript('OnClick', ctrl.Show)

		tmp.HideButton = CreateFrame('Button', 'PredatorArchyMenuHideButton', tmp, 'OptionsButtonTemplate')
		tmp.HideButton:SetText(texts.button_hide)
		tmp.HideButton:SetPoint('TOPLEFT', tmp.ShowButton, 'TOPRIGHT', 5, 0)
		tmp.HideButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_hide)
			GameTooltip:Show()
		end)
		tmp.HideButton:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)
		tmp.HideButton:SetScript('OnClick', ctrl.Hide)

		tmp.SleepButton = CreateFrame('Button', 'PredatorArchyMenuSleepButton', tmp, 'OptionsButtonTemplate')
		tmp.SleepButton:SetText(texts.button_sleep)
		tmp.SleepButton:SetPoint('TOPLEFT', tmp.HideButton, 'TOPRIGHT', 5, 0)
		tmp.SleepButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_sleep)
			GameTooltip:Show()
		end)
		tmp.SleepButton:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)
		tmp.SleepButton:SetScript('OnClick', ctrl.Sleep)

		tmp.ResetButton = CreateFrame('Button', 'PredatorArchyMenuSleepButton', tmp, 'OptionsButtonTemplate')
		tmp.ResetButton:SetText(texts.button_reset)
		tmp.ResetButton:SetPoint('TOPLEFT', tmp.SleepButton, 'TOPRIGHT', 5, 0)
		tmp.ResetButton:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_CURSOR')
			GameTooltip:AddLine(texts.tooltip_reset)
			GameTooltip:Show()
		end)
		tmp.ResetButton:SetScript('OnLeave', function()
			GameTooltip:Hide()
		end)
		tmp.ResetButton:SetScript('OnClick', function()
			StaticPopup_Show('PREDATORARCHY_CONFIRM_RESET')
		end)

		tmp.AlwaysShowRare = CreateFrame('CheckButton', 'PredatorArchyMenuAlwaysShowRareCheckbox', tmp, 'InterfaceOptionsCheckButtonTemplate')
		_G['PredatorArchyMenuAlwaysShowRareCheckboxText']:SetText(texts.alwaysShowRareCaption)
		tmp.AlwaysShowRare:SetPoint('TOPLEFT', tmp.ShowButton, 'BOTTOMLEFT', 0, -30)
		tmp.AlwaysShowRare:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.alwaysShowRare = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)

		tmp.ShowMinimapButton = CreateFrame('CheckButton', 'PredatorArchyMenuShowMinimapButtonCheckbox', tmp, 'InterfaceOptionsCheckButtonTemplate')
		_G['PredatorArchyMenuShowMinimapButtonCheckboxText']:SetText(texts.showMinimapButtonCaption)
		tmp.ShowMinimapButton:SetPoint('TOPLEFT', tmp.SleepButton, 'BOTTOMLEFT', 0, -30)
		tmp.ShowMinimapButton:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.showMinimapButton = (self:GetChecked() and true or false)
			if ( self:GetChecked() ) then
				PredatorArchyMinimapButton:Show()
				ctrl.SetMinimapButtonPos()
			else
				PredatorArchyMinimapButton:Hide()
			end
		end)

		tmp.ModeDropDown = CreateFrame('Button', 'PredatorArchyMenuModeDropDown', tmp, 'UIDropDownMenuTemplate')
		tmp.ModeDropDown:SetPoint('TOPLEFT', tmp.ShowButton, 'BOTTOMLEFT', 50, -100)
		tmp.ModeDropDown:SetScript('OnShow', function(self)
			UIDropDownMenu_Initialize(self, function()
				local info = {}
				info.notCheckable = true

				info.text = texts.mode_all
				info.func = function()
					_G['PredatorArchyMenuModeDropDownText']:SetText(texts.mode_all)
					PredatorArchyOptions.mode = texts.mode_all
					PredatorArchyMenu.CustomMode:Hide()
					core.UpdateArtifactWindow()
				end
				UIDropDownMenu_AddButton(info)

				info.text = texts.mode_artifacts
				info.func = function()
					_G['PredatorArchyMenuModeDropDownText']:SetText(texts.mode_artifacts)
					PredatorArchyOptions.mode = texts.mode_artifacts
					PredatorArchyMenu.CustomMode:Hide()
					core.UpdateArtifactWindow()
				end
				UIDropDownMenu_AddButton(info)

				info.text = texts.mode_fragments
				info.func = function()
					_G['PredatorArchyMenuModeDropDownText']:SetText(texts.mode_fragments)
					PredatorArchyOptions.mode = texts.mode_fragments
					PredatorArchyMenu.CustomMode:Hide()
					core.UpdateArtifactWindow()
				end
				UIDropDownMenu_AddButton(info)

				info.text = texts.mode_custom
				info.func = function()
					_G['PredatorArchyMenuModeDropDownText']:SetText(texts.mode_custom)
					PredatorArchyOptions.mode = texts.mode_custom
					PredatorArchyMenu.CustomMode:Show()
					core.UpdateArtifactWindow()
				end
				UIDropDownMenu_AddButton(info)
			end)
		end)

		tmp.ModeCaption = tmp:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		tmp.ModeCaption:SetText(texts.mode_caption)
		tmp.ModeCaption:SetPoint('LEFT', tmp.ShowButton, 'LEFT', 10, 0)
		tmp.ModeCaption:SetPoint('TOP', tmp.ModeDropDown, 'TOP', 0, -10)

		tmp.CustomMode = CreateFrame('Frame', nil, tmp)
		tmp.CustomMode:SetPoint('LEFT', tmp.ShowButton, 'LEFT', 10, 0)
		tmp.CustomMode:SetPoint('RIGHT', tmp.ResetButton, 'RIGHT')
		tmp.CustomMode:SetPoint('TOP', tmp.ModeDropDown, 'BOTTOM', 0, -20)
		tmp.CustomMode:SetHeight(100)
		tmp.CustomMode.race = {}
		for i = 1, numArchRaces do
			tmp.CustomMode.race[i] = CreateFrame('CheckButton', 'PredatorArchyMenuRace'..i..'Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
			if ( i == 1 ) then
				tmp.CustomMode.race[i]:SetPoint('TOPLEFT', tmp.CustomMode, 'TOPLEFT')
			elseif ( i == 6 ) then
				tmp.CustomMode.race[i]:SetPoint('LEFT', tmp.CustomMode, 'CENTER')
				tmp.CustomMode.race[6]:SetPoint('TOP', tmp.CustomMode.race[1], 'TOP')
			else
				tmp.CustomMode.race[i]:SetPoint('TOPLEFT', tmp.CustomMode.race[i-1], 'BOTTOMLEFT', 0, -10)
			end
			tmp.CustomMode.race[i]:SetScript('OnClick', function(self)
				self:SetChecked((self:GetChecked() and true) or false)
				PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
				core.UpdateArtifactWindow()
			end)
		end

		tmp:SetScript('OnShow', function()
			local raceName
			_G['PredatorArchyMenuModeDropDownText']:SetText(PredatorArchyOptions.mode)
			_G['PredatorArchyMenuAlwaysShowRareCheckbox']:SetChecked(PredatorArchyOptions.alwaysShowRare and true or false)
			_G['PredatorArchyMenuShowMinimapButtonCheckbox']:SetChecked(PredatorArchyOptions.showMinimapButton and true or false)
			for i = 1, numArchRaces do
				raceName = GetArchaeologyRaceInfo(i)
				_G['PredatorArchyMenuRace'..i..'CheckboxText']:SetText(raceName)
				_G['PredatorArchyMenuRace'..i..'Checkbox']:SetChecked(PredatorArchyOptions.customMode[raceName] and true or false)
			end
			if ( PredatorArchyOptions.mode == texts.mode_custom ) then
				PredatorArchyMenu.CustomMode:Show()
			else
				PredatorArchyMenu.CustomMode:Hide()
			end
		end)

		PredatorArchyMenu = tmp
		InterfaceOptions_AddCategory(PredatorArchyMenu)
	end

	--[[
		MINIMAP BUTTON
	]]
	do
		tmp = CreateFrame('Button', 'PredatorArchyMinimapButton', _G['Minimap'])
		tmp:SetSize(32, 32)
		tmp:SetFrameStrata(_G['Minimap']:GetFrameStrata())
		tmp:SetFrameLevel(_G['Minimap']:GetFrameLevel()+5)

		tmp.background = tmp:CreateTexture(nil, 'BACKGROUND')
		tmp.background:SetSize(21, 21)
		tmp.background:SetPoint('TOPLEFT', 7, -6)
		tmp.background:SetTexture(textures.minimap)

		tmp.border = tmp:CreateTexture(nil, 'OVERLAY')
		tmp.border:SetSize(56, 56)
		tmp.border:SetPoint('TOPLEFT')
		tmp.border:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')

		tmp:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')

		tmp.DropDown = CreateFrame('Frame', nil, tmp, 'UIDropDownMenuTemplate')
		tmp.DropDown:SetClampedToScreen(true)
		tmp.DropDown:Hide()
		UIDropDownMenu_Initialize(tmp.DropDown, function()
			local info = {}
			info.notCheckable = true

			info.text = texts.button_toggle
			info.func = ctrl.Toggle
			UIDropDownMenu_AddButton(info)

			info.text = texts.button_show
			info.func = ctrl.Show
			UIDropDownMenu_AddButton(info)

			info.text = texts.button_hide
			info.func = ctrl.Hide
			UIDropDownMenu_AddButton(info)

			info.text = texts.button_sleep
			info.func = ctrl.Sleep
			UIDropDownMenu_AddButton(info)

			info.text = texts.button_statistics
			info.func = core.PrintStatistics
			UIDropDownMenu_AddButton(info)
		end)

		tmp.DragFrame = CreateFrame('Frame', nil, tmp)
		tmp.DragFrame:Hide()
		tmp.DragFrame:SetScript('OnUpdate', function(self)
			local mx, my = _G['Minimap']:GetCenter()
			local cx, cy = GetCursorPosition()
			local scale = _G['Minimap']:GetEffectiveScale()
			cx = cx / scale
			cy = cy / scale
			PredatorArchyOptions.minimapButtonAngle = math.deg(math.atan2(cy-my, cx-mx))%360
			ctrl.SetMinimapButtonPos()
		end)

		tmp:RegisterForClicks('anyUp')
		tmp:RegisterForDrag('LeftButton')
		tmp:SetScript('OnClick', ctrl.MinimapButtonHandler)
		tmp:SetScript('OnDragStart', function(self)
			if ( IsAltKeyDown() ) then
				self:LockHighlight()
				self.DragFrame:Show()
			end
		end)
		tmp:SetScript('OnDragStop', function(self)
			self:UnlockHighlight()
			self.DragFrame:Hide()
		end)

		PredatorArchyMinimapButton = tmp

		if ( PredatorArchyOptions.showMinimapButton ) then
			PredatorArchyMinimapButton:Show()
			ctrl.SetMinimapButtonPos()
		else
			PredatorArchyMinimapButton:Hide()
		end
	end

	SLASH_PREDATORARCHY1, SLASH_PREDATORARCHY2 = '/predatorarchy', '/pa'
	SlashCmdList['PREDATORARCHY'] = ctrl.SlashCmdHandler

	PredatorArchyArtifacts:Hide()
	PredatorArchyDigSites:Hide()

end)
