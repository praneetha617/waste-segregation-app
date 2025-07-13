import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/my_video_widget.dart';
import 'food_waste_game_page.dart';

class EducationalVideoPage extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color binColor;
  final String videoAsset;

  const EducationalVideoPage({
    super.key,
    required this.categoryName,
    required this.icon,
    required this.binColor,
    required this.videoAsset,
  });

  @override
  Widget build(BuildContext context) {
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
                      Icon(icon, color: binColor, size: 60),
                      const SizedBox(height: 10),
                      Text(
                        categoryName,
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: binColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // === Actual Video Player Widget ===
                      MyVideoWidget(assetPath: videoAsset),
                      const SizedBox(height: 18),
                      Text(
                        "Watch this short video to learn about $categoryName!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 26),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Continue to Game", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: binColor.withOpacity(0.15),
                          foregroundColor: binColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          minimumSize: const Size(200, 48),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FoodWasteGamePage()),
                          ); // TODO: Navigate to game screen
                        },
                      ),
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
