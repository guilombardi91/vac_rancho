RuralVorp = {}

local Core

local function getCore()
    if Core then return Core end
    local resourceState = GetResourceState('vorp_core')
    if resourceState ~= 'started' then return nil, 'vorp_core não está iniciado' end
    Core = exports.vorp_core:GetCore()
    if type(Core) ~= 'table' then return nil, 'vorp_core não retornou um Core válido' end
    return Core
end

function RuralVorp.getCharacter(source)
    local vorp, err = getCore()
    if not vorp then return nil, err end
    if type(vorp.getUser) ~= 'function' then return nil, 'API Core.getUser indisponível' end
    local user = vorp.getUser(source)
    if not user then return nil, 'Usuário VORP indisponível' end
    local character = user.getUsedCharacter
    if type(character) == 'function' then character = character() end
    if type(character) ~= 'table' then return nil, 'Personagem VORP inválido' end
    local identifier = character.charIdentifier or character.identifier
    if not identifier then return nil, 'Identificador do personagem VORP indisponível' end
    return { id = tostring(identifier), firstName = character.firstname or character.firstName or 'Desconhecido', lastName = character.lastname or character.lastName or '' }, character
end

function RuralVorp.getCash(source)
    local _, character = RuralVorp.getCharacter(source)
    if not character then return nil, 'Personagem indisponível' end
    if type(character.money) == 'number' then return character.money end
    if type(character.getCurrency) == 'function' then return character.getCurrency(Config.CurrencyType) end
    return nil, 'API de leitura de dinheiro não suportada pela versão VORP instalada'
end

function RuralVorp.removeCash(source, amount)
    local _, character = RuralVorp.getCharacter(source)
    if not character then return false, 'Personagem indisponível' end
    if type(character.removeCurrency) ~= 'function' then return false, 'API removeCurrency do VORP indisponível' end
    character.removeCurrency(Config.CurrencyType, amount)
    return true
end

function RuralVorp.addCash(source, amount)
    local _, character = RuralVorp.getCharacter(source)
    if not character then return false, 'Personagem indisponível' end
    if type(character.addCurrency) ~= 'function' then return false, 'API addCurrency do VORP indisponível' end
    character.addCurrency(Config.CurrencyType, amount)
    return true
end

function RuralVorp.notify(source, description, notifyType)
    TriggerClientEvent('ox_lib:notify', source, { description = description, type = notifyType or 'inform' })
end
