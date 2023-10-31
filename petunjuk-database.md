# Dokumentasi Database untuk Pengembang

Dokumentasi ini akan membantu pengembang dalam mengakses dan menggunakan database yang telah disediakan. Kami memiliki database yang dapat diakses melalui secret Github, dan juga menyediakan dua opsi untuk mengelola database, yaitu PHPMyAdmin dan Adminer.

## Menggunakan Database

Anda dapat mengakses database kami dengan mengambil informasi koneksi dari secret Github. Dalam kodingan Anda, gunakan informasi berikut:

- **DB_HOST**: Ini adalah host database yang dapat Anda gunakan untuk koneksi.
- **DB_HOST_DEV**: Ini adalah host database yang dapat Anda gunakan saat mengembangkan aplikasi Anda.
- **DB_USER**: Username yang akan digunakan untuk mengakses database.
- **DB_PASSWORD**: Password yang sesuai dengan username.
- **DB_DATABASE**: Nama database yang akan Anda akses.

Pastikan untuk tidak menyertakan informasi ini secara langsung dalam kode Anda, tetapi baca informasinya dari secret Github saat aplikasi Anda berjalan. Ini akan menjaga keamanan koneksi database.

## Mengakses PHPMyAdmin

Anda dapat mengelola database Anda dengan menggunakan PHPMyAdmin yang telah disediakan. Untuk mengakses PHPMyAdmin, kunjungi [mysql.kalbarprov.app](http://mysql.kalbarprov.app). Anda akan diminta untuk login menggunakan kredensial yang sesuai dengan database yang ingin Anda kelola.

## Mengakses Adminer

Alternatif lain untuk mengelola database adalah menggunakan Adminer. Anda dapat mengakses Adminer melalui [adminer.kalbarprov.app](http://adminer.kalbarprov.app). Anda juga akan diminta untuk login menggunakan kredensial database yang sesuai.

Pastikan untuk selalu menjaga kredensial login PHPMyAdmin dan Adminer dengan baik, dan hanya memberikan akses kepada pihak yang berwenang.

Dengan informasi di atas, Anda sekarang dapat mengakses dan mengelola database dengan aman dan efisien. Jika Anda memiliki pertanyaan lebih lanjut atau masalah terkait database, jangan ragu untuk menghubungi tim teknis kami.
