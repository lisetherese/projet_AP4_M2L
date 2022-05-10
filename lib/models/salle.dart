import 'dart:ui';

class Salle {
  final int id;
  final String nom;
  final int capacite;
  final int idDomaine;

  //mark your field required if it is mandatory for others to pass some value to it
  Salle(
      {required this.id,
      required this.nom,
      required this.capacite,
      required this.idDomaine});
  //function to simply deserialize the json
  // A necessary factory constructor for creating a new User instance
  // from a map.
  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      id: json['id'],
      nom: json['nom'],
      capacite: json['capacite'],
      idDomaine: json['id_domaine'],
    );
  }
  //use to replace a similar object in a Future<List<Object>> for dropDownButton
  @override
  bool operator == (dynamic other) =>
      // ignore: unnecessary_this
      other != null && other is Salle && this.id == other.id;

  @override
  int get hashCode => hashValues(id, nom, capacite, idDomaine);

  // `toJson` is the convention for a class to declare support for serialization
  Map<String, dynamic> toJson() =>
      {'nom': nom, 'capacite': capacite, 'id_domaine': idDomaine};
}
