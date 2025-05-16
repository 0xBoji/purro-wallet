import 'dart:convert';
import 'dart:typed_data';

import 'package:bs58/bs58.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:solana/solana.dart';
import '../models/solana_wallet.dart';
import '../providers/network_provider.dart';

/// Service for managing Solana wallet operations
class WalletService {
  static const String _mnemonicKey = 'solana_wallet_mnemonic';
  static const String _privateKeyKey = 'solana_wallet_private_key';

  final FlutterSecureStorage _secureStorage;
  SolanaClient _solanaClient;
  NetworkProvider? _networkProvider;

  // Define network endpoints - using public RPC endpoints that allow CORS
  static const Map<String, Map<String, String>> _networks = {
    'mainnet': {
      'rpc': 'https://free.rpcpool.com',
      'ws': 'wss://free.rpcpool.com',
    },
    'devnet': {
      'rpc': 'https://api.devnet.solana.com',
      'ws': 'wss://api.devnet.solana.com',
    },
    'testnet': {
      'rpc': 'https://api.testnet.solana.com',
      'ws': 'wss://api.testnet.solana.com',
    },
  };

  // Default to devnet for testing
  static const String _defaultNetwork = 'devnet';

  WalletService({
    FlutterSecureStorage? secureStorage,
    SolanaClient? solanaClient,
    NetworkProvider? networkProvider,
    String network = _defaultNetwork,
  }) :
    _secureStorage = secureStorage ?? const FlutterSecureStorage(),
    _solanaClient = solanaClient ?? SolanaClient(
      rpcUrl: Uri.parse(_networks[network]?['rpc'] ?? _networks[_defaultNetwork]!['rpc']!),
      websocketUrl: Uri.parse(_networks[network]?['ws'] ?? _networks[_defaultNetwork]!['ws']!),
    ),
    _networkProvider = networkProvider {
      // Listen for network changes if provider is available
      _networkProvider?.addListener(_onNetworkChanged);
    }

  /// Handle network changes
  void _onNetworkChanged() {
    if (_networkProvider != null) {
      final networkValue = _networkProvider!.currentNetworkValue;

      // Update the Solana client with the new network
      _solanaClient = SolanaClient(
        rpcUrl: Uri.parse(_networks[networkValue]?['rpc'] ?? _networks[_defaultNetwork]!['rpc']!),
        websocketUrl: Uri.parse(_networks[networkValue]?['ws'] ?? _networks[_defaultNetwork]!['ws']!),
      );

      print('Network changed to: $networkValue');
    }
  }

  /// Dispose of resources
  void dispose() {
    _networkProvider?.removeListener(_onNetworkChanged);
  }

  /// Create a new wallet and store it securely
  Future<SolanaWallet> createWallet() async {
    // Create a new wallet
    final wallet = await SolanaWallet.create();

    // Store the mnemonic securely
    await _secureStorage.write(
      key: _mnemonicKey,
      value: wallet.mnemonic,
    );

    // For now, we'll just store the mnemonic
    // The private key is derived from the mnemonic when needed

    return wallet;
  }

  /// Import a wallet from a seed phrase (mnemonic) and store it securely
  Future<SolanaWallet> importWalletFromMnemonic(String mnemonic) async {
    // Create a wallet from the mnemonic
    final wallet = await SolanaWallet.fromMnemonic(mnemonic);

    // Store the mnemonic securely
    await _secureStorage.write(
      key: _mnemonicKey,
      value: mnemonic,
    );

    return wallet;
  }

  /// Import a wallet from a private key and store it securely
  Future<SolanaWallet> importWalletFromPrivateKey(String privateKey) async {
    try {
      Uint8List privateKeyBytes;

      // Check if the private key is in Base58 format (like Solana private keys)
      if (privateKey.length >= 40 && privateKey.length <= 90) {
        try {
          // Try to decode as Base58
          privateKeyBytes = base58.decode(privateKey);

          // Solana private keys are typically 64 bytes, where the first 32 bytes
          // are the private key and the last 32 bytes are the public key
          if (privateKeyBytes.length >= 32) {
            // Extract just the private key part (first 32 bytes)
            privateKeyBytes = privateKeyBytes.sublist(0, 32);
          }
        } catch (e) {
          print('Not a valid Base58 key, trying hex format: $e');
          // If Base58 decoding fails, continue to try hex format
          privateKeyBytes = _hexToBytes(privateKey);
        }
      } else {
        // Try to parse as hex
        privateKeyBytes = _hexToBytes(privateKey);
      }

      // Create a wallet from the private key
      final wallet = await SolanaWallet.fromPrivateKey(privateKeyBytes);

      // Since we don't have a mnemonic for private key imports, we'll store the private key
      await _secureStorage.write(
        key: _privateKeyKey,
        value: privateKey, // Store the original format
      );

      return wallet;
    } catch (e) {
      throw Exception('Invalid private key: ${e.toString()}');
    }
  }

  /// Helper method to convert hex string to bytes
  Uint8List _hexToBytes(String hex) {
    // Normalize the private key (remove 0x prefix if present)
    if (hex.toLowerCase().startsWith('0x')) {
      hex = hex.substring(2);
    }

    // Ensure the private key is the correct length (32 bytes = 64 hex chars)
    if (hex.length != 64) {
      throw Exception('Hex private key must be 64 characters long (32 bytes)');
    }

    // Check if it's a valid hex string
    final hexRegExp = RegExp(r'^[0-9a-fA-F]+$');
    if (!hexRegExp.hasMatch(hex)) {
      throw Exception('Not a valid hexadecimal string');
    }

    // Convert hex string to Uint8List
    return Uint8List.fromList(
      List<int>.generate(hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)
      )
    );
  }

  /// Load the wallet from secure storage
  Future<SolanaWallet?> loadWallet() async {
    try {
      // Try to load the mnemonic
      final mnemonic = await _secureStorage.read(key: _mnemonicKey);

      if (mnemonic != null) {
        // If we have a mnemonic, create the wallet from it
        return await SolanaWallet.fromMnemonic(mnemonic);
      }

      // If no mnemonic, try to load from private key
      final privateKey = await _secureStorage.read(key: _privateKeyKey);
      if (privateKey != null) {
        try {
          // Try to import using the same method as importWalletFromPrivateKey
          return await importWalletFromPrivateKey(privateKey);
        } catch (e) {
          print('Error loading wallet from private key: $e');
          // Delete the invalid private key
          await _secureStorage.delete(key: _privateKeyKey);
        }
      }

      // No wallet found
      return null;
    } catch (e) {
      print('Error loading wallet: $e');
      return null;
    }
  }

  /// Check if a wallet exists in secure storage
  Future<bool> hasWallet() async {
    final mnemonic = await _secureStorage.read(key: _mnemonicKey);
    final privateKey = await _secureStorage.read(key: _privateKeyKey);
    return mnemonic != null || privateKey != null;
  }

  /// Delete the wallet from secure storage
  Future<void> deleteWallet() async {
    await _secureStorage.delete(key: _mnemonicKey);
    await _secureStorage.delete(key: _privateKeyKey);
  }

  /// Get the balance of the wallet
  Future<double> getBalance(SolanaWallet wallet) async {
    try {
      print('Fetching balance for address: ${wallet.publicKey}');

      // Ensure we have a valid public key
      if (wallet.publicKey.isEmpty) {
        print('Error: Empty public key');
        return 0.0;
      }

      // Use the standard method to get balance
      final balanceResult = await _solanaClient.rpcClient.getBalance(
        wallet.publicKey,
        commitment: Commitment.confirmed,
      );

      // Convert lamports to SOL (1 SOL = 1,000,000,000 lamports)
      final solBalance = balanceResult.value / 1000000000;

      // Update the wallet's balance
      wallet.balance = solBalance;

      print('Balance in SOL: $solBalance');
      return solBalance;
    } catch (e) {
      print('Error getting balance: $e');
      return 0.0;
    }
  }
}
