Untuk menggunakan OpenID Connect (OIDC) dengan Keycloak di CodeIgniter, Anda dapat mengikuti langkah-langkah berikut:

1. **Instal Library OAuth2 untuk CodeIgniter**:
   - Anda dapat menggunakan library OAuth2 untuk CodeIgniter. Salah satu yang populer adalah "oauth2-server-php". Instal library ini menggunakan Composer:

     ```
     composer require bshaffer/oauth2-server-php
     ```

2. **Konfigurasi Keycloak**:
   - Pastikan bahwa konfigurasi Keycloak Anda telah benar. Perhatikan bahwa URL server otentikasi adalah `https://sso.kalbarprov.go.id/`.

3. **Implementasi Kode di CodeIgniter**:
   - Buat kontroler atau model yang akan menangani autentikasi dengan Keycloak. Contoh implementasi dasar dapat terlihat seperti berikut:

     ```php
     <?php
     defined('BASEPATH') OR exit('No direct script access allowed');

     use OAuth2\Autoloader;
     use OAuth2\Request;
     use OAuth2\Response;

     class Keycloak_authentication extends CI_Controller {
     
         public function __construct() {
             parent::__construct();
     
             // Load library OAuth2
             Autoloader::register();
     
             // Load model atau library lain yang dibutuhkan
             // ...
         }
     
         public function index() {
             // Konfigurasi Keycloak
             $config = array(
                 'issuer'                => 'https://sso.kalbarprov.go.id/',
                 'authorization_endpoint' => 'https://sso.kalbarprov.go.id/realms/kominfo-pegawai/protocol/openid-connect/auth',
                 'token_endpoint'         => 'https://sso.kalbarprov.go.id/realms/kominfo-pegawai/protocol/openid-connect/token',
                 'userinfo_endpoint'      => 'https://sso.kalbarprov.go.id/realms/kominfo-pegawai/protocol/openid-connect/userinfo',
                 'client_id'             => [Ambil dari env KEYCLOAK_CLIENT_ID],
                 'client_secret'         => [Ambil dari env KEYCLOAK_CLIENT_SECRET],
                 'redirect_uri'          => [URL Callback mu],
                 'scope'                 => 'openid profile email',
             );
     
             $this->load->library('oauth2');
             $this->oauth2->initialize($config);
     
             // Redirect ke halaman otentikasi Keycloak
             $this->oauth2->authorize();
         }
     
         public function callback() {
             // Callback dari Keycloak
             $code = $this->input->get('code');
     
             // Mendapatkan token akses
             $token = $this->oauth2->getAccessToken('authorization_code', array('code' => $code));
     
             // Lakukan sesuatu dengan token, misalnya simpan di session atau buat sesi pengguna
             // ...
         }
     }
     ```

4. **Tambahkan Rute di CodeIgniter**:
   - Tambahkan rute untuk mengakses kontroler yang telah Anda buat. Buka file `application/config/routes.php` dan tambahkan rute seperti ini:

     ```php
     $route['keycloak_authentication'] = 'keycloak_authentication';
     $route['keycloak_authentication/callback'] = 'keycloak_authentication/callback';
     ```

   Sesuaikan rute sesuai dengan kebutuhan Anda.

5. **Uji Coba**:
   - Buka URL yang sesuai dengan rute yang telah Anda tentukan, misalnya `http://localhost/CodeIgniter/index.php/keycloak_authentication`.
   - Pengguna akan diarahkan ke halaman otentikasi Keycloak untuk login.
   - Setelah login berhasil, pengguna akan diarahkan kembali ke callback URL yang telah Anda tentukan.

Pastikan Anda memahami dan mengonfigurasi dengan benar sesuai dengan kebutuhan aplikasi Anda. Jangan lupa untuk menyesuaikan kode sesuai dengan struktur aplikasi CodeIgniter Anda.
