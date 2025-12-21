abstract class UserEntity {
  const UserEntity({
    required this.middleName,
    required this.firstName,
    required this.lastName,
    required this.id,
    required this.phone,
    required this.password,
    required this.businesses,
  });

  final String middleName;
  final String firstName;
  final String lastName;
  final String id;
  final String phone;
  final String password;
  final List<String> businesses;
}
