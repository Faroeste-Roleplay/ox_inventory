if not lib then return end

local Utils = {}

function Utils.PlayAnim(wait, dict, name, blendIn, blendOut, duration, flag, rate, lockX, lockY, lockZ)
	lib.requestAnimDict(dict)
	TaskPlayAnim(cache.ped, dict, name, blendIn, blendOut, duration, flag, rate, lockX, lockY, lockZ)
	RemoveAnimDict(dict)

	if wait > 0 then Wait(wait) end
end

function Utils.PlayAnimAdvanced(wait, dict, name, posX, posY, posZ, rotX, rotY, rotZ, blendIn, blendOut, duration, flag,
								time)
	lib.requestAnimDict(dict)
	TaskPlayAnimAdvanced(cache.ped, dict, name, posX, posY, posZ, rotX, rotY, rotZ, blendIn, blendOut, duration, flag,
		time, 0, 0)
	RemoveAnimDict(dict)

	if wait > 0 then Wait(wait) end
end

---@param flag number
---@param destination? vector3
---@param size? number
---@return number | false
---@return number?
function Utils.Raycast(flag, destination, size)
	local playerCoords = GetEntityCoords(cache.ped)
	destination = destination or GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 2.2, -0.25)
	local rayHandle = StartShapeTestCapsule(playerCoords.x, playerCoords.y, playerCoords.z + 0.5, destination.x,
		destination.y, destination.z, size or 2.2, flag or 30, cache.ped, 4)
	while true do
		Wait(0)
		local result, _, coords, _, entityHit = GetShapeTestResult(rayHandle)
		if result ~= 1 then
			-- DrawLine(playerCoords.x, playerCoords.y, playerCoords.z + 0.5, destination.x, destination.y, destination.z, 0, 0, 255, 255)
			-- DrawLine(playerCoords.x, playerCoords.y, playerCoords.z + 0.5, coords.x, coords.y, coords.z, 255, 0, 0, 255)
			local entityType
			if entityHit then entityType = GetEntityType(entityHit) end
			if entityHit and entityType ~= 0 then
				return entityHit, entityType
			end
			return false
		end
	end
end

function Utils.GetClosestPlayer()
	local players = GetActivePlayers()
	local playerCoords = GetEntityCoords(cache.ped)
	local targetDistance, targetId, targetPed

	for i = 1, #players do
		local player = players[i]

		if player ~= cache.playerId then
			local ped = GetPlayerPed(player)
			local distance = #(playerCoords - GetEntityCoords(ped))

			if distance < (targetDistance or 2) then
				targetDistance = distance
				targetId = player
				targetPed = ped
			end
		end
	end

	return targetId, targetPed
end

-- Replace ox_inventory notify with ox_lib (backwards compatibility)
function Utils.Notify(data)
	data.description = data.text
	data.text = nil
	lib.notify(data)
end

RegisterNetEvent('ox_inventory:notify', Utils.Notify)
exports('notify', Utils.Notify)

function Utils.ItemNotify(data)
	if not client.itemnotify then
		return
	end

	local item = data[1]
	local notifyType = data[2]
	local itemCount = data[3]
	local positive = true

	if notifyType == "ui_removed" then
		positive = false
	end

	if item.name == "money" then
		Utils.CashNotify(itemCount, 2000, positive)
		return
	end

	local soundSetStr = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", "Transaction_Feed_Sounds",
		Citizen.ResultAsLong())
	local soundNameStr = 0

	if not positive then
		soundNameStr = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", "Transaction_Negative",
			Citizen.ResultAsLong())
	else
		soundNameStr = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", "Transaction_Positive",
			Citizen.ResultAsLong())
	end

	Utils.PlaySoundSet(soundSetStr, soundNameStr)

	SendNUIMessage({ action = 'itemNotify', data = data })
end

local is_soundset_playing = false

function Utils.PlaySoundSet(soundset_ref, soundset_name)
	if not is_soundset_playing then
		local counter_i = 1
		while soundset_ref ~= 0 and not Citizen.InvokeNative(0xD9130842D7226045, soundset_ref, 0) and counter_i <= 300 do -- load soundset
			counter_i = counter_i + 1
			Citizen.Wait(0)
		end

		if soundset_ref == 0 or Citizen.InvokeNative(0xD9130842D7226045, soundset_ref, 0) then
			-- PLAY SOUND FROM POSITION:
			local ped = PlayerPedId()
			local ped_coords = GetEntityCoords(ped)
			local x, y, z = table.unpack(ped_coords + GetEntityForwardVector(ped) * 15.0)
			-- Citizen.InvokeNative(0xCCE219C922737BFA, soundset_name, x, y, z - 1.0, soundset_ref, true, 0, true, 0) -- PLAY_SOUND_FROM_POSITION
			is_soundset_playing = true

			-- OR PLAY SOUND FROM ENTITY:
			Citizen.InvokeNative(0x6FB1DA3CA9DA7D90,soundset_name,PlayerPedId(),soundset_ref,false,0,0)  -- PLAY_SOUND_FROM_ENTITY
		end
	else
		Citizen.InvokeNative(0x531A78D6BF27014B, soundset_ref)  -- stop soundset (required, otherwise new soundsets can fail to load)
		is_soundset_playing = false
	end
end

RegisterNetEvent('ox_inventory:itemNotify', Utils.ItemNotify)

---@deprecated
function Utils.DeleteObject(obj)
	SetEntityAsMissionEntity(obj, false, true)
	DeleteObject(obj)
end

function Utils.DeleteEntity(entity)
	if DoesEntityExist(entity) then
		SetEntityAsMissionEntity(entity, false, true)
		DeleteEntity(entity)
	end
end

local rewardTypes = 1 << 0 | 1 << 1 | 1 << 2 | 1 << 3 | 1 << 7 | 1 << 10

-- Enables the weapon wheel, but disables the use of inventory items
-- Mostly used for weaponised vehicles, though could be called for "minigames"
function Utils.WeaponWheel(state)
	if state == nil then state = EnableWeaponWheel end

	EnableWeaponWheel = state

	if IS_RDR3 then
		Citizen.InvokeNative(0x2A7B50E, not state) -- SetWeaponsNoAutoswap
		Citizen.InvokeNative(0x311150E5, not state) -- SetWeaponsNoAutoreload
	end

	if IS_GTAV then
		SetWeaponsNoAutoswap(not state)
		SetWeaponsNoAutoreload(not state)
	end

	if client.suppresspickups then
		-- CLEAR_PICKUP_REWARD_TYPE_SUPPRESSION | SUPPRESS_PICKUP_REWARD_TYPE
		return state and N_0x762db2d380b48d04(rewardTypes) or N_0xf92099527db8e2a7(rewardTypes, true)
	end
end

exports('weaponWheel', Utils.WeaponWheel)

function Utils.CreateBlip(settings, coords)
	local blip
	if IS_GTAV then
		blip = AddBlipForCoord(coords.x, coords.y, coords.z)
		SetBlipSprite(blip, settings.id)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, settings.scale)
		SetBlipColour(blip, settings.colour)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName(settings.name)
		EndTextCommandSetBlipName(blip)
	end

	if IS_RDR3 then
		blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z)
		SetBlipSprite(blip, settings.id, 1);

		local blipColor = settings.colour and GetHashKey(settings.colour) or `BLIP_MODIFIER_MP_COLOR_32`
		Citizen.InvokeNative(0x662D364ABF16DE2F, blip, blipColor);

		local varString = CreateVarString(10, 'LITERAL_STRING', settings.name);
		Citizen.InvokeNative(0x9CB1A1623062F402, blip, varString)
	end

	return blip
end

---Takes OxTargetBoxZone or legacy zone data (PolyZone) and creates a zone.
---@param data OxTargetBoxZone | { length: number, minZ: number, maxZ: number, loc: vector3, heading: number, width: number, distance: number }
---@param options? OxTargetOption[]
---@return number
function Utils.CreateBoxZone(data, options)
	if data.length then
		local height = math.abs(data.maxZ - data.minZ)
		local z = data.loc.z + math.abs(data.minZ - data.maxZ) / 2
		data.coords = vec3(data.loc.x, data.loc.y, z)
		data.size = vec3(data.width, data.length, height)
		data.rotation = data.heading
		data.loc = nil
		data.heading = nil
		data.length = nil
		data.width = nil
		data.maxZ = nil
		data.minZ = nil
	end

	if not data.options and options then
		local distance = data.distance or 2.0

		for k, v in pairs(options) do
			if not v.distance then
				v.distance = distance
			end
		end

		data.options = options
	end

	return exports.ox_target:addBoxZone(data)
end

function Utils.CashNotify(fAmount, durationMs, positive)
	--Transaction_Feed_Sounds", "Transaction_Positive
	local moneyAmount = (fAmount / 100)
	local strAmount = ("$%s"):format(moneyAmount)

	local str1 = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", strAmount, Citizen.ResultAsLong())
	local str2 = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", "ITEMTYPE_TEXTURES",
		Citizen.ResultAsLong())

	local soundSetStr = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", "Transaction_Feed_Sounds",
		Citizen.ResultAsLong())
	local soundNameStr = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", "Transaction_Positive",
		Citizen.ResultAsLong())

	local pStr1 = DataView.ArrayBuffer(16)
	pStr1:SetInt64(0, str1)

	local pStr2 = DataView.ArrayBuffer(16)
	pStr2:SetInt64(0, str2)

	local pSoundSetStr = DataView.ArrayBuffer(16)
	pSoundSetStr:SetInt64(0, soundSetStr)
	local pSoundNameStr = DataView.ArrayBuffer(16)
	pSoundNameStr:SetInt64(0, soundNameStr)

	local struct1 = DataView.ArrayBuffer(128)
	struct1:SetInt32(8 * 0, durationMs)           --duration
	struct1:SetInt64(8 * 1, pSoundSetStr:GetInt64(0)) -- const char*, Sound set, e.g., "Honor_Display_Sounds"
	struct1:SetInt64(8 * 2, pSoundNameStr:GetInt64(0)) -- const char*, Sound to play, e.g., "Honor_Decrease_Small"
	struct1:SetInt32(8 * 3, 0)                    --int
	struct1:SetInt32(8 * 4, 0)                    --int
	struct1:SetInt32(8 * 5, 0)                    --int
	struct1:SetInt64(8 * 6, 0)                    -- const char* 2ndSubtitle
	struct1:SetInt32(8 * 7, 0)                    --int
	struct1:SetInt32(8 * 8, 0)                    --int
	struct1:SetInt32(8 * 9, 0)                    --int
	struct1:SetInt32(8 * 10, 0)                   --int
	struct1:SetInt32(8 * 11, 0)                   --int
	struct1:SetInt32(8 * 12, 0)                   --int

	local struct2 = DataView.ArrayBuffer(128)
	struct2:SetInt32(8 * 0, 0)                                          --unk0
	struct2:SetInt64(8 * 1, pStr1:GetInt64(0))                          -- title
	struct2:SetInt64(8 * 2, pStr2:GetInt64(0))                          -- subtitle
	struct2:SetInt32(8 * 3, `ITEMTYPE_CASH`)                            -- TRANSACTION_HONOR_BAD
	struct2:SetInt32(8 * 4, 0)
	struct2:SetInt32(8 * 5, positive and `COLOR_PURE_WHITE` or `COLOR_RED`) --COLOR_GOLD
	struct2:SetInt32(8 * 6, 0)
	struct2:SetInt32(8 * 7, 0)

	--_UI_FEED_POST_SAMPLE_TOAST_RIGHT. Part of HUD_TOASTS, I believe
	Citizen.InvokeNative(0xB249EBCB30DD88E0, struct1:Buffer(), struct2:Buffer(), 1)

	-- Could this prevent the above buffers from deleting before RAGE can use them?
	Citizen.Wait(durationMs)
end

return Utils
