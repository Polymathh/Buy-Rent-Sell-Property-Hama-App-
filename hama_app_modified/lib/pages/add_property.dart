import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  XFile? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  String? _bedroomCount;
  int? _actualBedroomCount;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Method to pick image or video
  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = pickedFile;
      });
    }
  }

  // Method to handle posting the property
  void _postProperty() async {
    // Get property details
    final location = _locationController.text;
    final price = _priceController.text;
    final bedroomCount = _bedroomCount ?? 'Unknown';

    if (_mediaFile != null) {
      try {
        // Convert XFile to a data stream for web compatibility
        final storageReference = FirebaseStorage.instance
            .ref()
            .child('property_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = storageReference.putData(
          await _mediaFile!.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // Wait for the upload to complete and get the download URL
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Save property details to Firestore
        await FirebaseFirestore.instance.collection('properties').add({
          'location': location,
          'price': price,
          'bedroomCount': bedroomCount,
          'imageUrl': imageUrl,  // Store the image URL
          'createdAt': Timestamp.now(),
        });

        // Clear the form
        _locationController.clear();
        _priceController.clear();
        setState(() {
          _mediaFile = null;
          _bedroomCount = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property posted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting property: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Property"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upload Photo or Video",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickMedia(ImageSource.gallery),
                    child: const Text("Choose Photo"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
                    child: const Text("Choose Video"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Select Bedroom Count",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Column(
                children: [
                  // Radio buttons for bedroom selection
                  for (String label in [
                    'Single Room',
                    'Bed-sitter',
                    '1 Bedroom',
                    '2 Bedrooms',
                    '3 Bedrooms',
                    '4 Bedrooms',
                    '5+ Bedrooms'
                  ])
                    RadioListTile<String>(
                      title: Text(label),
                      value: label,
                      groupValue: _bedroomCount,
                      onChanged: (value) {
                        setState(() {
                          _bedroomCount = value;
                          _actualBedroomCount = null;
                        });
                      },
                    ),
                  if (_bedroomCount == '5+ Bedrooms')
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Enter number of bedrooms',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _actualBedroomCount = int.tryParse(value);
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Property Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Enter property location',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Price",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  hintText: 'Enter property price',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _postProperty,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text('Post property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
