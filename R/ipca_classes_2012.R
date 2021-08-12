# Relatório de Inflação (dezembro/2011)

.ipca_classes_2012 <- dplyr::lst(

  "monitorados" = c(
    7451, # Taxa de água e esgoto
    7482, # Gás de botijão
    7483, # Gás encanado
    7485, # Energia elétrica residencial
    7628, # Ônibus urbano
    7629, # Táxi
    7630, # Trem
    7631, # Ônibus intermunicipal
    7632, # Ônibus interestadual
    7635, # Metrô
    12410, # Transporte hidroviário
    7642, # Emplacamento e licença
    107653, # Multa
    7649, # Pedágio
    7657, # Gasolina
    7659, # Óleo diesel
    107657, # Gás veicular
    7662, # Produtos farmacêuticos
    7696, # Plano de saúde
    107668, # Jogos de azar
    7789, # Correio
    7790, # Telefone fixo
    7791 # Telefone público
  ),

  "servicos" = c(
    7432, # Alimentação fora do domicílio
    7448, # Aluguel residencial
    7449, # Condomínio
    7453, # Mudança
    107641, # Mão de obra (Reparos)
    7549, # Consertos e manutenção
    7634, # Passagem aérea
    7639, # Transporte escolar
    7643, # Seguro voluntário de veículo
    7647, # Conserto de automóvel;
    7648, # Estacionamento
    7650, # Lubrificação e lavagem
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7685, # Médico
    7686, # Dentista
    12435, # Fisioterapeuta
    12436, # Psicólogo
    7690, # Serviços laboratoriais e hospitalares
    7715, # Costureira
    12421, # Manicure
    7719, # Cabeleireiro
    7720, # Empregado doméstico
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    7728, # Conselho de classe
    7731, # Cinema
    7732, # Ingresso para jogo
    7733, # Clube
    12424, # Tratamento de animais
    12425, # Locação de DVD
    12426, # Boate e danceteria
    7747, # Motel
    7753, # Hotel
    7756, # Excursão
    7763, # Revelação e cópia
    12427, # Cursos regulares
    7784, # Fotocópia
    107678, # Cursos diversos
    7792, # Telefone celular
    107688, # Acesso à internet
    12429, # Telefone com internet - pacote
    12430 # Tv por assinatura com internet
  ),

  "servicos_subjacente" = c(
    7432, # Alimentação fora do domicílio
    7448, # Aluguel residencial
    7449, # Condomínio
    7453, # Mudança
    7549, # Consertos e manutenção
    7639, # Transporte escolar
    7643, # Seguro voluntário de veículo
    7647, # Conserto de automóvel;
    7648, # Estacionamento
    7650, # Lubrificação e lavagem
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7685, # Médico
    7686, # Dentista
    12435, # Fisioterapeuta
    12436, # Psicólogo
    7690, # Serviços laboratoriais e hospitalares
    7715, # Costureira
    12421, # Manicure
    7719, # Cabeleireiro
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    7728, # Conselho de classe
    7731, # Cinema
    7732, # Ingresso para jogo
    7733, # Clube
    12424, # Tratamento de animais
    12425, # Locação de DVD
    12426, # Boate e danceteria
    7747, # Motel
    7763, # Revelação e cópia
    7784 # Fotocópia
  ),

  "servicos_ex_subjacente" = servicos[!servicos %in% servicos_subjacente],

  "ex0" = c(
    7433, # Alimentação fora do domicílio
    7448, # Aluguel residencial
    7449, # Condomínio
    7453, # Mudança
    7454, # Reparos
    7461, # Artigos de limpeza
    7481, # Carvão vegetal
    7488, # Mobiliário
    7495, # Utensílios e enfeites
    7517, # Cama, mesa e banho
    7522, # Eletrodomésticos e equipamentos
    7541, # Tv, som e informática
    7549, # Consertos e manutenção
    7560, # Roupa masculina
    7572, # Roupa feminina
    7587, # Roupa infantil
    7605, # Calçados e acessórios
    7616, # Joias e bijuterias
    7621, # Tecidos e armarinho
    7634, # Passagem aérea
    7639, # Transporte escolar
    7641, # Automóvel novo
    7643, # Seguro voluntário de veículo
    7644, # Óleo lubrificante
    7645, # Acessórios e peças
    12411, # Pneu
    7647, # Conserto de automóvel
    7648, # Estacionamento
    7650, # Lubrificação e lavagem
    107654, # Automóvel usado
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7654, # Motocicleta
    7658, # Etanol
    109464, # Produtos óticos
    7684, # Serviços médicos e dentários
    7690, # Serviços laboratoriais e hospitalares
    7698, # Higiene pessoal
    7715, # Costureira
    12421, # Manicure
    7719, # Cabeleireiro
    7720, # Empregado doméstico
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    7728, # Conselho de classe
    7731, # Cinema
    12423, # CD e DVD
    7732, # Ingresso para jogo
    7733, # Clube
    7735, # Instrumento musical
    12424, # Tratamento de animais
    7736, # Bicicleta
    107666, # Alimento para animais
    7738, # Brinquedo
    12425, # Locação de DVD
    12426, # Boate e danceteria
    7747, # Motel
    7753, # Hotel
    7756, # Excursão
    7759, # Cigarro
    7760, # Fotografia e filmagem
    12427, # Cursos regulares
    7777, # Leitura
    7782, # Papelaria
    107678, # Cursos diversos
    7792, # Telefone celular
    107688, # Acesso à internet
    7794, # Aparelho telefônico
    12429, # Telefone com internet - pacote
    12430 # TV por assinatura com internet
  ),

  "ex1" = c(
    7184, # Farinhas, féculas e massas
    7335, # Carnes e peixes industrializados
    7372, # Panificados
    7389, # Bebidas e infusões
    7401, # Enlatados e conservas
    7415, # Sal e condimentos
    7433, # Alimentação fora do domicílio
    7447, # Aluguel e taxas
    7454, # Reparos
    7461, # Artigos de limpeza
    7484, # Energia elétrica residencial
    7488, # Mobiliário
    7495, # Utensílios e enfeites
    7517, # Cama, mesa e banho
    7522, # Eletrodomésticos e equipamentos
    7541, # Tv, som e informática
    7549, # Consertos e manutenção
    7560, # Roupa masculina
    7572, # Roupa feminina
    7587, # Roupa infantil
    7605, # Calçados e acessórios
    7616, # Joias e bijuterias
    7621, # Tecidos e armarinho
    7627, # Transporte público
    7640, # Veículo próprio
    7662, # Produtos farmacêuticos
    109464, # Produtos óticos
    7684, # Serviços médicos e dentários
    7690, # Serviços laboratoriais e hospitalares
    7695, # Plano de saúde
    7698, # Higiene pessoal
    7714, # Serviços pessoais
    7730, # Recreação
    7758, # Fumo
    7760, # Fotografia e filmagem
    12427, # Cursos regulares
    7777, # Leitura
    7782, # Papelaria
    107678, # Cursos diversos
    7788 # Comunicação
  ),

  "ex2" = c(
    7432,
    7448,
    7449,
    7453,
    7549,
    7639,
    7643,
    7647,
    7648,
    7650,
    7653,
    107656,
    7685,
    7686,
    12435,
    12436,
    7690,
    7715,
    12421,
    7719,
    7721,
    7724,
    7727,
    7728,
    7731,
    7732,
    7733,
    12424,
    12425,
    12426,
    7747,
    7763,
    7784,
    7455,
    7456,
    7457,
    12433,
    7459,
    12398,
    107638,
    107639,
    107640,
    107642,
    12399,
    7461,
    7481,
    7508,
    7644,
    7698,
    107666,
    7778,
    7779,
    107676,
    7783,
    7785,
    7497,
    7498,
    12402,
    12403,
    107645,
    107646,
    7517,
    7559,
    7604,
    7620,
    7645,
    12411,
    7681,
    12414,
    7688,
    12423,
    7738,
    107677,
    7488,
    7615,
    7654,
    7680,
    12413,
    7735,
    7736,
    7761,
    7794,
    7335,
    7372,
    7389,
    7401
    ),

  "ex2" = c(
    7335, # Carnes e peixes industrializados
    7372, # Panificados
    7389, # Bebidas e infusões
    7401, # Enlatados e conservas
    7433, # Alimentação fora do domicílio
    7448, # Aluguel residencial
    7449, # Condomínio
    7453, # Mudança
    7455, # Ferragens
    7456, # Material de eletricidade
    7457, # Material de pintura
    12433, # Vidro
    7459, # Tinta
    12398, # Revestimento de piso e parede
    107638, # Cimento
    107639, # Tijolo
    107640, # Material hidráulico
    107642, # Areia
    12399, # Telha
    7461, # Artigos de limpeza
    7481, # Carvão vegetal
    7488, # Mobiliário
    7495, # Utensílios e enfeites
    7517, # Cama, mesa e banho
    7549, # Consertos e manutenção
    7560, # Roupa masculina
    7572, # Roupa feminina
    7587, # Roupa infantil
    7605, # Calçados e acessórios
    7616, # Joias e bijuterias
    7621, # Tecidos e armarinho
    7639, # Transporte escolar
    7643, # Seguro voluntário de veículo
    7644, # Óleo lubrificante
    7645, # Acessórios e peças
    12411, # Pneu
    7647, # Conserto de automóvel
    7648, # Estacionamento
    7650, # Lubrificação e lavagem
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7654, # Motocicleta
    109464, # Produtos óticos
    7684, # Serviços médicos e dentários
    7690, # Serviços laboratoriais e hospitalares
    7698, # Higiene pessoal
    7715, # Costureira
    12421, # Manicure
    7719, # Cabeleireiro
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    7728, # Conselho de classe
    7731, # Cinema
    12423, # CD e DVD
    7732, # Ingresso para jogo
    7733, # Clube
    7735, # Instrumento musical
    12424, # Tratamento de animais
    7736, # Bicicleta
    107666, # Alimento para animais
    7738, # Brinquedo
    12425, # Locação de DVD
    12426, # Boate e danceteria
    7747, # Motel
    7760, # Fotografia e filmagem
    7777, # Leitura
    7782, # Papelaria
    7794 # Aparelho telefônico
  ),

  "ex3" = c(
    7433, # Alimentação fora do domicílio
    7448, # Aluguel residencial
    7449, # Condomínio
    7453, # Mudança
    7455, # Ferragens
    7456, # Material de eletricidade
    7457, # Material de pintura
    12433, # Vidro
    7459, # Tinta
    12398, # Revestimento de piso e parede
    107638, # Cimento
    107639, # Tijolo
    107640, # Material hidráulico
    107642, # Areia
    12399, # Telha
    7461, # Artigos de limpeza
    7481, # Carvão vegetal
    7488, # Mobiliário
    7495, # Utensílios e enfeites
    7517, # Cama, mesa e banho
    7549, # Consertos e manutenção
    7560, # Roupa masculina
    7572, # Roupa feminina
    7587, # Roupa infantil
    7605, # Calçados e acessórios
    7616, # Joias e bijuterias
    7621, # Tecidos e armarinho
    7639, # Transporte escolar
    7643, # Seguro voluntário de veículo
    7644, # Óleo lubrificante
    7645, # Acessórios e peças
    12411, # Pneu
    7647, # Conserto de automóvel
    7648, # Estacionamento
    7650, # Lubrificação e lavagem
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7654, # Motocicleta
    109464, # Produtos óticos
    7684, # Serviços médicos e dentários
    7690, # Serviços laboratoriais e hospitalares
    7698, # Higiene pessoal
    7715, # Costureira
    12421, # Manicure
    7719, # Cabeleireiro
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    7728, # Conselho de classe
    7731, # Cinema
    12423, # CD e DVD
    7732, # Ingresso para jogo
    7733, # Clube
    7735, # Instrumento musical
    12424, # Tratamento de animais
    7736, # Bicicleta
    107666, # Alimento para animais
    7738, # Brinquedo
    12425, # Locação de DVD
    12426, # Boate e danceteria
    7747, # Motel
    7760, # Fotografia e filmagem
    7777, # Leitura
    7782, # Papelaria
    7794 # Aparelho telefônico
  )

  # exclui_ex1 = c(7172, 7200, 7219, 7241, 7254, 7283,
  #                7303, 7349, 7356, 7384, 7480, 7656),
  #
  # exclui_ex2 = c(7172, 7184, 7200, 7219, 7241, 7254,
  #                7283, 7303, 7349, 7356, 7384, 7415,
  #                7521, 7641, 107654, 7658, 7758,
  #                servicos_ex_subjacente, monitorados),
  #
  # exclui_ex3 = c(7171, 7521, 7641, 107654, 7658, 7758,
  #                servicos_ex_subjacente, monitorados)

  )
