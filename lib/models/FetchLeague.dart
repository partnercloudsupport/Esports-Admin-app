import 'dart:convert';

class FetchLeague {
  FetchLeague(
      {this.leagueName,
      this.president,
      this.leaguePhoto,
      this.admin,
      this.coach});

  factory FetchLeague.fromJson(Map<String, dynamic> json) {
    return FetchLeague(
        leagueName: json['leagueName'],
        leaguePhoto: json['leaguePhoto'],
        admin: json['admin'] == 'true' ? true : false,
        coach: json['coach'] == 'true' ? true : false,
        president: json['president'] == 'true' ? true : false);
  }

  final String leagueName;
  final bool president;
  final String leaguePhoto;
  final bool admin;
  final bool coach;
}

class FetchLeagues {
  FetchLeagues(this.leagues);
  final List<FetchLeague> leagues;

  factory FetchLeagues.fromJson(String leaguesData) {
    List<FetchLeague> temp = [];
    List<dynamic> data = json.decode(leaguesData);
    for (Map<String, dynamic> each in data) {
      temp.add(FetchLeague.fromJson(each));
    }
    return FetchLeagues(temp);
  }
}
