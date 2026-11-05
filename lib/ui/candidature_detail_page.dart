import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'candidature_form_page.dart';

class CandidatureDetailPage extends StatefulWidget {
  const CandidatureDetailPage({
    super.key,
    required this.controller,
    required this.candidature,
  });

  final CandidatureController controller;
  final Candidature candidature;

  @override
  State<CandidatureDetailPage> createState() => _CandidatureDetailPageState();
}

class _CandidatureDetailPageState extends State<CandidatureDetailPage> {
  late Candidature _candidature = widget.candidature;
  bool _suppression = false;
  String? _erreur;

  Future<void> _modifier() async {
    final modifiee = await Navigator.of(context).push<Candidature>(
      MaterialPageRoute(
        builder: (_) => CandidatureFormPage(
          controller: widget.controller,
          candidature: _candidature,
        ),
      ),
    );
    if (!mounted || modifiee == null) return;
    setState(() => _candidature = modifiee);
  }

  Future<void> _supprimer() async {
    if (_suppression) return;
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette candidature ?'),
        content: Text('${_candidature.poste} — ${_candidature.entreprise}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (!mounted || confirmation != true || _suppression) return;
    setState(() {
      _suppression = true;
      _erreur = null;
    });
    try {
      await widget.controller.supprimer(_candidature.id!);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erreur = 'Suppression impossible. Réessayez.');
    } finally {
      if (mounted) setState(() => _suppression = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = MaterialLocalizations.of(context);
    return PopScope(
      canPop: !_suppression,
      child: Scaffold(
        appBar: AppBar(title: const Text('Détail de la candidature')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _candidature.poste,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(_candidature.entreprise),
            const SizedBox(height: 16),
            Text('Statut : ${_candidature.statut.libelle}'),
            const SizedBox(height: 8),
            Text(
              'Date de candidature : ${dates.formatShortDate(_candidature.dateCreation)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Relance : ${_candidature.dateRelance == null ? 'Non prévue' : dates.formatShortDate(_candidature.dateRelance!)}',
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière modification : ${dates.formatShortDate(_candidature.dateModification)}',
            ),
            if (_candidature.lienOffre != null) ...[
              const SizedBox(height: 16),
              const Text('Lien vers l’offre'),
              SelectableText(_candidature.lienOffre!),
            ],
            if (_candidature.notes != null) ...[
              const SizedBox(height: 16),
              const Text('Notes'),
              Text(_candidature.notes!),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _suppression ? null : _modifier,
              child: const Text('Modifier'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _suppression ? null : _supprimer,
              child: Text(_suppression ? 'Suppression…' : 'Supprimer'),
            ),
            if (_erreur != null)
              Text(
                _erreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }
}
