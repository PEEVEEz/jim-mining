local time = 1000

function loadModel(model)
	if not HasModelLoaded(model) then
		if Config.Debug then print("^5Debug^7: ^2Loading Model^7: '^6" .. model .. "^7'") end
		while not HasModelLoaded(model) do
			if time > 0 then
				time = time - 1
				RequestModel(model)
			else
				time = 1000
				print("^5Debug^7: ^3LoadModel^7: ^2Timed out loading model ^7'^6" .. model .. "^7'")
				break
			end
			Wait(10)
		end
	end
end

function unloadModel(model)
	if Config.Debug then print("^5Debug^7: ^2Removing Model^7: '^6" .. model .. "^7'") end
	SetModelAsNoLongerNeeded(model)
end

function loadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		if Config.Debug then print("^5Debug^7: ^2Loading Anim Dictionary^7: '^6" .. dict .. "^7'") end
		while not HasAnimDictLoaded(dict) do
			RequestAnimDict(dict)
			Wait(5)
		end
	end
end

function unloadAnimDict(dict)
	if Config.Debug then print("^5Debug^7: ^2Removing Anim Dictionary^7: '^6" .. dict .. "^7'") end
	RemoveAnimDict(dict)
end

function loadPtfxDict(dict)
	if not HasNamedPtfxAssetLoaded(dict) then
		if Config.Debug then print("^5Debug^7: ^2Loading Ptfx Dictionary^7: '^6" .. dict .. "^7'") end
		while not HasNamedPtfxAssetLoaded(dict) do
			RequestNamedPtfxAsset(dict)
			Wait(5)
		end
	end
end

function unloadPtfxDict(dict)
	if Config.Debug then print("^5Debug^7: ^2Removing Ptfx Dictionary^7: '^6" .. dict .. "^7'") end
	RemoveNamedPtfxAsset(dict)
end

function loadDrillSound()
	if Config.Debug then print("^5Debug^7: ^2Loading Drill Sound Banks") end
	RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
	RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
end

function unloadDrillSound()
	if Config.Debug then print("^5Debug^7: ^2Removing Drill Sound Banks") end
	ReleaseAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET")
	ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL")
	ReleaseAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2")
end

function lookEnt(entity)
	if type(entity) == "vec3" then
		if not IsPedHeadingTowardsPosition(PlayerPedId(), entity, 10.0) then
			TaskTurnPedToFaceCoord(PlayerPedId(), entity, 1500)
			if Config.Debug then print("^5Debug^7: ^2Turning Player to^7: '^6" .. json.encode(entity) .. "^7'") end
			Wait(1500)
		end
	else
		if DoesEntityExist(entity) then
			if not IsPedHeadingTowardsPosition(PlayerPedId(), GetEntityCoords(entity), 30.0) then
				TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(entity), 1500)
				if Config.Debug then print("^5Debug^7: ^2Turning Player to^7: '^6" .. entity .. "^7'") end
				Wait(1500)
			end
		end
	end
end

function makeProp(data, freeze, synced)
	loadModel(data.prop)
	local prop = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z - 1.03, synced or false,
		synced or false, false)
	SetEntityHeading(prop, data.coords.w + 180.0)
	FreezeEntityPosition(prop, freeze or 0)
	if Config.Debug then
		local coords = { string.format("%.2f", data.coords.x), string.format("%.2f", data.coords.y), string.format(
			"%.2f", data.coords.z), (string.format("%.2f", data.coords.w or 0.0)) }
		print("^5Debug^7: ^1Prop ^2Created^7: '^6" ..
			prop ..
			"^7' | ^2Hash^7: ^7'^6" ..
			(data.prop) ..
			"^7' | ^2Coord^7: ^5vec4^7(^6" ..
			(coords[1]) .. "^7, ^6" .. (coords[2]) .. "^7, ^6" .. (coords[3]) .. "^7, ^6" .. (coords[4]) .. "^7)")
	end
	return prop
end

function DeleteProp(entity)
	if Config.Debug then print("^5Debug^7: ^2Destroying Prop^7: '^6" .. entity .. "^7'") end
	SetEntityAsMissionEntity(entity)
	Wait(5)
	DetachEntity(entity, true, true)
	Wait(5)
	DeleteObject(entity)
end

function CreateNewPed(model, coords, freeze, collision, scenario, anim)
	loadModel(model)
	local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.03, coords.w, false, false)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, freeze or true)
	if collision then SetEntityNoCollisionEntity(ped, PlayerPedId(), false) end
	if scenario then TaskStartScenarioInPlace(ped, scenario, 0, true) end
	if anim then
		loadAnimDict(anim[1])
		TaskPlayAnim(ped, anim[1], anim[2], 1.0, 1.0, -1, 1, 0.2, 0, 0, 0)
	end

	if Config.Debug then print("^5Debug^7: ^6Ped ^2Created for location^7: '^6" .. model .. "^7'") end

	return ped
end

function CreateBlip(data)
	local blip = AddBlipForCoord(data.coords)
	SetBlipAsShortRange(blip, true)
	SetBlipSprite(blip, data.sprite or 1)
	SetBlipColour(blip, data.col or 0)
	SetBlipScale(blip, data.scale or 0.7)
	SetBlipDisplay(blip, (data.disp or 6))
	if data.category then SetBlipCategory(blip, data.category) end
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(tostring(data.name))
	EndTextCommandSetBlipName(blip)

	if Config.Debug then print("^5Debug^7: ^6Blip ^2created for location^7: '^6" .. data.name .. "^7'") end

	return blip
end

function TriggerNotify(title, message, type, src)
	if not src then
		lib.notify({ title = title, description = message, type = type or "success" })
	else
		TriggerClientEvent('ox_lib:notify', src, { type = type or "success", title = title, description = message })
	end
end

function pairsByKeys(t)
	local a = {}
	for n in pairs(t) do a[#a + 1] = n end
	table.sort(a)
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then return nil else return a[i], t[a[i]] end
	end
	return iter
end

function countTable(table)
	local i = 0
	for keys in pairs(table) do i = i + 1 end
	return i
end

function toggleItem(give, item, amount) TriggerServerEvent("jim-mining:server:toggleItem", give, item, amount) end

function HasItem(items, amount)
	amount = (amount or 1)
	local count = exports.ox_inventory:Search('count', items)

	if count >= amount then
		if Config.Debug then
			print("^5Debug^7: ^3HasItem^7: ^5FOUND^7 ^3" ..
				count .. "^7/^3" .. amount .. " " .. tostring(items))
		end
		return true
	else
		if Config.Debug then print("^5Debug^7: ^3HasItem^7: ^2" .. tostring(items) .. " ^1NOT FOUND^7") end
		return false
	end
end

function LockInv(toggle)
	FreezeEntityPosition(cache.ped, toggle)
	LocalPlayer.state.invBusy = toggle
end

function ProgressBar(data)
	if lib.progressBar({
			duration = Config.Debug and 1000 or data.time,
			label = data.label,
			useWhileDead = data.dead or false,
			canCancel = data.cancel or true,
			disable = {
				combat = true,
			},
			anim = {
				dict = data.dict,
				clip = data.anim,
				flag = (data.flag == 8 and 32 or data.flag) or nil, scenario = data.task
			},
		}) then
		return true
	else
		return false
	end
end
