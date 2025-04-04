import 'package:flutter/material.dart';
import '../services/firestore_services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirestoreService _service = FirestoreService();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _service.searchByRegNo(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Hall Finder'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter registration number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _results = []);
                  },
                ),
              ),
              onChanged: _search,
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator()
          else if (_results.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'Enter a registration number to search'
                      : 'No results found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final data = _results[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(data['seat'] ?? '?'),
                      ),
                      title: Text(
                        data['reg_no'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Room: ${data['room'] ?? 'Unknown'}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Add navigation to details if needed
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}