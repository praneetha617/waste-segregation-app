
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //  Required for orientation
import 'package:google_fonts/google_fonts.dart';
import 'widgets/my_video_widget.dart';
import 'sorting_game_page.dart';

// Replace with actual enum import if not already included
// import 'your_enum_file.dart';

class EducationalVideoPage extends StatefulWidget {
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
  State<EducationalVideoPage> createState() => _EducationalVideoPageState();
}

class _EducationalVideoPageState extends State<EducationalVideoPage> {
  bool _videoCompleted = false;

  // Force landscape on entry
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // Revert to portrait on exit
  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // Determine waste type based on category name
  WasteType get wasteType {
    if (widget.categoryName.toLowerCase().contains('wet') ||
        widget.categoryName.toLowerCase().contains('organic')) {
      return WasteType.organic;
    } else if (widget.categoryName.toLowerCase().contains('dry') ||
        widget.categoryName.toLowerCase().contains('recyclable')) {
      return WasteType.dry;
    } else {
      return WasteType.hazardous;
    }
  }

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
                      Icon(widget.icon, color: widget.binColor, size: 60),
                      const SizedBox(height: 10),
                      Text(
                        widget.categoryName,
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: widget.binColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Custom video widget
                      MyVideoWidget(
                        assetPath: widget.videoAsset,
                        onVideoCompleted: () {
                          setState(() {
                            _videoCompleted = true;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 18),
                      Text(
                        "Watch this short video to learn about ${widget.categoryName}!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 26),
                      
                      // Continue button logic
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          _videoCompleted
                              ? "Continue to Game"
                              : "Please watch the whole video",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _videoCompleted ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _videoCompleted
                              ? widget.binColor
                              : widget.binColor.withAlpha((0.15 * 255).toInt()),
                          foregroundColor: _videoCompleted ? Colors.white : Colors.grey[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          minimumSize: const Size(200, 48),
                          elevation: _videoCompleted ? 4 : 0,
                        ),
                        onPressed: _videoCompleted
                            ? () async {
                         // Reset to portrait BEFORE navigating
                                await SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitUp,
                             ]);

        //  Then navigate to the game
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SortingGamePage(selectedType: wasteType),
                         ),
                      );
                    }
                : null,
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
