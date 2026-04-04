# Bo'lib To'lash API — Mobile Dasturchi Uchun

**Base URL:** `{{base_url}}/api/partners`
**Auth:** `Bearer {token}` — barcha so'rovlarda `Authorization` headeri majburiy.
**Content-Type:** `application/json`

---

## Umumiy Response Formati

### Muvaffaqiyatli (oddiy)
```json
{
  "status": true,
  "result": { }
}
```

### Muvaffaqiyatli (ro'yxat — simplePaginate)
```json
{
  "status": true,
  "result": {
    "data": [ ],
    "links": {
      "first": null,
      "last": null,
      "prev": null,
      "next": "https://api.example.com/api/partners/installments?page=2"
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "path": "https://api.example.com/api/partners/installments",
      "per_page": 20,
      "to": 20
    }
  }
}
```

> **Eslatma:** `simplePaginate` da `total` va `last_page` yo'q. Keyingi sahifa borligini `links.next` null yoki yo'qligiga qarab aniqlanadi.

### Xatolik
```json
{
  "status": false,
  "error": {
    "message": "Xatolik matni"
  }
}
```

---

## Ob'ektlar

### InstallmentPlan ob'ekti

```json
{
  "id": 1,
  "partner_id": 5,
  "partner_name": "Alibek Toshmatov",
  "currency_type_id": 1,
  "currency_type_name": "UZS",
  "total_amount": "500000.00",
  "paid_amount": "100000.00",
  "remaining": "400000.00",
  "schedule_type": "equal",
  "has_advance": true,
  "advance_amount": "100000.00",
  "start_date": "2026-05-01",
  "note": "Ixtiyoriy izoh",
  "status": "active",
  "status_label": "Faol",
  "items": [ ],
  "items_count": 5,
  "created_at": "03.04.2026 10:00",
  "activity": null
}
```

> `items` — faqat `show` va `partnerInstallments` endpointlarida to'ldiriladi. `index` da bo'sh array keladi.
> `items_count` — `index` da qismlar soni (qo'shimcha so'rovsiz).

**status qiymatlari:**

| Qiymat | Uzbekcha |
|--------|----------|
| `active` | Faol |
| `completed` | To'liq to'langan |
| `cancelled` | Bekor qilingan |

**schedule_type qiymatlari:**

| Qiymat | Tavsif |
|--------|--------|
| `equal` | Teng — tizim due_date larni avtomatik hisoblaydi |
| `custom` | Erkin — har bir qismga summa va sana alohida |

---

### InstallmentItem ob'ekti

```json
{
  "id": 12,
  "item_number": 1,
  "is_advance": true,
  "amount": "100000.00",
  "paid_amount": "100000.00",
  "remaining": "0.00",
  "due_date": "2026-05-01",
  "paid_at": "02.05.2026 09:15",
  "status": "paid",
  "status_label": "To'langan",
  "note": null
}
```

**status qiymatlari va ranglari:**

| Qiymat | Uzbekcha | Rang |
|--------|----------|------|
| `pending` | Kutilmoqda | Kulrang |
| `near` | Yaqinlashdi (≤7 kun) | Sariq |
| `overdue` | Muddati o'tdi | Qizil |
| `partial` | Qisman to'langan | Ko'k |
| `paid` | To'langan | Yashil |

---

## Endpointlar

---

### 1. Rejalari ro'yxati

```
GET /api/partners/installments
```

**Query parametrlar (hammasi ixtiyoriy):**

| Parametr | Tur | Tavsif |
|----------|-----|--------|
| `partner_id` | integer | Hamkor bo'yicha filter |
| `status` | string | `active` / `completed` / `cancelled` |
| `currency_type_id` | integer | Valyuta ID si |
| `schedule_type` | string | `equal` / `custom` |
| `search` | string | Izoh bo'yicha qidirish |
| `per_page` | integer | Default: 20, max: 100 |
| `page` | integer | Sahifa raqami, default: 1 |

**Response (200):**
```json
{
  "status": true,
  "result": {
    "data": [
      {
        "id": 1,
        "partner_id": 5,
        "partner_name": "Alibek Toshmatov",
        "currency_type_id": 1,
        "currency_type_name": "UZS",
        "total_amount": "500000.00",
        "paid_amount": "100000.00",
        "remaining": "400000.00",
        "schedule_type": "equal",
        "has_advance": true,
        "advance_amount": "100000.00",
        "start_date": "2026-05-01",
        "note": null,
        "status": "active",
        "status_label": "Faol",
        "items": [],
        "items_count": 5,
        "created_at": "03.04.2026 10:00",
        "activity": null
      }
    ],
    "links": {
      "first": null,
      "last": null,
      "prev": null,
      "next": "https://.../installments?page=2"
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "path": "https://.../installments",
      "per_page": 20,
      "to": 20
    }
  }
}
```

---

### 2. Yangi reja yaratish

```
POST /api/partners/installments
```

#### 2A — Teng, avans YO'Q

```json
{
  "partner_id": 5,
  "currency_type_id": 1,
  "total_amount": 500000,
  "schedule_type": "equal",
  "has_advance": false,
  "start_date": "2026-05-01",
  "installment_count": 4,
  "note": "Ixtiyoriy izoh"
}
```

#### 2B — Teng, avans bor

```json
{
  "partner_id": 5,
  "currency_type_id": 1,
  "total_amount": 500000,
  "schedule_type": "equal",
  "has_advance": true,
  "advance_amount": 100000,
  "start_date": "2026-05-01",
  "installment_count": 4,
  "note": null
}
```

> `installment_count` = avansdan **keyingi** oylar soni. Tizim +1 avans qo'shadi → jami 5 qism.
>
> Natija: `1-qism (avans): 100,000` + `2..5-qism: 100,000 × 4`

#### 2C — Erkin grafik, avans YO'Q

```json
{
  "partner_id": 5,
  "currency_type_id": 2,
  "total_amount": 1000,
  "schedule_type": "custom",
  "has_advance": false,
  "items": [
    { "amount": 300, "due_date": "2026-05-15", "note": "1-to'lov" },
    { "amount": 400, "due_date": "2026-06-20" },
    { "amount": 300, "due_date": "2026-07-10" }
  ]
}
```

#### 2D — Erkin grafik, avans bor

```json
{
  "partner_id": 5,
  "currency_type_id": 1,
  "total_amount": 500000,
  "schedule_type": "custom",
  "has_advance": true,
  "items": [
    { "amount": 100000, "due_date": "2026-05-01" },
    { "amount": 200000, "due_date": "2026-06-15" },
    { "amount": 200000, "due_date": "2026-08-01" }
  ]
}
```

> `has_advance: true` bo'lsa 1-element avans sifatida belgilanadi (`is_advance: true`).

**Validatsiya qoidalari:**

| Field | Shart |
|-------|-------|
| `partner_id` | Majburiy, mavjud hamkor ID |
| `currency_type_id` | Majburiy, mavjud valyuta ID |
| `total_amount` | Majburiy, > 0 |
| `schedule_type` | Majburiy — `equal` yoki `custom` (**`advance` qabul qilinmaydi**) |
| `has_advance` | Ixtiyoriy, default `false` |
| `advance_amount` | `has_advance=true` bo'lsa majburiy; jami summadan kichik bo'lishi shart |
| `start_date` | `equal` turda majburiy; bugundan katta; format: `YYYY-MM-DD` |
| `installment_count` | `equal` turda majburiy; `has_advance=false` → min 2; `has_advance=true` → min 1 |
| `items` | `custom` turda majburiy; min 2 element |
| `items[].amount` | `custom` turda majburiy, > 0 |
| `items[].due_date` | `custom` turda majburiy; bugundan katta; format: `YYYY-MM-DD` |
| `items[].note` | Ixtiyoriy |

> **BQ-03:** `custom` turida `items[].amount` yig'indisi `total_amount` ga teng bo'lishi shart.

**Response (200):**
```json
{
  "status": true,
  "result": {
    "id": 1,
    "partner_id": 5,
    "partner_name": "Alibek Toshmatov",
    "currency_type_id": 1,
    "currency_type_name": "UZS",
    "total_amount": "500000.00",
    "paid_amount": "0.00",
    "remaining": "500000.00",
    "schedule_type": "equal",
    "has_advance": true,
    "advance_amount": "100000.00",
    "start_date": "2026-05-01",
    "note": null,
    "status": "active",
    "status_label": "Faol",
    "items": [
      {
        "id": 1,
        "item_number": 1,
        "is_advance": true,
        "amount": "100000.00",
        "paid_amount": "0.00",
        "remaining": "100000.00",
        "due_date": "2026-05-01",
        "paid_at": null,
        "status": "pending",
        "status_label": "Kutilmoqda",
        "note": null
      },
      {
        "id": 2,
        "item_number": 2,
        "is_advance": false,
        "amount": "100000.00",
        "paid_amount": "0.00",
        "remaining": "100000.00",
        "due_date": "2026-06-01",
        "paid_at": null,
        "status": "pending",
        "status_label": "Kutilmoqda",
        "note": null
      }
    ],
    "items_count": null,
    "created_at": "03.04.2026 10:00",
    "activity": null
  }
}
```

**Xatoliklar:**
```json
{ "status": false, "error": { "message": "Qismlar yig'indisi jami summaga teng bo'lishi kerak." } }
{ "status": false, "error": { "message": "Avans summasi jami summadan kichik bo'lishi kerak." } }
{ "status": false, "error": { "message": "The schedule type field must be one of equal, custom." } }
```

---

### 3. Reja va qismlarini ko'rish

```
GET /api/partners/installments/{id}
```

**Response (200):**
```json
{
  "status": true,
  "result": {
    "id": 1,
    "partner_id": 5,
    "partner_name": "Alibek Toshmatov",
    "currency_type_id": 1,
    "currency_type_name": "UZS",
    "total_amount": "500000.00",
    "paid_amount": "100000.00",
    "remaining": "400000.00",
    "schedule_type": "equal",
    "has_advance": true,
    "advance_amount": "100000.00",
    "start_date": "2026-05-01",
    "note": null,
    "status": "active",
    "status_label": "Faol",
    "items": [
      {
        "id": 1,
        "item_number": 1,
        "is_advance": true,
        "amount": "100000.00",
        "paid_amount": "100000.00",
        "remaining": "0.00",
        "due_date": "2026-05-01",
        "paid_at": "02.05.2026 09:15",
        "status": "paid",
        "status_label": "To'langan",
        "note": null
      },
      {
        "id": 2,
        "item_number": 2,
        "is_advance": false,
        "amount": "100000.00",
        "paid_amount": "0.00",
        "remaining": "100000.00",
        "due_date": "2026-06-01",
        "paid_at": null,
        "status": "pending",
        "status_label": "Kutilmoqda",
        "note": null
      }
    ],
    "items_count": null,
    "created_at": "03.04.2026 10:00",
    "activity": { }
  }
}
```

**Xatolik:**
```json
{ "status": false, "error": { "message": "No query results for model [InstallmentPlan]." } }
```

---

### 4. Rejani tahrirlash

```
PUT /api/partners/installments/{id}
```

> Faqat `note` tahrirlanadi.

**Request body:**
```json
{
  "note": "Yangilangan izoh"
}
```

**Response (200):** → `store` response ga o'xshash (items bilan)

**Xatolik:**
```json
{ "status": false, "error": { "message": "Bekor qilingan rejani tahrirlash mumkin emas." } }
```

---

### 5. Rejani bekor qilish

```
DELETE /api/partners/installments/{id}
```

> Reja o'chirilmaydi — `status` → `cancelled`.

**Response (200):**
```json
{
  "status": true,
  "result": {
    "id": 1,
    "status": "cancelled",
    "status_label": "Bekor qilingan",
    "...": "..."
  }
}
```

**Xatolik:**
```json
{ "status": false, "error": { "message": "Faqat faol rejani bekor qilish mumkin." } }
```

---

### 6. Reja qismlari ro'yxati

```
GET /api/partners/installments/{id}/items
```

**Response (200):**
```json
{
  "status": true,
  "result": [
    {
      "id": 1,
      "item_number": 1,
      "is_advance": true,
      "amount": "100000.00",
      "paid_amount": "100000.00",
      "remaining": "0.00",
      "due_date": "2026-05-01",
      "paid_at": "02.05.2026 09:15",
      "status": "paid",
      "status_label": "To'langan",
      "note": null
    },
    {
      "id": 2,
      "item_number": 2,
      "is_advance": false,
      "amount": "100000.00",
      "paid_amount": "0.00",
      "remaining": "100000.00",
      "due_date": "2026-06-01",
      "paid_at": null,
      "status": "near",
      "status_label": "Yaqinlashdi",
      "note": null
    }
  ]
}
```

---

### 7. To'lov qabul qilish

```
POST /api/partners/installments/{id}/payment
```

> FIFO — eng yaqin `due_date` li qism birinchi yopiladi. Qisman to'lovni qo'llab-quvvatlaydi.

**Request body:**
```json
{
  "amount": 100000,
  "note": "Naqd to'lov"
}
```

| Field | Shart |
|-------|-------|
| `amount` | Majburiy, > 0, qolgan qarzdan oshmasligi kerak |
| `note` | Ixtiyoriy |

**Response (200):** → yangilangan `InstallmentPlan` (items bilan)
```json
{
  "status": true,
  "result": {
    "id": 1,
    "paid_amount": "200000.00",
    "remaining": "300000.00",
    "status": "active",
    "items": [
      {
        "id": 1,
        "item_number": 1,
        "is_advance": true,
        "amount": "100000.00",
        "paid_amount": "100000.00",
        "remaining": "0.00",
        "status": "paid",
        "status_label": "To'langan",
        "paid_at": "03.04.2026 14:22"
      },
      {
        "id": 2,
        "item_number": 2,
        "is_advance": false,
        "amount": "100000.00",
        "paid_amount": "100000.00",
        "remaining": "0.00",
        "status": "paid",
        "status_label": "To'langan",
        "paid_at": "03.04.2026 14:22"
      }
    ],
    "...": "..."
  }
}
```

**Xatoliklar:**
```json
{ "status": false, "error": { "message": "Faqat faol rejalarga to'lov qabul qilinadi." } }
{ "status": false, "error": { "message": "To'lov summasi qolgan qarzdan oshib ketmasligi kerak." } }
```

---

### 8. Hamkorning barcha rejalari

```
GET /api/partners/partner/{partnerId}/installments
```

> Pagination yo'q — hamkorning barcha rejalari to'liq qaytariladi (items bilan).

**Response (200):**
```json
{
  "status": true,
  "result": [
    {
      "id": 1,
      "partner_id": 5,
      "partner_name": "Alibek Toshmatov",
      "currency_type_id": 1,
      "currency_type_name": "UZS",
      "total_amount": "500000.00",
      "paid_amount": "100000.00",
      "remaining": "400000.00",
      "status": "active",
      "status_label": "Faol",
      "items": [ ],
      "...": "..."
    }
  ]
}
```

---

## Preview Hisoblash Algoritmi (equal tur)

Mobile UI da preview ko'rsatish uchun **backend bilan bir xil algoritm** ishlatilishi shart.

### Avans YO'Q
```
itemAmount  = round(total / count, 2)
distributed = round(itemAmount × (count - 1), 2)
lastAmount  = round(total - distributed, 2)
```

### Avans bor
```
remaining   = round(total - advance, 2)
itemAmount  = round(remaining / count, 2)
distributed = round(itemAmount × (count - 1), 2)
lastAmount  = round(remaining - distributed, 2)   ← oxirgi qism farqni oladi
```

### Misol: 400,000 / 3 qism
```
itemAmount  = round(400000 / 3, 2)    = 133333.33
distributed = round(133333.33 × 2, 2) = 266666.66
lastAmount  = round(400000 - 266666.66, 2) = 133333.34
```
Yig'indi: `133333.33 + 133333.33 + 133333.34 = 400000.00` ✓

---

## HTTP Kodlar

| Kod | Sabab |
|-----|-------|
| `200` | Muvaffaqiyatli |
| `401` | Token yo'q yoki yaroqsiz |
| `403` | Ruxsat yo'q |
| `404` | Reja topilmadi |
| `422` | Validatsiya xatoligi |
| `500` | Server xatoligi |
