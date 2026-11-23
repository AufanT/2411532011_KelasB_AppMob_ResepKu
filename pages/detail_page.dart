import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/recipe.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/favorite_provider.dart';
import 'package:flutter_application_1/services/recipe_service.dart';
import 'package:flutter_application_1/widgets/recipe_image.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipe});
  final Recipe recipe;
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int _servings; // state lokal: hanya halaman ini yang butuh
  final _nameController = TextEditingController(); // Latihan 2: dialog ubah nama
  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings; // nilai awal dari data resep
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Latihan 2: ubah nama dengan PUT /recipes/{id}
  Future<void> _editName() async {
    _nameController.text = widget.recipe.name;
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah nama resep'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nama baru'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _nameController.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || !mounted) return;

    final service = context.read<RecipeService>(); // diambil sebelum await
    try {
      final updated = await service.updateRecipe(
        widget.recipe.id,
        name: newName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Server mengubah nama menjadi "${updated.name}". '
            'dummyjson hanya menyimulasikan perubahan.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah nama: $e')),
      );
    }
  }

  // Latihan 2: hapus dengan DELETE /recipes/{id}
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus resep?'),
        content: Text('"${widget.recipe.name}" akan dihapus dari server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final service = context.read<RecipeService>();
    try {
      final deleted = await service.deleteRecipe(widget.recipe.id);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (deleted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '"${widget.recipe.name}" dihapus (isDeleted: true). '
              'dummyjson hanya menyimulasikan penghapusan.',
            ),
          ),
        );
        Navigator.pop(context); // tutup halaman detail
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Server tidak menghapus resep.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  void _addServing() {
    setState(() => _servings++);
  }

  void _removeServing() {
    if (_servings > 1) {
      setState(() => _servings--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final totalCalories = recipe.caloriesPerServing * _servings;
    final isFavorite = context.watch<FavoriteProvider>().isFavorite(recipe);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => context.read<FavoriteProvider>().toggle(recipe),
          ),
          PopupMenuButton<String>(
            tooltip: 'Menu lainnya',
            onSelected: (value) {
              if (value == 'edit') _editName();
              if (value == 'delete') _delete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Ubah nama'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: RecipeImage(url: recipe.image),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${recipe.cuisine} • ${recipe.difficulty} • ${recipe.totalTimeMinutes} menit',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('Porsi', style: textTheme.titleMedium),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: _servings > 1 ? _removeServing : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_servings', style: textTheme.titleLarge),
                  ),
                  IconButton.filledTonal(
                    onPressed: _addServing,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total kalori: $totalCalories kkal',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Text('Bahan', style: textTheme.titleLarge),
          for (final item in recipe.ingredients)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(item),
            ),
          if (recipe.instructions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Langkah', style: textTheme.titleLarge),
            for (final (index, step) in recipe.instructions.indexed)
              ListTile(
                dense: true,
                leading: CircleAvatar(radius: 12, child: Text('${index + 1}')),
                title: Text(step),
              ),
          ],
        ],
      ),
    );
  }
}
