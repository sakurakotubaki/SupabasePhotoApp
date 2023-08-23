import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  static const rootName = 'sign_up';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      // Scaffoldの背景色をグラーデーションにする.
      appBar: AppBar(
        title: const Text('Sign Up Page'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 50,
              child: TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  hintText: 'email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 50,
              child: TextFormField(
                controller: password,
                decoration: const InputDecoration(
                  hintText: 'password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  // メールアドレスが@と . が含まれているかチェック
                  if (!email.text.contains('@') || !email.text.contains('.')) {
                    throw 'メールアドレスが正しくありません';
                  }
                  // パスワードが6文字以上で、文字が含まれているかチェック
                  if (password.text.length < 6 ||
                      !password.text.contains(RegExp(r'[a-zA-Z]'))) {
                    throw 'パスワードが正しくありません';
                  }

                  await supabase.auth
                      .signUp(password: password.text, email: email.text);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(e.toString()),
                  ));
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
