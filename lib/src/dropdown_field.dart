import 'package:flutter/material.dart';

class FlutterEasySearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String hintText;
  final bool isClearable;
  final TextStyle? textStyle;
  final Widget? dropdownIcon;
  final Widget? clearIcon;

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
  State<FlutterEasySearchableDropdown<T>> createState() => _FlutterEasySearchableDropdownState<T>();
}

class _FlutterEasySearchableDropdownState<T> extends State<FlutterEasySearchableDropdown<T>> {
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

  void _openDropdown() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    final filteredItems = widget.items
        .where((item) =>
        widget.itemLabel(item).toLowerCase().contains(_searchQuery.toLowerCase()))
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
                icon: widget.dropdownIcon ?? const Icon(Icons.arrow_drop_down),
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
