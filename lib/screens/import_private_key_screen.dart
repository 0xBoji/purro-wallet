import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';

class ImportPrivateKeyScreen extends StatefulWidget {
  const ImportPrivateKeyScreen({Key? key}) : super(key: key);

  @override
  State<ImportPrivateKeyScreen> createState() => _ImportPrivateKeyScreenState();
}

class _ImportPrivateKeyScreenState extends State<ImportPrivateKeyScreen> {
  final _privateKeyController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Private Key'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.key,
              size: 60,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            const Text(
              'Import Wallet from Private Key',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your Solana private key to restore your wallet. Both Base58 and hexadecimal formats are supported.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _isObscured
              ? TextField(
                  controller: _privateKeyController,
                  decoration: InputDecoration(
                    labelText: 'Private Key',
                    hintText: 'Enter your private key (Base58 or hex format)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscured = false;
                        });
                      },
                    ),
                    errorText: walletProvider.error,
                  ),
                  obscureText: true,
                )
              : TextField(
                  controller: _privateKeyController,
                  decoration: InputDecoration(
                    labelText: 'Private Key',
                    hintText: 'Enter your private key (Base58 or hex format)',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isObscured = true;
                        });
                      },
                    ),
                    errorText: walletProvider.error,
                  ),
                ),
            const SizedBox(height: 30),
            if (walletProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: () async {
                  final privateKey = _privateKeyController.text.trim();

                  // Basic validation
                  if (privateKey.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your private key'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await walletProvider.importWalletFromPrivateKey(privateKey);

                    if (walletProvider.wallet != null && context.mounted) {
                      // Go back to the import options screen
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Import Wallet',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              '⚠️ Never share your private key with anyone. Anyone with this key can access your funds.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
