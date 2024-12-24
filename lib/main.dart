import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, index, isDragging) {
              return AnimatedScale(
                scale: isDragging ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        Colors.primaries[e.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(e, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T item, int index, bool isDragging) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> with SingleTickerProviderStateMixin {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// Currently dragging index.
  int? _draggingIndex;

  /// Dragged offset.
  Offset? _dragOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_items.length, (index) {
              final isDragging = index == _draggingIndex;
              return GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _draggingIndex = index;
                    _dragOffset = details.globalPosition;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _dragOffset = details.globalPosition;
                    _rippleItems(index, details.delta.dx);
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _draggingIndex = null;
                    _dragOffset = null;
                  });
                },
                child: Transform.translate(
                  offset:
                      _draggingIndex == index ? Offset(0, -10) : Offset.zero,
                  child: widget.builder(_items[index], index, isDragging),
                ),
              );
            }),
          ),
          if (_draggingIndex != null && _dragOffset != null)
            Positioned(
              top: _dragOffset!.dy - 24,
              left: _dragOffset!.dx - 24,
              child: widget.builder(
                _items[_draggingIndex!],
                _draggingIndex!,
                true,
              ),
            ),
        ],
      ),
    );
  }

  void _rippleItems(int draggingIndex, double deltaX) {
    // Ripple logic: rearranges or shifts items based on drag direction.
    final threshold = 30.0;
    if (deltaX > threshold && draggingIndex < _items.length - 1) {
      setState(() {
        final temp = _items[draggingIndex];
        _items[draggingIndex] = _items[draggingIndex + 1];
        _items[draggingIndex + 1] = temp;
        _draggingIndex = draggingIndex + 1;
      });
    } else if (deltaX < -threshold && draggingIndex > 0) {
      setState(() {
        final temp = _items[draggingIndex];
        _items[draggingIndex] = _items[draggingIndex - 1];
        _items[draggingIndex - 1] = temp;
        _draggingIndex = draggingIndex - 1;
      });
    }
  }
}
