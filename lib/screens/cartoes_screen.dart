import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class CartoesScreen extends StatelessWidget {
  const CartoesScreen({super.key});

  String _fmt(dynamic v) => NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((v ?? 0.0).toDouble());
  String get _monthKey => DateFormat('yyyy-MM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Cartões')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users/$uid/creditCards').snapshots(),
        builder: (context, cardSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users/$uid/cardInvoices').snapshots(),
            builder: (context, invSnap) {
              if (!cardSnap.hasData) return const Center(child: CircularProgressIndicator());
              final cards = cardSnap.data!.docs.map((d) => {...(d.data() as Map<String, dynamic>), 'id': d.id}).toList();

              if (cards.isEmpty) {
                return Center(child: Text('Nenhum cartão cadastrado', style: GoogleFonts.dmSans(color: AppTheme.textMuted)));
              }

              double totalFaturas = 0;
              for (final c in cards) {
                if (invSnap.hasData) {
                  final inv = invSnap.data!.docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['cardId'] == c['id'] && data['monthKey'] == _monthKey;
                  });
                  if (inv.isNotEmpty) {
                    totalFaturas += ((inv.first.data() as Map)['amount'] ?? 0.0);
                  }
                }
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Total faturas
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.credit_card, color: AppTheme.red, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total de Faturas este mês', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13)),
                            Text(_fmt(totalFaturas), style: GoogleFonts.syne(color: AppTheme.red, fontSize: 22, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Meus Cartões', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  ...cards.map((card) {
                    double fatura = 0;
                    double limite = (card['limit'] ?? 0.0).toDouble();
                    if (invSnap.hasData) {
                      final inv = invSnap.data!.docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return data['cardId'] == card['id'] && data['monthKey'] == _monthKey;
                      });
                      if (inv.isNotEmpty) fatura = ((inv.first.data() as Map)['amount'] ?? 0.0).toDouble();
                    }
                    final usedPct = limite > 0 ? (fatura / limite).clamp(0.0, 1.0) : 0.0;
                    Color cardColor = AppTheme.primary;
                    try {
                      cardColor = Color(int.parse((card['color'] ?? '#0F4C81').replaceFirst('#', '0xFF')));
                    } catch (_) {}

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [cardColor, cardColor.withOpacity(0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(card['name'] ?? '', style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                const Icon(Icons.credit_card, color: Colors.white70, size: 28),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(card['bank'] ?? '', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Fatura atual', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
                                  Text(_fmt(fatura), style: GoogleFonts.syne(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                ]),
                                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text('Limite', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
                                  Text(_fmt(limite), style: GoogleFonts.syne(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                ]),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: usedPct,
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  usedPct > 0.8 ? AppTheme.red : Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${(usedPct * 100).toStringAsFixed(0)}% do limite utilizado',
                              style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
