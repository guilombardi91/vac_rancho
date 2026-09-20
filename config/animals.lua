Config.Animals = {
    simulationIntervalSeconds = 900,
    maxCatchUpSeconds = 172800,
    streamingRadius = 90.0,
    streamingCheckMilliseconds = 5000,
    maxVisiblePerPasture = 20,
    starterSupplies = { hay = 100.0, water = 200.0, medicine_basic = 8.0 },
    feedAmountPerAnimal = 4.0,
    waterAmountPerAnimal = 8.0,
    initialAnimals = { valentine_starter = { { species = 'cow', breed = 'angus', sex = 'female', name = 'Margarida' }, { species = 'cow', breed = 'angus', sex = 'female', name = 'Estrela' } } },
}

Config.AnimalSpecies = {
    cow = { label = 'Vaca', model = 'a_c_cow', matureWeight = 480, foodPerInterval = 1.0, waterPerInterval = 2.0, growthDays = 730, allowedSexes = { 'female' } },
    bull = { label = 'Touro', model = 'a_c_bull_01', matureWeight = 750, foodPerInterval = 1.4, waterPerInterval = 2.8, growthDays = 730, allowedSexes = { 'male' } },
    horse = { label = 'Cavalo', model = 'a_c_horse_americanpaint_greyovero', matureWeight = 500, foodPerInterval = 1.1, waterPerInterval = 2.2, growthDays = 1095, allowedSexes = { 'male', 'female' } },
    pig = { label = 'Porco', model = 'a_c_pig_01', matureWeight = 220, foodPerInterval = 0.7, waterPerInterval = 1.2, growthDays = 365, allowedSexes = { 'male', 'female' } },
    sheep = { label = 'Ovelha', model = 'a_c_sheep_01', matureWeight = 85, foodPerInterval = 0.35, waterPerInterval = 0.7, growthDays = 365, allowedSexes = { 'female' } },
    goat = { label = 'Cabra', model = 'a_c_goat_01', matureWeight = 65, foodPerInterval = 0.3, waterPerInterval = 0.6, growthDays = 365, allowedSexes = { 'male', 'female' } },
    chicken = { label = 'Galinha', model = 'a_c_chicken_01', matureWeight = 3, foodPerInterval = 0.08, waterPerInterval = 0.15, growthDays = 180, allowedSexes = { 'female' } },
    rooster = { label = 'Galo', model = 'a_c_rooster_01', matureWeight = 4, foodPerInterval = 0.1, waterPerInterval = 0.16, growthDays = 180, allowedSexes = { 'male' } },
    dog = { label = 'Cão', model = 'a_c_dogamericanfoxhound_01', matureWeight = 30, foodPerInterval = 0.25, waterPerInterval = 0.45, growthDays = 365, allowedSexes = { 'male', 'female' } },
}

Config.AnimalBreeds = {
    angus = { species = 'cow', label = 'Angus', genetics = { meat = 95, milk = 40, growth = 80, endurance = 70 } },
    hereford = { species = 'cow', label = 'Hereford', genetics = { meat = 88, milk = 55, growth = 75, endurance = 72 } },
    texas_longhorn = { species = 'bull', label = 'Texas Longhorn', genetics = { meat = 80, milk = 35, growth = 65, endurance = 90 } },
}
