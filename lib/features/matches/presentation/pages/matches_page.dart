import 'package:flutter/material.dart';
import 'package:matchup/di/injection_container.dart';
import 'package:provider/provider.dart';
import '../viewmodels/match_viewmodel.dart';
import '../widgets/match_card.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchViewModel(

        sl(), // sl() es serviceLocator<GetPotentialMatches>()
      )..loadMatches(),
      child: const _MatchesView(),
    );
  }
}

class _MatchesView extends StatelessWidget {
  const _MatchesView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MatchViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(child: Text('Error: ${viewModel.error}'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Conexiones')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.matches.length,
        itemBuilder: (context, index) {
          final match = viewModel.matches[index];
          return MatchCard(
            name: match.name,
            age: match.age,
            career: match.career,
            imageUrl: match.imageUrl,
          );
        },
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Matches'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Grupos'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventos'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Perfil'),
      ],
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}
