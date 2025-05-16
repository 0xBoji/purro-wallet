import 'package:flutter/foundation.dart';
import '../models/solana_wallet.dart';
import '../services/wallet_service.dart';
import 'network_provider.dart';

/// Provider for managing wallet state throughout the app
class WalletProvider extends ChangeNotifier {
  final WalletService _walletService;

  SolanaWallet? _wallet;
  bool _isLoading = false;
  String? _error;

  WalletProvider({
    WalletService? walletService,
    NetworkProvider? networkProvider,
  }) : _walletService = walletService ?? WalletService(
         networkProvider: networkProvider,
       ) {
    // Load wallet on initialization
    _loadWallet();
  }

  /// Get the current wallet
  SolanaWallet? get wallet => _wallet;

  /// Check if the wallet is loading
  bool get isLoading => _isLoading;

  /// Get any error message
  String? get error => _error;

  /// Check if a wallet exists
  bool get hasWallet => _wallet != null;

  /// Load the wallet from secure storage
  Future<void> _loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hasWallet = await _walletService.hasWallet();

      if (hasWallet) {
        _wallet = await _walletService.loadWallet();

        if (_wallet != null) {
          // Get the wallet balance
          await refreshBalance();
        }
      }
    } catch (e) {
      _error = 'Failed to load wallet: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new wallet
  Future<void> createWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallet = await _walletService.createWallet();

      if (_wallet != null) {
        // Get the initial balance
        await refreshBalance();
      }
    } catch (e) {
      _error = 'Failed to create wallet: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Import a wallet from a seed phrase (mnemonic)
  Future<void> importWalletFromMnemonic(String mnemonic) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallet = await _walletService.importWalletFromMnemonic(mnemonic);

      if (_wallet != null) {
        // Get the initial balance
        await refreshBalance();
      }
    } catch (e) {
      _error = 'Failed to import wallet: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Import a wallet from a private key
  Future<void> importWalletFromPrivateKey(String privateKeyHex) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallet = await _walletService.importWalletFromPrivateKey(privateKeyHex);

      if (_wallet != null) {
        // Get the initial balance
        await refreshBalance();
      }
    } catch (e) {
      _error = 'Failed to import wallet: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the wallet balance
  Future<void> refreshBalance() async {
    if (_wallet == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Refreshing balance for wallet: ${_wallet!.publicKey}');
      final balance = await _walletService.getBalance(_wallet!);
      print('Updated balance: $balance SOL');
    } catch (e) {
      print('Error refreshing balance: $e');

      // Check if it's a CORS error
      if (e.toString().contains('XMLHttpRequest error') ||
          e.toString().contains('Access forbidden')) {
        _error = 'Network access restricted in browser. This is a CORS limitation.';
      } else {
        _error = 'Failed to refresh balance. Please try again later.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete the wallet
  Future<void> deleteWallet() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _walletService.deleteWallet();
      _wallet = null;
    } catch (e) {
      _error = 'Failed to delete wallet: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
