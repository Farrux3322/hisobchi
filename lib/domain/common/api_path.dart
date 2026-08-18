/// Global Base URL
/// Overridable at build time via: flutter build --dart-define=API_BASE_URL=https://api.ehisob.uz/api/
const String baseUrlApp = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: "https://api.pulza.uz/api/",
);

