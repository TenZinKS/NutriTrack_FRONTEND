import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  static const empty = AuthUser(id: '', name: '', email: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, photoUrl];
}
