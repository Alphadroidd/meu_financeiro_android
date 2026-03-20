import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  DateTime _selected = DateTime.now();

  String get _monthKey => DateFormat('yyyy-MM').format(_selected);

  String get _monthLabel => DateFormat('MMMM yyyy', 'pt_BR').format(_selected);

  void _prev() => setState(() => _selected = DateTime(_selected.year, _selected.month - 1));
  void _next() => setState(() => _selected = DateTime(_selected.year, _selected.month + 1));

  String _fmt(double v) => NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users/$uid/salaryConfig').snapshots(),
        builder: (context, salSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users/$uid/salaryHistory').snapshots(),
            builder: (context, histSnap) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users/$uid/debtors').snapshots(),
                builder: (context, debtSnap) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users/$uid/transactions').snapshots(),
                    builder: (context, txSnap) {
                      // Calcular salário líquido
                      Map<String, dynamic> salData = {};
                      if (histSnap.hasData) {
                        final h = histSnap.data!.docs.where((d) => d['monthKey'] == _monthKey);
                        if (h.isNotEmpty) salData = h.first.data() as Map<String, dynamic>;
                      }
                      if (salData.isEmpty && salSnap.hasData && salSnap.data!.docs.isNotEmpty) {
                        salData = salSnap.data!.docs.first.data() as Map<String, dynamic>;
                      }
                      final gross = (salData['salaryBase'] ?? 0.0) + (salData['analystCommission'] ?? 0.0) + (salData['annuity'] ?? 0.0);
                      final ded = (salData['inss'] ?? 0.0) + (salData['irrf'] ?? 0.0) + (salData['icatu'] ?? 0.0) +
                          (salData['unimed'] ?? 0.0) + (salData['uniodonto'] ?? 0.0) + (salData['afbepa'] ?? 0.0) +
                          (salData['consignado1'] ?? 0.0) + (salData['consignado2'] ?? 0.0) + (salData['confissaoDivida'] ?? 0.0);
                      final salLiq = (gross - ded).toDouble();

                      // Devedores
                      double devedores = 0;
                      if (debtSnap.hasData) {
                        for (var d in debtSnap.data!.docs) {
                          final data = d.data() as Map<String, dynamic>;
                          if (data['paid'] != true) devedores += (data['amount'] ?? 0.0);
                        }
                      }

                      // Transações do mês
                      double txIncome = 0, txExpense = 0;
                      if (txSnap.hasData) {
                        for (var d in txSnap.data!.docs) {
                          final data = d.data() as Map<String, dynamic>;
                          DateTime date;
                          try {
                            date = (data['date'] as Timestamp).toDate();
                          } catch (_) {
                            continue;
                          }
                          if (DateFormat('yyyy-MM').format(date) != _monthKey) continue;
                          if (data['type'] == 'income') txIncome += (data['amount'] ?? 0.0);
                          if (data['type'] == 'expense') txExpense += (data['amount'] ?? 0.0);
                        }
                      }

                      final totalIncome = salLiq + devedores + txIncome;
                      final balance = totalIncome - txExpense;

                      return RefreshIndicator(
                        onRefresh: () async => setState(() {}),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Navegador de mês
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                children: [
                                  IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left)),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        _monthLabel[0].toUpperCase() + _monthLabel.substring(1),
                                        style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  IconButton(onPressed: _next, icon: const Icon(Icons.chevron_right)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Card principal — salário líquido
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
                                  Text('Receitas do Mês', style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text(_fmt(totalIncome), style: GoogleFonts.syne(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(child: _miniCard('Salário\nLíquido', _fmt(salLiq), Colors.white24)),
                                      const SizedBox(width: 8),
                                      Expanded(child: _miniCard('A\nReceber', _fmt(devedores), Colors.white24)),
                                      const SizedBox(width: 8),
                                      Expanded(child: _miniCard('Extras', _fmt(txIncome), Colors.white24)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Cards resumo
                            Row(
                              children: [
                                Expanded(child: _statCard('Despesas', _fmt(txExpense), AppTheme.red, Icons.trending_down)),
                                const SizedBox(width: 12),
                                Expanded(child: _statCard('Saldo', _fmt(balance), balance >= 0 ? AppTheme.secondary : AppTheme.red, Icons.account_balance_wallet_outlined)),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Transações recentes
                            Text('Lançamentos Recentes', style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 12),
                            if (!txSnap.hasData || txSnap.data!.docs.isEmpty)
                              _emptyState('Nenhum lançamento este mês')
                            else
                              ...txSnap.data!.docs
                                  .where((d) {
                                    final data = d.data() as Map<String, dynamic>;
                                    try {
                                      final date = (data['date'] as Timestamp).toDate();
                                      return DateFormat('yyyy-MM').format(date) == _monthKey;
                                    } catch (_) { return false; }
                                  })
                                  .take(8)
                                  .map((d) {
                                    final data = d.data() as Map<String, dynamic>;
                                    final isIncome = data['type'] == 'income';
                                    return _txTile(
                                      data['description'] ?? '',
                                      data['categoryLabel'] ?? data['category'] ?? '',
                                      (data['amount'] ?? 0.0).toDouble(),
                                      isIncome,
                                    );
                                  }),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _miniCard(String label, String value, Color bg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 10, height: 1.3)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.syne(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12)),
                Text(value, style: GoogleFonts.syne(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _txTile(String desc, String category, double amount, bool isIncome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isIncome ? AppTheme.secondary.withOpacity(0.15) : AppTheme.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? AppTheme.secondary : AppTheme.red, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                Text(category, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(amount)}',
            style: GoogleFonts.syne(
              color: isIncome ? AppTheme.secondary : AppTheme.red,
              fontWeight: FontWeight.w700, fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Center(child: Text(msg, style: GoogleFonts.dmSans(color: AppTheme.textMuted))),
    );
  }
}
