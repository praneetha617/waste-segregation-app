import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// You can replace this with your real video screen import later!
// import 'video_page.dart';

class WasteCategorySelectionPage extends StatelessWidget {
  const WasteCategorySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      WasteCategory(
        name: 'Wet Waste',
        color: Colors.black,
        icon: Icons.opacity, // Use a custom bin image if you have one!
        binColor: Colors.black,
      ),
      WasteCategory(
        name: 'Dry Waste',
        color: Colors.blue[700]!,
        icon: Icons.inbox,
        binColor: Colors.blue[700]!,
      ),
      WasteCategory(
        name: 'Food Waste',
        color: Colors.green[700]!,
        icon: Icons.restaurant,
        binColor: Colors.green[700]!,
      ),
      WasteCategory(
        name: 'Hazardous Waste',
        color: Colors.red[700]!,
        icon: Icons.warning,
        binColor: Colors.red[700]!,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF58CFFB), Color(0xFF28E0AE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Select Waste Category',
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...categories.map((category) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: CategoryButton(category: category, onTap: () {
                          // TODO: Navigate to educational video page for this category
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPage(category: category)));
                        }),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WasteCategory {
  final String name;
  final Color color;
  final IconData icon;
  final Color binColor;
  WasteCategory({required this.name, required this.color, required this.icon, required this.binColor});
}

class CategoryButton extends StatelessWidget {
  final WasteCategory category;
  final VoidCallback onTap;
  const CategoryButton({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(category.icon, color: category.binColor, size: 32),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            category.name,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: category.binColor,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: category.color.withOpacity(0.08),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: BorderSide(
            color: category.binColor,
            width: 2,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
