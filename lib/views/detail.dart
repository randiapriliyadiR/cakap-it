import 'package:flutter/material.dart';
import './../models/post_model.dart';
import './../views/widgets/input_widget.dart';
import 'package:get/get.dart';
import 'widgets/post_data.dart';
import './../controllers/post_controller.dart';
import './../controllers/auth_controller.dart';

class Detail extends StatefulWidget {
  const Detail({super.key, required this.post});

  final PostModel post;

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // inisialisasi controller
  final TextEditingController _commentController = TextEditingController();
  final PostController _postController = Get.put(PostController());
  final AuthController _AuthController = Get.put(AuthController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postController.getComments(widget.post.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.post.user!.name!),
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
                              await _AuthController.logout();
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
          child: Column(
            children: [
              PostData(
                post: widget.post,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 300,
                child: Obx(() {
                  return _postController.isLoading.value
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: _postController.comments.value.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                _postController
                                    .comments.value[index].user!.name!,
                              ),
                              subtitle: Text(
                                _postController.comments.value[index].body!,
                              ),
                            );
                          });
                }),
              ),
              InputWidget(
                obscureText: false,
                hintText: 'Tulis komentar...',
                controller: _commentController,
              ),
              Divider(color: Colors.transparent),
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
                  await _postController.createComment(
                    widget.post.id,
                    _commentController.text.trim(),
                  );
                  _commentController.clear();
                  _postController.getComments(widget.post.id);
                },
                child: const Text('Komentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
