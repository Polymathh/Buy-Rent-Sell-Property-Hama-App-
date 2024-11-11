import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final String userId = "userId123"; // Replace with the actual user ID (you can use Firebase Authentication)

  // Fetch favourite properties from Firestore
  Future<List<DocumentSnapshot>> _fetchFavourites() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favourites')
          .get();

      return snapshot.docs;
    } catch (e) {
      print('Error fetching favourites: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchFavourites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching favourites.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favourites found.'));
          }

          final favourites = snapshot.data!;

          return ListView.builder(
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> propertyData = favourites[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: propertyData['imageUrl'] != null
                    ? Image.network(propertyData['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.home),
                title: Text('Location: ${propertyData['location']}'),
                subtitle: Text('Price: ${propertyData['price']}'),
                trailing: Text('${propertyData['numberOfBedrooms']} Bedrooms'),
                onTap: () {
                  // You can add an action when the user taps on a favourite property.
                },
              );
            },
          );
        },
      ),
    );
  }
}
