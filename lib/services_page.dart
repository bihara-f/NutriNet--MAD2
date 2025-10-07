import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Services",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Take care of your Health",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                "Learn more about the various\n"
                "offered by our website and\n"
                "we provide you with world\n"
                "class care",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              _buildSection(
                title: "Diet Planning",
                imagePath: 'asset/diet-plans-1.jpeg',
                description:
                    "Hey there! Are you looking for a way to eat healthier and live a happier life? "
                    "Well, look no further! We are here to help you achieve your health goals! Our team of "
                    "friendly experts will work closely with you to create personalized meal plans that take into "
                    "account your goals, preferences, and any health concerns you may have. We'll be there to support "
                    "and motivate you every step of the way, so you can succeed and feel your best!",
                imageLeft: true,
              ),
              const SizedBox(height: 40),

              _buildSection(
                title: "Fit Training",
                imagePath: 'asset/Dumbbells.jpeg',
                description:
                    "Looking for an exciting way to start your fitness journey? Look no further! Our gym offers a range of "
                    "training options that are guaranteed to get you moving and grooving. Our experienced team of trainers is "
                    "always on hand to guide you through every step of the way.",
                imageLeft: false,
              ),
              const SizedBox(height: 40),

              _buildSection(
                title: "Nutrition Guidelines",
                imagePath: 'asset/clip_dumbell.jpeg',
                description:
                    "We are here to help you eat better and feel better! Our experts create personalized meal plans that "
                    "fit your lifestyle and needs. With support and encouragement, you'll reach your wellness goals faster.",
                imageLeft: true,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String imagePath,
    required String description,
    required bool imageLeft,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;

        Widget image = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            width: isWide ? 200 : double.infinity,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  width: isWide ? 200 : double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
          ),
        );

        Widget text = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(description, style: const TextStyle(fontSize: 16)),
            ],
          ),
        );

        return isWide
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  imageLeft
                      ? [image, Expanded(child: text)]
                      : [Expanded(child: text), image],
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [image, const SizedBox(height: 12), text],
            );
      },
    );
  }
}
