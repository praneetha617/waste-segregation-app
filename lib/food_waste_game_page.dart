import 'package:flutter/material.dart';

// MODEL: A single food waste item (clean or messy)
class FoodWasteItem {
  final String name;
  final String image;
  final String type; // 'clean' or 'messy'

  FoodWasteItem({required this.name, required this.image, required this.type});
}

// Your list of food waste items
final List<FoodWasteItem> foodWasteItems = [
  // Clean
  FoodWasteItem(name: 'Banana Peel', image: 'assets/images/banana_peel.png', type: 'clean'),
  FoodWasteItem(name: 'Eggshell', image: 'assets/images/eggshell.png', type: 'clean'),
  FoodWasteItem(name: 'Apple Core', image: 'assets/images/apple_core.png', type: 'clean'),
  FoodWasteItem(name: 'Coffee Grounds', image: 'assets/images/coffee_grounds.png', type: 'clean'),
  // Messy
  FoodWasteItem(name: 'Moldy Bread', image: 'assets/images/moldy_bread.png', type: 'messy'),
  FoodWasteItem(name: 'Leftover Pasta', image: 'assets/images/leftover_pasta.png', type: 'messy'),
  FoodWasteItem(name: 'Rotten Tomato', image: 'assets/images/rotten_tomato.png', type: 'messy'),
  FoodWasteItem(name: 'Sour Milk', image: 'assets/images/sour_milk.png', type: 'messy'),
];

// The game page widget
class FoodWasteGamePage extends StatefulWidget {
  const FoodWasteGamePage({super.key});

  @override
  State<FoodWasteGamePage> createState() => _FoodWasteGamePageState();
}

class _FoodWasteGamePageState extends State<FoodWasteGamePage> {
  final List<FoodWasteItem> items = [...foodWasteItems];
  int currentIndex = 0;
  String feedback = '';

  void handleDrop(String droppedType) {
    if (items[currentIndex].type == droppedType) {
      setState(() {
        feedback = 'Good!';
        currentIndex++;
      });
    } else {
      setState(() {
        feedback = 'Try smart.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // When all items are sorted, show level complete
    if (currentIndex >= items.length) {
      return Scaffold(
        body: Center(
          child: Text(
            'Level Complete!\nGreat Job!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
      );
    }

    final item = items[currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text("Food Waste Sorting")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (feedback.isNotEmpty)
            Text(
              feedback,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: feedback == 'Good!' ? Colors.green : Colors.red,
              ),
            ),
          const SizedBox(height: 20),

          // DRAGGABLE WASTE ITEM
          Draggable<FoodWasteItem>(
            data: item,
            feedback: Image.asset(item.image, height: 90, width: 90),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: Image.asset(item.image, height: 90, width: 90),
            ),
            child: Column(
              children: [
                Image.asset(item.image, height: 90, width: 90),
                const SizedBox(height: 8),
                Text(item.name, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // TWO BINS (CLEAN & MESSY)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FoodBinWidget(
                label: 'Clean Food Waste',
                color: Colors.green,
                icon: Icons.eco,
                type: 'clean',
                onAccept: handleDrop,
              ),
              _FoodBinWidget(
                label: 'Messy Food Waste',
                color: Colors.black,
                icon: Icons.delete,
                type: 'messy',
                onAccept: handleDrop,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// BIN WIDGET
class _FoodBinWidget extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final String type;
  final Function(String) onAccept;

  const _FoodBinWidget({
    required this.label,
    required this.color,
    required this.icon,
    required this.type,
    required this.onAccept,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<FoodWasteItem>(
      onWillAccept: (data) => true,
      onAccept: (data) => onAccept(type),
      builder: (context, candidateData, rejectedData) => Column(
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border.all(color: color, width: 4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 48),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
