import 'dart:async';
void main() {
  var f = () async { throw Exception('error'); };
  try {
    f();
    print('Did not throw synchronously');
  } catch (e) {
    print('Threw synchronously');
  }
}
