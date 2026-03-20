import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class LancamentosScreen extends StatefulWidget {
  const LancamentosScreen({super.key});

  @override
  State<LancamentosScreen> createState() => _LancamentosScreenState();
}

class _LancamentosScreenState extends State<LancamentosScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  String _filter = 'all';

  String _fmt(dynamic v) => NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format((v ?? 0.0).toDouble());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamentos'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddModal(context)),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _filterChip('Todos', 'all'),
                const SizedBox(width: 8),
                _filterChip('Receitas', 'income'),
                const SizedBox(width: 8),
                _filterChip('Despesas', 'expense'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users/$uid/transactions')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snap.data!.docs;
                if (_filter != 'all') {
                  docs = docs.where((d) => (d.data() as Map)['type'] == _filter).toList();
                }
                if (docs.isEmpty) {
                  return Center(child: Text('Nenhum lançamento', style: GoogleFonts.dmSans(color: AppTheme.textMuted)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final isIncome = data['type'] == 'income';
                    DateTime? date;
                    try { date = (data['date'] as Timestamp).toDate(); } catch (_) {}

                    return Dismissible(
                      key: Key(docs[i].id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(color: AppTheme.red, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        FirebaseFirestore.instance.doc('users/$uid/transactions/${docs[i].id}').delete();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: isIncome ? AppTheme.secondary.withOpacity(0.15) : AppTheme.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text(data['icon'] ?? (isIncome ? '💚' : '🔴'), style: const TextStyle(fontSize: 18))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['description'] ?? '', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                                  Text(
                                    '${data['categoryLabel'] ?? data['category'] ?? ''}${date != null ? ' · ${DateFormat('dd/MM').format(date)}' : ''}',
                                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isIncome ? '+' : '-'}${_fmt(data['amount'])}',
                              style: GoogleFonts.syne(
                                color: isIncome ? AppTheme.secondary : AppTheme.red,
                                fontWeight: FontWeight.w700, fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.secondary : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.secondary : AppTheme.border),
        ),
        child: Text(label, style: GoogleFonts.dmSans(
          color: selected ? Colors.white : AppTheme.textMuted,
          fontSize: 13, fontWeight: FontWeight.w600,
        )),
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String type = 'expense';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Novo Lançamento', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              // Tipo
              Row(
                children: [
                  Expanded(child: GestureDetector(
                    onTap: () => setS(() => type = 'expense'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: type == 'expense' ? AppTheme.red.withOpacity(0.2) : AppTheme.bgTertiary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: type == 'expense' ? AppTheme.red : AppTheme.border),
                      ),
                      child: Center(child: Text('Despesa', style: GoogleFonts.dmSans(color: type == 'expense' ? AppTheme.red : AppTheme.textMuted, fontWeight: FontWeight.w600))),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: GestureDetector(
                    onTap: () => setS(() => type = 'income'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: type == 'income' ? AppTheme.secondary.withOpacity(0.2) : AppTheme.bgTertiary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: type == 'income' ? AppTheme.secondary : AppTheme.border),
                      ),
                      child: Center(child: Text('Receita', style: GoogleFonts.dmSans(color: type == 'income' ? AppTheme.secondary : AppTheme.textMuted, fontWeight: FontWeight.w600))),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ '),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final amt = double.tryParse(amtCtrl.text.replaceAll(',', '.')) ?? 0;
                    if (descCtrl.text.isEmpty || amt == 0) return;
                    await FirebaseFirestore.instance.collection('users/$uid/transactions').add({
                      'description': descCtrl.text,
                      'amount': amt,
                      'type': type,
                      'date': Timestamp.now(),
                      'category': type == 'income' ? 'income' : 'expense',
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text('Salvar', style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
