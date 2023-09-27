# GitOps Quick Guide

## Apa itu GitOps?
GitOps adalah metodologi pengelolaan infrastruktur dan aplikasi menggunakan Git sebagai sumber utama untuk menyimpan konfigurasi, definisi, dan perubahan. Perubahan pada infrastruktur dan aplikasi dipicu melalui Git dan otomatisasi.

## Node
Node adalah komponen dalam jaringan komputer yang bertindak sebagai titik akhir untuk menerima, mengirim, dan memproses data dalam suatu jaringan. Dalam konteks ini, "node" dapat merujuk pada komputer fisik atau virtual di mana aplikasi dan servis dijalankan.

## Container
Container adalah unit perangkat lunak yang memungkinkan aplikasi dan dependensinya diisolasi dari lingkungan sistem operasi. Container memiliki semua yang diperlukan untuk menjalankan aplikasi, termasuk kode, runtime, pustaka, dan dependensi, yang memudahkan portabilitas dan distribusi aplikasi.

## Docker
Docker adalah platform sumber terbuka yang memungkinkan pengelolaan dan penjalanan kontainer. Docker memfasilitasi pembuatan, distribusi, dan eksekusi kontainer secara konsisten di berbagai lingkungan. Docker menyediakan alat dan API untuk mengelola siklus hidup kontainer.

## Docker Compose
Docker Compose adalah alat yang memungkinkan definisi dan pengelolaan aplikasi multi-container dengan Docker. Dalam file konfigurasi (biasanya menggunakan format YAML), Anda dapat mendefinisikan semua komponen aplikasi, termasuk kontainer, jaringan, dan volume yang diperlukan, serta cara mereka berinteraksi. Docker Compose mempermudah pengelolaan aplikasi kompleks dengan konfigurasi yang terpusat.


## Node di Kominfo Kalimantan Barat (KalBar)

### Node Manager
Node Manager adalah node yang mengelola dan menjalankan service proxy, serta beberapa layanan pengembangan seperti MySQL dan Minio.

### Admin-AWDI (Node Worker)
admin-awdi adalah node khusus yang digunakan untuk menjalankan layanan AWDI.

### Minio Server (Node Worker)
minio-server adalah node khusus yang digunakan untuk menjalankan layanan produksi Minio dan sebagai tempat penyimpanan data Minio.

### MySQL Server (Node Worker)
mysql-server adalah node khusus yang digunakan untuk menjalankan layanan produksi MySQL dan sebagai tempat penyimpanan data MySQL.

### Penambahan Node Worker
Untuk menambahkan server, cukup menambahkan node worker baru dan mengintegrasikannya ke dalam lingkungan.

### Penanganan Service yang Tidak Terikat dengan Node
Service yang tidak terikat dengan node akan otomatis memilih node yang tersedia untuk dijalankan.

### Server Lokal Registry Docker
Server `10.10.11.93:5000` merupakan server lokal yang digunakan untuk menyimpan registry image Docker.

Pastikan untuk memperbarui konfigurasi dan informasi terkait ketika ada perubahan atau penambahan node atau layanan pada lingkungan ini.

## Template Workflow dan File Pendukung
Kami telah menyediakan template workflow GitHub, Dockerfile, dan docker-compose.yml yang dapat digunakan untuk proyek dalam repositori ini. Silakan gunakan template tersebut untuk mempermudah pengelolaan dan pengembangan proyek Anda.


