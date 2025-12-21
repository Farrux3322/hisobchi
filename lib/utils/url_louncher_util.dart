import 'package:url_launcher/url_launcher.dart';

Future<void> launchPhone(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone); // misol: "998937373322" yoki "+998937373322"
  if (!await launchUrl(uri)) {
    throw 'Telefon ilovasi ochilmadi: $uri';
  }
}

Future<void> launchSms(String phone, {String? body}) async {
  // body ni url encode qilish yaxshi
  final encodedBody = body == null ? null : Uri.encodeComponent(body);
  final uriString = encodedBody == null
      ? 'sms:$phone'
      : 'sms:$phone?body=$encodedBody';
  final uri = Uri.parse(uriString);
  if (!await launchUrl(uri)) {
    throw 'SMS ilovasi ochilmadi: $uri';
  }
}
