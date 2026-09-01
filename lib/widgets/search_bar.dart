import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rounded, light search bar used across screens.
///
/// Supports live [controller]/[onChanged] editing with a clear button,
/// or tap-only behavior when no controller is provided.
class GigSearchBar extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final Widget? trailing;
  final bool autofocus;

  const GigSearchBar({
    super.key,
    this.hint = 'Search workers, skills or services',
    this.controller,
    this.onChanged,
    this.onTap,
    this.onClear,
    this.trailing,
    this.autofocus = false,
  });

  @override
  State<GigSearchBar> createState() => _GigSearchBarState();
}

class _GigSearchBarState extends State<GigSearchBar> {
  bool _focused = false;
  late bool _hasText;

  @override
  void initState() {
    super.initState();
    _hasText = (widget.controller?.text ?? '').isNotEmpty;
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(GigSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    final hasText = (widget.controller?.text ?? '').isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    if (widget.controller != null) {
      widget.controller!.clear();
      widget.onChanged?.call('');
    }
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasEditing = widget.controller != null;
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _focused ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _focused ? AppColors.primary : AppColors.divider,
              width: _focused ? 1.5 : 1,
            ),
            boxShadow: _focused
                ? AppShadows.elevatedList
                : const [BoxShadow(color: Colors.transparent)],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: hasEditing
                    ? TextField(
                        controller: widget.controller,
                        onChanged: widget.onChanged,
                        autofocus: widget.autofocus,
                        decoration: InputDecoration(
                          hintText: widget.hint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                        ),
                      )
                    : Text(
                        widget.hint,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                        ),
                      ),
              ),
              if (hasEditing && _hasText)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  color: AppColors.textMuted,
                  tooltip: 'Clear',
                  onPressed: _clear,
                ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
