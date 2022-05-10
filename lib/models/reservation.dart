class Reservation {
  final int id;
  final String breveDes;
  final String des;
  final int etat;
  final String debut;
  final String update;
  final String fin;
  final int idUser;
  final int idTarif;
  final int idSalle;
  final int idDomaine;

  //mark your field required if it is mandatory for others to pass some value to it
  Reservation(
      {required this.id,
      required this.breveDes,
      required this.des,
      required this.etat,
      required this.debut,
      required this.update,
      required this.fin,
      required this.idUser,
      required this.idTarif,
      required this.idSalle,
      required this.idDomaine});
  //function to simply deserialize the json
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
        id: json['id'],
        breveDes: json['breve_description'],
        des: json['description_complete'],
        etat: json['etat_confirmation'],
        debut: json['date_heure_debut'],
        update: json['date_heure_update'],
        fin: json['date_heure_fin'],
        idUser: json['id_utilisateur'],
        idTarif: json['id_tarif_reservation'],
        idSalle: json['id_salle'],
        idDomaine: json['id_domaine']);
  }

  //Map<String, dynamic> toJson() => {'breve_description': breveDes};
}
