if not lib then return end

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerData(key, value)
	PlayerData[key] = value
	OnPlayerData(key, value)
end

function client.hasGroup(group)
	if not PlayerData.loaded then return end

	if type(group) == 'table' then
		for name, rank in pairs(group) do
			local groupRank = PlayerData.groups[name]

			if groupRank and groupRank >= (rank or 0) then
				return name, groupRank
			end

			local gradePermission = type(rank) == "string" and rank or nil

			if Business.hasClassePermission(name, gradePermission) then
				return name, rank
			end

			if API.IsPlayerAceAllowedGroup( PlayerData.source, name ) then
				return name, rank
			end
		end
	else
		local groupRank = PlayerData.groups[group]
		if groupRank then
			return group, groupRank
		end

		local gradePermission = type(groupRank) == "string" and groupRank or nil

		if Business.hasClassePermission(group, gradePermission) then
			return group, 0
		end

		if API.IsPlayerAceAllowedGroup( PlayerData.source, group ) then
			return group, 0
		end
	end
end

local Shops = require 'modules.shops.client'
local Utils = require 'modules.utils.client'
local Weapon = require 'modules.weapon.client'
local Items = require 'modules.items.client'

function client.onLogout()
	if not PlayerData.loaded then return end

	if client.parachute then
		Utils.DeleteEntity(client.parachute)
		client.parachute = false
	end

	for _, point in pairs(client.drops) do
		if point.entity then
			Utils.DeleteEntity(point.entity)
		end

		point:remove()
	end

    for _, v in pairs(Items --[[@as table]]) do
        v.count = 0
    end

	PlayerData.loaded = false
	client.drops = nil

	client.closeInventory()
	Shops.wipeShops()

    if client.interval then
        ClearInterval(client.interval)
        ClearInterval(client.tick)
    end

	Weapon.Disarm()
end

local success, result = pcall(lib.load, ('modules.bridge.%s.client'):format(shared.framework))

if not success then
    lib.print.error(result)
    lib = nil
    return
end
