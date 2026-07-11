# TESSERA - Mobil Tətbiq API Sənədləşməsi (API Documentation)

Bu sənəd TESSERA layihəsinin mobil tətbiqi üçün hazırlanmış API (Backend) inteqrasiya təlimatlarını və bütün əsas endpoint-ləri əhatə edir.

> [!NOTE]
> **Base URL:** `https://tessera-backend-production.up.railway.app/api` (Production)
> **Authentication (Zəmanət):** Qapalı (Protected) endpoint-lər üçün HTTP Header-də `Authorization: Bearer <TOKEN>` göndərilməlidir.

---

## 1. Autentifikasiya və İstifadəçi (Authentication & User)

### 1.1 İstifadəçi Qeydiyyatı
- **Endpoint:** `POST /auth/register` (və ya `POST /auth/user/register`)
- **İcazə (Auth):** Public
- **Body (JSON):**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secretpassword",
  "phone": "+994501234567" // (Opsional)
}
```

### 1.2 İstifadəçi Girişi (Login)
- **Endpoint:** `POST /auth/login` (və ya `POST /auth/user/login`)
- **İcazə (Auth):** Public
- **Body (JSON):**
```json
{
  "email": "john@example.com",
  "password": "secretpassword"
}
```
- **Uğurlu Cavab (Response):** 
```json
{
  "success": true,
  "token": "eyJhbGciOi...",
  "user": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "USER"
  }
}
```

### 1.3 Cari İstifadəçi Məlumatları
- **Endpoint:** `GET /auth/me`
- **İcazə (Auth):** Bearer Token (Protected)
- **Təsvir:** Daxil olmuş istifadəçinin məlumatlarını qaytarır.

### 1.4 Profili Yeniləmək
- **Endpoint:** `PATCH /auth/profile`
- **İcazə (Auth):** Bearer Token (Protected)
- **Body (JSON):** Ad, telefon, ünvan və s. göndərilə bilər.

### 1.5 Şifrəni Sıfırlama
- **Endpoint:** `POST /auth/forgot-password` (Şifrəmi unutdum emaili göndərir)
- **Endpoint:** `POST /auth/reset-password` (Yeni şifrəni təyin edir)

---

## 2. Kateqoriyalar (Categories)

### 2.1 Bütün Kateqoriya Ağacı
- **Endpoint:** `GET /categories`
- **İcazə (Auth):** Public
- **Təsvir:** Bütün əsas kateqoriyaları və onların alt kateqoriyalarını (subcategory) qaytarır. Menyu qurmaq üçün istifadə olunur.

### 2.2 Slug-a Görə Kateqoriya
- **Endpoint:** `GET /categories/slug/:slug`
- **İcazə (Auth):** Public
- **Təsvir:** Seçilmiş kateqoriyanın detallarını və "breadcrumb" məlumatlarını qaytarır.

---

## 3. Məhsullar (Products)

### 3.1 Məhsul Axtarışı və Siyahısı
- **Endpoint:** `GET /products`
- **İcazə (Auth):** Public
- **Query Parametrləri (Opsional):**
  - `page`: Səhifə nömrəsi (məs: 1)
  - `limit`: Hər səhifədəki limit (məs: 20)
  - `category`: Kateqoriya ID-si və ya adı
  - `minPrice`, `maxPrice`: Qiymət aralığı
  - `sort`: Sıralama (`price_asc`, `price_desc`, `newest`)
  - `search`: Axtarış sözü

### 3.2 Avtotamamlanma (Autocomplete / Search Suggestions)
- **Endpoint:** `GET /products/search/autocomplete`
- **Query:** `?q=köynək`
- **İcazə (Auth):** Public

### 3.3 Məhsul Detalları
- **Endpoint:** `GET /products/:id`
- **İcazə (Auth):** Public
- **Təsvir:** Məhsulun bütün məlumatlarını (şəkillər, qiymət, stok, ölçülər/rənglər, mağaza məlumatı) qaytarır.

### 3.4 Bənzər Məhsullar
- **Endpoint:** `GET /products/:id/similar`
- **İcazə (Auth):** Public

### 3.5 Baxış Sayını Artırmaq
- **Endpoint:** `POST /products/:id/views`
- **Təsvir:** Məhsul detallarına giriləndə çağrılmalıdır ki, baxış sayı (analytics) artsın.

---

## 4. Səbət (Cart)

> [!IMPORTANT]
> Səbət əməliyyatlarının hər biri üçün istifadəçi daxil olmuş (Logged In) olmalıdır. Yəni `Authorization: Bearer <TOKEN>` header-i mütləqdir.

### 4.1 Səbəti Görmək
- **Endpoint:** `GET /cart`

### 4.2 Səbətə Məhsul Əlavə Etmək
- **Endpoint:** `POST /cart/add`
- **Body (JSON):**
```json
{
  "productId": "64d23f...", // Məhsulun ID-si
  "quantity": 1
}
```

### 4.3 Səbətdəki Məhsulun Sayını Dəyişmək
- **Endpoint:** `PUT /cart/item/:productId`
- **Body (JSON):**
```json
{
  "quantity": 2
}
```

### 4.4 Məhsulu Səbətdən Silmək
- **Endpoint:** `DELETE /cart/item/:productId`

### 4.5 Səbəti Tamamilə Təmizləmək
- **Endpoint:** `DELETE /cart`

---

## 5. Ödəniş (Checkout) və Sifarişlər (Orders)

### 5.1 Ödəniş (Checkout) Yaratmaq
- **Endpoint:** `POST /checkout`
- **İcazə (Auth):** Bearer Token (USER)
- **Body (JSON):**
```json
{
  "shippingAddress": {
    "address": "Nizami str 100",
    "city": "Baku",
    "postalCode": "AZ1000",
    "country": "Azerbaijan"
  },
  "paymentMethod": "CARD" // və ya "CASH"
}
```
- **Təsvir:** İstifadəçinin səbətindəki (cart) məhsulları oxuyur, ümumi məbləği hesablayır və sifariş (Order) yaradır.

### 5.2 İstifadəçinin Sifarişləri
- **Endpoint:** `GET /orders`
- **İcazə (Auth):** Bearer Token (USER)

### 5.3 Sifariş Detalları
- **Endpoint:** `GET /orders/:id`
- **İcazə (Auth):** Bearer Token (USER)
- **Təsvir:** Spesifik sifarişin statusunu, kuryer məlumatlarını və içindəki məhsulları qaytarır.

---

## 6. Kombinlər (Outfits / AI Styling)

Bu API bölməsi tətbiqdəki "Ağıllı Kombin" (AI Styling) bölməsi üçündür.

### 6.1 Kombin Yaratmaq
- **Endpoint:** `GET /outfits/generate/:slug`
- **Təsvir:** Verilmiş məhsulun slug-ına əsasən avtomatik kombinasiya yaradır (Məsələn: bir şalvar üçün uyğun köynək və ayaqqabı tapır).

### 6.2 Kombini Yadda Saxlamaq
- **Endpoint:** `POST /outfits`
- **İcazə:** Bearer Token (Protected)
- **Body:** Kombin məlumatları (Items)

### 6.3 Mənim Kombinlərim
- **Endpoint:** `GET /outfits/me`
- **İcazə:** Bearer Token (Protected)
- **Təsvir:** İstifadəçinin yadda saxladığı kombinləri qaytarır.

---

## Error Handling (Xətaların İdarə Edilməsi)

API xətalar zamanı aşağıdakı kimi standart bir JSON formatı qaytarır. Mobil tətbiqdə xətaları ekranda göstərmək üçün `message` dəyərindən istifadə edin:

```json
{
  "success": false,
  "message": "İstifadəçi tapılmadı"
}
```

**Ümumi HTTP Status Kodları:**
- `200 OK` / `201 Created` - Əməliyyat uğurludur.
- `400 Bad Request` - Göndərilən məlumatlarda səhv var (Məsələn, zəruri sahə boşdur).
- `401 Unauthorized` - Token yoxdur və ya vaxtı bitib. İstifadəçini yenidən Login ekranına yönləndirin.
- `403 Forbidden` - Bu əməliyyatı etməyə yetkiniz yoxdur.
- `404 Not Found` - Axtarılan məlumat tapılmadı (Məsələn: məhsul silinib).
- `500 Internal Server Error` - Server xətası.
