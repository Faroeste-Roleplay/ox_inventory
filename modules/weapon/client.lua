if not lib then return end

local Weapon = {}
local Items = require 'modules.items.client'
local Utils = require 'modules.utils.client'

-- generic group animation data
local anims = {}
anims[`GROUP_MELEE`] = { 'melee@holster', 'unholster', 200, 'melee@holster', 'holster', 600 }
anims[`GROUP_PISTOL`] = { 'reaction@intimidation@cop@unarmed', 'intro', 400, 'reaction@intimidation@cop@unarmed', 'outro', 450 }
anims[`GROUP_STUNGUN`] = anims[`GROUP_PISTOL`]

local function vehicleIsCycle(vehicle)
	local class = GetVehicleClass(vehicle)
	return class == 8 or class == 13
end

local scopesComps = {
	'COMPONENT_RIFLE_SCOPE02',
	'COMPONENT_RIFLE_SCOPE03',
	'COMPONENT_RIFLE_SCOPE04',
	''
}

local function removeScopeComponentFromWeapon( playerPed, weaponHash )
	for _, comp in ipairs( scopesComps ) do 
		RemoveWeaponComponentFromPed( playerPed, GetHashKey(comp), weaponHash ) 
	end
end

function sortear_com_tint_no_fim(lista)

	local com_tint = {}
	local sem_tint = {}

	for _, palavra in ipairs(lista) do
		if palavra:find("TINT") then
		table.insert(com_tint, palavra)
		else
		table.insert(sem_tint, palavra)
		end
	end

	for _, palavra in ipairs(com_tint) do
		table.insert(sem_tint, palavra)
	end

	return sem_tint
end

local function getSlotHashByComponent( component )
	local hash 

	if string.find( component, "_GRIP") then
		hash = GetHashKey("egkzxeea_0x6c331a5f")
	elseif string.find(component, "_WRAP") then
		hash = GetHashKey("dkxlkpba_0xfc47ff5c")
	elseif string.find(component, "_WRAP_TINT_") then
		hash = GetHashKey("eltbxawa_0x1d09a85c")
	elseif string.find(component, "_FRAME_MATERIAL_") then
		hash = GetHashKey("tcjzguba_0xa9d72b85")
	elseif string.find(component, "_BARREL_MATERIAL_") then
		hash = GetHashKey("xwspsshc_0x3d351086")
	elseif string.find(component, "_SIGHT_MATERIAL_") then
		hash = GetHashKey("syrtpvva_0xd426ea5a")
	elseif string.find(component, "_TRIGGER_MATERIAL_") then
		hash = GetHashKey("vwctsoca_0xdc1a0de6")
	elseif string.find(component, "_HAMMER_MATERIAL_") then
		hash = GetHashKey("tpjpnvga_0xe680ecdf")
	elseif string.find(component, "_GRIPSTOCK_TINT_") then
		hash = GetHashKey("hapviwga_0x57575690")
	end

	return hash 
end

function Weapon.Equip(item, data, noWeaponAnim)
	local playerPed = cache.ped
	local coords = GetEntityCoords(playerPed, true)
    local sleep

	-- addWardrobeInventoryItem("CLOTHING_ITEM_M_OFFHAND_000_TINT_004", 0xF20B6B4A)
	-- addWardrobeInventoryItem("UPGRADE_OFFHAND_HOLSTER", 0x39E57B01)

	if client.weaponanims then
		if noWeaponAnim or (cache.vehicle and vehicleIsCycle(cache.vehicle)) then
			goto skipAnim
		end

		local anim = data.anim or anims[GetWeapontypeGroup(data.hash)]

		if anim == anims[`GROUP_PISTOL`] and not client.hasGroup(shared.police) then
			anim = nil
		end

		sleep = anim and anim[3] or 1200
		if IS_GTAV then
			Utils.PlayAnimAdvanced(sleep, anim and anim[1] or 'reaction@intimidation@1h', anim and anim[2] or 'intro', coords.x, coords.y, coords.z, 0, 0, GetEntityHeading(playerPed), 8.0, 3.0, sleep*2, 50, 0.1)
		end
	end

	::skipAnim::

	item.hash = data.hash
	item.ammo = data.ammoname
	item.melee = IsWeaponAGun(data.hash) == 0

	item.timer = 0
	item.throwable = data.throwable
	item.group = GetWeapontypeGroup(item.hash)
	item.currentAmmo = data.ammoname

	local isBow = IsWeaponBow( data.hash ) == 1

	local ammoCount = (item.metadata.ammo and item.metadata.ammo > 1) and item.metadata.ammo or 0

	if isBow and ammoCount < 1 then
		ammoCount = 1
	end

	if not HasPedGotWeapon(playerPed, data.hash, 0, false) then
		local currentWeaponAmmo = GetAmmoInPedWeapon(playerPed, data.hash)

        local model = GetWeapontypeModel(data.hash)

        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end

        RequestWeaponAsset(data.hash)
        while not HasWeaponAssetLoaded(data.hash) do
            Wait(0)
        end
		
		-- RemoveAmmoFromPed
		N_0xf4823c813cb8277d(playerPed, data.hash, currentWeaponAmmo, `REMOVE_REASON_DEBUG`)

		if item.metadata.customAmmo and next(item.metadata.customAmmo ) then
			for ammoType, aCount in pairs( item.metadata.customAmmo ) do
				AddAmmoToPedByType( playerPed, GetHashKey(ammoType), aCount)
			end
		end

		if isBow then
			AddAmmoToPedByType( playerPed, GetHashKey(item.ammo), ammoCount)
		end

		--[[ GiveWeaponToPed ]]
		if data.throwable then
    		GiveWeaponToPed_2(playerPed, data.hash, tonumber(item.count), true, false, 0, false, 0.5, 1.0, 0, false, 0.0, false)
			-- Citizen.InvokeNative(0xB282DC6EBD803C75, playerPed, data.hash, tonumber(item.count), true, 0) -- GIVE_DELAYED_WEAPON_TO_PED
		else	
    		GiveWeaponToPed_2(playerPed, data.hash, 0, true, false, 0, false, 0.5, 1.0, 0, false, 0.0, false)
			SetAmmoTypeForPedWeapon( playerPed,  data.hash,  GetHashKey(item.ammo) )
		end

		local isSniperRifle = 	data.hash == `WEAPON_SNIPERRIFLE_ROLLINGBLOCK` or 
								data.hash == `WEAPON_SNIPERRIFLE_ROLLINGBLOCK_EXOTIC` or 
								data.hash == `WEAPON_SNIPERRIFLE_CARCANO`

		local components = sortear_com_tint_no_fim(item.metadata.components)
		
		if isSniperRifle then
			removeScopeComponentFromWeapon( playerPed, data.hash )
		end

		local weaponObject = GetCurrentPedWeaponEntityIndex( playerPed, 0 )

		if components then
			assert(components, 'Cade os components?')

			if components[1] then
				RemoveAllWeaponComponents( data.hash )
			end
	
			CreateThread(function()
				-- Wait(500)

				for i = 1, #components do
					local component = components[i]
					local slot = getSlotHashByComponent( component )
					-- print(" c ", component, slot)
					applyWeaponComponent(weaponObject, component, item )
				end
			end)
		end
	end

	if item.metadata.tint then SetPedWeaponTintIndex(playerPed, data.hash, item.metadata.tint) end

	local ammo = item.metadata.ammo or item.throwable and 1 or 0

	local isDualWeaponActived =  GetAllowDualWield(playerPed)

	local ret, primaryWeapon = GetCurrentPedWeapon(playerPed, 0, 2, 0)
	local ret, secondaryWeapon = GetCurrentPedWeapon(playerPed, 0, 3, 0)

	local hasPrimaryWeapon = primaryWeapon ~= `WEAPON_UNARMED`
	local hasSecondaryWeapon = secondaryWeapon ~= `WEAPON_UNARMED`

	if hasPrimaryWeapon and hasSecondaryWeapon and not isDualWeaponActived then
		Citizen.InvokeNative(0x83B8D50EB9446BBA, playerPed, true)
		isDualWeaponActived = true
	end

	if isDualWeaponActived and (hasPrimaryWeapon == data.hash or hasSecondaryWeapon == data.hash) then
		if hasPrimaryWeapon and hasSecondaryWeapon then
			if hasPrimaryWeapon == data.hash or hasSecondaryWeapon == data.hash then
				Citizen.InvokeNative(0xB282DC6EBD803C75, playerPed, hasPrimaryWeapon,  item.metadata.ammo or 100, true, 0)
				Citizen.InvokeNative(0x5E3BDDBCB83F3D84, playerPed, hasSecondaryWeapon,  item.metadata.ammo or 100, true, 0, true, 1.0)
			end
		end
	else
		SetCurrentPedWeapon(playerPed, data.hash, false, 0, false, false)
	end

	Citizen.InvokeNative(0x2A7B50E, true) -- SetWeaponsNoAutoswap

	TriggerEvent('ox_inventory:currentWeapon', item)

	if client.weaponnotify then
		Utils.ItemNotify({ item, 'ui_equipped' })
	end

	-- IsWeaponAGun
	if IsWeaponAGun(data.hash) ~= 0 then
		Citizen.CreateThreadNow(function()
			while GetCurrentPedWeaponEntityIndex(playerPed, 0) == 0 do
				Wait(0)
			end

			if not item?.slot == data.slot then
				--[[ Garantir que ainda seja a mesma arma. ]]
				return
			end

			local weaponEntityId = GetCurrentPedWeaponEntityIndex(playerPed, 0)

			local degradation, soot, dirt, damage in item.metadata
		
			assert(degradation, 'Cade o degradation?')

			-- SetWeaponDegradation
			Citizen.InvokeNative(0xA7A57E89E965D839, weaponEntityId, degradation + 0.0001)

			assert(soot, 'Cade o soot?')

			-- SetWeaponSoot
			Citizen.InvokeNative(0xA9EF4AD10BDDDB57, weaponEntityId, soot + 0.0001, false)

			assert(dirt, 'Cade o dirt?')

			-- SetWeaponDirt
			Citizen.InvokeNative(0x812CE61DEBCAB948, weaponEntityId, dirt + 0.0001, false)

			assert(damage, 'Cade o damage?')

			-- SetWeaponDamage
			Citizen.InvokeNative(0xE22060121602493B, weaponEntityId, damage + 0.0001, false)

			--[[ Os estados de degradação foram aplicados, notificar os outros scripts... ]]
			TriggerEvent('ox_inventory:equippedWeaponDegradationIsReady', item.slot)
		end)
	end

	return item, sleep
end

function Weapon.Disarm(currentWeapon, noAnim, keepHolstered)

	if currentWeapon?.timer then
		currentWeapon.timer = nil

        TriggerServerEvent('ox_inventory:updateWeapon')
		SetPedAmmo(cache.ped, currentWeapon.hash, 0)

		if client.weaponanims and not noAnim then
			if cache.vehicle and vehicleIsCycle(cache.vehicle) then
				goto skipAnim
			end

			ClearPedSecondaryTask(cache.ped)

			local item = Items[currentWeapon.name]
			local coords = GetEntityCoords(cache.ped, true)
			local anim = item.anim or anims[GetWeapontypeGroup(currentWeapon.hash)]

			if anim == anims[`GROUP_PISTOL`] and not client.hasGroup(shared.police) then
				anim = nil
			end
		end

		::skipAnim::

		if client.weaponnotify then
			Utils.ItemNotify({ currentWeapon, 'ui_holstered' })
		end

		TriggerEvent('ox_inventory:currentWeapon')
	end

	if currentWeapon then
		-- print(" keepHolstered ", keepHolstered )
		if not keepHolstered then
			Citizen.InvokeNative(0xB6CFEC32E3742779, cache.ped, GetHashKey(currentWeapon.metadata.specialAmmo or currentWeapon.ammo), currentWeapon.metadata.ammo, GetHashKey('REMOVE_REASON_DROPPED'))  --_REMOVE_AMMO_FROM_PED_BY_TYPE
			RemoveWeaponFromPed(cache.ped, currentWeapon.hash)
		end

		--[[ GetPedCurrentHeldWeapon]]
		local heldWeapon = N_0x8425c5f057012dab(cache.ped)

		--[[ Only use Swap if the weapon currently carried by the ped is the same one we are trying to disarm. ]]
		if heldWeapon == currentWeapon.hash then
			--[[ HolsterPedWeapons ]]
			N_0x94a3c1b804d291ec(cache.ped, false, false, true, false)

			--[[ #WARNING: Essa task faz com que o ped pare de correr com outros parametros ]]
			TaskSwapWeapon(cache.ped, true, false, false, false)
			print('Swapping disarm ped weapon')
		end
	end
end

function Weapon.ClearAll(currentWeapon)
	Weapon.Disarm(currentWeapon)

	if IS_RDR3 then
		RemoveAllPedWeapons(PlayerPedId(), true, IS_RDR3)
	end

	if client.parachute then
		local chute = `GADGET_PARACHUTE`
		GiveWeaponToPed(cache.ped, chute, 0, true, false)
		SetPedGadget(cache.ped, chute, true)
	end
end

if IS_RDR3 then

	RegisterNetEvent("ox_inventory:weaponUnloadAmmo", function(item)

		-- if item.ammo then
			-- RemoveAmmoFromPedByType()
	end)
	
	local attachOriginal = true
	RegisterNetEvent("ox_inventory:ReplaceAttachPoint", function(item, attachPoint)
		local id = equippedWeapons[1] and 2 or 1
		local slot = attachPoint == 2 and 0 or 1

		-- addWeapon(item.name, slot, id)
		-- addWardrobeInventoryItem(id, slot, item.name, attachPoint)
		-- #TODO: Checar se o player tem dois coldres e só depois de ter duas armas adicionar como DualWield Ativo
		-- Citizen.InvokeNative(PlayerPedId(), true);
	end)

	-- RegisterCommand("dual", function()

	-- 	addWardrobeInventoryItem("CLOTHING_ITEM_M_OFFHAND_000_TINT_004", 0xF20B6B4A);
	-- 	addWardrobeInventoryItem("UPGRADE_OFFHAND_HOLSTER", 0x39E57B01);
	-- 	addWeapon('WEAPON_SHOTGUN_SAWEDOFF', 0, 1)
	-- 	addWeapon('WEAPON_SHOTGUN_SAWEDOFF', 1, 2)
	-- end)
	
	AddEventHandler("ox_inventory:ReplaceCurrentAttachPoint", function(itemSlot)	
		local weapon = lib.callback.await('ox_inventory:getItemBySlot', nil, itemSlot)
	
		local attachPoint = 0
	
		if attachOriginal then
			attachPoint = 12
		end

		local weaponHash = GetHashKey(weapon.name)
	
		Citizen.InvokeNative(0xADF692B254977C0C, PlayerPedId(), weaponHash, true, attachPoint)
	
		attachOriginal = not attachOriginal
	end)
end

Utils.Disarm = Weapon.Disarm
Utils.ClearWeapons = Weapon.ClearAll

return Weapon
