import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.code == 'user-not-found'
            ? 'Usuario nao encontrado'
            : e.code == 'wrong-password'
            ? 'Senha incorreta'
            : 'Erro ao entrar: ${e.message}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loginGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _googleLoading = false;
        });
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _error = 'Erro Google: $e';
      });
    } finally {
      setState(() {
        _googleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Minhas\nFinancas',
                style: GoogleFonts.syne(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Controle financeiro pessoal',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _googleLoading ? null : _loginGoogle,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppTheme.bgCard,
                  ),
                  child: _googleLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CustomPaint(painter: _GoogleIconPainter()),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Entrar com Google',
                              style: GoogleFonts.dmSans(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'ou',
                      style: GoogleFonts.dmSans(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppTheme.border)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'E-mail',
                style: GoogleFonts.dmSans(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'seu@email.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Senha',
                style: GoogleFonts.dmSans(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: '........',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppTheme.red, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Entrar',
                          style: GoogleFonts.syne(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Banpara - Gabriel Salbe',
                  style: GoogleFonts.dmSans(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.57,
      3.14,
      true,
      paint,
    );
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.57,
      -3.14,
      true,
      paint,
    );
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.57,
      1.57,
      true,
      paint,
    );
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0,
      1.57,
      true,
      paint,
    );
    paint.color = AppTheme.bgCard;
    canvas.drawCircle(Offset(cx, cy), r * 0.6, paint);
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(cx, cy - r * 0.15, r, r * 0.3), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
