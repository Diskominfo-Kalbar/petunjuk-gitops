# Dokumentasi Penggunaan MinIO di CodeIgniter

## Pemasangan Package AWS SDK
Tambahkan perintah di bawah ini ke dalam `Dockerfile` untuk memastikan package terpasang di lingkungan Docker:
```dockerfile
RUN composer require aws/aws-sdk-php
```

**Catatan:** Variabel ENV untuk konfigurasi MinIO sudah diatur otomatis di lingkungan GitOps(Jangan di kacau)

## Fungsi Mendapatkan URL Signed File Upload
Gunakan fungsi berikut untuk menghasilkan URL signed:

```php
use Aws\S3\S3Client;
use Aws\S3\Exception\S3Exception;

function generateSignedUrl($objectKey, $expiration = 3600)
{
    $bucketName = getenv('MINIO_BUCKET_NAME');
    $minioConfig = [
        'version'     => 'latest',
        'region'      => 'pontianak',
        'endpoint'    => 'http://' . getenv('MINIO_HOST') . ':9000',
        'use_path_style_endpoint' => true,
        'credentials' => [
            'key'    => getenv('MINIO_ACCESS_KEY'),
            'secret' => getenv('MINIO_SECRET_KEY'),
        ],
    ];

    $s3Client = new S3Client($minioConfig);

    try {
        $command = $s3Client->getCommand('GetObject', [
            'Bucket' => $bucketName,
            'Key'    => $objectKey,
        ]);

        $signedUrl = $s3Client->createPresignedRequest($command, "+{$expiration} seconds")->getUri()->__toString();
        $urlWithNewHost = str_replace('http://minio-dev:9000', base_url() . 'kominfo-minio-dev', $signedUrl);
        $urlWithNewHost = str_replace('http://minio:9000', base_url() . 'kominfo-minio', $urlWithNewHost);
        return $urlWithNewHost;
    } catch (S3Exception $e) {
        return null;
    }
}
```

## Fungsi Upload File ke MinIO
Fungsi berikut digunakan untuk mengunggah file tunggal ke MinIO:

```php
use Aws\S3\S3Client;
use Aws\S3\Exception\S3Exception;

function uploadToMinio($filePath, $destinationPath)
{
    $minioConfig = [
        'version'     => 'latest',
        'region'      => 'pontianak',
        'endpoint'    => 'http://' . getenv('MINIO_HOST') . ':9000',
        'use_path_style_endpoint' => true,
        'credentials' => [
            'key'    => getenv('MINIO_ACCESS_KEY'),
            'secret' => getenv('MINIO_SECRET_KEY'),
        ],
    ];

    $s3Client = new S3Client($minioConfig);
    $bucketName = getenv('MINIO_BUCKET_NAME');

    try {
        $result = $s3Client->putObject([
            'Bucket'     => $bucketName,
            'Key'        => $destinationPath,
            'SourceFile' => $filePath,
        ]);

        return $result['ObjectURL'];
    } catch (S3Exception $e) {
        return 'Error: ' . $e->getMessage();
    }
}
```

### Contoh Penggunaan Fungsi Upload

```php
$filePath = $_FILES['file']['tmp_name'];
$destinationPath = '/frontend/img/gallery/' . uniqid();

$result = uploadToMinio($filePath, $destinationPath);

if (strpos($result, 'Error') === false) {
    echo 'File berhasil diupload. URL: ' . $result;
} else {
    echo $result;
}
```