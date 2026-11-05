import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'candidature_detail_page.dart';
import 'candidature_form_page.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key, required this.controller});

  final CandidatureController controller;

  Future<void> _ajouter(BuildContext context) async {
    final candidature = await Navigator.of(context).push<Candidature>(
      MaterialPageRoute(
        builder: (_) => CandidatureFormPage(controller: controller),
      ),
    );
    if (!context.mounted || candidature == null) return;
    _ouvrirDetail(context, candidature);
  }

  void _ouvrirDetail(BuildContext context, Candidature candidature) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CandidatureDetailPage(
          controller: controller,
          candidature: candidature,
        ),
      ),
    );
  }

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
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                final candidatures = controller.candidatures;
                if (candidatures.isEmpty) {
                  return const Center(child: Text('Aucune candidature.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: candidatures.length,
                  itemBuilder: (context, index) {
                    final candidature = candidatures[index];
                    return Card(
                      child: ListTile(
                        title: Text(candidature.poste),
                        subtitle: Text(
                          '${candidature.entreprise} · ${candidature.statut.libelle}',
                        ),
                        onTap: () => _ouvrirDetail(context, candidature),
                      ),
                    );
                  },
                );
              },
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
          onPressed: () => _ajouter(context),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter'),
        ),
      ),
    );
  }
}
