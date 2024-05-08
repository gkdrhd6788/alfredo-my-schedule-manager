import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../api/token_api.dart';
import 'loading_screen.dart';
import '../../components/navbar/tabview.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  User? _currentUser;
  bool _isLoading = false; // 로딩 상태 관리 변수

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/main');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/alfredoback1.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/alfredologo2.png',
                width: MediaQuery.of(context).size.width * 0.63,
              ),
            ),
          ),
          _isLoading
              ? const MyLoadingScreen()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(),
                      if (_currentUser == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 385.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _signInWithGoogle,
                              borderRadius: BorderRadius.circular(22),
                              splashColor: Colors.grey.withAlpha(30),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/android_light_rd_ctn@2x.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                width: 250,
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      AuthService authService = AuthService();
      UserCredential? userCredential = await authService.signInWithGoogle();

      if (userCredential != null) {
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser) {
          Navigator.pushReplacementNamed(context, '/user_routine_test');
        } else {
          Navigator.pushReplacementNamed(
              context, '/main'); // '/main'은 이제 TabView
        }
      } else {
        print("Login failed.");
      }
    } catch (e) {
      print("Login error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    print("Logged out");
  }
}
