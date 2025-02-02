return {
    ['tonic_pirate_rum'] = {
		type = 'Generic',
		label = 'Rum pirata envelhecido',
		weight = 150,
		description = "Consumir aumenta sua experiência",
	},
    ['cocaine_gum'] = {
		type = 'Generic',
		label = 'Goma de cocaina',
		weight = 150,
		description = "Restaurar totalmente a stamina e pode deixar ligeiramente mais forte.",
	},
    ['chewing_tobacco'] = {
		type = 'Generic',
		label = 'Tabaco de Mascar',
		weight = 150,
		description = "Restaurar totalmente a stamina e pode deixar ligeiramente mais forte.",
	},
    ['ginseng_elixir'] = {
		type = 'Generic',
		label = 'Ginseng Elixir',
		weight = 150,
		description = "Consumir dá experiência à saúde",
	},


    ['tonic_health_care'] = {
		type = 'Generic',
		label = 'Tônico de Saúde',
		weight = 150,
		description = "Consumir dá experiência à saúde",
	},
    ['tonic_miracle_cure'] = {
		type = 'Generic',
		label = 'Tônico Cura milagrosa',
		weight = 150,
		description = "Restaura a saúde, a resistência",
	},
    ['tonic_miracle'] = {
		type = 'Generic',
		label = 'Tônico Milagre',
		weight = 150,
		description = "Restaura totalmente tudo e ligeiramente os fortalece",
	},
	['tonic_horse_care'] = {
		type = 'Generic',
		label = 'Tônico de Cavalo',
		weight = 150,
		description = "Restaurar a saúde do cavalo e fortifificá-lo ligeiramente",
	},


    ['tonic_potent_cure'] = {
		type = 'Generic',
		label = 'Tônico de Cura Fraco',
		description = "Restaurar totalmente a saúde e fortifica-a moderadamente",
		degrade = 900000,
		["weight"] = 500,
		consume = 0,
		server = { export = 'frp_death_state.itemTonic' },
	},
    ['tonic_potent_miracle'] = {
		type = 'Generic',
		label = 'Tônico de cura Potente',
		description = "Restore totalmente tudo e moderadamente fortificá-los",
		degrade = 900000,
		["weight"] = 700,
		consume = 0,
		server = { export = 'frp_death_state.itemTonic' },
	},

    ['tonic_horse_reviver'] = {
		type = 'Generic',
		label = 'Reanimador de Cavalo',
		weight = 150,
		description = "Revive cavalo de grave lesão e restaura a saúde",
		consume = 1,
		client = { export = 'frp_death_state.reviverItem' },
		server = { export = 'frp_death_state.reviverItem' },
	},

    ['tonic_horse_stimulant'] = {
		type = 'Generic',
		label = 'Estimulante de Cavalo',
		weight = 150,
		consume = 1,
		description = "Restaura totalmente a resistência do cavalo e o fortalece ligeiramente",
	},
    ['tonic_horse_potent_cure'] = {
		type = 'Generic',
		label = 'Tônico de Cura para Cavalos',
		weight = 150,
		consume = 1,
		description = "Restaurar totalmente a saúde do cavalo e fortifica-a moderadamente",
	},
    ['tonic_horse_potent_stimulant'] = {
		type = 'Generic',
		label = 'Tônico Amargo potente',
		weight = 150,
		consume = 1,
		description = "Restaurar a resistência e fortificá-la moderadamente",
	},

	['reviver_dog'] = {
		type = 'Generic',
		label = 'Reanimador de Cachorros',
		weight = 150,
		consume = 1,
		description = "Reanima cachorros",
	},

	["reviver"] =
	{
		type = 'Generic',
		["label"] = "Reanimador",
		["description"] = "Revive pessoas gravemente feridas",
		["weight"] = 500,
		consume = 1,
		client = { export = 'frp_death_state.reviverItem' },
		server = { export = 'frp_death_state.reviverItem' },
	},

	["medicine"] =
	{
		type = 'Generic',
		["label"] = "Remédio",
		["description"] = "Cura até os mais feridos",
		["weight"] = 700,
		degrade = 15000,
		consume = 1,
		client = { export = 'frp_death_state.itemMedicine' },
		server = { export = 'frp_death_state.itemMedicine' },
	},
}