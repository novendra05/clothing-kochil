# qbx_clothing_items - Dynamic Clothing System 👕

Sistem pakaian dinamis untuk FiveM menggunakan **Qbox Framework** yang memungkinkan pemain untuk mengemas pakaian yang mereka pakai menjadi item inventory yang bisa dipindah-tangan atau disimpan.

## ✨ Fitur Utama
- **Kemasan Pakaian**: Ubah jaket, celana, sepatu, topi, tas, dll menjadi item inventory.
- **Ikon Dinamis**: Ikon item otomatis menyesuaikan tipe pakaian (Pants, Shirt, Shoes, dll).
- **Custom Gambar URL**: Pemain bisa memberikan link gambar kustom (URL) saat mengemas pakaian.
- **Anti-Ghosting**: Pakaian di badan akan otomatis terlepas jika itemnya keluar dari inventory (didrop atau diberikan ke orang lain).
- **Persistence**: Tampilan pakaian otomatis tersimpan ke database karakter.

## 📦 Kebutuhan (Dependencies)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [illenium-appearance](https://github.com/iLLeniumStudios/illenium-appearance)
- [ox_lib](https://github.com/overextended/ox_lib)

## 🛠️ Instalasi

### 1. Registrasi Item
Tambahkan item berikut ke dalam file `ox_inventory/data/items.lua`:

```lua
['apparel_packaged'] = {
    label = 'Pakaian Kemasan',
    weight = 500,
    stack = false,
    close = true,
    client = {
        anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
        usetime = 2000,
        export = 'qbx_clothing_items.useClothingItem'
    }
},
```

### 2. Copy Resources
1. Download atau Clone repositori ini.
2. Masukkan folder `qbx_clothing_items` ke dalam folder resources server Anda (biasanya di `resources/[standalone]`).
3. Pastikan folder bernama `qbx_clothing_items`.

### 3. Server Config
Tambahkan baris berikut di `server.cfg` Anda setelah dependensi di atas:
```cfg
ensure qbx_clothing_items
```

## 🎮 Cara Penggunaan

Gunakan perintah `/packageclothing` untuk mengemas baju yang sedang Anda pakai.

**Format Perintah:**
```
/packageclothing [tipe] [label] [url_gambar_opsional]
```

**Contoh:**
- `/packageclothing jacket "Jas Biru"` (Pakai ikon jaket bawaan)
- `/packageclothing pants "Celana Jeans" "https://link-ke-gambar.png"` (Pakai gambar kustom)

**Tipe yang didukung:**
`jacket`, `pants`, `shoes`, `mask`, `hat`, `bag`, `vest`, `chain`, `glasses`, `watch`, `ear`, `brace`.

## 📜 Lisensi
Dibuat untuk keperluan server komunitas. Silakan dimodifikasi sesuai kebutuhan.
