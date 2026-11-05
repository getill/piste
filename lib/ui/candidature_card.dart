import 'package:flutter/material.dart';

import '../models/candidature.dart';
import 'piste_theme.dart';

class CandidatureCard extends StatelessWidget {
  const CandidatureCard({
    super.key,
    required this.candidature,
    required this.onTap,
  });

  final Candidature candidature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, contraintes) {
            final compact =
                contraintes.maxWidth < 310 ||
                MediaQuery.textScalerOf(context).scale(14) > 18;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEFF5F8),
                  foregroundColor: pistePrimaire,
                  child: Text(
                    candidature.entreprise.trim().isEmpty
                        ? '?'
                        : candidature.entreprise
                              .trim()
                              .characters
                              .first
                              .toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidature.entreprise,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidature.poste,
                        style: const TextStyle(
                          color: pisteSecondaire,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      if (compact) ...[
                        const SizedBox(height: 10),
                        StatutBadge(statut: candidature.statut),
                      ],
                    ],
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  StatutBadge(statut: candidature.statut),
                ],
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: pisteSecondaire,
                  size: 22,
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
