import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/app_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/user_session.dart';
import '../../../core/app_snackbar.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/usecases/register_usecase.dart';
import '../../../core/app_localizations.dart';
import 'registration_success_page.dart';

const Color _primaryPink = Color(0xFFFF6F91);

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  late final http.Client _client;
  late final RegisterUseCase _registerUseCase;

  // Focus nodes for input-aware header text
  late final FocusNode _nameFocus;
  late final FocusNode _phoneFocus;

  String? _headerMain;
  String? _welcomeHeader;
  String? _nameFocusHeader;
  String? _phoneFocusHeader;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = AppLocalizations.of(context);
    if (t != null) {
      _welcomeHeader = t.translate('welcome_header');
      _nameFocusHeader = t.translate('name_focus_header');
      _phoneFocusHeader = t.translate('phone_focus_header');
      if (_nameFocus.hasFocus) {
        _headerMain = _nameFocusHeader;
      } else if (_phoneFocus.hasFocus) {
        _headerMain = _phoneFocusHeader;
      } else {
        _headerMain = _welcomeHeader;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // network / usecase init
    _client = http.Client();
    final remote = AuthRemoteDataSourceImpl(client: _client);
    final repo = AuthRepositoryImpl(remote: remote);
    _registerUseCase = RegisterUseCase(repository: repo);

    // focus nodes init
    _nameFocus = FocusNode();
    _phoneFocus = FocusNode();

    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) {
        setState(() {
          _headerMain = _nameFocusHeader;
        });
      } else if (!_phoneFocus.hasFocus) {
        setState(() {
          _headerMain = _welcomeHeader;
        });
      }
    });

    _phoneFocus.addListener(() {
      if (_phoneFocus.hasFocus) {
        setState(() {
          _headerMain = _phoneFocusHeader;
        });
      } else if (!_nameFocus.hasFocus) {
        setState(() {
          _headerMain = _welcomeHeader;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _client.close();
    // animations removed
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final user = await _registerUseCase.execute(
        ismi: name,
        tel: phone,
        parol: _passCtrl.text,
      );

      await UserSession().saveUser(name, phone, id: user.id);

      if (!mounted) return;

      // Navigate to a small success page with indicator, then to HomePage
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RegistrationSuccessPage(userId: user.id)),
      );
    } catch (e) {
      if (!mounted) return;
      
      final t = AppLocalizations.of(context)!;
      String message = '${t.translate('generic_error')}: ${e.toString()}';
      // Agar internet yoki ruxsat yo'q bo'lsa, tushunarliroq xabar chiqaramiz
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        message = t.translate('network_error');
      }
      
      AppSnackBar.show(context, message, style: AppSnackBarStyle.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFFFF4F6),
              _primaryPink,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    t.translate('register'),
                    style: AppFonts.plusJakartaSans(
                      textStyle: const TextStyle(
                        fontSize: 22,
                        color: Color.fromARGB(255, 10, 10, 10),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // header as animated typewriter text (replaces logo card)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _TypewriterText(
                        text: _headerMain ?? '',
                        textStyle: AppFonts.plusJakartaSans(
                          textStyle: const TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.w900, height: 1.08, letterSpacing: 0.2),
                        ),
                        charDuration: const Duration(milliseconds: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.translate('create_profile_subheader'),
                        textAlign: TextAlign.center,
                        style: AppFonts.plusJakartaSans(
                          textStyle: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                // form fields on blurred backdrop
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                      // sharpened blur for a clearer frosted glass effect
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          // increase opacity slightly so inputs remain legible over stronger blur
                          color: Colors.white.withOpacity(0.26),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: Offset(0, 8))],
                        ),
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              focusNode: _nameFocus,
                              controller: _nameCtrl,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: t.translate('name'),
                                labelStyle: const TextStyle(color: Colors.black54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.95),
                                prefixIcon: const Icon(Icons.person_outline, color: _primaryPink),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? t.translate('name_validation') : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              focusNode: _phoneFocus,
                              controller: _phoneCtrl,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: t.translate('phone'),
                                labelStyle: const TextStyle(color: Colors.black54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.95),
                                prefixIcon: const Icon(Icons.phone, color: _primaryPink),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().isEmpty) ? t.translate('phone_validation') : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passCtrl,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: t.translate('password'),
                                labelStyle: const TextStyle(color: Colors.black54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.95),
                                prefixIcon: const Icon(Icons.lock_outline, color: _primaryPink),
                                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                              validator: (v) => (v == null || v.length < 6) ? t.translate('password_validation') : null,
                            ),
                            const SizedBox(height: 20),
                            // Register button (static)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: _AnimatedBlackRoundedButton(
                                isLoading: _loading,
                                onPressed: _loading ? null : _submit,
                                leading: const Icon(Icons.favorite, color: Color.fromARGB(255, 243, 158, 174), size: 20),
                                label: t.translate('register'),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

// Compact animated black button with slight press scale effect
class _AnimatedBlackRoundedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? leading;
  final String label;
  final Widget? trailing;
  final bool isLoading;

  const _AnimatedBlackRoundedButton({
    Key? key,
    required this.onPressed,
    this.leading,
    required this.label,
    this.trailing,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<_AnimatedBlackRoundedButton> createState() => _AnimatedBlackRoundedButtonState();
}

class _AnimatedBlackRoundedButtonState extends State<_AnimatedBlackRoundedButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.0, upperBound: 0.04);
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _pressCtrl.forward();
  void _onTapUp(_) => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapCancel: () => _pressCtrl.reverse(),
      onTapUp: (details) => _onTapUp(details),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: widget.isLoading
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 12),
                    ],
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 12),
                      widget.trailing!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

// Simple typewriter text widget that restarts when `text` changes.
class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration charDuration;

  const _TypewriterText({Key? key, required this.text, this.textStyle, this.charDuration = const Duration(milliseconds: 40)}) : super(key: key);

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _display = '';
  Timer? _timer;
  int _pos = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    _display = '';
    _pos = 0;
    if (widget.text.isEmpty) return;
    _timer = Timer.periodic(widget.charDuration, (t) {
      setState(() {
        _pos++;
        if (_pos <= widget.text.length) {
          _display = widget.text.substring(0, _pos);
        }
        if (_pos >= widget.text.length) {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_display, textAlign: TextAlign.center, style: widget.textStyle);
  }
}

// Registration success page moved to `registration_success_page.dart`.

