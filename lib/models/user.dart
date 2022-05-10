class User {
  final int id;
  final String email;
  final String role;
  final int droitReservation;
  final int niveauTarif;
  final String jwt;

  User(
      {required this.id,
      required this.email,
      required this.role,
      required this.droitReservation,
      required this.niveauTarif,
      required this.jwt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      droitReservation: json['droit_reservation'],
      niveauTarif: json['niveau_tarif'],
      jwt: json['jwt'] ?? "",
    );
  }
}
