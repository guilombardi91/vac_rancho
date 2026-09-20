Config = Config or {}

Config.Debug = false
Config.Locale = 'pt-br'
Config.CurrencyType = 0 -- VORP: 0 = dinheiro em espécie.
Config.MaxRanchesPerCharacter = 2
Config.ActionDistance = 3.0
Config.RanchCacheTtlSeconds = 300
Config.Security = {
    maxRequestsPerWindow = 12,
    windowSeconds = 10,
}

Config.Commands = {
    dashboard = 'rancho',
}
