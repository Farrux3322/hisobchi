# Bo'lib To'lash — Hisobotlar API

**Base URL:** `{{base_url}}/api/reports/installments`
**Auth:** `Bearer {token}` — barcha so'rovlarda `Authorization` headeri majburiy.

---

## Umumiy Response Formati

```json
{ "status": true, "result": { } }
```

---

## Hisobotlar ro'yxati

| # | Nomi | Endpoint |
|---|------|----------|
| 1 | Umumiy ko'rinish | `GET /summary` |
| 2 | Hamkorlar bo'yicha | `GET /partners` |
| 3 | Kutilayotgan to'lovlar | `GET /forecast` |
| 4 | Muammoli hamkorlar | `GET /risky-partners` |
| 5 | Undirish samaradorligi | `GET /recovery` |
| 6 | Oylik dinamika | `GET /monthly` |
| 7 | Muddat bo'yicha detail | `GET /due-dates` |

---

## 1. Umumiy ko'rinish (Summary)

**Endpoint:** `GET {{base_url}}/api/reports/installments/summary`

Barcha bo'lib to'lash rejalarining umumiy statistikasi, valyuta bo'yicha.

### Request
Parametr yo'q.

### Response
```json
{
  "status": true,
  "result": [
    {
      "currency_type_id":   1,
      "currency_type_name": "UZS",
      "active_plans":       8,
      "completed_plans":    3,
      "cancelled_plans":    1,
      "total_given":        "15000000.00",
      "total_paid":         "8500000.00",
      "total_remaining":    "6500000.00",
      "overdue_amount":     "1200000.00"
    },
    {
      "currency_type_id":   2,
      "currency_type_name": "USD",
      "active_plans":       2,
      "completed_plans":    1,
      "cancelled_plans":    0,
      "total_given":        "2500.00",
      "total_paid":         "1100.00",
      "total_remaining":    "1400.00",
      "overdue_amount":     "200.00"
    }
  ]
}
```

| Maydon | Tur | Izoh |
|--------|-----|------|
| `active_plans` | int | Hozir faol rejalar soni |
| `completed_plans` | int | To'liq to'langan rejalar |
| `cancelled_plans` | int | Bekor qilingan rejalar |
| `total_given` | string | Jami berilgan summa |
| `total_paid` | string | Jami to'langan summa |
| `total_remaining` | string | Jami qolgan qarz |
| `overdue_amount` | string | Muddati o'tgan qismlarning qolgan summasi |

---

## 2. Hamkorlar bo'yicha

**Endpoint:** `GET {{base_url}}/api/reports/installments/partners`

Har bir hamkor bo'yicha bo'lib to'lash qarzlari. `simplePaginate` — 20 ta.

### Query Parametrlar
| Parametr | Tur | Majburiy | Izoh |
|----------|-----|----------|------|
| `currency_type_id` | int | Yo'q | 1=UZS, 2=USD |
| `sort` | string | Yo'q | `remaining` (default) \| `total_given` |

### Response
```json
{
  "status": true,
  "result": {
    "data": [
      {
        "partner_id":      29,
        "partner_name":    "Jahongir",
        "partner_phone":   "993153755",
        "active_plans":    2,
        "total_given":     "800000.00",
        "total_paid":      "300000.00",
        "total_remaining": "500000.00",
        "overdue_amount":  "100000.00",
        "last_payment_at": "05.04.2026"
      }
    ],
    "links": { "next": "...?page=2", "prev": null },
    "meta":  { "current_page": 1, "per_page": 20 }
  }
}
```

| Maydon | Tur | Izoh |
|--------|-----|------|
| `total_given` | string | Hamkorga berilgan jami summa |
| `total_remaining` | string | Jami qolgan qarz |
| `overdue_amount` | string | Muddati o'tgan qismlari summasi |
| `last_payment_at` | string\|null | Oxirgi to'lov sanasi |

> **Eslatma:** Hamkorning to'liq rejalari uchun `GET /api/partners/partner/{partnerId}/installments` endpointidan foydalaning.

---

## 3. Kutilayotgan to'lovlar (Forecast)

**Endpoint:** `GET {{base_url}}/api/reports/installments/forecast`

Kelgusi N kunda muddati keluvchi qismlar — cash flow rejalashtirish uchun.

### Query Parametrlar
| Parametr | Tur | Majburiy | Izoh |
|----------|-----|----------|------|
| `period` | int | Yo'q | `30` (default) \| `60` \| `90` |
| `currency_type_id` | int | Yo'q | 1=UZS, 2=USD |

### Response
```json
{
  "status": true,
  "result": [
    {
      "currency_type_id":   1,
      "currency_type_name": "UZS",
      "period_days":        30,
      "items_count":        12,
      "expected_amount":    "3500000.00",
      "due_today_count":    2,
      "due_3days_count":    4
    }
  ]
}
```

| Maydon | Tur | Izoh |
|--------|-----|------|
| `period_days` | int | Necha kun uchun forecast (30/60/90) |
| `items_count` | int | Ushbu davrdagi qismlar soni |
| `expected_amount` | string | Kutilayotgan jami summa |
| `due_today_count` | int | Bugun muddati kelganlar soni |
| `due_3days_count` | int | 3 kun ichida muddati kelganlar soni |

---

## 4. Muammoli hamkorlar reytingi (Risky Partners)

**Endpoint:** `GET {{base_url}}/api/reports/installments/risky-partners`

Muddati o'tgan qismlar asosida xavf bali hisoblanib, eng muammolidan tartiblangan ro'yxat.

### Query Parametrlar
| Parametr | Tur | Majburiy | Izoh |
|----------|-----|----------|------|
| `currency_type_id` | int | Yo'q | 1=UZS, 2=USD |

### Response
```json
{
  "status": true,
  "result": [
    {
      "partner_id":       29,
      "partner_name":     "Sardor",
      "partner_phone":    "901234567",
      "risk_score":       85,
      "risk_level":       "high",
      "overdue_items":    4,
      "overdue_amount":   "850000.00",
      "avg_days_overdue": 12,
      "total_remaining":  "1200000.00",
      "last_payment_at":  "15.03.2026"
    }
  ]
}
```

| Maydon | Tur | Izoh |
|--------|-----|------|
| `risk_score` | int | Xavf bali: 0–100 |
| `risk_level` | string | `low` \| `medium` \| `high` |
| `overdue_items` | int | Muddati o'tgan qismlar soni |
| `overdue_amount` | string | Muddati o'tgan qismlar summasi |
| `avg_days_overdue` | int | O'rtacha kechikish kunlari |
| `last_payment_at` | string\|null | Oxirgi to'lov sanasi |

### Risk level ranglari (tavsiya)
| Level | Rang |
|-------|------|
| `low` | Yashil |
| `medium` | Sariq |
| `high` | Qizil |

---

## 5. Undirish samaradorligi (Recovery Rate)

**Endpoint:** `GET {{base_url}}/api/reports/installments/recovery`

Berilgan pullarning qanchasi qaytib kelganini foizda ko'rsatadi.

### Request
Parametr yo'q.

### Response
```json
{
  "status": true,
  "result": [
    {
      "currency_type_id":   1,
      "currency_type_name": "UZS",
      "total_given":        "20000000.00",
      "total_collected":    "13000000.00",
      "total_remaining":    "7000000.00",
      "recovery_rate":      "65.00",
      "overdue_amount":     "2500000.00",
      "overdue_rate":       "12.50",
      "rating_label":       "O'rtacha",
      "active_plans":       8,
      "completed_plans":    5,
      "by_items": {
        "paid":    45,
        "partial": 8,
        "overdue": 12,
        "pending": 30
      }
    }
  ]
}
```

| Maydon | Tur | Izoh |
|--------|-----|------|
| `recovery_rate` | string | Foiz: to'langan / berilgan × 100 |
| `overdue_rate` | string | Foiz: muddati o'tgan / berilgan × 100 |
| `rating_label` | string | `Yaxshi` (≥80%) \| `O'rtacha` (60–80%) \| `Xavfli` (<60%) |
| `by_items.paid` | int | To'liq to'langan qismlar soni |
| `by_items.partial` | int | Qisman to'langan qismlar soni |
| `by_items.overdue` | int | Muddati o'tgan qismlar soni |
| `by_items.pending` | int | Hali muddati kelmagan qismlar soni |

---

## 6. Oylik to'lovlar dinamikasi

**Endpoint:** `GET {{base_url}}/api/reports/installments/monthly`

Yil bo'yicha har oy qabul qilingan to'lovlar — grafik uchun.

### Query Parametrlar
| Parametr | Tur | Majburiy | Izoh |
|----------|-----|----------|------|
| `year` | int | Yo'q | Default: joriy yil |
| `currency_type_id` | int | Yo'q | 1=UZS, 2=USD |

### Response
```json
{
  "status": true,
  "result": [
    {
      "currency_type_id":   1,
      "currency_type_name": "UZS",
      "year":               2026,
      "months": [
        { "month": 1,  "month_label": "January",  "payments_count": 0,  "total_amount": "0.00" },
        { "month": 2,  "month_label": "February", "payments_count": 3,  "total_amount": "450000.00" },
        { "month": 3,  "month_label": "March",    "payments_count": 7,  "total_amount": "1200000.00" },
        { "month": 4,  "month_label": "April",    "payments_count": 5,  "total_amount": "800000.00" },
        { "month": 5,  "month_label": "May",      "payments_count": 0,  "total_amount": "0.00" },
        ...
        { "month": 12, "month_label": "December", "payments_count": 0,  "total_amount": "0.00" }
      ]
    }
  ]
}
```

| Maydon | Tur | Izoh |
|--------|-----|------|
| `months` | array | Har doim 12 ta element (to'lov bo'lmasa `0`) |
| `month` | int | 1–12 |
| `month_label` | string | Oy nomi (server locale bo'yicha) |
| `payments_count` | int | O'sha oyda qabul qilingan to'lovlar soni |
| `total_amount` | string | O'sha oyda qabul qilingan jami summa |

---

## 7. Muddat bo'yicha detail

**Endpoint:** `GET {{base_url}}/api/reports/dashboard/installments/due-dates`

Dashboard'dagi sonlarga mos keladigan qismlar ro'yxati. `simplePaginate` — 15 ta.

### Query Parametrlar
| Parametr | Tur | Majburiy | Izoh |
|----------|-----|----------|------|
| `type` | string | Ha | `installment_expired` \| `installment_today` \| `installment_3_days` |

### Response
```json
{
  "status": true,
  "result": {
    "data": [
      {
        "id":                 27,
        "item_number":        2,
        "is_advance":         false,
        "amount":             "100000.00",
        "paid_amount":        "40000.00",
        "remaining":          "60000.00",
        "due_date":           "10.04.2026",
        "status":             "partial",
        "status_label":       "Qisman to'langan",
        "days_overdue":       null,
        "days_left":          2,
        "plan_id":            7,
        "partner_id":         29,
        "partner_name":       "Jahongir",
        "partner_phone":      "993153755",
        "currency_type_id":   1,
        "currency_type_name": "UZS",
        "plan_total":         "500000.00",
        "plan_paid":          "200000.00",
        "plan_remaining":     "300000.00",
        "plan_status":        "active",
        "activity":           null
      }
    ],
    "links": { "next": null, "prev": null },
    "meta":  { "current_page": 1, "per_page": 15 }
  }
}
```

| `type` | `days_overdue` | `days_left` |
|--------|---------------|-------------|
| `installment_expired` | Necha kun kechikkan | `null` |
| `installment_today` | `null` | `0` |
| `installment_3_days` | `null` | 1–3 |
