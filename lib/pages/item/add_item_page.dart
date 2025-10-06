// lib/pages/add_item_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../widgets/custom_input_field.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});
  @override
  AddItemPageState createState() => AddItemPageState();
}

class AddItemPageState extends State<AddItemPage> {
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _uploading = false;

  Future<void> pickImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _image = File(img.path));
  }

  Future<void> _handleUpload() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (_image == null) return;

    setState(() => _uploading = true);
    final svc = Provider.of<SupabaseService>(context, listen: false);

    await svc.addItem(
      title: _titleCtrl.text.trim(),
      desc: _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      contact: _contactCtrl.text.trim(),
      uploaderName: _nameCtrl.text.trim(),
      image: _image!,
    );

    setState(() => _uploading = false);
    if (svc.error == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${svc.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUpload = _image != null && !_uploading;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4CC9F0), // light blue top
            Color(0xFF90E0EF), // aqua
            Color(0xFFFFB385), // peach/orange bottom
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            '✨ Add Your Thrift',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Item Title
                _frostedInput(_titleCtrl, 'Item Title', Icons.label_outline),
                const SizedBox(height: 16),

                // Description
                _frostedInput(
                    _descCtrl, 'Description', Icons.description_outlined,
                    maxLines: 3),
                const SizedBox(height: 16),

                // Price
                _frostedInput(_priceCtrl, 'Price (Php)', Icons.attach_money,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),

                // Display Name
                _frostedInput(
                    _nameCtrl, 'Your Display Name', Icons.person_outline),
                const SizedBox(height: 16),

                // Contact Email
                _frostedInput(
                    _contactCtrl, 'Contact Email', Icons.contact_mail_outlined),
                const SizedBox(height: 24),

                // Image Picker
                _image == null
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined, size: 22),
                  label: Text(
                    'Choose Photo',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: const Color(0xFF4895EF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: pickImage,
                )
                    : Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!,
                          height: 180, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _image = null),
                      child: Text(
                        'Re-pick Image',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Upload Button
                ElevatedButton(
                  onPressed: canUpload ? _handleUpload : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: const Color(0xFF4895EF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _uploading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(
                    'Upload Item',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: frosted input field
  Widget _frostedInput(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: label,
          hintStyle:
          GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
