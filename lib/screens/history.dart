import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/history_manager.dart';
import 'detail.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryManager _historyManager = HistoryManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          ValueListenableBuilder<List<HistoryEntry>>(
            valueListenable: _historyManager.historyNotifier,
            builder: (context, history, _) {
              if (history.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Hapus Semua Riwayat',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Semua Riwayat'),
                      content: const Text(
                          'Apakah Anda yakin ingin menghapus semua riwayat? '
                          'Tindakan ini tidak dapat dibatalkan.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            _historyManager.clearAll();
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Semua riwayat telah dihapus'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text('Hapus Semua'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<HistoryEntry>>(
        valueListenable: _historyManager.historyNotifier,
        builder: (context, history, _) {
          if (history.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Riwayat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Negara yang Anda kunjungi akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final country = entry.country;
              final timeFormatted =
                  DateFormat('dd MMM yyyy, HH:mm').format(entry.viewedAt);

              return Dismissible(
                key: ValueKey('${country.name}_${entry.viewedAt.millisecondsSinceEpoch}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Riwayat'),
                      content: Text(
                          'Hapus "${country.name}" dari riwayat secara permanen?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) {
                  _historyManager.removeEntry(entry);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${country.name} dihapus dari riwayat'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: country.flagsPng != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              country.flagsPng!,
                              width: 50,
                              height: 35,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox(
                                  width: 50, child: Icon(Icons.flag)),
                            ),
                          )
                        : const SizedBox(width: 50, child: Icon(Icons.flag)),
                    title: Text(
                      country.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${country.region} • $timeFormatted',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red),
                      tooltip: 'Hapus dari Riwayat',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Hapus Riwayat'),
                            content: Text(
                                'Hapus "${country.name}" dari riwayat secara permanen?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _historyManager.removeEntry(entry);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${country.name} dihapus dari riwayat'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(country: country),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
