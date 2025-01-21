local Tunnel = module("frp_lib", "lib/Tunnel")
local Proxy = module("frp_lib", "lib/Proxy")

API = Proxy.getInterface("API")

local Inventory = require 'modules.inventory.server'
local Items = require 'modules.items.server'

Tunnel.bindInterface("inventory", Inventory)
Proxy.addInterface("inventory", Inventory)

Business = Proxy.getInterface("business")

AddEventHandler('FRP:ReleaseCharacter', function(playerId)
	server.playerDropped(playerId)
end)

AddEventHandler('FRP:UserDropped', server.playerDropped)

local function setupPlayer(User, charId)
	local Player = User:GetCharacter()

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

AddEventHandler('FRP:onCharacterLoaded', setupPlayer)

SetTimeout(500, function()
	for _, Player in pairs(API.GetUsers()) do setupPlayer(Player) end
end)