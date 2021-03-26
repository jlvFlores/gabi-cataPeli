import 'dart:async';
import 'dart:convert';
import 'package:peliculas/src/models/actores_model.dart';
import 'package:peliculas/src/models/pelicula_model.dart';
import 'package:http/http.dart' as http;

class PeliculasProvider{
  String _apiKey = 'eb6dd47dbd32a3f446bf22764f1e749d';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';
  int _popularesPage = 0;
  bool _cargando = false;

  // ignore: deprecated_member_use
  List<Pelicula> _populares = new List();

  final _popularesStreamController = 
      StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink => 
      _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream =>
      _popularesStreamController.stream;

  void disposeStreams(){
    _popularesStreamController?.close();
  }

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
    if (_cargando) return [];
    _cargando = true;
    _popularesPage++;
    print('cargando siguentes ... ');
    final url = Uri.https(_url, '3/movie/popular', { 
      'api_key': _apiKey,
      'language': _language,
      'page': _popularesPage.toString(),
    });
    final resp = await _procesarRespuesta(url);

    _populares.addAll(resp);
    popularesSink(_populares); // añadir info al stream
    _cargando = false;
    return resp;
  }

  Future<List<Actor>> getCast(String peliculaId) async{
    final url = Uri.https(_url, '3/movie/$peliculaId/credits', { 
      'api_key': _apiKey,
      'language': _language,
    });
    final resp = await http.get(url);

    final decodedData = json.decode(resp.body);
    final cast = new Cast.fromJsonList(decodedData['cast']);
    return cast.actores;
  }
}