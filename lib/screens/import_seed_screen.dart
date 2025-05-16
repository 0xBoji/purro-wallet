import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';

class ImportSeedScreen extends StatefulWidget {
  const ImportSeedScreen({Key? key}) : super(key: key);

  @override
  State<ImportSeedScreen> createState() => _ImportSeedScreenState();
}

class _ImportSeedScreenState extends State<ImportSeedScreen> {
  final _seedController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Seed Phrase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.vpn_key_rounded,
              size: 60,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            const Text(
              'Import Wallet from Seed Phrase',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your 12 or 24-word seed phrase to restore your wallet.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _isObscured
              ? TextField(
                  controller: _seedController,
                  decoration: InputDecoration(
                    labelText: 'Seed Phrase',
                    hintText: 'Enter your seed phrase',
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
                  controller: _seedController,
                  decoration: InputDecoration(
                    labelText: 'Seed Phrase',
                    hintText: 'Enter your seed phrase words separated by spaces',
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
                  maxLines: 3,
                ),
            const SizedBox(height: 30),
            if (walletProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: () async {
                  final seedPhrase = _seedController.text.trim();

                  // Basic validation
                  final wordCount = seedPhrase.split(' ').length;
                  if (seedPhrase.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your seed phrase'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (wordCount != 12 && wordCount != 24) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Seed phrase must be 12 or 24 words'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await walletProvider.importWalletFromMnemonic(seedPhrase);

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
              '⚠️ Never share your seed phrase with anyone. Anyone with this phrase can access your funds.',
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
