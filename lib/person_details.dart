import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../main.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonDetailsPage extends StatefulWidget {
  const PersonDetailsPage({super.key});

  @override
  _PersonDetailsPageState createState() => _PersonDetailsPageState();
}

class _PersonDetailsPageState extends State<PersonDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? _mobileImage;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
      } else {
        _mobileImage = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;
    const double paddingValue = 20.0;
    final double formWidth = isWeb ? 600.0 : double.infinity;

    return Scaffold(
      // FIX: Removed const from AppBar
      appBar: AppBar(title: const Text('Report Lost: Step 2/2')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(paddingValue),
          child: Container(
            width: formWidth,
            padding: EdgeInsets.all(isWeb ? 40 : 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 20, spreadRadius: 5),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressBar(context, 2),
                  const SizedBox(height: 20),
                  Text(
                    'Missing Person Details (Database 1)',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 25),

                  _buildTextField('Full Name of Missing Person', nameController, Icons.person_off),
                  const SizedBox(height: 15),
                  _buildTextField('Age (Approx.)', ageController, Icons.cake, TextInputType.number),
                  const SizedBox(height: 15),
                  _buildTextField('Last Seen Address', addressController, Icons.location_on),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Distinctive Features (Birth Mark, Disability, Habbits, etc.)',
                      prefixIcon: Icon(Icons.description, color: Theme.of(context).primaryColor.withOpacity(0.7)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a description or features' : null,
                  ),
                  const SizedBox(height: 30),

                  const Text('Upload Missing Person\'s Recent Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('High-quality photo is crucial for AI matching.', style: TextStyle(fontSize: 14, color: Colors.red[400])),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildImagePickerButton(Icons.camera_alt, 'Camera', () => _pickImage(ImageSource.camera), context),
                      _buildImagePickerButton(Icons.photo, 'Gallery', () => _pickImage(ImageSource.gallery), context),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: kIsWeb
                          ? (_webImage != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.memory(_webImage!, fit: BoxFit.cover))
                              : const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)))
                          : (_mobileImage != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_mobileImage!, fit: BoxFit.cover))
                              : const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey))),
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && (_mobileImage != null || _webImage != null)) {
                          // Final Submission to Database 1 (Matching Algorithm kicks off here)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Missing Person Report Submitted! Matching Process Started.')),
                          );
                          Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
                        } else if (_mobileImage == null && _webImage == null) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please upload a photo of the missing person.')),
                          );
                        }
                      },
                      child: const Text('Submit Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Progress Bar Helper
  Widget _buildProgressBar(BuildContext context, int step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step $step of 2', style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: step / 2,
          backgroundColor: Colors.grey[300],
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  // HELPER FUNCTIONS 
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildImagePickerButton(IconData icon, String label, VoidCallback onPressed, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1),
        ),
      ),
    );
  }
}