import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon y Letras',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = PokemonSearchPage();
        break;
      case 1:
        page = LyricsSearchPage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon y Letras'),
      ),
      body: Row(
        children: [
          NavigationRail(
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.search),
                label: Text('Pokémon'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.music_note),
                label: Text('Letras'),
              ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
          Expanded(child: page),
        ],
      ),
    );
  }
}

class PokemonSearchPage extends StatefulWidget {
  @override
  _PokemonSearchPageState createState() => _PokemonSearchPageState();
}

class _PokemonSearchPageState extends State<PokemonSearchPage> {
  final TextEditingController _pokemonController = TextEditingController();
  Map<String, dynamic>? pokemonData;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchPokemon(String name) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
      );

      if (response.statusCode == 200) {
        setState(() {
          pokemonData = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'Pokémon no encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al buscar el Pokémon.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _pokemonController,
            decoration: InputDecoration(
              labelText: 'Nombre del Pokémon',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final name = _pokemonController.text.toLowerCase();
              if (name.isNotEmpty) {
                fetchPokemon(name);
              }
            },
            child: Text('Buscar Pokémon'),
          ),
          SizedBox(height: 20),
          if (isLoading) CircularProgressIndicator(),
          if (errorMessage.isNotEmpty)
            Text(errorMessage, style: TextStyle(color: Colors.red)),
          if (pokemonData != null)
            Column(
              children: [
                Image.network(pokemonData!['sprites']['front_default']),
                Text(
                  pokemonData!['name'].toString().toUpperCase(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('Peso: ${pokemonData!['weight']}'),
                Text('Altura: ${pokemonData!['height']}'),
                Text('Habilidades:'),
                for (var ability in pokemonData!['abilities'])
                  Text('• ${ability['ability']['name']}'),
              ],
            ),
        ],
      ),
    );
  }
}

class LyricsSearchPage extends StatefulWidget {
  @override
  _LyricsSearchPageState createState() => _LyricsSearchPageState();
}

class _LyricsSearchPageState extends State<LyricsSearchPage> {
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _songController = TextEditingController();
  String lyrics = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchLyrics(String artist, String song) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.lyrics.ovh/v1/$artist/$song'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          lyrics = data['lyrics'];
        });
      } else {
        setState(() {
          errorMessage = 'No se encontraron letras para esta canción.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al buscar la letra.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _artistController,
            decoration: InputDecoration(
              labelText: 'Artista',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _songController,
            decoration: InputDecoration(
              labelText: 'Canción',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final artist = _artistController.text.trim();
              final song = _songController.text.trim();
              if (artist.isNotEmpty && song.isNotEmpty) {
                fetchLyrics(artist, song);
              }
            },
            child: Text('Buscar Letra'),
          ),
          SizedBox(height: 20),
          if (isLoading) CircularProgressIndicator(),
          if (errorMessage.isNotEmpty)
            Text(errorMessage, style: TextStyle(color: Colors.red)),
          if (lyrics.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    lyrics,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
