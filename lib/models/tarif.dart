import 'dart:ui';

class Tarif {
  final int id;
  final double tarif;
  final int niveau;

  //mark your field required if it is mandatory for others to pass some value to it
  Tarif({required this.id, required this.tarif, required this.niveau});
  //function to simply deserialize the json
  factory Tarif.fromJson(Map<String, dynamic> json) {
    return Tarif(
      id: json['id'],
      tarif: json['tarif'],
      niveau: json['niveau'],
    );
  }

  //use to replace a similar object in a Future<List<Object>> for dropDownButton
  @override
  bool operator == (dynamic other) =>
      // ignore: unnecessary_this
      other != null && other is Tarif && this.id == other.id;

  @override
  int get hashCode => hashValues(id, tarif, niveau);

  Map<String, dynamic> toJson() => {'tarif': tarif};
}
