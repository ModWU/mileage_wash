class StringUtils {
  StringUtils._();

  static bool isEmpty(String? str) {
    return str == null || str == '';
  }

  static bool isTrimEmpty(String? str) {
    return str == null || str.trim() == '';
  }

  static String toSafeStr(Object? str) {
    return str?.toString() ?? '';
  }

  static List<String>? splitTrim(String? str, String split,
      {String? leading, String? trailing}) {
    if (str == null) {
      return null;
    }

    str = str.trim();
    if (str == '') {
      return null;
    }

    List<String> list = str.split(RegExp('\\s*$split\\s*'));

    if (list.isEmpty) {
      return null;
    }

    if (trailing != null || leading != null) {
      list = list
          .map<String>((String str) => '${leading ?? ''}$str${trailing ?? ''}')
          .toList();
    }

    return list;
  }

  static bool isEmptySplitTrim(String? str, String split) {
    return splitTrim(str, split) == null;
  }
}
