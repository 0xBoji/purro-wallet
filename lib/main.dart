import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/network_provider.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider for managing user authentication
        ChangeNotifierProvider(
          create: (context) => AuthService(),
        ),

        // Network provider for managing blockchain and network settings
        ChangeNotifierProvider(
          create: (context) => NetworkProvider(),
        ),

        // Wallet provider that depends on the network provider
        ChangeNotifierProxyProvider<NetworkProvider, WalletProvider>(
          create: (context) {
            final networkProvider = Provider.of<NetworkProvider>(context, listen: false);
            return WalletProvider(
              networkProvider: networkProvider,
            );
          },
          update: (context, networkProvider, previous) => previous!,
        ),
      ],
      child: MaterialApp(
        title: 'Purro Wallet',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            // Check if user is logged in
            return authService.isLoggedIn ? const MainScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
