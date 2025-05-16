import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';
import '../providers/wallet_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // Don't show back button in tabbed interface
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          // Network Settings Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Network Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Network Selection Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Network',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Choose which Solana network to connect to',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Network Radio Buttons
                  _buildNetworkRadio(
                    context, 
                    networkProvider, 
                    SolanaNetwork.mainnet,
                    walletProvider,
                  ),
                  const Divider(),
                  _buildNetworkRadio(
                    context, 
                    networkProvider, 
                    SolanaNetwork.devnet,
                    walletProvider,
                  ),
                  const Divider(),
                  _buildNetworkRadio(
                    context, 
                    networkProvider, 
                    SolanaNetwork.testnet,
                    walletProvider,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // App Info Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'App Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // App Version Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('App Version'),
              subtitle: Text('1.0.0'),
            ),
          ),
          
          // About Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('About'),
              subtitle: Text('Solana Wallet App'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNetworkRadio(
    BuildContext context, 
    NetworkProvider networkProvider, 
    SolanaNetwork network,
    WalletProvider walletProvider,
  ) {
    return RadioListTile<SolanaNetwork>(
      title: Text(network.name),
      value: network,
      groupValue: networkProvider.currentNetwork,
      onChanged: (SolanaNetwork? value) async {
        if (value != null) {
          // Show confirmation dialog if wallet exists
          if (walletProvider.hasWallet && 
              networkProvider.currentNetwork != value) {
            final shouldChange = await _showNetworkChangeConfirmation(
              context, 
              network.name,
            );
            
            if (shouldChange) {
              await networkProvider.changeNetwork(value);
              
              // Refresh wallet balance with new network
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Network changed to ${value.name}'),
                  ),
                );
                
                // Refresh balance with new network
                walletProvider.refreshBalance();
              }
            }
          } else {
            // No wallet or same network, just change
            await networkProvider.changeNetwork(value);
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Network changed to ${value.name}'),
                ),
              );
            }
          }
        }
      },
      subtitle: Text(_getNetworkDescription(network)),
      activeColor: Colors.deepPurple,
    );
  }
  
  String _getNetworkDescription(SolanaNetwork network) {
    switch (network) {
      case SolanaNetwork.mainnet:
        return 'Main Solana network with real SOL';
      case SolanaNetwork.devnet:
        return 'Development network with test SOL';
      case SolanaNetwork.testnet:
        return 'Test network for developers';
    }
  }
  
  Future<bool> _showNetworkChangeConfirmation(
    BuildContext context, 
    String networkName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Network?'),
        content: Text(
          'Changing networks will update your wallet to use $networkName. '
          'Your balance and transaction history may be different on this network.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Change Network'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
