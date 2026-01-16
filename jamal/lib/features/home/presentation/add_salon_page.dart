import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_localizations.dart';
import '../../../core/app_snackbar.dart';
import '../data/salon_repository.dart';
import '../data/salon_store.dart';

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
  final List<Map<String, String>> _masters = [];

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
    final colorScheme = Theme.of(context).colorScheme;
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
                  decoration: BoxDecoration(color: colorScheme.outline.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                t.translate('add_service'),
                style: AppFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
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
                child: InkWell(
                  onTap: () {
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
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6F91), Color(0xFFFF8FA6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        t.translate('add'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
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
      AppSnackBar.show(context, t.translate('add_at_least_one_service'));
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

      if (mounted) {
        final imagePath = _salonImage?.path ?? '';
        final imageUrl = imagePath.startsWith('http://') || imagePath.startsWith('https://') ? imagePath : null;
        Salon? remoteSalon;
        try {
          remoteSalon = await SalonStore().createRemoteSalon(
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            imageUrl: imageUrl,
          );
        } catch (e) {
          AppSnackBar.show(context, '${t.translate('error_occurred')}: $e', style: AppSnackBarStyle.error);
        }

        final salonId = remoteSalon?.id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}';
        final salon = remoteSalon ??
            Salon(
              id: salonId,
              name: _nameCtrl.text.trim(),
              address: _descCtrl.text.trim(),
              rating: 0.0,
              image: _salonImage?.path ?? 'assets/salon.png',
            );
        final customServices = _services.asMap().entries.map((entry) {
          final index = entry.key;
          final service = entry.value;
          final name = service['name']?.trim() ?? '';
          final description = service['description']?.trim() ?? '';
          final price = service['price']?.trim() ?? '';
          return SalonService(
            id: '${salonId}_service_$index',
            salonId: salonId,
            titleKey: name,
            durationKey: description,
            priceKey: price.isNotEmpty ? '$price ${t.translate('currency_uzs')}' : '',
            categoryKey: 'category_hair',
          );
        }).toList();
        final customMasters = _masters.asMap().entries.map((entry) {
          final index = entry.key;
          final master = entry.value;
          final name = master['name']?.trim() ?? '';
          final image = master['image']?.trim() ?? 'assets/images/profile.png';
          return SalonMaster(
            id: '${salonId}_master_$index',
            salonId: salonId,
            name: name.isEmpty ? t.translate('salon_master_label') : name,
            image: image,
          );
        }).toList();
        if (remoteSalon == null) {
          await SalonStore().addSalon(
            salon,
            salonServices: customServices,
            salonMasters: customMasters,
          );
        } else {
          for (final service in _services) {
            final serviceName = service['name']?.trim() ?? '';
            final serviceDescription = service['description']?.trim() ?? '';
            final servicePrice = service['price']?.trim() ?? '';
            if (serviceName.isEmpty) continue;
            try {
              await SalonStore().createRemoteService(
                salonId: salonId,
                name: serviceName,
                description: serviceDescription,
                price: servicePrice,
              );
            } catch (_) {
              // Best-effort remote sync; local save already handled.
            }
          }
          for (final master in customMasters) {
            final photo = master.image.startsWith('http://') || master.image.startsWith('https://') ? master.image : '';
            try {
              await SalonStore().createRemoteMaster(
                salonId: salonId,
                fullName: master.name,
                photoUrl: photo,
              );
            } catch (_) {
              // Best-effort remote sync; local save already handled.
            }
          }
          await SalonStore().addSalonExtras(
            salonMasters: customMasters,
            salonServices: customServices,
          );
        }
        AppSnackBar.show(context, t.translate('salon_added_successfully'), style: AppSnackBarStyle.success);
        Navigator.pop(context); // Go back
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, '${t.translate('error_occurred')}: $e', style: AppSnackBarStyle.error);
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
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF6F8), Color(0xFFFFE3EA), Color(0xFFFFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.translate('exit'),
                      style: AppFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.translate('exit_confirm'),
                      style: AppFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: Colors.white.withOpacity(0.6),
                            ),
                            child: Text(
                              t.translate('cancel'),
                              style: AppFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F91),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: Text(
                              t.translate('exit'),
                              style: AppFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFFF6F91);
    final t = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: _handleExit,
        ),
        title: Text(
          t.translate('add_salon'),
          style: AppFonts.plusJakartaSans(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
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
                style: AppFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
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
                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                    image: _salonImage != null
                        ? DecorationImage(image: FileImage(_salonImage!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _salonImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded, size: 40, color: colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(height: 8),
                            Text(
                              t.translate('upload_salon_photo'),
                              style: AppFonts.plusJakartaSans(color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
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
                    style: AppFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  _buildGradientAddButton(
                    label: t.translate('add'),
                    onTap: _showAddServiceBottomSheet,
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
                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  ),
                  child: Text(
                    t.translate('no_services_yet'),
                    style: AppFonts.plusJakartaSans(color: colorScheme.onSurface.withOpacity(0.5)),
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
                              color: colorScheme.surfaceVariant.withOpacity(0.4),
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
                                  style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: colorScheme.onSurface),
                                ),
                                Text(
                                  '${service['price']} ${t.translate('currency_uzs')}',
                                  style: AppFonts.plusJakartaSans(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
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

              const SizedBox(height: 32),

              Text(
                t.translate('salon_masters_title'),
                style: AppFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${t.translate('salon_masters_title')} (${_masters.length})',
                    style: AppFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  _buildGradientAddButton(
                    label: t.translate('add'),
                    onTap: _showAddMasterBottomSheet,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_masters.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  ),
                  child: Text(
                    t.translate('no_services_yet'),
                    style: AppFonts.plusJakartaSans(color: Colors.black54),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _masters.length,
                  itemBuilder: (context, index) {
                    final master = _masters[index];
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
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _masterImageProvider(master['image'] ?? ''),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              master['name'] ?? '',
                              style: AppFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _masters.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: InkWell(
                  onTap: _isLoading ? null : _submitSalon,
                  borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              t.translate('save_and_submit'),
                              style: AppFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return t.translate('field_is_required');
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.plusJakartaSans(color: Colors.black54),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6F91)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6F91), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.4), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildGradientAddButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6F91), Color(0xFFFF8FA6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMasterBottomSheet() {
    final nameCtrl = TextEditingController();
    File? masterImage;
    final t = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
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
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.translate('salon_masters_title'),
                    style: AppFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(nameCtrl, t.translate('salon_master_label'), Icons.person),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setSheetState(() {
                          masterImage = File(image.path);
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.4)),
                        image: masterImage != null
                            ? DecorationImage(image: FileImage(masterImage!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: masterImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate_rounded, size: 36, color: Colors.black54),
                                const SizedBox(height: 8),
                                Text(
                                  t.translate('upload_salon_photo'),
                                  style: AppFonts.plusJakartaSans(color: Colors.black54),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        setState(() {
                          _masters.add({
                            'name': nameCtrl.text.trim(),
                            'image': masterImage?.path ?? 'assets/images/profile.png',
                          });
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6F91), Color(0xFFFF8FA6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            t.translate('add'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

ImageProvider _masterImageProvider(String path) {
  if (path.isEmpty) {
    return const AssetImage('assets/images/profile.png');
  }
  if (path.startsWith('assets/')) {
    return AssetImage(path);
  }
  final file = File(path);
  if (file.existsSync()) {
    return FileImage(file);
  }
  return const AssetImage('assets/images/profile.png');
}

