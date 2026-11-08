import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:flutter_application_1/pages/detail_page.dart';
import 'package:flutter_application_1/providers/favorite_provider.dart';

class RecipeTile extends StatelessWidget {
  const RecipeTile({super.key, required this.recipe});
  final Recipe recipe;
  @override
  Widget build(BuildContext context) {
    // watch: widget ini ikut rebuild saat daftar favorit berubah
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(recipe);
    return ListTile(
      leading: CircleAvatar(child: Text(recipe.name[0])),
      title: Text(recipe.name),
      subtitle: Text(
        '${recipe.cuisine} • ${recipe.totalTimeMinutes} menit • ★ ${recipe.rating}',
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        // read: di dalam callback cukup "membaca", tidak perlu listen
        onPressed: () => context.read<FavoriteProvider>().toggle(recipe),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage(recipe: recipe)),
      ),
    );
  }
}
