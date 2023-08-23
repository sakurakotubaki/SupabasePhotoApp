import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoPage extends ConsumerStatefulWidget {
  const PhotoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PhotoPageState();
}

class _PhotoPageState extends ConsumerState<PhotoPage> {
  bool isUploading = false;
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getImage() async {
    final List<FileObject> result = await supabase.storage
        .from('profiles')
        .list(path: supabase.auth.currentUser!.id);
    List<Map<String, String>> myImages = [];

    for (var image in result) {
      final getUrl = await supabase.storage
          .from('profiles')
          .getPublicUrl("${supabase.auth.currentUser!.id}/${image.name}");
      myImages.add({"name": image.name, "url": getUrl});
    }
    print(myImages);
    return myImages;
  }

  Future<void> deleteImage(String imageName) async {
    try {
      await supabase.storage
          .from('profiles')
          .remove([supabase.auth.currentUser!.id + '/' + imageName]);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("削除")));
    }
  }

  @override
  void initState() {
    getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhotoPage'),
      ),
      body: FutureBuilder(
          future: getImage(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return const Center(
                  child: Text('画像がありません'),
                );
              }
              return ListView.separated(
                itemCount: snapshot.data.length,
                padding: const EdgeInsets.symmetric(vertical: 10),
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    thickness: 2,
                    color: Colors.black,
                  );
                },
                itemBuilder: (context, index) {
                  Map<String, dynamic> image = snapshot.data[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 200,
                          width: 300,
                          child: Image.network(
                            image['url'],
                            fit: BoxFit.cover,
                          )),
                      IconButton(
                          onPressed: () async {
                            await deleteImage(image['name']);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red)),
                    ],
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
