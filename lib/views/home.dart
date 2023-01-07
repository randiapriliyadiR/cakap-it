import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/post_field.dart';
import 'widgets/post_data.dart';
import './../controllers/post_controller.dart';
import './../controllers/auth_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // inisialisasi controller
  final PostController _postController = Get.put(PostController());
  final TextEditingController _textController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cakap IT'),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text('Apa kamu yakin ingin keluar?'),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Icon(Icons.cancel),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          ElevatedButton(
                            child: Icon(Icons.check_circle),
                            onPressed: () async {
                              await _authController.logout();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.logout)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: () async {
              await _postController.getAllPosts();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostField(
                  hintText: 'Apa yang ingin kamu tanyakan?',
                  controller: _textController,
                ),
                // const SizedBox(
                //   height: ,
                // ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () async {
                    await _postController.createPost(
                      content: _textController.text.trim(),
                    );
                    _textController.clear();
                    _postController.getAllPosts();
                  },
                  child: Obx(() {
                    return _postController.isLoading.value
                        ? const CircularProgressIndicator()
                        : Text('Posting');
                  }),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text('Postingan'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(() {
                  return _postController.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _postController.posts.value.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: PostData(
                                post: _postController.posts.value[index],
                              ),
                            );
                          },
                        );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
