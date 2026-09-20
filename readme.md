# PROMPT MESTRE — SISTEMA RURAL / RANCH / FARM PARA REDM

Você é um **arquiteto de software sênior especializado em RedM, Red Dead Redemption 2, Lua, VORP, ox_lib, oxmysql e servidores RP de alta população**.

Sua tarefa é projetar e implementar um sistema completo, profissional, modular, otimizado e escalável de **Ranch / Farm / Rural Business** para um servidor RedM RP.

O sistema não deve ser apenas um script de “comprar animais e vender carne”.

Quero criar um verdadeiro **ecossistema econômico rural**, utilizando o máximo possível das mecânicas, entidades, animais, veículos, NPCs, clima, mundo aberto, interação e ambientação disponíveis no Red Dead Redemption 2.

---

# 1. STACK OBRIGATÓRIA

O sistema deverá ser desenvolvido prioritariamente utilizando:

* RedM
* Lua
* VORP Core
* ox_lib
* oxmysql
* natives do Red Dead Redemption 2 / RedM
* OneSync, quando aplicável

Não utilizar frameworks desnecessários.

Não criar dependências externas sem necessidade.

Sempre que existir uma funcionalidade equivalente no VORP ou ox_lib, prefira utilizar a funcionalidade existente em vez de reinventá-la.

O sistema deve ser compatível com servidores Linux.

O banco de dados será MySQL/MariaDB através do oxmysql.

---

# 2. OBJETIVO

Criar um sistema chamado:

`rural_system`

que permita aos jogadores possuir, administrar, trabalhar e interagir com propriedades rurais.

O sistema deve suportar:

* Ranchos
* Fazendas
* Homesteads
* Haras
* Propriedades de criação de animais
* Propriedades agrícolas
* Propriedades mistas

O sistema deverá ser persistente.

Tudo que for importante deve ser salvo no banco de dados.

Se o servidor reiniciar:

* animais não podem desaparecer;
* plantações não podem desaparecer;
* construções não podem desaparecer;
* estoque não pode desaparecer;
* funcionários não podem desaparecer;
* contratos não podem desaparecer;
* dinheiro não pode desaparecer;
* progresso não pode desaparecer.

---

# 3. PRINCÍPIO FUNDAMENTAL

NÃO crie um sistema baseado exclusivamente em menus.

O gameplay deve acontecer no mundo do RedM.

Exemplo:

Para alimentar uma vaca, o jogador pode precisar:

1. ir até o celeiro;
2. pegar ração;
3. transportar a ração;
4. chegar ao curral;
5. alimentar os animais.

Para vender carne:

1. produzir/criar o animal;
2. transportar o animal;
3. levar ao abatedouro ou estação de processamento;
4. processar;
5. armazenar;
6. transportar;
7. vender.

Menus devem existir para gerenciamento administrativo, mas não substituir o gameplay.

---

# 4. ARQUITETURA

Crie o projeto com arquitetura modular.

Estrutura sugerida:

rural_system/

```
fxmanifest.lua

config/
    general.lua
    ranches.lua
    animals.lua
    crops.lua
    buildings.lua
    production.lua
    economy.lua
    jobs.lua
    contracts.lua
    events.lua

client/
    main.lua
    ranch.lua
    animals.lua
    crops.lua
    buildings.lua
    production.lua
    interaction.lua
    vehicles.lua
    employees.lua
    events.lua
    ui.lua

server/
    main.lua
    ranch.lua
    animals.lua
    crops.lua
    buildings.lua
    production.lua
    economy.lua
    employees.lua
    contracts.lua
    events.lua
    security.lua

shared/
    utils.lua
    enums.lua
    constants.lua

sql/
    install.sql

README.md
```

A arquitetura pode ser alterada se houver uma justificativa técnica melhor.

Não coloque todo o código em `main.lua`.

---

# 5. PROPRIEDADES

Cada propriedade deve possuir:

* ID
* nome
* proprietário
* tipo
* localização
* coordenadas
* preço
* nível
* reputação
* capacidade
* caixa
* estoque
* funcionários
* construções
* animais
* plantações
* pastos
* produção

Tipos:

* ranch
* farm
* homestead
* horse_ranch
* cattle_ranch
* livestock_farm
* mixed

---

# 6. COMPRA / VENDA / ALUGUEL / ARRENDAMENTO

O sistema deve permitir:

* comprar propriedade;
* vender propriedade;
* alugar propriedade;
* arrendar terreno;
* transferir propriedade;
* adicionar sócios;
* remover sócios.

Criar sistema de permissões.

Exemplo:

OWNER

MANAGER

WORKER

VETERINARIAN

FARMER

RANCH_HAND

Cada cargo possui permissões diferentes.

---

# 7. SOCIEDADE

Permitir que uma propriedade tenha vários membros.

Exemplo:

Rancho Rodrigues

Guilherme — 60%

John — 40%

O sistema deve permitir definir:

* porcentagem;
* cargo;
* permissões;
* acesso ao dinheiro;
* acesso ao estoque;
* acesso aos animais;
* acesso às construções.

---

# 8. ANIMAIS

Criar sistema persistente de animais.

Cada animal deve possuir individualmente:

* ID;
* ranch_id;
* espécie;
* raça;
* sexo;
* nome;
* idade;
* peso;
* saúde;
* fome;
* sede;
* felicidade;
* estresse;
* qualidade;
* genética;
* posição;
* estado;
* data de nascimento;
* proprietário.

Exemplo:

Vaca #1837

Raça: Angus

Sexo: Fêmea

Idade: 3 anos

Peso: 487 kg

Saúde: 92

Felicidade: 78

Genética:

Carne: 87

Leite: 72

Resistência: 64

---

# 9. ESPÉCIES

Criar suporte para pelo menos:

* vaca;
* touro;
* cavalo;
* porco;
* ovelha;
* cabra;
* galinha;
* galo;
* cachorro.

A arquitetura deve permitir adicionar novas espécies facilmente.

---

# 10. RAÇAS

Criar configuração para raças.

Exemplos:

Gado:

* Angus
* Hereford
* Texas Longhorn

Cavalos:

Utilizar raças/modelos disponíveis no RDR2 quando possível.

Cada raça deve possuir atributos diferentes.

Exemplo:

Angus:

carne = 95

leite = 40

crescimento = 80

resistência = 70

---

# 11. GENÉTICA

Implementar sistema de genética.

Os animais devem possuir atributos genéticos.

Quando dois animais reproduzem:

* calcular atributos dos pais;
* aplicar variação;
* criar descendente;
* herdar características;
* permitir mutações/variações controladas.

Não tornar o resultado completamente aleatório.

A genética dos pais deve influenciar o resultado.

---

# 12. REPRODUÇÃO

Animais devem poder reproduzir.

Criar:

* período de gestação;
* gravidez;
* nascimento;
* filhote;
* idade;
* maturidade;
* reprodução.

Exemplo:

Vaca + touro

↓

gestação

↓

bezerro

↓

crescimento

↓

adulto

---

# 13. NECESSIDADES DOS ANIMAIS

Cada animal deverá possuir:

* fome;
* sede;
* saúde;
* estresse;
* felicidade;
* higiene, quando aplicável.

Esses valores devem influenciar:

* crescimento;
* reprodução;
* produção;
* qualidade;
* doenças;
* morte.

---

# 14. DOENÇAS

Criar sistema de doenças.

Exemplos:

* infecção;
* doença respiratória;
* parasitas;
* desidratação;
* desnutrição.

O jogador deverá poder:

* diagnosticar;
* tratar;
* contratar veterinário;
* comprar medicamento.

---

# 15. VETERINÁRIO

Criar profissão de veterinário.

Outro jogador poderá ser veterinário.

O veterinário poderá:

* diagnosticar;
* tratar;
* vacinar;
* examinar;
* acompanhar animais.

Criar permissões para isso.

---

# 16. ALIMENTAÇÃO

Criar sistema de alimentação.

Tipos:

* ração;
* milho;
* trigo;
* feno;
* pastagem.

O alimento deve ser armazenado no estoque.

Animais consomem alimento.

Não criar consumo a cada segundo.

Usar sistema de simulação por intervalos.

---

# 17. PASTOS

Criar pastos.

Cada pasto possui:

* capacidade;
* fertilidade;
* qualidade;
* quantidade de animais;
* estado.

Se o jogador ultrapassar a capacidade:

* estresse aumenta;
* saúde diminui;
* produção diminui.

---

# 18. AGRICULTURA

Criar sistema de plantações.

Suportar:

* milho;
* trigo;
* algodão;
* tabaco;
* batata;
* cenoura;
* feijão;
* aveia;
* cevada;
* outras culturas configuráveis.

Cada plantação deve possuir:

* ID;
* ranch_id;
* posição;
* tipo;
* data de plantio;
* estágio;
* saúde;
* umidade;
* fertilidade;
* qualidade;
* doença;
* praga.

---

# 19. CICLO DA PLANTA

Implementar:

SEMENTE

↓

PLANTADA

↓

GERMINAÇÃO

↓

CRESCIMENTO

↓

MADURA

↓

COLHEITA

↓

PRODUTO

---

# 20. CLIMA

Utilizar o clima do Red Dead Redemption 2 quando possível.

O clima deve afetar:

* plantações;
* animais;
* pastos;
* água;
* produção.

Exemplos:

Chuva:

* aumenta umidade;
* ajuda crescimento;
* pode aumentar doenças.

Seca:

* diminui umidade;
* reduz crescimento;
* aumenta consumo de água.

Tempestade:

* pode danificar plantações;
* pode danificar construções;
* pode assustar animais.

---

# 21. PRAGAS

Criar eventos de pragas.

Exemplos:

* gafanhotos;
* ratos;
* insetos.

O jogador deverá poder combater através de:

* produtos;
* trabalhadores;
* ações manuais.

---

# 22. ROTAÇÃO DE CULTURA

Implementar fertilidade do solo.

Se o jogador cultivar repetidamente o mesmo produto:

* fertilidade diminui;
* produção diminui.

Implementar rotação de culturas.

---

# 23. CONSTRUÇÕES

Permitir construir:

* casa;
* celeiro;
* curral;
* estábulo;
* galinheiro;
* pasto;
* silo;
* armazém;
* oficina;
* açougue;
* defumador;
* moinho;
* poço;
* cisterna;
* torre de água;
* cercas.

As construções devem possuir:

* custo;
* nível;
* capacidade;
* manutenção;
* estado.

---

# 24. CONSTRUÇÃO NO MUNDO

Quando possível, utilizar objetos/props do próprio RDR2.

A construção deve ser persistente.

Após reiniciar o servidor:

as construções devem reaparecer.

Criar sistema de posicionamento configurável.

---

# 25. MANUTENÇÃO

Construções podem sofrer desgaste.

Exemplo:

Cerca danificada.

Celeiro danificado.

Poço quebrado.

O jogador precisa reparar.

---

# 26. PRODUÇÃO

Criar sistema de processamento.

Exemplos:

Leite

↓

Queijo

Trigo

↓

Farinha

Milho

↓

Ração

Carne

↓

Carne processada

Carne

↓

Carne defumada

Lã

↓

Tecido

---

# 27. AÇOUGUE

Criar sistema de abate/processamento.

O rendimento deve depender de:

* espécie;
* raça;
* peso;
* idade;
* saúde;
* qualidade.

Exemplo:

Animal:

Peso 500 kg

Resultado:

* carne;
* couro;
* gordura;
* ossos.

---

# 28. QUALIDADE

Produtos devem possuir qualidade de 0 a 100.

A qualidade deve depender de:

* genética;
* saúde;
* alimentação;
* idade;
* manejo;
* processamento.

Qualidade influencia preço.

---

# 29. ESTOQUE

Criar inventário próprio do rancho.

Separar:

* alimentos;
* animais;
* sementes;
* produtos;
* materiais;
* medicamentos;
* mercadorias.

Nunca confiar somente em valores enviados pelo client.

---

# 30. ECONOMIA

Criar economia configurável.

Os preços devem poder variar.

Produtos podem ter:

* preço base;
* preço mínimo;
* preço máximo;
* demanda;
* oferta.

---

# 31. MERCADO DINÂMICO

A economia deve considerar a produção do servidor.

Se muitos jogadores produzirem carne:

oferta aumenta.

Preço diminui.

Se houver pouca carne:

oferta diminui.

Preço aumenta.

Tudo deve ser configurável.

---

# 32. COMÉRCIO ENTRE CIDADES

Criar preços diferentes por região.

Exemplo:

Valentine

Carne: $8/kg

Saint Denis

Carne: $14/kg

Blackwater

Carne: $11/kg

Isso cria comércio e transporte.

---

# 33. TRANSPORTE

Criar sistema de transporte.

Suportar:

* carroças;
* transporte de animais;
* transporte de produtos;
* entrega de mercadorias.

O jogador deve precisar transportar fisicamente os produtos.

---

# 34. CONTRATOS

Criar contratos comerciais.

Exemplo:

"Entregar 500 kg de carne para Valentine."

Contrato:

* quantidade;
* produto;
* destino;
* prazo;
* valor;
* penalidade;
* reputação.

---

# 35. REPUTAÇÃO

Cada propriedade possui reputação.

Reputação aumenta com:

* contratos cumpridos;
* produtos de qualidade;
* comércio;
* bom atendimento.

Diminui com:

* contratos quebrados;
* mercadorias ruins;
* atrasos.

A reputação deve desbloquear novas oportunidades.

---

# 36. FUNCIONÁRIOS

Criar sistema de funcionários.

NPCs e jogadores poderão trabalhar no rancho.

Cargos:

* trabalhador;
* tratador;
* agricultor;
* veterinário;
* gerente;
* vaqueiro.

Cada funcionário pode possuir:

* salário;
* habilidades;
* tarefas;
* produtividade.

---

# 37. FUNCIONÁRIOS JOGADORES

Permitir contratar outros jogadores.

Exemplo:

Rancho Rodrigues

Vaga:

Vaqueiro

Salário:

$50/dia

Permissões:

* cuidar de animais;
* alimentar;
* transportar;
* colher.

Sem acesso a:

* dinheiro;
* venda;
* transferência de propriedade.

---

# 38. CÃES

Criar sistema de cães.

Tipos:

* guarda;
* pastoreio;
* caça.

Cães podem:

* proteger;
* alertar sobre invasores;
* ajudar no pastoreio;
* acompanhar o dono.

---

# 39. SEGURANÇA

Criar sistema de invasão.

Possíveis eventos:

* ladrões;
* roubo de animais;
* roubo de estoque;
* invasão;
* sabotagem.

O sistema deve permitir:

* cercas;
* cães;
* guardas;
* iluminação;
* segurança.

---

# 40. INCÊNDIOS

Criar eventos de incêndio.

Possíveis causas:

* lampião;
* fogo;
* raio;
* acidente;
* sabotagem.

O jogador deverá poder reagir.

---

# 41. EVENTOS DINÂMICOS

Criar sistema de eventos aleatórios.

Exemplos:

* seca;
* tempestade;
* doença;
* praga;
* roubo;
* incêndio;
* nascimento;
* animal fugiu;
* excelente colheita;
* infestação.

O sistema deve ser configurável.

---

# 42. CAVALOS

Criar suporte para criação de cavalos.

Permitir:

* reprodução;
* genética;
* crescimento;
* venda;
* treinamento;
* qualidade.

Utilizar atributos compatíveis com o sistema de cavalos do servidor sempre que possível.

---

# 43. GADO

Criar sistema de pastoreio.

O jogador pode:

* reunir gado;
* transportar;
* separar;
* mover;
* conduzir;
* vender.

Criar atividades de cowboy.

---

# 44. MISSÕES

Criar missões dinâmicas.

Exemplos:

"Levar 20 cabeças de gado para Valentine."

"Colher 200 kg de trigo."

"Proteger o rancho durante a noite."

"Tratar 5 animais."

"Entregar 300 kg de carne."

---

# 45. DASHBOARD

Criar painel administrativo do rancho usando ox_lib ou NUI, conforme apropriado.

Mostrar:

* dinheiro;
* produção;
* animais;
* plantações;
* funcionários;
* estoque;
* reputação;
* contratos;
* despesas;
* receitas;
* eventos.

---

# 46. FINANCEIRO

Criar caixa próprio da propriedade.

Registrar:

* receitas;
* despesas;
* salários;
* compras;
* vendas;
* manutenção;
* contratos.

Criar histórico financeiro.

---

# 47. BANCO DE DADOS

Criar SQL completo.

Sugestão mínima:

ranches

ranch_members

ranch_permissions

ranch_animals

ranch_breeding

ranch_crops

ranch_fields

ranch_buildings

ranch_inventory

ranch_production

ranch_employees

ranch_contracts

ranch_transactions

ranch_events

ranch_pastures

ranch_water

ranch_market

---

# 48. PERFORMANCE

ESTA É UMA REGRA CRÍTICA.

Não criar loops pesados.

Não executar consultas SQL continuamente.

Não atualizar todos os animais a cada frame.

Utilizar:

* cache;
* eventos;
* ticks;
* intervalos;
* lazy loading;
* sincronização somente quando necessária.

Animais distantes devem ser simulados abstratamente.

Animais próximos de jogadores podem existir como entidades reais.

---

# 49. SIMULAÇÃO OFFLINE

O rancho deve continuar funcionando quando o proprietário estiver offline.

Porém, não gerar infinitamente recursos.

Criar simulação baseada em tempo.

Exemplo:

Última atualização:

12:00

Jogador retorna:

18:00

Sistema calcula:

6 horas de simulação.

Isso deve ser feito matematicamente, sem precisar manter entidades spawnadas.

---

# 50. SPAWN INTELIGENTE

Animais e objetos devem ser spawnados somente quando necessário.

Se ninguém estiver perto:

não spawnar entidades.

Se jogador entrar na área:

spawnar.

Se sair:

despawnar e salvar estado.

---

# 51. SEGURANÇA

Toda operação importante deve ser validada no servidor.

NUNCA confiar no client.

Validar:

* proprietário;
* distância;
* permissões;
* quantidade;
* preço;
* inventário;
* dinheiro;
* animal;
* propriedade.

Evitar exploits de:

* dinheiro;
* itens;
* animais;
* duplicação;
* eventos;
* SQL.

Criar módulo:

server/security.lua

---

# 52. LOGS

Criar logs para:

* compra;
* venda;
* criação;
* abate;
* nascimento;
* contratação;
* demissão;
* alteração de permissões;
* retirada de dinheiro;
* depósito;
* transferência;
* destruição;
* eventos.

---

# 53. CONFIGURAÇÃO

Quero poder configurar praticamente tudo sem modificar a lógica principal.

Exemplo:

Config.Animals

Config.Crops

Config.Prices

Config.Ranches

Config.Buildings

Config.Events

Config.Jobs

Config.Permissions

Config.Production

---

# 54. COMPATIBILIDADE

O código deve ser preparado para integração com outros scripts.

Criar exports quando fizer sentido.

Exemplos:

exports.rural_system:GetPlayerRanch()

exports.rural_system:GetRanchAnimals()

exports.rural_system:AddRanchMoney()

exports.rural_system:AddProduct()

exports.rural_system:GetRanch()

---

# 55. EVENTOS

Criar eventos internos bem definidos.

Exemplo:

rural:animalBorn

rural:animalDied

rural:cropHarvested

rural:productCreated

rural:contractCompleted

rural:ranchUpdated

Não permitir que eventos críticos sejam exploráveis pelo client.

---

# 56. INTERAÇÃO

Priorizar:

* ox_target, se disponível;
* ox_lib;
* prompts nativos;
* interação física no mundo.

Não criar dezenas de comandos.

---

# 57. IMERSÃO

O sistema deve parecer pertencente ao universo de Red Dead Redemption 2.

Evitar:

* interfaces modernas demais;
* linguagem moderna;
* elementos futuristas;
* sistemas incompatíveis com o período histórico.

Utilizar terminologia como:

* rancho;
* fazenda;
* estábulo;
* curral;
* carroça;
* celeiro;
* armazém;
* estação;
* comerciante.

---

# 58. INTERFACE

A interface deve ser limpa e simples.

Não transformar o jogo em um painel administrativo.

O jogador deve passar a maior parte do tempo jogando no mundo.

Menus devem ser usados para:

* administração;
* estoque;
* finanças;
* permissões;
* relatórios.

---

# 59. ESCALABILIDADE

O sistema deve suportar potencialmente:

100+ ranchos.

Cada rancho pode possuir:

50+ animais.

Não projetar o sistema assumindo apenas 5 ranchos.

---

# 60. ESTRUTURA DE DADOS

Evitar armazenar dados complexos desnecessariamente em JSON quando uma tabela relacional fizer mais sentido.

Usar JSON apenas quando realmente fizer sentido, por exemplo:

genética;

configurações especiais;

atributos extensíveis.

---

# 61. SQL

Entregar:

* CREATE TABLE;
* índices;
* foreign keys quando apropriado;
* índices para consultas frequentes;
* valores padrão;
* constraints quando possível.

Pensar em performance.

---

# 62. TRATAMENTO DE ERROS

Todo código deve possuir tratamento de erros.

Não deixar:

nil errors

queries silenciosas

callbacks sem tratamento

entidades inválidas

referências inexistentes.

Logs devem ajudar o administrador a diagnosticar problemas.

---

# 63. RECUPERAÇÃO

Se o servidor reiniciar no meio de uma operação:

o sistema deve conseguir recuperar o estado.

Evitar operações parcialmente concluídas.

---

# 64. DOCUMENTAÇÃO

Criar README.md explicando:

* instalação;
* dependências;
* SQL;
* configuração;
* comandos;
* exports;
* eventos;
* permissões;
* troubleshooting;
* performance;
* estrutura do projeto.

---

# 65. DESENVOLVIMENTO EM ETAPAS

NÃO tente gerar todo o projeto em uma única resposta.

Divida a implementação em fases.

FASE 1:

Arquitetura

Banco de dados

Ranch

Proprietário

Permissões

Persistência

FASE 2:

Animais

Spawn

Necessidades

Alimentação

Água

FASE 3:

Reprodução

Genética

Doenças

Veterinário

FASE 4:

Agricultura

Plantações

Crescimento

Colheita

Clima

FASE 5:

Produção

Açougue

Processamento

Estoque

FASE 6:

Economia

Mercado

Preços

Contratos

Transporte

FASE 7:

Funcionários

NPCs

Jogadores

Salários

FASE 8:

Eventos

Roubo

Incêndio

Doenças

Pragas

FASE 9:

Cavalos

Gado

Pastoreio

FASE 10:

Otimização

Segurança

Logs

Testes

---

# 66. REGRA DE IMPLEMENTAÇÃO

Ao implementar cada fase:

1. explique a arquitetura;
2. mostre os arquivos que serão criados;
3. gere o código completo dos arquivos;
4. não gere pseudocódigo;
5. não utilize `-- TODO` no lugar de implementação;
6. não omita funções importantes;
7. mantenha compatibilidade com o código das fases anteriores;
8. informe dependências;
9. informe como instalar;
10. informe como testar.

Se uma função ainda não estiver implementada, não finja que está pronta.

---

# 67. REGRA SOBRE CÓDIGO

O código deve ser:

* organizado;
* legível;
* comentado quando necessário;
* modular;
* seguro;
* performático;
* preparado para produção.

Não criar código propositalmente simplificado apenas para caber na resposta.

Se o código for grande, divida em múltiplas respostas mantendo exatamente a mesma arquitetura.

---

# 68. REGRA SOBRE REDM

Sempre que precisar implementar uma funcionalidade específica do RedM:

* verificar qual native/API realmente existe;
* não inventar natives;
* não inventar exports;
* não inventar eventos do VORP;
* não assumir que uma função existe.

Se houver dúvida sobre uma API, deixe explícito que precisa ser confirmada e utilize uma abordagem compatível/conservadora.

---

# 69. VORP

Utilizar o VORP de forma correta.

Não criar um sistema paralelo de personagem/dinheiro/inventário quando o VORP já fornecer isso.

O sistema deve poder utilizar:

* character identifier;
* dinheiro;
* job;
* inventory;
* notifications;
* callbacks;
* etc.

conforme a versão instalada do servidor.

---

# 70. OX_LIB

Utilizar ox_lib quando apropriado para:

* menus;
* context;
* input;
* progress;
* notifications;
* callbacks;
* zones;
* dialogs.

---

# 71. MYSQL

Utilizar oxmysql corretamente.

Preferir queries preparadas.

Evitar SQL montado por concatenação.

Criar índices adequados.

---

# 72. EXPLORAÇÃO DO RED DEAD REDEMPTION 2

Quero que você pense além de um sistema genérico de fazenda.

Analise como aproveitar:

* cavalos;
* gado;
* animais selvagens;
* carroças;
* clima;
* ciclo dia/noite;
* NPCs;
* estradas;
* estações;
* cidades;
* trem;
* água;
* pastagens;
* caça;
* pesca;
* armas;
* ferramentas;
* mundo aberto.

Sempre respeitando as limitações reais do RedM.

---

# 73. EXPERIÊNCIA DO JOGADOR

Um jogador deve conseguir começar pequeno.

Exemplo:

$2.000

Compra:

* pequena propriedade;
* 2 vacas;
* 5 galinhas;
* algumas sementes.

Depois evolui.

$10.000:

* mais animais;
* funcionários;
* novas plantações.

$50.000:

* grande propriedade;
* produção;
* contratos.

$100.000+:

* empresa rural;
* múltiplos funcionários;
* comércio regional;
* exportação.

---

# 74. NÃO CRIAR PAY-TO-WIN

A progressão deve acontecer dentro do gameplay.

---

# 75. RESULTADO FINAL

Quero que o sistema tenha potencial para se tornar uma das principais atividades econômicas do servidor.

O jogador deve sentir que:

"Eu realmente tenho um rancho."

e não:

"Eu tenho um menu que gera dinheiro."

---

# 76. PRIMEIRA TAREFA

Antes de escrever qualquer código:

1. analise toda esta especificação;
2. proponha a arquitetura final;
3. proponha o modelo completo do banco de dados;
4. proponha o fluxo de gameplay;
5. identifique dependências;
6. identifique possíveis problemas de performance;
7. identifique riscos de exploit;
8. proponha a estrutura de arquivos;
9. proponha o sistema de simulação offline;
10. proponha o sistema de sincronização de entidades;
11. proponha a estratégia de spawn/despawn;
12. proponha a estratégia de cache;
13. proponha as APIs/exports;
14. proponha a divisão em fases.

NÃO escreva ainda o código completo.

Primeiro entregue a arquitetura técnica.

Depois que eu aprovar a arquitetura, começaremos pela FASE 1.

Durante todo o desenvolvimento, preserve compatibilidade entre as fases.

Não reescreva partes anteriormente implementadas sem necessidade.

O objetivo é produzir um recurso RedM de qualidade de produção, e não apenas uma demonstração.

---

# IMPLEMENTAÇÃO — FASE 1 (em andamento)

## Escopo entregue

A primeira fase cria a fundação persistente do resource `rural_system`:

* manifest e carregamento ordenado de `ox_lib`, `oxmysql` e `vorp_core`;
* catálogo configurável de propriedades iniciais;
* compra presencial de propriedade por ponto de mundo;
* tabelas de ranchos, membros, permissões por cargo, arrendamento, razão financeira, transações e auditoria;
* cargos `OWNER`, `MANAGER`, `WORKER`, `VETERINARIAN`, `FARMER` e `RANCH_HAND`;
* caixa de rancho com depósito/retirada server-authoritative;
* serviços e exports de consulta, autorização e crédito controlado;
* limitação de chamadas, validação de distância e trilha de auditoria.

## Instalação da Fase 1

1. Instale/inicie `oxmysql`, `ox_lib` e `vorp_core` antes de `rural_system` no `server.cfg`.
2. Importe `sql/install.sql` no banco MariaDB/MySQL do servidor.
3. Copie a pasta para os resources e adicione `ensure rural_system` após as dependências.
4. Ajuste preços e coordenadas em `config/ranches.lua` para o mapa e a economia do servidor.
5. Confirme a API da versão instalada do VORP. O adaptador utiliza `Core.getUser(source)`, `getUsedCharacter`, `removeCurrency` e `addCurrency`; se sua versão divergir, altere somente `server/adapters/vorp.lua`.

## Uso da Fase 1

Vá a uma placa configurada em `Config.RanchListings`, pressione **E** e confirme a compra. A compra valida posição, saldo VORP, limite de propriedades e disponibilidade da listagem no servidor.

## Exports de servidor

* `exports.rural_system:GetRanch(ranchId)`
* `exports.rural_system:GetPlayerRanches(characterId)`
* `exports.rural_system:GetPlayerRanch(characterId[, ranchId])`
* `exports.rural_system:HasRanchPermission(characterId, ranchId, permission)`
* `exports.rural_system:AddRanchMoney(ranchId, amount, reason[, actorCharacterId])`

## Limitações deliberadas da fase

Animais, construções, inventário, colheitas, produção, contratos e empregados ainda não existem nesta fase; eles serão adicionados nas fases posteriores sem modificar o contrato de propriedade, RBAC e razão financeira. A gestão completa de sócios/arrendamentos já possui serviços de servidor, mas sua interface física administrativa será acrescentada junto ao dashboard administrativo.

---

# IMPLEMENTAÇÃO — FASE 2 (em andamento)

## Escopo entregue

* catálogo extensível de nove espécies e raças iniciais, com modelos e consumo por intervalo;
* persistência individual de animais, pastos, fonte de água, estoque de cuidados e histórico de manejo;
* criação automática do pasto, bebedouro, suprimentos e animais iniciais ao comprar uma propriedade configurada;
* alimentação no cocho e reabastecimento no bebedouro como ações físicas no mundo, autorizadas e calculadas no servidor;
* necessidades de fome, sede, saúde, felicidade e estresse simuladas em intervalos de quinze minutos, inclusive por tempo decorrido;
* streaming visual de animais limitado por distância e quantidade, com despawn quando o jogador deixa o pasto;
* exports `GetRanchAnimals` e `AddRanchAnimal`.

## Operação

Após adquirir uma propriedade, visite o curral. No cocho, pressione **E** para alimentar todos os animais com feno armazenado no estoque do rancho; no bebedouro, pressione **E** para distribuir água. Ambas as ações verificam personagem, cargo, distância, rancho, quantidade de animais e saldo de suprimento no servidor.

O servidor executa a simulação em lotes de quinze minutos. Animais sem cuidados acumulam fome e sede, perdem felicidade/saúde e podem morrer; superlotação agrava estresse e perda de saúde. Não há loop por frame nem consulta contínua de todos os animais.

## Limites técnicos conhecidos

O streaming visual desta fase cria peds **locais e não autoritativos** apenas como representação dos registros persistidos. Saúde, posição persistente, inventário e qualquer resultado econômico continuam no servidor. A sincronização de peds networked/OneSync e comportamento de pastoreio coletivo será endurecida na Fase 9 depois de confirmar os natives e o modelo de ownership do artifact RedM instalado no servidor.

---

# IMPLEMENTAÇÃO — FASE 3 (em andamento)

## Escopo entregue

* configurações de gestação, critérios de reprodução, mutação genética limitada e doenças tratáveis;
* tabelas persistentes de diagnósticos/tratamentos e de concepção/nascimento;
* seleção de matrizes e reprodutores saudáveis no mesmo pasto, com gestação baseada em espécie;
* herança por média genética dos pais com variação determinística limitada, evitando resultados puramente aleatórios;
* nascimento persistente, logado e publicado pelo evento interno `rural:animalBorn`;
* doenças por desidratação, desnutrição, condições respiratórias e parasitas, agravadas pela simulação;
* posto veterinário físico com livro de atendimento, diagnóstico e tratamento que consome medicamento do estoque do rancho;
* export `GetAnimalDiseases(animalId)`.

## Permissões

O cargo `VETERINARIAN` já possui `animals.veterinary`. Proprietários mantêm acesso total; outros cargos só podem diagnosticar/tratar caso recebam a permissão no papel da propriedade. Todo atendimento valida a posição do jogador, associação ao rancho e doença ativa no servidor.
