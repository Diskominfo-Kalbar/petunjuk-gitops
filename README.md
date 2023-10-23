## Latar Belakang

Penggunaan GitOps dalam pengembangan dan pengelolaan aplikasi semakin populer dalam dunia teknologi. GitOps adalah pendekatan yang mengintegrasikan Git (misalnya, GitHub) sebagai sumber kebenaran tunggal untuk infrastruktur dan konfigurasi aplikasi. Ini dapat menjadi solusi yang efektif untuk meningkatkan pengelolaan aplikasi dan infrastruktur.

Selain itu, penggunaan Docker Swarm sebagai orkestrator kontainer memberikan fleksibilitas dalam pengelolaan aplikasi. Polise, aplikasi penghubung yang memfasilitasi Single Sign-On (SSO), pembaruan berita melalui pesan commit di GitHub, pelaporan masalah oleh pengguna, penilaian pengguna, dan halaman kontribusi developer, akan memberikan layanan yang lebih baik kepada pengguna dan memudahkan pengembang dalam berkontribusi.

[Detil Aplikasi pada web polise](https://ibb.co/0XXgTff)

## Manfaat

Penerapan GitOps dengan GitHub Actions dan Docker Swarm di lingkungan Kominfo Kalbar membawa manfaat sebagai berikut:

1. **Manajemen Infrastruktur yang Efisien:** Penggunaan GitOps memungkinkan pengelolaan infrastruktur dengan mudah. Perubahan dalam konfigurasi dan infrastruktur dapat dilakukan melalui Git, memungkinkan dokumentasi dan kontrol yang ketat.

2. **Pembaruan Aplikasi yang Terkontrol:** Pembaruan aplikasi akan dilakukan melalui Git commit, memastikan pembaruan yang terkendali dan terdokumentasi dengan baik. Ini juga memudahkan manajemen rollback jika diperlukan.

3. **Pelaporan Masalah yang Otomatis:** Integrasi Polise dengan GitHub akan secara otomatis membuat issue di repositori GitHub ketika pengguna melaporkan masalah. Ini mempercepat tanggapan terhadap masalah-masalah tersebut.

4. **Penilaian Pengguna:** Menyediakan sistem penilaian dari pengguna memungkinkan pengembang untuk mendapatkan umpan balik yang berguna dan meningkatkan aplikasi.

5. **Transparansi Kontribusi Developer:** Halaman kontribusi developer yang mengambil data dari total kontribusi di GitHub memberikan pandangan transparan tentang kontribusi masing-masing pengembang, membantu dalam mengukur bobot pengerjaan aplikasi. Ini juga mencakup kontribusi dalam bentuk pembuatan dokumentasi penggunaan aplikasi dan dokumentasi database di repositori yang relevan.

## Penjelasan

### Infrastruktur Node VM dan Docker Swarm

Kominfo Kalbar menggunakan empat virtual machine (VM) yang dijelaskan sebagai berikut:

1. **Node Docker Registry:** Terdapat satu VM yang berperan sebagai Docker Registry, tempat penyimpanan untuk hasil build image. VM ini hanya dapat diakses melalui jaringan lokal, memastikan keamanan data image yang dibangun.

2. **Node Aplikasi (Dapat Diperluas):** VM ini berperan sebagai node dalam Docker Swarm dan berisi berbagai container aplikasi. Node aplikasi ini adalah bagian yang dapat diperluas, yang berarti Anda dapat memiliki lebih dari satu VM dalam cluster ini sesuai dengan kebutuhan. Node aplikasi juga berperan sebagai proxy yang mengarahkan permintaan pengguna ke container-container aplikasi yang sesuai.

3. **Node AWDI:** Terdapat satu VM yang di khususkan untuk menjalankan container AWDI (Andalan Water Data Integration). VM ini menjalankan kontainer AWDI secara eksklusif.

4. **Node Object Storage:** VM ini bertugas menjalankan Minio Server, yang berperan sebagai penyimpanan objek atau object storage. Minio Server digunakan untuk penyimpanan objek seperti gambar, video, dan file lainnya yang diperlukan oleh aplikasi.

5. **Node Database:** VM ini menjalankan layanan database dan berfungsi sebagai node yang menjalankan MySQL dan PostgreSQL. Ini menjadi tempat penyimpanan data struktured yang dibutuhkan oleh aplikasi.

Dengan menggunakan node aplikasi yang dapat diperluas, Kominfo Kalbar dapat mengelola dan menambah kapasitas aplikasi dengan fleksibilitas. Ini memungkinkan peningkatan performa dan skalabilitas aplikasi dengan mudah saat kebutuhan meningkat, serta menjaga isolasi dan kehandalan aplikasi. Docker Swarm akan mendistribusikan dan mengelola container-container aplikasi di seluruh node aplikasi yang ada dalam cluster.

### Cara Kerja GitOps

1. **Penyiapan Akun GitHub Developer dan Repository**: Langkah pertama adalah berkomunikasi antara developer aplikasi dengan tim Kominfo. Developer akan menyediakan akun GitHub mereka kepada tim Kominfo. Setelah itu, tim Kominfo akan membuatkan repositori GitHub yang sudah di-setup untuk proses GitOps. Ini mencakup konfigurasi GitHub Actions dan Docker Swarm stack files yang diperlukan untuk penyebaran otomatis.

2. **Penggunaan Template Direktori**: Untuk memudahkan proses pengembangan aplikasi, tim Kominfo menyediakan template direktori sesuai dengan teknologi yang digunakan dalam aplikasi. Template ini berisi struktur direktori yang telah diatur dan berisi contoh file konfigurasi Docker Compose stack yang sesuai.

3. **Perubahan Melalui Git Commit**: Developer melakukan perubahan dalam aplikasi, konfigurasi, atau infrastruktur melalui Git commit pada repositori GitHub. Perubahan ini mencakup pembaruan kode aplikasi, atau pembaruan pada dokumentasi penggunaan aplikasi dan dokumentasi database.

4. **Pemantauan dengan GitHub Actions**: GitHub Actions memantau repositori GitHub secara berkala. Setiap kali ada perubahan, GitHub Actions akan melakukan serangkaian tindakan otomatis yang telah ditentukan.

5. **Pelaporan Masalah dari Polise**: Aplikasi Polise berfungsi sebagai pintu masuk bagi pengguna untuk mengakses aplikasi melalui SSO. Ketika pengguna melaporkan masalah atau masalah keamanan melalui Polise, Polise secara otomatis menciptakan issue di repositori GitHub yang sesuai dengan aplikasi terkait. Issue tersebut mencakup informasi tentang masalah yang dilaporkan dan menciptakan alur kerja untuk menanganinya.

6. **Evaluasi Penilaian Pengguna**: Aplikasi memiliki mekanisme penilaian yang memungkinkan pengguna memberikan umpan balik tentang kualitas aplikasi, termasuk kualitas dokumentasi penggunaan aplikasi. Data penilaian ini disimpan dan dapat digunakan oleh tim pengembang untuk evaluasi dan perbaikan aplikasi serta dokumentasi yang relevan.

Dengan menggunakan GitOps, proses pengembangan, dan penyebaran aplikasi menjadi otomatis dan terdokumentasi dengan baik. Ini memungkinkan pengembang untuk fokus pada pengembangan fitur baru sambil menjaga kontrol yang ketat terhadap infrastruktur dan konfigurasi aplikasi. Selain itu, masalah yang dilaporkan oleh pengguna dapat dengan cepat diidentifikasi dan diatasi, memberikan pengalaman yang lebih baik kepada pengguna aplikasi.
