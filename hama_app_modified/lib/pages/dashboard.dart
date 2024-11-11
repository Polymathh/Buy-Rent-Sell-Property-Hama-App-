import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_property.dart';
import 'favorites.dart';
import 'profile_page.dart';
import 'search.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Map<String, dynamic>>> _propertyListFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _propertyListFuture = _fetchProperties();
  }

  Future<List<Map<String, dynamic>>> _fetchProperties() async {
    try {
      final propertyCollection = FirebaseFirestore.instance.collection('properties');
      final snapshot = await propertyCollection.get();
      for (var doc in snapshot.docs) {
        debugPrint(doc.data().toString()); // Print the document data to verify field names and structure.
      }

      if (snapshot.docs.isEmpty) {
        debugPrint('No documents found in properties collection.');
      }
      return snapshot.docs.map((doc) {
        return {
          'imageUrl': doc.data()['imageUrl'] ?? '',
          'location': doc.data()['location'] ?? 'Unknown',
          'price': doc.data()['price'] ?? 'Unknown',
          'bedroomCount': doc.data()['bedroomCount'] ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching properties: $e');
      return [];
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddPropertyPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavouritesPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const Center(child: Text('Search Page'));
      case 2:
        return const SizedBox.shrink();
      case 3:
        return const Center(child: Text('Favorites'));
      case 4:
        return const Center(child: Text('My Profile'));
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hama Fast'),
        backgroundColor: Colors.teal,
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "Explore Available Properties",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _propertyListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No properties found.'));
              }

              final propertyItems = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: propertyItems.length,
                itemBuilder: (context, index) {
                  final property = propertyItems[index];
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
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                              child: Image.network(
                                       imageUrl,
                                       fit: BoxFit.cover,
                                       errorBuilder: (context, error, stackTrace) {
                                         debugPrint('Failed to load image: $error');
                                         return const Center(child: Icon(Icons.broken_image, size: 50));
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                         if (loadingProgress == null) return child;
                                         return const Center(child: CircularProgressIndicator());
                                       },
                                      )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location: $location',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Price: $price',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Bedrooms: $bedroomCount',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class PropertyDetailsPage extends StatelessWidget {
  final String imageUrl;
  final String location;
  final String price;
  final String bedroomCount;

  const PropertyDetailsPage({
    super.key,
    required this.imageUrl,
    required this.location,
    required this.price,
    required this.bedroomCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, size: 100));
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location: $location',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: $price',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bedrooms: $bedroomCount',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
