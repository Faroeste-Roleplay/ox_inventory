return {
    
	['badge_deputy'] = {
		type = 'Generic',
		label = 'Distintivo Deputy',
		weight = 220,	
		description = 'Se você não for um policial ou oficial, devolva em um departamento mais próximo.',
		client = {
			usetime = 2500
		},
		consume = 0
	},	
	['badge_officer'] = {
		type = 'Generic',
		label = 'Distintivo de Oficial',
		weight = 220,	
		description = 'Se você não for um policial ou oficial, devolva em um departamento mais próximo.',
		client = {
			usetime = 2500
		},
		consume = 0,
	},
	['badge_pinkerton'] = {
		type = 'Generic',
		label = 'Distintivo Pinkerton',
		weight = 220,
		description = 'Se você não for um policial ou oficial, devolva em um departamento mais próximo.',
		client = {
			usetime = 2500
		},
		consume = 0
	},
	['badge_sheriff'] = {
		type = 'Generic',
		label = 'Distintivo Sheriff',
		weight = 220,
		description = 'Se você não for um policial ou oficial, devolva em um departamento mais próximo.',
		client = {
			usetime = 2500
		},
		consume = 0
	},
	['badge_marshal'] = {
		type = 'Generic',
		label = 'Distintivo Marshal',
		weight = 220,
		description = 'Se você não for um policial ou oficial, devolva em um departamento mais próximo.',
		client = {
			usetime = 2500
		},
		consume = 0
	},
	['badge_police'] = {
		type = 'Generic',
		label = 'Distintivo Policial',
		weight = 220,
		description = 'Se você não for um policial ou oficial, devolva em um departamento mais próximo.',
		client = {
			usetime = 2500
		},
		consume = 0
	},
	['badge_texas_ranger'] = {
		type = 'Generic',
		label = 'Distintivo Texas Ranger',
		weight = 220,
		description = 'Se você não for um policial ou oficial, devolva em um departamento mais próximo.',
		client = {
			usetime = 2500
		},
		consume = 0
	},

	['ammo_case'] = {
		type = 'Generic',
		label = 'Caixa de Munições',
		description = 'Utilizado para armazenar suas munições.',
		weight = 220,
		stack = false,
		client = {
			usetime = 2500,
			notification = 'Abrindo as caixa'
		},
	},

	['aljava'] = {
		type = 'Generic',
		label = 'Aljava',
		weight = 220,
		description = "Usado para armazenar flechas",
		consume = 0
	},


	['bucket'] = {
		type = 'Generic',
		label = 'Balde Fechado',
		weight = 220,
		description = "Usado para por na cabeça de algum player",
		consume = 0
	},


	-- ITENS GERAIS
	["id_card"] = {
		type = 'Generic',  
		label = "Documento de Identificação",
		description = "",
		weight = 30,
		consume = 0
	},

	["newspaper"] = {
		type = 'Generic',  
		label = "Jornal",
		description = "Fique por dentro de todas as novidades da cidade.",
		weight = 50,
		-- image = "newspaper"
	},

	["dog_whistle"] = {
		type = 'Generic',  
		label = "Apito para Cachorro",
		description = "Cães treinados reconhecem o som e vem até você.",
		weight = 50,
		-- image = "apito",
		consume = 0
	},

	["scratch_ticket"] = {
		type = 'Generic',
		label = "Raspadinha",
		description = "Fique rico ou fique pobre tentando",
		weight = 10,
		consume = 0
	},

	["canteen_empty"] = {
		type = 'Generic',
		label = "Cantil Vazio",
		description = "Muito prático para armazenar diversos líquidos",
		weight = 300,
		-- image = "cantil",
		consume = 1
	},

	["canteen_full"] = {
		type = 'Generic',
		label = "Cantil Cheio",
		description = "Muito prático para armazenar diversos líquidos",
		weight = 300,
		-- image = "cantilcheio",
		consume = 1
	},

	["campfire"] = {
		type = 'Generic',
		label = "Fogueira",
		description = "",
		weight = 900,
		-- image = "campfiresmall",
		consume = 1
	},

	["notepad"] = {
		type = 'Generic',
		label = "Bloco de Notas",
		description = "Com este papel você consegue escrever anotações ou uma carta.",
		weight = 150,
		-- image = "document_player_journal",
	},

	["bottle_empty"] = {
		type = 'Generic',
		label = "Garrafa Vazia",
		description = "Simples garrafa de vidro vazia",
		weight = 200,
		-- image = "water",
		consume = 1
	},

	["sieve"] = {
		type = 'Generic',
		label = "Peneira",
		description = "Uma ferramenta fundamental para separar coisas",
		weight = 1000,
		-- image = "peneira",
		consume = 0
	},
	
	["buckets"] = {
		type = 'Generic',
		label = "Balde vazio",
		description = "Balde com furos e velho",
		weight = 2,
		-- image = "baldes",
		consume = 0
	},

	["brush"] = {
		type = 'Generic',
		label = "Escova para Cavalos",
		description = "Usada para limpar cavalos",
		weight = 500,
		-- image = "escova",
		consume = 0
	},

	["ticket"] = {
		type = 'Generic',
		label = "Ticket",
		description = "Usado nos banheiros do saloon",
		weight = 2,
		-- image = "ticket_generico",
	},
	
	["flour_sack"] = {
		type = 'Generic',
		label = "Saco com farinha",
		description = "Saco cheio de farinha",
		weight = 300,
		-- image = "sacofarinha",
	},

	["barrel"] = {
		type = 'Generic',
		label = "Barril ",
		description = "Barril para fazer bebidas de mosto",
		weight = 3500,
		-- image = "barril",
		consume = 0
	},

	["line"] = {
		type = 'Generic',
		label = "Linha",
		description = "Usado para costuras ",
		weight = 40,
		-- image = "linha",
	},
	["rope"] = {
		type = 'Generic',  
		label = "Corda",
		description = "Usado para Amarar ",
		weight = 40,
		-- image = "corda",
	},

	-- NOVOS ITENS GERAIS			
	["bowl"] = {
		type = 'Generic',
		label = "Tigela",
		description = "Uma tigela perfeita para ensopados",
		weight = 20,
	},

	["sugar_bag"] = {
		type = 'Generic',
		label = "Saco com açúcar",
		description = "É um saco de açucar, pesado e ruim de carregar",
		weight = 20,
	},
	
	["sugar_pot"] = {
		type = 'Generic',
		label = "Pote cheio de açúcar",
		description = "Pote cheio com farinha",
		weight = 20,
	},

	["pot"] = {
		type = 'Generic', 
		label = "Pote",
		description = "Um pote resistente, bom para guardar quase qualquer coisa",
		weight = 20,
	},

	["salt_pot"] = {
		type = 'Generic',
		label = "Pote com sal",
		description = "Pote com sal, parece importado",
		weight = 20,
	},
	
	["yeast_pot"] = {
		type = 'Generic',
		label = "Fermento",
		description = "O ingrediente ideal para crescimento de massas, pães e bolos",
		weight = 20,
	},

	["flour_pot"] = {
		type = 'Generic',
		label = "Pote cheio de farinha",
		description = "Pote cheio com farinha",
		weight = 20,
	},

	["silk"] = {
		type = 'Generic',
		label = "Seda",
		description = "Você está bem?",
		weight = 120,
		consume = 1
	},

	["soap"] = {
		type = 'Generic',
		label = "Sabonete",
		description = "Usado para higiene pessoal",
		weight = 50,
		-- image = "sabonete",
	},

	["watering_can"] = {
		type = 'Generic',
		label = "Balde cheio de agua",
		description = "Balde cheio de agua",
		weight = 1000,
		consume = 0
	},

	["empty_watering_can"] = {
		type = 'Generic',
		label = "Balde vazio",
		description = "Usado para regar flores e plantas",
		weight = 500,
		consume = 0
	},

	["pigeon"] = {
		type = 'Generic',
		label = "Pombo Correio",
		description = "Usado para comunicar com outras pessoas",
		weight = 500,
		consume = 0
	},

}