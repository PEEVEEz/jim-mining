local Props, targets, Peds, Blips, soundId = {}, {}, {}, {}, GetSoundId()
------------------------------------------------------------

local items = nil
local function getItem(name)
	if not items then
		items = exports.ox_inventory:Items()
	end

	local item = items[name]

	if not item then
		items = nil
		print("[ERROR] Item not found, try again")
		return
	end

	return item
end

--Hide the mineshaft doors
CreateModelHide(-596.04, 2089.01, 131.41, 10.5, -1241212535, true)

local function removeAll()
	for id in pairs(targets) do exports.ox_target:removeZone(id) end

	for _, ped in pairs(Peds) do
		unloadModel(GetEntityModel(ped))
		DeletePed(ped)
	end

	for _, prop in pairs(Props) do
		unloadModel(GetEntityModel(prop))
		DeleteObject(prop)
	end

	for _, blip in pairs(Blips) do RemoveBlip(blip) end
end
--------------------------------------------------------
local function openShop(ped)
	exports.ox_inventory:openInventory('shop', { type = 'miningShop' })
	lookEnt(ped)
end

local function stoneBreak(name, stone)
	CreateThread(function()
		local rockcoords = GetEntityCoords(stone)

		if Config.Debug then
			print("^5Debug^7: ^2Hiding prop and target^7: '^6" ..
				name .. "^7' ^2at coords^7: ^6" .. rockcoords)
		end

		--Stone CoolDown + Recreation
		SetEntityAlpha(stone, 0, false)

		exports.ox_target:removeZone(targets[name])
		targets[name] = nil

		Wait(Config.Debug and 2000 or Config.Timings["OreRespawn"])

		--Unhide Stone and create a new target location
		SetEntityAlpha(stone, 255, false)

		targets[name] = exports.ox_target:addSphereZone({
			coords = rockcoords.xyz,
			radius = 1.2,
			debug = Config.Debug,
			options = {
				{
					icon = "fas fa-hammer",
					items = "pickaxe",
					label = Loc[Config.Lan].info["mine_ore"] .. " (" .. getItem("pickaxe").label .. ")",
					onSelect = function()
						PickMineOre(stone, name)
					end
				},
				{
					icon = "fas fa-screwdriver",
					items = "miningdrill",
					label = Loc[Config.Lan].info["mine_ore"] .. " (" .. getItem("miningdrill").label .. ")",
					onSelect = function()
						DrillMineOre(stone, name)
					end
				},
				{
					icon = "fas fa-screwdriver-wrench",
					items = "mininglaser",
					label = Loc[Config.Lan].info["mine_ore"] .. " (" .. getItem("mininglaser").label .. ")",
					onSelect = function()
						LaserMineOre(stone, name)
					end
				},
			}
		})

		if Config.Debug then
			print("^5Debug^7: ^2Remaking Prop and Target^7: '^6" ..
				name .. "^7' ^2at coords^7: ^6" .. rockcoords)
		end
	end)
end

local isMining = false
function PickMineOre(prop, name)
	if isMining then return else isMining = true end -- Stop players from doubling up the event

	-- Anim Loading
	local dict = "amb@world_human_hammering@male@base"
	local anim = "base"
	loadAnimDict(dict)
	loadDrillSound()

	--Create Pickaxe and Attach
	local picaxe = makeProp({ prop = "prop_tool_pickaxe", coords = vec4(0, 0, 0, 0) }, 0, 1)
	DisableCamCollisionForObject(picaxe)
	DisableCamCollisionForEntity(picaxe)
	AttachEntityToEntity(picaxe, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.09, -0.53, -0.22, 252.0, 180.0, 0.0,
		false,
		true,
		true, true, 0, true)

	local IsDrilling = true
	local rockcoords = GetEntityCoords(prop)

	--Calculate if you're facing the stone--
	lookEnt(prop)
	if #(rockcoords - GetEntityCoords(cache.ped)) > 1.5 then
		TaskGoStraightToCoord(cache.ped, rockcoords.x, rockcoords.y, rockcoords.z, 0.5, 400, 0.0, 0)
		Wait(400)
	end

	loadPtfxDict("core")
	CreateThread(function()
		while IsDrilling do
			UseParticleFxAssetNextCall("core")
			TaskPlayAnim(cache.ped, tostring(dict), tostring(anim), 8.0, -8.0, -1, 2, 0, false, false, false)

			Wait(200)

			local pickcoords = GetOffsetFromEntityInWorldCoords(picaxe, -0.4, 0.0, 0.7)
			StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", pickcoords.x, pickcoords.y,
				pickcoords.z, 0.0, 0.0, 0.0, 0.4, false, false, false)

			Wait(350)
		end
	end)

	if ProgressBar({ label = Loc[Config.Lan].info["drilling_ore"], time = Config.Debug and 1000 or Config.Timings["Pickaxe"], cancel = true, icon = "pickaxe" }) then
		TriggerServerEvent('jim-mining:Reward', { mine = true, cost = nil })
		if math.random(1, 10) >= 9 then
			local breakId = GetSoundId()
			PlaySoundFromEntity(breakId, "Drill_Pin_Break", cache.ped, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
			toggleItem(false, "pickaxe", 1)
		end

		stoneBreak(name, prop)
	end

	StopAnimTask(cache.ped, tostring(dict), tostring(anim), 1.0)
	DeleteProp(picaxe)
	unloadPtfxDict("core")
	unloadAnimDict(dict)
	unloadDrillSound()
	StopSound(soundId)
	IsDrilling = false
	isMining = false
end

function DrillMineOre(prop, name)
	print("isMining", isMining)
	if isMining then return else isMining = true end -- Stop players from doubling up the event

	if HasItem("drillbit", 1) then
		-- Sounds & Anim loading
		loadDrillSound()
		local dict = "anim@heists@fleeca_bank@drilling"
		local anim = "drill_straight_fail"
		loadAnimDict(tostring(dict))

		--Create Drill and Attach
		local DrillObject = makeProp({ prop = "hei_prop_heist_drill", coords = vec4(0, 0, 0, 0) }, 0, 1)
		AttachEntityToEntity(DrillObject, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.14, 0, -0.01, 90.0, -90.0,
			180.0,
			true,
			true, false, true, 1, true)

		local IsDrilling = true
		local rockcoords = GetEntityCoords(prop)

		--Calculate if you're heading is within 20.0 degrees -
		lookEnt(prop)
		if #(rockcoords - GetEntityCoords(cache.ped)) > 1.5 then
			TaskGoStraightToCoord(cache.ped, rockcoords.x, rockcoords.y, rockcoords.z, 0.5, 400, 0.0, 0)
			Wait(400)
		end

		TaskPlayAnim(cache.ped, tostring(dict), tostring(anim), 3.0, 3.0, -1, 1, 0, false, false, false)
		Wait(200)

		if Config.DrillSound then PlaySoundFromEntity(soundId, "Drill", DrillObject, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0) end

		CreateThread(function() -- Dust/Debris Animation
			loadPtfxDict("core")
			while IsDrilling do
				UseParticleFxAssetNextCall("core")
				StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", rockcoords.x, rockcoords.y,
					rockcoords.z, 0.0, 0.0, GetEntityHeading(cache.ped) - 180.0, 1.0, false, false, false)
				Wait(600)
			end
		end)

		if ProgressBar({ label = Loc[Config.Lan].info["drilling_ore"], time = Config.Debug and 1000 or Config.Timings["Pickaxe"], cancel = true, icon = "pickaxe" }) then
			TriggerServerEvent('jim-mining:Reward', { mine = true, cost = nil })

			--Destroy drill bit chances
			if math.random(1, 10) >= 8 then
				local breakId = GetSoundId()
				PlaySoundFromEntity(breakId, "Drill_Pin_Break", cache.ped, "DLC_HEIST_FLEECA_SOUNDSET", true, 0)
				toggleItem(0, "drillbit", 1)
				stoneBreak(name, prop)
			end
		end

		StopAnimTask(cache.ped, "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)
		unloadDrillSound()
		StopSound(soundId)
		DeleteProp(DrillObject)
		unloadPtfxDict("core")
		unloadAnimDict(dict)
		IsDrilling = false
		isMining = false
	else
		TriggerNotify(nil, Loc[Config.Lan].error["no_drillbit"], nil)
		isMining = false
		return
	end
end

function LaserMineOre(prop, name)
	print("isMining", isMining)
	if isMining then return else isMining = true end -- Stop players from doubling up the event

	-- Sounds & Anim Loading
	RequestAmbientAudioBank("DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS", 0)
	RequestAmbientAudioBank("dlc_xm_silo_laser_hack_sounds", 0)
	local dict = "anim@heists@fleeca_bank@drilling"
	local anim = "drill_straight_fail"
	loadAnimDict(dict)

	--Create Drill and Attach
	local DrillObject = makeProp({ prop = "ch_prop_laserdrill_01a", coords = vec4(0, 0, 0, 0) }, 0, 1)
	AttachEntityToEntity(DrillObject, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0,
		true,
		true,
		false, true, 1, true)

	local IsDrilling = true
	local rockcoords = GetEntityCoords(prop)

	--Calculate if you're facing the stone--
	lookEnt(prop)

	--Activation noise & Anims
	TaskPlayAnim(cache.ped, tostring(dict), 'drill_straight_idle', 3.0, 3.0, -1, 1, 0, false, false, false)
	PlaySoundFromEntity(soundId, "Pass", DrillObject, "dlc_xm_silo_laser_hack_sounds", 1, 0)
	Wait(1000)
	TaskPlayAnim(cache.ped, tostring(dict), tostring(anim), 3.0, 3.0, -1, 1, 0, false, false, false)
	PlaySoundFromEntity(soundId, "EMP_Vehicle_Hum", DrillObject, "DLC_HEIST_BIOLAB_DELIVER_EMP_SOUNDS", 1, 0) --Not sure about this sound, best one I could find as everything else wouldn't load

	--Laser & Debris Effect
	local lasercoords = GetOffsetFromEntityInWorldCoords(DrillObject, 0.0, -0.5, 0.02)
	CreateThread(function()
		loadPtfxDict("core")
		while IsDrilling do
			UseParticleFxAssetNextCall("core")
			StartNetworkedParticleFxNonLoopedAtCoord("muz_railgun", lasercoords.x, lasercoords.y,
				lasercoords.z, 0, -10.0, GetEntityHeading(DrillObject) + 270, 1.0, false, false, false)

			UseParticleFxAssetNextCall("core")
			StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", rockcoords.x, rockcoords.y,
				rockcoords.z, 0.0, 0.0, GetEntityHeading(cache.ped) - 180.0, 1.0, false, false, false)
			Wait(60)
		end
	end)

	if ProgressBar({ label = Loc[Config.Lan].info["drilling_ore"], time = Config.Debug and 1000 or Config.Timings["Laser"], cancel = true, icon = "mininglaser" }) then
		TriggerServerEvent('jim-mining:Reward', { mine = true, cost = nil })
		stoneBreak(name, prop)
	end

	IsDrilling = false
	isMining = false
	StopAnimTask(cache.ped, tostring(dict), tostring(anim), 1.0)
	ReleaseScriptAudioBank()
	StopSound(soundId)
	DeleteProp(DrillObject)
	unloadPtfxDict("core")
	unloadAnimDict(dict)
end

------------------------------------------------------------
-- Cracking Command / Animations
local Cracking = false
local function crackStart(bench)
	if Cracking then return end
	local cost = 1
	if HasItem("stone", cost) then
		Cracking = true
		LockInv(true)

		-- Sounds & Anim Loading
		local dict = "amb@prop_human_parking_meter@male@idle_a"
		local anim = "idle_a"
		loadAnimDict(dict)
		loadDrillSound()
		local benchcoords = GetOffsetFromEntityInWorldCoords(bench, 0.0, -0.2, 2.08)

		--Calculate if you're facing the bench--
		lookEnt(bench)
		if #(benchcoords - GetEntityCoords(cache.ped)) > 1.5 then
			TaskGoStraightToCoord(cache.ped, benchcoords.x, benchcoords.y, benchcoords.z, 0.5, 400, 0.0, 0)
			Wait(400)
		end
		local Rock = makeProp(
			{ prop = "prop_rock_5_smash1", coords = vec4(benchcoords.x, benchcoords.y, benchcoords.z, 0) }, 0, 1)

		if Config.DrillSound then
			PlaySoundFromCoord(soundId, "Drill", benchcoords.x, benchcoords.y, benchcoords.z, "DLC_HEIST_FLEECA_SOUNDSET",
				false, 4.5,
				false)
		end

		loadPtfxDict("core")
		CreateThread(function()
			while Cracking do
				UseParticleFxAssetNextCall("core")
				StartNetworkedParticleFxNonLoopedAtCoord("ent_dst_rocks", benchcoords.x, benchcoords.y,
					benchcoords.z - 0.9, 0.0, 0.0, 0.0, 0.2, false, false, false)

				Wait(400)
			end
		end)

		TaskPlayAnim(cache.ped, dict, anim, 3.0, 3.0, -1, 1, 0, false, false, false)
		if ProgressBar({ label = Loc[Config.Lan].info["cracking_stone"], time = Config.Debug and 1000 or Config.Timings["Cracking"], cancel = true, icon = "stone" }) then
			TriggerServerEvent('jim-mining:Reward', { crack = true, cost = cost })
		end

		StopAnimTask(cache.ped, dict, anim, 1.0)
		unloadDrillSound()
		StopSound(soundId)
		unloadPtfxDict("core")
		unloadAnimDict(dict)
		DeleteProp(Rock)
		LockInv(false)
		Cracking = false
	else
		TriggerNotify(nil, Loc[Config.Lan].error["no_stone"], 'error')
	end
end

------------------------------------------------------------
-- Washing Command / Animations
local Washing = false
local function startWash()
	if Washing then return end

	local cost = 1
	if HasItem("stone", cost) then
		Washing = true
		LockInv(true)

		--Create Rock and Attach
		local Rock = makeProp({ prop = "prop_rock_5_smash1", coords = vec4(0, 0, 0, 0) }, 0, 1)
		AttachEntityToEntity(Rock, cache.ped, GetPedBoneIndex(cache.ped, 60309), 0.1, 0.0, 0.05, 90.0, -90.0, 90.0, true,
			true,
			false,
			true, 1, true)
		TaskStartScenarioInPlace(cache.ped, "PROP_HUMAN_BUM_BIN", 0, true)

		local water
		CreateThread(function()
			Wait(3000)
			loadPtfxDict("core")
			while Washing do
				UseParticleFxAssetNextCall("core")
				water = StartNetworkedParticleFxLoopedOnEntity("water_splash_veh_out", cache.ped, 0.0, 1.0, -0.2, 0.0,
					0.0, 0.0, 2.0, 0, 0, 0)
				Wait(500)
			end
		end)

		if ProgressBar({ label = Loc[Config.Lan].info["washing_stone"], time = Config.Debug and 1000 or Config.Timings["Washing"], cancel = true, icon = "stone" }) then
			TriggerServerEvent('jim-mining:Reward', { wash = true, cost = cost })
		end

		LockInv(false)
		StopParticleFxLooped(water, false)
		DeleteProp(Rock)
		unloadPtfxDict("core")
		Washing = false
		ClearPedTasks(cache.ped)
	else
		TriggerNotify(nil, Loc[Config.Lan].error["no_stone"], 'error')
	end
end

------------------------------------------------------------
-- Gold Panning Command / Animations
local Panning = false
local function panStart()
	if Panning then return else Panning = true end
	LockInv(true)

	--Create Rock and Attach
	local trayCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.5, -0.9)

	local propId = #Props + 1
	Props[propId] = makeProp(
		{
			coords = vec4(trayCoords.x, trayCoords.y, trayCoords.z + 1.03, GetEntityHeading(cache.ped)),
			prop =
			`bkr_prop_meth_tray_01b`
		}, 1, 1)

	CreateThread(function()
		loadPtfxDict("core")
		while Panning do
			UseParticleFxAssetNextCall("core")
			StartNetworkedParticleFxLoopedOnEntity("water_splash_veh_out", Props[propId], 0.0, 0.0, 0.0,
				0.0, 0.0, 0.0, 3.0, 0, 0, 0)
			Wait(100)
		end
	end)

	--Start Anim
	TaskStartScenarioInPlace(cache.ped, "CODE_HUMAN_MEDIC_KNEEL", 0, true)
	if ProgressBar({ label = Loc[Config.Lan].info["goldpanning"], time = Config.Debug and 1000 or Config.Timings["Panning"], cancel = true, icon = "goldpan" }) then
		TriggerServerEvent('jim-mining:Reward', { pan = true, cost = nil })
	end

	ClearPedTasksImmediately(cache.ped)
	DeleteProp(Props[propId])
	unloadPtfxDict("core")
	LockInv(false)
	Panning = false
end

------------------------------------------------------------
--Selling animations are simply a pass item to seller animation
RegisterNetEvent('jim-mining:SellAnim', function(data)
	if not HasItem(data.item, 1) then
		TriggerNotify(nil, Loc[Config.Lan].error["dont_have"] .. " " .. getItem(data.item)?.label, "error")
		return
	end

	for _, object in pairs(GetGamePool('CObject')) do
		for _, model in pairs({ `p_cs_clipboard` }) do
			if GetEntityModel(object) == model then
				if IsEntityAttachedToEntity(data.ped, object) then
					DeleteObject(object)
					DetachEntity(object, false, false)
					SetEntityAsMissionEntity(object, true, true)
					Wait(100)
					DeleteEntity(object)
				end
			end
		end
	end

	loadAnimDict("mp_common")
	TriggerServerEvent('jim-mining:Selling', data.item) -- Had to slip in the sell command during the animation command
	loadAnimDict("mp_common")
	lookEnt(data.ped)
	TaskPlayAnim(cache.ped, "mp_common", "givetake2_a", 100.0, 200.0, 0.3, 1, 0.2, 0, 0, 0) --Start animations
	TaskPlayAnim(data.ped, "mp_common", "givetake2_b", 100.0, 200.0, 0.3, 1, 0.2, 0, 0, 0)
	Wait(2000)
	StopAnimTask(cache.ped, "mp_common", "givetake2_a", 1.0)
	StopAnimTask(data.ped, "mp_common", "givetake2_b", 1.0)
	unloadAnimDict("mp_common")

	if data.sub then
		TriggerEvent('jim-mining:JewelSell:Sub', { sub = data.sub, ped = data.ped })
		return
	else
		SellOre(data.ped)
		return
	end
end)

------------------------------------------------------------
function SellOre(ped)
	local sellMenu = {}

	for _, v in pairs(Config.OreSell) do
		local disable = true
		local item = getItem(v)

		if item then
			local setheader = item.label

			if HasItem(v, 1) then
				setheader = setheader .. " 💰"
				disable = false
			end

			sellMenu[#sellMenu + 1] = { -- TODO: Fix menu
				icon = "nui://" .. Config.img .. item.image,
				disabled = disable,
				header = setheader,
				txt = Loc[Config.Lan].info["sell_all"] ..
					" " .. Config.SellingPrices[v] .. " " .. Loc[Config.Lan].info["sell_each"],
				params = { event = "jim-mining:SellAnim", args = { item = v, ped = ped } },
				title = setheader,
				description = Loc[Config.Lan].info["sell_all"] ..
					" " .. Config.SellingPrices[v] .. " " .. Loc[Config.Lan].info["sell_each"],
				event = "jim-mining:SellAnim",
				args = { item = v, ped = ped },
			}
		end
	end

	lib.registerContext({
		id = 'sellMenu',
		title = Loc[Config.Lan].info["header_oresell"],
		position =
		'top-right',
		options = sellMenu
	})

	lib.showContext("sellMenu")
	lookEnt(ped)
end

------------------------
--Jewel Selling Main Menu
function JewelSell(ped)
	local sellMenu = {}
	local table = {
		{ title = getItem("emerald").label,          sub = "emerald" },
		{ title = getItem("ruby").label,             sub = "ruby" },
		{ title = getItem("diamond").label,          sub = "diamond" },
		{ title = getItem("sapphire").label,         sub = "sapphire" },
		{ title = Loc[Config.Lan].info["rings"],     sub = "rings" },
		{ title = Loc[Config.Lan].info["necklaces"], sub = "necklaces" },
		{ title = Loc[Config.Lan].info["earrings"],  sub = "earrings" },
	}

	for i = 1, #table do -- TODO: Fix menu
		sellMenu[#sellMenu + 1] = {
			header = table[i].title,
			txt = Loc[Config.Lan].info["see_options"],
			params = { event = "jim-mining:JewelSell:Sub", args = { sub = table[i].sub, ped = ped } },
			title = table[i].title,
			description = Loc[Config.Lan].info["see_options"],
			event = "jim-mining:JewelSell:Sub",
			args = { sub = table[i].sub, ped = ped }
		}
	end

	lib.registerContext({
		id = 'sellMenu',
		title = Loc[Config.Lan].info["jewel_buyer"],
		position =
		'top-right',
		options = sellMenu
	})

	lib.showContext("sellMenu")

	lookEnt(ped)
end

--Jewel Selling - Sub Menu Controller
RegisterNetEvent('jim-mining:JewelSell:Sub', function(data)
	local sellMenu = {}

	sellMenu[#sellMenu + 1] = {
		icon = "fas fa-circle-arrow-left",
		header = "",
		txt = Loc[Config.Lan].info["return"],
		params = { event = "jim-mining:JewelSell", args = data },
		title = Loc[Config.Lan].info["return"],
		event = "jim-mining:JewelSell",
		args = data
	}

	local table = {
		["emerald"] = { "emerald", "uncut_emerald" },
		["ruby"] = { "ruby", "uncut_ruby" },
		["diamond"] = { "diamond", "uncut_diamond" },
		["sapphire"] = { "sapphire", "uncut_sapphire" },
		["rings"] = { "gold_ring", "silver_ring", "diamond_ring", "emerald_ring", "ruby_ring", "sapphire_ring", "diamond_ring_silver", "emerald_ring_silver", "ruby_ring_silver", "sapphire_ring_silver" },
		["necklaces"] = { "goldchain", "silverchain", "diamond_necklace", "emerald_necklace", "ruby_necklace", "sapphire_necklace", "diamond_necklace_silver", "emerald_necklace_silver", "ruby_necklace_silver", "sapphire_necklace_silver" },
		["earrings"] = { "goldearring", "silverearring", "diamond_earring", "emerald_earring", "ruby_earring", "sapphire_earring", "diamond_earring_silver", "emerald_earring_silver", "ruby_earring_silver", "sapphire_earring_silver" },
	}

	for _, v in pairs(table[data.sub]) do
		local disable = true
		local item = getItem(v)

		if item then
			local setheader = item.label

			if HasItem(v, 1) then
				setheader = setheader .. " 💰"
				disable = false
			end

			sellMenu[#sellMenu + 1] = {
				disabled = disable,
				icon = "nui://" .. Config.img .. item.image,
				header = setheader,
				txt = Loc[Config.Lan].info["sell_all"] ..
					" " .. Config.SellingPrices[v] .. " " .. Loc[Config.Lan].info["sell_each"],
				params = { event = "jim-mining:SellAnim", args = { item = v, sub = data.sub, ped = data.ped } },
				title = setheader,
				description = Loc[Config.Lan].info["sell_all"] ..
					" " .. Config.SellingPrices[v] .. " " .. Loc[Config.Lan].info["sell_each"],
				event = "jim-mining:SellAnim",
				args = { item = v, sub = data.sub, ped = data.ped }
			}
		end
	end

	lib.registerContext({
		id = 'sellMenu',
		title = Loc[Config.Lan].info["jewel_buyer"],
		position =
		'top-right',
		options = sellMenu
	})
	lib.showContext("sellMenu")

	lookEnt(data.ped)
end)

--Cutting Jewels
local function jewelCut(bench)
	local cutMenu = {}

	local table = {
		{ header = Loc[Config.Lan].info["gem_cut"],   txt = Loc[Config.Lan].info["gem_cut_section"],    craftable = Crafting.GemCut, },
		{ header = Loc[Config.Lan].info["make_ring"], txt = Loc[Config.Lan].info["ring_craft_section"], craftable = Crafting.RingCut, },
		{ header = Loc[Config.Lan].info["make_neck"], txt = Loc[Config.Lan].info["neck_craft_section"], craftable = Crafting.NeckCut, },
		{ header = Loc[Config.Lan].info["make_ear"],  txt = Loc[Config.Lan].info["ear_craft_section"],  craftable = Crafting.EarCut, },
	}

	for i = 1, #table do -- TODO: Fix menu
		cutMenu[#cutMenu + 1] = {
			header = table[i].header,
			txt = table[i].txt,
			params = { event = "jim-mining:CraftMenu", args = { craftable = table[i].craftable, ret = true, bench = bench } },
			title = table[i].header,
			description = table[i].txt,
			event = "jim-mining:CraftMenu",
			args = { craftable = table[i].craftable, ret = true, bench = bench },
		}
	end

	lib.registerContext({
		id = 'cutMenu',
		title = Loc[Config.Lan].info["craft_bench"],
		position =
		'top-right',
		options = cutMenu
	})

	lib.showContext("cutMenu")
end

function CraftMenu(ret, craftable, bench)
	local CraftMenu = {}
	local header = ret and Loc[Config.Lan].info["craft_bench"] or Loc[Config.Lan].info["smelter"]

	if ret then
		CraftMenu[#CraftMenu + 1] = {
			icon = "fas fa-circle-arrow-left",
			header = "",
			txt = Loc[Config.Lan].info
				["return"],
			title = Loc[Config.Lan].info["return"],
			event = "jim-mining:JewelCut",
			args = data,
			params = { event = "jim-mining:JewelCut", args = data }
		}
	end

	for i = 1, #craftable do
		for k in pairs(craftable[i]) do
			if k ~= "amount" then
				local text = ""
				setheader = getItem(tostring(k)).label
				if craftable[i]["amount"] ~= nil then setheader = setheader .. " x" .. craftable[i]["amount"] end
				local disable = false
				local checktable = {}

				for l, b in pairs(craftable[i][tostring(k)]) do
					if b == 0 or b == 1 then number = "" else number = " x" .. b end

					local item = getItem(l)
					if not item then
						print("^3Error^7: ^2Script can't find ingredient item - ^1" .. l .. "^7")
						return
					end

					text = text .. item.label .. number .. "\n"

					settext = text
					checktable[l] = HasItem(l, b)
				end

				for _, v in pairs(checktable) do
					if v == false then
						disable = true
						break
					end
				end

				if not disable then setheader = setheader .. " ✔️" end
				local event = Config.MultiCraft and "jim-mining:Crafting:MultiCraft" or "jim-mining:Crafting:MakeItem"

				CraftMenu[#CraftMenu + 1] = { -- TODO: Fix menu
					disabled = disable,
					icon = "nui://" .. Config.img .. getItem(tostring(k)).image,
					header = setheader,
					title = setheader,
					description = settext,                                                                        -- ox_lib
					event = event,
					args = { item = k, craft = craftable[i], craftable = craftable, header = header, ret = ret, bench = bench }, -- ox_lib
				}
				settext, setheader = nil
			end
		end
	end

	lib.registerContext({
		id = 'CraftMenu',
		title = data.ret and Loc[Config.Lan].info["craft_bench"] or
			Loc[Config.Lan].info["smelter"],
		position = 'top-right',
		options = CraftMenu
	})

	lib.showContext("CraftMenu")
	lookEnt(data.coords)
end

RegisterNetEvent('jim-mining:Crafting:MultiCraft', function(data)
	local success = Config.MultiCraftAmounts

	local Menu = {}
	for k in pairs(success) do
		success[k] = true
		for l, b in pairs(data.craft[data.item]) do
			local has = HasItem(l, (b * k))
			if not has then
				success[k] = false
				break
			else
				success[k] = true
			end
		end
	end

	Menu[#Menu + 1] = {
		icon = "fas fa-arrow-left",
		title = Loc[Config.Lan].info["return"],
		header = "",
		txt = Loc
			[Config.Lan].info["return"],
		params = { event = "jim-mining:CraftMenu", args = data },
		event = "jim-mining:CraftMenu",
		args =
			data
	}

	for k in pairsByKeys(success) do
		Menu[#Menu + 1] = {
			disabled = not success[k],
			icon = "nui://" .. Config.img .. getItem(data.item).image,
			header = getItem(data.item).label .. " (x" .. k * (data.craft.amount or 1) .. ")",
			title = getItem(data.item).label .. " (x" .. k * (data.craft.amount or 1) .. ")",
			event = "jim-mining:Crafting:MakeItem",
			args = { item = data.item, craft = data.craft, craftable = data.craftable, header = data.header, anim = data.anim, amount = k, ret = data.ret, bench = data.bench },
			params = { event = "jim-mining:Crafting:MakeItem", args = { item = data.item, craft = data.craft, craftable = data.craftable, header = data.header, anim = data.anim, amount = k, ret = data.ret, bench = data.bench } }
		}
	end

	lib.registerContext({
		id = 'Crafting',
		title = data.ret and Loc[Config.Lan].info["craft_bench"] or
			Loc[Config.Lan].info["smelter"],
		position = 'top-right',
		options = Menu
	})

	lib.showContext("Crafting")
end)

RegisterNetEvent('jim-mining:Crafting:MakeItem',
	function(data)
		local bartext, animDictNow, animNow, scene = "", nil, nil, nil

		if not data.ret then
			bartext = Loc[Config.Lan].info["smelting"] .. getItem(data.item).label
		else
			bartext = Loc[Config.Lan].info["cutting"] .. getItem(data.item).label
		end

		local bartime = Config.Timings["Crafting"]
		if (data.amount and data.amount ~= 1) then
			data.craft.amount = data.craft.amount or 1
			data.craft["amount"] *= data.amount
			for k in pairs(data.craft[data.item]) do data.craft[data.item][k] *= data.amount end
			bartime *= data.amount
			bartime *= 0.9
		end

		LockInv(true)
		local isDrilling = true

		if data.ret then -- If jewelcutting
			if not HasItem("drillbit", 1) then
				TriggerNotify(nil, Loc[Config.Lan].error["no_drillbit"], 'error')
				TriggerEvent('jim-mining:JewelCut', data)
				LockInv(false)
				return
			else
				local dict = "anim@amb@machinery@speed_drill@"
				local anim = "operate_02_hi_amy_skater_01"
				loadAnimDict(tostring(dict))
				LockInv(true)
				loadDrillSound()

				if Config.DrillSound then
					PlaySoundFromEntity(soundId, "Drill", cache.ped, "DLC_HEIST_FLEECA_SOUNDSET", 0.5, 0)
				end

				local drillcoords = GetOffsetFromEntityInWorldCoords(data.bench, 0.0, -0.15, 1.1)

				local benchCoords = GetEntityCoords(data.bench)
				local benchRot = GetEntityRotation(data.bench)
				scene = NetworkCreateSynchronisedScene(benchCoords.x, benchCoords.y, benchCoords.z,
					benchRot.x, benchRot.y, benchRot.z, 2,
					false, false, 1065353216, 0, 1.3)

				NetworkAddPedToSynchronisedScene(cache.ped, scene, tostring(dict), tostring(anim), 0, 0, 0, 16,
					1148846080, 0)
				NetworkStartSynchronisedScene(scene)

				CreateThread(function()
					loadPtfxDict("core")
					while isDrilling do
						UseParticleFxAssetNextCall("core")
						StartNetworkedParticleFxNonLoopedAtCoord("glass_side_window", drillcoords.x,
							drillcoords.y, drillcoords.z, 0.0, 0.0, GetEntityHeading(cache.ped) + math.random(0, 359),
							0.2,
							false, false, false)

						Wait(100)
					end

					unloadAnimDict(dict)
				end)
			end
		else -- If not Jewel Cutting, you'd be smelting (need to work out what is possible for this)
			animDictNow = "amb@prop_human_parking_meter@male@idle_a"
			animNow = "idle_a"
		end

		if ProgressBar({ label = bartext, time = Config.Debug and 2000 or bartime, cancel = true, dict = animDictNow, anim = animNow, flag = 8, icon = data.item }) then
			TriggerServerEvent('jim-mining:Crafting:GetItem', data.item, data.craft)
			if data.ret then
				if math.random(1, 1000) <= 75 then
					local breakId = GetSoundId()
					PlaySoundFromEntity(breakId, "Drill_Pin_Break", cache.ped, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
					toggleItem(false, "drillbit", 1)
				end
			end
			Wait(500)

			CraftMenu(data.ret, data.craft, data.bench)
		end

		LockInv(false)
		StopSound(soundId)
		unloadDrillSound()
		LockInv(false)

		if scene then NetworkStopSynchronisedScene(scene) end

		unloadPtfxDict("core")
		isDrilling = false

		if animDictNow and animNow then
			StopAnimTask(cache.ped, animDictNow, animNow, 1.0)
		end

		FreezeEntityPosition(cache.ped, false)
	end)

AddEventHandler('onResourceStop', function(r) if r == GetCurrentResourceName() then removeAll() end end)

CreateThread(function()
	for mine in pairs(Config.Locations["Mines"]) do
		local loc = Config.Locations["Mines"][mine]
		if loc.Enable then
			--[[Blips]] --
			if loc.Blip.Enable then Blips[#Blips + 1] = CreateBlip(loc["Blip"]) end

			--[[Ores]] --
			if loc["OrePositions"] then
				for i = 1, #loc["OrePositions"] do
					local name = "Ore" .. "_" .. mine .. "_" .. i
					local coords = loc["OrePositions"][i]

					local propTable = {
						{ full = "cs_x_rubweec", empty = "prop_rock_5_a" },
					}

					if Config.K4MB1Prop then
						propTable = {
							{ full = "k4mb1_crystalblue",  empty = "k4mb1_crystalempty" },
							{ full = "k4mb1_crystalgreen", empty = "k4mb1_crystalempty" },
							{ full = "k4mb1_crystalred",   empty = "k4mb1_crystalempty" },
							{ full = "k4mb1_copperore2",   empty = "k4mb1_emptyore2" },
							{ full = "k4mb1_ironore2",     empty = "k4mb1_emptyore2" },
							{ full = "k4mb1_goldore2",     empty = "k4mb1_emptyore2" },
							{ full = "k4mb1_leadore2",     empty = "k4mb1_emptyore2" },
							{ full = "k4mb1_tinore2",      empty = "k4mb1_emptyore2" },
						}
					end

					local propPick = propTable[math.random(1, #propTable)]
					local propId = #Props + 1
					Props[propId] = makeProp(
						{
							coords = vec4(coords.x, coords.y, coords.z + (not Config.K4MB1Prop and 1.10 or 0.8), coords
								.a),
							prop =
								propPick.full
						}, 1, false)

					local rot = GetEntityRotation(Props[propId])
					rot = vec3(rot.x - math.random(60, 100), rot.y, rot.z)
					SetEntityRotation(Props[propId], rot.x, rot.y, rot.z, 0, 0)


					targets[name] = exports.ox_target:addSphereZone({
						coords = coords.xyz,
						radius = 1.2,
						debug = Config.Debug,
						options = {
							{
								icon = "fas fa-hammer",
								label = Loc[Config.Lan].info["mine_ore"] ..
									" (" .. getItem("pickaxe").label .. ")",
								items = "pickaxe",
								onSelect = function()
									PickMineOre(Props[propId], name) -- jim-mining:MineOre:Pick
								end
							},
							{
								icon = "fas fa-screwdriver",
								label = Loc[Config.Lan].info["mine_ore"] ..
									" (" .. getItem("miningdrill").label .. ")",
								items = "miningdrill",
								onSelect = function()
									DrillMineOre(Props[propId], name) -- jim-mining:MineOre:Drill
								end
							},
							{
								icon = "fas fa-screwdriver",
								label = Loc[Config.Lan].info["mine_ore"] ..
									" (" .. getItem("mininglaser").label .. ")",
								items = "mininglaser",
								onSelect = function()
									LaserMineOre(Props[propId], name) -- jim-mining:MineOre:Laser
								end
							},
						}

					})

					Props[#Props + 1] = makeProp(
						{
							coords = vec4(coords.x, coords.y, coords.z + (not Config.K4MB1Prop and 1.1 or 0.8), coords.a),
							prop =
								propPick.empty
						}, 1, false)

					SetEntityRotation(Props[#Props], rot.x, rot.y, rot.z, 0, 0)
				end
			end

			--[[LIGHTS]] --
			if loc["Lights"] then
				if loc["Lights"].Enable then
					for i = 1, #loc["Lights"].positions do
						Props[#Props + 1] = makeProp({ coords = loc["Lights"].positions[i], prop = loc["Lights"].prop },
							1, false)
					end
				end
			end

			--[[Stores]] --
			if loc["Store"] then
				for i = 1, #loc["Store"] do
					local name = "Store" .. "_" .. mine .. "_" .. i

					local pedId = #Peds + 1
					Peds[pedId] = CreateNewPed(loc["Store"][i].model, loc["Store"][i].coords, 1, 1,
						loc["Store"][i].scenario)

					targets[name] = exports.ox_target:addSphereZone({
						coords = loc["Store"][i].coords.xyz,
						radius = 1.0,
						debug = Config.Debug,
						options = {
							{
								icon = "fas fa-store",
								label = Loc[Config.Lan].info["browse_store"],
								onSelect = function()
									openShop(Peds[pedId])
								end
							}
						}
					})
				end
			end

			--[[Smelting]] --
			if loc["Smelting"] then
				for i = 1, #loc["Smelting"] do
					local name = "Smelting" .. "_" .. mine .. "_" .. i
					if loc["Smelting"][i].blipEnable then Blips[#Blips + 1] = CreateBlip(loc["Smelting"][i]) end

					targets[name] = exports.ox_target:addSphereZone({
						coords = loc["Smelting"][i].coords.xyz,
						radius = 3.0,
						debug = Config.Debug,
						options = {
							{
								icon = "fas fa-fire-burner",
								label = Loc[Config.Lan].info["use_smelter"],
								onSelect = function()
									CraftMenu(nil, Crafting.SmeltMenu, nil) --jim-mining:CraftMenu
								end
							}
						}
					})
				end
			end

			--[[Cracking]] --
			if loc["Cracking"] then
				for i = 1, #loc["Cracking"] do
					local name = "Cracking" .. "_" .. mine .. "_" .. i
					if loc["Cracking"][i].blipEnable then Blips[#Blips + 1] = CreateBlip(loc["Cracking"][i]) end

					local propId = #Props + 1
					Props[propId] = makeProp(loc["Cracking"][i], 1, false)

					targets[name] = exports.ox_target:addLocalEntity(Props[propId], {
						{
							icon = 'fas fa-compact-disc',
							label = Loc[Config.Lan].info["crackingbench"],
							items = "stone",
							onSelect = function(entity)
								crackStart(entity) -- jim-mining:CrackStart
							end,
						}
					})
				end
			end

			--[[Ore Buyer]] --
			if loc["OreBuyer"] then
				for i = 1, #loc["OreBuyer"] do
					local name = "OreBuyer" .. "_" .. mine .. "_" .. i

					local pedId = #Peds + 1
					Peds[pedId] = CreateNewPed(loc["OreBuyer"][i].model, loc["OreBuyer"][i].coords, 1, 1,
						loc["OreBuyer"][i].scenario)

					if loc["OreBuyer"][i].blipEnable then Blips[#Blips + 1] = CreateBlip(loc["OreBuyer"][i]) end

					targets[name] = exports.ox_target:addSphereZone({
						coords = loc["OreBuyer"][i].coords.xyz,
						radius = 0.9,
						debug = Config.Debug,
						options = {
							{
								icon = "fas fa-sack-dollar",
								label = Loc[Config.Lan].info["sell_ores"],
								onSelect = function()
									SellOre(Peds[pedId])
								end
							}
						}
					})
				end
			end

			--[[Jewel Cutting]] --
			if loc["JewelCut"] then
				for i = 1, #loc["JewelCut"] do
					local name = "JewelCut" .. "_" .. mine .. "_" .. i
					if loc["JewelCut"][i].blipEnable then Blips[#Blips + 1] = CreateBlip(loc["JewelCut"][i]) end

					local propId = #Props + 1
					Props[propId] = makeProp(loc["JewelCut"][i], 1, false)

					targets[name] = exports.ox_target:addLocalEntity(Props[propId], {
						{
							icon = 'fas fa-gem',
							label = Loc[Config.Lan].info["jewelcut"],
							onSelect = function(entity)
								jewelCut(entity)
							end,
						}
					})
				end
			end
		end
	end

	--[[Stone Washing]] --
	if Config.Locations["Washing"].Enable then
		for k, v in pairs(Config.Locations["Washing"].positions) do
			local name = "Washing" .. k


			targets[name] = exports.ox_target:addSphereZone({
				coords = v.coords.xyz,
				radius = 9.0,
				debug = Config.Debug,
				options = {
					{
						icon = "fas fa-hands-bubbles",
						items = "stone",
						label = Loc[Config.Lan].info["washstone"],
						onSelect = startWash
					}
				}
			})

			if v.blipEnable then Blips[#Blips + 1] = CreateBlip(v) end
		end
	end

	--[[Panning]] --
	if Config.Locations["Panning"].Enable then
		for location in pairs(Config.Locations["Panning"].positions) do
			local loc = Config.Locations["Panning"].positions[location]
			if loc.Blip.Enable then Blips[#Blips + 1] = CreateBlip(loc["Blip"]) end
			for i = 1, #loc.Positions do
				local name = "Panning" .. location .. i


				targets[name] = exports.ox_target:addBoxZone({
					coords = loc.Positions[i].coords.xyz,
					size = loc.Positions[i].size,
					debug = Config.Debug,
					options = {
						{
							items = "goldpan",
							icon = "fas fa-ring",
							label = Loc[Config.Lan].info["goldpan"],
							onSelect = panStart
						}
					}
				})
			end
		end
	end

	--[[Jewel Buyer]] --
	if Config.Locations["JewelBuyer"].Enable then
		for k, v in pairs(Config.Locations["JewelBuyer"].positions) do
			local pedId = #Peds + 1
			Peds[#Peds + 1] = CreateNewPed(v.model, v.coords, 1, 1, v.scenario)

			targets["JewelBuyer" .. k] = exports.ox_target:addSphereZone({
				coords = v.coords.xyz,
				radius = 1.2,
				debug = Config.Debug,
				options = {
					{
						icon = "fas fa-gem",
						label = Loc[Config.Lan].info["jewelbuyer"],
						onSelect = function()
							JewelSell(Peds[pedId])
						end
					}
				}
			})
		end
	end
end)
