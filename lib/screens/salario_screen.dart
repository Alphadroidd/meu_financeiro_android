import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class SalarioScreen extends StatelessWidget {
  const SalarioScreen({super.key});

  String _fmt(dynamic v) => NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((v ?? 0.0).toDouble());

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Salário')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users/$uid/salaryConfig').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!.docs.first.data() as Map<String, dynamic>;
          final gross = (data['salaryBase'] ?? 0.0) + (data['analystCommission'] ?? 0.0) + (data['annuity'] ?? 0.0);
          final ded = (data['inss'] ?? 0.0) + (data['irrf'] ?? 0.0) + (data['icatu'] ?? 0.0) +
              (data['unimed'] ?? 0.0) + (data['uniodonto'] ?? 0.0) + (data['afbepa'] ?? 0.0) +
              (data['consignado1'] ?? 0.0) + (data['consignado2'] ?? 0.0) + (data['confissaoDivida'] ?? 0.0);
          final net = gross - ded;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Card hero
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Salário Líquido Estimado', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(_fmt(net), style: GoogleFonts.syne(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Banco do Estado do Pará — Banpará', style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _miniCard('Bruto', _fmt(gross), Colors.white24)),
                        const SizedBox(width: 8),
                        Expanded(child: _miniCard('Descontos', _fmt(ded), const Color(0x40E05A4E))),
                        const SizedBox(width: 8),
                        Expanded(child: _miniCard('Líquido', _fmt(net), const Color(0x401A7C5C))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Proventos
              _sectionTitle('💚 Proventos'),
              const SizedBox(height: 8),
              _item('Salário Base', data['salaryBase'], AppTheme.secondary),
              _item('Comissão / Grat. Analista', data['analystCommission'], AppTheme.secondary),
              _item('Anuênio', data['annuity'], AppTheme.secondary),
              _totalRow('Total Bruto', gross, AppTheme.secondary),
              const SizedBox(height: 20),

              // Descontos
              _sectionTitle('🔴 Descontos'),
              const SizedBox(height: 8),
              _item('INSS / Previdência Social', data['inss'], AppTheme.red),
              _item('IRRF (Imposto de Renda)', data['irrf'], AppTheme.red),
              _item('Prev. Complementar ICATU', data['icatu'], AppTheme.red),
              _item('Plano de Saúde Unimed', data['unimed'], AppTheme.red),
              _item('Odontológico Uniodonto', data['uniodonto'], AppTheme.red),
              _item('Mensalidade AFBEPA', data['afbepa'], AppTheme.red),
              _item('Consignado I — 7471524', data['consignado1'], AppTheme.red, highlight: true),
              _item('Consignado II — 8194822', data['consignado2'], AppTheme.red, highlight: true),
              _item('Confissão Dívida — 58681', data['confissaoDivida'], AppTheme.red, highlight: true),
              _totalRow('Total Descontos', ded, AppTheme.red),
              const SizedBox(height: 24),

              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _infoRow('Admissão', '05/10/2020'),
                    _infoRow('Cargo', 'Técnico Bancário'),
                    _infoRow('Banco', 'Banpará'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary));

  Widget _miniCard(String label, String value, Color bg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.syne(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _item(String label, dynamic value, Color color, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.08) : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? color.withOpacity(0.3) : AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: highlight ? color : AppTheme.textPrimary))),
          Text(_fmt(value), style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          Text(_fmt(value), style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13)),
          Text(value, style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
