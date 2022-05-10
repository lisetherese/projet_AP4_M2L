import 'dart:ui';

class Domaine {
  final int id;
  final String libelle;

  //mark your field required if it is mandatory for others to pass some value to it
  Domaine({required this.id, required this.libelle});
  //function to simply deserialize the json
  factory Domaine.fromJson(Map<String, dynamic> json) {
    return Domaine(
      id: json['id'],
      libelle: json['libelle'],
    );
  }

  //use to replace a similar object in a Future<List<Object>> for dropDownButton
  @override
  bool operator == (dynamic other) =>
      // ignore: unnecessary_this
      other != null && other is Domaine && this.id == other.id;

  @override
  int get hashCode => hashValues(id, libelle);

  Map<String, dynamic> toJson() => {'libelle': libelle};
}
