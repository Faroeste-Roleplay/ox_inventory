if not lib then return end

require 'modules.bridge.client'
require 'modules.interface.client'

local Utils = require 'modules.utils.client'
local Weapon = require 'modules.weapon.client'
local currentWeapon

local hotbarOpen = false

exports('getCurrentWeapon', function()
	return currentWeapon
end)

RegisterNetEvent('ox_inventory:disarm', function(noAnim)
	currentWeapon = Weapon.Disarm(currentWeapon, noAnim)
end)

RegisterNetEvent('ox_inventory:clearWeapons', function()
	Weapon.ClearAll(currentWeapon)
end)

RegisterNetEvent('tryLockpicking', function(lockpickHealth)
	local entity, entityType = Utils.Raycast(2|16)

	if not entity then return end

	-- if not shared.target and entityType == 3 then
	-- 	local model = GetEntityModel(entity)

	-- 	if model and Inventory?.Dumpsters[model] then
	-- 		return Inventory.OpenDumpster(entity)
	-- 	end
	-- end

	if entityType ~= 2 then return end

	local tryLockpick = exports.lockpicking:lockpick(lockpickHealth, 10, 10, 10)
	if tryLockpick then
		Inventory.OpenTrunk(entity, true)
	end
end)


local StashTarget

exports('setStashTarget', function(id, owner)
	StashTarget = id and {id=id, owner=owner}
end)

---@type boolean | number
local invBusy = true

---@type boolean?
local invOpen = false
local plyState = LocalPlayer.state
local IsPedCuffed = IsPedCuffed
local playerPed = cache.ped
local currentInteractedEntityId

gCanPlayerCloseInventory = true

lib.onCache('ped', function(ped)
	playerPed = ped
	Utils.WeaponWheel()
end)

plyState:set('invBusy', true, false)
plyState:set('invHotkeys', false, false)
plyState:set('canUseWeapons', false, false)

local function canOpenInventory()
    if not PlayerData.loaded then
        return shared.info('cannot open inventory', '(is not loaded)')
    end

    if IsPauseMenuActive() then return end

    if invBusy or invOpen == nil or (currentWeapon and currentWeapon.timer ~= 0) then
        return shared.info('cannot open inventory', '(is busy)')
    end

    if PlayerData.dead or IsPedFatallyInjured(playerPed) then
        return shared.info('cannot open inventory', '(fatal injury)')
    end

    if PlayerData.cuffed or IsPedCuffed(playerPed) then
        return shared.info('cannot open inventory', '(cuffed)')
    end

    return true
end

---@param ped number
---@return boolean
local function canOpenTarget(ped)
	return IsPedFatallyInjured(ped)
	or IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3)
	or IsPedCuffed(ped)
	or IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3)
	or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 3)
	or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_enter', 3)
	or IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)
	or IsEntityPlayingAnim(ped, 'script_proc@robberies@shop@rhodes@gunsmith@inside_upstairs', 'handsup_register_owner', 3)
end

local defaultInventory = {
	type = 'newdrop',
	slots = shared.playerslots,
	weight = 0,
	maxWeight = shared.playerweight,
	items = {}
}

local currentInventory = defaultInventory

local function closeTrunk()
	if currentInventory?.type == 'trunk' then
		local coords = GetEntityCoords(playerPed, true)
		if IS_GTAV then
			---@todo animation for vans?
			Utils.PlayAnimAdvanced(0, 'anim@heists@fleeca_bank@scope_out@return_case', 'trevor_action', coords.x, coords.y, coords.z, 0.0, 0.0, GetEntityHeading(playerPed), 2.0, 2.0, 1000, 49, 0.25)
		end

		CreateThread(function()
			local entity = currentInventory.entity
			local door = currentInventory.door
			Wait(900)

			if type(door) == 'table' then
				for i = 1, #door do
					SetVehicleDoorShut(entity, door[i], false)
				end
			else
				SetVehicleDoorShut(entity, door, false)
			end
		end)
	end
end

local CraftingBenches = require 'modules.crafting.client'
local Vehicles = lib.load('data.vehicles')
local Inventory = require 'modules.inventory.client'

---@param inv string?
---@param data any?
---@return boolean?
function client.openInventory(inv, data)
	if invOpen then

		if IS_RDR3 then
			if data and type(data) ~= "number" and data?.netid then
				local entity = NetworkGetEntityFromNetworkId(data.netid)

				if inv == "glovebox" then
					if DoesEntityExist(entity) and not Citizen.InvokeNative(0xAAB0FE202E9FC9F0, entity, -1) then
						return client.closeInventory()
					end
				end
			end
		end

		if not inv and currentInventory.type == 'newdrop' then
			return client.closeInventory()
		end

		if IsNuiFocused() then
			if inv == 'container' and currentInventory.id == PlayerData.inventory[data].metadata.container then
				return client.closeInventory()
			end

			if currentInventory.type == 'drop' and (not data or currentInventory.id == (type(data) == 'table' and data.id or data)) then
				return client.closeInventory()
			end

			if inv ~= 'drop' and inv ~= 'container' then
				if (data?.id or data) == currentInventory?.id then
					-- Triggering exports.ox_inventory:openInventory('stash', 'mystash') twice in rapid succession is weird behaviour
					return warn(("script tried to open inventory, but it is already open\n%s"):format(Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString())))
				else
					return client.closeInventory()
				end
			end
		end
	elseif IsNuiFocused() then
		-- If triggering from another nui, may need to wait for focus to end.
		Wait(100)

        -- People still complain about this being an "error" and ask "how fix" despite being a warning
        -- for people with above room-temperature iqs to look into resource conflicts on their own.
		-- if IsNuiFocused() then
		-- 	warn('other scripts have nui focus and may cause issues (e.g. disable focus, prevent input, overlap inventory window)')
		-- end
	end

	if inv == 'dumpster' and cache.vehicle then
		return lib.notify({ id = 'inventory_right_access', type = 'error', description = locale('inventory_right_access') })
	end

	if canOpenInventory() then
		local left, right

		if inv == 'player' and data ~= cache.serverId then
			local targetId, targetPed

			if not data then
				targetId, targetPed = Utils.GetClosestPlayer()
				data = targetId and GetPlayerServerId(targetId)
			else
				local serverId = type(data) == 'table' and data.id or data

				if serverId == cache.serverId then return end

				targetId = serverId and GetPlayerFromServerId(serverId)
				targetPed = targetId and GetPlayerPed(targetId)
			end

			local targetCoords = targetPed and GetEntityCoords(targetPed)

			if not targetCoords or #(targetCoords - GetEntityCoords(playerPed)) > 1.8 or not (client.hasGroup(shared.police) or canOpenTarget(targetPed)) then
				return lib.notify({ id = 'inventory_right_access', type = 'error', description = locale('inventory_right_access') })
			end
		end

		if inv == 'shop' and invOpen == false then
			if cache.vehicle then
				return lib.notify({ id = 'cannot_perform', type = 'error', description = locale('cannot_perform') })
			end

			left, right = lib.callback.await('ox_inventory:openShop', 200, data)
		elseif inv == 'crafting' then
			if cache.vehicle then
				return lib.notify({ id = 'cannot_perform', type = 'error', description = locale('cannot_perform') })
			end

			left = lib.callback.await('ox_inventory:openCraftingBench', 200, data.id, data.index)

			if left then
				right = CraftingBenches[data.id]

				if not right?.items then return end

				local coords, distance

				if not right.zones and not right.points then
					coords = GetEntityCoords(cache.ped)
					distance = 2
				else
					coords = shared.target and right.zones and right.zones[data.index].coords or right.points and right.points[data.index]
					distance = coords and shared.target and right.zones[data.index].distance or 2
				end

				right = {
					type = 'crafting',
					id = data.id,
					label = right.label or locale('crafting_bench'),
					index = data.index,
					slots = right.slots,
					items = right.items,
					coords = coords,
					distance = distance
				}
			end
		elseif invOpen ~= nil then
			if inv == 'policeevidence' then
                if not data then
                    local input = lib.inputDialog(locale('police_evidence'), {
                        { label = locale('locker_number'), type = 'number', required = true, icon = 'calculator' }
                    }) --[[@as number[]? ]]

                    if not input then return end

                    data = input[1]
                end
			end
			left, right = lib.callback.await('ox_inventory:openInventory', false, inv, data)
		end

		-- Stash does not exist
		if not left then
			if left == false then return false end
	
			if invOpen == false then
				return lib.notify({ id = 'inventory_right_access', type = 'error', description = locale('inventory_right_access') })
			end
	
			if invOpen then return client.closeInventory() end
		end
	
		if not cache.vehicle then
			if IS_GTAV then
				if inv == 'player' then
					Utils.PlayAnim(0, 'mp_common', 'givetake1_a', 8.0, 1.0, 2000, 50, 0.0, 0, 0, 0)
				elseif inv ~= 'trunk' then
					Utils.PlayAnim(0, 'pickup_object', 'putdown_low', 5.0, 1.5, 1000, 48, 0.0, 0, 0, 0)
				end
			end
		end

		plyState.invOpen = true

		SetInterval(client.interval, 100)
		SetNuiFocus(true, true)
		SetNuiFocusKeepInput(true)
		closeTrunk()

		if IS_GTAV then
			if client.screenblur then TriggerScreenblurFadeIn(0) end
		end

		currentInventory = right or defaultInventory
		left.items = PlayerData.inventory
		left.groups = PlayerData.groups

		SendNUIMessage({
			action = 'setupInventory',
			data = {
				leftInventory = left,
				rightInventory = currentInventory
			}
		})

		if not currentInventory.coords and not inv == 'container' then
			currentInventory.coords = GetEntityCoords(playerPed)
		end

		if inv == 'trunk' then
			SetTimeout(200, function()
				---@todo animation for vans?

				if IS_GTAV then
					Utils.PlayAnim(0, 'anim@heists@prison_heiststation@cop_reactions', 'cop_b_idle', 3.0, 3.0, -1, 49, 0.0, 0, 0, 0)

					local entity = data.entity or NetworkGetEntityFromNetworkId(data.netid)
					currentInventory.entity = entity
					currentInventory.door = data.door

					if not currentInventory.door then
						local vehicleHash = GetEntityModel(entity)
						local vehicleClass = GetVehicleClass(entity)
						currentInventory.door = vehicleClass == 12 and { 2, 3 } or Vehicles.Storage[vehicleHash] and 4 or 5
					end

					while currentInventory?.entity == entity and invOpen and DoesEntityExist(entity) and Inventory.CanAccessTrunk(entity) do
						Wait(100)
					end
					if invOpen then client.closeInventory() end
				end

			end)
		end

		return true
	else lib.notify({ id = 'inventory_player_access', type = 'error', description = locale('inventory_player_access') }) end
end

RegisterNetEvent('ox_inventory:openInventory', client.openInventory)
exports('openInventory', client.openInventory)

RegisterNetEvent('ox_inventory:forceOpenInventory', function(left, right)
	if source == '' then return end

	plyState.invOpen = true

	SetInterval(client.interval, 100)
	SetNuiFocus(true, true)
	SetNuiFocusKeepInput(true)
	closeTrunk()

	if IS_GTAV then
		if client.screenblur then TriggerScreenblurFadeIn(0) end
	end

	currentInventory = right or defaultInventory
	currentInventory.ignoreSecurityChecks = true
	left.items = PlayerData.inventory
	left.groups = PlayerData.groups

	SendNUIMessage({
		action = 'setupInventory',
		data = {
			leftInventory = left,
			rightInventory = currentInventory
		}
	})
end)

local Animations = lib.load('data.animations')
local Items = require 'modules.items.client'

local usingItem = false

---@param data { name: string, label: string, count: number, slot: number, metadata: table<string, any>, weight: number }
lib.callback.register('ox_inventory:usingItem', function(data, noAnim)
	local item = Items[data.name]

	if item and usingItem then
		if not item.client then return true end
		---@cast item +OxClientProps
		item = item.client

		if type(item.anim) == 'string' then
			item.anim = Animations.anim[item.anim]
		end

		if item.prop then
			if item.prop[1] then
				for i = 1, #item.prop do
					if type(item.prop) == 'string' then
						item.prop = Animations.prop[item.prop[i]]
					end
				end
			elseif type(item.prop) == 'string' then
				item.prop = Animations.prop[item.prop]
			end
		end

		if not item.disable then
			item.disable = { combat = true }
		elseif item.disable.combat == nil then
			-- Backwards compatibility; you probably don't want people shooting while eating and bandaging anyway
			item.disable.combat = true
		end

		local success = (not item.usetime or noAnim or lib.progressBar({
			duration = item.usetime,
			label = item.label or locale('using', data.metadata.label or data.label),
			useWhileDead = item.useWhileDead,
			canCancel = item.cancel,
			disable = item.disable,
			anim = item.anim or item.scenario,
			prop = item.prop --[[@as ProgressProps]]
		})) and not PlayerData.dead

		if success then
			if item.notification then
				lib.notify({ description = item.notification })
			end

			if item.status then
				if client.setPlayerStatus then
					client.setPlayerStatus(item.status)
				end
			end

			return true
		end
	end
end)

local function canUseItem(isAmmo)
	local ped = cache.ped

	return not usingItem
    and (not isAmmo or currentWeapon)
	and PlayerData.loaded
	and not PlayerData.dead
	and not invBusy
	and not lib.progressActive()
	and not IsPedRagdoll(ped)
	and not IsPedFalling(ped)
end

---@param data table
---@param cb fun(response: SlotWithItem | false)?
---@param noAnim? boolean
local function useItem(data, cb, noAnim)
	local slotData, result = PlayerData.inventory[data.slot]

	if not slotData or not canUseItem(data.ammo and true) then return end

	if currentWeapon?.timer and currentWeapon.timer > 100 then return end

    if invOpen and data.close then client.closeInventory() end

    usingItem = true

    ---@type boolean?
    result = lib.callback.await('ox_inventory:useItem', 200, data.name, data.slot, slotData.metadata, noAnim)

	if result and cb then
		local success, response = pcall(cb, result and slotData)

		if not success and response then
			warn(('^1An error occurred while calling item "%s" callback!\n^1SCRIPT ERROR: %s^0'):format(slotData.name, response))
		end
	end

    if result then
        TriggerEvent('ox_inventory:usedItem', slotData.name, slotData.slot, next(slotData.metadata) and slotData.metadata)
    end

	Wait(500)
    usingItem = false
end

AddEventHandler('ox_inventory:usedItem', function(name, slot, metadata)
    TriggerServerEvent('ox_inventory:usedItemInternal', slot)
end)

AddEventHandler('ox_inventory:item', useItem)
exports('useItem', useItem)

---@param slot number
---@return boolean?
local function useSlot(slot, noAnim)
	local item = PlayerData.inventory[slot]

	if not item then return end

	local data = Items[item.name]
	if not data then return end

	if canUseItem(data.ammo and true) then
		if data.component and not currentWeapon then
			return lib.notify({ id = 'weapon_hand_required', type = 'error', description = locale('weapon_hand_required') })
		end

		local durability = item.metadata.durability --[[@as number?]]
		local consume = data.consume --[[@as number?]]
		local label = item.metadata.label or item.label --[[@as string]]

		-- Naive durability check to get an early exit
		-- People often don't call the 'useItem' export and then complain about "broken" items being usable
		-- This won't work with degradation since we need access to os.time on the server
		if durability and durability <= 100 and consume then
			if durability <= 0 then
				return lib.notify({ type = 'error', description = locale('no_durability', label) })
			elseif consume ~= 0 and consume < 1 and durability < consume * 100 then
				if data.decay then
					TriggerServerEvent("inventory:server:forceRemoveItemWithNoDurability", item.slot, item.name)
				end
				return lib.notify({ type = 'error', description = locale('not_enough_durability', label) })
			end
		end

		data.slot = slot

		if item.metadata.container then
			return client.openInventory('container', item.slot)
		elseif data.client then
			if invOpen and data.close then client.closeInventory() end

			if data.export then
				return data.export(data, {name = item.name, slot = item.slot, metadata = item.metadata})
			elseif data.client.event then -- re-add it, so I don't need to deal with morons taking screenshots of errors when using trigger event
				return TriggerEvent(data.client.event, data, {name = item.name, slot = item.slot, metadata = item.metadata})
			end
		end

		if data.effect then
			data:effect({name = item.name, slot = item.slot, metadata = item.metadata})
		elseif data.weapon then
			if EnableWeaponWheel or not plyState.canUseWeapons then return end

			if IsCinematicCamRendering() then SetCinematicModeActive(false) end

			useItem(data, function(result)
				if result then
					
					if currentWeapon then
						if currentWeapon?.slot == data.slot then
							--[[ Just keep it in the holster if it's not a throwable ]]
							local keepHolstered = data.throwable ~= true

							currentWeapon = Weapon.Disarm(currentWeapon, IS_RDR3, keepHolstered)
							return
						end
					end

					SetCurrentPedWeapon(cache.ped, data.hash, false, 0, false, false)

                    local sleep
					currentWeapon, sleep = Weapon.Equip(item, data, noAnim or IS_RDR3)

					setCurrentWeaponGroup()
					if sleep then Wait(sleep) end
				end
			end, noAnim or IS_RDR3)

		elseif currentWeapon then
			if data.ammo then

				local weaponDurability = currentWeapon.metadata.degradation and currentWeapon.metadata.degradation >= 1.0
	
				if EnableWeaponWheel or weaponDurability then
					return
				end


				local clipSize = GetMaxAmmoInClip(playerPed, currentWeapon.hash, true)
				local currentAmmo = GetPedAmmoByType(playerPed, GetHashKey(data.name))
				SetAmmoTypeForPedWeapon( playerPed, currentWeapon.hash,  GetHashKey(data.name) )
		
				local _, maxAmmo = GetMaxAmmo(playerPed, currentWeapon.hash)

				local isDualWeaponActived = GetAllowDualWield(playerPed) == 1

				local ret, primaryWeapon = GetCurrentPedWeapon(playerPed, 0, 2, 0)
				local ret, secondaryWeapon = GetCurrentPedWeapon(playerPed, 0, 3, 0)
		
				local hasPrimaryWeapon = primaryWeapon ~= `WEAPON_UNARMED`
				local hasSecondaryWeapon = secondaryWeapon ~= `WEAPON_UNARMED`
		
				if hasPrimaryWeapon and hasSecondaryWeapon and not isDualWeaponActived then
					Citizen.InvokeNative(0x83B8D50EB9446BBA, playerPed, true)
					isDualWeaponActived = true
				end

				local isABow = currentWeapon.hash == `WEAPON_BOW` or currentWeapon.hash == `WEAPON_BOW_IMPROVED`

				if maxAmmo < clipSize then clipSize = maxAmmo end

				if maxAmmo > clipSize then
					clipSize = GetMaxAmmoInClip(playerPed, currentWeapon.hash, true)
				end
		
				if isABow then
					--[[ 
						Allow to use up to the maximum amount of ammunition possible when using a bow, instead
						to use only the maximum possible in the clip, which in the arc is 1
					--]]

					--[[
						Rockstar also sets the maximum ammo manually in her scripts ;)
					--]]
					maxAmmo = 8
					clipSize = 8
				end

				-- print(" currentAmmo :: ", currentAmmo, clipSize )

				-- local currentAmmoType = GetPedAmmoTypeFromWeapon( cache.ped, currentWeapon.hash ) 

				-- local newAmmoTypeHash = 

				if currentAmmo >= clipSize then return end

				useItem(data, function(resp)
					local isSameName = resp.name:lower() == currentWeapon?.ammo:lower()

					if currentAmmo >= clipSize and not isDualWeaponActived then return end
					
					if IS_RDR3 and string.find(resp.name:lower(), currentWeapon?.ammo:lower()) then
						isSameName = true
					end

					if not resp or not isSameName then return end
					currentAmmo = GetPedAmmoByType(playerPed, GetHashKey(resp.name:lower()))

					if isDualWeaponActived and not isABow then
						clipSize = clipSize * 2
					end
					local missingAmmo = clipSize - currentAmmo

					local addAmmo = resp.count > missingAmmo and missingAmmo or resp.count
					local newAmmo = currentAmmo + addAmmo

					if newAmmo == currentAmmo then return end

					if cache.vehicle then
						SetAmmoInClip(playerPed, currentWeapon.hash, newAmmo)

						if cache.seat > -1 or IsVehicleStopped(cache.vehicle) then
							TaskReloadWeapon(playerPed, true)
						end
					else
						AddAmmoToPedByType( playerPed, GetHashKey(resp.name), addAmmo )

						if isABow then
							SetCurrentPedWeapon(playerPed, currentWeapon.hash, false, 0, false, false)
						end

						SetAmmoTypeForPedWeapon( playerPed,  currentWeapon.hash,  GetHashKey(resp.name) )
						-- if resp.name ~= currentWeapon?.ammo then
						-- 	if currentWeapon.metadata.specialAmmo ~= resp.name then
						-- 		currentWeapon.metadata.specialAmmo = resp.name
						-- 	end
						-- end

						Wait(100)

						-- local N_0x79e1e511ff7efb13 = IS_GTAV and MakePedReload or N_0x79e1e511ff7efb13
						N_0x79e1e511ff7efb13(playerPed)

						SetTimeout(100, function()
							while IsPedReloading(playerPed) do
								DisableControlAction(0, 22, true)
								Wait(0)
							end
						end)
					end

					local ammoType = data?.name or currentWeapon.currentAmmo

					local reloadRes = lib.callback.await('ox_inventory:updateWeapon', false, 'load', newAmmo, false, ammoType:lower())
				end)
			elseif data.allowArmed then
				useItem(data)
			end
		elseif not data.ammo and not data.component then
			useItem(data)
		end
	end
end
exports('useSlot', useSlot)

---@param id number
---@param slot number
local function useButton(id, slot)
	if PlayerData.loaded and not invBusy and not lib.progressActive() then
		local item = PlayerData.inventory[slot]
		if not item then return end

		local data = Items[item.name]
		local buttons = data?.buttons

		if buttons and buttons[id]?.action then
			buttons[id].action(slot)
		end
	end
end

local function openNearbyInventory() client.openInventory('player') end

exports('openNearbyInventory', openNearbyInventory)

local currentInstance
local playerCoords
local Shops = require 'modules.shops.client'


RegisterNetEvent("business:finishLoad", function()
	Inventory.Stashes()
	Inventory.Evidence()
	Shops.refreshShops()
end)

RegisterNetEvent("business:RemovePlayerClassPermission", function()
	Inventory.Stashes()
	Inventory.Evidence()
	Shops.refreshShops()
end)

RegisterNetEvent("business:AddPlayerClassPermission", function()
	Inventory.Stashes()
	Inventory.Evidence()
	Shops.refreshShops()
end)


---@todo remove or replace when the bridge module gets restructured
function OnPlayerData(key, val)
	if key ~= 'groups' and key ~= 'ped' and key ~= 'dead' then return end

	if key == 'groups' then
		Inventory.Stashes()
		Inventory.Evidence()
		Shops.refreshShops()
	elseif key == 'dead' and val then
		currentWeapon = Weapon.Disarm(currentWeapon)
		client.closeInventory()
	end

	Utils.WeaponWheel()
end

-- People consistently ignore errors when one of the "modules" failed to load
if not Utils or not Weapon or not Items or not Inventory then return end

local invHotkeys = false

---@type function?
local function registerCommands()
	-- RegisterCommand('steal', openNearbyInventory, false)

	local function openGlovebox(vehicle)

		if IS_GTAV then
			if not IsPedInAnyVehicle(playerPed, false) then return end
		end

		if not NetworkGetEntityIsNetworked(vehicle) then return end

		local vehicleHash = GetEntityModel(vehicle)
		local vehicleClass
		local checkVehicle

		local gloveId

		if IS_GTAV then
			checkVehicle = Vehicles.Storage[vehicleHash]
			vehicleClass = GetVehicleClass(vehicle)
			gloveId = ('glove%d' --[[ é junto assim mesmo... não tá errado ]]):format(GetVehicleNumberPlateText(vehicle))
		end

		if IS_RDR3 then
			checkVehicle = Vehicles.glovebox.models[vehicleHash]
			local state = Entity(vehicle).state
			local horseUUID = state['transport:id']
			local ownerServerId = state["transport:ownerPlayerServerId"]

			if not horseUUID then
				--[[ O cavalo não faz parte do nosso sistema. ]]
				return
			end

			local playerServerId = GetPlayerServerId( PlayerId() )

			if tonumber(playerServerId) ~= tonumber(ownerServerId) then
				cAPI.NotifyToast("warning", "Não consigo olhar essa carroça")
				return 
			end

			gloveId = ('glove%d' --[[ é junto assim mesmo... não tá errado ]]):format(horseUUID)
		end

		-- No storage or no glovebox
		if (checkVehicle == 0 or checkVehicle == 2) or (not Vehicles.glovebox[vehicleClass] and not Vehicles.glovebox.models[vehicleHash]) then return end

		local maxWeight = checkVehicle
		local slots = 4

		local isOpen = client.openInventory('glovebox', { id = gloveId, netid = NetworkGetNetworkIdFromEntity(vehicle) })

		if isOpen then
			currentInventory.entity = vehicle
		end
	end

	local function tryOpenSecondaryInventory(self)
		if IS_GTAV then
			if primary:GetCurrentKey() == self:GetCurrentKey() then
				return warn(("secondary inventory keybind '%s' disabled (keybind cannot match primary inventory keybind)"):format(self:GetCurrentKey()))
			end
		end

		if invOpen then
			return client.closeInventory()
		end

		if invBusy or not canOpenInventory() then
			return lib.notify({ id = 'inventory_player_access', type = 'error', description = locale('inventory_player_access') })
		end

		if StashTarget then
			return client.openInventory('stash', StashTarget)
		end

		if currentInteractedEntityId and IsThisModelAHorse( GetEntityModel( currentInteractedEntityId ) ) == 1 then
			return openGlovebox( cache.vehicle or currentInteractedEntityId )
		end

		if cache.vehicle then
			return openGlovebox( cache.vehicle or currentInteractedEntityId )
		end

		local entity, entityType = Utils.Raycast(2|16)

		if not entity then return end

		if not shared.target and entityType == 3 then
			local model = GetEntityModel(entity)

			if Inventory.Dumpsters[model] then
				return Inventory.OpenDumpster(entity)
			end
		end

		if entityType ~= 2 then return end

		Inventory.OpenTrunk(entity, Business.hasClassePermission("police"))
	end

	
	local function tryOpenInventory()
		if invOpen then
			return client.closeInventory()
		end

		tryOpenSecondaryInventory()

		local closest = lib.points.getClosestPoint()

		if closest and closest.currentDistance < 1.2 and (not closest.instance or closest.instance == currentInstance) then
			if closest.inv == 'crafting' then
				return client.openInventory('crafting', { id = closest.id, index = closest.index })
			elseif closest.inv ~= 'license' and closest.inv ~= 'policeevidence' then
				return client.openInventory(closest.inv or 'drop', { id = closest.invId, type = closest.type })
			end
		end

		return client.openInventory()
	end

	RegisterCommand("openinv", function()
		tryOpenInventory()
	end)

	local function playerReload()
		if not currentWeapon or not canUseItem(true) then return end

		if currentWeapon?.currentAmmo or currentWeapon.ammo then
			local weaponDurability 

			if IS_GTAV then
				weaponDurability = currentWeapon?.metadata?.durability > 0
			end

			if IS_RDR3 then
				weaponDurability = (currentWeapon?.metadata?.degradation or currentWeapon?.metadata?.durability) < 1
			end

			if weaponDurability then
				local slotId = Inventory.GetSlotIdWithItem(currentWeapon?.currentAmmo or currentWeapon.ammo, { }, false)
				if slotId then
					useSlot(slotId)
				end
			else
				lib.notify({ id = 'no_durability', type = 'error', description = locale('no_durability', currentWeapon.label) })
			end
		end
	end

	local primary = lib.addKeybind({
		name = 'inv',
		description = locale('open_player_inventory'),
		defaultKey = client.keys[1],
		onPressed = function()
			tryOpenInventory()
		end
	})

	lib.addKeybind({
		name = 'inv2',
		description = locale('open_secondary_inventory'),
		defaultKey = client.keys[2],
		onPressed = function(self)
            tryOpenSecondaryInventory(self)
		end
	})

	lib.addKeybind({
		name = 'reloadweapon',
		description = locale('reload_weapon'),
		defaultKey = 'r',
		onPressed = function(self)
			playerReload()
		end
	})

	lib.addKeybind({
		name = 'hotbar',
		description = locale('disable_hotbar'),
		defaultKey = client.keys[3],
		onPressed = function()
			if EnableWeaponWheel or IsNuiFocused() or lib.progressActive() then return end
			SendNUIMessage({ action = 'toggleHotbar' })
		end
	})

	for i = 1, 5 do
		lib.addKeybind({
			name = ('hotkey%s'):format(i),
			description = locale('use_hotbar', i),
			defaultKey = tostring(i),
			onPressed = function()
				if invOpen or IsNuiFocused() or not invHotkeys then return end
				useSlot(i)
			end
		})
	end


	if IS_RDR3 then
		local function useHotKeyByControl(key)
			if not IsEntityDead(PlayerPedId()) and not IsPauseMenuActive() then
				if not invOpen then
					CreateThread(function()
						--[[ useSlot is thread-blocking af. ]]
						useSlot(key)
					end)
				end		
			end
		end	

		Citizen.CreateThread(function()

			local HOTKEY_CONTROL_MAPPING =
			{
				{
					1, --[[ Hotkey ]]
					{
						`INPUT_SELECT_QUICKSELECT_SIDEARMS_LEFT`, --[[ Botão padrão ]]
						-- `INPUT_EMOTE_DANCE`, --[[ Botão usado para quando o menu de ação está aberto ]]
					},
				},
				{
					2,
					{
						`INPUT_SELECT_QUICKSELECT_DUALWIELD`,
						-- `INPUT_EMOTE_GREET`,
					},
				},
				{
					3,
					{
						`INPUT_SELECT_QUICKSELECT_SIDEARMS_RIGHT`,
						-- `INPUT_EMOTE_COMM`,
					},
				},
				{
					4,
					{
						`INPUT_SELECT_QUICKSELECT_UNARMED`,
						-- `INPUT_EMOTE_TAUNT`,
					},
				},
				{
					5,
					{
						`INPUT_SELECT_QUICKSELECT_MELEE_NO_UNARMED`,
					},
				},
			}

			while true do
				Citizen.Wait(0)
		
				if PlayerData then

					for _, mapping in ipairs(HOTKEY_CONTROL_MAPPING) do
						local controlHashes = mapping[2]

						for _, controlHash in ipairs(controlHashes) do						
							DisableControlAction(0, controlHash, true)
							if IsDisabledControlJustPressed(0, controlHash) and not IsDisabledControlPressed(0, `INPUT_SELECT_RADAR_MODE`) then
								local hotkey = mapping[1]

								useHotKeyByControl(hotkey)

								goto skip_hotkey_processing
							end
						end
					end

					:: skip_hotkey_processing ::

					DisableControlAction(0, `INPUT_OPEN_WHEEL_MENU`)
					if IsDisabledControlJustPressed(0, `INPUT_OPEN_WHEEL_MENU`) then -- tab
						if not client.weaponWheel and not IsPauseMenuActive() then
							SendNUIMessage({ action = 'toggleHotbar' })
						end
					end

					if IsControlJustReleased(0, `INPUT_QUICK_USE_ITEM`) then -- open inventory I
						tryOpenInventory()
					end

					if IsControlJustReleased(0,  `INPUT_RELOAD`) then -- reload R
						playerReload()
					end

					if IsControlJustReleased(0,  `INPUT_AIM_IN_AIR`) then -- open inventory U
						tryOpenSecondaryInventory()
					end
					
					if IsDisabledControlPressed(0, `INPUT_OPEN_WHEEL_MENU`) then
						if IsControlJustReleased(0, `INPUT_PREV_WEAPON`) then -- LEFT ARROW
							setCurrentAmmo( false )
						end
						if IsControlJustReleased(0,`INPUT_NEXT_WEAPON`) then --RIGHT ARROW
							setCurrentAmmo( true )
						end
					end
				end
			end
		end)
	end

	registerCommands = nil
end

function client.closeInventory(server)
	-- because somehow people are triggering this when the inventory isn't loaded
	-- and they're incapable of debugging, and I can't repro on a fresh install
	if not client.interval then return end

	if invOpen then
		invOpen = nil
		SetNuiFocus(false, false)
		SetNuiFocusKeepInput(false)
		if IS_GTAV then
			TriggerScreenblurFadeOut(0)
		end
		closeTrunk()
		SendNUIMessage({ action = 'closeInventory' })
		SetInterval(client.interval, 200)
		Wait(200)

		TriggerEvent('kd_stable:client:closeSaddleBag')

		if invOpen ~= nil then return end

		if not server and currentInventory then
			TriggerServerEvent('ox_inventory:closeInventory')
		end

		currentInventory = nil
		plyState.invOpen = false
		defaultInventory.coords = nil
		TriggerEvent("ox_inventory:closed")
		
		--[[ Resetar, o inventário foi fechado pelo próprio script. ]]
		gCanPlayerCloseInventory = true
	end
end

RegisterNetEvent('ox_inventory:closeInventory', client.closeInventory)
exports('closeInventory', client.closeInventory)

---@param data updateSlot[]
---@param weight number
local function updateInventory(data, weight)
	local changes = {}
    ---@type table<string, number>
	local itemCount = {}

	for i = 1, #data do
		local v = data[i]

		if not v.inventory or v.inventory == cache.serverId then
			v.inventory = 'player'
			local item = v.item

			if currentWeapon?.slot == item?.slot then
                if item?.metadata then
				    currentWeapon.metadata = item.metadata
				    TriggerEvent('ox_inventory:currentWeapon', currentWeapon)
                else
                    currentWeapon = Weapon.Disarm(currentWeapon, true)
                end
			end

			local curItem = PlayerData.inventory[item.slot]

			if curItem and curItem.name then
				itemCount[curItem.name] = (itemCount[curItem.name] or 0) - curItem.count
			end

			if item.count then
				itemCount[item.name] = (itemCount[item.name] or 0) + item.count
			end

			if item?.metadata then
				if item.metadata?.ammo ~= nil then
					local weaponHash = GetHashKey( item.name )
					local clipSize = GetMaxAmmoInClip(cache.ped, weaponHash, true)

					item.metadata.ammoMaxClip = clipSize
				end
			end

			changes[item.slot] = item.count and item or false
			if not item.count then item.name = nil end
			PlayerData.inventory[item.slot] = item.name and item or nil
		end
	end

	SendNUIMessage({ action = 'refreshSlots', data = { items = data, itemCount = itemCount} })

    if weight ~= PlayerData.weight then client.setPlayerData('weight', weight) end

	for itemName, count in pairs(itemCount) do
		local item = Items(itemName)

        if item then
            item.count += count

            TriggerEvent('ox_inventory:itemCount', item.name, item.count)

            if count < 0 then
                if shared.framework == 'esx' then
                    TriggerEvent('esx:removeInventoryItem', item.name, item.count)
                end

                if item.client?.remove then
                    item.client.remove(item.count)
                end
            elseif count > 0 then
                if shared.framework == 'esx' then
                    TriggerEvent('esx:addInventoryItem', item.name, item.count)
                end

                if item.client?.add then
                    item.client.add(item.count)
                end
            end
        end
	end

	client.setPlayerData('inventory', PlayerData.inventory)
	TriggerEvent('ox_inventory:updateInventory', changes)
end

RegisterNetEvent('ox_inventory:updateSlots', function(items, weights)
	if source ~= '' and next(items) then updateInventory(items, weights) end
end)

RegisterNetEvent('ox_inventory:inventoryReturned', function(data)
	if source == '' then return end
	if currentWeapon then currentWeapon = Weapon.Disarm(currentWeapon) end

	lib.notify({ description = locale('items_returned') })
	client.closeInventory()

	local num, items = 0, {}

	for _, slotData in pairs(data[1]) do
		num += 1
		items[num] = { item = slotData, inventory = cache.serverId }
	end

	updateInventory(items, data[3])
end)

RegisterNetEvent('ox_inventory:inventoryConfiscated', function(message)
	if source == '' then return end
	if message then lib.notify({ description = locale('items_confiscated') }) end
	if currentWeapon then currentWeapon = Weapon.Disarm(currentWeapon) end

	client.closeInventory()

	local num, items = 0, {}

	for slot in pairs(PlayerData.inventory) do
		num += 1
		items[num] = { item = { slot = slot }, inventory = cache.serverId }
	end

	updateInventory(items, 0)
end)


---@param point CPoint
local function nearbyDrop(point)
	if not point.instance or point.instance == currentInstance then
		---@diagnostic disable-next-line: param-type-mismatch
		
		if IS_GTAV then
			DrawMarker(2, point.coords.x, point.coords.y, point.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 150, 30, 30, 222, false, false, 0, true, false, false, false)
		end

		if IS_RDR3 then
			Citizen.InvokeNative(0x2A32FAA57B937173, 0x07DCE236, point.coords.x, point.coords.y, point.coords.z - 0.85, 0,0,0,0,0,0,0.15, 0.15,1.0, 30, 150, 30, 222, 0, 0, 2, 0, 0, 0, 0)
		end
	
	
	end
end

---@param point CPoint
local function onEnterDrop(point)
	if not point.instance or point.instance == currentInstance and not point.entity then
		local model = point.model or client.dropmodel

		lib.requestModel(model)

		local entity = CreateObject(model, point.coords.x, point.coords.y, point.coords.z, false, true, true)

		SetModelAsNoLongerNeeded(model)
		PlaceObjectOnGroundProperly(entity)
		FreezeEntityPosition(entity, true)
		SetEntityCollision(entity, false, true)

		point.entity = entity
	end
end

local function onExitDrop(point)
	local entity = point.entity

	if entity then
		Utils.DeleteEntity(entity)
		point.entity = nil
	end
end

local function createDrop(dropId, data)
	local point = lib.points.new({
		coords = data.coords,
		distance = 16,
		invId = dropId,
		instance = data.instance,
		model = data.model
	})

	if point.model or client.dropprops then
		point.distance = 30
		point.onEnter = onEnterDrop
		point.onExit = onExitDrop
	else
		point.nearby = nearbyDrop
	end

	client.drops[dropId] = point
end

RegisterNetEvent('ox_inventory:createDrop', function(dropId, data, owner, slot)
	if client.drops then
		createDrop(dropId, data)
	end

	if owner == cache.serverId then
		if currentWeapon?.slot == slot then
			currentWeapon = Weapon.Disarm(currentWeapon)
		end

		if invOpen and #(GetEntityCoords(playerPed) - data.coords) <= 1 then
			if not cache.vehicle then
				client.openInventory('drop', dropId)
			else
				SendNUIMessage({
					action = 'setupInventory',
					data = { rightInventory = currentInventory }
				})
			end
		end
	end
end)

RegisterNetEvent('ox_inventory:removeDrop', function(dropId)
	if client.drops then
		local point = client.drops[dropId]

		if point then
			client.drops[dropId] = nil
			point:remove()

			if point.entity then Utils.DeleteEntity(point.entity) end
		end
	end
end)

---@type function?
local function setStateBagHandler(stateId)
	AddStateBagChangeHandler('invOpen', stateId, function(_, _, value)
		invOpen = value
	end)

	AddStateBagChangeHandler('invBusy', stateId, function(_, _, value)
		invBusy = value
	end)

    AddStateBagChangeHandler('canUseWeapons', stateId, function(_, _, value)
        if not value and currentWeapon then
            currentWeapon = Weapon.Disarm(currentWeapon)
        end
    end)

	AddStateBagChangeHandler('instance', stateId, function(_, _, value)
		currentInstance = value

		-- Iterate over known drops and remove any points in a different instance (ignoring no instance)
		for dropId, point in pairs(client.drops) do
			if point.instance then
				if point.instance ~= value then
					if point.entity then
						Utils.DeleteEntity(point.entity)
						point.entity = nil
					end

					point:remove()
				else
					-- Recreate the drop using data from the old point
					createDrop(dropId, point)
				end
			end
		end
	end)

	AddStateBagChangeHandler('dead', stateId, function(_, _, value)
		Utils.WeaponWheel()
		PlayerData.dead = value
	end)

	AddStateBagChangeHandler('invHotkeys', stateId, function(_, _, value)
		invHotkeys = value
	end)

	setStateBagHandler = nil
end

lib.onCache('seat', function(seat)
	if seat then
		local hasWeapon = GetCurrentPedVehicleWeapon(cache.ped)

		if hasWeapon then
			return Utils.WeaponWheel(true)
		end
	end

	Utils.WeaponWheel(false)
end)

lib.onCache('vehicle', function()
	if invOpen and (not currentInventory.entity or currentInventory.entity == cache.vehicle) then
		return client.closeInventory()
	end
end)

RegisterNetEvent('ox_inventory:setPlayerInventory', function(currentDrops, inventory, weight, player)
	if source == '' then return end

    ---@class PlayerData
    ---@field inventory table<number, SlotWithItem?>
    ---@field weight number
	PlayerData = player
	PlayerData.id = cache.playerId
	PlayerData.source = cache.serverId
    PlayerData.maxWeight = shared.playerweight

	setmetatable(PlayerData, {
		__index = function(self, key)
			if key == 'ped' then
				return PlayerPedId()
			end
		end
	})

	if setStateBagHandler then setStateBagHandler(('player:%s'):format(cache.serverId)) end

	local ItemData = table.create(0, #Items)

	for _, v in pairs(Items --[[@as table<string, OxClientItem>]]) do
		local buttons = v.buttons and {} or nil

		if buttons then
			for i = 1, #v.buttons do
				buttons[i] = {label = v.buttons[i].label, group = v.buttons[i].group}
			end
		end

		ItemData[v.name] = {
			label = v.label,
			stack = v.stack,
			close = v.close,
			count = 0,
			description = v.description,
			buttons = buttons,
			ammoName = v.ammoname,
			image = v.client?.image
		}
	end

	for _, data in pairs(inventory) do
		local item = Items[data.name]

		if item then
			item.count += data.count
			ItemData[data.name].count += data.count
			local add = item.client?.add

			if add then
				add(item.count)
			end
		end
	end

	local phone = Items.phone

	if phone and phone.count < 1 then
		pcall(function()
			return exports.npwd:setPhoneDisabled(true)
		end)
	end

	client.setPlayerData('inventory', inventory)
	client.setPlayerData('weight', weight)
	currentWeapon = nil
	Weapon.ClearAll()

	local uiLocales = {}
	local locales = lib.getLocales()

	for k, v in pairs(locales) do
		if k:find('^ui_')then
			uiLocales[k] = v
		end
	end

	uiLocales['$'] = locales['$']
	uiLocales.ammo_type = locales.ammo_type

	client.drops = currentDrops

	for dropId, data in pairs(currentDrops) do
		createDrop(dropId, data)
	end

	local hasTextUi = false
	local uiOptions = { icon = 'fa-id-card' }

	---@param point CPoint
	local function nearbyLicense(point)
		---@diagnostic disable-next-line: param-type-mismatch
		DrawMarker(2, point.coords.x, point.coords.y, point.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 30, 150, 30, 222, false, false, 0, true, false, false, false)

		if point.isClosest and point.currentDistance < 1.2 then
			if not hasTextUi then
				hasTextUi = true
				lib.showTextUI(point.message, uiOptions)
			end

			if IsControlJustReleased(0, 38) then
				lib.callback('ox_inventory:buyLicense', 1000, function(success, message)
					if success ~= nil then
						lib.notify({
							id = message,
							type = success == false and 'error' or 'success',
							description = locale(message, locale('license', point.type:gsub("^%l", string.upper)))
						})
					end
				end, point.invId)
			end
		elseif hasTextUi then
			hasTextUi = false
			lib.hideTextUI()
		end
	end

	if IS_GTAV then
		for id, data in pairs(lib.load('data.licenses')) do
			lib.points.new({
				coords = data.coords,
				distance = 16,
				inv = 'license',
				type = data.name,
				price = data.price,
				invId = id,
				nearby = nearbyLicense,
				message = ('**%s**  \n%s'):format(locale('purchase_license', data.name), locale('interact_prompt', GetControlInstructionalButton(0, 38, true):sub(3)))
			})
		end
	end

	while not client.uiLoaded do Wait(50) end

	SendNUIMessage({
		action = 'init',
		data = {
			locale = uiLocales,
			items = ItemData,
			leftInventory = {
				id = cache.playerId,
				slots = shared.playerslots,
				items = PlayerData.inventory,
				maxWeight = shared.playerweight,
			},
			imagepath = client.imagepath
		}
	})

	PlayerData.loaded = true

	lib.notify({ description = locale('inventory_setup') })
	Shops.refreshShops()
	Inventory.Stashes()
	Inventory.Evidence()

	if registerCommands then registerCommands() end

	TriggerEvent('ox_inventory:updateInventory', PlayerData.inventory)

	client.interval = SetInterval(function()
		if invOpen == false then
			playerCoords = GetEntityCoords(playerPed)

			if currentWeapon and IsPedUsingActionMode(playerPed) then
				SetPedUsingActionMode(playerPed, false, -1, 'DEFAULT_ACTION')
			end

		elseif invOpen == true then
			if not canOpenInventory() then
				client.closeInventory()
			else
				playerCoords = GetEntityCoords(playerPed)

				if currentInventory and not currentInventory.ignoreSecurityChecks then
					if currentInventory.type == 'otherplayer' then
						local id = GetPlayerFromServerId(currentInventory.id)
						local ped = GetPlayerPed(id)
						local pedCoords = GetEntityCoords(ped)

						if not id or #(playerCoords - pedCoords) > 1.8 or not (client.hasGroup(shared.police) or canOpenTarget(ped)) then
							client.closeInventory()
							lib.notify({ id = 'inventory_lost_access', type = 'error', description = locale('inventory_lost_access') })
						else
							TaskTurnPedToFaceCoord(playerPed, pedCoords.x, pedCoords.y, pedCoords.z, 50)
						end

					elseif currentInventory.coords and (#(playerCoords - currentInventory.coords) > (currentInventory.distance or 2.0) or canOpenTarget(playerPed)) then
						client.closeInventory()
						lib.notify({ id = 'inventory_lost_access', type = 'error', description = locale('inventory_lost_access') })
					end
				end
			end
		end

		if client.parachute and GetPedParachuteState(playerPed) ~= -1 then
			Utils.DeleteEntity(client.parachute)
			client.parachute = false
		end

		if EnableWeaponWheel then return end

		local weaponHash = GetSelectedPedWeapon(playerPed)
	
		if currentWeapon then
			if weaponHash ~= currentWeapon.hash and currentWeapon.timer then
				local weaponCount = Items[currentWeapon.name]?.count

				if IS_RDR3 then
					if weaponHash == `WEAPON_UNARMED` then
						goto continue
					end
				end

				if weaponCount > 0 then
					SetCurrentPedWeapon(playerPed, currentWeapon.hash, true)
					local ammoType = currentWeapon?.currentAmmo or currentWeapon.ammo
					if ammoType then
						local currentAmmo = currentWeapon.metadata?.customAmmo[ammoType:lower()] or 0

						SetAmmoInClip(playerPed, currentWeapon.hash, currentAmmo)
						SetPedCurrentWeaponVisible(playerPed, true, false, false, false)

						weaponHash = GetSelectedPedWeapon(playerPed)
					end
				end

				if weaponHash ~= currentWeapon.hash then
					currentWeapon = Weapon.Disarm(currentWeapon, true)
				end

				::continue::
			end
		elseif client.weaponmismatch and not client.ignoreweapons[weaponHash] then
			local weaponType = GetWeapontypeGroup(weaponHash)

			if weaponType ~= 0 and weaponType ~= `GROUP_UNARMED` then
				Weapon.Disarm(currentWeapon, true)
			end
		end
	end, 200)

	local playerId = cache.playerId
	local EnableKeys = client.enablekeys
	local DisablePlayerVehicleRewards = DisablePlayerVehicleRewards
	local DisableAllControlActions = DisableAllControlActions
	local HideHudAndRadarThisFrame = HideHudAndRadarThisFrame
	local EnableControlAction = EnableControlAction
	local DisablePlayerFiring = DisablePlayerFiring
	local HudWeaponWheelIgnoreSelection = HudWeaponWheelIgnoreSelection
	local DisableControlAction = DisableControlAction
	local IsPedShooting = IsPedShooting
	local IsControlJustReleased = IsControlJustReleased

	client.tick = SetInterval(function()
		if IS_GTAV then
			DisablePlayerVehicleRewards(playerId)
		end

		if invOpen then
			DisableAllControlActions(0)
			-- HideHudAndRadarThisFrame()

			for i = 1, #EnableKeys do
				EnableControlAction(0, EnableKeys[i], true)
			end

			if currentInventory.type == 'newdrop' then
				EnableControlAction(0, 30, true)
				EnableControlAction(0, 31, true)
			end
		else
			if invBusy then
				DisableControlAction(0, 23, true)
				DisableControlAction(0, 36, true)
			end

			if usingItem or invBusy == true or IsPedCuffed(playerPed) then
				DisablePlayerFiring(playerId, true)
			end

			if IS_GTAV then
				if not EnableWeaponWheel then
					HudWeaponWheelIgnoreSelection()
					DisableControlAction(0, 37, true)
				end
			end

			if currentWeapon and currentWeapon.timer then
				DisableControlAction(0, 80, true)
				DisableControlAction(0, 140, true)

				---- USING DEGRATATION TO RDR3 WEAPONS
				if IS_GTAV then
					if currentWeapon?.metadata?.durability <= 0 then
						DisablePlayerFiring(playerId, true)
					elseif client.aimedfiring and not currentWeapon.melee and currentWeapon.group ~= `GROUP_PETROLCAN` and not IsPlayerFreeAiming(playerId) then
						DisablePlayerFiring(playerId, true)
					end
				end

				local currentAmmoType = currentWeapon?.currentAmmo or currentWeapon?.ammo
				
				-- print(" currentAmmoType", currentAmmoType)

				local weaponAmmo = 0

				if currentAmmoType and currentWeapon.metadata?.customAmmo then
					currentAmmoType = currentAmmoType:lower()
					weaponAmmo = currentWeapon.metadata?.customAmmo[currentAmmoType] or 0
				end

				if not invBusy and currentWeapon.timer ~= 0 and currentWeapon.timer < GetGameTimer() then
					currentWeapon.timer = 0

					if weaponAmmo then
						TriggerServerEvent('ox_inventory:updateWeapon', 'ammo', weaponAmmo, nil, currentAmmoType or currentWeapon?.ammoname)

						if client.autoreload and currentWeapon.ammo and GetAmmoInPedWeapon(playerPed, currentWeapon.hash) == 0 then
							local slotId = Inventory.GetSlotIdWithItem(currentAmmoType, { }, false)

							if slotId then
								CreateThread(function() useSlot(slotId) end)
							end
						end

					elseif currentWeapon.metadata.durability then
						TriggerServerEvent('ox_inventory:updateWeapon', 'melee', currentWeapon.melee)
						currentWeapon.melee = 0
					end
				elseif weaponAmmo or currentWeapon.throwable then
					-- print(" is throw")
					if IsPedShooting(playerPed) then
						if currentWeapon.throwable then
							RemoveWeaponFromPed(playerPed, currentWeapon.hash)

							TriggerServerEvent('ox_inventory:updateWeapon', 'throw')
							currentWeapon = nil
							TriggerEvent('ox_inventory:currentWeapon')
						else
							local currentAmmo
							local durabilityDrain = Items[currentWeapon.name].durability

							if currentWeapon.group == `GROUP_PETROLCAN` or currentWeapon.group == `GROUP_FIREEXTINGUISHER` then
								currentAmmo = weaponAmmo - durabilityDrain < 0 and 0 or weaponAmmo - durabilityDrain
								currentWeapon.metadata.durability = currentAmmo

								currentWeapon.metadata.customAmmo[currentAmmoType] = (weaponAmmo < currentAmmo) and 0 or currentAmmo
								-- currentWeapon.metadata.ammo = (weaponAmmo < currentAmmo) and 0 or currentAmmo

								if currentAmmo <= 0 then
									SetPedInfiniteAmmo(playerPed, false, currentWeapon.hash)
								end
							else
								currentAmmo = GetAmmoInPedWeapon(playerPed, currentWeapon.hash)

								if currentAmmo < weaponAmmo then
									currentAmmo = (weaponAmmo < currentAmmo) and 0 or currentAmmo
									currentWeapon.metadata.customAmmo[currentAmmoType] = currentAmmo
									currentWeapon.metadata.durability = (currentWeapon.metadata.durability or 100) - (durabilityDrain * math.abs((weaponAmmo or 0.1) - currentAmmo))
								end
							end

							if currentAmmo <= 0 then
								if cache.vehicle then
									TaskSwapWeapon(playerPed, true)
								end

								currentWeapon.timer = GetGameTimer() + 200
							else currentWeapon.timer = GetGameTimer() + 400 end
						end
					end
				elseif currentWeapon.throwable then
					if not invBusy and IsControlPressed(0, 24) then
						invBusy = 1

						CreateThread(function()
							local weapon = currentWeapon

							while currentWeapon and (not IsPedWeaponReadyToShoot(cache.ped) or IsDisabledControlPressed(0, 24)) and GetSelectedPedWeapon(playerPed) == weapon.hash do
								Wait(0)
							end

							if IS_GTAV then

								if GetSelectedPedWeapon(playerPed) == weapon.hash then Wait(700) end

								while IsPedPlantingBomb(playerPed) do Wait(0) end

							end

							TriggerServerEvent('ox_inventory:updateWeapon', 'throw', nil, weapon.slot)

							plyState.invBusy = false
							currentWeapon = nil

							RemoveWeaponFromPed(playerPed, weapon.hash)
							TriggerEvent('ox_inventory:currentWeapon')
						end)
					end
				elseif currentWeapon.melee and IsControlJustReleased(0, 24) and IsPedPerformingMeleeAction(playerPed) then
					currentWeapon.melee += 1
					currentWeapon.timer = GetGameTimer() + 200
				end
			end
		end
	end)

	plyState:set('invBusy', false, false)
	plyState:set('invOpen', false, false)
	plyState:set('invHotkeys', true, false)
	plyState:set('canUseWeapons', true, false)
	collectgarbage('collect')
end)

AddEventHandler('onResourceStop', function(resourceName)
	if shared.resource == resourceName then
		client.onLogout()
	end
end)

RegisterNetEvent('ox_inventory:viewInventory', function(left, right)
	if source == '' then return end

	plyState.invOpen = true

	SetInterval(client.interval, 100)
	SetNuiFocus(true, true)
	SetNuiFocusKeepInput(true)
	closeTrunk()

	-- if client.screenblur then TriggerScreenblurFadeIn(0) end

	currentInventory = right or defaultInventory
	currentInventory.ignoreSecurityChecks = true
    currentInventory.type = 'inspect'
	left.items = PlayerData.inventory
	left.groups = PlayerData.groups

	SendNUIMessage({
		action = 'setupInventory',
		data = {
			leftInventory = left,
			rightInventory = currentInventory
		}
	})
end)

RegisterNUICallback('uiLoaded', function(_, cb)
	client.uiLoaded = true
	cb(1)
end)

RegisterNUICallback('getItemData', function(itemName, cb)
	cb(Items[itemName])
end)

RegisterNUICallback('removeComponent', function(data, cb)
	cb(1)

	if not currentWeapon then
		return TriggerServerEvent('ox_inventory:updateWeapon', 'component', data)
	end

	if data.slot ~= currentWeapon.slot then
		return lib.notify({ id = 'weapon_hand_wrong', type = 'error', description = locale('weapon_hand_wrong') })
	end

	local itemSlot = PlayerData.inventory[currentWeapon.slot]

    if not itemSlot then return end

	if IS_GTAV then

		for _, component in pairs(Items[data.component].client.component) do
			if HasPedGotWeaponComponent(playerPed, currentWeapon.hash, component) then
				for k, v in pairs(itemSlot.metadata.components) do
					if v == data.component then
						local success = lib.callback.await('ox_inventory:updateWeapon', false, 'component', k)

						if success then
							RemoveWeaponComponentFromPed(playerPed, currentWeapon.hash, component)
							TriggerEvent('ox_inventory:updateWeaponComponent', 'removed', component, data.component)
						end

						break
					end
				end
			end
		end
	end
end)

RegisterNUICallback('removeAmmo', function(slot, cb)
	cb(1)
	local slotData = PlayerData.inventory[slot]

	-- local currentAmmoType = currentWeapon?.currentAmmo or currentWeapon.ammo

	-- if not slotData or not slotData.metadata.customAmmo[currentAmmoType:lower()] or slotData.metadata.customAmmo[currentAmmoType:lower()] == 0 then return end

	if not currentWeapon then return 
		lib.notify({ type = 'error', description = "A arma precisa estar equipada em sua mão" }) 
	end

	local success = lib.callback.await('ox_inventory:removeAmmoFromWeapon', false, slot)

	if success then
		for ammoType, _ in pairs ( slotData.metadata.customAmmo ) do 
			local ammoTypehash = GetHashKey( ammoType )
			RemoveAmmoFromPedByType( PlayerPedId(), ammoTypehash, 1000, `REMOVE_REASON_USED`)
		end
	end
end)

RegisterNUICallback('useItem', function(slot, cb)
	useSlot(slot --[[@as number]])
	cb(1)
end)

local function giveItemToTarget(serverId, slotId, count)
    if type(slotId) ~= 'number' then return TypeError('slotId', 'number', type(slotId)) end
    if count and type(count) ~= 'number' then return TypeError('count', 'number', type(count)) end

    if slotId == currentWeapon?.slot then
        currentWeapon = Weapon.Disarm(currentWeapon)
    end

	if IS_GTAV then
    	Utils.PlayAnim(0, 'mp_common', 'givetake1_a', 1.0, 1.0, 2000, 50, 0.0, 0, 0, 0)
	end
    TriggerServerEvent('ox_inventory:giveItem', slotId, serverId, count or 0)
end

exports('giveItemToTarget', giveItemToTarget)

local function isGiveTargetValid(ped, coords)
    if cache.vehicle and GetVehiclePedIsIn(ped, false) == cache.vehicle then
        return true
    end

    local entity = Utils.Raycast(1|2|4|8|16, coords + vec3(0, 0, 0.5), 0.2)

    return entity == ped and IsEntityVisible(ped)
end

RegisterNUICallback('giveItem', function(data, cb)
	cb(1)

	if client.giveplayerlist then
		local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(playerPed), 3.0)
        local nearbyCount = #nearbyPlayers

		if nearbyCount == 0 then return end

        if nearbyCount == 1 then
			local option = nearbyPlayers[1]

            if not isGiveTargetValid(option.ped, option.coords) then return end

            return giveItemToTarget(GetPlayerServerId(option.id), data.slot, data.count)
        end

        local giveList, n = {}, 0

		for i = 1, #nearbyPlayers do
			local option = nearbyPlayers[i]

            if isGiveTargetValid(option.ped, option.coords) then
				local userId = API.GetUserIdFromServerId( GetPlayerServerId(option.id) )
				local playerName = ("ID - %s"):format( userId )
				option.id = GetPlayerServerId(option.id)
                ---@diagnostic disable-next-line: inject-field
				option.label = playerName
				n += 1
				giveList[n] = option
			end
		end

        if n == 0 then return end

		lib.registerMenu({
			id = 'ox_inventory:givePlayerList',
			title = 'Give item',
			options = giveList,
		}, function(selected)
            giveItemToTarget(giveList[selected].id, data.slot, data.count)
        end)

		return lib.showMenu('ox_inventory:givePlayerList')
	end

    if cache.vehicle then
		local seats = GetVehicleMaxNumberOfPassengers(cache.vehicle) - 1

		if seats >= 0 then
			local passenger = GetPedInVehicleSeat(cache.vehicle, cache.seat - 2 * (cache.seat % 2) + 1)

			if passenger ~= 0 and IsEntityVisible(passenger) then
                return giveItemToTarget(GetPlayerServerId(NetworkGetPlayerIndexFromPed(passenger)), data.slot, data.count)
			end
		end

        return
	end

    local entity = Utils.Raycast(1|2|4|8|16, GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 3.0, 0.5), 0.2)

    if entity and IsPedAPlayer(entity) and IsEntityVisible(entity) and #(GetEntityCoords(playerPed, true) - GetEntityCoords(entity, true)) < 3.0 then
        return giveItemToTarget(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), data.slot, data.count)
    end
end)

RegisterNUICallback('useButton', function(data, cb)
	useButton(data.id, data.slot)
	cb(1)
end)

RegisterNUICallback('exit', function(_, cb)
	
	if not gCanPlayerCloseInventory then
		cb(0)
		return
	end

	client.closeInventory()
	cb(1)
end)

lib.callback.register('ox_inventory:startCrafting', function(id, recipe)
	recipe = CraftingBenches[id].items[recipe]

	return lib.progressCircle({
		label = locale('crafting_item', recipe.metadata?.label or Items[recipe.name].label),
		duration = recipe.duration or 3000,
		canCancel = true,
		disable = {
			move = true,
			combat = true,
		},
		anim = {
			dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
			clip = 'machinic_loop_mechandplayer',
		}
	})
end)

local swapActive = false

local function swapWeaponHotbar(item, data)
	if IS_RDR3 then
		if string.find(string.lower(item.name), "weapon") then
			if data.fromType == "player" then
				if data.fromSlot > 0 and data.fromSlot < 6 then
					local playerPed = PlayerPedId()
					local weaponHash = GetHashKey(item.name)
					local ammoHash = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)
					local weaponAmmo = GetAmmoInPedWeapon(playerPed, item.hash)

					Citizen.InvokeNative(0xB6CFEC32E3742779, playerPed, ammoHash, weaponAmmo, GetHashKey('REMOVE_REASON_DROPPED'))  --_REMOVE_AMMO_FROM_PED_BY_TYPE
					RemoveWeaponFromPed(playerPed, weaponHash)
				end
			end
		end
	end
end

---Synchronise and validate all item movement between the NUI and server.
RegisterNUICallback('swapItems', function(data, cb)
    if swapActive or not invOpen or invBusy or usingItem then return cb(false) end

    swapActive = true

	if data.toType == 'newdrop' then
		if cache.vehicle or IsPedFalling(playerPed) then
			swapActive = false
			return cb(false)
		end

		local coords = GetEntityCoords(playerPed)

		if IsEntityInWater(playerPed) then
			local destination = vec3(coords.x, coords.y, -200)
			local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z, 511, cache.ped, 4)

			while true do
				Wait(0)
				local retval, hit, endCoords = GetShapeTestResult(handle)

				if retval ~= 1 then
					if not hit then return end

					data.coords = vec3(endCoords.x, endCoords.y, endCoords.z + 1.0)

					break
				end
			end
		else
			data.coords = coords
		end

		if shared.persistent_items then
			data.coords = cAPI.GetFromCoordsFromPlayer(coords)
		end
    end

	if currentInstance then
		data.instance = currentInstance
	end

	if currentWeapon and data.fromType ~= data.toType then
		if (data.fromType == 'player' and data.fromSlot == currentWeapon.slot) or (data.toType == 'player' and data.toSlot == currentWeapon.slot) then
			currentWeapon = Weapon.Disarm(currentWeapon, true)
		end
	end

	StartInventoryAction('swap', data, function()

		local success, response, weaponSlot = lib.callback.await('ox_inventory:swapItems', false, data)

		swapActive = false

		if success then

			--[[ Remove weapon completly from player if remove from hotbar]]
			if IS_RDR3 then
				local itemSlot = response and response?.items[1].item.slot or data.fromSlot
				local item = PlayerData.inventory[itemSlot or data.fromSlot] 

				-- if item.name == 'compass' then 
				-- 	if item.count >= 1 then
				-- 		TriggerEvent("HUD:Client:UsedCompass", true)
				-- 	else
				-- 		TriggerEvent("HUD:Client:UsedCompass", false)
				-- 	end
				-- end

				if item then
					actionWeaponToHorse(data, item)
					swapWeaponHotbar(item, data)
				end
			end

			if weaponSlot and currentWeapon then
				currentWeapon.slot = weaponSlot
			end

			if response then
				updateInventory(response.items, response.weight)
			end

		elseif response then

			if type(response) == 'table' then
				SendNUIMessage({ action = 'refreshSlots', data = { items = response } })
			else
				lib.notify({ type = 'error', description = locale(response) })
			end
			
		end

		cb(success or false)
	end)
end)


function actionWeaponToHorse(data, item)
	
	if IS_RDR3 then
		local playerPed = PlayerPedId()

		local horseEntity = currentInventory.entity

		local horse = horseEntity or Citizen.InvokeNative(0x4C8B59171957BCF7, playerPed) or GetMount(playerPed)
		
		if string.find(string.lower(item.name), "weapon") then
			local weaponHash = GetHashKey(item.name)


			Wait(100)
		
			if data.toType == 'glovebox' then 
				Citizen.InvokeNative(0xE9BD19F8121ADE3E, playerPed, weaponHash)

				N_0x14ff0c2545527f9b(horse, weaponHash, playerPed)

			elseif data.fromType == 'glovebox' then

				SetCurrentPedWeapon(playerPed, weaponHash, false)

			end
		end
	end
end


function swapWeaponHotbar(item, data)
	if string.find(string.lower(item.name), "weapon") then
		if data.toType == "player" then
			
			if data.fromSlot > 0 and data.fromSlot < 6 then
				local playerPed = PlayerPedId()
				local weaponHash = GetHashKey(item.name)
				local ammoHash = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)

				local mountOwnedByPlayer = Citizen.InvokeNative(0xF49F14462F0AE27C, PlayerId()) -- GET_MOUNT_OWNED_BY_PLAYER

				if currentInventory.entity ~= mountOwnedByPlayer or (data.toType == "player" and data.fromType == "player") then
					Citizen.InvokeNative(0xB6CFEC32E3742779, playerPed, ammoHash, weaponAmmo, GetHashKey('REMOVE_REASON_DROPPED'))  --_REMOVE_AMMO_FROM_PED_BY_TYPE
					RemoveWeaponFromPed(playerPed, weaponHash)
				end
			end
			
			--[[
				useSlot esta dando merda se usar ele por aqui, tem que usar pelo servidor
			]]
			
			-- if data.toSlot > 0 and data.toSlot < 6 then
			-- 	useSlot(data.toSlot)
			-- end
		end
	end
end


local SADDLEBAG_POINTS =
{
    {
        boneName = 'SPR_L_Saddlebag',

        lootAnimationDict = 'mech_pickup@loot@horse_saddlebags@live@lt'
    },
    {
        boneName = 'SPR_R_Saddlebag',
        
        lootAnimationDict = 'mech_pickup@loot@horse_saddlebags@live@rt'
    }
}

function StartInventoryAction(actionType, data, cb)
	if IS_RDR3 and (data.fromType == 'glovebox' or data.toType == 'glovebox') then

		--[[ Só bloquear o inventário caso esteja removendo item do cavalo ]]
		local lockInventory = (data.fromType == 'glovebox' and data.toType == 'player')
							-- true

		if lockInventory then
			gCanPlayerCloseInventory = false
		else
			cb()
		end

		local playerPed = PlayerPedId()
		local horseEntity = currentInventory.entity

		local closestSaddlebagPoint         = nil
		local closestSaddlebagPointDistance = nil
		local closestSaddlebagPointPosition = nil

		local playerPos = GetEntityCoords(playerPed)

		for _, saddlebagPoint in ipairs(SADDLEBAG_POINTS) do

			local boneName in saddlebagPoint

			local boneIndex = GetEntityBoneIndexByName(horseEntity, boneName)

			local bonePos = GetWorldPositionOfEntityBone(horseEntity, boneIndex)
			-- local bonePos = GetPedBoneCoords(horseEntity, 50064)

			local distanceToPlayer = #(playerPos - bonePos)

			if not closestSaddlebagPoint or distanceToPlayer < closestSaddlebagPointDistance then
				closestSaddlebagPoint         = saddlebagPoint
				closestSaddlebagPointDistance = distanceToPlayer
				closestSaddlebagPointPosition = bonePos
			end
		end

		local DICT = closestSaddlebagPoint.lootAnimationDict
		local ANIM = 'base'

		RequestAnimDict(DICT)

		while not HasAnimDictLoaded(DICT) do
			Citizen.Wait(0)
		end

		ClearPedTasks(playerPed, true, false) --[[ Flags de acordo com script da rockstar ]]
		ClearPedTasks(horseEntity)

        ClearPedSecondaryTask(playerPed)

		local taskSequenceId = OpenSequenceTask()
		--[[ 0 ]] TaskFollowNavMeshToCoord(0, closestSaddlebagPointPosition, 1.0, 20000, 0.1, 0, 40000.0)
        --[[ 1 ]] TaskTurnPedToFaceCoord(0, closestSaddlebagPointPosition, 0)
        --[[ 2 ]] TaskPlayAnim(0, DICT, ANIM, 4.0, -4.0, -1, 4, 0.0, false, 0, false, 0, false)
		CloseSequenceTask(taskSequenceId)
		TaskPerformSequence(playerPed, taskSequenceId)
		ClearSequenceTask(taskSequenceId)

        CreateThread(function()
            local sequenceProgress

            local taskedHorse = false

            while sequenceProgress ~= -1 do
                Wait(0)

                sequenceProgress = GetSequenceProgress(playerPed)

                if sequenceProgress == 2 and not taskedHorse then
                    TaskPlayAnim(horseEntity, DICT, 'base_horse', 4.0, -4.0, -1, 65552, 0.0, false, 0, false, 0, false)

                    taskedHorse = true
                end
            end

			if lockInventory then
				if taskedHorse then
					-- Animação acabou e tudo ocorreu como esperado, então a gente executa a ação do inventário
					cb()
				end

				gCanPlayerCloseInventory = true
			end

			RemoveAnimDict(DICT)
        end)

        --[=[
        do -- DEBUG
            CreateThread(function()
                while true do
                    Wait(0)

                    for _, saddlebagPoint in ipairs(SADDLEBAG_POINTS) do

                        local boneName in saddlebagPoint

                        local boneIndex = GetEntityBoneIndexByName(horseEntity, boneName)

                        local bonePos = GetWorldPositionOfEntityBone(horseEntity, boneIndex)

                        Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, bonePos, bonePos + vec3(0.0, 0.0, 0.5), 255, 0, 0, 255)
                    end
                end
            end)
        end
        --]=]
		
		return
	end

	cb()
end

RegisterNUICallback('buyItem', function(data, cb)
	---@type boolean, false | { [1]: number, [2]: SlotWithItem, [3]: SlotWithItem | false, [4]: number}, NotifyProps
	local response, data, message = lib.callback.await('ox_inventory:buyItem', 100, data)

	if data then
		updateInventory({
			{
				item = data[2],
				inventory = cache.serverId
			}
		}, data[4])

		if data[3] then
			SendNUIMessage({
				action = 'refreshSlots',
				data = {
					items = {
						{
							item = data[3],
							inventory = 'shop'
						}
					}
				}
			})
		end
	end

	if message then
		lib.notify(message)
	end

	cb(response)
end)

RegisterNUICallback('craftItem', function(data, cb)
	cb(true)

	local id, index = currentInventory.id, currentInventory.index

	for i = 1, data.count do
		local success, response = lib.callback.await('ox_inventory:craftItem', 200, id, index, data.fromSlot, data.toSlot)

		if not success then
			if response then lib.notify({ type = 'error', description = locale(response or 'cannot_perform') }) end
			break
		end
	end

	if not currentInventory or currentInventory.type ~= 'crafting' then
		client.openInventory('crafting', { id = id, index = index })
	end
end)

lib.callback.register('ox_inventory:getVehicleData', function(netid)
	local entity = NetworkGetEntityFromNetworkId(netid)

	if entity then
		return GetEntityModel(entity), IS_GTAV and GetVehicleClass(entity) or 'wagon'
	end
end)

AddEventHandler('playerTargetEntityChanged', function(interactedEntityId)
    currentInteractedEntityId = interactedEntityId
end)

AddEventHandler("client.receivePickupType", function(pickupHash)
	TriggerServerEvent("inventory:addWeaponFromPickup", pickupHash)
end)


RegisterNUICallback('updateCurrentAmmo', function(itemName, cb)
	local playerPed = PlayerPedId()
	local currentAmmo = GetPedAmmoByType(playerPed, itemName)

	local ammoHash = GetHashKey( itemName )

	-- Citizen.InvokeNative(0xCC9C4393523833E2, playerPed, currentWeapon.hash, ammoHash)
	SetAmmoTypeForPedWeapon(playerPed, currentWeapon.hash, ammoHash)
end)

local weaponGroupHashByString = {
	[`group_pistol`] = 'bullet',
	[`group_repeater`] = 'bullet',
	[`group_revolver`] = 'bullet',
	[`group_rifle`] = 'bullet',
	[`group_sniper`] = 'bullet',
	[`group_shotgun`] = 'shotgun',
	[`group_thrown`] = 'tomahawk',
	[`group_bow`] = 'arrow',
	[`group_fishingrod`] = 'fishing',
}

local ammoTypeByGroup = {
	arrow = {
        { '' ,'arrow_type_normal' },
        { '_CONFUSION' ,'arrow_type_confusion' },
        { '_DISORIENT' ,'arrow_type_disoriented' },
        { '_DRAIN' ,'arrow_type_drained' },
        { '_DYNAMITE' ,'arrow_type_explosive' },
        { '_FIRE' ,'arrow_type_fire' },
        { '_IMPROVED' ,'arrow_type_improved' },
        { '_POISON' ,'arrow_type_poison' },
        { '_SMALL_GAME' ,'arrow_type_small_game' },
        { '_TRAIL' ,'arrow_type_trail' },
        { '_WOUND' ,'arrow_type_wounded' },
    },
    bullet = {
        { '' ,'bullet_normal' },
        { '_EXPRESS' ,'bullet_express' },
        { '_EXPRESS_EXPLOSIVE' ,'bullet_express_explosive' },
        { '_HIGH_VELOCITY' ,'bullet_high_velocity' },
        { '_INCENDIARY' ,'bullet_incendiary' },
        { '_SPLIT_POINT' ,'bullet_split_point' },
        { '_TRANQUILIZER' ,'bullet_varmint' },
    },
    dynamite = {
        { '' ,'dynamite_normal' },
        { '_VOLATILE' ,'dynamite_volatile' },
    },
	-- fishing = { 
	-- 	bobber = { '', 'fishing_type_bobber' },
	-- 	lure = { '', 'fishing_type_lure' },
	-- },
    shotgun = {
        { '' ,'shotgun_normal' },
        { '_SLUG_EXPLOSIVE' ,'shotgun_explosive' },
        { '_BUCKSHOT_INCENDIARY' ,'bullet_incendiary' },
        { '_SLUG' ,'shotgun_slug' },
    },
    tomahawk = {
        { '' ,'tomahawk_normal' },
        { '_ANCIENT' ,'tomahawk_ancient' },
        { '_HOMING' ,'tomahawk_homing' },
        { '_IMPROVED' ,'tomahawk_improved' },
    }
}

function setCurrentWeaponGroup()
	if not currentWeapon then
		return
	end

	local weaponGroup = GetWeapontypeGroup( currentWeapon.hash )
	local groupType = weaponGroupHashByString[weaponGroup]

	if not groupType then
		return
	end

	local groupAmmoTypes = ammoTypeByGroup[groupType]

	if not groupAmmoTypes then
		return
	end	

	SendNUIMessage({
		action = 'setAmmoGroup',
		data = groupType
	})

	local ammoType = ("%s%s"):format( currentWeapon.ammo, groupAmmoTypes[1][1])

	local ammoHash = GetHashKey( ammoType )
	local ammoName = GetLabelTextByHash( ammoHash )

	currentWeapon.currentAmmo = ammoType:lower()

	SendNUIMessage({
		action = 'setCurrentAmmo',
		data = { hash = groupAmmoTypes[1][2], name = ammoName }
	})
end

local currentSelectedAmmoIndex = 0

function setCurrentAmmo( isRight, selectedIndex )
	if not currentWeapon then
		return
	end

	local weaponGroup = GetWeapontypeGroup( currentWeapon.hash )

	local groupType = weaponGroupHashByString[weaponGroup]
	
	if not groupType then
		return
	end
	
	local groupAmmoTypes = ammoTypeByGroup[groupType]

	if not groupAmmoTypes then
		return
	end

	if not currentSelectedAmmoIndex then
		currentSelectedAmmoIndex = 0
	end

	if selectedIndex then
		currentSelectedAmmoIndex = selectedIndex
	end

	local newIndex = currentSelectedAmmoIndex

	if isRight == true then
		newIndex = currentSelectedAmmoIndex + 1
		if newIndex > #groupAmmoTypes then
			newIndex = 1
		end
	elseif isRight == false then
		newIndex = currentSelectedAmmoIndex - 1
		if newIndex < 1 then
			newIndex = #groupAmmoTypes
		end
	end

	local currentAmmoData = groupAmmoTypes[newIndex or 1]

	local playerPed = PlayerPedId()
	local ammoType = ("%s%s"):format( currentWeapon.ammo, currentAmmoData[1] )

	local ammoHash = GetHashKey( ammoType )
	local currentAmmo = GetPedAmmoByType(playerPed, ammoHash)

	-- if currentAmmo <= 1 and groupType == 'arrow' then
	-- 	return
	-- end

	local ammoName = GetLabelTextByHash( ammoHash )

	SendNUIMessage({
		action = 'setCurrentAmmo',
		data = { hash = currentAmmoData[2], name = ammoName}
	})

	currentWeapon.currentAmmo = ammoType:lower()

	currentSelectedAmmoIndex = newIndex
	SetAmmoTypeForPedWeapon(playerPed, currentWeapon.hash, ammoHash)
end
