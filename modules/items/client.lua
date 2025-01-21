if not lib then return end

local Items = require 'modules.items.shared' --[[@as table<string, OxClientItem>]]

local function sendDisplayMetadata(data)
    SendNUIMessage({
		action = 'displayMetadata',
		data = data
	})
end

--- use array of single key value pairs to dictate order
---@param metadata string | table<string, string> | table<string, string>[]
---@param value? string
local function displayMetadata(metadata, value)
	local data = {}

	if type(metadata) == 'string' then
        if not value then return end

        data = { { metadata = metadata, value = value } }
	elseif table.type(metadata) == 'array' then
		for i = 1, #metadata do
			for k, v in pairs(metadata[i]) do
				data[i] = {
					metadata = k,
					value = v,
				}
			end
		end
	else
		for k, v in pairs(metadata) do
			data[#data + 1] = {
				metadata = k,
				value = v,
			}
		end
	end

    if client.uiLoaded then
        return sendDisplayMetadata(data)
    end

    CreateThread(function()
        repeat Wait(100) until client.uiLoaded

        sendDisplayMetadata(data)
    end)
end

exports('displayMetadata', displayMetadata)

---@param _ table?
---@param name string?
---@return table?
local function getItem(_, name)
    if not name then return Items end

	if type(name) ~= 'string' then return end

    name = name:lower()

    if name:sub(0, 7) == 'weapon_' or name:sub(0, 5) == 'ammo_' then
        name = name:upper()
    end

    return Items[name]
end

setmetatable(Items --[[@as table]], {
	__call = getItem
})

---@cast Items +fun(itemName: string): OxClientItem
---@cast Items +fun(): table<string, OxClientItem>

local function Item(name, cb)
	local item = Items[name]
	if item then
		if not item.client?.export and not item.client?.event then
			item.effect = cb
		end
	end
end

local ox_inventory = exports[shared.resource]
-----------------------------------------------------------------------------------------------
-- Clientside item use functions
-----------------------------------------------------------------------------------------------

Item('bandage', function(data, slot)
	local maxHealth = GetEntityMaxHealth(cache.ped)
	local health = GetEntityHealth(cache.ped)
	ox_inventory:useItem(data, function(data)
		if data then
			SetEntityHealth(cache.ped, math.min(maxHealth, math.floor(health + maxHealth / 16)))
			lib.notify({ description = 'You feel better already' })
		end
	end)
end)

Item('armour', function(data, slot)
	if GetPedArmour(cache.ped) < 100 then
		ox_inventory:useItem(data, function(data)
			if data then
				SetPlayerMaxArmour(PlayerData.id, 100)
				SetPedArmour(cache.ped, 100)
			end
		end)
	end
end)

client.parachute = false
Item('parachute', function(data, slot)
	if not client.parachute then
		ox_inventory:useItem(data, function(data)
			if data then
				local chute = `GADGET_PARACHUTE`
				SetPlayerParachuteTintIndex(PlayerData.id, -1)
				GiveWeaponToPed(cache.ped, chute, 0, true, false)
				SetPedGadget(cache.ped, chute, true)
				lib.requestModel(1269906701)
				client.parachute = CreateParachuteBagObject(cache.ped, true, true)
				if slot.metadata.type then
					SetPlayerParachuteTintIndex(PlayerData.id, slot.metadata.type)
				end
			end
		end)
	end
end)

Item('phone', function(data, slot)
	local success, result = pcall(function()
		return exports.npwd:isPhoneVisible()
	end)

	if success then
		exports.npwd:setPhoneVisible(not result)
	end
end)

Item('clothing', function(data, slot)
	local metadata = slot.metadata

	if not metadata.drawable then return print('Clothing is missing drawable in metadata') end
	if not metadata.texture then return print('Clothing is missing texture in metadata') end

	if metadata.prop then
		if not SetPedPreloadPropData(cache.ped, metadata.prop, metadata.drawable, metadata.texture) then
			return print('Clothing has invalid prop for this ped')
		end
	elseif metadata.component then
		if not IsPedComponentVariationValid(cache.ped, metadata.component, metadata.drawable, metadata.texture) then
			return print('Clothing has invalid component for this ped')
		end
	else
		return print('Clothing is missing prop/component id in metadata')
	end

	ox_inventory:useItem(data, function(data)
		if data then
			metadata = data.metadata

			if metadata.prop then
				local prop = GetPedPropIndex(cache.ped, metadata.prop)
				local texture = GetPedPropTextureIndex(cache.ped, metadata.prop)

				if metadata.drawable == prop and metadata.texture == texture then
					return ClearPedProp(cache.ped, metadata.prop)
				end

				-- { prop = 0, drawable = 2, texture = 1 } = grey beanie
				SetPedPropIndex(cache.ped, metadata.prop, metadata.drawable, metadata.texture, false);
			elseif metadata.component then
				local drawable = GetPedDrawableVariation(cache.ped, metadata.component)
				local texture = GetPedTextureVariation(cache.ped, metadata.component)

				if metadata.drawable == drawable and metadata.texture == texture then
					return -- item matches (setup defaults so we can strip?)
				end

				-- { component = 4, drawable = 4, texture = 1 } = jeans w/ belt
				SetPedComponentVariation(cache.ped, metadata.component, metadata.drawable, metadata.texture, 0);
			end
		end
	end)
end)

-----------------------------------------------------------------------------------------------



-- Item('bandage', function(data, slot)
-- 	local maxHealth = GetEntityMaxHealth(cache.ped)
-- 	local health = GetEntityHealth(cache.ped)
-- 	ox_inventory:useItem(data, function(data)
-- 		if data then
-- 			SetEntityHealth(cache.ped, math.min(maxHealth, math.floor(health + maxHealth / 16)))
-- 			ox_inventory:notify({text = 'You feel better already'})
-- 		end
-- 	end)
-- end)


local badges = {
	{ item = 'badge_deputy', hash = 's_badgedeputy01x'},
	{ item = 'badge_pinkerton', hash = 's_badgepinkerton01x'},
	{ item = 'badge_sheriff', hash = 's_badgesherif01x'},
	{ item = 'badge_marshal', hash = 's_badgeusmarshal01x'},
	{ item = 'badge_police', hash = 's_badgepolice01x'},
	{ item = 'badge_officer', hash = 's_badgedeputy01x'},
	{ item = 'badge_texas_ranger', hash = 's_badgepinkerton01x'},
}
	
Citizen.CreateThread(function()
	for i = 1, #badges do

		local badge = badges[i]
		Item(badge.item, function(data, slot)
			exports.ox_inventory:useItem(data, function(data)
				if data then
					TriggerEvent('police:client:applyBadgeInPlayer', badge.hash) 
				end
			end)
		end)
	end
end)

local baits = {
    'p_baitbread01x',
    'p_baitcorn01x',
    'p_baitcheese01x',
    'p_baitworm01x',
    'p_baitcricket01x',
    'p_crawdad01x',
    'p_finishedragonfly01x',
    'p_finishdcrawd01x',
    'p_finishedragonflylegendary01x',
    'p_finisdfishlurelegendary01x',
    'p_finishdcrawdlegendary01x',
    'p_lgoc_spinner_v4',
    'p_lgoc_spinner_v6'
}
Citizen.CreateThread(function()
    for i = 1, #baits do

        local bait = baits[i]

		Item(bait, function(data, slot)
			exports.ox_inventory:useItem(data, function(data)
				if data then				
					TriggerEvent("FISHING:UseBait", bait)
				end
			end)
		end)
    end
end)

local seeds = {
	{ name = 'potato_seed', value1 = 'CRP_POTATO_AA_sim', value2 = 'CRP_POTATO_AA_sim', value3 = 'CRP_POTATO_AA_sim' },
	{ name = 'goldencurrant_seed', value1 = 'goldencurrant_p', value2 = 'goldencurrant_p', value3 = 'goldencurrant_p' },
	{ name = 'tobacco_seed', value1 = 'CRP_TOBACCOPLANT_AA_SIM', value2 = 'CRP_TOBACCOPLANT_AB_SIM', value3 = 'CRP_TOBACCOPLANT_AC_SIM' },
	{ name = 'sugar_seed', value1 = 'CRP_SUGARCANE_AA_sim', value2 = 'CRP_SUGARCANE_AB_sim', value3 = 'CRP_SUGARCANE_AC_sim' },
	{ name = 'tomato_seed', value1 = 'CRP_TOMATOES_AA_SIM', value2 = 'CRP_TOMATOES_AA_SIM', value3 = 'CRP_TOMATOES_AA_SIM' },
	{ name = 'corn_seed', value1 = 'CRP_CORNSTALKS_CB_sim', value2 = 'CRP_CORNSTALKS_CA_sim', value3 = 'CRP_CORNSTALKS_AB_sim' },
	{ name = 'carrot_seed', value1 = 'crp_carrots_Aa_sim', value2 = 'crp_carrots_Aa_sim', value3 = 'crp_carrots_Aa_sim' },
	{ name = 'cotton_seed', value1 = 'CRP_cotton_Bc_sim', value2 = 'CRP_cotton_Bb_sim', value3 = 'CRP_cotton_Ba_sim' },
	{ name = 'wheat_seed', value1 = 'CRP_WHEAT_SAP_LONG_AB_SIM', value2 = 'CRP_WHEAT_SAP_LONG_AB_SIM', value3 = 'CRP_WHEAT_SAP_LONG_AB_SIM' },
	{ name = 'weed_seed', value1 = 'prop_weed_02', value2 = 'prop_weed_02', value3 = 'prop_weed_01' },
	{ name = 'orleander_seed', value1 = 'orleander_p', value2 = 'orleander_p', value3 = 'orleander_p' },
}
	
Citizen.CreateThread(function()
	for i = 1, #seeds do

		local seed = seeds[i]

		Item(seed.name, function(data, slot)
			exports.ox_inventory:useItem(data, function(data)
				if data then
					TriggerEvent('planting:planto1', seed.name, seed.value1, seed.value2, seed.value3)
				end
			end)
		end)
	end
end)

local horsesfoods = {
	'hay',
	'herb_wild_carrot',
	'carrot',
	'corn',
	'tomato',
}

Citizen.CreateThread(function()
    for i = 1, #horsesfoods do

        local horsesfood = horsesfoods[i]

		Item(horsesfood, function(data, slot)
			exports.ox_inventory:useItem(data, function(data)
				if data then				
					TriggerEvent('HORSES:startfeed', horsesfood)
				end
			end)
		end)
    end
end)


local consumables = {
	"water",
    "glueglue",
	"apple",
	"canned_meat",
	"canned_corn",	
	"canned_stew",
	"canteen_full",
	"bottle_milk",
	"blackberry_cake", -- Sem utilidade
	"bread",
	"oat_bread", -- Sem utilidade
	"cracker", -- Sem utilidade
	"biscuit", --
	"carrot_cake", --
	"washingtoncake", --
	"moonshine_bottle",
	"applejuice",
	"milkbread",
	"luxurymeal",
	"corn_juice",
	"grandmasstew",
	"orange_juice",
	"fullmeal",
	"opio_pipe",
	-- Até aqui está feito
	'absinto',
	'vodka',
	'arake',
	'chocolate_liquor',
	'skane_liquor',
	'champagne',
	'hidromel',
	'bberrypie',
	'washington_cake',
	'raspberry_juice',
	'sidra',
	'gin',
	'vinho',
	'blackberry_juice',
	'apple_juice',
	'corn_cake',
	'colacola',
	'canteen_full',
	'vitamin',
	'bottle_milk',
	'beer',
	'sparkling_wine',
	'whisky',
	'rum',
	'moonshine',
	'opio',
	'cigarette',
	'cigar',
	'pipe',
	'rape',
	'stringy_meat_roasted',
	'flaky_meat_roasted',
	'succulent_meat_roasted',
	'gritty_meat_roasted',
	'herptile_meat_roasted',
	'plump_meat_roasted',
	'game_meat_roasted',
	'gristly_meat_roasted',
	'crustacean_meat_roasted',
	'prime_meat_roasted',
	'mature_meat_roasted',
	'tender_meat_roasted',
	'exotic_meat_roasted',
	'big_meat_roasted',
	'stringy_meat_cooked',
	'flaky_meat_cooked',
	'succulent_meat_cooked',
	'gritty_meat_cooked',
	'herptile_meat_cooked',
	'plump_meat_cooked',
	'game_meat_cooked',
	'gristly_meat_cooked',
	'crustacean_meat_cooked',
	'prime_meat_cooked',
	'mature_meat_cooked',
	'tender_meat_cooked',
	'exotic_meat_cooked',
	'big_meat_cooked',
}

Citizen.CreateThread(function()
    for i = 1, #consumables do

        local consumable = consumables[i]

		Item(consumable, function(data, slot)
			exports.ox_inventory:useItem(data, function(data)
				if data then				
					TriggerServerEvent("HUD:Consumable:Item", consumable)
				end
			end)
		end)
    end
end)

Item('sieve', function(data, slot)
	TriggerEvent('goldpanner:StartPaning')
end)

Item('aljava', function(data, slot)
	TriggerEvent('Indian:Client:Aljava')
end)


Item('tonic_potent_cure', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("usableItems:UseTonic", 0.16)
			TriggerServerEvent('inventory:server:RemoveDurability', slot, 34)
		end
	end)
end)
Item('tonic_potent_miracle', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("usableItems:UseTonic", 0.33)
			TriggerServerEvent('inventory:server:RemoveDurability', slot, 34)
		end
	end)
end)

Item('roupaspreso', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("TexasRoupasPreso")
		end
	end)
end)

Item('handcuffs', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("police:client:CuffPlayerSoft")
		end
	end)
end)

Item('handcuffs_keys', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("police:client:CuffPlayerForceRemove")
		end
	end)
end)

Item('dog_whistle', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("ricx_dogs:pegarcachorro")
		end
	end)
end)

Item('brush', function(data, slot)
	TriggerEvent("HORSES:startbrush")
end)

Item('bucket', function(data, slot)
	TriggerEvent("lto_headbucket:Verification")
end)

Item('distiller', function(data, slot)
	local moonshineItemHash = "mp001_p_mp_still02x"
	TriggerEvent("drugs.moonshine:client:RequestSpawnItem", moonshineItemHash)	
end)

Item('opiumtable', function(data, slot)
	local moonshineItemHash = "P_TABLE06X"
	TriggerEvent("drugs.moonshine:client:RequestSpawnItem", moonshineItemHash)	
end)

Item('lockpick', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('tryLockpickingDoor', 50)
		end
	end)
end)
Item('lockpickr', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('tryLockpickingDoor', 100)
		end
	end)
end)

Item('id_card', function(data, slot)
    TriggerServerEvent("idcard:show",slot.metadata)
end)

Item('campfire', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('CAMPFIRE:Client:SpawnCampfire', "p_campfire01x")
		end
	end)
end)
Item('campfiresmall', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('CAMPFIRE:Client:SpawnCampfire', "p_campfire03x")
		end
	end)
end)

Item('scratch_ticket', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then    
			TriggerEvent("scratching:isActiveCooldown")
		end
	end)
end)

Item('newspaper', function(data, slot)
	TriggerEvent("newspaper:openNewspaper")
end)

Item('tonic_horse_stimulant', function(data, slot)
	local playerPed = PlayerPedId()
	if not IsPedOnMount(playerPed) then
		TriggerEvent("texas:notify:native", "Você precisa estar montado em um cavalo!", 2000)
		return
	end
	exports.ox_inventory:useItem(data, function(data)
		if data then 
			TriggerEvent("tonic_horse_usable", 100, 0)
		end
	end)
end)

Item('tonic_horse_potent_cure', function(data, slot)
	local playerPed = PlayerPedId()
	if not IsPedOnMount(playerPed) then
		TriggerEvent("texas:notify:native", "Você precisa estar montado em um cavalo!", 2000)
		return
	end
	exports.ox_inventory:useItem(data, function(data)
		if data then 
			TriggerEvent("tonic_horse_usable", 0, 100)
		end
	end)
end)

Item('bucket', function(data, slot)
	TriggerEvent("planting:regar1")
end)

Item('watering_can', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
        if data then
            TriggerServerEvent('planting_regarbalde')
        end
    end)
end)

Item('empty_watering_can', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
        if data then
            TriggerEvent("river_actions:item", data.name)
        end
    end)
end)
Item('canteen_empty', function(data, slot)
    TriggerEvent("river_actions:item", data.name)
end)


Item('tonic_horse_revive', function(data, slot)
	ExecuteCommand('reviveitem')
end)

Item("luckybox", function(data, slot)
	TriggerServerEvent('inventory:item:OpenLuckyBox')
end)






exports('Items', function(item) return getItem(nil, item) end)
exports('ItemList', function(item) return getItem(nil, item) end)

return Items
