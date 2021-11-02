class StringUtils {
  StringUtils._();

  static bool isEmpty(String? str) {
    return str == null || str == '';
  }

  static bool isTrimEmpty(String? str) {
    return str == null || str.trim() == '';
  }

}