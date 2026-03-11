import 'package:flutter/services.dart';

/// A [TextInputFormatter] that prevents users from entering emojis (stickers).
/// This is useful for fields like names where emojis are not appropriate.
class EmojiFilterFormatter extends FilteringTextInputFormatter {
  EmojiFilterFormatter()
      : super.deny(
          RegExp(
            r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
          ),
        );
}
