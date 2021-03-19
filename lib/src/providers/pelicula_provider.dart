import 'package:peliculas/src/models/pelicula_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PeliculasProvider{
  String _apiKey = 'eb6dd47dbd32a3f446bf22764f1e749d';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async{
    final resp = await http.get(url);
    final decodedData = json.decode(resp.body);
    // print(decodedData);
    // print(decodedData['results']);
    final peliculas = new Peliculas.fromJsonList(decodedData['results']);
    // print(peliculas.items[2].title);

    return peliculas.items; //Lista de peliculas mapeadas
  }

  Future<List<Pelicula>> getEnCines() async{
    final url = Uri.https(_url, '3/movie/now_playing', { 
      'api_key': _apiKey,
      'language': _language,
    });
    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async{
    final url = Uri.https(_url, '3/movie/popular', { 
      'api_key': _apiKey,
      'language': _language,
    });
    return await _procesarRespuesta(url);
  }
}