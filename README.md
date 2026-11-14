# Panduan Kolaborasi Proyek

Dokumen ini berisi panduan untuk menyiapkan proyek, aturan kerja tim, dan workflow penggunaan Git selama pengembangan game. Seluruh anggota tim diharapkan mengikuti panduan ini agar proses pengembangan berjalan teratur dan mengurangi risiko konflik file.

GDD: https://docs.google.com/document/d/1wWwXl_P3cLciRPG97cUjV5jHKgy8mPFzaBPRXVG1ukI/edit?usp=sharing

## 1. Persiapan Proyek

### Prasyarat

Pastikan perangkat sudah memiliki:
- [Godot Engine 4.7.2](https://godotengine.org/download/)
- [Git](https://git-scm.com/downloads)
- Akun GitHub dengan akses ke repository.

### Clone Repository

Buka terminal, kemudian jalankan:

```bash
git clone https://github.com/wldn-087/gimersia-inspire-gamejam.git
```

Masuk ke direktori proyek:

```bash
cd gimersia-inspire-gamejam
```

### Membuka Proyek

1. Buka Godot Engine.
2. Pilih **Import** pada Project Manager.
3. Pilih file `project.godot` dari direktori repository.
4. Klik **Import & Edit** untuk membuka proyek.

## 2. Aturan Kolaborasi

Untuk menjaga konsistensi proyek dan menghindari konflik selama pengerjaan, seluruh anggota tim wajib memperhatikan aturan berikut.

### Aturan Umum

1. Selalu gunakan versi Godot yang telah ditentukan agar kompatibilitas proyek tetap terjaga.
2. Sebelum mulai bekerja, pastikan repository sudah diperbarui.
3. Kerjakan tugas sesuai pembagian dan tanggung jawab masing-masing.
4. Jangan mengubah file milik anggota lain tanpa koordinasi terlebih dahulu.
5. Hindari mengubah banyak bagian proyek yang tidak berkaitan dengan tugas.
6. Lakukan pengujian sebelum mengirim perubahan ke repository.

### Pengelolaan File

1. Simpan file sesuai kategori dan struktur folder yang telah tersedia.
2. Gunakan nama file yang jelas dan konsisten.
3. Jangan mengunggah file sementara, cache, atau hasil export yang tidak diperlukan.
4. Jangan menghapus atau memindahkan file yang digunakan oleh bagian lain tanpa koordinasi.
5. Jika membuat folder atau sistem baru, informasikan kepada anggota tim.

### Komunikasi Tim

1. Informasikan tugas yang sedang dikerjakan kepada anggota tim.
2. Koordinasikan perubahan pada file yang digunakan bersama.
3. Laporkan bug atau kendala yang ditemukan.
4. Diskusikan perubahan struktur proyek sebelum menerapkannya.

## 3. Git Workflow

Gunakan branch terpisah untuk setiap pekerjaan. Branch `main` digunakan sebagai branch utama yang berisi perubahan yang sudah siap digabungkan.

### Branch Convention

Gunakan format penamaan berikut:

| Prefix | Penggunaan | Contoh |
|---|---|---|
| `feat/` | Menambahkan fitur | `feat/player-movement` |
| `fix/` | Memperbaiki bug | `fix/animation-bug` |
| `refactor/` | Merapikan kode | `refactor/player-script` |
| `asset/` | Menambahkan atau memperbarui aset | `asset/player-sprites` |
| `docs/` | Memperbarui dokumentasi | `docs/readme` |

### Workflow Pengerjaan

**1. Perbarui branch utama**

Sebelum memulai pekerjaan, ambil perubahan terbaru:

```bash
git switch main
git pull origin main
```

**2. Buat branch baru**

Buat branch sesuai pekerjaan yang akan dilakukan:

```bash
git switch -c feat/nama-fitur
```

Note: Bisa pakai ini untuk membuat branch baru atau berpindah branch:

```bash
git checkout -b nama/branch
```

**3. Kerjakan perubahan**

Lakukan perubahan pada file yang berkaitan dengan tugas. Setelah selesai, periksa perubahan:

```bash
git status
git diff
```

**4. Simpan perubahan**

Tambahkan file yang ingin disimpan dan buat commit:

```bash
git add .
git commit -m "feat: add player movement"
```

**5. Kirim branch ke GitHub**

```bash
git push -u origin feat/nama-fitur
```

**6. Buat Pull Request**

1. Buka repository di GitHub.
2. Pilih branch yang sudah dikirim.
3. Buat Pull Request dengan target branch `main`.
4. Jelaskan perubahan yang dilakukan.
5. Tunggu pemeriksaan dan persetujuan sebelum merge.

### Memperbarui Branch Pekerjaan

Jika branch `main` memiliki perubahan terbaru selama kamu bekerja, sinkronkan branch pekerjaan:

```bash
git switch main
git pull origin main
git switch feat/nama-fitur
git merge main
```

Jika terjadi konflik, selesaikan konflik terlebih dahulu, kemudian lakukan pengujian sebelum melanjutkan.

### Aturan Git

- Jangan melakukan push langsung ke branch `main`.
- Gunakan branch terpisah untuk setiap pekerjaan.
- Hindari membuat satu commit yang mencakup banyak perubahan tidak berkaitan.
- Gunakan pesan commit yang menjelaskan perubahan.
- Jangan melakukan force push pada branch bersama tanpa koordinasi.
- Pastikan Pull Request sudah diperiksa sebelum di-merge.
- Hapus branch pekerjaan setelah berhasil di-merge jika sudah tidak diperlukan.

## 4. Standar Penulisan

Gunakan penamaan yang konsisten agar file dan kode mudah dipahami oleh seluruh anggota tim.

### Penamaan File dan Folder

Gunakan `snake_case` untuk nama file dan folder.

Contoh:

```text
player_controller.gd
animation_handler.gd
player_assets/
enemy_sprites/
```

### Penamaan Script dan Variabel

Ikuti konvensi penamaan GDScript:

| Elemen | Konvensi | Contoh |
|---|---|---|
| Class | PascalCase | `PlayerController` |
| Function | snake_case | `handle_movement()` |
| Variable | snake_case | `move_speed` |
| Constant | UPPER_SNAKE_CASE | `MAX_HEALTH` |
| File | snake_case | `player_controller.gd` |

### Penulisan Kode

1. Gunakan nama variabel dan fungsi yang menjelaskan kegunaannya.
2. Hindari nama yang terlalu singkat atau sulit dipahami.
3. Pisahkan tanggung jawab kode sesuai fungsinya.
4. Hindari duplikasi kode jika dapat menggunakan fungsi bersama.
5. Tambahkan komentar hanya jika diperlukan untuk menjelaskan bagian yang tidak mudah dipahami.

---

**Catatan:** Jika terdapat perubahan aturan atau workflow, diskusikan terlebih dahulu dengan anggota tim sebelum memperbarui panduan ini.
