import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import 'search_suggestions.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = value;
        _showSuggestions = value.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          Container(
            height: AppDimensions.searchBarHeight,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              onTap: () {
                setState(() => _showSuggestions = _controller.text.isNotEmpty);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search meals, ingredients or grocery items...',
                hintStyle: const TextStyle(color: AppColors.outlineVariant, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                suffixIcon: GestureDetector(
                  onTap: () {
                    _focusNode.unfocus();
                    setState(() => _showSuggestions = false);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.primary, size: 22),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          if (_showSuggestions)
            SearchSuggestions(
              query: _query,
              onSelect: () {
                _focusNode.unfocus();
                setState(() => _showSuggestions = false);
                _controller.clear();
              },
            ),
        ],
      ),
    );
  }
}
