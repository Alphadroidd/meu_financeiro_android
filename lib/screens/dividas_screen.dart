import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class DividasScreen extends StatelessWidget {
  const DividasScreen({super.key});

  String _fmt(dynamic v) => NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((v ?? 0.0).toDouble());

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Dívidas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users/$uid/debts').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final debts = snap.data!.docs.map((d) => {...(d.data() as Map<String, dynamic>), 'id': d.id}).toList();

          if (debts.isEmpty) {
            return Center(child: Text('Nenhuma dívida cadastrada', style: GoogleFonts.dmSans(color: AppTheme.textMuted)));
          }

          final totalBalance = debts.fold<double>(0, (a, b) => a + (b['remainingBalance'] ?? 0.0));
          final totalMonthly = debts.fold<double>(0, (a, b) => a + (b['installment'] ?? 0.0));
          final totalPaid = debts.fold<double>(0, (a, b) => a + ((b['paidInstallments'] ?? 0) * (b['installment'] ?? 0.0)));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Resumo
              Row(
                children: [
                  Expanded(child: _summaryCard('Saldo Devedor', _fmt(totalBalance), AppTheme.red)),
                  const SizedBox(width: 10),
                  Expanded(child: _summaryCard('Parcela Mensal', _fmt(totalMonthly), AppTheme.accent)),
                ],
              ),
              const SizedBox(height: 10),
              _summaryCard('Total Já Pago', _fmt(totalPaid), AppTheme.secondary),
              const SizedBox(height: 20),

              Text('Contratos', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              ...debts.map((debt) => _debtCard(context, debt, uid!)),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.syne(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _debtCard(BuildContext context, Map<String, dynamic> debt, String uid) {
    final paid = (debt['paidInstallments'] ?? 0) as int;
    final total = (debt['totalInstallments'] ?? 1) as int;
    final pct = total > 0 ? paid / total : 0.0;
    final remaining = total - paid;
    final color = Color(int.parse((debt['color'] ?? '#0F4C81').replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(debt['name'] ?? '', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                ),
                Text(_fmt(debt['installment']), style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.red)),
              ],
            ),
            const SizedBox(height: 4),
            if (debt['discountedFromPayroll'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('✓ Desconto em folha', style: GoogleFonts.dmSans(color: AppTheme.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$paid parcelas pagas', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12)),
                Text('$remaining restantes · ${(pct * 100).toStringAsFixed(0)}%', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: AppTheme.bgTertiary,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _infoChip('Saldo devedor', _fmt(debt['remainingBalance']), AppTheme.red)),
                const SizedBox(width: 8),
                Expanded(child: _infoChip('Valor original', _fmt(debt['originalValue']), AppTheme.textMuted)),
              ],
            ),
            if (debt['note'] != null && debt['note'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('ℹ️ ${debt['note']}', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 11, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppTheme.bgTertiary, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.syne(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

const bgTertiary = AppTheme.bgTertiary;
