import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_gorouter/extention/push.dart';
import 'package:supabase_gorouter/screen/home_page.dart';
import 'package:supabase_gorouter/screen/sign_up.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  static const rootName = '/';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  // Supabaseをインスタンス化する.
  final supabase = Supabase.instance.client;


late final StreamSubscription<AuthState> _authSubscription;
  //セッションを使うための変数.
  User? _user;
  //ログイン判定をする変数.
  bool _redirecting = false;

    // ログインした状態を維持するためのロジック．
  @override
  void initState() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      // ユーザーがログインしているかをifで判定する.
      if (_redirecting) return;
      if (session != null) {
        _redirecting = true;
        // ユーザーがログインしていたら、アプリのページへリダイレクトする.
        context.toAndRemoveUntil(const HomePage());
      }
      setState(() {
        _user = session?.user;
      });
    });
    super.initState();
  }


    @override
  void dispose() {
    _authSubscription.cancel();
    email.dispose();
    password.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In Page'),
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
                  if (password.text.length < 6 || !password.text.contains(RegExp(r'[a-zA-Z]'))) {
                    throw 'パスワードが正しくありません';
                  }

                  await supabase.auth.signInWithPassword(password: password.text, email: email.text);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(e.toString()),
                  ));
                }
              },
              child: const Text('Sign In'),
            ),
            TextButton(onPressed: () {
              context.to(const SignUpPage());
            }, child: const Text('Sign Up'))
          ],
        ),
      ),
    );
  }
}