# Panduan Penggunaan SCRUM di GitHub: Pembuatan Issue dan Milestone

## Pengenalan Issues dan Milestones di GitHub
- **Issues:**
  - **Apa itu Issue?**
    - Issue adalah alat yang digunakan untuk melacak tugas, bug, atau permintaan fitur dalam proyek.
    - Setiap issue menggambarkan pekerjaan yang perlu dilakukan oleh tim.
  - **Mengapa Menggunakan Issue?**
    - Memudahkan komunikasi antar anggota tim.
    - Menyediakan tempat untuk mendiskusikan detail tugas atau masalah.
    - Membantu dalam perencanaan dan pengelolaan proyek secara keseluruhan.
  - **Contoh Penggunaan Issue:**
    - Melacak bug: "Form login tidak berfungsi saat memasukkan data yang valid."
    - Permintaan fitur: "Tambahkan fitur pencarian pada halaman utama."
    - Tugas: "Desain UI untuk halaman dashboard."

- **Milestones:**
  - **Apa itu Milestone?**
    - Milestone adalah cara untuk mengelompokkan beberapa issues yang terkait dalam satu periode waktu tertentu, seperti sprint dalam metode SCRUM.
    - Milestone membantu mengorganisir dan melacak progres pekerjaan dalam interval waktu tertentu.
  - **Mengapa Menggunakan Milestone?**
    - Memudahkan untuk melihat progres proyek dalam skala yang lebih besar.
    - Membantu dalam pengelolaan tenggat waktu dan perencanaan sprint.
    - Menyediakan visibilitas mengenai pencapaian target dan sasaran tim.
  - **Contoh Penggunaan Milestone:**
    - Sprint 1: "Selesaikan fitur login, registrasi, dan dashboard."
    - Sprint 2: "Implementasi fitur pencarian dan filter data."
    - Rilis versi 1.0: "Selesaikan semua fitur utama dan perbaikan bug."

## Peran Product Manager
- **Tanggung Jawab Product Manager:**
  - Menentukan dan memprioritaskan backlog produk.
  - Memastikan tim memahami pekerjaan yang harus dilakukan.
  - Melakukan komunikasi dengan pemangku kepentingan untuk mengklarifikasi kebutuhan dan prioritas.

- **Langkah-langkah Product Manager dalam Membuat Issue dan Milestone:**

### **Langkah 1: Product Manager Membuat Issue**
- **Langkah-langkah Membuat Issue:**
  1. Navigasi ke tab Issues di repositori GitHub.
  2. Klik "New Issue".
  3. Isi judul dan deskripsi issue secara detail.
  4. Tambahkan label, assignee, dan proyek jika diperlukan.

- **Contoh Issue:**
  ```markdown
  ### Judul: Implementasi Fungsi Login

  **Deskripsi:**
  Buat halaman login dengan autentikasi pengguna.

  **Tugas:**
  - [ ] Desain UI halaman login.
  - [ ] Implementasi backend untuk autentikasi.
  - [ ] Integrasi frontend dan backend.

  **Label:**
  - enhancement, frontend, backend

  **Assignee:**
  - @developer-username
  ```

### **Langkah 2: Product Manager Membuat Milestone**
- **Langkah-langkah Membuat Milestone:**
  1. Navigasi ke tab Issues di repositori GitHub.
  2. Klik "Milestones" dan kemudian "New Milestone".
  3. Isi nama, deskripsi, dan tanggal penyelesaian milestone.
  - Nama: Sprint 1
  - Deskripsi: Pekerjaan yang harus diselesaikan dalam Sprint 1.
  - Tanggal Penyelesaian: [Tanggal akhir sprint]
- **Menambahkan Issues ke Milestone:**
  - Saat membuat atau mengedit issue, pilih milestone yang sesuai dari dropdown "Milestone".

### **Langkah 3: Developer Menyelesaikan Issue**
- **Menghubungkan Commit ke Issue:**
  - Buat branch baru untuk issue:
    ```bash
    git checkout -b feature/login
    ```
  - Lakukan perubahan dan commit dengan pesan yang menghubungkan ke issue:
    ```bash
    git add .
    git commit -m "Menyelesaikan desain UI halaman login. Closes #1"
    ```
  - Push commit ke branch utama (misalnya `main` atau `development`):
    ```bash
    git push origin main
    ```

### **Menutup Issue dengan Komentar Menggunakan Hash Commit**
- **Referensi ke Commit dengan Hash:**
  - Untuk menutup issue dengan komentar, tulis SHA-hash commit yang menyelesaikan issue.
  - Contoh penggunaan hash lengkap:
    ```markdown
    Commit 3e5c1e60269ae0329094de131227285d4682b665 menyelesaikan issue ini.
    ```
  - Contoh penggunaan hash singkat:
    ```markdown
    Commit 3e5c1e6 menyelesaikan issue ini.
    ```
  - Hash commit akan otomatis menjadi tautan ke commit tersebut.

### **Memantau dan Mengelola Issues dan Milestones**
- **Melacak Progres:**
  - Progres milestone dapat dilihat di tab Milestones.
  - Persentase penyelesaian berdasarkan jumlah issues yang selesai.
- **Memantau Aktivitas:**
  - Setiap commit yang dihubungkan ke issue akan otomatis menutup issue tersebut jika menggunakan kata kunci seperti `Closes #1` dalam pesan commit.
  - Aktivitas terbaru dapat dilihat di tab Issues dan Commits.

### **Manfaat Penggunaan Issues dan Milestones**
- **Organisasi dan Struktur:**
  - Mengelompokkan tugas ke dalam sprint yang terdefinisi dengan baik.
  - Memastikan semua anggota tim mengetahui apa yang harus dikerjakan.
- **Transparansi dan Visibilitas:**
  - Semua anggota tim dapat melihat progres proyek secara real-time.
  - Memudahkan manajemen dan penyesuaian rencana jika diperlukan.
---
