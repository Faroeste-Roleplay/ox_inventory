if not lib then return end

if GetConvar('inventory:versioncheck', 'true') == 'true' then
	lib.versionCheck('overextended/ox_inventory')
end

require 'modules.bridge.server'
require 'modules.pefcl.server'

local TriggerEventHooks = require 'modules.hooks.server'
local db = require 'modules.mysql.server'
local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'

require 'modules.crafting.server'
require 'modules.shops.server'

---@param player table
---@param data table?
--- player requires source, identifier, and name
--- optionally, it should contain jobs/groups, sex, and dateofbirth
function server.setPlayerInventory(player, data)
	while not shared.ready do Wait(0) end

	if not data then
		data = db.loadPlayer(player.identifier)
	end

	local playerInventoryConfig = shared.prime[1]

	for _, group in ipairs(shared.prime) do 
		if API.IsPlayerAceAllowedGroup( player.source, "prime_"..group.Group ) or API.IsPlayerAceAllowedGroup( player.source, group.Group ) then	
			playerInventoryConfig = group
		end
	end

	local inventory = {}
	local totalWeight = 0

	if type(data.items) == 'table' then
		local ostime = os.time()

		for _, v in pairs(data.items) do
			if type(v) == 'number' or not v.count or not v.slot then
				if server.convertInventory then
					inventory, totalWeight = server.convertInventory(player.source, data.items)
					break
				else
					return error(('Inventory for player.%s (%s) contains invalid data. Ensure you have converted inventories to the correct format.'):format(player.source, GetPlayerName(player.source)))
				end
			else
				local item = Items(v.name)

				if item then
					v.metadata = Items.CheckMetadata(v.metadata or {}, item, v.name, ostime)
					local weight = Inventory.SlotWeight(item, v)
					totalWeight = totalWeight + weight

					inventory[v.slot] = {
						name = item.name, 
						label = item.label, 
						weight = weight, 
						slot = v.slot, 
						count = v.count, 
						description = item.description, 
						metadata = v.metadata, 
						stack = item.stack, 
						close = item.close,
						
					}
				end
			end
		end
	end

	local customSlots = playerInventoryConfig.MaxSlots
	local customMaxWeight = playerInventoryConfig.MaxWeight

	if data and data.slots then
		customSlots += data.slots
	end

	if data and data.weight then
		customMaxWeight += data.weight
	end

	player.source = tonumber(player.source)
	local inv = Inventory.Create(player.source, player.name, 'player', customSlots, totalWeight, customMaxWeight, player.identifier, inventory)

	if inv then
		inv.player = server.setPlayerData(player)
		inv.player.ped = GetPlayerPed(player.source)

		if server.syncInventory then server.syncInventory(inv) end
		TriggerClientEvent('ox_inventory:setPlayerInventory', player.source, Inventory.Drops, inventory, totalWeight, inv.player)
	end
end
exports('setPlayerInventory', server.setPlayerInventory)
AddEventHandler('ox_inventory:setPlayerInventory', server.setPlayerInventory)

---@param playerPed number
---@param coordinates vector3|vector3[]
---@param distance? number
---@return vector3|false
local function getClosestStashCoords(playerPed, coordinates, distance)
	local playerCoords = GetEntityCoords(playerPed)

	if not distance then distance = 10 end

	if type(coordinates) == 'table' then
		for i = 1, #coordinates do
			local coords = coordinates[i] --[[@as vector3]]

			if #(coords - playerCoords) < distance then
				return coords
			end
		end

		return false
	end

	return #(coordinates - playerCoords) < distance and coordinates
end

---@param source number
---@param invType string
---@param data? string|number|table
---@param ignoreSecurityChecks boolean?
---@return boolean|table|nil
---@return table?
local function openInventory(source, invType, data, ignoreSecurityChecks)
	if Inventory.Lock then return false end

	local left = Inventory(source) --[[@as OxInventory]]
	local right, closestCoords

    left:closeInventory(true)
	Inventory.CloseAll(left, source)

    if invType == 'player' and data == source then
        data = nil
    end

	if data then
        local isDataTable = type(data) == 'table'
		if invType == 'stash' then
			right = Inventory(data, left)
			if right == false then return false end
		elseif isDataTable then
			if data.netid then
				data.type = invType
				right = Inventory(data)
			elseif invType == 'drop' then
				right = Inventory(data.id)
			else
				return
			end
		elseif invType == 'policeevidence' then
			if server.hasGroup(left, shared.police) then
				right = Inventory(('evidence-%s'):format(data))
			end
		elseif invType == 'dumpster' then
			right = Inventory(data)

			if not right then
				local netid = tonumber(data:sub(9))

				-- dumpsters do not work with entity lockdown. need to rewrite, but having to do
				-- distance checks to some ~7000 dumpsters and freeze the entities isn't ideal
				if netid and NetworkGetEntityFromNetworkId(netid) > 0 then
					right = Inventory.Create(data, locale('dumpster'), invType, 15, 0, 100000, false)
				end
			end
		elseif invType == 'container' then
			left.containerSlot = data --[[@as number]]
			data = left.items[data]

			if data then
				right = Inventory(data.metadata.container)

				if not right then
					right = Inventory.Create(data.metadata.container, data.label, invType, data.metadata.size[1], 0, data.metadata.size[2], false)
				end
			else left.containerSlot = nil end
		else right = Inventory(data) end

		if not right then return end

		if not ignoreSecurityChecks and right.groups and not server.hasGroup(left, right.groups) then return end

		local hookPayload = {
			source = source,
			inventoryId = right.id,
			inventoryType = right.type,
		}

		if invType == 'container' then hookPayload.slot = left.containerSlot end
		if isDataTable and data.netid then hookPayload.netId = data.netid end

		if not TriggerEventHooks('openInventory', hookPayload) then return end

        if left == right then return end

		if right.player then
			if right.open then return end

			right.coords = not ignoreSecurityChecks and GetEntityCoords(right.player.ped) or nil
		end

		if not ignoreSecurityChecks and right.coords then
			closestCoords = getClosestStashCoords(left.player.ped, right.coords)

			if not closestCoords then return end
		end

		left:openInventory(right)
	else
		left:openInventory(left)
	end

	return {
		id = left.id,
		label = left.label,
		type = left.type,
		slots = left.slots,
		weight = left.weight,
		maxWeight = left.maxWeight
	}, right and {
		id = right.id,
		label = right.player and '' or right.label,
		type = right.player and 'otherplayer' or right.type,
		slots = right.slots,
		weight = right.weight,
		maxWeight = right.maxWeight,
		items = right.items,
		coords = closestCoords or right.coords,
		distance = right.distance
	}
end

---@param source number
---@param invType string
---@param data string|number|table
lib.callback.register('ox_inventory:openInventory', function(source, invType, data)
	return openInventory(source, invType, data)
end)

lib.callback.register('ox_inventory:getItemBySlot', function(source, slot)
	return Inventory.GetSlot(source, slot)
end)

---@param netId number
lib.callback.register('ox_inventory:isVehicleATrailer', function(source, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local retval = GetVehicleType(entity)
	return retval == 'trailer'
end)

---@param playerId number
---@param invType string
---@param data string|number|table
exports('forceOpenInventory', function(playerId, invType, data)
	local left, right = openInventory(playerId, invType, data, true)

	if left and right then
		TriggerClientEvent('ox_inventory:forceOpenInventory', playerId, left, right)
		return right.id
	end
end)

local Licenses = lib.load('data.licenses')

lib.callback.register('ox_inventory:buyLicense', function(source, id)
	local license = Licenses[id]
	if not license then return end

	local inventory = Inventory(source)
	if not inventory then return end

	return server.buyLicense(inventory, license)
end)

lib.callback.register('ox_inventory:getItemCount', function(source, item, metadata, target)
	local inventory = target and Inventory(target) or Inventory(source)
	return (inventory and Inventory.GetItem(inventory, item, metadata, true)) or 0
end)

lib.callback.register('ox_inventory:getInventory', function(source, id)
	local inventory = Inventory(id or source)
	return inventory and {
		id = inventory.id,
		label = inventory.label,
		type = inventory.type,
		slots = inventory.slots,
		weight = inventory.weight,
		maxWeight = inventory.maxWeight,
		owned = inventory.owner and true or false,
		items = inventory.items
	}
end)

RegisterNetEvent('ox_inventory:usedItemInternal', function(slot)
    local inventory = Inventory(source)

    if not inventory then return end

    local item = inventory.usingItem

    if not item or item.slot ~= slot then
        ---@todo
        -- DropPlayer(inventory.id, 'sussy')
		Inventory.RemoveItem(inventory.id, item.name, 1, nil, item.slot)
        return
    end

    TriggerEvent('ox_inventory:usedItem', inventory.id, item.name, item.slot, next(item.metadata) and item.metadata)

    inventory.usingItem = nil
end)

---@param source number
---@param itemName string
---@param slot number?
---@param metadata { [string]: any }?
---@return table | boolean | nil
lib.callback.register('ox_inventory:useItem', function(source, itemName, slot, metadata, noAnim)
	local inventory = Inventory(source) --[[@as OxInventory]]

	if inventory and inventory.player then
		local item = Items(itemName)
		local data = item and (slot and inventory.items[slot] or Inventory.GetSlotWithItem(inventory, item.name, metadata, true))

		if not data then return end

		slot = data.slot
		local durability = data.metadata.durability --[[@as number|boolean|nil]]
		local consume = item.consume
		local label = data.metadata.label or item.label

		if durability and consume then
			if durability > 100 then
				local ostime = os.time()

				if ostime > durability then
                    Items.UpdateDurability(inventory, data, item, 0)
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
				elseif consume ~= 0 and consume < 1 then
					local degrade = (data.metadata.degrade or item.degrade) * 60
					local percentage = ((durability - ostime) * 100) / degrade

					if percentage < consume * 100 then
						return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('not_enough_durability', label) })
					end
				end
			elseif durability <= 0 then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
			elseif consume ~= 0 and consume < 1 and durability < consume * 100 then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('not_enough_durability', label) })
			end

			if data.count > 1 and consume < 1 and consume > 0 and not Inventory.GetEmptySlot(inventory) then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('cannot_use', label) })
			end
		end

		if item and data and data.count > 0 and data.name == item.name then
			data = {name=data.name, label=label, count=data.count, slot=slot, metadata=data.metadata, weight=data.weight}

			if item.ammo then

				if inventory.weapon then
					local weapon = inventory.items[inventory.weapon]

					if IS_GTAV then
						if weapon and weapon?.metadata.durability > 0 then
							consume = nil
						end
					end

					if IS_RDR3 then
						if weapon and weapon?.metadata.degradation < 1.0 then
							consume = nil
						end
					end

				else return false end
			elseif item.component or item.tint then
				consume = 1
				data.component = true
			elseif consume then
				if data.count >= consume then
					local result = item.cb and item.cb('usingItem', item, inventory, slot)

					if result == false then return end

					if result ~= nil then
						data.server = result
					end
				else
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('item_not_enough', item.name) })
				end
			elseif not item.weapon and server.UseItem then
                inventory.usingItem = data
				-- This is used to call an external useItem function, i.e. ESX.UseItem / QBCore.Functions.CanUseItem
				-- If an error is being thrown on item use there is no internal solution. We previously kept a list
				-- of usable items which led to issues when restarting resources (for obvious reasons), but config
				-- developers complained the inventory broke their items. Safely invoking registered item callbacks
				-- should resolve issues, i.e. https://github.com/esx-framework/esx-legacy/commit/9fc382bbe0f5b96ff102dace73c424a53458c96e
				return pcall(server.UseItem, source, data.name, data)
			end

			data.consume = consume

            if not TriggerEventHooks('usingItem', {
				source = source,
                inventoryId = inventory and inventory.id,
                item = inventory.items[slot],
                consume = consume
			}) then return false end

            ---@type boolean
			local success = lib.callback.await('ox_inventory:usingItem', source, data, noAnim)

			if item.weapon then
				inventory.weapon = success and slot or nil
			end

			if not success then return end

            inventory.usingItem = data

			if consume and consume ~= 0 and not data.component then
				data = inventory.items[data.slot]

				if not data then return end

				durability = consume ~= 0 and consume < 1 and data.metadata.durability --[[@as number | false]]

				if durability then
					if durability > 100 then
						local degrade = (data.metadata.degrade or item.degrade) * 60
						durability -= degrade * consume
					else
						durability -= consume * 100
					end

					if data.count > 1 then
						local emptySlot = Inventory.GetEmptySlot(inventory)

						if emptySlot then
							local newItem = Inventory.SetSlot(inventory, item, 1, table.deepclone(data.metadata), emptySlot)

							if newItem then
                                Items.UpdateDurability(inventory, newItem, item, durability)
							end
						end

						durability = 0
					else
                        Items.UpdateDurability(inventory, data, item, durability)
					end

					if durability <= 0 then
						durability = false
					end
				end

				if not durability then
					Inventory.RemoveItem(inventory.id, data.name, consume < 1 and 1 or consume, nil, data.slot)
				else
					inventory.changed = true

					if server.syncInventory then server.syncInventory(inventory) end
				end

				if item?.cb then
					item.cb('usedItem', item, inventory, data.slot)
				end
			end

			return true
		end
	end
end)

local function conversionScript()
	shared.ready = false

	local file = 'setup/convert.lua'
	local import = LoadResourceFile(shared.resource, file)
	local func = load(import, ('@@%s/%s'):format(shared.resource, file)) --[[@as function]]

	conversionScript = func()
end

-- RegisterCommand('convertinventory', function(source, args)
-- 	if source ~= 0 then return warn('This command can only be executed with the server console.') end
-- 	if type(conversionScript) == 'function' then conversionScript() end
-- 	local arg = args[1]

-- 	local convert = arg and conversionScript[arg]

-- 	if not convert then
-- 		return warn('Invalid conversion argument. Valid options: esx, esxproperty, qb, linden')
-- 	end

-- 	CreateThread(convert)
-- end, true)


local discordWebHook = "DISCORD_WEBHOOK_TO_LOG"

function logs(playerId, message)
	local playerDiscord = GetPlayerIdentifierByType( playerId, "discord") 

    local embedData = {
        {
            ["title"] = "Staff Give Item",
            ["color"] = 4777493,
            ['type'] = "rich",
            ["footer"] = {
                ["text"] = os.date("%c"),
            },
            ["description"] = ("%s \n <@%s>"):format(message, playerDiscord:gsub('discord:', '')),
            ["author"] = {
                ["name"] = 'Valiria Logs',
            },
        }
    }

    PerformHttpRequest(discordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = "Fiscal", embeds = embedData}), { ['Content-Type'] = 'application/json' })
end

lib.addCommand({'additem', 'giveitem'}, {
	help = 'Gives an item to a player with the given id',
	params = {
		{ name = 'target', type = 'number', help = 'The player to receive the item' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of the item to give', optional = true },
		{ name = 'type', help = 'Sets the "type" metadata to the value', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local User = API.GetUserFromUserId( tonumber( args.target ) )

		if not User then
			return Citizen.Trace(('Usuário inválido %s'):format(args.target))
		end

		local reason 

		if source > 0 then
			reason = cAPI.Prompt(source, "Motivo do give", "")
			if not reason or reason == '' then
				if string.len( reason ) < 15 then
					cAPI.Notify(source, "error", "Precisa ser mais explicativo")
					return
				end
				cAPI.Notify(source, "error", "É obrigatório informar um motivo")
				return
			end
		else
			reason = "Givado pelo Console do TX Admin"
		end

		local targetSource = User:GetSource()

		local inventory = Inventory(targetSource) --[[@as OxInventory]]
		local count = args.count or 1

		local success, response = Inventory.AddItem(inventory, item.name, count, args.type and { type = tonumber(args.type) or args.type })

		if not success then
			return Citizen.Trace(('Failed to give %sx %s to player %s (%s)'):format(count, item.name, targetSource, response))
		end

		source = Inventory(source) or { label = 'console', owner = 'console' }

		if server.loglevel > 0 then
			local msg = ('"%s" deu %sx %s (%s) para "%s"'):format(source.label, count, item.name, reason, inventory.label)
			lib.logger(source.source, 'admin', msg)
			logs(source.source, msg )
		end
	end
end)


lib.addCommand('removeitem', {
	help = 'Removes an item to a player with the given id',
	params = {
		{ name = 'target', type = 'number', help = 'The player to remove the item from' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of the item to take' },
		{ name = 'type', help = 'Only remove items with a matching metadata "type"', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item and args.count > 0 then

		local User = API.GetUserFromUserId( tonumber( args.target ) )

		if not User then
			return Citizen.Trace(('Usuário inválido %s'):format(args.target))
		end

		local targetSource = User:GetSource()

		local inventory = Inventory( targetSource ) --[[@as OxInventory]]
		local success, response = Inventory.RemoveItem(inventory, item.name, args.count, args.type and { type = tonumber(args.type) or args.type }, nil, true)

		if not success then
			return Citizen.Trace(('Failed to remove %sx %s from player %s (%s)'):format(args.count, item.name, args.target, response))
		end

		source = Inventory(source) or {label = 'console', owner = 'console'}

		if server.loglevel > 0 then
			lib.logger(source.source, 'admin', ('"%s" removed %sx %s from "%s"'):format(source.label, args.count, item.name, inventory.label))
		end
	end
end)

-- lib.addCommand('setitem', {
-- 	help = 'Sets the item count for a player, removing or adding as needed',
-- 	params = {
-- 		{ name = 'target', type = 'number', help = 'The player to set the items for' },
-- 		{ name = 'item', type = 'string', help = 'The name of the item' },
-- 		{ name = 'count', type = 'number', help = 'The amount of items to set', optional = true },
-- 		{ name = 'type', help = 'Add or remove items with the metadata "type"', optional = true },
-- 	},
-- 	restricted = 'group.admin',
-- }, function(source, args)
-- 	local item = Items(args.item)

-- 	if item then
-- 		local User = API.GetUserFromUserId(  args.target  )

-- 		if not User then
-- 			return Citizen.Trace(('Usuário inválido %s'):format(args.target))
-- 		end

-- 		local targetSource = User:GetSource()

-- 		local inventory = Inventory( targetSource ) --[[@as OxInventory]]
-- 		local success, response = Inventory.SetItem(inventory, item.name, args.count or 0, args.type and { type = tonumber(args.type) or args.type })

-- 		if not success then
-- 			return Citizen.Trace(('Failed to set %s count to %sx for player %s (%s)'):format(item.name, args.count, args.target, response))
-- 		end

-- 		source = Inventory(source) or {label = 'console', owner = 'console'}

-- 		if server.loglevel > 0 then
-- 			lib.logger(source.source, 'admin', ('"%s" set "%s" %s count to %sx'):format(source.label, inventory.label, item.name, args.count))
-- 		end
-- 	end
-- end)

lib.addCommand('clearevidence', {
	help = 'Clears a police evidence locker with the given id',
	params = {
		{ name = 'locker', type = 'number', help = 'The locker id to clear' },
	},
}, function(source, args)
	if not server.isPlayerBoss then return end

	local inventory = Inventory(source)
	local group, grade = server.hasGroup(inventory, shared.police)
	local hasPermission = group and server.isPlayerBoss(source, group, grade)

	if hasPermission then
		MySQL.query('DELETE FROM ox_inventory WHERE name = ?', {('evidence-%s'):format(args.locker)})
	end
end)

lib.addCommand('takeinv', {
	help = 'Confiscates the target inventory, to restore with /restoreinv',
	params = {
		{ name = 'target', type = 'number', help = 'The player to confiscate items from' },
	},
	restricted = 'group.admin',
}, function(source, args)
	local User = API.GetUserFromUserId( tonumber( args.target ) )

	if not User then
		return Citizen.Trace(('Usuário inválido %s'):format(args.target))
	end

	local targetSource = User:GetSource()

	Inventory.Confiscate( targetSource )
end)

lib.addCommand({'restoreinv', 'returninv'}, {
	help = 'Restores a previously confiscated inventory for the target',
	params = {
		{ name = 'target', type = 'number', help = 'The player to restore items to' },
	},
	restricted = 'group.admin',
}, function(source, args)
	local User = API.GetUserFromUserId( tonumber( args.target ) )

	if not User then
		return Citizen.Trace(('Usuário inválido %s'):format(args.target))
	end

	local targetSource = User:GetSource()

	Inventory.Return(targetSource)
end)

lib.addCommand('clearinv', {
	help = 'Wipes all items from the target inventory',
	params = {
		{ name = 'target', type = "number", help = 'The inventory to wipe items from' },
	},
	restricted = 'group.admin',
}, function(source, args)
	local User = API.GetUserFromUserId( tonumber( args.target ) or source )

	if not User then
		return Citizen.Trace(('Usuário inválido %s'):format(args.target))
	end

	local targetSource = User:GetSource()

	Inventory.Clear(targetSource)
end)

lib.addCommand('saveinv', {
	help = 'Save all pending inventory changes to the database',
	params = {
		{ name = 'lock', help = 'Lock inventory access, until restart or saved without a lock', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.SaveInventories(args.lock == 'true', false)
end)

lib.addCommand('viewinv', {
	help = 'Inspect the target inventory without allowing interactions',
	params = {
		{ name = 'invId', help = 'The inventory to inspect' },
	},
	restricted = 'group.admin',
}, function(source, args)


	local User = API.GetUserFromUserId( tonumber( args.target ) )

	if not User then
		return Citizen.Trace(('Usuário inválido %s'):format(args.target))
	end

	local targetSource = User:GetSource()

	Inventory.InspectInventory(source, targetSource)
end)

RegisterNetEvent("inventory:server:forceRemoveItemWithNoDurability", function( slotId, itemName )
	local playerId = source
	exports.ox_inventory:RemoveItem(playerId, itemName, 1, nil, slotId)
end)

RegisterNetEvent("inventory:server:forceRemoveItem", function( itemName, amount )
	local playerId = source
	exports.ox_inventory:RemoveItem(playerId, itemName, amount)
end)

RegisterNetEvent("inventory:server:RemoveByConsume", function(slot, playerId)
	local playerId = playerId or source

	if not playerId then
		return
	end

	local slotKey = slot.slot

	local item = Inventory(playerId).items[slotKey]

	local itemInfo = Items(item.name)
	local itemInfoDegrade = ( itemInfo?.metadata?.consume or itemInfo?.consume )

	-- local changePercentage = (durability / 100)

	-- local change = (60 * itemInfoDegrade) * changePercentage

	local prevDurability = item.metadata.durability
	local remove = prevDurability * itemInfoDegrade

	local newDurability = prevDurability - remove

	Inventory.SetDurability(playerId, slotKey, newDurability)
end)


RegisterNetEvent("inventory:server:RemoveDurability", function(slot, durability, playerId)
	local playerId = playerId or source

	if not playerId then
		return
	end

	local slotKey = slot.slot

	local itemInfo = Items(slot.name)

	local itemInfoDegrade = itemInfo?.metadata?.degrade or itemInfo?.degrade

	local item = Inventory(playerId).items[slotKey]

	local changePercentage = (durability / 100)

	local change = (60 * itemInfoDegrade) * changePercentage

	local prevDurability = item.metadata.durability

	local newDurability = prevDurability - change

	Inventory.SetDurability(playerId, slotKey, newDurability)
end)

local PickupToItem = data 'pickup_to_item'

RegisterServerEvent('inventory:addWeaponFromPickup', function(pickupHash)
	local playerId = source

	local inv = Inventory(playerId)

	local item = PickupToItem[pickupHash]

	if item then
		Inventory.AddItem(inv, item, 1)
	end
end)

RegisterNetEvent("inventory:tryPileMoney", function()
	local playerId = source
	local amountPerPack = 10

	local itemName = "money_clip"

	local amount = Inventory.GetItem( playerId, itemName, nil, true)

	if amount >= amountPerPack then
		Inventory.AddItem(playerId, "money_stack", 1)
		Inventory.RemoveItem(playerId, itemName, amountPerPack)
		return true
	else
		TriggerClientEvent("texas:notify:native", playerId, "Preciso ter 10 para fazer uma pilha")
		return false
	end
end)

RegisterNetEvent("inventory:removeOilGun", function()
	local playerId = source

    local Item = exports.ox_inventory:GetItem(playerId, 'oil_gun')

    if Item.count < 1 then
        Item = exports.ox_inventory:GetItem(playerId, 'oil_gun')
        if Item.count < 1 then
            return
        end
    end

    return exports.ox_inventory:RemoveItem(playerId, Item.name, 1)
end)


RegisterNetEvent("inventory:tryHoneycombs", function()
	local playerId = source
	local amountPerPack = 10

	local itemName = "honeycombs"
	local amount = Inventory.GetItem( playerId, itemName, nil, true)

	if amount >= amountPerPack then
		local honeyMaxAmount = 5
		local totalAmount = 5

		Inventory.AddItem(playerId, "honey", totalAmount)
		Inventory.AddItem(playerId, "honey_wax", honeyMaxAmount)

		Inventory.RemoveItem(playerId, itemName, amountPerPack)
		return true
	else
		TriggerClientEvent("texas:notify:native", playerId, "Preciso ter 10 para fazer mel")
		return false
	end
end)

RegisterNetEvent("inventory:tryCoalBox", function()
	local playerId = source
	local amountPerPack = 10

	local itemName = "ore_coal_nugget"
	local amount = Inventory.GetItem( playerId, itemName, nil, true)
	local boxAmount = Inventory.GetItem( playerId, "container_box", nil, true)

	if boxAmount < 1 then 
		TriggerClientEvent("texas:notify:native", playerId, "Preciso ter uma caixa de madeira")
		return false
	end

	if amount >= amountPerPack then
		Inventory.AddItem(playerId, "ore_coal_box", 1)

		Inventory.RemoveItem(playerId, "container_box", 1)
		Inventory.RemoveItem(playerId, itemName, amountPerPack)
		return true
	else
		TriggerClientEvent("texas:notify:native", playerId, "Preciso ter 50 para fazer uma caixa")
		return false
	end
end)

local function reloadPlayerInventory (User, charId) 
	server.playerDropped( User:GetSource() )
	Wait(1000)

	local Player = User:GetCharacter()
	if not Player then return end

	local PlayerData = {}
	PlayerData.source = Player.source

	PlayerData.inventory = Player.Inventory.items
	PlayerData.slots = Player.Inventory.slots
	PlayerData.weight = Player.Inventory.weight
	PlayerData.identifier = charId or Player.id
	PlayerData.citizenId = Player.citizenId

	shared.playerslots = Player.Inventory.slots
	shared.playerweight = Player.Inventory.weight

	PlayerData.name = ('%s %s (%s)'):format(Player.firstName, Player.lastName, Player.citizenId)
	server.setPlayerInventory(PlayerData)
end

AddEventHandler('ox_inventory:addAdditionalSlots', function( playerId, characterId )
	local inv = MySQL.single.await('SELECT weight, slots FROM character_inventory WHERE charId = ? LIMIT 1', { characterId })

	if inv?.slots >= 100 then
		TriggerClientEvent("texas:notify:simple", playerId, "Já estou no maximo da minha bolsa")
		return
	end

	local res = MySQL.update.await('UPDATE character_inventory SET weight = weight + ?, slots = slots + ? WHERE charId = ? ', {2500, 5, characterId })

	if res ~= nil then
		Inventory.RemoveItem(playerId, "bag_container", 1)
		local User = API.GetUserFromSource( playerId )
		reloadPlayerInventory( User, characterId )
		TriggerClientEvent("texas:notify:simple", playerId, "Aumentei os espaços na minha bolsa")
	else
		TriggerClientEvent("texas:notify:simple", playerId, "Ocorreu um erro ao tentar aumentar a bolsa")
	end
end)

AddEventHandler('ox_inventory:removeAdditionalSlots', function( playerId, characterId )
	local res = MySQL.update.await('UPDATE character_inventory SET weight = 0, slots = 0 WHERE charId = ? ', { characterId })

	if res ~= nil then
		local User = API.GetUserFromSource( playerId )

		reloadPlayerInventory( User, characterId )

		TriggerClientEvent("texas:notify:simple", playerId, "Perdi os expaços extras na minha bolsa")
	else
		-- TriggerClientEvent("texas:notify:simple", playerId, "Ocorreu um erro ao tentar aumentar a bolsa")
	end
end)
