class VerificationUtils {
  VerificationUtils._();

  static bool isChinaPhoneLegal(String str) {
    return RegExp(
            r'^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\d{8}$')
        .hasMatch(str);
  }
}
