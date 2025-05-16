import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/network_provider.dart';
import '../models/solana_wallet.dart';
import '../models/ethereum_wallet.dart';

class WalletDetailsScreen extends StatelessWidget {
  const WalletDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final networkProvider = Provider.of<NetworkProvider>(context);
    final wallet = walletProvider.wallet;

    if (wallet == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${networkProvider.currentPlatform.name} Wallet'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'No ${networkProvider.currentPlatform.name} Wallet Found',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Create a new wallet or import an existing one',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show different wallet details based on the platform
    return networkProvider.currentPlatform == BlockchainPlatform.solana
        ? _buildSolanaWalletDetails(context, walletProvider, wallet as SolanaWallet)
        : _buildEthereumWalletDetails(context, walletProvider, wallet as EthereumWallet);
  }

  // Build Solana wallet details screen
  Widget _buildSolanaWalletDetails(
    BuildContext context,
    WalletProvider walletProvider,
    SolanaWallet wallet,
  ) {
    final networkProvider = Provider.of<NetworkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Solana Wallet (${networkProvider.currentSolanaNetwork.name})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Don't show back button in tabbed interface
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => walletProvider.refreshBalance(),
            tooltip: 'Refresh Balance',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => walletProvider.refreshBalance(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),

              // Balance Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      walletProvider.isLoading
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Loading balance...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                                '${wallet.balance.toStringAsFixed(6)} SOL',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      if (walletProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            walletProvider.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Public Key Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Public Key',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              wallet.publicKey,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: wallet.publicKey),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Public key copied to clipboard'),
                                ),
                              );
                            },
                            tooltip: 'Copy to Clipboard',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Mnemonic Card (Seed Phrase)
              if (wallet.mnemonic.isNotEmpty)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Seed Phrase (Mnemonic)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: wallet.mnemonic),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Seed phrase copied to clipboard'),
                                  ),
                                );
                              },
                              tooltip: 'Copy to Clipboard',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            wallet.mnemonic,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '⚠️ IMPORTANT: Never share your seed phrase with anyone. Anyone with this phrase can access your funds.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Delete Wallet Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Wallet?'),
                        content: const Text(
                          'Are you sure you want to delete this wallet? This action cannot be undone. Make sure you have backed up your seed phrase.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await walletProvider.deleteWallet();
                              if (context.mounted) {
                                Navigator.of(context).pop(); // Close the dialog
                              }
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Wallet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build Ethereum wallet details screen
  Widget _buildEthereumWalletDetails(
    BuildContext context,
    WalletProvider walletProvider,
    EthereumWallet wallet,
  ) {
    final networkProvider = Provider.of<NetworkProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ethereum Wallet (${networkProvider.currentEthereumNetwork.name})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Don't show back button in tabbed interface
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => walletProvider.refreshBalance(),
            tooltip: 'Refresh Balance',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => walletProvider.refreshBalance(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),

              // Balance Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      walletProvider.isLoading
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Loading balance...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                                '${wallet.balance.toStringAsFixed(6)} ETH',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      if (walletProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            walletProvider.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Address Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ethereum Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              wallet.address,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: wallet.address),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address copied to clipboard'),
                                ),
                              );
                            },
                            tooltip: 'Copy to Clipboard',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Private Key Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Private Key',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: wallet.privateKeyHex),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Private key copied to clipboard'),
                                ),
                              );
                            },
                            tooltip: 'Copy to Clipboard',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wallet.privateKeyHex,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '⚠️ IMPORTANT: Never share your private key with anyone. Anyone with this key can access your funds.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Mnemonic Card (Seed Phrase)
              if (wallet.mnemonic.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Seed Phrase (Mnemonic)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: wallet.mnemonic),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Seed phrase copied to clipboard'),
                                    ),
                                  );
                                },
                                tooltip: 'Copy to Clipboard',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              wallet.mnemonic,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '⚠️ IMPORTANT: Never share your seed phrase with anyone. Anyone with this phrase can access your funds.',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Delete Wallet Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Wallet?'),
                        content: const Text(
                          'Are you sure you want to delete this wallet? This action cannot be undone. Make sure you have backed up your private key and seed phrase.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await walletProvider.deleteWallet();
                              if (context.mounted) {
                                Navigator.of(context).pop(); // Close the dialog
                              }
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Wallet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
