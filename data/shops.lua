return {
	General = {
		name = 'Armazém Geral',
		prompt = true,
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{name = "water", price = 0.05},
			{name = "apple", price = 0.05},
			{name = "canned_meat", price = 0.25},
			{name = "canned_corn", price = 0.25},
			{name = "canned_stew", price = 0.25},
			{name = "alcohol", price = 0.30},
			{name = "canteen_empty", price = 1.20},
			{name = "notepad", price = 0.30},
			{name = "compass", price = 0.50},
			{name = "brush", price = 0.90},
			{name = "empty_watering_can", price = 1.50},
			{name = "bottle_empty", price = 0.05},	
			{name = "axe", price = 2.35}, 
			{name = "pickaxe", price = 2.35},	
			{name = "sieve", price = 2.35}, 
			{name = "campfire", price = 0.15}, 
			{name = "emptybag", price = 0.01},
			{name = "pigeon", price = 0.25},
			{name = "scratch_ticket", price = 1.50},
			{name = "dog_food", price = 1.00},	
		}, locations = {
			vec3(2825.75, -1318.34, 46.76), -- Saint Denis
			vec3( 1328.48, -1292.83, 77.02), -- Rhodes
			vec3(-322.39, 803.89, 117.69), -- Valentine
			vec3(-785.20, -1323.84, 43.89), -- BlackWater
			--vec3(-3685.508, -2623.638, -13.431), -- Armadillo
			--vec3(-5487.755, -2938.284, -0.388), -- Tumbleweed
			vec3(-1791.316, -387.160, 160.334), -- Strawberry
		}, targets = {
			-- { loc = vec3(25.06, -1347.32, 29.5), length = 0.7, width = 0.5, heading = 0.0, minZ = 29.5, maxZ = 29.9, distance = 1.5 },
		}
	},

	Idcard = {
		name = 'Emissão de Documento',
		prompt = true,
		blip = {
			id = 59, colour = 69, scale = 0.8
		}, inventory = {
			{name = "id_card", price = 2.00},
		}, locations = {
			vec3(2513.64, -1305.51, 48.77), -- Saint Denis
			vec3(-279.01, 808.6, 119.19), -- Valentine
			vec3(-768.12, -1266.33, 43.87), -- Blackwater
			vec3(2906.2, 1308.63, 44.75), -- Annesburg
		}, targets = {
			-- { loc = vec3(25.06, -1347.32, 29.5), length = 0.7, width = 0.5, heading = 0.0, minZ = 29.5, maxZ = 29.9, distance = 1.5 },
		}
	},

	Pexeiro = {
		name = 'Acessorios de Pesca',
		prompt = true,
		blip = {
			id = 402, colour = 69, scale = 0.8
		}, inventory = {
			{name = "WEAPON_FISHINGROD", price = 0.5},
			{name = "p_baitBread01x", price = 0.02},
			{name = "p_baitCorn01x", price = 0.02},
			{name = "p_baitCheese01x", price = 0.02},
			{name = "p_baitWorm01x", price = 0.02},
			{name = "p_baitCricket01x", price = 0.02},			
			{name = "p_crawdad01x", price = 0.02},
			{name = "p_FinisdFishlure01x", price = 0.05},
			{name = "p_finishdcrawd01x", price = 0.05},
			{name = "p_finishedragonflylegendary01x", price = 2},
			{name = "p_finisdfishlurelegendary01x", price = 0.12},						
			{name = "p_finishdcrawdlegendary01x", price = 0.12},			
			{name = "p_lgoc_spinner_v4", price = 0.12},
			{name = "p_lgoc_spinner_v6", price = 0.12},
		}, locations = {
			vec3(2662.841, -1505.69, 45.978),  -- saint denis
			vec3(-757.3929, -1360.937, 43.737)  -- black water
		}, targets = {
			-- { loc = vec3(2746.8, 3473.13, 55.67), length = 0.6, width = 3.0, heading = 65.0, minZ = 55.0, maxZ = 56.8, distance = 3.0 }
		}
	},

	Ammunation = {
		name = 'Loja de Armas',
		prompt = true,
		blip = {
			id = 110, colour = 69, scale = 0.8
		}, inventory = {
			{name = "weapon_melee_lantern", price = 2},
            {name = "weapon_melee_davy_lantern", price = 2},

            {name = "WEAPON_KIT_BINOCULARS", price = 3},			
            {name = "WEAPON_LASSO", price = 2.50},
            {name = "WEAPON_MELEE_KNIFE", price = 2.50},
            {name = "WEAPON_BOW", price = 20},

            {name = "WEAPON_REVOLVER_DOUBLEACTION", price = 8},
            {name = "WEAPON_REVOLVER_DOUBLEACTION_GAMBLER", price = 15},

            {name = "WEAPON_REVOLVER_CATTLEMAN", price = 13},
            {name = "WEAPON_REVOLVER_CATTLEMAN_MEXICAN", price = 20},

            {name = "WEAPON_REVOLVER_NAVY", price = 15},
            {name = "WEAPON_PISTOL_MAUSER", price = 30},
			{name = "WEAPON_REPEATER_EVANS", price = 40},
            {name = "WEAPON_RIFLE_VARMINT", price = 10},
            {name = "WEAPON_REPEATER_CARBINE", price = 20},	

            {name = "ammo_22", price = 0.01},
            {name = "ammo_revolver", price = 0.04},
            {name = "ammo_pistol", price = 0.05},
            {name = "ammo_rifle", price = 0.10},
            {name = "ammo_repeater", price = 0.04},
            {name = "ammo_arrow", price = 0.13},
			{name = "ammo_case", price = 2.55},

			-- { name = 'WEAPON_PISTOL', price = 1000, metadata = { registered = true }, license = 'weapon' }
		}, locations = {
			vec3(2715.9, -1285.04, 49.63), -- Saint Denis
			vec3(1323.09, -1321.63, 77.8), -- Rhodes
			vec3(2946.47, 1319.74, 44.88), -- Annesburg
			vec3(-281.26, 780.72, 119.49), -- Valentine
			--vec3(-5508.22, -2964.26, -0.62), -- Tumb
		}, targets = {
			-- { loc = vec3(-660.92, -934.10, 21.94), length = 0.6, width = 0.5, heading = 180.0, minZ = 21.8, maxZ = 22.2, distance = 2.0 },
		}
	},

	Jornaleiro = {
		name = 'Jornaleiro',
		prompt = true,
		blip = {
			id = 93, colour = 69, scale = 0.8
		},
		inventory = {
			{name = "newspaper", price = 0.45},
			{ name = 'weapon_kit_camera', price = 10},
		}, locations = {
			vec3(2696.89, -1385.2, 46.02), -- Saint Denis
			vec3(-791.61, -1289.63, 43.44), -- BlackWater
			vec3(1239.38, -1287.44, 76.73), -- Rhodes
			vec3(-1837.3, -423.0, 160.63), -- Strawberry
			--vec3(-3642.41, -2618.9, -13.94), -- Armadillo
		}, targets = {
			-- { loc = vec3(1134.9, -982.34, 46.41), length = 0.5, width = 0.5, heading = 96.0, minZ = 46.4, maxZ = 46.8, distance = 1.5 },
		}
	},

	Estabulo = {
		name = 'Estabulo',
		prompt = true,
		blip = {
			id = 93, colour = 69, scale = 0.8
		},
		inventory = {
			{name = "tonic_horse_reviver", price = 0.50},
			{name = "tonic_horse_stimulant", price = 1.50},
			{name = "tonic_horse_potent_cure", price = 1.50},
		}, locations = {
			vec3(2510.71, -1456.25, 46.13),
			vec3(-878.33, -1367.98, 43.34),
		}, targets = {
			-- { loc = vec3(1134.9, -982.34, 46.41), length = 0.5, width = 0.5, heading = 96.0, minZ = 46.4, maxZ = 46.8, distance = 1.5 },
		}
	},
	
	Farmacia = {
		name = 'Farmacia',
		prompt = true,
		blip = {
			id = 93, colour = 69, scale = 0.8
		},
		inventory = {
			{name = "tonic_potent_cure", price = 5.0},
			{name = "reviver", price = 5.00},
			{name = "reviver_dog", price = 2.00},
			reviver_dog
		}, locations = {
			vec3(2727.88, -1232.04, 50.37),             
            vec3(1369.522, -1310.382, 77.937),          
            vec3(-289.544, 807.453, 119.385),
            vec3(-1806.983, -432.513, 158.831),       
            vec3(-3646.776, -2601.155, -13.1639),      
            vec3(2931.193, 1365.98, 45.19),     
            vec3(472.666, 2267.511, 249.1554), 
		}, targets = {
			-- { loc = vec3(1134.9, -982.34, 46.41), length = 0.5, width = 0.5, heading = 96.0, minZ = 46.4, maxZ = 46.8, distance = 1.5 },
		}
	},

	MercadoClandestino = {
		name = 'Vendedor Klandestino',
		prompt = true,
		blip = {
			id = 93, colour = 69, scale = 0.8
		}, 
		inventory = {
			{name = "lockpick", price = 2 },
			{name = "lockpickr", price = 5 },
			{name = "dynamite", price = 10 },

			{ name = 'handcuffs', price = 5 },
			{ name = 'handcuffs_keys', price = 1 },
		}, locations = {
			vec3(2831.45, -1054.33, 43.78), -- saint dennis
			vec3(2955.12, 1419.45, 44.87), -- Van Horn

		}, targets = {
			-- { loc = vec3(1134.9, -982.34, 46.41), length = 0.5, width = 0.5, heading = 96.0, minZ = 46.4, maxZ = 46.8, distance = 1.5 },
		}
	},

	PoliceArmoury = {
		name = 'Armário de Sheriff',
		prompt = true,
		groups = shared.police,
		blip = {
			id = 110, colour = 84, scale = 0.8
		}, 
		inventory = {
			{ name = 'badge_officer', price = 0, grade = 0 },
			{ name = 'badge_texas_ranger', price = 0, grade = 0 },
			{ name = 'badge_sheriff', price = 0, grade = 0 },
			{ name = 'badge_deputy', price = 0, grade = 0 },
			{ name = 'badge_marshal', price = 0, grade = 0 },

			{ name = 'handcuffs', price = 0 },
			{ name = 'handcuffs_keys', price = 0 },
			{name = "pigeon", price = 0.15},	

			{ name = 'weapon_kit_camera', price = 5, grade = 0 },
			{ name = "weapon_kit_binoculars", price = 0.80},		
			{ name = 'weapon_melee_knife', price = 0.30 },
			{ name = 'weapon_lasso', price = 0.20 },

            { name = "ammo_revolver", price = 0.03},
            { name = "ammo_pistol", price = 0.04},
            { name = "ammo_rifle", price = 0.05},
            { name = "ammo_repeater", price = 0.03},

			{ name = 'weapon_revolver_schofield', price = 5, metadata = { registered = true, serial = 'OFICIAL' } },
			{ name = 'weapon_revolver_cattleman', price = 1, metadata = { registered = true, serial = 'OFICIAL' } },
			{ name = 'weapon_revolver_navy', price = 3, metadata = { registered = true, serial = 'OFICIAL' } },
			{ name = 'weapon_revolver_lemat', price = 7, metadata = { registered = true, serial = 'OFICIAL' } },

			{ name = 'weapon_pistol_mauser', price = 7, metadata = { registered = true, serial = 'OFICIAL' } },

			{ name = 'weapon_repeater_carbine', price = 5, metadata = { registered = true, serial = 'OFICIAL' } },
			{ name = 'weapon_repeater_evans', price = 14, metadata = { registered = true, serial = 'OFICIAL' } },
			{ name = 'weapon_repeater_winchester', price = 15, metadata = { registered = true, serial = 'OFICIAL' } },
			{ name = 'weapon_repeater_henry', price = 16, metadata = { registered = true, serial = 'OFICIAL' } },

			{ name = 'weapon_rifle_springfield', price = 20, metadata = { registered = true, serial = 'OFICIAL' } },
			{ name = 'weapon_rifle_boltaction', price = 28, metadata = { registered = true, serial = 'OFICIAL' } },
		
			-- { name = 'WEAPON_CARBINERIFLE', price = 1000, metadata = { registered = true, serial = 'POL' }, license = 'weapon', grade = 3 },
		}, locations = {
			vec3(2494.307, -1304.298, 48.953), -- saint dennis
			vec3(1361.17, -1305.839, 77.760), -- rhodes			
			vec3(2906.925, 1315.27, 44.938), -- annesburg
			vec3(-278.4373, 805.3104, 119.38), -- valentine
			vec3(-1814.101, -354.86, 164.64), -- Strawberry
			vec3(-764.753, -1272.402, 44.0413), -- blackwater
			vec3(-3623.315, -2602.468, -13.342), -- armadillo
			vec3(-5526.658, -2928.369, -1.3609), -- Thumbweed
		}, targets = {
			{ loc = vec3(453.21, -980.03, 30.68), length = 0.5, width = 3.0, heading = 270.0, minZ = 30.5, maxZ = 32.0, distance = 6 }
		}
	},

	
	IllegalShop = {
		name = 'Vendedor Clandestino',
		prompt = false,
		blip = {
			id = 403, colour = 69, scale = 0.8
		}, inventory = {
			{ name = 'distiller',  price = 250, count = 1 },
			{ name = 'opiumtable', price = 200, count = 1 },
		}, locations = {
			vector3(759.85, -849.62, 55.13)
		},
		targets = {
			-- { loc = vec3(453.21, -980.03, 30.68), length = 0.5, width = 3.0, heading = 270.0, minZ = 30.5, maxZ = 32.0, distance = 6 }
		}
	},

	Fazenda = {
		name = 'Fazenda',
		prompt = true,
		blip = {
			id = 93, colour = 69, scale = 0.8
		},
		inventory = {
			{name = "tobacco_seed", price = 0.05},
			{name = "sugar_seed", price = 0.05},
			{name = "tomato_seed", price = 0.05},
			{name = "corn_seed", price = 0.05},
			{name = "carrot_seed", price = 0.05},
			{name = "cotton_seed", price = 0.05},
			{name = "wheat_seed", price = 0.05},
			{name = "potato_seed", price = 0.05},
			{name = "goldencurrant_seed", price = 0.05},
			{name = "weed_seed", price = 0.05},

		}, locations = {
			vec3(2587.82, -1010.6, 44.05), -- Saint Denis
			vec3(-965.36, -1252.72, 53.78), -- BlackWater
			vec3(-404.62, 662.44, 115.37), -- Valentine
		}, targets = {
			-- { loc = vec3(1134.9, -982.34, 46.41), length = 0.5, width = 0.5, heading = 96.0, minZ = 46.4, maxZ = 46.8, distance = 1.5 },
		}
	},
}