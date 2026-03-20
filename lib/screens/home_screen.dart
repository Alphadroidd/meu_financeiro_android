import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'salario_screen.dart';
import 'dividas_screen.dart';
import 'lancamentos_screen.dart';
import 'cartoes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SalarioScreen(),
    DividasScreen(),
    LancamentosScreen(),
    CartoesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined), activeIcon: Icon(Icons.account_balance), label: 'Salário'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), activeIcon: Icon(Icons.credit_card), label: 'Dívidas'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Lançamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.style_outlined), activeIcon: Icon(Icons.style), label: 'Cartões'),
        ],
      ),
    );
  }
}
