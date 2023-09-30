# Petunjuk Menggunakan Minio

## Pendahuluan
Object storage adalah tipe penyimpanan yang memungkinkan penyimpanan dan pengambilan data dalam bentuk objek, seperti gambar, video, atau dokumen. Kelebihan dari object storage termasuk skalabilitas tinggi, durabilitas, dan aksesibilitas yang mudah dari berbagai lokasi.

Minio adalah sistem penyimpanan objek open-source yang kompatibel dengan API S3.

## Konfigurasi dengan Laravel dan `league/flysystem-aws-s3-v3`

1. Tambahkan driver di file system pada konfigurasi Laravel:
   ```php
   'minio' => [
       'driver' => 's3',
       'endpoint' => "http://".env('MINIO_HOST').":9000",
       'use_path_style_endpoint' => true,
       'key' => env('MINIO_ACCESS_KEY'),
       'secret' => env('MINIO_SECRET_KEY'),
       'region' => "pontianak",
       'bucket' => env('MINIO_BUCKET_NAME'),
       'url' => "http://".env('MINIO_HOST').":9000",
   ],
   ```

2. Penggunaan untuk mengupload file dengan Laravel:
   ```php
   \Storage::disk('minio')->putFileAs($path, $file, $fileName);
   ```

3. Fungsi untuk mendapatkan signed URL dengan Laravel:
   ```php
   function gcpGetSignedGcsUrl($objPath, $duration = 21600)
   {
       $url = Storage::disk('minio')->temporaryUrl($objPath, $duration);
       $urlWithNewHost = str_replace('http://minio-dev:9000', url('/kominfo-minio-dev'), $url);
       $urlWithNewHost = str_replace('http://minio:9000', url('/kominfo-minio'), $urlWithNewHost);
       return $urlWithNewHost;
   }
   ```

Penting untuk menggunakan konfigurasi default yang telah diatur melalui secret repository yang telah disiapkan oleh Kominfo. Pengembang hanya perlu menyesuaikan nilai konfigurasi dengan memanggil dari environment yang telah disediakan.

Berikut adalah konfigurasi yang akan diambil dari environment tanpa perlu diset manual:
- `MINIO_ACCESS_KEY`: Kunci akses Minio diambil dari environment.
- `MINIO_SECRET_KEY`: Kunci rahasia Minio diambil dari environment.
- `MINIO_HOST`: Alamat host Minio diambil dari environment.
- `MINIO_BUCKET_NAME`: Nama bucket pada Minio diambil dari environment.

Pengembang dapat menggunakan nilai-nilai ini langsung dalam kode aplikasi, tanpa perlu melakukan pengaturan manual pada environment.
Untuk bahasa pemrograman atau framework lain, penyesuaian konfigurasi akan mirip dengan langkah-langkah di atas dengan mengacu pada dokumentasi dan library yang sesuai.
