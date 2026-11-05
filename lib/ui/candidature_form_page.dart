import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'piste_theme.dart';

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
  late final TextEditingController _lienOffre;
  late final TextEditingController _notes;
  late StatutCandidature _statut;
  DateTime? _dateRelance;
  bool _enregistrement = false;

  @override
  void initState() {
    super.initState();
    _poste = TextEditingController(text: widget.candidature?.poste);
    _entreprise = TextEditingController(text: widget.candidature?.entreprise);
    _lienOffre = TextEditingController(text: widget.candidature?.lienOffre);
    _notes = TextEditingController(text: widget.candidature?.notes);
    _statut = widget.candidature?.statut ?? StatutCandidature.envoyee;
    _dateRelance = widget.candidature?.dateRelance;
  }

  @override
  void dispose() {
    _poste.dispose();
    _entreprise.dispose();
    _lienOffre.dispose();
    _notes.dispose();
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
    FocusScope.of(context).unfocus();
    setState(() => _enregistrement = true);
    try {
      final candidature = await widget.controller.enregistrer(
        initiale: widget.candidature,
        poste: _poste.text,
        entreprise: _entreprise.text,
        statut: _statut,
        dateRelance: _dateRelance,
        lienOffre: _lienOffre.text,
        notes: _notes.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(candidature);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enregistrement impossible. Réessayez, votre saisie est conservée.',
          ),
        ),
      );
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
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          canPop: !_enregistrement,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.candidature == null
                      ? 'Nouvelle candidature'
                      : 'Modifier la candidature',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Complétez les informations ci-dessous.',
                  style: TextStyle(color: pisteSecondaire, height: 1.6),
                ),
                const SizedBox(height: 26),
                TextFormField(
                  controller: _entreprise,
                  enabled: !_enregistrement,
                  decoration: const InputDecoration(
                    labelText: 'Entreprise',
                    hintText: 'Ex. Google',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Renseignez l’entreprise.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _poste,
                  enabled: !_enregistrement,
                  decoration: const InputDecoration(
                    labelText: 'Poste',
                    hintText: 'Ex. Développeur Flutter',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Renseignez le poste.'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StatutCandidature>(
                  initialValue: _statut,
                  decoration: const InputDecoration(labelText: 'Statut'),
                  items: [
                    for (final statut in StatutCandidature.values)
                      DropdownMenuItem(
                        value: statut,
                        child: Text(statut.libelle),
                      ),
                  ],
                  onChanged: _enregistrement
                      ? null
                      : (value) => setState(() => _statut = value!),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
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
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lienOffre,
                  enabled: !_enregistrement,
                  decoration: const InputDecoration(
                    labelText: 'Lien vers l’offre (facultatif)',
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: (value) => Candidature.lienOffreValide(value)
                      ? null
                      : 'Utilisez une adresse HTTP ou HTTPS valide.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  enabled: !_enregistrement,
                  decoration: const InputDecoration(
                    labelText: 'Notes (facultatives)',
                    hintText: 'Informations complémentaires…',
                  ),
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _enregistrement ? null : _enregistrer,
                  child: Text(
                    _enregistrement ? 'Enregistrement…' : 'Enregistrer',
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
