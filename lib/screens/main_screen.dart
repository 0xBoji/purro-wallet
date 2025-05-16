import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../services/auth_service.dart';
import 'wallet_details_screen.dart';
import 'create_wallet_screen.dart';
import 'import_options_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final authService = Provider.of<AuthService>(context);

    // Show loading indicator while checking for existing wallet
    if (walletProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Purro Wallet'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // User info and logout button
            _buildUserMenu(context, authService),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Define the screens for each tab
    final List<Widget> screens = [
      // Wallet Tab
      walletProvider.hasWallet
          ? const WalletDetailsScreen()
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No Wallet Found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
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

      // Create Tab
      const CreateWalletScreen(),

      // Import Tab
      const ImportOptionsScreen(),

      // Settings Tab
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: _selectedIndex == 0 && !walletProvider.hasWallet ?
        AppBar(
          title: const Text('Purro Wallet'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false,
          actions: [
            // User info and logout button
            _buildUserMenu(context, authService),
          ],
        ) : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Important for 4+ items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Import',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, AuthService authService) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle),
      onSelected: (value) async {
        if (value == 'logout') {
          // Show confirmation dialog
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

          if (shouldLogout == true) {
            await authService.logout();

            if (context.mounted) {
              // Navigate to login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          }
        }
      },
      itemBuilder: (context) => [
        // User info
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authService.userName ?? 'User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (authService.userEmail != null)
                Text(
                  authService.userEmail!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Logout option
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );
  }
}
