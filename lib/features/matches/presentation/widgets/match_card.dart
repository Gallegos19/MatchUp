import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  final String name;
  final int age;
  final String career;
  final String imageUrl;

  const MatchCard({
    super.key,
    required this.name,
    required this.age,
    required this.career,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name, $age', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(career, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.clear, color: Colors.red),
                    Icon(Icons.star, color: Colors.amber),
                    Icon(Icons.favorite, color: Colors.pink),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
