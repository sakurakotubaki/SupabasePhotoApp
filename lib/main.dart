import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_gorouter/screen/sign_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // URLとanon keyの設定をする
  await Supabase.initialize(
    url: '自分のプロジェクトのURL',
    anonKey:
    'アノンキーを貼り付ける',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignInPage(),
    );
  }
}