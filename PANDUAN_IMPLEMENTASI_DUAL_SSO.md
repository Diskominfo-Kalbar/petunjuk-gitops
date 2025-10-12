# Panduan Implementasi Dual SSO (SSO Publik & SSO ASN/Pegawai)

**Panduan untuk Developer**

## Daftar Isi
- [Pengantar](#pengantar)
- [Quick Reference](#quick-reference)
- [Arsitektur & Konsep](#arsitektur--konsep)
- [Prerequisites](#prerequisites)
- [Langkah Implementasi](#langkah-implementasi)
- [Testing & Troubleshooting](#testing--troubleshooting)
- [FAQ](#faq)

---

## Pengantar

Panduan ini menjelaskan cara mengimplementasikan sistem autentikasi dual SSO menggunakan Keycloak untuk membedakan antara:
- **SSO Publik**: Untuk masyarakat umum (menggunakan NIK)
- **SSO ASN/Pegawai**: Untuk pegawai pemerintah (menggunakan NIP)

Implementasi ini menggunakan Laravel 11 dengan Laravel Socialite dan Keycloak sebagai Identity Provider.

---

## Quick Reference

### TL;DR untuk Developer

**Secrets Keycloak sudah di-set di repository!** Anda TIDAK perlu menambahkan secrets manual.

**Yang perlu dilakukan:**

1. **Install packages**:
   ```bash
   composer require laravel/socialite socialiteproviders/keycloak
   ```

2. **Update GitHub Workflow** (`.github/workflows/your-workflow.yml`):
   ```yaml
   --build-arg KEYCLOAK_PEGAWAI_BASE_URL=${{ secrets.KEYCLOAK_PEGAWAI_BASE_URL }}
   --build-arg KEYCLOAK_PEGAWAI_CLIENT_ID=${{ secrets.KEYCLOAK_PEGAWAI_CLIENT_ID }}
   --build-arg KEYCLOAK_PEGAWAI_CLIENT_SECRET=${{ secrets.KEYCLOAK_PEGAWAI_CLIENT_SECRET }}
   --build-arg KEYCLOAK_PEGAWAI_REDIRECT_URI=${{ secrets.KEYCLOAK_PEGAWAI_REDIRECT_URI }}
   --build-arg KEYCLOAK_PEGAWAI_REALM=${{ secrets.KEYCLOAK_PEGAWAI_REALM }}
   --build-arg KEYCLOAK_PUBLIK_BASE_URL=${{ secrets.KEYCLOAK_PUBLIK_BASE_URL }}
   --build-arg KEYCLOAK_PUBLIK_CLIENT_ID=${{ secrets.KEYCLOAK_PUBLIK_CLIENT_ID }}
   --build-arg KEYCLOAK_PUBLIK_CLIENT_SECRET=${{ secrets.KEYCLOAK_PUBLIK_CLIENT_SECRET }}
   --build-arg KEYCLOAK_PUBLIK_REDIRECT_URI=${{ secrets.KEYCLOAK_PUBLIK_REDIRECT_URI }}
   --build-arg KEYCLOAK_PUBLIK_REALM=${{ secrets.KEYCLOAK_PUBLIK_REALM }}
   ```

3. **Update Dockerfile** - tambahkan ARG dan ENV (lihat [Langkah 1B](#langkah-1-environment-configuration))

4. **Buat struktur file**:
   ```
   app/
   ├── Socialite/
   │   ├── KeycloakPegawaiProvider.php
   │   ├── KeycloakPublikProvider.php
   │   ├── KeycloakPegawaiExtendSocialite.php
   │   └── KeycloakPublikExtendSocialite.php
   ├── Providers/
   │   └── SocialiteServiceProvider.php
   └── Http/Controllers/Auth/
       └── LoginController.php
   ```

5. **Database migration** (pilih salah satu):
   - **Opsi A (Recommended)**: Laravel Migration
     ```bash
     php artisan make:migration add_sso_fields_to_users_table
     # Tambahkan: tipe, nip, nik, groups_data, role
     php artisan migrate
     ```
   - **Opsi B**: Langsung dari phpMyAdmin di mysql.kalbarprov.app
     ```sql
     ALTER TABLE users ADD COLUMN tipe VARCHAR(255) NULL AFTER email;
     ALTER TABLE users ADD COLUMN nip VARCHAR(255) NULL AFTER tipe;
     ALTER TABLE users ADD COLUMN nik VARCHAR(255) NULL AFTER nip;
     ALTER TABLE users ADD COLUMN groups_data TEXT NULL AFTER nik;
     ALTER TABLE users ADD COLUMN role VARCHAR(255) NULL DEFAULT 'user' AFTER groups_data;
     ```

6. **Routes**: Tambahkan routes untuk SSO (lihat [Langkah 8](#langkah-8-routes-configuration))

**Secrets yang tersedia di repository:**
- `KEYCLOAK_PEGAWAI_BASE_URL`, `KEYCLOAK_PEGAWAI_CLIENT_ID`, `KEYCLOAK_PEGAWAI_CLIENT_SECRET`, `KEYCLOAK_PEGAWAI_REDIRECT_URI`, `KEYCLOAK_PEGAWAI_REALM`
- `KEYCLOAK_PUBLIK_BASE_URL`, `KEYCLOAK_PUBLIK_CLIENT_ID`, `KEYCLOAK_PUBLIK_CLIENT_SECRET`, `KEYCLOAK_PUBLIK_REDIRECT_URI`, `KEYCLOAK_PUBLIK_REALM`

---

## Arsitektur & Konsep

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     User mengakses aplikasi                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Halaman Pilihan Login (Opsional)                │
│   ┌──────────────────┐          ┌──────────────────┐       │
│   │  Login Pegawai   │          │  Login Publik    │       │
│   │   (SSO ASN)      │          │   (SSO Publik)   │       │
│   └─────────┬────────┘          └────────┬─────────┘       │
└─────────────┼─────────────────────────────┼─────────────────┘
              │                             │
              ▼                             ▼
    ┌─────────────────┐          ┌──────────────────┐
    │  Keycloak SSO   │          │  Keycloak SSO    │
    │  Pegawai Realm  │          │  Publik Realm    │
    └────────┬────────┘          └────────┬─────────┘
             │                            │
             │ (Callback)                 │ (Callback)
             ▼                            ▼
    ┌─────────────────────────────────────────────┐
    │    LoginController Callback Handler         │
    │  ┌──────────────┐    ┌──────────────┐     │
    │  │  Pegawai CB  │    │  Publik CB   │     │
    │  └──────┬───────┘    └──────┬───────┘     │
    └─────────┼─────────────────────┼────────────┘
              │                     │
              ▼                     ▼
    ┌─────────────────────────────────────────┐
    │     Buat/Update User di Database        │
    │  • tipe: 'pegawai' / 'publik'          │
    │  • nip / nik                            │
    │  • Session: keycloak_token, sso_type   │
    └────────────────┬────────────────────────┘
                     │
                     ▼
           ┌─────────────────┐
           │  Redirect ke    │
           │  Dashboard/App  │
           └─────────────────┘
```

### Komponen Utama

1. **Custom Socialite Providers**:
   - `KeycloakPegawaiProvider` - untuk SSO ASN
   - `KeycloakPublikProvider` - untuk SSO Publik

2. **Service Configuration**:
   - Konfigurasi terpisah untuk setiap Keycloak realm

3. **Authentication Flow**:
   - Redirect ke Keycloak
   - Callback handling
   - User creation/update
   - Session management

4. **User Differentiation**:
   - Field `tipe` ('pegawai' atau 'publik')
   - Field `nip` untuk pegawai
   - Field `nik` untuk publik

---

## Prerequisites

### 1. Keycloak Server
Pastikan Anda memiliki akses ke:
- **Keycloak Server URL** (contoh: `https://asn-sso.example.com`)
- **Realm Pegawai** dengan client ID dan secret
- **Realm Publik** dengan client ID dan secret

### 2. Laravel Project
- Laravel 11 atau lebih tinggi
- PHP 8.2+
- Composer

### 3. Package Dependencies
Tambahkan di `composer.json`:
```json
{
    "require": {
        "laravel/socialite": "^5.21",
        "socialiteproviders/keycloak": "^5.3"
    }
}
```

Install:
```bash
composer require laravel/socialite socialiteproviders/keycloak
```

---

## Langkah Implementasi

### Langkah 1: Environment Configuration

**CATATAN PENTING**: Untuk project di repository organisasi, secrets Keycloak **SUDAH DI-SET DI LEVEL REPOSITORY** oleh administrator. Developer **TIDAK PERLU** menambahkan secrets ini secara manual.

#### Secrets yang Sudah Tersedia di Repository:
- `KEYCLOAK_PEGAWAI_BASE_URL`
- `KEYCLOAK_PEGAWAI_CLIENT_ID`
- `KEYCLOAK_PEGAWAI_CLIENT_SECRET`
- `KEYCLOAK_PEGAWAI_REDIRECT_URI`
- `KEYCLOAK_PEGAWAI_REALM`
- `KEYCLOAK_PUBLIK_BASE_URL`
- `KEYCLOAK_PUBLIK_CLIENT_ID`
- `KEYCLOAK_PUBLIK_CLIENT_SECRET`
- `KEYCLOAK_PUBLIK_REDIRECT_URI`
- `KEYCLOAK_PUBLIK_REALM`

#### A. Untuk Deployment dengan GitHub Actions (Production/Staging)

Developer hanya perlu menambahkan build arguments di **GitHub Workflow** (`.github/workflows/your-workflow.yml`):

```yaml
- name: Build Docker image
  run: |
    docker build -t your-app:latest \
      --build-arg KEYCLOAK_PEGAWAI_BASE_URL=${{ secrets.KEYCLOAK_PEGAWAI_BASE_URL }} \
      --build-arg KEYCLOAK_PEGAWAI_CLIENT_ID=${{ secrets.KEYCLOAK_PEGAWAI_CLIENT_ID }} \
      --build-arg KEYCLOAK_PEGAWAI_CLIENT_SECRET=${{ secrets.KEYCLOAK_PEGAWAI_CLIENT_SECRET }} \
      --build-arg KEYCLOAK_PEGAWAI_REDIRECT_URI=${{ secrets.KEYCLOAK_PEGAWAI_REDIRECT_URI }} \
      --build-arg KEYCLOAK_PEGAWAI_REALM=${{ secrets.KEYCLOAK_PEGAWAI_REALM }} \
      --build-arg KEYCLOAK_PUBLIK_BASE_URL=${{ secrets.KEYCLOAK_PUBLIK_BASE_URL }} \
      --build-arg KEYCLOAK_PUBLIK_CLIENT_ID=${{ secrets.KEYCLOAK_PUBLIK_CLIENT_ID }} \
      --build-arg KEYCLOAK_PUBLIK_CLIENT_SECRET=${{ secrets.KEYCLOAK_PUBLIK_CLIENT_SECRET }} \
      --build-arg KEYCLOAK_PUBLIK_REDIRECT_URI=${{ secrets.KEYCLOAK_PUBLIK_REDIRECT_URI }} \
      --build-arg KEYCLOAK_PUBLIK_REALM=${{ secrets.KEYCLOAK_PUBLIK_REALM }} \
      .
```

**Contoh lengkap dari POLISE repository**:
```yaml
- name: Build Docker image
  run: docker build -t kominfo/${{ steps.repo_name.outputs.name }}_development:latest -f Dockerfile \
    --build-arg DB_HOST=${{ secrets.DB_HOST }} \
    --build-arg DB_USERNAME=${{ secrets.DB_USER }} \
    --build-arg DB_PASSWORD=${{ secrets.DB_PASSWORD }} \
    --build-arg DB_DATABASE=${{ secrets.DB_DATABASE }} \
    --build-arg KEYCLOAK_PEGAWAI_BASE_URL=${{ secrets.KEYCLOAK_PEGAWAI_BASE_URL }} \
    --build-arg KEYCLOAK_PEGAWAI_CLIENT_ID=${{ secrets.KEYCLOAK_PEGAWAI_CLIENT_ID }} \
    --build-arg KEYCLOAK_PEGAWAI_CLIENT_SECRET=${{ secrets.KEYCLOAK_PEGAWAI_CLIENT_SECRET }} \
    --build-arg KEYCLOAK_PEGAWAI_REDIRECT_URI=${{ secrets.KEYCLOAK_PEGAWAI_REDIRECT_URI }} \
    --build-arg KEYCLOAK_PEGAWAI_REALM=${{ secrets.KEYCLOAK_PEGAWAI_REALM }} \
    --build-arg KEYCLOAK_PUBLIK_BASE_URL=${{ secrets.KEYCLOAK_PUBLIK_BASE_URL }} \
    --build-arg KEYCLOAK_PUBLIK_CLIENT_ID=${{ secrets.KEYCLOAK_PUBLIK_CLIENT_ID }} \
    --build-arg KEYCLOAK_PUBLIK_CLIENT_SECRET=${{ secrets.KEYCLOAK_PUBLIK_CLIENT_SECRET }} \
    --build-arg KEYCLOAK_PUBLIK_REDIRECT_URI=${{ secrets.KEYCLOAK_PUBLIK_REDIRECT_URI }} \
    --build-arg KEYCLOAK_PUBLIK_REALM=${{ secrets.KEYCLOAK_PUBLIK_REALM }} \
    .
```

#### B. Konfigurasi di Dockerfile

Tambahkan ARG dan ENV di **Dockerfile**:

```dockerfile
# Build arguments untuk Keycloak SSO
ARG KEYCLOAK_PEGAWAI_BASE_URL
ARG KEYCLOAK_PEGAWAI_CLIENT_ID
ARG KEYCLOAK_PEGAWAI_CLIENT_SECRET
ARG KEYCLOAK_PEGAWAI_REDIRECT_URI
ARG KEYCLOAK_PEGAWAI_REALM
ARG KEYCLOAK_PUBLIK_BASE_URL
ARG KEYCLOAK_PUBLIK_CLIENT_ID
ARG KEYCLOAK_PUBLIK_CLIENT_SECRET
ARG KEYCLOAK_PUBLIK_REDIRECT_URI
ARG KEYCLOAK_PUBLIK_REALM

# Set environment variables
ENV KEYCLOAK_PEGAWAI_BASE_URL=${KEYCLOAK_PEGAWAI_BASE_URL}
ENV KEYCLOAK_PEGAWAI_CLIENT_ID=${KEYCLOAK_PEGAWAI_CLIENT_ID}
ENV KEYCLOAK_PEGAWAI_CLIENT_SECRET=${KEYCLOAK_PEGAWAI_CLIENT_SECRET}
ENV KEYCLOAK_PEGAWAI_REDIRECT_URI=${KEYCLOAK_PEGAWAI_REDIRECT_URI}
ENV KEYCLOAK_PEGAWAI_REALM=${KEYCLOAK_PEGAWAI_REALM}
ENV KEYCLOAK_PUBLIK_BASE_URL=${KEYCLOAK_PUBLIK_BASE_URL}
ENV KEYCLOAK_PUBLIK_CLIENT_ID=${KEYCLOAK_PUBLIK_CLIENT_ID}
ENV KEYCLOAK_PUBLIK_CLIENT_SECRET=${KEYCLOAK_PUBLIK_CLIENT_SECRET}
ENV KEYCLOAK_PUBLIK_REDIRECT_URI=${KEYCLOAK_PUBLIK_REDIRECT_URI}
ENV KEYCLOAK_PUBLIK_REALM=${KEYCLOAK_PUBLIK_REALM}
```

#### C. Untuk Development Lokal

Untuk development lokal, tambahkan di file `.env` (TIDAK DI-COMMIT ke repository):

```env
# SSO Pegawai/ASN Configuration
KEYCLOAK_PEGAWAI_BASE_URL=https://asn-sso.kalbarprov.go.id
KEYCLOAK_PEGAWAI_CLIENT_ID=kalbar-pegawai
KEYCLOAK_PEGAWAI_CLIENT_SECRET=your-local-dev-secret
KEYCLOAK_PEGAWAI_REDIRECT_URI=http://localhost:8000/sso-login-pegawai-callback
KEYCLOAK_PEGAWAI_REALM=kominfo-pegawai

# SSO Publik Configuration (jika ada)
KEYCLOAK_PUBLIK_BASE_URL=https://publik-sso.example.com
KEYCLOAK_PUBLIK_CLIENT_ID=your-publik-client-id
KEYCLOAK_PUBLIK_CLIENT_SECRET=your-local-dev-secret
KEYCLOAK_PUBLIK_REDIRECT_URI=http://localhost:8000/sso-login-publik-callback
KEYCLOAK_PUBLIK_REALM=publik-realm
```

**PENTING**:
- ✅ Secrets sudah dikonfigurasi di repository level oleh administrator
- ✅ Developer hanya perlu referensi secrets di workflow dan Dockerfile
- ❌ JANGAN menambahkan secrets manual ke repository settings
- ❌ File `.env` lokal TIDAK boleh di-commit ke repository
- ⚠️ Redirect URI untuk local development berbeda dengan production

---

### Langkah 2: Service Configuration

Edit file `config/services.php`:

```php
<?php

return [
    // ... konfigurasi service lain ...

    'keycloak_pegawai' => [
        'base_url' => env('KEYCLOAK_PEGAWAI_BASE_URL', 'https://asn-sso.example.com'),
        'client_id' => env('KEYCLOAK_PEGAWAI_CLIENT_ID'),
        'client_secret' => env('KEYCLOAK_PEGAWAI_CLIENT_SECRET'),
        'redirect' => env('KEYCLOAK_PEGAWAI_REDIRECT_URI', config('app.url') . '/sso-login-pegawai-callback'),
        'realms' => env('KEYCLOAK_PEGAWAI_REALM', 'pegawai'),
    ],

    'keycloak_publik' => [
        'base_url' => env('KEYCLOAK_PUBLIK_BASE_URL', 'https://publik-sso.example.com'),
        'client_id' => env('KEYCLOAK_PUBLIK_CLIENT_ID'),
        'client_secret' => env('KEYCLOAK_PUBLIK_CLIENT_SECRET'),
        'redirect' => env('KEYCLOAK_PUBLIK_REDIRECT_URI', config('app.url') . '/sso-login-publik-callback'),
        'realms' => env('KEYCLOAK_PUBLIK_REALM', 'publik'),
    ],
];
```

---

### Langkah 3: Custom Socialite Providers

#### 3.1 Buat KeycloakPegawaiProvider

File: `app/Socialite/KeycloakPegawaiProvider.php`

```php
<?php

namespace App\Socialite;

use SocialiteProviders\Keycloak\Provider as KeycloakProvider;

class KeycloakPegawaiProvider extends KeycloakProvider
{
    public const IDENTIFIER = 'KEYCLOAK_PEGAWAI';

    protected function getBaseUrl()
    {
        $baseUrl = config('services.keycloak_pegawai.base_url');
        $realms = config('services.keycloak_pegawai.realms');

        return rtrim(rtrim($baseUrl, '/').'/realms/'.$realms, '/');
    }
}
```

#### 3.2 Buat KeycloakPublikProvider

File: `app/Socialite/KeycloakPublikProvider.php`

```php
<?php

namespace App\Socialite;

use SocialiteProviders\Keycloak\Provider as KeycloakProvider;

class KeycloakPublikProvider extends KeycloakProvider
{
    public const IDENTIFIER = 'KEYCLOAK_PUBLIK';

    protected function getBaseUrl()
    {
        $baseUrl = config('services.keycloak_publik.base_url');
        $realms = config('services.keycloak_publik.realms');

        return rtrim(rtrim($baseUrl, '/').'/realms/'.$realms, '/');
    }
}
```

#### 3.3 Buat ExtendSocialite Classes

File: `app/Socialite/KeycloakPegawaiExtendSocialite.php`

```php
<?php

namespace App\Socialite;

use SocialiteProviders\Manager\SocialiteWasCalled;

class KeycloakPegawaiExtendSocialite
{
    public function handle(SocialiteWasCalled $socialiteWasCalled)
    {
        $socialiteWasCalled->extendSocialite('keycloak_pegawai', KeycloakPegawaiProvider::class);
    }
}
```

File: `app/Socialite/KeycloakPublikExtendSocialite.php`

```php
<?php

namespace App\Socialite;

use SocialiteProviders\Manager\SocialiteWasCalled;

class KeycloakPublikExtendSocialite
{
    public function handle(SocialiteWasCalled $socialiteWasCalled)
    {
        $socialiteWasCalled->extendSocialite('keycloak_publik', KeycloakPublikProvider::class);
    }
}
```

---

### Langkah 4: Register Custom Providers

#### 4.1 Buat SocialiteServiceProvider

File: `app/Providers/SocialiteServiceProvider.php`

```php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Laravel\Socialite\Facades\Socialite;
use App\Socialite\KeycloakPegawaiProvider;
use App\Socialite\KeycloakPublikProvider;

class SocialiteServiceProvider extends ServiceProvider
{
    public function register()
    {
        //
    }

    public function boot()
    {
        // Mendaftarkan driver keycloak_pegawai
        Socialite::extend('keycloak_pegawai', function ($app) {
            $config = config('services.keycloak_pegawai');

            return new KeycloakPegawaiProvider(
                $app['request'],
                $config['client_id'],
                $config['client_secret'],
                $config['redirect'],
                $config
            );
        });

        // Mendaftarkan driver keycloak_publik
        Socialite::extend('keycloak_publik', function ($app) {
            $config = config('services.keycloak_publik');

            return new KeycloakPublikProvider(
                $app['request'],
                $config['client_id'],
                $config['client_secret'],
                $config['redirect'],
                $config
            );
        });
    }
}
```

#### 4.2 Register di config/app.php

Edit `config/app.php`, tambahkan di array `providers`:

```php
'providers' => [
    // ... providers lain ...

    App\Providers\SocialiteServiceProvider::class,
],
```

---

### Langkah 5: Database Migration

Tambahkan kolom yang diperlukan untuk dual SSO. Anda memiliki **2 opsi**:

#### Opsi A: Menggunakan Laravel Migration (Recommended)

**Langkah 1**: Buat file migration

```bash
php artisan make:migration add_sso_fields_to_users_table
```

**Langkah 2**: Edit file migration yang dibuat

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            // Tipe user: 'pegawai' atau 'publik'
            $table->string('tipe')->nullable()->after('email');

            // NIP untuk pegawai
            $table->string('nip')->nullable()->after('tipe')->index();

            // NIK untuk publik
            $table->string('nik')->nullable()->after('nip')->index();

            // Menyimpan data groups dari Keycloak
            $table->text('groups_data')->nullable()->after('nik');

            // Role untuk akses aplikasi
            $table->string('role')->nullable()->default('user')->after('groups_data');
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['tipe', 'nip', 'nik', 'groups_data', 'role']);
        });
    }
};
```

**Langkah 3**: Jalankan migration

```bash
php artisan migrate
```

**Keuntungan**:
- ✅ Versioning dan history perubahan database
- ✅ Rollback jika terjadi masalah
- ✅ Konsisten dengan Laravel best practices
- ✅ Automatis saat deployment

#### Opsi B: Langsung dari phpMyAdmin (mysql.kalbarprov.app)

Jika Anda ingin langsung menambahkan kolom via phpMyAdmin:

**Langkah 1**: Akses phpMyAdmin di [mysql.kalbarprov.app](https://mysql.kalbarprov.app)

**Langkah 2**: Pilih database Anda, kemudian tabel `users`

**Langkah 3**: Klik tab "Structure" → "Add column"

**Langkah 4**: Jalankan SQL query berikut:

```sql
-- Tambahkan kolom untuk dual SSO
ALTER TABLE `users`
ADD COLUMN `tipe` VARCHAR(255) NULL AFTER `email`,
ADD COLUMN `nip` VARCHAR(255) NULL AFTER `tipe`,
ADD COLUMN `nik` VARCHAR(255) NULL AFTER `nip`,
ADD COLUMN `groups_data` TEXT NULL AFTER `nik`,
ADD COLUMN `role` VARCHAR(255) NULL DEFAULT 'user' AFTER `groups_data`;

-- Tambahkan index untuk performa
ALTER TABLE `users`
ADD INDEX `users_nip_index` (`nip`),
ADD INDEX `users_nik_index` (`nik`);
```

**Atau tambahkan satu per satu via UI**:

| Column Name | Type | Length | Default | Null | Index | After |
|-------------|------|--------|---------|------|-------|-------|
| tipe | VARCHAR | 255 | NULL | Yes | - | email |
| nip | VARCHAR | 255 | NULL | Yes | INDEX | tipe |
| nik | VARCHAR | 255 | NULL | Yes | INDEX | nip |
| groups_data | TEXT | - | NULL | Yes | - | nik |
| role | VARCHAR | 255 | user | Yes | - | groups_data |

**Langkah 5**: Verify struktur tabel

```sql
DESCRIBE users;
```

**Keuntungan**:
- ✅ Quick & direct access
- ✅ Tidak perlu akses ke server/container
- ✅ Visual interface untuk non-developer

**Kekurangan**:
- ⚠️ Tidak ada versioning
- ⚠️ Tidak ada rollback otomatis
- ⚠️ Perlu manual documentation

#### Rekomendasi

Untuk project yang menggunakan CI/CD dan Git workflow, **gunakan Opsi A (Laravel Migration)** karena:
1. Migration otomatis dijalankan saat deployment
2. Perubahan database ter-track di Git
3. Mudah di-rollback jika ada masalah
4. Tim dapat review perubahan database via Pull Request

Gunakan **Opsi B (phpMyAdmin)** hanya untuk:
- Quick fix di production
- Database troubleshooting
- Saat tidak memiliki akses ke aplikasi server

---

### Langkah 6: Update User Model

Edit `app/Models/User.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'tipe',          // 'pegawai' atau 'publik'
        'nip',           // untuk pegawai
        'nik',           // untuk publik
        'groups_data',   // groups dari Keycloak
        'role',          // role aplikasi
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    /**
     * Check apakah user adalah pegawai
     */
    public function isPegawai()
    {
        return $this->tipe === 'pegawai';
    }

    /**
     * Check apakah user adalah publik
     */
    public function isPublik()
    {
        return $this->tipe === 'publik';
    }
}
```

---

### Langkah 7: LoginController

File: `app/Http/Controllers/Auth/LoginController.php`

```php
<?php

namespace App\Http\Controllers\Auth;

use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Facades\Log;

class LoginController extends Controller
{
    /**
     * Redirect ke SSO Pegawai (ASN)
     */
    public function redirectToPegawaiKeycloak()
    {
        Log::info('Redirecting to Pegawai Keycloak', [
            'base_url' => config('services.keycloak_pegawai.base_url'),
            'client_id' => config('services.keycloak_pegawai.client_id'),
        ]);

        return Socialite::driver('keycloak_pegawai')
            ->scopes(['openid'])
            ->redirect();
    }

    /**
     * Redirect ke SSO Publik
     */
    public function redirectToPublikKeycloak()
    {
        Log::info('Redirecting to Publik Keycloak', [
            'base_url' => config('services.keycloak_publik.base_url'),
            'client_id' => config('services.keycloak_publik.client_id'),
        ]);

        return Socialite::driver('keycloak_publik')
            ->scopes(['openid'])
            ->redirect();
    }

    /**
     * Handle callback dari SSO Pegawai
     */
    public function handlePegawaiKeycloakCallback()
    {
        Log::info('Handling Pegawai Keycloak callback');

        try {
            $keycloakUser = Socialite::driver('keycloak_pegawai')->user();

            Log::info('Pegawai Keycloak user data:', [
                'email' => $keycloakUser->email,
                'id' => $keycloakUser->id
            ]);

            // Simpan token dan tipe SSO di session
            session([
                'keycloak_token' => $keycloakUser->token,
                'sso_type' => 'sso_pegawai'
            ]);

            // Mengambil NIP sebagai username
            $nip = $keycloakUser->nickname ?? $keycloakUser->user['preferred_username'] ?? null;

            if (!$nip) {
                throw new \Exception('NIP tidak ditemukan dari Keycloak');
            }

            // Cari atau buat user
            $existingUser = User::query()
                ->where('nip', $nip)
                ->where('tipe', 'pegawai')
                ->whereNotNull('nip')
                ->first();

            if (!$existingUser) {
                $existingUser = User::create([
                    'tipe' => 'pegawai',
                    'nip' => $nip,
                    'name' => $keycloakUser->name,
                    'email' => $keycloakUser->email ?? $nip . '@example.com',
                    'groups_data' => json_encode($keycloakUser->user['groups'] ?? []),
                    'password' => bcrypt(str()->random(32)), // Random password
                ]);
            } else {
                // Update data user
                $existingUser->name = $keycloakUser->name;
                $existingUser->groups_data = json_encode($keycloakUser->user['groups'] ?? []);
                $existingUser->save();
            }

            // Login user
            Auth::login($existingUser);
            session()->save();

            Log::info('Pegawai authentication successful');

            return redirect()->intended('/dashboard');

        } catch (\Exception $e) {
            Log::error('Pegawai Keycloak callback error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);

            return redirect()->route('login')
                ->with('error', 'Gagal login menggunakan SSO Pegawai. Silakan coba lagi.');
        }
    }

    /**
     * Handle callback dari SSO Publik
     */
    public function handlePublikKeycloakCallback()
    {
        Log::info('Handling Publik Keycloak callback');

        try {
            $keycloakUser = Socialite::driver('keycloak_publik')->user();

            Log::info('Publik Keycloak user data:', [
                'email' => $keycloakUser->email,
                'id' => $keycloakUser->id
            ]);

            // Simpan token dan tipe SSO di session
            session([
                'keycloak_token' => $keycloakUser->token,
                'sso_type' => 'sso_publik'
            ]);

            // Mengambil NIK untuk masyarakat
            $nik = $keycloakUser->user['preferred_username'] ?? null;

            if (!$nik) {
                throw new \Exception('NIK tidak ditemukan dari Keycloak');
            }

            // Cari atau buat user
            $existingUser = User::query()
                ->where('nik', $nik)
                ->where('tipe', 'publik')
                ->whereNotNull('nik')
                ->first();

            if (!$existingUser) {
                $existingUser = User::create([
                    'tipe' => 'publik',
                    'nik' => $nik,
                    'name' => $keycloakUser->name,
                    'email' => $keycloakUser->email ?? $nik . '@publik.example.com',
                    'groups_data' => json_encode($keycloakUser->user['groups'] ?? []),
                    'password' => bcrypt(str()->random(32)), // Random password
                ]);
            } else {
                // Update data user
                $existingUser->name = $keycloakUser->name;
                $existingUser->groups_data = json_encode($keycloakUser->user['groups'] ?? []);
                $existingUser->save();
            }

            // Login user
            Auth::login($existingUser);
            session()->save();

            Log::info('Publik authentication successful');

            return redirect()->intended('/dashboard');

        } catch (\Exception $e) {
            Log::error('Publik Keycloak callback error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);

            return redirect()->route('login')
                ->with('error', 'Gagal login menggunakan SSO Publik. Silakan coba lagi.');
        }
    }

    /**
     * Logout dan redirect ke Keycloak logout
     */
    public function logout()
    {
        $userType = Auth::user()->tipe ?? 'pegawai';

        // Logout dari aplikasi
        Auth::logout();
        session()->invalidate();
        session()->regenerateToken();

        // Redirect ke Keycloak logout endpoint
        $redirectUri = urlencode(url(''));

        if ($userType === 'pegawai') {
            $clientId = config('services.keycloak_pegawai.client_id');
            $baseUrl = config('services.keycloak_pegawai.base_url');
            $realm = config('services.keycloak_pegawai.realms');
        } else {
            $clientId = config('services.keycloak_publik.client_id');
            $baseUrl = config('services.keycloak_publik.base_url');
            $realm = config('services.keycloak_publik.realms');
        }

        $logoutUrl = "{$baseUrl}/realms/{$realm}/protocol/openid-connect/logout";

        return redirect()->away($logoutUrl);
    }
}
```

---

### Langkah 8: Routes Configuration

Edit `routes/web.php`:

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\LoginController;

// Route untuk redirect ke SSO
Route::get('login/pegawai', [LoginController::class, 'redirectToPegawaiKeycloak'])
    ->name('login.pegawai');

Route::get('login/publik', [LoginController::class, 'redirectToPublikKeycloak'])
    ->name('login.publik');

// Route untuk callback dari SSO
Route::get('sso-login-pegawai-callback', [LoginController::class, 'handlePegawaiKeycloakCallback'])
    ->name('login.pegawai.callback');

Route::get('sso-login-publik-callback', [LoginController::class, 'handlePublikKeycloakCallback'])
    ->name('login.publik.callback');

// Route logout
Route::get('logout', [LoginController::class, 'logout'])
    ->name('logout');

// Route protected dengan auth middleware
Route::middleware(['auth'])->group(function () {
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');
});
```

---

### Langkah 9: Login Page (Opsional)

Buat halaman untuk memilih jenis login:

File: `resources/views/auth/login.blade.php`

```blade
@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">Login</div>

                <div class="card-body">
                    @if (session('error'))
                        <div class="alert alert-danger">
                            {{ session('error') }}
                        </div>
                    @endif

                    <div class="text-center mb-4">
                        <h4>Silakan pilih metode login</h4>
                    </div>

                    <div class="d-flex justify-content-center gap-3">
                        <a href="{{ route('login.pegawai') }}" class="btn btn-primary btn-lg">
                            <i class="fas fa-user-tie"></i>
                            Login sebagai Pegawai (SSO ASN)
                        </a>

                        <a href="{{ route('login.publik') }}" class="btn btn-success btn-lg">
                            <i class="fas fa-users"></i>
                            Login sebagai Publik
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
```

---

## Konfigurasi Tambahan

### Session Configuration

Edit `config/session.php`:

```php
return [
    'lifetime' => 120, // Session lifetime dalam menit
    'expire_on_close' => false,
    'same_site' => 'lax', // Penting untuk SSO
    'secure' => env('SESSION_SECURE_COOKIE', true), // HTTPS
    'http_only' => true,
];
```

### Middleware (Opsional)

Jika ingin membedakan akses berdasarkan tipe user:

File: `app/Http/Middleware/PegawaiOnly.php`

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class PegawaiOnly
{
    public function handle(Request $request, Closure $next)
    {
        if (auth()->check() && auth()->user()->isPegawai()) {
            return $next($request);
        }

        return redirect('/')->with('error', 'Akses hanya untuk pegawai');
    }
}
```

Register di `app/Http/Kernel.php`:

```php
protected $routeMiddleware = [
    // ... middleware lain ...
    'pegawai.only' => \App\Http\Middleware\PegawaiOnly::class,
];
```

---

## Testing & Troubleshooting

### Testing Manual

1. **Test SSO Pegawai**:
   ```
   Akses: https://yourdomain.com/login/pegawai
   Expected: Redirect ke Keycloak SSO Pegawai
   Login dengan NIP
   Expected: Redirect kembali ke aplikasi dan user terautentikasi
   ```

2. **Test SSO Publik**:
   ```
   Akses: https://yourdomain.com/login/publik
   Expected: Redirect ke Keycloak SSO Publik
   Login dengan NIK
   Expected: Redirect kembali ke aplikasi dan user terautentikasi
   ```

3. **Verify Database**:
   ```sql
   SELECT id, name, tipe, nip, nik FROM users;
   ```
   Expected: User dengan tipe 'pegawai' memiliki NIP, user dengan tipe 'publik' memiliki NIK

### Common Issues

#### 1. Redirect URI Mismatch
**Error**: `invalid_redirect_uri`

**Solution**:
- Pastikan URL callback di `.env` sama persis dengan yang terdaftar di Keycloak
- Check trailing slash
- Pastikan menggunakan HTTPS di production

#### 2. Invalid Client Credentials
**Error**: `Unauthorized client` atau `invalid_client`

**Solution**:
- Verify `KEYCLOAK_*_CLIENT_ID` dan `KEYCLOAK_*_CLIENT_SECRET`
- Pastikan client secret di-copy dengan benar dari Keycloak
- Check client access type adalah `confidential`

#### 3. Token Validation Failed
**Error**: Token validation error

**Solution**:
- Clear cache: `php artisan config:clear`
- Verify base URL dan realm di konfigurasi
- Check network connectivity ke Keycloak server

#### 4. User Attribute Missing
**Error**: NIK atau NIP tidak ditemukan

**Solution**:
- Check Keycloak user mappers
- Pastikan field `preferred_username` atau `nickname` terisi
- Custom mapper di Keycloak jika perlu:
  ```
  Client Scopes → openid → Mappers → Create
  Mapper Type: User Property
  Property: username
  Token Claim Name: preferred_username
  ```

### Logging untuk Debug

Tambahkan logging di callback handler:

```php
Log::info('Keycloak User Data', [
    'user' => $keycloakUser->user,
    'email' => $keycloakUser->email,
    'name' => $keycloakUser->name,
    'nickname' => $keycloakUser->nickname,
    'token' => substr($keycloakUser->token, 0, 20) . '...',
]);
```

Check logs:
```bash
tail -f storage/logs/laravel.log
```

### Testing dengan Artisan Tinker

```php
php artisan tinker

// Check konfigurasi
config('services.keycloak_pegawai');
config('services.keycloak_publik');

// Check user
$user = User::where('tipe', 'pegawai')->first();
$user->isPegawai(); // should return true
$user->isPublik();  // should return false
```

---

## Best Practices untuk Developer

### 1. Secrets Management
- ❌ **JANGAN** commit file `.env` ke repository
- ❌ **JANGAN** menambahkan secrets manual ke repository settings
- ✅ Referensi `${{ secrets.KEYCLOAK_* }}` di workflow
- 📝 Untuk local development, gunakan `.env` lokal (tidak di-commit)
- 📝 Tambahkan `.env` ke `.gitignore`

### 2. Code Organization
- Pisahkan logic SSO pegawai dan publik dengan jelas
- Gunakan helper methods (`isPegawai()`, `isPublik()`) untuk readability
- Log setiap step authentication untuk debugging

### 3. Session & Security
- Set session timeout yang wajar (default 120 menit)
- Pastikan `SESSION_SECURE_COOKIE=true` di production
- CSRF protection otomatis aktif di Laravel

### 4. Database
- **Recommended**: Gunakan Laravel migration untuk database changes
- Tambahkan index pada kolom `nip` dan `nik` untuk performa
- Jangan lupa rollback method di migration

### 5. Testing
- Test kedua flow SSO (pegawai dan publik) setelah implementasi
- Verify data user tersimpan dengan benar di database
- Test logout flow untuk memastikan session dibersihkan

---

## Deployment Checklist untuk Developer

### Pre-deployment
- [ ] Code sudah di-commit dan push ke branch
- [ ] Migration file sudah dibuat (jika perlu)
- [ ] Workflow GitHub Actions sudah update dengan build args
- [ ] Dockerfile sudah memiliki ARG dan ENV untuk Keycloak
- [ ] Routes sudah terdaftar di `routes/web.php`

### Saat Deployment (Otomatis via CI/CD)
GitHub Actions akan otomatis:
- Build Docker image dengan secrets dari repository
- Run migration (jika dikonfigurasi)
- Deploy ke environment target

### Post-deployment
- [ ] Test SSO Pegawai: `/login/pegawai`
- [ ] Test SSO Publik: `/login/publik`
- [ ] Verify user data di database
- [ ] Test logout flow
- [ ] Monitor logs untuk error

---

## Advanced Configuration

### Single Logout (SLO)

Implementasi global logout yang juga logout dari Keycloak:

```php
public function logout(Request $request)
{
    $userType = Auth::user()->tipe;
    $token = session('keycloak_token');

    // Logout dari aplikasi
    Auth::logout();
    $request->session()->invalidate();
    $request->session()->regenerateToken();

    // Panggil Keycloak logout endpoint
    if ($userType === 'pegawai') {
        $config = config('services.keycloak_pegawai');
    } else {
        $config = config('services.keycloak_publik');
    }

    $logoutUrl = "{$config['base_url']}/realms/{$config['realms']}/protocol/openid-connect/logout";

    // Optional: revoke token
    if ($token) {
        Http::post("{$config['base_url']}/realms/{$config['realms']}/protocol/openid-connect/revoke", [
            'client_id' => $config['client_id'],
            'client_secret' => $config['client_secret'],
            'token' => $token,
        ]);
    }

    return redirect()->away($logoutUrl);
}
```

---

## FAQ

### Pertanyaan Umum untuk Developer

#### 1. Apakah saya perlu mengatur secrets Keycloak?
**Tidak**. Secrets Keycloak sudah di-set di repository level oleh administrator. Anda hanya perlu mereferensikan `${{ secrets.KEYCLOAK_* }}` di workflow dan menambahkan ARG/ENV di Dockerfile.

#### 2. Bagaimana cara testing SSO di local development?
Tambahkan environment variables di file `.env` lokal (jangan di-commit). Gunakan `http://localhost:8000/sso-login-*-callback` sebagai redirect URI untuk local development.

#### 3. Apakah bisa menggunakan satu realm Keycloak untuk kedua SSO?
Secara teknis bisa, namun **tidak disarankan**. Memisahkan realm memudahkan management user pegawai vs publik dengan policy dan configuration yang berbeda.

#### 4. Database migration via Laravel atau phpMyAdmin?
**Recommended**: Laravel migration untuk konsistensi dengan CI/CD workflow. Gunakan phpMyAdmin hanya untuk quick fix atau troubleshooting di production.

#### 5. Bagaimana cara menambahkan field custom di user?
Edit migration file untuk menambahkan kolom baru, kemudian tambahkan ke `$fillable` array di User model. Update callback handler di LoginController untuk menyimpan data tambahan dari Keycloak.

#### 6. Error "invalid_redirect_uri" muncul saat callback
Pastikan redirect URI di konfigurasi sama persis (termasuk protokol http/https dan trailing slash) dengan yang didaftarkan di Keycloak client. Hubungi administrator untuk verifikasi konfigurasi Keycloak.

#### 7. Session expired terlalu cepat
Edit `config/session.php` dan sesuaikan `lifetime` (dalam menit). Default adalah 120 menit.

#### 8. Bagaimana cara membedakan user pegawai vs publik di aplikasi?
Gunakan helper method di User model:
```php
if (auth()->user()->isPegawai()) {
    // Logic untuk pegawai
} else if (auth()->user()->isPublik()) {
    // Logic untuk publik
}
```

#### 9. Apakah perlu membuat Keycloak client sendiri?
**Tidak**. Keycloak clients sudah dikonfigurasi oleh administrator organisasi. Anda hanya perlu menggunakan credentials yang sudah tersedia di repository secrets.

---

## Kesimpulan

Dengan mengikuti panduan ini, Anda dapat mengimplementasikan sistem dual SSO yang memisahkan autentikasi untuk:
- Pegawai/ASN menggunakan NIP
- Masyarakat umum menggunakan NIK

Implementasi ini fleksibel dan dapat disesuaikan dengan kebutuhan organisasi Anda.

### Ringkasan untuk Developer

**Yang PERLU dilakukan:**
1. ✅ Install package: `laravel/socialite` dan `socialiteproviders/keycloak`
2. ✅ Buat Custom Providers (KeycloakPegawaiProvider & KeycloakPublikProvider)
3. ✅ Register providers di SocialiteServiceProvider
4. ✅ Konfigurasi `config/services.php`
5. ✅ Implementasi LoginController dengan callback handlers
6. ✅ Setup routes untuk SSO
7. ✅ Tambahkan ARG dan ENV di Dockerfile
8. ✅ Referensi `${{ secrets.KEYCLOAK_* }}` di GitHub workflow
9. ✅ Database migration untuk field `tipe`, `nip`, `nik` (via Laravel migration atau phpMyAdmin di mysql.kalbarprov.app)

**Yang TIDAK PERLU dilakukan:**
- ❌ Menambahkan secrets manual ke GitHub repository settings
- ❌ Commit file `.env` dengan credentials Keycloak
- ❌ Request akses ke Keycloak client secret (sudah di-set oleh admin)

### Key Points

🔐 **Secrets Management**: Semua credentials Keycloak sudah di-manage di repository level oleh administrator. Developer hanya perlu referensi via `${{ secrets.* }}` di workflow.

🏗️ **Architecture**: Dual SSO provider dengan custom Socialite drivers yang extend dari base Keycloak provider.

🔑 **User Differentiation**: Menggunakan field `tipe` ('pegawai'/'publik'), `nip` untuk pegawai, `nik` untuk publik.

🚀 **Deployment**: Otomatis via GitHub Actions dengan build arguments yang mengambil dari repository secrets.

💾 **Database Migration**: Fleksibel - bisa menggunakan Laravel migration (recommended untuk CI/CD) atau langsung via phpMyAdmin di mysql.kalbarprov.app (untuk quick fix).

### Referensi Tambahan
- [Laravel Socialite Documentation](https://laravel.com/docs/11.x/socialite)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [SocialiteProviders Keycloak](https://socialiteproviders.com/Keycloak/)

### Support & Kontribusi
Jika menemukan issue atau ingin berkontribusi, silakan buat issue atau pull request di repository.

---

**Versi**: 1.0
**Terakhir diupdate**: 2025-10-13
**Kompatibel dengan**: Laravel 11+, PHP 8.2+, Keycloak 20+
