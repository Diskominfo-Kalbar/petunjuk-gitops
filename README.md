# GitOps Quick Guide

## Apa itu GitOps?
GitOps adalah metodologi pengelolaan infrastruktur dan aplikasi menggunakan Git sebagai sumber utama untuk menyimpan konfigurasi, definisi, dan perubahan. Perubahan pada infrastruktur dan aplikasi dipicu melalui Git dan otomatisasi.

## Prosedur Pengajuan Akun
[Pembuatan akun github dan pengajuan akun github ke Kominfo Kalbar](pembuatan-akun-github.md)

## Panduan Penggunan Github
[Penggunaan Github Issue](panduan-github-issue.md)

## Node
Node adalah komponen dalam jaringan komputer yang bertindak sebagai titik akhir untuk menerima, mengirim, dan memproses data dalam suatu jaringan. Dalam konteks ini, "node" dapat merujuk pada komputer fisik atau virtual di mana aplikasi dan servis dijalankan.

## Container
Container adalah unit perangkat lunak yang memungkinkan aplikasi dan dependensinya diisolasi dari lingkungan sistem operasi. Container memiliki semua yang diperlukan untuk menjalankan aplikasi, termasuk kode, runtime, pustaka, dan dependensi, yang memudahkan portabilitas dan distribusi aplikasi.

## Docker
Docker adalah platform sumber terbuka yang memungkinkan pengelolaan dan penjalanan kontainer. Docker memfasilitasi pembuatan, distribusi, dan eksekusi kontainer secara konsisten di berbagai lingkungan. Docker menyediakan alat dan API untuk mengelola siklus hidup kontainer.

## Docker Compose
Docker Compose adalah alat yang memungkinkan definisi dan pengelolaan aplikasi multi-container dengan Docker. Dalam file konfigurasi (biasanya menggunakan format YAML), Anda dapat mendefinisikan semua komponen aplikasi, termasuk kontainer, jaringan, dan volume yang diperlukan, serta cara mereka berinteraksi. Docker Compose mempermudah pengelolaan aplikasi kompleks dengan konfigurasi yang terpusat.

### Server Lokal Registry Docker
Server `10.10.11.93:5000` merupakan server lokal yang digunakan untuk menyimpan registry image Docker.

Pastikan untuk memperbarui konfigurasi dan informasi terkait ketika ada perubahan atau penambahan node atau layanan pada lingkungan ini.

## Template Workflow dan File Pendukung
Kami telah menyediakan template workflow GitHub, Dockerfile, dan docker-compose.yml yang dapat digunakan untuk proyek dalam repositori ini. Silakan gunakan template tersebut untuk mempermudah pengelolaan dan pengembangan proyek Anda.

## Penggunaan Variable Environment untuk Akses MySQL
Gunakanlah variabel environment seperti DB_HOST, DB_USERNAME, dan DB_PASSWORD untuk mengakses MySQL. Dengan menggunakan variabel environment, developer tidak perlu lagi menyertakan password akses ke database secara langsung. Sesuaikan variabel environment ini sesuai dengan konfigurasi yang sesuai dengan pengaturan akses MySQL.
