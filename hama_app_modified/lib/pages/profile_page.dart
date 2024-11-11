import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String? phoneNumber;
  String? profilePictureUrl;

  // Controller for name input field
  final TextEditingController _nameController = TextEditingController();

  // Fetch user profile from Firestore
  Future<void> _fetchUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        name = user.displayName ?? 'No Name';
        email = user.email ?? 'No Email';
        phoneNumber = user.phoneNumber ?? 'No Phone Number';
        profilePictureUrl = user.photoURL ?? ''; // User's profile picture (URL)
        _nameController.text = name; // Set the name controller text
      });
    }
  }

  // Update user profile in Firestore
  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;

    if (user != null && _formKey.currentState!.validate()) {
      try {
        await user.updateDisplayName(_nameController.text);
        // Update any other profile info you want to update (e.g., photo)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        setState(() {
          name = _nameController.text;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Display Profile Picture
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                        ? NetworkImage(profilePictureUrl!)
                        : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20),

                // Display Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Display Email
                Text(
                  'Email: $email',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Display Phone Number
                if (phoneNumber != null) ...[
                  Text(
                    'Phone Number: $phoneNumber',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],

                // Update Button
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Update Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
