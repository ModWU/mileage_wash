class HTTPApis {
  HTTPApis._();

  static const String offlineBeta = 'https://chehuanxin.com:8080/car-sys/api';//'http://chehuanxin.com:8080/car-sys/api';
  static const String onlineBeta = 'https://open-joist.com/car-sys/api';
  static const String production = 'http://chehuanxin.com:8080/car-sys/api';

  static const String carImgURL = 'https://chehuanxin.com:8080/file/car/img/';//'https://file.jue-huo.com/file/car/img';

  static const String login = '/login';
  static const String logout = '/logout';

  static const String orderList = '/order/orderList';
  static const String saveOrder = '/order/saveOrder';
  static const String updateAddress = '/order/updateAddress';
  static const String orderDetails = '/order/orderDetail';

  static const String upload = '/common/upload';
}
