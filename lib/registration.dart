import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double formWidth = MediaQuery.of(context).size.width > 600 ? 500.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(title: const Text('New User Registration')),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Anveshak',
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'Create your secure account to report a lost person or a found person.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),

                _buildTextField('Full Name', Icons.person),
                const SizedBox(height: 20),
                _buildTextField('Email', Icons.email),
                const SizedBox(height: 20),
                _buildTextField('Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                // **Fixed the error by changing the argument to named argument**
                _buildTextField('Create Password', Icons.lock, isObscure: true),
                const SizedBox(height: 30),

                // Legal Consent Box - Crucial part of your flowchart
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(value: true, onChanged: (val) {}, activeColor: Theme.of(context).primaryColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          'I agree to the Terms & Conditions and understand that any false claim may result in legal action.',
                          style: TextStyle(fontSize: 14, color: Colors.red[700], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // After basic registration, user goes to login or home.
                      // For simplicity, let's navigate to Login.
                      Navigator.pop(context); // Go back to login
                    },
                    child: const Text('Complete Registration'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIX: Using named and default arguments for better clarity and flexibility
  Widget _buildTextField(
    String label, 
    IconData icon, 
    {
      TextInputType keyboardType = TextInputType.text, 
      bool isObscure = false // Default value is false
    }
  ) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}