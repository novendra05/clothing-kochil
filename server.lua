-- Mapping Gambar Default berdasarkan Tipe (Pakaian aslinya)
local itemIcons = {
    ['jacket'] = 'shirt',
    ['pants'] = 'pants',
    ['shoes'] = 'shoes',
    ['hat'] = 'hat',
    ['mask'] = 'mask',
    ['bag'] = 'bag',
    ['vest'] = 'vest',
    ['chain'] = 'chain',
    ['glasses'] = 'glasses',
    ['watch'] = 'watch',
}

-- Event: Kemas Baju menjadi Item
RegisterNetEvent('qbx_clothing_items:server:packageItem', function(data)
    local src = source
    
    -- Tentukan gambar berdasarkan tipe, default ke 'shirt' jika tidak ada di map
    local defaultIcon = itemIcons[data.clothingType] or 'shirt'

    -- Rekonstruksi metadata
    local metadata = {
        type = data.type,
        clothingType = data.clothingType,
        id = data.id,
        label = data.label or 'Pakaian Kustom',
        drawable = data.drawable,
        texture = data.texture,
        arms = data.arms,
        armsTexture = data.armsTexture,
        description = 'Tipe: ' .. (data.clothingType or 'pakaian'),
        image = data.imageurl and nil or defaultIcon,
        imageurl = data.imageurl
    }
    
    -- Panggil AddItem
    local success, response = exports.ox_inventory:AddItem(src, 'apparel_packaged', 1, metadata)
    
    if success then
        local slot = type(response) == 'table' and response.slot or 'N/A'
        print('^2[qbx_clothing_items] SUCCESS: Item apparel_packaged diberikan ke ID ' .. src .. '^7')
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Item Diterima',
            description = 'Berhasil mengemas: ' .. metadata.label,
            type = 'success'
        })
    end
end)

-- Hook: Deteksi saat item dibuang/dipindah (Anti-Ghosting)
-- Hook 'swapItems' dipanggil saat item pindah slot, pindah inventory, atau dibuang
exports.ox_inventory:registerHook('swapItems', function(payload)
    -- Jika item 'apparel_packaged' pindah dari inventory PLAYER ke tempat lain (bukan ke slot lain dalam inventory yang sama)
    if payload.fromType == 'player' and (payload.toType ~= 'player' or payload.fromInventory ~= payload.toInventory) then
        local src = payload.source
        local itemMetadata = payload.fromSlot.metadata
        
        -- Beritahu client untuk melepas baju jika sedang dipakai
        TriggerClientEvent('qbx_clothing_items:client:checkRemoval', src, itemMetadata)
    end
    
    return true
end, {
    itemFilter = {
        ['apparel_packaged'] = true
    }
})
