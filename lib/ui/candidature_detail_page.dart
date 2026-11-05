import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'candidature_form_page.dart';
import 'piste_theme.dart';

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
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFC82C48),
        ),
        title: const Text('Supprimer cette candidature ?'),
        content: Text(
          '${_candidature.poste} — ${_candidature.entreprise}\n\nCette action est définitive.',
        ),
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

  Widget _information(IconData icone, String titre, String valeur) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: pistePrimaire, size: 23),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(color: pisteSecondaire, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dates = MaterialLocalizations.of(context);
    return PopScope(
      canPop: !_suppression,
      child: Scaffold(
        appBar: AppBar(title: const Text('Détail de la candidature')),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFE6F5F4),
                      foregroundColor: pistePrimaire,
                      child: Text(
                        _candidature.entreprise.trim().isEmpty
                            ? '?'
                            : _candidature.entreprise
                                  .trim()
                                  .characters
                                  .first
                                  .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _candidature.entreprise,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _candidature.poste,
                            style: const TextStyle(
                              color: pisteSecondaire,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatutBadge(statut: _candidature.statut),
                ),
                const SizedBox(height: 28),
                _information(
                  Icons.calendar_today_outlined,
                  'Date de candidature',
                  dates.formatFullDate(_candidature.dateCreation),
                ),
                const SizedBox(height: 12),
                _information(
                  Icons.event_available_outlined,
                  'Relance',
                  _candidature.dateRelance == null
                      ? 'Non prévue'
                      : dates.formatFullDate(_candidature.dateRelance!),
                ),
                const SizedBox(height: 12),
                _information(
                  Icons.schedule_rounded,
                  'Dernière modification',
                  dates.formatFullDate(_candidature.dateModification),
                ),
                if (_candidature.lienOffre != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Lien vers l’offre',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        _candidature.lienOffre!,
                        style: const TextStyle(color: pisteAction),
                      ),
                    ),
                  ),
                ],
                if (_candidature.notes != null) ...[
                  const SizedBox(height: 24),
                  Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        _candidature.notes!,
                        style: const TextStyle(height: 1.8),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _suppression ? null : _modifier,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text('Modifier'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFC82C48),
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: _suppression ? null : _supprimer,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text(_suppression ? 'Suppression…' : 'Supprimer'),
                ),
                if (_erreur != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _erreur!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
