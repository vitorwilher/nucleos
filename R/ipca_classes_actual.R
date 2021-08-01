# Relatório de Inflação (dezembro/2019)

ipca_classes_actual = dplyr::lst(

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
    47650, # Integração transporte público
    7642, # Emplacamento e licença
    107653, # Multa
    7649, # Pedágio
    7657, # Gasolina
    7659, # Óleo diesel
    107657, # Gás veicular
    7662, # Produtos farmacêuticos
    7696, # Plano de saúde
    7723, # Cartório
    7728, # Conselho de classe
    107668, # Jogos de azar
    7789, # Correio
    47668 # Plano de telefonia fixa
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
    47649, # Transporte por aplicativo
    7643, # Seguro voluntário de veículo
    7647, # Conserto de automóvel;
    7648, # Estacionamento
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7685, # Médico
    7686, # Dentista
    12414, # Aparelho ortodôntico
    12435, # Fisioterapeuta
    12436, # Psicólogo
    7690, # Serviços laboratoriais e hospitalares
    7715, # Costureira
    12421, # Manicure
    7720, # Empregado doméstico
    47654, # Cabeleireiro e barbeiro
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    47655, # Sobrancelha
    7733, # Clube
    47657, # Tratamento de animais (clínica)
    47658, # Casa noturna
    47659, # Hospedagem
    47660, # Pacote turístico
    47661, # Serviço de higiene para animais
    47662, # Cinema, teatro e concertos
    12427, # Cursos regulares
    107678, # Cursos diversos
    47669, # Plano de telefonia móvel
    47670, # TV por assinatura
    107688, # Acesso à internet
    47671, # Serviços de streaming
    47672 # Combo de telefonia, internet e TV por assinatura
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
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7685, # Médico
    7686, # Dentista
    12414, # Aparelho ortodôntico
    12435, # Fisioterapeuta
    12436, # Psicólogo
    7690, # Serviços laboratoriais e hospitalares
    7715, # Costureira
    12421, # Manicure
    47654, # Cabeleireiro e barbeiro
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    47655, # Sobrancelha
    7733, # Clube
    47657, # Tratamento de animais (clínica)
    47658, # Casa noturna
    47661, # Serviço de higiene para animais
    47662 # Cinema, teatro e concertos
    ),

  "servicos_ex_subjacente" = servicos[!servicos %in% servicos_subjacente],

  "ex0" = c(
    7432, # Alimentação fora do domicílio
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
    47649, # Transporte por aplicativo
    7641, # Automóvel novo
    7643, # Seguro voluntário de veículo
    7644, # Óleo lubrificante
    7645, # Acessórios e peças
    12411, # Pneu
    7647, # Conserto de automóvel
    7648, # Estacionamento
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
    7720, # Empregado doméstico
    47654, # Cabeleireiro e barbeiro
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    47655, # Sobrancelha
    7733, # Clube
    7735, # Instrumento musical
    47657, # Tratamento de animais (clínica)
    7736, # Bicicleta
    107666, # Alimento para animais
    7738, # Brinquedo
    47658, # Casa noturna
    7746, # Material de caça e pesca
    47659, # Hospedagem
    47660, # Pacote turístico
    47661, # Serviço de higiene para animais
    47662, # Cinema, teatro e concertos
    7759, # Cigarro
    12427, # Cursos regulares
    7777, # Leitura
    7782, # Papelaria
    107678, # Cursos diversos
    47669, # Plano de telefonia móvel
    47670, # Tv por assinatura
    107688, # Acesso à internet
    7794, # Aparelho telefônico
    47671, # Serviços de streaming
    47672 # Combo de telefonia, internet e tv por assinatura
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
    12427, # Cursos regulares
    7777, # Leitura
    7782, # Papelaria
    107678, # Cursos diversos
    7788 # Comunicação
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
    12433, # Vidro
    7459, # Tinta
    12398, # Revestimento de piso e parede
    47634, # Madeira e taco
    107638, # Cimento
    107639, # Tijolo
    107640, # Material hidráulico
    107642, # Areia
    107643, # Pedras
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
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7654, # Motocicleta
    109464, # Produtos óticos
    7684, # Serviços médicos e dentários
    7690, # Serviços laboratoriais e hospitalares
    7698, # Higiene pessoal
    7715, # Costureira
    12421, # Manicure
    47654, # Cabeleireiro e barbeiro
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    47655, # Sobrancelha
    7733, # Clube
    7735, # Instrumento musical
    47657, # Tratamento de animais (clínica)
    7736, # Bicicleta
    107666, # Alimento para animais
    7738, # Brinquedo,
    47658, # Casa noturna
    7746, # Material de caça e pesca
    47661, # Serviço de higiene para animais
    47662, # Cinema, teatro e concertos
    7777, # Leitura
    7782, # Papelaria
    7794 # Aparelho telefônico
    ),

  "ex3" = c(
    7432, # Alimentação fora do domicílio
    7448, # Aluguel residencial
    7449, # Condomínio
    7453, # Mudança
    7455, # Ferragens
    7456, # Material de eletricidade
    12433, # Vidro
    7459, # Tinta
    12398, # Revestimento de piso e parede
    47634, # Madeira e taco
    107638, # Cimento
    107639, # Tijolo
    107640, # Material hidráulico
    107642, # Areia
    107643, # Pedras
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
    7653, # Pintura de veículo
    107656, # Aluguel de veículo
    7654, # Motocicleta
    109464, # Produtos óticos
    7684, # Serviços médicos e dentários
    7690, # Serviços laboratoriais e hospitalares
    7698, # Higiene pessoal
    7715, # Costureira
    12421, # Manicure
    47654, # Cabeleireiro e barbeiro
    7721, # Depilação
    7724, # Despachante
    7727, # Serviço bancário
    47655, # Sobrancelha
    7733, # Clube
    7735, # Instrumento musical
    47657, # Tratamento de animais (clínica)
    7736, # Bicicleta
    107666, # Alimento para animais
    7738, # Brinquedo
    47658, # Casa noturna
    7746, # Material de caça e pesca
    47661, # Serviço de higiene para animais
    47662, # Cinema, teatro e concertos
    7777, # Leitura
    7782, # Papelaria
    7794 # Aparelho telefônico
    )

  )
