import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/models/favorite.dart';
import 'package:flutter_application_1/pages/detail_page.dart';
import 'package:flutter_application_1/providers/favorite_provider.dart';
import 'package:flutter_application_1/providers/settings_provider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  Future<void> _editNote(BuildContext context, Favorite item) async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => _NoteDialog(initial: item.note),
    );
    // null = Batal ditekan; halaman juga dapat sudah ditutup selama menunggu
    if (note == null || !context.mounted) return;
    await context.read<FavoriteProvider>().updateNote(
      item.recipe.id,
      note.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Latihan 1: urutan dibaca dari SettingsProvider (tersimpan di HP)
    final settings = context.watch<SettingsProvider>();
    final sort = settings.favoriteSort;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        actions: [
          PopupMenuButton<FavoriteSort>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort),
            initialValue: sort,
            onSelected: settings.setFavoriteSort,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: FavoriteSort.newest,
                child: Text('Terbaru disimpan'),
              ),
              PopupMenuItem(value: FavoriteSort.name, child: Text('Nama A–Z')),
            ],
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favorite, child) {
          if (favorite.count == 0) {
            return const Center(
              child: Text(
                'Belum ada resep favorit.\nTekan ikon hati di daftar resep.',
                textAlign: TextAlign.center,
              ),
            );
          }
          // Latihan 1: urutkan SALINAN list, bukan list milik provider
          final items = [...favorite.items];
          if (sort == FavoriteSort.name) {
            items.sort(
              (a, b) => a.recipe.name.toLowerCase().compareTo(
                b.recipe.name.toLowerCase(),
              ),
            );
          }
          // newest: urutan dari provider sudah terbaru di atas

          return ListView(
            children: [
              for (final item in items)
                ListTile(
                  title: Text(item.recipe.name),
                  subtitle: Text(
                    item.note.isEmpty ? 'Belum ada catatan' : item.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(recipe: item.recipe),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Catatan',
                        icon: const Icon(Icons.edit_note),
                        onPressed: () => _editNote(context, item),
                      ),
                      IconButton(
                        tooltip: 'Hapus dari favorit',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => favorite.toggle(item.recipe),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Dialog catatan. StatefulWidget agar dapat membuat dan men-dispose
/// TextEditingController miliknya sendiri.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan pribadi'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Contoh: kurangi garam'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
