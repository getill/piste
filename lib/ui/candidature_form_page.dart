import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';

class CandidatureFormPage extends StatefulWidget {
  const CandidatureFormPage({
    super.key,
    required this.controller,
    this.candidature,
  });

  final CandidatureController controller;
  final Candidature? candidature;

  @override
  State<CandidatureFormPage> createState() => _CandidatureFormPageState();
}

class _CandidatureFormPageState extends State<CandidatureFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _poste;
  late final TextEditingController _entreprise;
  late StatutCandidature _statut;
  DateTime? _dateRelance;
  bool _enregistrement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _poste = TextEditingController(text: widget.candidature?.poste);
    _entreprise = TextEditingController(text: widget.candidature?.entreprise);
    _statut = widget.candidature?.statut ?? StatutCandidature.envoyee;
    _dateRelance = widget.candidature?.dateRelance;
  }

  @override
  void dispose() {
    _poste.dispose();
    _entreprise.dispose();
    super.dispose();
  }

  Future<void> _choisirRelance() async {
    final maintenant = DateTime.now();
    final initiale = _dateRelance ?? maintenant;
    final date = await showDatePicker(
      context: context,
      initialDate: initiale,
      firstDate: DateTime(initiale.year - 100),
      lastDate: DateTime(initiale.year + 100),
      helpText: 'Date de relance',
      cancelText: 'Annuler',
      confirmText: 'Choisir',
    );
    if (!mounted || date == null) return;
    setState(() => _dateRelance = date);
  }

  Future<void> _enregistrer() async {
    if (_enregistrement || !_formKey.currentState!.validate()) return;
    setState(() {
      _enregistrement = true;
      _erreur = null;
    });
    try {
      final candidature = await widget.controller.enregistrer(
        initiale: widget.candidature,
        poste: _poste.text,
        entreprise: _entreprise.text,
        statut: _statut,
        dateRelance: _dateRelance,
      );
      if (!mounted) return;
      Navigator.of(context).pop(candidature);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erreur =
            'Enregistrement impossible. Réessayez, votre saisie est conservée.';
      });
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.candidature == null
              ? 'Nouvelle candidature'
              : 'Modifier la candidature',
        ),
      ),
      body: Form(
        key: _formKey,
        canPop: !_enregistrement,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _poste,
              enabled: !_enregistrement,
              decoration: const InputDecoration(labelText: 'Poste'),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Renseignez le poste.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _entreprise,
              enabled: !_enregistrement,
              decoration: const InputDecoration(labelText: 'Entreprise'),
              textCapitalization: TextCapitalization.words,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Renseignez l’entreprise.'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StatutCandidature>(
              initialValue: _statut,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: [
                for (final statut in StatutCandidature.values)
                  DropdownMenuItem(value: statut, child: Text(statut.libelle)),
              ],
              onChanged: _enregistrement
                  ? null
                  : (value) => setState(() => _statut = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Relance (facultative)'),
              subtitle: Text(
                _dateRelance == null
                    ? 'Aucune date'
                    : MaterialLocalizations.of(context)
                          .formatShortDate(_dateRelance!),
              ),
              onTap: _enregistrement ? null : _choisirRelance,
              trailing: _dateRelance == null
                  ? const Icon(Icons.calendar_today)
                  : IconButton(
                      tooltip: 'Retirer la relance',
                      onPressed: _enregistrement
                          ? null
                          : () => setState(() => _dateRelance = null),
                      icon: const Icon(Icons.clear),
                    ),
            ),
            if (_erreur != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _erreur!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _enregistrement ? null : _enregistrer,
              child: Text(_enregistrement ? 'Enregistrement…' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
