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

## 1. Aturan Projek & Git Workflow

### A. Aturan Kolaborasi Tim

1. **Dilarang Direct Push ke `main`:** Semua perubahan kode/aset wajib melalui *branch* fitur dan mekanisme *Pull Request* (PR).
2. **Prinsip "Satu Orang, Satu Scene":** Jangan mengedit file `.tscn` yang sedang dikerjakan anggota tim lain untuk mencegah *merge conflict*.
3. **Proteksi Base Template:** Dilarang mengedit file di folder `base_templates/` secara langsung. Selalu gunakan fungsi *Inherit Scene* atau *Duplicate*.
4. **Pull Sebelum Push:** Selalu jalankan `git pull origin main` ke cabang lokal sebelum membuka *Pull Request*.

### B. Format Branching & Commit

* **Format Branch:** `<tipe>/<nama-fitur-singkat>` (contoh: `feat/player-movement`, `fix/ui-pause-glitch`).
* **Format Commit:** `<tipe>: <deskripsi singkat>`

| Tipe Commit | Kegunaan | Contoh |
| --- | --- | --- |
| `feat:` | Fitur atau logika baru | `feat: tambah mekanik phasing hantu` |
| `fix:` | Perbaikan bug/eror | `fix: perbaiki offset collision player` |
| `art:` | Aset visual / sprite / tilemap | `art: tambah spritesheet penebang` |
| `audio:` | Aset suara (BGM/SFX) | `audio: tambah sfx petir dan angin` |
| `refactor:` | Penataan ulang kode tanpa merubah fungsi | `refactor: pisahkan UI logic dari GameManager` |
| `docs:` | Pembaharuan dokumentasi | `docs: update readme struktur folder` |

---

## 2. Standar Penamaan Universal (Naming Conventions)

| Elemen Projek | Format | Contoh |
| --- | --- | --- |
| **Folder & Berkas File** | `snake_case` | `player_controller.gd`, `main_menu.tscn`, `bgm_forest.ogg` |
| **Class Name & Custom Node** | `PascalCase` | `class_name PlayerController`, `class_name InteractableBase` |
| **Node di Scene Tree** | `PascalCase` | `Player`, `CollisionShape2D`, `InteractionArea` |
| **Variabel & Fungsi** | `snake_case` | `var move_speed: float`, `func take_damage(amount: int):` |
| **Signal** | `snake_case` | `signal health_changed(new_value)`, `signal item_picked_up` |
| **Konstanta & Enum** | `UPPER_SNAKE` | `const MAX_SPEED = 300.0`, `enum State { IDLE, MOVE, SCARE }` |
| **Fungsi/Variabel Private** | `_snake_case` | `var _internal_timer: float`, `func _update_state():` |

---

## 3. Struktur Direktori Projek (General File System)

```text
res://
├── assets/                 # Berkas aset mentah dan media
│   ├── audio/              # SFX (.wav) dan Music (.ogg)
│   ├── fonts/              # File font (.ttf, .otf)
│   ├── sprites/            # Textures, Tilemap, SpriteSheets (.png)
│   └── ui/                 # Frame, icon, & elemen visual antarmuka
├── scenes/                 # Seluruh komponen visual/node (.tscn)
│   ├── levels/             # Peta level, arena, & world scene
│   ├── player/             # Entitas utama pemain & komponennya
│   ├── enemies/            # Entitas musuh & AI
│   ├── interactables/      # Objek lingkungan, jebakan, & pancingan
│   └── ui/                 # Main Menu, HUD Overlay, Pause Popup
├── scripts/                # Berkas logika & skrip (.gd)
│   ├── autoload/           # Manager global / Singleton (GameManager.gd)
│   ├── base/               # Class induk / Interface (CharacterBase.gd)
│   └── utils/              # Helper, Math, & Constant Loader
├── base_templates/         # Base template scene untuk di-inherit
├── docs/                   # GDD, catatan desain, & panduan
└── project.godot           # File konfigurasi utama engine

```

---

## 4. Struktur Scene & Komponen (Scene Node Architecture)

### A. Prinsip Komponen & Komunikasi Node

**Satu Scene = Satu Komponen / Entitas Spesifik:** Buat scene sekecil dan semenolong mungkin agar gampang di-re-use (*Modular Design*).

### B. Anatomi Standard Scene

#### 1. Entitas Karakter / Player (`CharacterBody2D` / `CharacterBody3D`)

```text
Player (CharacterBody2D) [Script: PlayerController.gd]
├── Sprite2D / AnimatedSprite2D     # Visual utama & animasi
├── CollisionShape2D                # Batas fisika dengan dunia/tembok
├── Hurtbox (Area2D)                # Area deteksi menerima damage/lampu
│   └── CollisionShape2D
├── Hitbox (Area2D)                 # Area deteksi memberi efek/teror
│   └── CollisionShape2D
├── InteractionDetector (RayCast2D) # Sensor garis lurus depan karakter
├── StateMachine (Node)             # Logika status (Idle, Move, Scare)
│   ├── IdleState (Node)
│   └── MoveState (Node)
└── AudioStreamPlayer2D             # Efek suara langkah/aksi karakter

```

#### 2. Objek Interaktif Lingkungan (`Area2D` / `StaticBody2D`)

```text
InteractableObject (Area2D) [Script: InteractableBase.gd]
├── Sprite2D                        # Visual objek (misal: Api Unggun / Semak)
├── CollisionShape2D                # Radius zona interaksi
├── InteractionPrompt (Control)     # UI melayang (misal: "Tekan E")
│   └── Label
└── AudioStreamPlayer2D             # Efek suara objek saat dipicu

```

#### 3. Tampilan Antarmuka / UI (`CanvasLayer`)

```text
UIOverlay (CanvasLayer) [Script: UIManager.gd]
└── Control (Full Rect)
    ├── MarginContainer (HUD Layer)
    │   └── HBoxContainer
    │       ├── HealthBar (TextureProgressBar)
    │       └── ScoreLabel (Label)
    └── PauseMenu (Control - Hidden)
        └── PanelContainer
            └── VBoxContainer
                ├── ResumeButton (Button)
                └── QuitButton (Button)

```
