import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RewardsPage extends StatefulWidget {
  final String rewardTitle;
  final String rewardMessage;
  final String rewardImageAsset;
  final String funFact;

  const RewardsPage({
    super.key,
    required this.rewardTitle,
    required this.rewardMessage,
    required this.rewardImageAsset,
    required this.funFact,
  });

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward(); // Start the animation on page load
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(widget.rewardImageAsset, height: 120),
              ),
              const SizedBox(height: 20),
              Text(
                widget.rewardTitle,
                style: GoogleFonts.fredoka(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.rewardMessage,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  color: Colors.brown[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                "🌱 Fun Fact!",
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.funFact,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: Colors.green[900],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text("Back to Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
