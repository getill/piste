import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'candidature_detail_page.dart';
import 'candidature_form_page.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key, required this.controller});

  final CandidatureController controller;

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final _recherche = TextEditingController();
  CandidatureController get controller => widget.controller;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

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

  Widget _contenu(BuildContext context) {
    if (controller.etat == EtatChargement.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.etat == EtatChargement.error) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(controller.messageErreur ?? 'Chargement impossible.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: controller.charger,
            child: const Text('Réessayer'),
          ),
        ],
      );
    }
    final visibles = controller.visibles;
    final candidatures = controller.candidatures;
    return TabBarView(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _recherche,
                onChanged: controller.rechercher,
                decoration: const InputDecoration(
                  labelText: 'Rechercher une candidature',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Toutes'),
                    selected: controller.filtre == null,
                    onSelected: (_) => controller.filtrer(null),
                  ),
                  for (final statut in StatutCandidature.values)
                    ChoiceChip(
                      label: Text(statut.libelle),
                      selected: controller.filtre == statut,
                      onSelected: (_) => controller.filtrer(statut),
                    ),
                ],
              ),
            ),
            Expanded(
              child: candidatures.isEmpty
                  ? const Center(child: Text('Aucune candidature.'))
                  : visibles.isEmpty
                  ? const Center(
                      child: Text('Aucun résultat pour ces critères.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: visibles.length,
                      itemBuilder: (context, index) {
                        final candidature = visibles[index];
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
                    ),
            ),
          ],
        ),
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Text(
              'Total : ${candidatures.length}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            for (final statut in StatutCandidature.values)
              ListTile(
                title: Text(statut.libelle),
                trailing: Text(
                  '${candidatures.where((item) => item.statut == statut).length}',
                ),
                subtitle: LinearProgressIndicator(
                  value: candidatures.isEmpty
                      ? 0
                      : candidatures
                                .where((item) => item.statut == statut)
                                .length /
                            candidatures.length,
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Piste'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Candidatures'),
                Tab(text: 'Bilan'),
              ],
            ),
          ),
          body: _contenu(context),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: controller.occupe ? null : () => _ajouter(context),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
        ),
      ),
    );
  }
}
