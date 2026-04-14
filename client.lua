print('^2[qbx_clothing_items] Loading Dynamic Clothing System...^7')

-- Mapping Command Type ke ID Komponen/Prop
local componentMap = {
    ['mask']     = { id = 1,  type = 'component' },
    ['arms']     = { id = 3,  type = 'component' },
    ['pants']    = { id = 4,  type = 'component' },
    ['bag']      = { id = 5,  type = 'component' },
    ['shoes']    = { id = 6,  type = 'component' },
    ['chain']    = { id = 7,  type = 'component' },
    ['shirt']    = { id = 8,  type = 'component' },
    ['vest']     = { id = 9,  type = 'component' },
    ['jacket']   = { id = 11, type = 'component' },
    ['hat']      = { id = 0,  type = 'prop' },
    ['glasses']  = { id = 1,  type = 'prop' },
    ['ear']      = { id = 2,  type = 'prop' },
    ['watch']    = { id = 6,  type = 'prop' },
    ['brace']    = { id = 7,  type = 'prop' },
}

-- Default Naked/Base IDs
local nakedDefaults = {
    male = {
        components = {
            [1] = 0, [3] = 15, [4] = 21, [5] = 0, [6] = 34, [7] = 0, [8] = 15, [9] = 0, [11] = 15
        },
        props = {
            [0] = -1, [1] = -1, [2] = -1, [6] = -1, [7] = -1
        }
    },
    female = {
        components = {
            [1] = 0, [3] = 15, [4] = 15, [5] = 0, [6] = 35, [7] = 0, [8] = 15, [9] = 0, [11] = 15
        },
        props = {
            [0] = -1, [1] = -1, [2] = -1, [6] = -1, [7] = -1
        }
    }
}

-- Helper: Deteksi Gender
local function getGender()
    local model = GetEntityModel(cache.ped)
    return model == `mp_f_freemode_01` and 'female' or 'male'
end

-- Export: Gunakan Item Pakaian (Metadata Based)
-- Argumen 1 (item): Definisi item dari items.lua
-- Argumen 2 (info): Data spesifik item di slot tersebut (termasuk metadata)
exports('useClothingItem', function(item, info)
    local metadata = info.metadata
    
    -- Debugging: Muncul di F8 jika masih bermasalah
    if not metadata or not metadata.id then
        print('^1[qbx_clothing_items] ERROR: Metadata tidak ditemukan di argumen kedua!^7')
        print('^3Isi Argumen 1: ' .. json.encode(item) .. '^7')
        print('^3Isi Argumen 2: ' .. json.encode(info) .. '^7')
        return lib.notify({ title = 'Error', description = 'Item ini tidak memiliki data pakaian!', type = 'error' })
    end

    local ped = cache.ped
    local gender = getGender()

    if lib.progressBar({
        duration = 2000,
        label = 'Memakai ' .. (metadata.label or 'Pakaian') .. '...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, mouse = false },
        anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' }
    }) then
        if metadata.type == 'component' then
            exports['illenium-appearance']:setPedComponent(ped, {
                component_id = metadata.id,
                drawable = metadata.drawable,
                texture = metadata.texture
            })
            -- Jika memakai jaket, sesuaikan lengan (Opsional: bisa diotomatisasi lebih lanjut)
            if metadata.id == 11 and metadata.arms then
                exports['illenium-appearance']:setPedComponent(ped, {
                    component_id = 3,
                    drawable = metadata.arms,
                    texture = metadata.armsTexture or 0
                })
            end
        else -- Prop
            exports['illenium-appearance']:setPedProp(ped, {
                prop_id = metadata.id,
                drawable = metadata.drawable,
                texture = metadata.texture
            })
        end

        -- Save Appearance
        local appearance = exports['illenium-appearance']:getPedAppearance(ped)
        TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
        
        lib.notify({ title = 'Berhasil', description = 'Pakaian berhasil digunakan.', type = 'success' })
    end
end)

-- Command: /packageclothing [type] [label]
-- Contoh: /packageclothing jacket "Jas Biru Keren"
RegisterCommand('packageclothing', function(source, args)
    local typeName = args[1] and args[1]:lower()
    local label = args[2] or 'Pakaian Kustom'
    local imageUrl = args[3] -- Argumen ketiga bisa berupa URL gambar
    
    local config = componentMap[typeName]
    if not config then
        return lib.notify({ 
            title = 'Error', 
            description = 'Tipe tidak valid! Gunakan: jacket, pants, shoes, hat, dll.', 
            type = 'error' 
        })
    end

    local ped = cache.ped
    local gender = getGender()
    local metadata = {
        type = config.type,
        clothingType = typeName, -- Simpan tipe aslinya (jacket, pants, dll)
        id = config.id,
        label = label,
        imageurl = imageUrl -- Kirim URL jika ada
    }

    if config.type == 'component' then
        metadata.drawable = GetPedDrawableVariation(ped, config.id)
        metadata.texture = GetPedTextureVariation(ped, config.id)
        
        -- Cek jika ini jaket (11), ambil data lengan (3) juga
        if config.id == 11 then
            metadata.arms = GetPedDrawableVariation(ped, 3)
            metadata.armsTexture = GetPedTextureVariation(ped, 3)
        end
        
        -- Reset ke Naked
        exports['illenium-appearance']:setPedComponent(ped, {
            component_id = config.id,
            drawable = nakedDefaults[gender].components[config.id],
            texture = 0
        })
        if config.id == 11 then
             exports['illenium-appearance']:setPedComponent(ped, {
                component_id = 3,
                drawable = nakedDefaults[gender].components[3],
                texture = 0
            })
        end
    else
        metadata.drawable = GetPedPropIndex(ped, config.id)
        metadata.texture = GetPedPropTextureIndex(ped, config.id)
        
        -- Reset Prop
        exports['illenium-appearance']:setPedProp(ped, {
            prop_id = config.id,
            drawable = -1,
            texture = 0
        })
    end

    -- Kirim ke Server untuk memberikan Item
    TriggerServerEvent('qbx_clothing_items:server:packageItem', metadata)
    
    -- Save Appearance
    local appearance = exports['illenium-appearance']:getPedAppearance(ped)
    TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
    
    lib.notify({ title = 'Berhasil', description = 'Pakaian telah dikemas menjadi item.', type = 'success' })
end)

-- Event: Cek Pelepasan Jika Item Hilang (Anti-Ghosting)
RegisterNetEvent('qbx_clothing_items:client:checkRemoval', function(itemMetadata)
    local ped = cache.ped
    local currentDrawable, currentTexture
    local isEquipped = false
    local gender = getGender()

    if itemMetadata.type == 'component' then
        currentDrawable = GetPedDrawableVariation(ped, itemMetadata.id)
        currentTexture = GetPedTextureVariation(ped, itemMetadata.id)
        
        -- Cek apakah yang sedang dipakai sama dengan yang di-drop
        if currentDrawable == itemMetadata.drawable and currentTexture == itemMetadata.texture then
            isEquipped = true
            -- Melepas Baju (Set ke Naked/Nude)
            exports['illenium-appearance']:setPedComponent(ped, {
                component_id = itemMetadata.id,
                drawable = nakedDefaults[gender].components[itemMetadata.id] or 15,
                texture = 0
            })
            -- Jika itu jaket (11), lepas juga lengannya (3)
            if itemMetadata.id == 11 then
                exports['illenium-appearance']:setPedComponent(ped, {
                    component_id = 3,
                    drawable = nakedDefaults[gender].components[3] or 15,
                    texture = 0
                })
            end
        end
    else -- Prop
        currentDrawable = GetPedPropIndex(ped, itemMetadata.id)
        currentTexture = GetPedPropTextureIndex(ped, itemMetadata.id)
        
        if currentDrawable == itemMetadata.drawable and currentTexture == itemMetadata.texture then
            isEquipped = true
            -- Melepas Prop
            exports['illenium-appearance']:setPedProp(ped, {
                prop_id = itemMetadata.id,
                drawable = -1,
                texture = 0
            })
        end
    end

    -- Jika terdeteksi sedang dipakai, simpan appearance terbaru
    if isEquipped then
        local appearance = exports['illenium-appearance']:getPedAppearance(ped)
        TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
        lib.notify({
            title = 'Baju Terlepas',
            description = 'Pakaian Anda dilepas secara otomatis karena item tidak ada lagi di inventory.',
            type = 'warning'
        })
    end
end)

print('^2[qbx_clothing_items] Dynamic System Loaded!^7')

