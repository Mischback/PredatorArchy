--[[

]]

	local borderTex = [[Interface\AddOns\PredatorArchy\media\border_generic]]
	local barTex = [[Interface\AddOns\PredatorArchy\media\bar]]
	local solidTex = [[Interface\AddOns\PredatorArchy\media\solid]]
	local font = [[Interface\AddOns\PredatorArchy\media\accid__.ttf]]
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
		['mode_all'] = 'All',
		['mode_artifacts'] = 'Artifacts',
		['mode_fragments'] = 'Fragments',
		['mode_custom'] = 'Custom',
	}
	local artifactColors = {
		[0] = {0.7, 0.7, 0.7},							-- for normal, 'grey' artifacts
		[1] = {0, 0.3, 0.9}								-- for the exciting rare artifacts ;)
	}


-- *********************************************************************************
-- *** DON'T EDIT BEYOND THIS LINE!!! **********************************************
-- *********************************************************************************

	local numArchRaces = 10			-- made this static, so we don't have to wait for PLAYER_ALIVE on login

	--[[
		This table holds all information about the races, including their current active
		fragment count
	]]
	local PredatorArchy, PredatorArchyArtifacts, PredatorArchyDigSites
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
		timeout = 0,
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
	lib.CreateStatusBar = function(parent)
		local tmp = CreateFrame('StatusBar', nil, parent)
		tmp:SetHeight(20)
		tmp:SetStatusBarTexture(barTex)
		tmp:SetStatusBarColor(0.7, 0, 0)

		tmp.tex = {}
		tmp.tex['back'] = tmp:CreateTexture(nil, 'BACKGROUND')
		tmp.tex['back']:SetAllPoints(tmp)
		tmp.tex['back']:SetTexture(barTex)
		tmp.tex['back']:SetVertexColor(0.3, 0.3, 0.3, 1)

		tmp.text = lib.CreateFontObject(tmp, 14, font)
		tmp.text:SetPoint('LEFT', 5, 1)
		tmp.text:SetPoint('RIGHT', -15)
		tmp.text:SetJustifyH('LEFT')
		tmp.text:SetText('INIT')

		tmp.tex[1] = tmp:CreateTexture(nil, 'ARTWORK')
		tmp.tex[1]:SetPoint('TOPLEFT', tmp, 'TOPLEFT', -1, 1)
		tmp.tex[1]:SetPoint('BOTTOMRIGHT', tmp, 'BOTTOMLEFT', 0, 0)
		tmp.tex[1]:SetTexture(solidTex)
		tmp.tex[1]:SetVertexColor(0, 0, 0, 1)
		tmp.tex[2] = tmp:CreateTexture(nil, 'ARTWORK')
		tmp.tex[2]:SetPoint('TOPLEFT', tmp, 'TOPLEFT', 0, 1)
		tmp.tex[2]:SetPoint('BOTTOMRIGHT', tmp, 'TOPRIGHT', 1, 0)
		tmp.tex[2]:SetTexture(solidTex)
		tmp.tex[2]:SetVertexColor(0, 0, 0, 1)
		tmp.tex[3] = tmp:CreateTexture(nil, 'ARTWORK')
		tmp.tex[3]:SetPoint('TOPLEFT', tmp, 'TOPRIGHT', 0, 0)
		tmp.tex[3]:SetPoint('BOTTOMRIGHT', tmp, 'BOTTOMRIGHT', 1, -1)
		tmp.tex[3]:SetTexture(solidTex)
		tmp.tex[3]:SetVertexColor(0, 0, 0, 1)
		tmp.tex[4] = tmp:CreateTexture(nil, 'ARTWORK')
		tmp.tex[4]:SetPoint('TOPLEFT', tmp, 'BOTTOMLEFT', -1, 0)
		tmp.tex[4]:SetPoint('BOTTOMRIGHT', tmp, 'BOTTOMRIGHT', 0, -1)
		tmp.tex[4]:SetTexture(solidTex)
		tmp.tex[4]:SetVertexColor(0, 0, 0, 1)

		return tmp
	end



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

	--[[
	
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
	ctrl.Show = function()
		PredatorArchyOptions.state = true
		PredatorArchy:RegisterEvent('CHAT_MSG_CURRENCY')
		PredatorArchy:RegisterEvent('ARTIFACT_UPDATE')
		PredatorArchy:RegisterEvent('ARTIFACT_DIG_SITE_UPDATED')
		PredatorArchy:RegisterEvent('ZONE_CHANGED_NEW_AREA')
		PredatorArchy:RegisterEvent('TAXIMAP_OPENED')
		PredatorArchyArtifacts:Show()
		PredatorArchyDigSites:Show()
		core.UpdateProject()
		core.UpdateArtifactWindow()
	end

	--[[
	
	]]
	ctrl.Hide = function()
		PredatorArchyOptions.state = false
		PredatorArchyArtifacts:Hide()
		PredatorArchyDigSites:Hide()
	end

	--[[
	
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

	--[[
	
	]]
	ctrl.Reset = function()
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

	--[[
	
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
		elseif ( cmd == 'reset' ) then
			lib.debugging('Reset()')
			StaticPopup_Show('PREDATORARCHY_CONFIRM_RESET')
		else
			lib.debugging('Help()')
		end
	end




-- *********************************************************************************

--[[ *******************************************************************************

]]
PredatorArchy = CreateFrame('Frame', 'PredatorArchy', UIParent)
PredatorArchy:RegisterEvent('PLAYER_LOGIN')
PredatorArchy:SetScript('OnEvent', function(self)
	local _, _, hasArch = GetProfessions()
	if ( not hasArch ) then
		lib.debugging(texts.noskill)
		return
	end

	local tmp

	-- build the menu
	do
		tmp = CreateFrame('Frame', 'PredatorArchyMenu', UIParent)
		tmp.name = 'PredatorArchy'
		tmp.title = tmp:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		tmp.title:SetPoint('TOPLEFT', 16, -16)
		tmp.title:SetText('PredatorArchy')

		tmp.ShowButton = CreateFrame('Button', 'PredatorArchyMenuShowButton', tmp, 'OptionsButtonTemplate')
		tmp.ShowButton:SetText('Show')
		tmp.ShowButton:SetPoint('TOPLEFT', tmp.title, 'BOTTOMLEFT', 0, -20)
		tmp.ShowButton:SetScript('OnClick', ctrl.Show)

		tmp.HideButton = CreateFrame('Button', 'PredatorArchyMenuHideButton', tmp, 'OptionsButtonTemplate')
		tmp.HideButton:SetText('Hide')
		tmp.HideButton:SetPoint('TOPLEFT', tmp.ShowButton, 'TOPRIGHT', 5, 0)
		tmp.HideButton:SetScript('OnClick', ctrl.Hide)

		tmp.SleepButton = CreateFrame('Button', 'PredatorArchyMenuSleepButton', tmp, 'OptionsButtonTemplate')
		tmp.SleepButton:SetText('Sleep')
		tmp.SleepButton:SetPoint('TOPLEFT', tmp.HideButton, 'TOPRIGHT', 5, 0)
		tmp.SleepButton:SetScript('OnClick', ctrl.Sleep)

		tmp.ResetButton = CreateFrame('Button', 'PredatorArchyMenuSleepButton', tmp, 'OptionsButtonTemplate')
		tmp.ResetButton:SetText('Reset')
		tmp.ResetButton:SetPoint('TOPLEFT', tmp.SleepButton, 'TOPRIGHT', 5, 0)
		tmp.ResetButton:SetScript('OnClick', function()
			StaticPopup_Show('PREDATORARCHY_CONFIRM_RESET')
		end)

		tmp.ModeDropDown = CreateFrame('Button', 'PredatorArchyMenuModeDropDown', tmp, 'UIDropDownMenuTemplate')
		tmp.ModeDropDown:SetPoint('TOPLEFT', tmp.ShowButton, 'BOTTOMLEFT', 0, -20)
		tmp.ModeDropDown:SetScript('OnShow', function(self)
			UIDropDownMenu_Initialize(self, function()
				local info = {}
				info.notCheckable = true

				info.text = texts.mode_all
				info.func = function()
					_G['PredatorArchyMenuModeDropDownText']:SetText(texts.mode_all)
					PredatorArchyOptions.mode = texts.mode_all
					core.UpdateArtifactWindow()
				end
				UIDropDownMenu_AddButton(info)

				info.text = texts.mode_artifacts
				info.func = function()
					_G['PredatorArchyMenuModeDropDownText']:SetText(texts.mode_artifacts)
					PredatorArchyOptions.mode = texts.mode_artifacts
					core.UpdateArtifactWindow()
				end
				UIDropDownMenu_AddButton(info)

				info.text = texts.mode_fragments
				info.func = function()
					_G['PredatorArchyMenuModeDropDownText']:SetText(texts.mode_fragments)
					PredatorArchyOptions.mode = texts.mode_fragments
					core.UpdateArtifactWindow()
				end
				UIDropDownMenu_AddButton(info)

				info.text = texts.mode_custom
				info.func = function()
					_G['PredatorArchyMenuModeDropDownText']:SetText(texts.mode_custom)
					PredatorArchyOptions.mode = texts.mode_custom
					core.UpdateArtifactWindow()
				end
				UIDropDownMenu_AddButton(info)
			end)
		end)

		tmp.CustomMode = CreateFrame('Frame', nil, tmp)
		tmp.CustomMode:SetPoint('LEFT', tmp.ShowButton, 'LEFT')
		tmp.CustomMode:SetPoint('RIGHT', tmp.ResetButton, 'RIGHT')
		tmp.CustomMode:SetPoint('TOP', tmp.ModeDropDown, 'BOTTOM', 0, -20)
		tmp.CustomMode:SetHeight(100)
		tmp.CustomMode.race = {}

		tmp.CustomMode.race[1] = CreateFrame('CheckButton', 'PredatorArchyMenuRace1Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[1]:SetPoint('TOPLEFT', tmp.CustomMode, 'TOPLEFT')
		tmp.CustomMode.race[1]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[2] = CreateFrame('CheckButton', 'PredatorArchyMenuRace2Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[2]:SetPoint('TOPLEFT', tmp.CustomMode.race[1], 'BOTTOMLEFT', 0, -10)
		tmp.CustomMode.race[2]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[3] = CreateFrame('CheckButton', 'PredatorArchyMenuRace3Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[3]:SetPoint('TOPLEFT', tmp.CustomMode.race[2], 'BOTTOMLEFT', 0, -10)
		tmp.CustomMode.race[3]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[4] = CreateFrame('CheckButton', 'PredatorArchyMenuRace4Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[4]:SetPoint('TOPLEFT', tmp.CustomMode.race[3], 'BOTTOMLEFT', 0, -10)
		tmp.CustomMode.race[4]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[5] = CreateFrame('CheckButton', 'PredatorArchyMenuRace5Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[5]:SetPoint('TOPLEFT', tmp.CustomMode.race[4], 'BOTTOMLEFT', 0, -10)
		tmp.CustomMode.race[5]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[6] = CreateFrame('CheckButton', 'PredatorArchyMenuRace6Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[6]:SetPoint('LEFT', tmp.CustomMode, 'CENTER')
		tmp.CustomMode.race[6]:SetPoint('TOP', tmp.CustomMode.race[1], 'TOP')
		tmp.CustomMode.race[6]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[7] = CreateFrame('CheckButton', 'PredatorArchyMenuRace7Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[7]:SetPoint('TOPLEFT', tmp.CustomMode.race[6], 'BOTTOMLEFT', 0, -10)
		tmp.CustomMode.race[7]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[8] = CreateFrame('CheckButton', 'PredatorArchyMenuRace8Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[8]:SetPoint('TOPLEFT', tmp.CustomMode.race[7], 'BOTTOMLEFT', 0, -10)
		tmp.CustomMode.race[8]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[9] = CreateFrame('CheckButton', 'PredatorArchyMenuRace9Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[9]:SetPoint('TOPLEFT', tmp.CustomMode.race[8], 'BOTTOMLEFT', 0, -10)
		tmp.CustomMode.race[9]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)
		tmp.CustomMode.race[10] = CreateFrame('CheckButton', 'PredatorArchyMenuRace10Checkbox', tmp.CustomMode, 'InterfaceOptionsCheckButtonTemplate')
		tmp.CustomMode.race[10]:SetPoint('TOPLEFT', tmp.CustomMode.race[9], 'BOTTOMLEFT', 0, -10)
		tmp.CustomMode.race[10]:SetScript('OnClick', function(self)
			self:SetChecked((self:GetChecked() and true) or false)
			PredatorArchyOptions.customMode[_G[self:GetName()..'Text']:GetText()] = (self:GetChecked() and true or false)
			core.UpdateArtifactWindow()
		end)

		tmp:SetScript('OnShow', function()
			local raceName
			_G['PredatorArchyMenuModeDropDownText']:SetText(PredatorArchyOptions.mode)
			for i = 1, numArchRaces do
				raceName = GetArchaeologyRaceInfo(i)
				_G['PredatorArchyMenuRace'..i..'CheckboxText']:SetText(raceName)
				_G['PredatorArchyMenuRace'..i..'Checkbox']:SetChecked(PredatorArchyOptions.customMode[raceName] and true or false)
			end
		end)

		InterfaceOptions_AddCategory(tmp)
	end

	SLASH_PREDATORARCHY1, SLASH_PREDATORARCHY2 = '/predatorarchy', '/pa'
	SlashCmdList['PREDATORARCHY'] = ctrl.SlashCmdHandler

	core.BuildInfoTable()

	core.UpdateArtifactWindow()
	core.UpdateSkill(hasArch)

	core.BuildContinentTable()
	core.FindDigSiteOnContinent()
	
	-- build the event handler
	self:UnregisterEvent('PLAYER_LOGIN')
	self:RegisterEvent('PLAYER_ALIVE')
	self:RegisterEvent('CHAT_MSG_CURRENCY')
	self:RegisterEvent('ARTIFACT_UPDATE')
	self:RegisterEvent('ARTIFACT_DIG_SITE_UPDATED')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	self:RegisterEvent('TAXIMAP_OPENED')
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
		end
	end)

end)


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
		ctrl.Reset()
	else
		if ( not PredatorArchyOptions.state ) then
			PredatorArchyOptions.state = true
		end
		if ( not PredatorArchyOptions.mode ) then
			PredatorArchyOptions.mode = texts.mode_all
		end
		if ( not PredatorArchyOptions.customMode ) then
			PredatorArchyOptions.customMode = {}
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
			bgFile = solidTex,
			edgeFile = borderTex,
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
		PredatorArchyArtifacts.Skill.text:ClearAllPoints()
		PredatorArchyArtifacts.Skill.text:SetPoint('CENTER', 0, 1)
		PredatorArchyArtifacts.Skill.text:SetJustifyH('CENTER')

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
			tmp.tex[1] = tmp:CreateTexture(nil, 'ARTWORK')
			tmp.tex[1]:SetPoint('TOPLEFT', tmp, 'TOPLEFT', -1, 1)
			tmp.tex[1]:SetPoint('BOTTOMRIGHT', tmp, 'BOTTOMLEFT', 0, 0)
			tmp.tex[1]:SetTexture(solidTex)
			tmp.tex[1]:SetVertexColor(0, 0, 0, 1)
			tmp.tex[2] = tmp:CreateTexture(nil, 'ARTWORK')
			tmp.tex[2]:SetPoint('TOPLEFT', tmp, 'TOPLEFT', 0, 1)
			tmp.tex[2]:SetPoint('BOTTOMRIGHT', tmp, 'TOPRIGHT', 1, 0)
			tmp.tex[2]:SetTexture(solidTex)
			tmp.tex[2]:SetVertexColor(0, 0, 0, 1)
			tmp.tex[3] = tmp:CreateTexture(nil, 'ARTWORK')
			tmp.tex[3]:SetPoint('TOPLEFT', tmp, 'TOPRIGHT', 0, 0)
			tmp.tex[3]:SetPoint('BOTTOMRIGHT', tmp, 'BOTTOMRIGHT', 1, -1)
			tmp.tex[3]:SetTexture(solidTex)
			tmp.tex[3]:SetVertexColor(0, 0, 0, 1)
			tmp.tex[4] = tmp:CreateTexture(nil, 'ARTWORK')
			tmp.tex[4]:SetPoint('TOPLEFT', tmp, 'BOTTOMLEFT', -1, 0)
			tmp.tex[4]:SetPoint('BOTTOMRIGHT', tmp, 'BOTTOMRIGHT', 0, -1)
			tmp.tex[4]:SetTexture(solidTex)
			tmp.tex[4]:SetVertexColor(0, 0, 0, 1)
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
			bgFile = solidTex,
			edgeFile = borderTex,
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

end)
