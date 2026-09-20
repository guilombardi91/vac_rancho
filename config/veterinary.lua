Config.Veterinary = {
    diagnosisDistance = 3.0,
    treatmentItem = 'medicine_basic',
    starterMedicine = 8.0,
    maxDiagnosesPerMinute = 10,
    diseases = {
        dehydration = { label = 'Desidratação', baseChance = 0.00, thirstThreshold = 78, healthLossPerInterval = 2.2, treatmentHealth = 16, treatmentThirst = 35 },
        malnutrition = { label = 'Desnutrição', baseChance = 0.00, hungerThreshold = 78, healthLossPerInterval = 1.8, treatmentHealth = 14, treatmentHunger = 35 },
        respiratory = { label = 'Doença respiratória', baseChance = 0.012, healthLossPerInterval = 1.2, treatmentHealth = 18 },
        parasites = { label = 'Parasitas', baseChance = 0.008, healthLossPerInterval = 0.9, treatmentHealth = 12 },
    },
}

Config.Breeding = {
    checkIntervalSeconds = 3600,
    mutationRange = 6,
    minimumHealth = 65,
    minimumHappiness = 55,
    speciesPairs = {
        cow = { maleSpecies = 'bull', gestationDays = 283, offspringFemaleSpecies = 'cow', offspringMaleSpecies = 'bull' },
        horse = { maleSpecies = 'horse', gestationDays = 340, offspringFemaleSpecies = 'horse', offspringMaleSpecies = 'horse' },
        pig = { maleSpecies = 'pig', gestationDays = 114, offspringFemaleSpecies = 'pig', offspringMaleSpecies = 'pig' },
        sheep = { maleSpecies = 'sheep', gestationDays = 152, offspringFemaleSpecies = 'sheep', offspringMaleSpecies = 'sheep' },
        goat = { maleSpecies = 'goat', gestationDays = 150, offspringFemaleSpecies = 'goat', offspringMaleSpecies = 'goat' },
    },
}
