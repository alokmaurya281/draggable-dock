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
  IconData? _draggingItem;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildDockItem(IconData item, int index) {
    final isHovered = _hoveredIndex == index;

    return Draggable<IconData>(
      data: item,
      feedback: _buildDockIcon(item, isHovered: true),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        setState(() {
          _draggingItem = item;
        });
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          _draggingItem = null;
        });
      },
      onDragEnd: (_) {
        setState(() {
          _draggingItem = null;
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
                child: _buildDockIcon(item, isHovered: false),
              ),
            ),
          );
        },
      ),
    );
  }

  // Determines the scale factor based on the hovered index
  double _getScaleFactor(int index) {
    if (_hoveredIndex == null) return 1.0;

    // Calculate the distance from the hovered index
    final distance = (index - _hoveredIndex!).abs();

    // Base scale factor for hovered item
    double scaleFactor = 1.0;

    // Apply scaling: closer items scale more, farther scale less
    if (distance == 0) {
      scaleFactor = 1.25; // Item directly under the cursor scales up most
    } else if (distance == 1) {
      scaleFactor = 1.15; // Next items scale a bit less
    } else if (distance == 2) {
      scaleFactor = 1.1; // Items two indices away scale even less
    } else {
      scaleFactor =
          1.0; // Items farthest from the hovered index stay at normal scale
    }

    return scaleFactor;
  }

  Widget _buildDockIcon(IconData icon, {bool isHovered = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      margin:
          EdgeInsets.symmetric(horizontal: _draggingItem == icon ? 16.0 : 8.0),
      decoration: BoxDecoration(
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: isHovered ? 30 : 24,
      ),
    );
  }
}
