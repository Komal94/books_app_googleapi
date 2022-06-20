import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_demo/models/book_model.dart';
import 'package:test_demo/providers/home_provider.dart';
import 'package:test_demo/screens/book_detail_screen.dart';
import 'package:test_demo/utils/strings.dart';
import 'package:test_demo/widgets/book_widget.dart';
import 'package:test_demo/widgets/bottom_sheet_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  HomeProvider? _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<HomeProvider>(context, listen: false);
    _provider?.getBooks();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getBooksApi();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, widget) => SafeArea(
        top: true,
        child: Scaffold(
          floatingActionButton: _floatingActionWidget(),
          body: Column(
            children: [
              _toolbar(),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      child: ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        itemCount: provider.books.length,
                        itemBuilder: (context, position) {
                          final book = provider.books[position];
                          return InkWell(
                            onTap: () {
                              _openBookDetail(book);
                            },
                            child: BookWidget(
                                book.title,
                                book.subtitle ?? book.description,
                                book.thumbnail),
                          );
                        },
                      ),
                    ),
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBookDetail(BookModel book) {
    print("book.id ${book.id}");
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BookDetailScreen(bookId: book.id)));
  }

  Widget _toolbar() {
    return Container(
      width: double.infinity,
      color: Colors.teal,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          AppStrings.bookLibrary,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  void _openSearchBottomSheet() {
    showModalBottomSheet(
        context: context,
        barrierColor: Colors.transparent,
        elevation: 10,
        isScrollControlled: true,
        builder: (ctx) {
          return FractionallySizedBox(
            heightFactor:
                MediaQuery.of(context).viewInsets.bottom == 0 ? 0.3 : 0.7,
            child: BottomSheetWidget(),
          );
        }).then((value) {
      if (value != null) {
        _provider?.query = value;
        _provider?.books.clear();
        _getBooksApi();
      }
    });
  }

  Widget _floatingActionWidget() {
    return Container(
      child: RawMaterialButton(
        shape: CircleBorder(),
        padding: EdgeInsets.all(8),
        elevation: 2,
        fillColor: Colors.teal,
        child: Icon(
          Icons.search_outlined,
          size: 28,
          color: Colors.white,
        ),
        onPressed: () {
          _openSearchBottomSheet();
        },
      ),
    );
  }

  void _getBooksApi() {
    _provider?.showLoading();
    _provider?.getBooks();
  }
}
