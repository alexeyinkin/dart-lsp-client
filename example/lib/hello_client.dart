import 'hello_macro.dart';

@Hello()
class User {
  const User({
    required this.age,
    required this.name,
    required this.username,
  });

  final int? age;
  final String name;
  final String username;
}

void main() {
  const user = User(
    age: 5,
    name: 'Roger',
    username: 'roger1337',
  );
  user.hello();
}
