import 'package:flutter/material.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Piste'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Candidatures'),
              Tab(text: 'Bilan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: const [
                Card(
                  child: ListTile(
                    title: Text('Développeur Flutter junior'),
                    subtitle: Text('Atelier Mobile · Envoyée'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Développeuse web en alternance'),
                    subtitle: Text('Studio Numérique · Entretien'),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: const [
                Text('Le bilan sera réalisé dans un prochain TP.'),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Le formulaire sera réalisé dans un prochain TP.',
                ),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Ajouter'),
        ),
      ),
    );
  }
}
