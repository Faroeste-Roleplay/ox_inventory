---@todo separate module into smaller submodules to handle each framework
---starting to get bulky

function server.hasGroup(inv, group)
	if type(group) == 'table' then
		for name, rank in pairs(group) do
			local groupRank = inv.player.groups[name]
			if groupRank and groupRank >= (rank or 0) then
				return name, groupRank
			end

			if Business.hasClassePermission(inv.player.citizenId, name) then
				return name, rank
			end

			if API.IsPlayerAceAllowedGroup( inv.player.source, name ) then
				return name, 0
			end
		end
	else
		local groupRank = inv.player.groups[group]
		if groupRank then
			return group, groupRank
		end

		if Business.hasClassePermission(inv.player.citizenId, group) then
			return group, 0
		end
	
		if API.IsPlayerAceAllowedGroup( inv.player.source, group ) then
			return group, 0
		end
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
	if not player.groups then
		warn(("server.setPlayerData did not receive any groups for '%s'"):format(player?.name or GetPlayerName(player)))
	end

	return {
		source = player.source,
		name = player.name,
		groups = player.groups or {},
		citizenId = player.citizenId,
		sex = player.sex,
		dateofbirth = player.dateofbirth,
	}
end

---@diagnostic disable-next-line: duplicate-set-field
function server.buyLicense()
	warn('Licenses are not supported for the current framework.')
end

local Inventory = require 'modules.inventory.server'

function server.playerDropped(source)
	local inv = Inventory(source) --[[@as OxInventory]]

	if inv?.player then
		inv:closeInventory()
		Inventory.Remove(inv)
	end
end

local success, result = pcall(lib.load, ('modules.bridge.%s.server'):format(shared.framework))

if not success then
    lib.print.error(result)
    lib = nil
    return
end

if server.convertInventory then exports('ConvertItems', server.convertInventory) end
