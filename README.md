# Amanah Transparan
### Sistem Keuangan Pesantren Berbasis Blockchain

> *"Transparansi adalah Ibadah"*

Demo live: `https://[username].github.io/pesantren-transparan`

---

## Tentang Proyek

Sistem ini memungkinkan pesantren mencatat biaya bulanan secara transparan di blockchain, sehingga setiap wali santri bisa memverifikasi penggunaan dana secara real-time — tanpa perlu mempercayai laporan manual.

**Fitur Utama:**
- Biaya SPP dinamis (tidak flat) — dihitung dari biaya aktual bulan itu
- Batas maksimal SPP yang bisa diatur (agar orang tua bisa perencanaan)
- Setiap data tersimpan permanen di blockchain (tidak bisa diubah)
- Dashboard publik — siapapun bisa akses tanpa login
- Verifikasi via Polygon Explorer

---

## Struktur Proyek

```
pesantren-transparan/
├── frontend/
│   └── index.html          ← Aplikasi utama (upload ini ke GitHub Pages)
├── blockchain/
│   └── PesantrenBudget.sol ← Smart contract (deploy via Remix IDE)
├── .github/
│   └── workflows/
│       └── deploy.yml      ← Auto-deploy ke GitHub Pages
└── README.md
```

---

## Cara Deploy — Step by Step

### Langkah 1: Upload ke GitHub

1. Buka [github.com](https://github.com) → New Repository
2. Nama: `pesantren-transparan`
3. Centang "Add a README file"
4. Klik "Create repository"
5. Upload semua file dari folder ini

### Langkah 2: Aktifkan GitHub Pages

1. Masuk ke **Settings** → **Pages**
2. Source: **GitHub Actions**
3. Push ke branch `main` → otomatis deploy

Website akan live di: `https://[username].github.io/pesantren-transparan`

### Langkah 3: Deploy Smart Contract

1. Buka [remix.ethereum.org](https://remix.ethereum.org)
2. Buat file baru: `PesantrenBudget.sol`
3. Paste isi file `blockchain/PesantrenBudget.sol`
4. **Compile:** Pilih Solidity `0.8.20`, klik Compile
5. **Deploy:**
   - Environment: `Injected Provider - MetaMask`
   - Pastikan MetaMask di Polygon Amoy Testnet
   - Constructor params:
     - `_namaPesantren`: nama pesantren Anda
     - `_admin`: alamat wallet MetaMask Anda
   - Klik Deploy → konfirmasi di MetaMask
6. Copy **Contract Address** yang muncul

### Langkah 4: Hubungkan Frontend ke Contract

1. Buka aplikasi di browser
2. Masuk ke menu **Smart Contract**
3. Paste contract address di kolom yang tersedia
4. Klik **Simpan Address**

---

## Cara Pakai (Setelah Deploy)

### Admin / Bendahara

```
1. Buka website → Klik "Hubungkan Wallet"
2. Konfirmasi di MetaMask
3. Masuk ke "Input Biaya Bulanan"
4. Isi semua komponen biaya bulan ini
5. Klik "Simpan & Rekam On-Chain"
6. Konfirmasi transaksi di MetaMask
7. Selesai — data tercatat permanen di blockchain
```

### Wali Santri (Orang Tua)

```
1. Buka link website pesantren di HP
2. Tidak perlu login, tidak perlu install apapun
3. Lihat Dashboard → rincian biaya bulan ini
4. Klik TX Hash untuk verifikasi di Polygon Explorer
```

---

## Konfigurasi Polygon Amoy Testnet di MetaMask

| Parameter | Nilai |
|-----------|-------|
| Network Name | Polygon Amoy Testnet |
| RPC URL | https://rpc-amoy.polygon.technology |
| Chain ID | 80002 |
| Currency Symbol | MATIC |
| Block Explorer | https://amoy.polygonscan.com |

**Dapatkan MATIC Testnet gratis:** https://faucet.polygon.technology

---

## Teknologi

| Layer | Teknologi |
|-------|-----------|
| Frontend | HTML, CSS, JavaScript (vanilla) |
| Blockchain | Polygon Amoy Testnet |
| Smart Contract | Solidity 0.8.20 |
| Wallet | MetaMask + Ethers.js v6 |
| Hosting | GitHub Pages (gratis) |
| Explorer | PolygonScan |

---

## Roadmap

- [x] MVP Frontend (form input + dashboard + verifikasi)
- [x] Smart Contract dasar
- [x] GitHub Pages deployment
- [ ] Koneksi Ethers.js ke contract sungguhan
- [ ] WhatsApp Bot untuk notifikasi tagihan
- [ ] Mode offline + sinkronisasi
- [ ] Multi-pesantren support
- [ ] Audit laporan PDF otomatis

---

## Lisensi

MIT License — bebas digunakan dan dimodifikasi untuk kepentingan pesantren.

---

*Dibangun dengan semangat amanah dan transparansi untuk kemajuan pendidikan Islam Indonesia.*
