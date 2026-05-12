// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PesantrenBudget
 * @notice Smart contract untuk sistem keuangan transparan pesantren
 * @dev Deploy ke Polygon Amoy Testnet via Remix IDE
 *
 * CARA DEPLOY:
 * 1. Buka https://remix.ethereum.org
 * 2. Buat file baru: PesantrenBudget.sol
 * 3. Paste seluruh kode ini
 * 4. Compile: Solidity 0.8.20
 * 5. Deploy: Environment = Injected Provider (MetaMask)
 * 6. Pastikan MetaMask di Polygon Amoy Testnet (Chain ID: 80002)
 * 7. Copy contract address yang muncul setelah deploy
 */

contract PesantrenBudget {

    // ============================================
    // STRUCTS
    // ============================================

    struct BudgetBulanan {
        uint256 bulan;              // format: YYYYMM (contoh: 202605)
        string  namaPesantren;      // nama pesantren

        // Rincian biaya (dalam Wei/Rupiah tergantung implementasi)
        uint256 biayaPendidik;      // gaji ustaz, guru
        uint256 biayaPengurus;      // gaji pengurus, musyrif
        uint256 biayaKonsumsi;      // makan 3x sehari
        uint256 biayaUtilitas;      // listrik, air, gas
        uint256 biayaPerlengkapan;  // ATK, buku, seragam
        uint256 biayaLainnya;       // kegiatan, kesehatan, lain-lain

        // Kalkulasi
        uint256 totalBiaya;         // subtotal semua komponen
        uint256 reserveFund;        // dana cadangan (pct dari total)
        uint256 grandTotal;         // total + reserve
        uint256 jumlahSantri;       // santri aktif bulan ini
        uint256 sppPerSantri;       // grandTotal / jumlahSantri
        uint256 capSPP;             // batas maksimal SPP
        uint256 reservePct;         // persentase reserve (contoh: 7 = 7%)

        // Metadata
        bool    overCap;            // apakah SPP melebihi cap
        uint256 timestamp;          // waktu pencatatan
        address adminAddress;       // siapa yang input
    }

    // ============================================
    // STATE VARIABLES
    // ============================================

    address public owner;
    address public admin;

    // Data utama: bulan => budget
    mapping(uint256 => BudgetBulanan) public budgets;

    // Daftar semua bulan yang pernah diinput
    uint256[] public allMonths;

    // Nama pesantren
    string public namaPesantren;

    // ============================================
    // EVENTS
    // ============================================

    // Dipancarkan setiap kali budget baru disimpan
    event BudgetInputted(
        uint256 indexed bulan,
        uint256 sppPerSantri,
        uint256 jumlahSantri,
        uint256 grandTotal,
        bool overCap,
        address admin,
        uint256 timestamp
    );

    // Dipancarkan saat admin diganti
    event AdminChanged(address oldAdmin, address newAdmin);

    // ============================================
    // MODIFIERS
    // ============================================

    modifier onlyOwner() {
        require(msg.sender == owner, "Hanya owner yang bisa memanggil fungsi ini");
        _;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin || msg.sender == owner,
            "Hanya admin pesantren yang bisa input data"
        );
        _;
    }

    modifier validBulan(uint256 bulan) {
        // Format YYYYMM: tahun 2020-2099, bulan 01-12
        uint256 tahun = bulan / 100;
        uint256 bln = bulan % 100;
        require(tahun >= 2020 && tahun <= 2099, "Tahun tidak valid");
        require(bln >= 1 && bln <= 12, "Bulan tidak valid (1-12)");
        _;
    }

    // ============================================
    // CONSTRUCTOR
    // ============================================

    constructor(string memory _namaPesantren, address _admin) {
        owner = msg.sender;
        admin = _admin;
        namaPesantren = _namaPesantren;
    }

    // ============================================
    // FUNGSI UTAMA (Write — hanya admin)
    // ============================================

    /**
     * @notice Input data biaya bulanan pesantren
     * @dev Hanya bisa dipanggil oleh admin atau owner
     * @param bulan Format YYYYMM (contoh: 202605 = Mei 2026)
     * @param biayaPendidik Total gaji tenaga pendidik (dalam satuan Rupiah)
     * @param biayaPengurus Total gaji pengurus pondok
     * @param biayaKonsumsi Total biaya konsumsi santri
     * @param biayaUtilitas Total biaya utilitas dan fasilitas
     * @param biayaPerlengkapan Total biaya perlengkapan belajar
     * @param biayaLainnya Total biaya kegiatan dan lain-lain
     * @param jumlahSantri Jumlah santri aktif bulan ini
     * @param capSPP Batas maksimal SPP per santri (dalam Rupiah)
     * @param reservePct Persentase reserve fund (contoh: 7 = 7%)
     */
    function inputBudget(
        uint256 bulan,
        string memory _namaPesantren,
        uint256 biayaPendidik,
        uint256 biayaPengurus,
        uint256 biayaKonsumsi,
        uint256 biayaUtilitas,
        uint256 biayaPerlengkapan,
        uint256 biayaLainnya,
        uint256 jumlahSantri,
        uint256 capSPP,
        uint256 reservePct
    ) external onlyAdmin validBulan(bulan) {
        require(jumlahSantri > 0, "Jumlah santri harus lebih dari 0");
        require(capSPP > 0, "Batas SPP harus lebih dari 0");
        require(reservePct <= 50, "Reserve fund maksimal 50%");

        // Hitung total
        uint256 totalBiaya = biayaPendidik
            + biayaPengurus
            + biayaKonsumsi
            + biayaUtilitas
            + biayaPerlengkapan
            + biayaLainnya;

        require(totalBiaya > 0, "Total biaya tidak boleh nol");

        uint256 reserveFund = (totalBiaya * reservePct) / 100;
        uint256 grandTotal = totalBiaya + reserveFund;
        uint256 sppPerSantri = grandTotal / jumlahSantri;
        bool overCap = sppPerSantri > capSPP;

        // Simpan ke storage
        // Jika bulan belum pernah diinput, tambahkan ke daftar
        if (budgets[bulan].timestamp == 0) {
            allMonths.push(bulan);
        }

        budgets[bulan] = BudgetBulanan({
            bulan: bulan,
            namaPesantren: bytes(_namaPesantren).length > 0 ? _namaPesantren : namaPesantren,
            biayaPendidik: biayaPendidik,
            biayaPengurus: biayaPengurus,
            biayaKonsumsi: biayaKonsumsi,
            biayaUtilitas: biayaUtilitas,
            biayaPerlengkapan: biayaPerlengkapan,
            biayaLainnya: biayaLainnya,
            totalBiaya: totalBiaya,
            reserveFund: reserveFund,
            grandTotal: grandTotal,
            jumlahSantri: jumlahSantri,
            sppPerSantri: sppPerSantri,
            capSPP: capSPP,
            reservePct: reservePct,
            overCap: overCap,
            timestamp: block.timestamp,
            adminAddress: msg.sender
        });

        // Emit event — tersimpan di blockchain log, bisa di-filter kapanpun
        emit BudgetInputted(
            bulan,
            sppPerSantri,
            jumlahSantri,
            grandTotal,
            overCap,
            msg.sender,
            block.timestamp
        );
    }

    // ============================================
    // FUNGSI BACA (View — siapapun bisa akses)
    // ============================================

    /**
     * @notice Ambil data budget bulan tertentu
     * @param bulan Format YYYYMM
     */
    function getBudgetByMonth(uint256 bulan)
        external view returns (BudgetBulanan memory)
    {
        require(budgets[bulan].timestamp > 0, "Data bulan ini belum ada");
        return budgets[bulan];
    }

    /**
     * @notice Ambil nilai SPP per santri untuk bulan tertentu
     * @param bulan Format YYYYMM
     */
    function getSPPPerSantri(uint256 bulan)
        external view returns (uint256)
    {
        require(budgets[bulan].timestamp > 0, "Data bulan ini belum ada");
        return budgets[bulan].sppPerSantri;
    }

    /**
     * @notice Ambil semua data budget semua bulan
     * @dev Digunakan untuk dashboard publik
     */
    function getAllRecords()
        external view returns (BudgetBulanan[] memory)
    {
        BudgetBulanan[] memory result = new BudgetBulanan[](allMonths.length);
        for (uint256 i = 0; i < allMonths.length; i++) {
            result[i] = budgets[allMonths[i]];
        }
        return result;
    }

    /**
     * @notice Ambil jumlah total bulan yang sudah diinput
     */
    function getTotalMonths() external view returns (uint256) {
        return allMonths.length;
    }

    /**
     * @notice Ambil daftar semua bulan yang sudah ada datanya
     */
    function getAllMonths() external view returns (uint256[] memory) {
        return allMonths;
    }

    /**
     * @notice Cek apakah data bulan tertentu sudah ada
     */
    function isBudgetExist(uint256 bulan) external view returns (bool) {
        return budgets[bulan].timestamp > 0;
    }

    // ============================================
    // FUNGSI ADMIN (hanya owner)
    // ============================================

    /**
     * @notice Ganti alamat admin pesantren
     * @param newAdmin Alamat wallet admin baru
     */
    function changeAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "Alamat tidak valid");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    /**
     * @notice Update nama pesantren
     */
    function updateNamaPesantren(string memory _nama) external onlyOwner {
        namaPesantren = _nama;
    }
}
