import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'candidature_card.dart';
import 'candidature_detail_page.dart';
import 'candidature_form_page.dart';
import 'piste_theme.dart';
import 'repartition_chart.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key, required this.controller});
  final CandidatureController controller;

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final _recherche = TextEditingController();
  int _page = 0;
  CandidatureController get controller => widget.controller;

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  Future<void> _ajouter() async {
    final candidature = await Navigator.of(context).push<Candidature>(
      MaterialPageRoute(
        builder: (_) => CandidatureFormPage(controller: controller),
      ),
    );
    if (!mounted || candidature == null) return;
    _ouvrirDetail(candidature);
  }

  void _ouvrirDetail(Candidature candidature) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CandidatureDetailPage(
          controller: controller,
          candidature: candidature,
        ),
      ),
    );
  }

  Widget _etat({
    required IconData icone,
    required String titre,
    required String description,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F5F4),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 32, color: pistePrimaire),
          ),
          const SizedBox(height: 20),
          Text(
            titre,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: pisteSecondaire, height: 1.6),
          ),
          if (action != null) ...[const SizedBox(height: 24), action],
        ],
      ),
    );
  }

  Widget _compteur(
    String titre,
    int nombre,
    IconData icone,
    Color couleur,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
      child: Column(
        children: [
          Icon(icone, color: couleur, size: 26),
          const SizedBox(height: 12),
          Text('$nombre', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            titre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );

  Widget _accueil() {
    final candidatures = controller.candidatures;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 100),
      children: [
        Text('Bonjour !', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        const Text(
          'Suivez l’avancement de vos candidatures.',
          style: TextStyle(color: pisteSecondaire, height: 1.6),
        ),
        const SizedBox(height: 26),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _compteur(
                'Candidatures',
                candidatures.length,
                Icons.work_outline_rounded,
                const Color(0xFF3289F3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _compteur(
                'Entretiens',
                candidatures
                    .where((c) => c.statut == StatutCandidature.entretien)
                    .length,
                Icons.check_circle_outline_rounded,
                const Color(0xFF16B782),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _compteur(
                'Offres',
                candidatures
                    .where((c) => c.statut == StatutCandidature.offre)
                    .length,
                Icons.star_rounded,
                const Color(0xFFFFBB43),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Mes candidatures',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _page = 1),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (candidatures.isEmpty)
          _etat(
            icone: Icons.work_outline_rounded,
            titre: 'Aucune candidature.',
            description: 'Ajoutez votre première candidature pour commencer votre suivi.',
            action: FilledButton.icon(
              onPressed: _ajouter,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une candidature'),
            ),
          ),
        for (final candidature in candidatures.take(4)) ...[
          CandidatureCard(
            candidature: candidature,
            onTap: () => _ouvrirDetail(candidature),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _liste() {
    final visibles = controller.visibles;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
          child: TextField(
            controller: _recherche,
            onChanged: controller.rechercher,
            decoration: InputDecoration(
              labelText: 'Rechercher une candidature',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _recherche.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer la recherche',
                      onPressed: () {
                        _recherche.clear();
                        controller.rechercher('');
                      },
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Toutes'),
                labelStyle: TextStyle(
                  color: controller.filtre == null
                      ? Colors.white
                      : pisteSecondaire,
                ),
                selected: controller.filtre == null,
                onSelected: (_) => controller.filtrer(null),
              ),
              for (final statut in StatutCandidature.values)
                ChoiceChip(
                  label: Text(statut.libelle),
                  labelStyle: TextStyle(
                    color: controller.filtre == statut
                        ? Colors.white
                        : pisteSecondaire,
                  ),
                  selected: controller.filtre == statut,
                  onSelected: (_) => controller.filtrer(statut),
                ),
            ],
          ),
        ),
        Expanded(
          child: visibles.isEmpty
              ? ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  children: [
                    controller.candidatures.isEmpty
                        ? _etat(
                            icone: Icons.work_outline_rounded,
                            titre: 'Aucune candidature.',
                            description: 'Ajoutez votre première candidature pour commencer.',
                          )
                        : _etat(
                            icone: Icons.search_off_rounded,
                            titre: 'Aucun résultat pour ces critères.',
                            description: 'Essayez un autre poste, une entreprise ou un statut.',
                          ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
                  itemCount: visibles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => CandidatureCard(
                    candidature: visibles[index],
                    onTap: () => _ouvrirDetail(visibles[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _bilan() {
    final candidatures = controller.candidatures;
    final comptes = {
      for (final statut in StatutCandidature.values)
        statut: candidatures.where((c) => c.statut == statut).length,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
      children: [
        Text(
          'Vue d’ensemble',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        const Text(
          'Toutes vos candidatures, quel que soit le filtre.',
          style: TextStyle(color: pisteSecondaire, height: 1.6),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: RepartitionChart(comptes: comptes),
          ),
        ),
        const SizedBox(height: 28),
        Text('Répartition', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final statut in StatutCandidature.values) ...[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Icon(Icons.circle, color: statut.couleur, size: 12),
              title: Text(
                statut.libelle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${comptes[statut]}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${candidatures.isEmpty ? 0 : (comptes[statut]! * 100 / candidatures.length).round()} %',
                    style: const TextStyle(
                      color: pisteSecondaire,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _contenu() {
    if (controller.etat == EtatChargement.loading) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Chargement des candidatures',
        ),
      );
    }
    if (controller.etat == EtatChargement.error) {
      return ListView(
        padding: const EdgeInsets.all(22),
        children: [
          _etat(
            icone: Icons.cloud_off_rounded,
            titre: 'Chargement impossible',
            description:
                controller.messageErreur ??
                'Vos données ne sont pas disponibles pour le moment.',
            action: FilledButton.icon(
              onPressed: controller.charger,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ),
        ],
      );
    }
    return switch (_page) {
      0 => _accueil(),
      1 => _liste(),
      _ => _bilan(),
    };
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: _page == 0
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    color: pistePrimaire,
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Piste',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ],
              )
            : Text(_page == 1 ? 'Candidatures' : 'Bilan'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SafeArea(top: false, child: _contenu()),
      floatingActionButton: _page == 2
          ? null
          : FloatingActionButton(
              onPressed: controller.occupe ? null : _ajouter,
              tooltip: 'Ajouter',
              child: const Icon(Icons.add_rounded, size: 30),
            ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: pisteBordure)),
        ),
        child: NavigationBar(
          selectedIndex: _page,
          onDestinationSelected: (page) {
            FocusScope.of(context).unfocus();
            setState(() => _page = page);
          },
          destinations: const [
            NavigationDestination(
              key: Key('nav-accueil'),
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            NavigationDestination(
              key: Key('nav-candidatures'),
              icon: Icon(Icons.format_list_bulleted_rounded),
              label: 'Candidatures',
            ),
            NavigationDestination(
              key: Key('nav-bilan'),
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Bilan',
            ),
          ],
        ),
      ),
    ),
  );
}
