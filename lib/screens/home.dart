import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/country.dart';
import '../services/favorites_manager.dart';
import '../services/history_manager.dart';
import 'detail.dart';

export '../models/country.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countries;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRegion = 'Semua';

  final List<String> _regions = [
    'Semua',
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
    'Antarctic',
  ];

  @override
  void initState() {
    super.initState();
    countries = fetchCountries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse('https://countries.dev/countries');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((j) => Country.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama negara, ibukota, region...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),
          // Region filter chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _regions.length,
              itemBuilder: (context, index) {
                final region = _regions[index];
                final isSelected = region == _selectedRegion;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      region,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey.shade200,
                    checkmarkColor: Colors.white,
                    onSelected: (_) {
                      setState(() {
                        _selectedRegion = region;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          // Country list
          Expanded(
            child: FutureBuilder<List<Country>>(
              future: countries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No countries found'));
                }

                var allCountries = snapshot.data!;

                // Filter by region
                if (_selectedRegion != 'Semua') {
                  allCountries = allCountries
                      .where((c) => c.region == _selectedRegion)
                      .toList();
                }

                // Filter by search query
                final filtered = _searchQuery.isEmpty
                    ? allCountries
                    : allCountries.where((c) {
                        final q = _searchQuery.toLowerCase();
                        final nameMatch = c.name.toLowerCase().contains(q);
                        final capitalMatch =
                            c.capital?.toLowerCase().contains(q) ?? false;
                        final regionMatch =
                            c.region.toLowerCase().contains(q);
                        return nameMatch || capitalMatch || regionMatch;
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada hasil untuk "$_searchQuery"'
                              : 'Tidak ada negara di region "$_selectedRegion"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coba kata kunci lain atau ubah filter benua',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final country = filtered[i];
                    return Card(
                      child: ListTile(
                        leading: country.flagsPng != null
                            ? Image.network(
                                country.flagsPng!,
                                width: 50,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox(width: 50, child: Icon(Icons.flag)),
                              )
                            : const SizedBox(width: 50, child: Icon(Icons.flag)),
                        title: Text(country.name),
                        subtitle: Text(country.region),
                        trailing: ValueListenableBuilder<List<Country>>(
                          valueListenable: FavoritesManager().favoritesNotifier,
                          builder: (context, _, _) {
                            final isFav = FavoritesManager().isFavorite(country);
                            return IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey,
                              ),
                              tooltip: isFav
                                  ? 'Hapus dari Favorit'
                                  : 'Tambah ke Favorit',
                              onPressed: () {
                                final added =
                                    FavoritesManager().toggleFavorite(country);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      added
                                          ? '${country.name} ditambahkan ke favorit'
                                          : '${country.name} dihapus dari favorit',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        onTap: () {
                          HistoryManager().addToHistory(country);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(country: country),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
