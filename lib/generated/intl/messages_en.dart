// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "bottom_navigation_home_title":
            MessageLookupByLibrary.simpleMessage("home"),
        "bottom_navigation_me_title":
            MessageLookupByLibrary.simpleMessage("me"),
        "home_order_item_cancelled_btn":
            MessageLookupByLibrary.simpleMessage("cancelled"),
        "home_order_item_done_btn":
            MessageLookupByLibrary.simpleMessage("done"),
        "home_order_item_waiting_btn":
            MessageLookupByLibrary.simpleMessage("arrived"),
        "home_order_item_washing_btn":
            MessageLookupByLibrary.simpleMessage("washed"),
        "home_tab_cancelled": MessageLookupByLibrary.simpleMessage("cancelled"),
        "home_tab_done": MessageLookupByLibrary.simpleMessage("done"),
        "home_tab_waiting": MessageLookupByLibrary.simpleMessage("waiting"),
        "home_tab_washing": MessageLookupByLibrary.simpleMessage("washing"),
        "home_title": MessageLookupByLibrary.simpleMessage("Mileage Wash"),
        "login_password_hint_text":
            MessageLookupByLibrary.simpleMessage("Please input password"),
        "login_password_length_error": MessageLookupByLibrary.simpleMessage(
            "The password must contain at least six characters"),
        "login_password_text": MessageLookupByLibrary.simpleMessage("password"),
        "login_phone_error":
            MessageLookupByLibrary.simpleMessage("Illegal phone number "),
        "login_phone_hint_text":
            MessageLookupByLibrary.simpleMessage("Please input phone"),
        "login_phone_text": MessageLookupByLibrary.simpleMessage("phone"),
        "login_submit_text": MessageLookupByLibrary.simpleMessage("Login"),
        "login_title": MessageLookupByLibrary.simpleMessage("Login"),
        "me_logout_text": MessageLookupByLibrary.simpleMessage("Logout"),
        "title": MessageLookupByLibrary.simpleMessage("Mileage Wash")
      };
}
