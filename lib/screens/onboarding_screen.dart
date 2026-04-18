import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ENTER YOUR NAME',
            style: TextStyle(fontFamily: 'BebasNeue', letterSpacing: 2),
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameCtrl.text.trim());
    await prefs.setBool('onboarded', true);

    ref.read(currentUserProvider.notifier).state = AppUser(
      id: 'local_user',
      name: _nameCtrl.text.trim(),
      email: '',
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo / title block
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.yellow,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'XPNS',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 80,
                          color: AppColors.black,
                          height: 1,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'TRACKER',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: 32,
                          color: AppColors.black,
                          height: 1,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  '"WHERE DID MY MONEY GO?"',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 22,
                    color: Colors.white,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Track every rupee. Brutally honestly.',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 11,
                    color: Colors.white54,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 40),

                // Name input
                const Text(
                  'YOUR NAME',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 14,
                    letterSpacing: 2,
                    color: AppColors.yellow,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: _nameCtrl,
                  autofocus: false,
                  style: const TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  cursorColor: AppColors.yellow,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Arjun',
                    hintStyle: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 13,
                      color: Colors.white38,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide:
                          BorderSide(color: Colors.white38, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide:
                          BorderSide(color: AppColors.yellow, width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),

                const SizedBox(height: 14),

                // Start button
                GestureDetector(
                  onTap: _loading ? null : _start,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.yellow,
                          offset: Offset(5, 5),
                          blurRadius: 0,
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'START TRACKING ★',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: 22,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    'NO SIGN UP · NO CLOUD · 100% LOCAL',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 9,
                      color: Colors.white30,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
