import 'package:flutter/material.dart';
import 'package:new_task_management/common/services/auth_service.dart';
import 'package:new_task_management/app/super/home_super.dart';
import 'package:new_task_management/app/manager/home_manager.dart';
import 'package:new_task_management/app/leader/home_leader.dart';
import 'package:new_task_management/app/employee/home_employee.dart';
import 'package:new_task_management/app/auth/register.dart';
import 'package:new_task_management/app/auth/widget/login_form.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;
  String errorMessage = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final userInfo = await AuthService().login(email, password);
      if (userInfo != null) {
        final role = userInfo['role'];
        final uid = userInfo['uid'];

        Future.delayed(Duration.zero, () {
          Widget nextPage;
          switch (role) {
            case 'superadmin':
              nextPage = HomeSuperAdmin();
              break;
            case 'manager':
              nextPage = HomeManager(uid: uid);
              break;
            case 'leader':
              nextPage = HomeLeader(uid: uid);
              break;
            case 'employee':
              nextPage = HomeEmployee(uid: uid);
              break;
            default:
              setState(() => errorMessage = 'Không xác định được vai trò người dùng.');
              return;
          }
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => nextPage,
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        });
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB3E5FC),
              Color(0xFFB2EBF2),
              Color(0xFFB2DFDB),
              Color(0xFFC8E6C9),
              Color(0xFFB2DFDB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: LoginForm(
                    emailController: emailController,
                    passwordController: passwordController,
                    obscurePassword: obscurePassword,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    onTogglePassword: () => setState(() {
                      obscurePassword = !obscurePassword;
                    }),
                    onSubmit: () => handleLogin(),
                    onRegister: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterPage()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
