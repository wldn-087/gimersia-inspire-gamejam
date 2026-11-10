# Gimersia Inspire Gamejam

GDD: https://docs.google.com/document/d/1wWwXl_P3cLciRPG97cUjV5jHKgy8mPFzaBPRXVG1ukI/edit?usp=sharing

## Alur Kerja
### 1. Kloning Repository ke Lokal (`git clone`)

Buka Terminal / Git Bash di komputer, masuk ke folder tempat penyimpanan projek, lalu jalankan:

```bash
# 1. Download projek dari GitHub ke komputer
git clone https://github.com/wldn-087/gimersia-inspire-gamejam.git

# 2. Masuk ke folder projek yang baru terunduh
cd gimersia-inspire-gamejam

```

---

### 2. Memastikan Cabang Utama Up-to-Date (`git pull`)

Sebelum mulai mengedit kode atau membuat fitur baru, selalu pastikan cabang `main` di lokal sudah mengambil versi terbaru dari remote:

```bash
git checkout main
git pull origin main

```

---

### 3. Membuat Cabang Fitur Baru (`git checkout -b`)

Jangan pernah memodifikasi kode langsung di cabang `main`. Buat cabang (*branch*) baru sesuai fitur atau tugas yang akan digarap:

```bash
# Format: git checkout -b tipe/nama-fitur
git checkout -b feat/player-movement

# (Alternatif perintah baru di Git)
# git switch -c feat/player-movement

```

---

### 4. Mengerjakan Fitur & Menyimpan Perubahan Lokal (`git add` & `git commit`)

Buka projek di Godot / kode editor, lalu kerjakan tugasmu di dalam *scene* atau *script* tersendiri. Setelah selesai atau mencapai *milestone* kecil:

```bash
# 1. Cek file mana saja yang telah diubah atau ditambahkan
git status

# 2. Masukkan semua perubahan ke Staging Area
git add .

# 3. Simpan perubahan ke histori lokal dengan pesan yang jelas
git commit -m "feat: tambah sistem movement hantu dan collision phasing"

```

---

### 5. Mengambil Update Terbaru `main` Sebelum Push (Mencegah Conflict)

Jika anggota tim lain ada yang melakukan *merge* ke `main` saat kamu sedang *ngoding*, gabungkan pembaruan `main` tersebut ke cabang fiturnya terlebih dahulu:

```bash
# 1. Pindah sementara ke main dan ambil update terbaru dari GitHub
git checkout main
git pull origin main

# 2. Kembali ke cabang fiturnya
git checkout feat/player-movement

# 3. Gabungkan update dari main ke cabang fiturmu
git merge main

```

*Jika ada bentrok (*conflict*), selesaikan file yang bentrok di editor, simpan, lalu jalankan `git add .` dan `git commit -m "fix: resolve merge conflict"`.*

---

### 6. Mengunggah Cabang Fitur ke GitHub (`git push`)

Kirim cabang lokal beserta commit-nya ke repository remote di GitHub:

```bash
# Mengunggah cabang ke GitHub untuk pertama kali
git push -u origin feat/player-movement

```

---

### 7. Membuat Pull Request (PR) & Merge di GitHub

1. Buka browser dan kunjungi repository [gimersia-inspire-gamejam](https://www.google.com/search?q=https://github.com/wldn-087/gimersia-inspire-gamejam).
2. Di bagian atas repository, akan muncul banner kuning dengan tombol **Compare & pull request**. Klik tombol tersebut.
3. Isi **Title** dan **Description** mengenai perubahan apa saja yang telah dikerjakan.
4. Klik **Create pull request**.
5. Setelah ditinjau (atau dipastikan tidak ada bentrok), klik tombol **Merge pull request** $\rightarrow$ **Confirm merge**. Cabang fiturnya kini resmi bergabung ke cabang `main`.

---

### 8. Pembersihan & Sinkronisasi Akhir di Lokal

Setelah Pull Request berhasil di-merge di GitHub, bersihkan cabang lokal agar siap untuk fitur berikutnya:

```bash
# 1. Pindah kembali ke cabang main
git checkout main

# 2. Tarik kode main terbaru yang sudah berisi fitur dari PR tadi
git pull origin main

# 3. Hapus cabang fitur lokal yang sudah selesai di-merge
git branch -d feat/player-movement

```
