import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/controllers/user_controller.dart';

class MySearchBar extends StatefulWidget {
  final Function(List<FileModel>, String)? onSearchResults; // Add callback

  const MySearchBar({super.key, this.onSearchResults});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  final UserController _userController = UserController();

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        // Pass empty results and query to reset the UI
        if (widget.onSearchResults != null) {
          widget.onSearchResults!([], query);
        }
        print('Empty search query');
      }
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      print('Performing search for: $query');
      final results = await _userController.searchFiles(context, query);
      print('Search results: ${results.length} items found');
      
      // Pass the results and query to the parent widget
      if (widget.onSearchResults != null) {
        widget.onSearchResults!(results, query);
      }
      
      for (var file in results) {
        print('Found file: ${file.fileName}');
      }
      
    } catch (e) {
      print('Error during search: $e');
      // Pass empty results on error
      if (widget.onSearchResults != null) {
        widget.onSearchResults!([], query);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.15,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        cursorHeight: 16,
        cursorColor: Colors.black,
        cursorWidth: 1,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: Colors.grey.withOpacity(0.6),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 5,
          ),
        ),
      ),
    );
  }
}