import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart'; // Import the PropertyDetailsPage

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _allProperties = [];
  List<Map<String, dynamic>> _filteredProperties = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllProperties();
    _searchController.addListener(_filterProperties);
  }

  Future<void> _fetchAllProperties() async {
    try {
      final propertyCollection = FirebaseFirestore.instance.collection('properties');
      final snapshot = await propertyCollection.get();

      if (snapshot.docs.isEmpty) {
        debugPrint('No documents found in properties collection.');
      }

      final properties = snapshot.docs.map((doc) {
        return {
          'imageUrl': doc.data()['imageUrl'] ?? '',
          'location': doc.data()['location'] ?? 'Unknown',
          'price': doc.data()['price'] ?? 'Unknown',
          'bedroomCount': doc.data()['bedroomCount'] ?? 'Unknown',
        };
      }).toList();

      setState(() {
        _allProperties = properties;
        _filteredProperties = properties;
      });
    } catch (e) {
      debugPrint('Error fetching properties: $e');
    }
  }

  void _filterProperties() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProperties = _allProperties.where((property) {
        final location = property['location'].toLowerCase();
        return location.contains(query);
      }).toList();
    });
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
        title: const Text('Search Properties'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredProperties.isEmpty
                ? const Center(child: Text('No properties found.'))
                : ListView.builder(
                    itemCount: _filteredProperties.length,
                    itemBuilder: (context, index) {
                      final property = _filteredProperties[index];
                      final imageUrl = property['imageUrl'];
                      final location = property['location'];
                      final price = property['price'];
                      final bedroomCount = property['bedroomCount'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailsPage(
                                imageUrl: imageUrl,
                                location: location,
                                price: price,
                                bedroomCount: bedroomCount,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10.0)),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 50);
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location: $location',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text('Price: $price'),
                                      Text('Bedrooms: $bedroomCount'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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
