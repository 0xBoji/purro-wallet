import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import 'create_wallet_screen.dart';
import 'wallet_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    // Show loading indicator while checking for existing wallet
    if (walletProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Solana Wallet'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If wallet exists, show wallet details screen
    if (walletProvider.hasWallet) {
      return const WalletDetailsScreen();
    }

    // If no wallet exists, show create wallet screen
    return const CreateWalletScreen();
  }
}
