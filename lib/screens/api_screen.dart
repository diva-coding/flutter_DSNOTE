import 'package:flutter/material.dart';
import 'package:my_app/models/news.dart';
import 'package:my_app/services/data_service.dart';

class APIScreen extends StatefulWidget {
  const APIScreen({Key? key}) : super(key: key);

  @override
  _APIScreenState createState() => _APIScreenState();
}

class _APIScreenState extends State<APIScreen> {
  Future<List<News>>? _news;

  @override
  void initState() {
    super.initState();
    _news = DataService.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetch Data News'),
      ),
      body: Center(
        child: FutureBuilder<List<News>>(
          future: _news,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final post = snapshot.data![index];
                  return ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.body),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // Show a loading indicator while waiting for data
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}