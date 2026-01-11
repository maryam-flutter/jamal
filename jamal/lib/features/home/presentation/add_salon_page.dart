import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_localizations.dart';

class AddSalonPage extends StatefulWidget {
  const AddSalonPage({Key? key}) : super(key: key);

  @override
  State<AddSalonPage> createState() => _AddSalonPageState();
}

class _AddSalonPageState extends State<AddSalonPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for salon details
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  File? _salonImage;

  // List of services
  final List<Map<String, String>> _services = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _salonImage = File(image.path);
      });
    }
  }

  // Add service (via Bottom Sheet)
  void _showAddServiceBottomSheet() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final t = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(t.translate('add_service'), style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _buildTextField(nameCtrl, t.translate('service_name'), Icons.spa),
              const SizedBox(height: 12),
              _buildTextField(descCtrl, t.translate('description'), Icons.description),
              const SizedBox(height: 12),
              _buildTextField(priceCtrl, t.translate('price_in_uzs'), Icons.attach_money, isNumber: true),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                      setState(() {
                        _services.add({
                          'name': nameCtrl.text,
                          'description': descCtrl.text,
                          'price': priceCtrl.text,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F91),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(t.translate('add'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
        ),
      ),
    );
  }

  // Function to submit to backend
  Future<void> _submitSalon() async {
    final t = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('add_at_least_one_service'), style: const TextStyle(color: Color(0xFFFF6F91))),
          backgroundColor: Colors.grey[800],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Data object to be prepared
      final salonData = {
        'name': _nameCtrl.text,
        'description': _descCtrl.text,
        'image': _salonImage?.path, // File path
        'services': _services,
      };

      // Send request to backend (Simulation)
      // In a real project, the following code is used:
      // final response = await http.post(
      //   Uri.parse('https://sizning-backend-api.com/salons'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(salonData),
      // );

      // Wait for 2 seconds for now (for loading effect)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('salon_added_successfully'), style: const TextStyle(color: Color(0xFFFF6F91))),
            backgroundColor: Colors.grey[800],
          ),
        );
        Navigator.pop(context); // Go back
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.translate('error_occurred')}: $e', style: const TextStyle(color: Color(0xFFFF6F91))),
            backgroundColor: Colors.grey[800],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Exit confirmation dialog
  Future<void> _handleExit() async {
    final t = AppLocalizations.of(context)!;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 254, 254),
        surfaceTintColor: const Color.fromARGB(255, 255, 253, 253), // To keep white color in Material 3
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          t.translate('exit'),
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          t.translate('exit_confirm'),
          style: GoogleFonts.plusJakartaSans(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              t.translate('cancel'),
              style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              t.translate('exit'),
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFFFF6F91), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: _handleExit,
        ),
        title: Text(
          t.translate('add_salon'),
          style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.translate('salon_info'),
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _buildTextField(_nameCtrl, t.translate('salon_name'), Icons.store),
              const SizedBox(height: 12),
              _buildTextField(_descCtrl, t.translate('description_short'), Icons.description, maxLines: 3),
              const SizedBox(height: 12),
              
              // Image upload section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    image: _salonImage != null
                        ? DecorationImage(image: FileImage(_salonImage!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _salonImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(t.translate('upload_salon_photo'), style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
                          ],
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${t.translate('services')} (${_services.length})',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: _showAddServiceBottomSheet,
                    icon: const Icon(Icons.add, color: primaryPink),
                    label: Text(
                      t.translate('add'),
                      style: GoogleFonts.plusJakartaSans(color: primaryPink, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              if (_services.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    t.translate('no_services_yet'),
                    style: GoogleFonts.plusJakartaSans(color: Colors.grey[400]),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.spa, color: primaryPink),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name']!,
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                Text(
                                  '${service['price']} ${t.translate('currency_uzs')}',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _services.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitSalon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          t.translate('save_and_submit'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    final t = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return t.translate('field_is_required');
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF6F91)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}