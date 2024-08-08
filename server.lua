RegisterServerEvent('jim-mining:Crafting:GetItem', function(ItemMake, craftable)
	local src, amount = source, 1
	if not src then return end

	if craftable then
		if craftable["amount"] then amount = craftable["amount"] end

		for k, v in pairs(craftable[ItemMake]) do
			TriggerEvent("jim-mining:server:toggleItem", false, tostring(k), v, src)
		end
	end

	TriggerEvent("jim-mining:server:toggleItem", true, ItemMake, amount, src)
end)

RegisterServerEvent("jim-mining:Reward", function(data)
	local src, amount = source, 1
	if not src then return end

	if data.mine then
		TriggerEvent("jim-mining:server:toggleItem", true, "stone", math.random(1, 3), src)
	elseif data.crack then
		TriggerEvent("jim-mining:server:toggleItem", false, "stone", data.cost, src)
		for _ = 1, math.random(1, 3) do
			amount = math.random(1, 2)

			TriggerEvent("jim-mining:server:toggleItem", true, Config.CrackPool[math.random(1, #Config.CrackPool)],
				amount, src)
		end
	elseif data.wash then
		TriggerEvent("jim-mining:server:toggleItem", false, "stone", data.cost, src)
		for _ = 1, math.random(1, 2) do
			TriggerEvent("jim-mining:server:toggleItem", true, Config.WashPool[math.random(1, #Config.WashPool)], amount,
				src)
		end
	elseif data.pan then
		for _ = 1, math.random(1, 3) do
			TriggerEvent("jim-mining:server:toggleItem", true, Config.PanPool[math.random(1, #Config.PanPool)], amount,
				src)
		end
	end
end)

RegisterNetEvent("jim-mining:Selling", function(itemName)
	local src = source
	if not src then return end

	local itemCount = exports.ox_inventory:GetItemCount(src, itemName)

	if itemCount > 0 then
		TriggerEvent("jim-mining:server:toggleItem", false, itemName, itemCount, src)
		exports.ox_inventory:AddItem("cash", (itemCount * Config.SellingPrices[itemName]))
	end
end)

RegisterNetEvent('jim-mining:server:toggleItem', function(give, item, amount, newsrc)
	local src = newsrc or source

	if give == 0 or give == false then
		if HasItem(src, item, amount or 1) then -- check if you still have the item
			exports.ox_inventory:RemoveItem(src, item, amount)

			if Config.Debug then
				print("^5Debug^7: ^1Removing ^2from Player^7(^2" ..
					src .. "^7) '^6" .. item .. "^7(^2x^6" .. (amount or "1") .. "^7)'")
			end
		end
	else
		if exports.ox_inventory:AddItem(src, item, amount or 1) then
			if Config.Debug then
				print("^5Debug^7: ^4Giving ^2Player^7(^2" ..
					src .. "^7) '^6" .. item .. "^7(^2x^6" .. (amount or "1") .. "^7)'")
			end
		end
	end
end)

exports.ox_inventory:RegisterShop("miningShop", { name = Config.Items.label, inventory = Config.Items.items })

function HasItem(src, items, amount)
	local count = exports.ox_inventory:Search(src, 'count', items)

	if count >= (amount or 1) then
		if Config.Debug then print("^5Debug^7: ^3HasItem^7: ^5FOUND^7 x^3" .. count .. "^7 ^3" .. tostring(items)) end
		return true
	else
		if Config.Debug then print("^5Debug^7: ^3HasItem^7: ^2Items ^1NOT FOUND^7") end
		return false
	end
end

AddEventHandler('onResourceStart', function(resource)
	if GetCurrentResourceName() ~= resource then return end
	local items = exports.ox_inventory:Items()


	for k, _ in pairs(Config.SellingPrices) do
		if not items[k] then
			print(
				"Selling: Missing Item: " .. k)
		end
	end

	for i = 1, #Config.CrackPool do
		if not items[Config.CrackPool[i]] then
			print(
				"CrackPool: Missing Item: " .. Config.CrackPool[i])
		end
	end

	for i = 1, #Config.WashPool do
		if not items[Config.WashPool[i]] then
			print(
				"WashPool: Missing Item: " .. Config.WashPool[i])
		end
	end

	for i = 1, #Config.PanPool do
		if not items[Config.PanPool[i]] then
			print(
				"PanPool: Missing Item: " .. Config.PanPool[i])
		end
	end

	for i = 1, #Config.Items.items do
		if not items[Config.Items.items[i].name] then
			print(
				"Shop: Missing Item: " .. Config.Items.items[i].name)
		end
	end

	local itemcheck = {}
	for _, v in pairs(Crafting) do
		for _, b in pairs(v) do
			for k, l in pairs(b) do
				if k ~= "amount" then
					itemcheck[k] = {}

					if type(l) == "table" then
						for j in pairs(l) do itemcheck[j] = {} end
					end
				end
			end
		end
	end

	for k in pairs(itemcheck) do
		if not items[k] then print("Crafting recipe couldn't find item '" .. k) end
	end
end)
