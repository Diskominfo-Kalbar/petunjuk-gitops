## Dokumentasi dan Standar Pemanggilan Konten di AWDI

### Mekanisme Tema Hugo Dasar
Hugo adalah framework yang sangat cepat dan fleksibel untuk membuat situs statis. Tema Hugo memungkinkan pengembang untuk mendesain tampilan dan tata letak situs web mereka dengan mudah. Setiap tema dapat memiliki template, asset statis, dan konfigurasi khusus yang mengontrol bagaimana konten ditampilkan. Tema ini dapat diinstal dan diaktifkan dengan mudah melalui konfigurasi Hugo.

### Penggunaan Tema di AWDI
Pengembang hanya perlu mengubah folder tema tanpa menyentuh folder proyek utama. Jika ada folder konten khusus dan folder statis yang ingin ditambahkan, mereka dapat disertakan dalam folder tema yang dibuat. AWDI akan menyertakan konten ini secara otomatis.

### Standar Pemanggilan Konten di AWDI

#### Slider
Untuk memanggil konten slider, gunakan kode berikut:

```html
{{ $sliderImages := .Site.Params.sliders.images }}

{{ if len $sliderImages }}
<div class="swiper mySwiper">
  <div class="swiper-wrapper">
    {{ range $sliderImages }}
      <div class="swiper-slide">
        <img src="sliders/{{ .url }}" alt="Slider Image" style="width:100%">
      </div>
    {{ end }}
  </div>
  <div class="swiper-button-next"></div>
  <div class="swiper-button-prev"></div>
  <div class="swiper-pagination"></div>
</div>
{{ end }}
```

- **$sliderImages**: Array gambar slider yang diambil dari parameter situs.

#### Front Bundle
Untuk menampilkan daftar konten di halaman awal, gunakan kode berikut:

```html
<div class="grid md:grid-cols-1 gap-4 lg:gap-x-16">
  <div>
    {{ $frontBundle := .Site.Params.frontBundle | default "berita" }}
    <h2 class="text-2xl font-bold mt-6 text-center">{{ $frontBundle | title }}</h2>
    <div class="container p-6 mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 lg:gap-8">
      {{ range first 6 (where .Site.RegularPages.ByDate.Reverse "Type" $frontBundle) }}
        {{- partial "blog-card.html" . -}}
      {{ end }}
    </div>
    {{ if gt (len (where .Site.RegularPages.ByDate.Reverse "Type" $frontBundle)) 6 }}
    <div class="text-center mb-8">
      <a class="px-8 py-3 rounded transition-colors {{ .Site.Params.ascentColor | default "bg-pink-50" }} text-gray-500 hover:text-gray-800 dark:bg-gray-900 dark:text-gray-400 dark:hover:text-white" href="{{ (index (.Site.Menus.main) 0).URL | absLangURL }}" lang="{{ .Lang }}">
        {{ i18n "morePosts" }}
      </a>
    </div>
    {{ end }}
  </div>
  
  <div>
    {{ $frontBundle2 := .Site.Params.frontBundle2 | default "gallery" }}
    <h2 class="text-2xl font-bold mt-6 text-center">{{ $frontBundle2 | title }}</h2>
    <div class="container p-6 mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-1 lg:gap-1">
      {{ range first 6 (where .Site.RegularPages.ByDate.Reverse "Type" $frontBundle2) }}
        {{- partial "blog-card.html" . -}}
      {{ end }}
    </div>
    {{ if gt (len (where .Site.RegularPages.ByDate.Reverse "Type" $frontBundle2)) 6 }}
    <div class="text-center mb-8">
      <a class="px-8 py-3 rounded transition-colors {{ .Site.Params.ascentColor | default "bg-pink-50" }} text-gray-500 hover:text-gray-800 dark:bg-gray-900 dark:text-gray-400 dark:hover:text-white" href="{{ (index (.Site.Menus.main) 0).URL | absLangURL }}" lang="{{ .Lang }}">
        {{ i18n "morePosts" }}
      </a>
    </div>
    {{ end }}
  </div>
</div>
```

- **$frontBundle**: Tipe konten yang akan ditampilkan di halaman depan, diambil dari parameter situs.
- **$frontBundle2**: Tipe konten kedua yang akan ditampilkan di halaman depan, diambil dari parameter situs.

#### Agenda
Untuk memanggil konten agenda, gunakan kode berikut:

```html
{{ $agenda := .Site.Params.agenda }}
{{ if $agenda }}
<div>
  <h2 class="text-2xl font-bold mt-6 text-center">Agenda</h2>
  <div class="container p-6 mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 lg:gap-8">
    {{ range $agenda }}
      <div class="dark:bg-gray-900 bg-white p-4 rounded-lg shadow-lg">
        <h3 class="font-bold text-lg">{{ .hari }}</h3>
        <p>{{ .lokasi }}</p>
        <p>{{ .jamMulai }} - {{ .jamSelesai }}</p>
        <p>{{ .judul }}</p>
      </div>
    {{ end }}
  </div>
</div>
{{ end }}
```

- **$agenda**: Array agenda yang diambil dari parameter situs.

#### Menu
Untuk memanggil konten menu, gunakan kode berikut:

```html
{{ range .Site.Menus.main }}
  {{ $menuURL := .URL }}
  {{ $menuName := .Name }}
  {{ $menuHasChildren := .HasChildren }}
  {{ if $menuHasChildren }}
    <li class="relative cursor-pointer">
      <span class="language-switcher flex items-center gap-2">
        <a>{{ $menuName }}</a>
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
          <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
          <path d="M18 15l-6 -6l-6 6h12" transform="rotate(180 12 12)"></path>
        </svg>
      </span>
      <div class="language-dropdown absolute top-full mt-2 left-0 flex-col gap-2 bg-gray-100 dark:bg-gray-900 dark:text-white z-10 hidden">
        {{ range .Children }}
          <a class="px-3 py-2 hover:bg-gray-200 dark:hover:bg-gray-700" href="{{ .URL }}">{{ .Name }}</a>
        {{ end }}
      </div>
    </li>
  {{ else }}
    <li><a href="{{ $menuURL }}">{{ $menuName }}</a></li>
  {{ end }}
{{ end }}
```

- **$menuURL**: URL dari menu.
- **$menuName**: Nama menu.
- **$menuHasChildren**: Boolean yang menunjukkan apakah menu memiliki sub-menu.

### Catatan Tambahan
- Developer hanya perlu mengubah folder tema dan tidak menyentuh folder proyek utama.
- Jika ada folder konten khusus dan folder statis yang ingin ditambahkan, mereka dapat disertakan dalam folder tema yang dibuat, dan AWDI akan menyertakannya secara otomatis.
