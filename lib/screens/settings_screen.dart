import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';
import '../providers/wallet_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

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

          // Blockchain Platform Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Blockchain Platform',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Blockchain Platform Selection Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Blockchain',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Choose which blockchain platform to use',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Blockchain Platform Radio Buttons
                  _buildBlockchainRadio(
                    context,
                    networkProvider,
                    BlockchainPlatform.solana,
                    walletProvider,
                  ),
                  const Divider(),
                  _buildBlockchainRadio(
                    context,
                    networkProvider,
                    BlockchainPlatform.ethereum,
                    walletProvider,
                  ),
                ],
              ),
            ),
          ),

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

          // Show different network options based on selected blockchain
          networkProvider.currentPlatform == BlockchainPlatform.solana
              ? _buildSolanaNetworkCard(context, networkProvider, walletProvider)
              : _buildEthereumNetworkCard(context, networkProvider, walletProvider),

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
              subtitle: Text('Purro Multi-Chain Wallet'),
            ),
          ),

          const SizedBox(height: 20),

          // Account Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // User Info Card
          _buildUserInfoCard(context),

          // Logout Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              subtitle: const Text('Sign out of your account'),
              onTap: () => _showLogoutConfirmation(context),
            ),
          ),
        ],
      ),
    );
  }

  // Build the Solana network selection card
  Widget _buildSolanaNetworkCard(
    BuildContext context,
    NetworkProvider networkProvider,
    WalletProvider walletProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Solana Network',
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

            // Solana Network Radio Buttons
            _buildSolanaNetworkRadio(
              context,
              networkProvider,
              SolanaNetwork.mainnet,
              walletProvider,
            ),
            const Divider(),
            _buildSolanaNetworkRadio(
              context,
              networkProvider,
              SolanaNetwork.devnet,
              walletProvider,
            ),
            const Divider(),
            _buildSolanaNetworkRadio(
              context,
              networkProvider,
              SolanaNetwork.testnet,
              walletProvider,
            ),
          ],
        ),
      ),
    );
  }

  // Build the Ethereum network selection card
  Widget _buildEthereumNetworkCard(
    BuildContext context,
    NetworkProvider networkProvider,
    WalletProvider walletProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Ethereum Network',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Choose which Ethereum network to connect to',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 15),

            // Ethereum Network Radio Buttons
            _buildEthereumNetworkRadio(
              context,
              networkProvider,
              EthereumNetwork.mainnet,
              walletProvider,
            ),
            const Divider(),
            _buildEthereumNetworkRadio(
              context,
              networkProvider,
              EthereumNetwork.sepolia,
              walletProvider,
            ),
            const Divider(),
            _buildEthereumNetworkRadio(
              context,
              networkProvider,
              EthereumNetwork.base,
              walletProvider,
            ),
            const Divider(),
            _buildEthereumNetworkRadio(
              context,
              networkProvider,
              EthereumNetwork.arbitrum,
              walletProvider,
            ),
          ],
        ),
      ),
    );
  }

  // Build a blockchain platform radio button
  Widget _buildBlockchainRadio(
    BuildContext context,
    NetworkProvider networkProvider,
    BlockchainPlatform platform,
    WalletProvider walletProvider,
  ) {
    return RadioListTile<BlockchainPlatform>(
      title: Text(platform.name),
      value: platform,
      groupValue: networkProvider.currentPlatform,
      onChanged: (BlockchainPlatform? value) async {
        if (value != null && networkProvider.currentPlatform != value) {
          // Show confirmation dialog if wallet exists
          if (walletProvider.hasWallet) {
            final shouldChange = await _showPlatformChangeConfirmation(
              context,
              value.name,
            );

            if (shouldChange) {
              await networkProvider.changePlatform(value);

              // Refresh wallet balance with new platform
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Platform changed to ${value.name}'),
                  ),
                );

                // Refresh balance with new platform
                walletProvider.refreshBalance();
              }
            }
          } else {
            // No wallet, just change
            await networkProvider.changePlatform(value);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Platform changed to ${value.name}'),
                ),
              );
            }
          }
        }
      },
      subtitle: Text(_getBlockchainDescription(platform)),
      activeColor: Colors.deepPurple,
    );
  }

  // Build a Solana network radio button
  Widget _buildSolanaNetworkRadio(
    BuildContext context,
    NetworkProvider networkProvider,
    SolanaNetwork network,
    WalletProvider walletProvider,
  ) {
    return RadioListTile<SolanaNetwork>(
      title: Text(network.name),
      value: network,
      groupValue: networkProvider.currentSolanaNetwork,
      onChanged: (SolanaNetwork? value) async {
        if (value != null && networkProvider.currentSolanaNetwork != value) {
          // Show confirmation dialog if wallet exists
          if (walletProvider.solanaWallet != null) {
            final shouldChange = await _showNetworkChangeConfirmation(
              context,
              network.name,
            );

            if (shouldChange) {
              await networkProvider.changeSolanaNetwork(value);

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
            // No wallet, just change
            await networkProvider.changeSolanaNetwork(value);

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
      subtitle: Text(_getSolanaNetworkDescription(network)),
      activeColor: Colors.deepPurple,
    );
  }

  // Build an Ethereum network radio button
  Widget _buildEthereumNetworkRadio(
    BuildContext context,
    NetworkProvider networkProvider,
    EthereumNetwork network,
    WalletProvider walletProvider,
  ) {
    return RadioListTile<EthereumNetwork>(
      title: Text(network.name),
      value: network,
      groupValue: networkProvider.currentEthereumNetwork,
      onChanged: (EthereumNetwork? value) async {
        if (value != null && networkProvider.currentEthereumNetwork != value) {
          // Show confirmation dialog if wallet exists
          if (walletProvider.ethereumWallet != null) {
            final shouldChange = await _showNetworkChangeConfirmation(
              context,
              network.name,
            );

            if (shouldChange) {
              await networkProvider.changeEthereumNetwork(value);

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
            // No wallet, just change
            await networkProvider.changeEthereumNetwork(value);

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
      subtitle: Text(_getEthereumNetworkDescription(network)),
      activeColor: Colors.deepPurple,
    );
  }

  // Get description for blockchain platform
  String _getBlockchainDescription(BlockchainPlatform platform) {
    switch (platform) {
      case BlockchainPlatform.solana:
        return 'Fast, secure, and scalable blockchain';
      case BlockchainPlatform.ethereum:
        return 'Decentralized platform for smart contracts';
    }
  }

  // Get description for Solana network
  String _getSolanaNetworkDescription(SolanaNetwork network) {
    switch (network) {
      case SolanaNetwork.mainnet:
        return 'Main Solana network with real SOL';
      case SolanaNetwork.devnet:
        return 'Development network with test SOL';
      case SolanaNetwork.testnet:
        return 'Test network for developers';
    }
  }

  // Get description for Ethereum network
  String _getEthereumNetworkDescription(EthereumNetwork network) {
    switch (network) {
      case EthereumNetwork.mainnet:
        return 'Main Ethereum network with real ETH';
      case EthereumNetwork.sepolia:
        return 'Ethereum testnet for developers';
      case EthereumNetwork.base:
        return 'Layer 2 scaling solution for Ethereum';
      case EthereumNetwork.arbitrum:
        return 'Layer 2 scaling solution with low fees';
    }
  }

  // Show confirmation dialog for network change
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

  // Show confirmation dialog for platform change
  Future<bool> _showPlatformChangeConfirmation(
    BuildContext context,
    String platformName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Blockchain Platform?'),
        content: Text(
          'Changing to $platformName will switch your active wallet. '
          'You will need to create or import a wallet for this platform if you haven\'t already.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Change Platform'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // Show logout confirmation dialog
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access your wallets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();

      if (context.mounted) {
        // Navigate to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  // Build user info card
  Widget _buildUserInfoCard(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authService.userName ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (authService.userEmail != null)
                        Text(
                          authService.userEmail!,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
