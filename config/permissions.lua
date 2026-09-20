Config.Permissions = {
    OWNER = {
        'ranch.view', 'ranch.manage', 'ranch.transfer', 'members.manage', 'finance.view',
        'finance.deposit', 'finance.withdraw', 'inventory.view', 'inventory.manage',
        'animals.view', 'animals.manage', 'buildings.view', 'buildings.manage',
    },
    MANAGER = {
        'ranch.view', 'members.manage', 'finance.view', 'finance.deposit', 'inventory.view',
        'inventory.manage', 'animals.view', 'animals.manage', 'buildings.view', 'buildings.manage',
    },
    WORKER = { 'ranch.view', 'inventory.view', 'animals.view', 'animals.manage' },
    VETERINARIAN = { 'ranch.view', 'animals.view', 'animals.veterinary' },
    FARMER = { 'ranch.view', 'inventory.view', 'crops.view', 'crops.manage' },
    RANCH_HAND = { 'ranch.view', 'inventory.view', 'animals.view', 'animals.feed' },
}
