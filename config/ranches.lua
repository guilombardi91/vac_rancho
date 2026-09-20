Config.RanchTypes = {
    ranch = { label = 'Rancho' },
    farm = { label = 'Fazenda' },
    homestead = { label = 'Homestead' },
    horse_ranch = { label = 'Haras' },
    cattle_ranch = { label = 'Rancho de gado' },
    livestock_farm = { label = 'Fazenda de criação' },
    mixed = { label = 'Propriedade mista' },
}

-- Catálogo inicial. A Fase 5 permitirá expansão construtiva dentro desses lotes.
Config.RanchListings = {
    {
        key = 'valentine_starter', label = 'Pequena Propriedade de Valentine', type = 'mixed',
        price = 2000.00, region = 'valentine', x = -238.52, y = 672.44, z = 113.10, heading = 90.0,
        pasture = { x = -227.12, y = 674.20, z = 113.20, radius = 24.0, capacity = 8 },
        water = { x = -231.50, y = 669.10, z = 113.10, capacity = 500.0 },
    },
    {
        key = 'heartlands_cattle', label = 'Curral das Heartlands', type = 'cattle_ranch',
        price = 10000.00, region = 'heartlands', x = -158.40, y = 624.32, z = 113.18, heading = 150.0,
        pasture = { x = -149.80, y = 630.40, z = 113.20, radius = 40.0, capacity = 30 },
        water = { x = -154.20, y = 620.20, z = 113.10, capacity = 1500.0 },
    },
}
