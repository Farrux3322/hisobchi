# Client List Page - Currency Widget Integration

## O'zgarishlar

### Client List Page (`lib/presentation/pages/client/client_list_page.dart`)

#### 1. **Import qo'shildi** ✅
```dart
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/presentation/pages/currency/currency_page.dart';
```

#### 2. **initState yangilandi** ✅
```dart
@override
void initState() {
  super.initState();
  context.read<PartnerBloc>().add(const GetAllEvent());
  // Valyuta kurslarini yuklash
  context.read<CurrencyBloc>().add(const GetExchangeRates());
}
```

#### 3. **Hardcoded exchangeRate o'chirildi** ✅
```dart
// O'chirildi: final double exchangeRate = 15000;
```

#### 4. **Yangi Currency Widget qo'shildi** ✅
- **Metod:** `_buildCurrencyWidget()`
- **Joylashuv:** AppBar ning o'ng tarafida (logo yonida)

### Features:

#### 🔄 **Real-time USD kursi**
- API dan kelgan haqiqiy ma'lumot
- Avtomatik yangilanish
- Loading state (yuklanayotganda spinner)

#### 🎯 **Navigation**
- Widget ga bosganda `CurrencyPage` ochiladi
- Professional transition

#### 🎨 **UI Details**
- Clean, minimal design
- Chevron icon (o'ng tomonda) - bosilishi mumkinligini bildiradi
- Loading spinner (kichik va chiroyli)
- Subtle shadow effect

## Widget tuzilishi

```dart
Widget _buildCurrencyWidget() {
  return BlocBuilder<CurrencyBloc, CurrencyState>(
    builder: (context, state) {
      // USD kursini olish
      String usdRate = '...';
      bool isLoading = state.exchangeRatesStatus == Status.loading;

      if (state.exchangeRatesStatus == Status.success) {
        // USD topish
        final usdCurrency = state.exchangeRateModel!.rates
            .firstWhere((rate) => rate.code == 'USD');
        usdRate = usdCurrency.rate.split('.')[0];
      }

      return GestureDetector(
        onTap: () => Navigator.push(...CurrencyPage...),
        child: Container(
          // Styled container with loading/data states
        ),
      );
    },
  );
}
```

## UI States:

### 1. **Loading State**
```
┌─────────────────────────────┐
│ USD 1 ⇄ [spinner]        › │
└─────────────────────────────┘
```

### 2. **Success State**
```
┌─────────────────────────────┐
│ USD 1 ⇄ UZS 12021        › │
└─────────────────────────────┘
```

### 3. **Initial/Error State**
```
┌─────────────────────────────┐
│ USD 1 ⇄ UZS ...          › │
└─────────────────────────────┘
```

## User Experience Flow:

1. **Sahifa ochilganda:**
   - Partner list yuklanadi
   - Valyuta kurslari yuklanadi
   - Loading spinner ko'rsatiladi

2. **Ma'lumot kelganda:**
   - USD kursi ko'rsatiladi
   - Format: "UZS 12021" (faqat butun qism)

3. **Bosilganda:**
   - CurrencyPage ochiladi
   - Barcha valyutalar ko'rsatiladi
   - Back tugmasi bilan qaytish mumkin

## Data Flow:

```
ClientPage (initState)
    ↓
CurrencyBloc.add(GetExchangeRates)
    ↓
CurrencyRepository.getExchangeRates()
    ↓
API: /documents/currencys-exchange-rates
    ↓
ExchangeRateModel
    ↓
_buildCurrencyWidget (BlocBuilder)
    ↓
Display: "UZS 12021"
```

## Performance:

- ✅ Single API call on page load
- ✅ Cached in BLoC state
- ✅ No unnecessary rebuilds
- ✅ Efficient BlocBuilder usage
- ✅ Minimal widget tree

## Testing Scenarios:

1. **Normal Flow:**
   - Open client page
   - Wait for currency to load
   - Tap currency widget
   - Verify CurrencyPage opens

2. **Loading State:**
   - Check spinner shows during load
   - Verify no crash if tapped while loading

3. **Error Handling:**
   - API fails → shows "..."
   - Still navigable to CurrencyPage

4. **Data Display:**
   - USD rate formatted correctly
   - Only whole number shown (no decimals)

## Integration Points:

### ✅ **Client List Page**
- Shows USD rate in header
- Navigates to Currency Page

### ✅ **Currency BLoC**
- Provides exchange rates
- Manages loading states

### ✅ **Currency Page**
- Shows all currencies
- Pull-to-refresh
- Full details

---

**Developer:** Senior Flutter Developer
**Date:** 2025-12-21
**Status:** ✅ Production Ready
**Testing:** Ready for QA