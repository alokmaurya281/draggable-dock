import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});

  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  int? _hoveredIndex;
  IconData? draggingItem;
  double dragOffsetX = 0;
  double dragOffsetY = 0;
  bool isHorizontalDrag = false;
  double placeholderOffsetX = 0;

  void moveItemToPlaceholder(int direction) {
    // setState(() {
    //   if (draggingItem != null) {
    //     final oldIndex = _items.indexOf(draggingItem!);
    //     final newIndex = (oldIndex + direction).clamp(0, _items.length - 1);

    //     if (oldIndex != newIndex) {
    //       _items.removeAt(oldIndex);
    //       _items.insert(newIndex, draggingItem!);
    //     }
    //   }
    // });
  }

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _hoveredIndex == null ? 1.0 : 1.05,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _items.length,
            (index) {
              final item = _items[index];
              return _buildDockItem(item, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem(IconData item, int index) {
    final isHovered = _hoveredIndex == index;

    return Draggable<IconData>(
      data: item,
      feedback: _buildDockIcon(item, isHovered: true),
      childWhenDragging: Transform.translate(
        offset: Offset(placeholderOffsetX, 0),
        child: _buildPlaceholder(isInvisible: !isHorizontalDrag),
      ),
      onDragStarted: () {
        setState(() {
          draggingItem = item;
          placeholderOffsetX = 0;
        });
      },
      onDragUpdate: (details) {
        setState(() {
          dragOffsetX += details.delta.dx;
          dragOffsetY += details.delta.dy;

          isHorizontalDrag = dragOffsetY > -48.0;

          if (isHorizontalDrag) {
            placeholderOffsetX += details.delta.dx;
            // if (placeholderOffsetX > 50) {
            //   moveItemToPlaceholder(1);
            //   placeholderOffsetX = 0;
            // } else if (placeholderOffsetX < -50) {
            //   moveItemToPlaceholder(-1);
            //   placeholderOffsetX = 0;
            // }
          }
        });
      },
      onDragEnd: (_) {
        setState(() {
          draggingItem = null;
          placeholderOffsetX = 0;
        });
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          draggingItem = null;
          placeholderOffsetX = 0;
        });
      },
      child: DragTarget<IconData>(
        onAccept: (receivedItem) {
          setState(() {
            final oldIndex = _items.indexOf(receivedItem);
            _items.removeAt(oldIndex);
            _items.insert(index, receivedItem);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: AnimatedScale(
              scale: _getScaleFactor(index),
              duration: const Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(
                  0.0,
                  _getHoverTranslationY(index),
                  0.0,
                ),
                child: _buildDockIcon(item, isHovered: isHovered),
              ),
            ),
          );
        },
      ),
    );
  }

  double _getScaleFactor(int index) {
    if (_hoveredIndex == null) return 1.0;

    final distance = (index - _hoveredIndex!).abs();

    double scaleFactor = 1.0;

    if (distance == 0) {
      scaleFactor = 1.15;
    } else if (distance == 1) {
      scaleFactor = 1.1;
    } else if (distance == 2) {
      scaleFactor = 1.05;
    } else {
      scaleFactor = 1.0;
    }

    return scaleFactor;
  }

  double _getHoverTranslationY(int index) {
    if (_hoveredIndex == null) return 0.0;

    final difference = (index - _hoveredIndex!).abs();
    double translationY = 0.0;

    if (difference == 0) {
      translationY = -10.0;
    } else if (difference == 1) {
      translationY = -5.0;
    }

    return translationY;
  }

  Widget _buildDockIcon(IconData icon, {bool isHovered = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      decoration: BoxDecoration(
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedScale(
        scale: isHovered ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Icon(
          icon,
          color: Colors.white,
          size: isHovered ? 28 : 24,
        ),
      ),
    );
  }

  Widget _buildPlaceholder({bool isInvisible = false}) {
    return isInvisible
        ? const SizedBox.shrink()
        : AnimatedContainer(
          width: 48,
            transform: Matrix4.translationValues(placeholderOffsetX, 0, 0),
          duration: const Duration(milliseconds: 300), 
          child: const Icon(Icons.add, color: Colors.transparent,)
          );
  }
}
