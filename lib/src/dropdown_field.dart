import 'package:flutter/material.dart';

/// A customizable, lightweight, and easy-to-use **searchable dropdown widget**.
///
/// This widget provides:
/// - A text field with built-in search functionality
/// - A dropdown list that filters items as the user types
/// - Optional clear button to reset selection
/// - Fully customizable styles and icons
///
/// Example usage:
///
/// ```dart
/// FlutterEasySearchableDropdown<String>(
///   items: ["Apple", "Banana", "Mango", "Orange"],
///   itemLabel: (item) => item,
///   onChanged: (value) {
///     debugPrint("Selected: $value");
///   },
/// )
/// ```
class FlutterEasySearchableDropdown<T> extends StatefulWidget {
  /// List of items to display in the dropdown.
  final List<T> items;

  /// A function to extract the display label for each item.
  final String Function(T) itemLabel;

  /// Callback when the selected value changes.
  final ValueChanged<T?> onChanged;

  /// Hint text shown when nothing is selected.
  final String hintText;

  /// Whether the user can clear the selection.
  final bool isClearable;

  /// Style for the text inside the dropdown.
  final TextStyle? textStyle;

  /// Icon used to open/close the dropdown.
  final Widget? dropdownIcon;

  /// Icon used to clear the current selection.
  final Widget? clearIcon;

  /// Creates a [FlutterEasySearchableDropdown].
  const FlutterEasySearchableDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hintText = "Select an option",
    this.isClearable = true,
    this.textStyle,
    this.dropdownIcon,
    this.clearIcon,
  });

  @override
  State<FlutterEasySearchableDropdown<T>> createState() =>
      _FlutterEasySearchableDropdownState<T>();
}

class _FlutterEasySearchableDropdownState<T>
    extends State<FlutterEasySearchableDropdown<T>> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  T? _selectedItem;
  String _searchQuery = "";

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.dispose();
    super.dispose();
  }

  /// Opens the dropdown overlay.
  void _openDropdown() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Closes the dropdown overlay.
  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Builds the dropdown overlay with filtered items.
  OverlayEntry _createOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    final filteredItems = widget.items
        .where((item) => widget
        .itemLabel(item)
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(widget.itemLabel(item)),
                    onTap: () {
                      setState(() {
                        _selectedItem = item;
                        _controller.text = widget.itemLabel(item);
                      });
                      widget.onChanged(item);
                      _closeDropdown();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium,
        readOnly: false,
        decoration: InputDecoration(
          hintText: widget.hintText,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isClearable && _selectedItem != null)
                IconButton(
                  icon: widget.clearIcon ?? const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedItem = null;
                      _controller.clear();
                    });
                    widget.onChanged(null);
                  },
                ),
              IconButton(
                icon: widget.dropdownIcon ??
                    const Icon(Icons.arrow_drop_down),
                onPressed: () {
                  if (_overlayEntry == null) {
                    _openDropdown();
                  } else {
                    _closeDropdown();
                  }
                },
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _overlayEntry?.remove();
            _overlayEntry = _createOverlay();
            Overlay.of(context).insert(_overlayEntry!);
          });
        },
      ),
    );
  }
}
