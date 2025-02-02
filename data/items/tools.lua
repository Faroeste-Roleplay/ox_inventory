return {
    ["pan"] = {
		type = 'Generic',
		label = "Bateia de Garimpo",
		weight = 100,
		description = "Quem sabe você não acabe achando ouro?",
		degrade = 2880, -- dois dias
	},
    ["photographic_camera"] = {
		type = 'Generic',
		label = "Câmera Fotográfica",
		description = "Permite que você tire fotos de seus arredores",
		weight = 120,
	},
    ["coffee_percolator"] = {
		type = 'Generic',
		label = "Coador de Café",
		description = "Prepare café em qualquer fogueira",
		weight = 120,
	},
    ["oil_gun"] = {
		type = 'Generic',
		label = "Óleo de Arma",
		description = "Mantém sua arma em uma condição.",
		weight = 120,
		degrade = 2880, -- dois dias
	},
    ["anti_odor_perfume"] = {
		type = 'Generic',
		label = "Loção de Perfume Anti Odor",
		description = "Usado para bloquear o cheiro humano e reduzir a detecção de animais.",
		weight = 120,
	},
    ["compass"] = {
		type = 'Generic',
		label = "Bússola",
		description = "",
		weight = 120,
		consume = 0,
		degrade = 15000, -- dois dias
		client = {
			export = 'manager_small_resources.inventoryUsedCompass',

			remove = function(total)
				if total <= 0 then
					TriggerEvent('playerInventoryRemovedAllCompassItem')
				end
			end
		}
	},
	
    ['handcuffs'] = {
		type = 'Generic',
		label = 'Algemas',
		weight = 220,
		description = "Usado para algemar pessoas",
		degrade = 10000, -- 1 Semana
		consume = 0,
	},
	['handcuffs_keys'] = {
		type = 'Generic',
		label = 'Chaves de algemas',
		weight = 220,
		description = "Usado para abrir algemas pessoas",
		degrade = 10000,
		consume = 0,
	},
	["pickaxe"] = {
		type = 'Generic',
		label = "Picareta",
		description = "Picareta normalmente usada para estrair minerios de rochas",
		weight = 3500,
		degrade = 2880, -- dois dias
	},
	
	["shovel"] = {
		type = 'Generic',
		label = "Pá",
		description = "Normalmente utilizado para cavar buracos",
		weight = 3500,
		degrade = 2880, -- dois dias
	},

    ["axe"] = {
		type = 'Generic',
		label = "Machado",
		description = "Machado afiado ideal para cortar arvores",
		weight = 1500,
		degrade = 2880, -- dois dias
	},
	["lockpickr"] = {
		type = 'Generic',  
		label = "Gazua Roforçada",
		description = "Usada para abrir coisas, não quebra fácil",
		weight = 40,
		consume = 0,
		degrade = 2880, -- dois dias
	},
	["lockpick"] = {
		type = 'Generic',
		label = "Gazua",
		description = "Usada para abrir coisas",
		weight = 20,
		consume = 0,
		degrade = 2880, -- dois dias
	},

	-- NOVOS CRAFTS
	["knife_cordless"] = {
		type = 'Generic',
		label = "Faca sem fio",
		description = "Arma branca sem Fio",
		weight = 500,
	},
	["knife_rustic_cordless"] = {
		type = 'Generic',
		label = "Faca Rustica sem fio",
		description = "Arma branca sem Fio",
		weight = 500,
	},
	["knife_trader_cordless"] = {
		type = 'Generic',
		label = "Faca de Negociador sem fio",
		description = "Arma branca sem Fio",
		weight = 500,
	},
	["thrown_knives_cordless"] = {
		type = 'Generic',
		label = "Faca de Arremesso sem fio",
		description = "Arma branca sem Fio",
		weight = 500,
	},
	["thrown_tomahawk_cordless"] = {
		type = 'Generic',
		label = "Machadinho de Arremesso sem fio",
		description = "Arma branca sem Fio",
		weight = 500,
	},
	["machete_collector_cordless"] = {
		type = 'Generic',
		label = "Machete de Colecionador sem fio",
		description = "Arma branca sem Fio",
		weight = 500,
	},
	["axe_cordless"] = {
		type = 'Generic',
		label = "Machado sem fio",
		description = "Arma branca sem Fio",
		weight = 500,
	},
	["pickaxe_cordless"] = {
		type = 'Generic',
		label = "Picareta sem fio",
		description = "Arma branca sem Fio",
		weight = 500,
	},
	["rake"] = {
		type = 'Generic',
		label = "Rastelo",
		description = "Ferramenta agrícola manual usada para nivelar o solo",
		weight = 400,
	},
}