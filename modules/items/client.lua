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

-- Item('clothing', function(data, slot)
-- 	local metadata = slot.metadata

-- 	if not metadata.drawable then return print('Clothing is missing drawable in metadata') end
-- 	if not metadata.texture then return print('Clothing is missing texture in metadata') end

-- 	if metadata.prop then
-- 		if not SetPedPreloadPropData(cache.ped, metadata.prop, metadata.drawable, metadata.texture) then
-- 			return print('Clothing has invalid prop for this ped')
-- 		end
-- 	elseif metadata.component then
-- 		if not IsPedComponentVariationValid(cache.ped, metadata.component, metadata.drawable, metadata.texture) then
-- 			return print('Clothing has invalid component for this ped')
-- 		end
-- 	else
-- 		return print('Clothing is missing prop/component id in metadata')
-- 	end

-- 	ox_inventory:useItem(data, function(data)
-- 		if data then
-- 			metadata = data.metadata

-- 			if metadata.prop then
-- 				local prop = GetPedPropIndex(cache.ped, metadata.prop)
-- 				local texture = GetPedPropTextureIndex(cache.ped, metadata.prop)

-- 				if metadata.drawable == prop and metadata.texture == texture then
-- 					return ClearPedProp(cache.ped, metadata.prop)
-- 				end

-- 				-- { prop = 0, drawable = 2, texture = 1 } = grey beanie
-- 				SetPedPropIndex(cache.ped, metadata.prop, metadata.drawable, metadata.texture, false);
-- 			elseif metadata.component then
-- 				local drawable = GetPedDrawableVariation(cache.ped, metadata.component)
-- 				local texture = GetPedTextureVariation(cache.ped, metadata.component)

-- 				if metadata.drawable == drawable and metadata.texture == texture then
-- 					return -- item matches (setup defaults so we can strip?)
-- 				end

-- 				-- { component = 4, drawable = 4, texture = 1 } = jeans w/ belt
-- 				SetPedComponentVariation(cache.ped, metadata.component, metadata.drawable, metadata.texture, 0);
-- 			end
-- 		end
-- 	end)
-- end)

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

Item('shovel', function(data, slot)
    TriggerEvent("grave:useShovelViolate")
end)


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
	{ name = 'potato_seed' },
	{ name = 'goldencurrant_seed' },
	{ name = 'tobacco_seed' },
	{ name = 'sugar_seed' },
	{ name = 'tomato_seed' },
	{ name = 'corn_seed' },
	{ name = 'carrot_seed' },
	{ name = 'cotton_seed' },
	{ name = 'wheat_seed' },
	{ name = 'weed_seed' },
	{ name = 'prariepoppy_seed' },
	{ name = 'herb_guarana_seed' },
	{ name = 'seed_blackberry' },
	{ name = 'seed_strawberry' },
	{ name = 'seed_orange' },
	{ name = 'herb_coffee_seed' },

	{ name = 'herb_milkweed_seed' },
	{ name = 'herb_oregano_seed' },
	{ name = 'herb_wild_carrot_seed' },
	{ name = 'herb_alaskan_ginseng_seed' },
	{ name = 'herb_wild_mint_seed' },
}
	
Citizen.CreateThread(function()
	for i = 1, #seeds do

		local seed = seeds[i]

		Item(seed.name, function(data, slot)
			exports.ox_inventory:useItem(data, function(data)
				if data then
					TriggerEvent('plantation:client:requestPlant', seed.name)
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
	"consumable_chocolate_bar",
	"consumable_chocolate",
	"consumable_candycanes",
	"consumable_candy_bag",
	"apple",
	"canned_meat",
	"canned_corn",	
	"canned_stew",
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
	-- 'canteen_full',
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
	'pipe_native',
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
	"drink_generic",
	"food_generic",
	'tobacco_gum',
}

Citizen.CreateThread(function()
    for i = 1, #consumables do

        local consumable = consumables[i]

		Item(consumable, function(data, slot)
			exports.ox_inventory:useItem(data, function(data)
				if data then				
					TriggerServerEvent("HUD:Consumable:Item", consumable, slot.metadata)
				end
			end)
		end)
    end
end)

Item('sieve', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		TriggerEvent('goldpanner:StartPaning')
	end)
end)

Item('aljava', function(data, slot)
	TriggerEvent('Indian:Client:Aljava')
end)

Item('poison_mana', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("usableItems:UseTonicPoison", 45)
			-- TriggerServerEvent('inventory:server:RemoveDurability', slot, 28)
		end
	end)
end)

Item('hunt_eye_poison', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		exports.player_interactions.eyePoison( data, slot )
	end)
end)

Item('tonic_potent_cure_native', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("usableItems:UseTonic", 0.25)
			-- TriggerServerEvent('inventory:server:RemoveDurability', slot, 28)
		end
	end)
end)

Item('tonic_potent_cure', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("usableItems:UseTonic", 0.20)
			-- TriggerServerEvent('inventory:server:RemoveDurability', slot, 34)
		end
	end)
end)

Item('tonic_potent_miracle', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent("usableItems:UseTonic", 0.40)
			-- TriggerServerEvent('inventory:server:RemoveDurability', slot, 34)
		end
	end)
end)

Item('cigarette_box', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerServerEvent("consumable:cigarette_box:getOne")
			-- TriggerServerEvent('inventory:server:RemoveDurability', slot, 10)
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

-- Item('handcuffs', function(data, slot)
-- 	exports.ox_inventory:useItem(data, function(data)
-- 		if data then
-- 			TriggerEvent("interact:player:tryCuff")
-- 		end
-- 	end)
-- end)

-- Item('handcuffs_keys', function(data, slot)
-- 	exports.ox_inventory:useItem(data, function(data)
-- 		if data then
-- 			TriggerEvent("interact:player:tryUnCuffWithKey")
-- 		end
-- 	end)
-- end)

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
			TriggerEvent('tryLockpicking', 50)
		end
	end)
end)
Item('lockpick_advanced', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('tryLockpickingDoor', 100)
			TriggerEvent('tryLockpicking', 100)
		end
	end)
end)

Item('id_card', function(data, slot)
    TriggerEvent("document:display", slot.metadata)
end)

Item('campfire', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('CAMPFIRE:Client:SpawnCampfire', "p_campfire05x")
		end
	end)
end)

Item('campfire_smoke', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('CAMPFIRE:Client:SpawnCampfire', "p_campfire_coloursmoke01x")
		end
	end)
end)

Item('campfire_medium', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('CAMPFIRE:Client:SpawnCampfire', "p_campfire04x")
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

-- Item('newspaper', function(data, slot)
-- 	TriggerEvent("newspaper:readNewspaper")
-- end)

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

-- Item('bottle_empty', function(data, slot)
--     exports.ox_inventory:useItem(data, function(data)
--         if data then
--             TriggerEvent("river_actions:item", data.name)
--         end
--     end)
-- end)

Item('canteen_full', function(data, slot)

	TriggerEvent("river_actions:item", data.name)

    exports.ox_inventory:useItem(data, function(data)
		TriggerServerEvent("HUD:Consumable:Item", data.name)
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

Item("initial_weapon_box", function(data, slot)
	TriggerServerEvent('inventory:item:openWeaponBox', data.name)
end)
Item("medium_weapon_box", function(data, slot)
	TriggerServerEvent('inventory:item:openWeaponBox', data.name)
end)
Item("elite_weapon_box", function(data, slot)
	TriggerServerEvent('inventory:item:openWeaponBox', data.name)
end)

Item('whistle', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
        if data then
            TriggerEvent("law:whistle:item")
        end
    end)
end)

Item('scroll_skill', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
		local metadata = slot.metadata
		TriggerEvent("frp:tryUnlockSkill", metadata.skill, slot.slot)
    end)
end)

Item("dry_rack", function(data, slot)
	TriggerEvent('plantation:client:requestDry')
end)


Item("misc_bench", function(data, slot)
	local metadata = slot.metadata
	TriggerEvent('crafting:beforeBenches', metadata.bench, metadata.permission)
end)


Item("blueprint_molotov", function(data, slot)
	TriggerEvent('crafting:useBlueprint', data.name)
end)


Item("collectable_card", function(data, slot)
	local metadata = slot.metadata
	TriggerEvent('FRP:interactWithCard', metadata.model)
end)

-- Item('money_clip', function(data, slot)
-- 	TriggerServerEvent('inventory:tryPileMoney')
-- end)

-- Item('ore_coal_nugget', function(data, slot)
-- 	TriggerServerEvent('inventory:tryCoalBox')
-- end)

Item('bag_container', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
		
	end)
end)

local blueprints = {
	"blueprint_ammunition",
	"blueprint_pistol",
	"blueprint_revolver",
	"blueprint_rifle",
	"blueprint_repeater",
	"blueprint_shotgun",
	"blueprint_cruza",
	"blueprint_saka_cafe",
	"blueprint_saka_corn",
	"blueprint_yeast",
	"blueprint_cow_milk",
	"blueprint_licor_coffee",
	"blueprint_corn_oil",
	"blueprint_cornstarch",
	"blueprint_wheat_beer",
	"blueprint_alcohol",
	"blueprint_craft_alcohol",
	"blueprint_flour_wheat",
	"blueprint_refined_sugar",
	"blueprint_molasses_sugar",
	"blueprint_sugar",
	"blueprint_coffee_powder",
	"blueprint_gunpowder",
	"blueprint_lockpick_advanced",
	"blueprint_pistol_m1899",
	"blueprint_revolver_cattleman",
	"blueprint_revolver_lemat",
	"blueprint_repeater_henry",
	"blueprint_rifle_springfield",
	"blueprint_shotgun_doublebarrel",
	"blueprint_pulp_orange",
	"blueprint_pulp_strawberry",
	"blueprint_pulp_blackberry",
	"blueprint_dynamite",

	"blueprint_lockpick",
	"blueprint_handcuffs",
	"blueprint_handcuffs_keys",
	"blueprint_ammerican_cedules",
	"blueprint_cedules_molds",
	"blueprint_capitale",
	"blueprint_herbs_fine_package",
	"blueprint_oilgun"
}

for _, blueprint in pairs (blueprints) do 
	Item(blueprint, function(data, slot)
		TriggerEvent('crafting:useBlueprint', blueprint)
	end)
end

Item("clothing", function(data, slot)
	local metadata = slot.metadata

	if metadata.outfit_id then
		TriggerServerEvent('murphy_clothing:UseOutfit',metadata.outfit_id)
	else
		TriggerEvent('frp:tailor:applyItemOutfit', metadata.pedModel, metadata.outfitId)
	end
end)

local headBands = {
	'headbands1',
	'headbands2',
	'headbands3',
	'headbands4',
	'headbands5',
	'headbands6',

	'native_accessory_1',
	'native_accessory_2',
	'native_accessory_3',
	'native_accessory_4',
	'native_accessory_5',
	'native_accessory_6',
	'native_accessory_7',
	'native_accessory_8',

	'headband1',
	'headband2',
	'headband3',
	'headband4',
	'headband5',
	'headband6',
}
for _, headband in pairs (headBands) do 
	Item(headband, function(data, slot)
		TriggerEvent('mm_native_headbands:AttachHeadbandTypeOnPlayerPed', headband)
	end)
end

local facepaints = {
	'native_paint_1',
	'native_paint_2',
	'native_paint_3',
	'native_paint_4',
	'native_paint_5',
}

for _, facepaint in pairs (facepaints) do 
	Item(facepaint, function(data, slot)
		TriggerEvent('native_paint:apply', facepaint)
	end)
end

Item('phonograph', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
		TriggerEvent("boss_phonograph:client:placePropPhonograph")
	end)
end)

Item('reviver', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
		TriggerEvent("frp:reviverItem", data, slot)
	end)
end)

-- Item('tonic_horse_reviver', function(data, slot)
--     exports.ox_inventory:useItem(data, function(data)
-- 		TriggerEvent("frp:reviverItem", data, slot)
-- 	end)
-- end)

Item('honeycombs', function(data, slot)
	TriggerServerEvent('inventory:tryHoneycombs')
end)

exports('Items', function(item) return getItem(nil, item) end)
exports('ItemList', function(item) return getItem(nil, item) end)

return Items
