import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_gorouter/extention/push.dart';
import 'package:supabase_gorouter/screen/photo_page.dart';
import 'package:supabase_gorouter/screen/sign_in_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const rootName = '/home_page';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool isUploading = false;
  final supabase = Supabase.instance.client;

  Future<void> uploadFile() async {
    var pickedFile = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (pickedFile != null) {
      setState(() {
        isUploading = true;
      });
      try {
        File file = File(pickedFile.files.single.path!);
        String fileName = pickedFile.files.first.name;
        String uploadUrl = await supabase.storage
            .from('profiles')
            .upload("${supabase.auth.currentUser!.id}/$fileName", file);
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploaded $fileName'),
          ),
        );
      } catch (e) {
        print(e.toString());
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploaded Error'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: () async {
            await supabase.auth.signOut();
            if (context.mounted) {
              await context.toAndRemoveUntil(const SignInPage());
            }
          },
          icon: const Icon(Icons.logout),
        ),
        const SizedBox(width: 10),
        IconButton(
            onPressed: () {
              context.to(const PhotoPage());
            },
            icon: const Icon(Icons.photo)),
      ], title: const Text('Home Page')),
      body: Center(
        child: Column(
          children: [
            IconButton(
                onPressed: () async {
                  await uploadFile();
                },
                icon: const Icon(Icons.upload))
          ],
        ),
      ),
    );
  }
}
