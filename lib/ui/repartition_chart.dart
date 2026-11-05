import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/candidature.dart';
import 'piste_theme.dart';

class RepartitionChart extends StatelessWidget {
  const RepartitionChart({super.key, required this.comptes});
  final Map<StatutCandidature, int> comptes;

  @override
  Widget build(BuildContext context) {
    final total = comptes.values.fold(0, (somme, valeur) => somme + valeur);
    return Semantics(
      label: 'Répartition par statut. Total : $total candidatures.',
      child: SizedBox(
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RepartitionPainter([
                  for (final statut in StatutCandidature.values)
                    comptes[statut] ?? 0,
                ]),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$total',
                  key: const Key('bilan-total'),
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 40),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Candidatures',
                  style: TextStyle(color: pisteSecondaire, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RepartitionPainter extends CustomPainter {
  _RepartitionPainter(this.comptes);
  final List<int> comptes;

  @override
  void paint(Canvas canvas, Size size) {
    final rayon = math.min(size.width, size.height) / 2 - 14;
    if (rayon <= 0) return;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: rayon,
    );
    final peinture = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..color = pisteBordure;
    canvas.drawCircle(size.center(Offset.zero), rayon, peinture);
    final total = comptes.fold(0, (somme, valeur) => somme + valeur);
    if (total == 0) return;
    var depart = -math.pi / 2;
    for (var index = 0; index < comptes.length; index++) {
      final angle = comptes[index] * math.pi * 2 / total;
      peinture.color = StatutCandidature.values[index].couleur;
      canvas.drawArc(rect, depart, angle, false, peinture);
      depart += angle;
    }
  }

  @override
  bool shouldRepaint(_RepartitionPainter oldDelegate) =>
      !listEquals(comptes, oldDelegate.comptes);
}
