import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';

class FavoriteButton extends StatefulWidget {
  final String mealId;
  final double size;
  final int favoritesCount;

  const FavoriteButton({
    super.key,
    required this.mealId,
    this.size = 34,
    this.favoritesCount = 0,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.favoritesCount;
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoritesCount != widget.favoritesCount) {
      _count = widget.favoritesCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoriteProvider>();
    final isFavorite = provider.isFavorite(widget.mealId);
    final toggling = provider.isToggling(widget.mealId);

    return SizedBox(
      width: widget.size + 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: toggling
                ? null
                : () async {
                    final wasFav = isFavorite;
                    try {
                      await provider.toggle(widget.mealId);
                      if (mounted) {
                        setState(() {
                          _count += wasFav ? -1 : 1;
                        });
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: toggling ? widget.size : widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: toggling
                    ? Colors.white
                    : isFavorite
                        ? const Color(0xFF22C55E)
                        : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: toggling
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: widget.size * 0.55,
                      color:
                          isFavorite ? Colors.white : const Color(0xFF006E2F),
                    ),
            ),
          ),
          if (_count > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _count > 999 ? '${(_count / 1000).toStringAsFixed(1)}k' : '$_count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
