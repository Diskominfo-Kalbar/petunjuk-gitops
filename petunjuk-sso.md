# Dokumentasi SSO Keycloak dengan Laravel menggunakan Socialite Keycloak Provider

Dokumen ini memberikan panduan langkah demi langkah untuk mengintegrasikan Single Sign-On (SSO) dengan Keycloak dalam aplikasi Laravel menggunakan Socialite Keycloak Provider. Socialite adalah paket Laravel yang menyederhanakan proses otentikasi pihak ketiga, dan Socialite Keycloak Provider merupakan ekstensi Socialite untuk integrasi dengan server otentikasi Keycloak.

## Persiapan

1. **Instalasi Socialite Keycloak Provider**

   Pastikan Anda telah menginstal Socialite Keycloak Provider melalui Composer dengan menjalankan perintah berikut:

   ```bash
   composer require socialiteproviders/keycloak
   ```

2. **Konfigurasi Kredensial Keycloak**

    nilai sudah tersedia tinggal di gunakan saja nilai envorionment nya
   ```dotenv
   KEYCLOAK_CLIENT_ID
   KEYCLOAK_CLIENT_SECRET
   KEYCLOAK_REDIRECT_URI
   KEYCLOAK_BASE_URL
   KEYCLOAK_REALM
   ```

3. **Konfigurasi ENV KEYCLOAK_REDIRECT_URI **

Untuk lingkungan pengembangan (`docker-compose-dev.yml`):

```yaml
version: '3.5'

services:
  your_service_name:
    user: ${MY_UID}:${MY_GID}
    build:
      context: '.'
    image: your_image_name
    networks:
      - kominfo_network
    deploy:
      placement:
        constraints:
          - node.hostname == node-manager
    environment:
      - DB_CONNECTION=mysql
      - APP_DEBUG=TRUE
      - KEYCLOAK_REDIRECT_URI=your_callback_url

networks:
  kominfo_network:
    external: true
```

Untuk lingkungan produksi (`docker-compose-prod.yml`):

```yaml
version: '3.5'

services:
  your_service_name:
    user: ${MY_UID}:${MY_GID}
    build:
      context: '.'
    image: your_image_name
    networks:
      - kominfo_network
    deploy:
      placement:
        constraints:
          - node.hostname == node-manager
    environment:
      - DB_CONNECTION=mysql
      - APP_DEBUG=FALSE
      - KEYCLOAK_REDIRECT_URI=your_callback_url

networks:
  kominfo_network:
    external: true
```

Pastikan untuk menyesuaikan nilai `your_callback_url` dengan URL callback aplikasi Laravel Anda.

## Implementasi Controller

Berikut adalah implementasi controller untuk menangani otentikasi dengan Keycloak:

```php
<?php

namespace App\Http\Controllers\Auth;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Laravel\Socialite\Facades\Socialite;

class LoginController extends Controller
{
    // ... (bagian kode lainnya)

    public function redirectToKeycloak()
    {
        return Socialite::driver('keycloak')->scopes(['openid'])->redirect();
    }

    public function handleKeycloakCallback()
    {
        try {
            $user = Socialite::driver('keycloak')->user();
        } catch (\Exception $e) {
            return redirect()->route('login');
        }

        $nip = $user->nickname;
        $existingUser = \App\Models\User::where('nip', $nip)->first();

        if ($existingUser) {
            auth()->login($existingUser);
        } else {
            $newUser = \App\Models\User::create([
                'nip' => $nip,
                // Tambahkan atribut lain sesuai kebutuhan
            ]);

            auth()->login($newUser);
        }

        \Auth::user()->name = $user->name;
        \Auth::user()->groups_data = json_encode($user->user['groups']);
        \Auth::user()->save();

        return redirect()->route('dashboard');
    }

    public function logout()
    {
        \Auth::logout();

        $redirectUri = url('');
        $clientId = env('KEYCLOAK_CLIENT_ID');
        $baseUrl = env('KEYCLOAK_BASE_URL');
        $realm = env('KEYCLOAK_REALM');
        $logoutUrl = $baseUrl . 'realms/' . $realm . '/protocol/openid-connect/logout';

        return redirect()->away("$logoutUrl?client_id=$clientId&post_logout_redirect_uri=$redirectUri");
    }
}
```

## Penggunaan dan Integrasi

1. **Pengalihan ke Keycloak**

   - Panggil metode `redirectToKeycloak()` untuk mengalihkan pengguna ke halaman otentikasi Keycloak.

2. **Callback dari Keycloak**

   - Metode `handleKeycloakCallback()` menangani respons dari Keycloak setelah otentikasi berhasil.

3. **Logout dengan Keycloak**

   - Metode `logout()` akan melakukan logout dari aplikasi Laravel dan mengarahkan pengguna ke endpoint logout Keycloak.

## Kesimpulan

Dengan mengikuti panduan ini, Anda dapat mengintegrasikan otentikasi SSO menggunakan Keycloak dalam aplikasi Laravel dengan bantuan Socialite Keycloak Provider.
