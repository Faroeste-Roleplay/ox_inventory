return {
	['dog_food'] = {
        type = 'Generic',
		label = 'Ração para Cachorro',
		weight = 220,	
		client = {
			usetime = 2500
		},
	},
	["animal_fat_oil"] = {
        type = 'Generic',
		label = "Óleo de gordura animal",
		description = "Óleo feito para cozinhar as coisas",
		weight = 20,
	},
	["canned_meat"] = {
        type = 'Generic',
		label = "Enlatado de carne",
		description = "Carne enlatada",
		degrade = 10000,
		weight = 500,
		-- image = "enlatadodecarne",
		consume = 1
	},
	["canned_stew"] = {
        type = 'Generic',
		label = "Enlatado de Feijoada",
		description = "Feijoada Enlatada",
		degrade = 10000,
		weight = 500,
		-- image = "enlatado_de_feijoada",
		consume = 1
	},
	["canned_corn"] = {
        type = 'Generic',
		label = "Enlatado de Milho",
		description = "Milho Enlatado",
		degrade = 10000,
		weight = 400,
		-- image = "enlatado_de_milho",
		consume = 1
	},
	["refined_sugar"] = {
        type = 'Generic',
		label = "Açucar Refinado",
		description = "Saco cheio de açucar",
		weight = 300,
		-- image = "acucar",
	},
	["carrot_cake"] = {
        type = 'Generic',
		label = "Bolo de Cenoura",
		description = "Fofinho, quentinho e docinho! Bom para alimentar e desestressar",
		degrade = 7000,
		weight = 300,
		-- image = "bolocenoura",
		consume = 1
	},
	["blackberry_cake"] = {
        type = 'Generic',
		label = "Bolo de Amora Silvestre",
		description = "É um pedaço sabaroso de bolo de amora",
		degrade = 7000,
		weight = 300,
		-- image = "tortaamora",
		consume = 1
	},
	["cracker"] = {
        type = 'Generic',
		label = "Bolacha",
		description = "Deliciosas bolachas",
		degrade = 7000,
		weight = 300,
		-- image = "bolacha",
		consume = 1
	},
	["biscuit"] = {
        type = 'Generic',
		label = "Biscoitos",
		description = "Deliciosos biscoitos",
		degrade = 7000,
		weight = 300,
		-- image = "biscoito",
		consume = 1
	},
	["bread"] = {
        type = 'Generic',
		label = "Pão",
		description = "A ideia venho da França",
		degrade = 7000,
		weight = 100,
		-- image = "bread",
		consume = 1
	},
	["oat_bread"] = {
        type = 'Generic',
		label = "Pão de Aveia",
		description = "Pão feito com aveia",
		degrade = 7000,
		weight = 400,
		-- image = "paoaveia",
		consume = 1
	},

	["apple"] = {
        type = 'Generic',
		label = "Maçã",
		description = "De onde veio isso?",
		degrade = 7000,
		weight = 10,
		consume = 1
	},
	["tomato"] = {
        type = 'Generic',
		label = "Tomate",
		description = "Muito bom para usar como molho",
		degrade = 7000,
		weight = 10,
		consume = 1
	},
	["corn"] = {
        type = 'Generic',
		label = "Milho",
		description = "Uma espiga saborosa",
		degrade = 7000,
		weight = 10,
		-- consume = 1
	},
	["carrot"] = {
        type = 'Generic',
		label = "Cenoura",
		description = "Faz bem pra vista",
		degrade = 7000,
		weight = 10,
		consume = 1
	},

	["garlic"] = {
        type = 'Generic',
		label = "Alho",
		description = "Otimo Tempeiro",
		degrade = 7000,
		weight = 10,
		-- image = "garlic",
		consume = 1
	},
	["lettuce"] = {
        type = 'Generic',
		label = "Alface",
		description = "Com tomate fica bom",
		degrade = 7000,
		weight = 10,
		-- image = "letuce",
		consume = 1
	},
	["potato"] = {
        type = 'Generic',
		label = "Batata",
		description = "Descascada fica saborosa",
		degrade = 7000,
		weight = 10,
		-- image = "batata",
		consume = 1
	},
	["sugar"] = {
        type = 'Generic',
		label = "Torrões de Açucar",
		description = "Torrões de açúcar, excelente para adoçar as coisas",
		degrade = 7000,
		weight = 1,
		consume = 1
	},
	["broccoli"] = {
        type = 'Generic',
		label = "Brócolis",
		description = "Saudável",
		degrade = 3000,
		weight = 10,
		-- image = "brocolis",
		consume = 1
	},

	-- NOVOS ALIMENTOS
	["egg"] = {
        type = 'Generic',
		label = "Ovo frescos",
		description = "Ovos frescos, um bom ingrediente para bolos",
		degrade = 7000,
		weight = 20,
		consume = 1
	},
	["vanilla_essence"] = {
        type = 'Generic',
		label = "Essência de baunilha",
		description = "O cheiro disso é ótimo!",
		degrade = 7000,
		weight = 100,
		consume = 1
	},
	["whip_cream"] = {
        type = 'Generic',
		label = "Creme de chantilly",
		description = "Pera, que? Bom, parece ser feito para confeitar",
		degrade = 7000,
		weight = 100,
		consume = 1
	},
	["butter"] = {
        type = 'Generic', 
		label = "Manteiga",
		description = "Um dos derivados do leite mais antigos! Ótimo para receitas.",
		degrade = 7000,
		weight = 300,
		consume = 1
	},
	["strawberry"] = {
        type = 'Generic',
		label = "Morango",
		description = "Morango... É só um morango mesmo",
		degrade = 7000,
		weight = 20,
		consume = 1
	},
	["chocolate_syrup"] = {
        type = 'Generic',
		label = "Xarope de chocolate",
		description = "Um bom xarope, não é pra beber, é pra usar em receitas!",
		degrade = 7000,
		weight = 100,
		consume = 1
	},
	["washington_cake"] = {
        type = 'Generic',
		label = "Bolo Washington",
		description = "O clássico de Washington, esse é um dos melhores!",
		degrade = 7000,
		weight = 50,
		consume = 1
	},
	["blackberry_pie"] = {
        type = 'Generic',
		label = "Torta de amora",
		description = "Macia, docinha e bem fresca! Bom para alimentar e desestressar",
		degrade = 7000,
		weight = 50,
		consume = 1
	},
	["boston_pie"] = {
        type = 'Generic',
		label = "Torta de Boston",
		description = "A clássica torta de Boston, é uma das melhores!",
		degrade = 7000,
		weight = 50,
		consume = 1
	},
	["raspberry_juice"] = {
        type = 'Generic',
		label = "Suco de framboesa",
		description = "Nada como um suco docinho para começar o dia... ou terminar ele!",
		degrade = 7000,
		weight = 100,
		consume = 1
	},
	["orange_juice"] = {
		type = 'Generic',
		label = "Suco de Laranja",
		description = "Nada como um suco docinho para começar o dia e relaxar!",
		degrade = 7000,
		weight = 100,
		consume = 1
	},
	["corn_juice"] = {
		type = 'Generic',
		label = "Suco de Milho",
		description = "Nada como um suco docinho para começar o dia... ou terminar ele!",
		degrade = 7000,
		weight = 100,
		consume = 1
	},
	["corn_cake"] = {
        type = 'Generic',
		label = "Bolo de Milho Verde",
		description = "É delicioso demais",
		degrade = 7000,
		weight = 300,
		-- image = "bolomilho",
		consume = 1
	},
	["coca_nut"] = {
        type = 'Generic',
		label = "Noz de Coca",
		description = "Não coma isso puro",
		degrade = 15000,
		weight = 300,
		consume = 1
	},
	
	-- BEBIDAS ALCOOLICAS
	["alcohol"] = {
        type = 'Generic',
		label = "Garrafa de Alcool",
		description = "Garrafa cheia de alcool",
		degrade = 15000,
		weight = 1000,
		-- image = "Alcool",     
		consume = 1
	},
	["beer"] = {
        type = 'Generic',
		label = "Cerveja",
		description = "Garrafa com cerveja",
		degrade = 15000,
		weight = 700,
		-- image = "cerveja",
		consume = 1
	},
	["whisky"] = {
        type = 'Generic',
		label = "Whiskey",
		description = "Garrafa com whiskey",
		weight = 700,
		-- image = "whisky",
		consume = 1
	},
	["rum"] = {
        type = 'Generic',
		label = "Garrafa de Rum",
		description = "A bebida favorita dos homens do mar",
		degrade = 15000,
		weight = 1300,
		consume = 1
	},

	["sparkling_wine"] = {
        type = 'Generic',
		label = "Espumante",
		description = "Garrafa com Espumante",
		degrade = 15000,
		weight = 600,
		-- image = "consumable_ginseng_elixier",
		consume = 1
	},
	["vodka"] = {
        type = 'Generic',
		label = "Vodka",
		description = "Destilado original da Rússia",
		degrade = 15000,
		weight = 700,
		consume = 1
	},
	["skane_liquor"] = {
        type = 'Generic',
		label = "Lícor de oleo de cobra",
		description = "Beber isso faz bem ou te mata, você só vai saber se tentar",
		degrade = 15000,
		weight = 700,
		consume = 1
	},
	["chocolate_liquor"] = {
        type = 'Generic', 
		label = "Lícor de chocolate",
		description = "Bebida alcoolica doce, ideal para relaxar em um ambiente tranquilo",
		degrade = 15000,
		weight = 700,
		consume = 1
	},
	["chocolate_bar"] = {
        type = 'Generic', 
		label = "Barra de chocolate",
		description = "Bom para acalmar os animos",
		degrade = 15000,
		weight = 70,
		consume = 1
	},
	["champagne"] = {
        type = 'Generic',
		label = "Champanhe",
		description = "Bebida alcoolica importada, parece muito caro",
		degrade = 15000,
		weight = 700,
		consume = 1
	},
	["hidromel"] = {
        type = 'Generic',
		label = "Hidromel",
		description = "Doce e forte, como um bom hidromel",
		degrade = 15000,
		weight = 700,
		consume = 1
	},
	["saque"] = {
        type = 'Generic',
		label = "Saquê",
		description = "Bebida alcoolica importada, parece muito caro",
		degrade = 15000,
		weight = 700,
		consume = 1
	},

	["arake"] = {
        type = 'Generic',
		label = "Arakê",
		description = "Bebida alcoolica importada, parece muito caro",
		degrade = 15000,
		weight = 700,
		consume = 1
	},

	["absinto"] = {
        type = 'Generic',
		label = "Absinto",
		description = "Bebida alcoolica importada, parece muito caro",
		degrade = 15000,
		weight = 700,
		consume = 1
	},
	["sidra"] = {
        type = 'Generic',
		label = "Sidra",
		description = "Bebida alcoolica importada, parece muito caro",
		degrade = 15000,
		weight = 700,
		consume = 1
	},

	["gin"] = {
        type = 'Generic', 
		label = "Gin",
		description = "Bebida alcoolica doce, ideal para relaxar em um ambiente tranquilo",
		degrade = 15000,
		weight = 700,
		consume = 1
	},

	["wine"] = {
        type = 'Generic',
		label = "Vinho",
		description = "Bebida alcoolica doce, ideal para relaxar em um ambiente tranquilo",
		degrade = 15000,
		weight = 700,
		consume = 1
	},

	-- BEBIDAS NÃO ALCOOLICAS                                                  
	["vitamin"] = {
        type = 'Generic',
		label = "Vitamina",
		description = "Garrafa com vitamina",
		degrade = 15000,
		weight = 500,
		-- image = "vitamina",
		consume = 1
	},

	["water"] = {
        type = 'Generic',
		label = "Garrafa de Agua",
		description = "Garrafa cheia de agua potavel",
		degrade = 15000,
		weight = 100,
		-- image = "water",
		consume = 1
	},
	["blackberry_juice"] = {
        type = 'Generic',
		label = "Suco de Amora Silvestre",
		description = "Garrafa com suco de Amora Silvestre",
		degrade = 15000,
		weight = 300,
		-- image = "sucoamora",
		consume = 1
	},
	["apple_juice"] = {
        type = 'Generic',
		label = "Suco de Maça",
		description = "Garrafa com suco de Maça",
		degrade = 15000,
		weight = 300,
		-- image = "sucomaca",
		consume = 1
	},

	["bottle_milk"] = {
        type = 'Generic',
		label = "Garrafa de Leite",
		description = "Garrafa cheia de leite",
		degrade = 15000,
		weight = 900,
		consume = 1
	},

	["colacola"] = {
        type = 'Generic',
		label = "Cola Cola Antiga",
		description = "Agua preta adocicada",
		degrade = 15000,
		weight = 600,
		consume=  1
	},

	["cornflour"] = {
        type = 'Generic',
		label = "Farinha de Milho",
		description = "Saco com farinha de milho",
		weight = 10,
		consume = 1
	},

	["grandmasstew"] = {
        type = 'Generic',
		label = "Ensopado da Vovó",
		description = "Sopa de legumes com cubos de carnes feito especialmente pela vovó",
		degrade = 15000,
		weight = 600,
		consume = 1
	},

	["luxurymeal"] = {
        type = 'Generic',
		label = "Refeição de Luxo",
		description = "Sopa de legumes com cubos de carnes",
		degrade = 15000,
		weight = 600,
		consume = 1
	},

	["fullmeal"] = {
        type = 'Generic',
		label = "Refeição Completa",
		description = "Sopa de legumes com cubos de carnes",
		degrade = 15000,
		weight = 600,
		consume = 1
	},
	

	["milkbread"] = {
		type = 'Generic',
		label = "Pão de Leite",
		description = "",
		degrade = 15000,
		weight = 600,
		consume = 1
	},
	
	["applejuice"] = {
		type = 'Generic',
		label = "Suco de Maça",
		description = "",
		degrade = 15000,
		weight = 600,
		consume = 1
	},
}