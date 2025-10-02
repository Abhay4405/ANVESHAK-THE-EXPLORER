import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../main.dart';

class ParentAuthPage extends StatefulWidget {
  const ParentAuthPage({super.key});

  @override
  _ParentAuthPageState createState() => _ParentAuthPageState();
}

class _ParentAuthPageState extends State<ParentAuthPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedIdType;

  // States for image handling
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID Proof Image Selected!')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final double formWidth = MediaQuery.of(context).size.width > 600 ? 500.0 : double.infinity;

    return Scaffold(
      // FIX: Removed const from AppBar
      appBar: AppBar(title: const Text('Report Lost: Step 1/2')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Container(
            width: formWidth,
            padding: const EdgeInsets.all(30),
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
                  _buildProgressBar(context, 1),
                  const SizedBox(height: 20),
                  Text(
                    'Verify Parent Identity (Authentication)',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This step ensures security and prevents misuse of the system.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 30),

                  // ID Type Selection
                  _buildDropdownField(
                    'Select Government ID Type',
                    Icons.badge,
                    ['Aadhaar Card', 'Voter ID', 'Ration Card', 'Passport'],
                    (String? newValue) {
                      setState(() {
                        _selectedIdType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // ID Number Input
                  _buildTextField('Enter Selected ID Number', Icons.credit_card, TextInputType.number),
                  const SizedBox(height: 20),

                  // Upload ID Proof Button
                  _buildUploadButton('Upload ID Proof Photo (OCR Check)', Icons.camera_alt, Theme.of(context).colorScheme.secondary),
                  
                  const SizedBox(height: 10),

                  // Image Preview (for feedback)
                  _buildImagePreview(context),
                  
                  const SizedBox(height: 10),
                  Center(child: Text('OCR/AI based identity check will be performed', style: TextStyle(fontSize: 12, color: Colors.grey))),
                  const SizedBox(height: 30),
                  
                  // OTP Check
                   _buildTextField('Enter OTP Sent to Registered Phone/Email', Icons.sms_outlined, TextInputType.number),
                   const SizedBox(height: 10),
                   Center(child: Text('Final verification via OTP to ensure contact details are correct', style: TextStyle(fontSize: 12, color: Colors.grey))),
                   const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && (_mobileImage != null || _webImage != null)) {
                          // On successful validation, move to next step
                          Navigator.pushNamed(context, Routes.personDetails); 
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a Government ID Type and upload the photo.')),
                          );
                        }
                      },
                      child: const Text('Proceed to Step 2 (Person Details)'),
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
  
  // Image Preview Widget
  Widget _buildImagePreview(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.7), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: kIsWeb
            ? (_webImage != null
                ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_webImage!, fit: BoxFit.cover))
                : const Center(child: Icon(Icons.image_search, size: 40, color: Colors.grey)))
            : (_mobileImage != null
                ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_mobileImage!, fit: BoxFit.cover))
                : const Center(child: Icon(Icons.image_search, size: 40, color: Colors.grey))),
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

  // Helper Widgets 
  Widget _buildTextField(String label, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
  
  Widget _buildDropdownField(String label, IconData icon, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.7)),
      ),
      value: _selectedIdType,
      hint: Text(label),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a valid ID type' : null,
    );
  }

  Widget _buildUploadButton(String label, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // FIX: Added image picking dialog 
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Photo Library'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Camera'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        icon: Icon(icon, color: color),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}