import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_demo/models/book_model.dart';
import 'package:test_demo/providers/detail_provider.dart';
import 'package:test_demo/providers/home_provider.dart';
import 'package:test_demo/screens/home_screen.dart';
import 'package:test_demo/utils/strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({this.bookId});

  final String? bookId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(AppStrings.bookDetail),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            if (_isBookListNotEmpty(context)) {
              Navigator.pop(context);
            } else {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            }
          },
        ),
      ),
      bottomNavigationBar: _bottomNavWidget(),
      body: FutureBuilder<BookModel?>(
        future: DetailProvider().getBookDetail(bookId),
        builder: (context, apiResponse) {
          final bookModel = apiResponse.data;
          DetailProvider.bookUrl = bookModel?.bookUrl;

          if (apiResponse.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (apiResponse.connectionState == ConnectionState.done &&
              bookModel == null) {
            return Center(
              child: Text(
                AppStrings.dataNotFound,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    decoration: TextDecoration.none),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Text(
                    "${bookModel?.title}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Image.network(bookModel?.thumbnail ?? "")),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Text(
                    bookModel?.subtitle ?? "NA",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Html(
                    data: bookModel?.description ?? "NA",
                    defaultTextStyle:
                        TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isBookListNotEmpty(BuildContext context) {
    return Provider.of<HomeProvider>(context, listen: false).books.isNotEmpty;
  }

  Widget _bottomNavWidget() {
    final widget = Container(
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          AppStrings.viewFullDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
    return InkWell(
      child: widget,
      onTap: () async {
        final _url = DetailProvider.bookUrl;
        if (_url != null) {
          if (!await launch(_url)) throw 'Could not launch $_url';
        }
      },
    );
  }
}
