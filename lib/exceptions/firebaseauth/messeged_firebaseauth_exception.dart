
abstract class MessagedFirebaseAuthException{
  final String _message;
  MessagedFirebaseAuthException(this._message);
  String get message => _message;
  @override
  String toString() {
    return message;
  }
}
