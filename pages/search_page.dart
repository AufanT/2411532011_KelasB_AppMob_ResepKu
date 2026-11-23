import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/services/recipe_service.dart';
import 'package:flutter_application_1/widgets/error_view.dart';
import 'package:flutter_application_1/widgets/recipe_tile.dart';

/// Latihan 1: halaman pencarian resep.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _queryController = TextEditingController();
  Future<List<Recipe>>? _searchFuture; // null = user belum mencari
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  // Future baru dibuat di dalam setState setiap kali user menekan Enter
  void _search(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() {
      _query = query;
      _searchFuture = context.read<RecipeService>().searchRecipes(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari resep, misalnya pasta',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            tooltip: 'Cari',
            icon: const Icon(Icons.search),
            onPressed: () => _search(_queryController.text),
          ),
        ],
      ),
      body: _searchFuture == null
          ? const Center(child: Text('Ketik kata kunci, lalu tekan Enter.'))
          : FutureBuilder<List<Recipe>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                // Loading: setiap pencarian baru menampilkan indikator
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Gagal mencari resep.\n${snapshot.error}',
                    onRetry: () => _search(_query),
                  );
                }
                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Tidak ada resep untuk "$_query".',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) =>
                      RecipeTile(recipe: recipes[index]),
                );
              },
            ),
    );
  }
}
