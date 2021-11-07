import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mileage_wash/common/listener/ob.dart';
import 'package:mileage_wash/common/util/verification_utils.dart';
import 'package:mileage_wash/constant/route_ids.dart';
import 'package:mileage_wash/generated/l10n.dart';
import 'package:mileage_wash/model/global/app_data.dart';
import 'package:mileage_wash/server/controller/login_controller.dart';
import 'package:mileage_wash/ui/utils/loading_utils.dart';
import 'package:mileage_wash/ui/utils/toast_utils.dart';

enum LoginNavigationWay { pop, pushNamedAndRemoveUntil }

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _unameController = TextEditingController();
  late final TextEditingController _pwdController = TextEditingController();

  final GlobalKey _formKey = GlobalKey<FormState>();

  final FocusNode _blankNode = FocusNode();

  final Observer<bool> _loading = false.ob;

  DateTime? _lastPopTime;

  bool _isShowPassword = false;

  bool _nameAutoFocus = true;

  @override
  void initState() {
    super.initState();
    _unameController.text = AppData.instance.lastLoginInfo?.phoneNumber ?? '';
    if (_unameController.text != '') {
      _nameAutoFocus = false;
    }
  }

  @override
  void dispose() {
    _lastPopTime = null;
    super.dispose();
  }

  String? _verifyPhone(String? phone) {
    if (phone == null || phone == '') {
      return null;
    }

    return VerificationUtils.isChinaPhoneLegal(phone)
        ? null
        : S.of(context).login_phone_error;
  }

  String? _verifyPassword(String? password) {
    if (password == null || password == '') {
      return null;
    }

    return password.trim().length >= 6
        ? null
        : S.of(context).login_password_length_error;
  }

  Future<bool> _isAllowBack() async {
    final LoginNavigationWay? navigationWay =
        ModalRoute.of(context)!.settings.arguments as LoginNavigationWay?;
    if (navigationWay != LoginNavigationWay.pop) {
      if (_lastPopTime == null ||
          DateTime.now().difference(_lastPopTime!) >
              const Duration(seconds: 2)) {
        _lastPopTime = DateTime.now();
        ToastUtils.showToast(S.of(context).exit_tip_twice_click);
        return false;
      } else {
        _lastPopTime = DateTime.now();
      }
    }
    return true;
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        autovalidateMode: AutovalidateMode.always,
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              autofocus: _nameAutoFocus,
              controller: _unameController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                labelText: S.of(context).login_phone_text,
                hintText: S.of(context).login_phone_hint_text,
                prefixIcon: const Icon(Icons.person),
              ),
              validator: _verifyPhone,
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return TextFormField(
                controller: _pwdController,
                autofocus: !_nameAutoFocus,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'\S')),
                ],
                decoration: InputDecoration(
                    labelText: S.of(context).login_password_text,
                    hintText: S.of(context).login_password_hint_text,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isShowPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isShowPassword = !_isShowPassword;
                        });
                      },
                    )),
                obscureText: !_isShowPassword,
                validator: _verifyPassword,
              );
            }),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: TextButton(
                onPressed: _onLogin,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16)),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)))),
                  minimumSize: MaterialStateProperty.all(
                      Size(MediaQuery.of(context).size.width - 24, 0)),
                ),
                child: Text(
                  S.of(context).login_submit_text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(title: Text(S.of(context).login_title)),
          body:
              LoadingUtils.build(child: _buildLoginForm(), observer: _loading),
        ),
        onWillPop: _isAllowBack);
  }

  Future<void> _onLogin() async {
    // 提交前，先验证各个表单字段是否合法
    // 13262892612 123456
    if ((_formKey.currentState as FormState).validate()) {
      FocusScope.of(context).requestFocus(_blankNode);
      _loading.value = true;
      final bool isSuccess = await LoginController.login(
        context,
        username: _unameController.text,
        password: _pwdController.text,
      );
      _loading.value = false;
      _blankNode.unfocus();
      if (isSuccess) {
        final LoginNavigationWay? navigationWay =
            ModalRoute.of(context)!.settings.arguments as LoginNavigationWay?;
        if (navigationWay == LoginNavigationWay.pop) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              RouteIds.activity, (Route<dynamic> route) => false);
        }
      }
    }
  }
}
