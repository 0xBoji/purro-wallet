import 'package:flutter/foundation.dart';
import '../models/solana_wallet.dart';
import '../models/ethereum_wallet.dart';
import '../services/wallet_service.dart';
import '../services/ethereum_wallet_service.dart';
import 'network_provider.dart';

/// Provider for managing wallet state throughout the app
class WalletProvider extends ChangeNotifier {
  final WalletService _solanaWalletService;
  final EthereumWalletService _ethereumWalletService;
  final NetworkProvider _networkProvider;

  SolanaWallet? _solanaWallet;
  EthereumWallet? _ethereumWallet;
  bool _isLoading = false;
  String? _error;

  WalletProvider({
    WalletService? solanaWalletService,
    EthereumWalletService? ethereumWalletService,
    required NetworkProvider networkProvider,
  }) :
    _solanaWalletService = solanaWalletService ?? WalletService(
      networkProvider: networkProvider,
    ),
    _ethereumWalletService = ethereumWalletService ?? EthereumWalletService(
      networkProvider: networkProvider,
    ),
    _networkProvider = networkProvider {
    // Load wallet on initialization
    _loadWallet();

    // Listen for network changes
    _networkProvider.addListener(_onNetworkChanged);
  }

  /// Get the current wallet based on the selected platform
  dynamic get wallet {
    switch (_networkProvider.currentPlatform) {
      case BlockchainPlatform.solana:
        return _solanaWallet;
      case BlockchainPlatform.ethereum:
        return _ethereumWallet;
    }
  }

  /// Get the Solana wallet
  SolanaWallet? get solanaWallet => _solanaWallet;

  /// Get the Ethereum wallet
  EthereumWallet? get ethereumWallet => _ethereumWallet;

  /// Check if the wallet is loading
  bool get isLoading => _isLoading;

  /// Get any error message
  String? get error => _error;

  /// Check if a wallet exists for the current platform
  bool get hasWallet {
    switch (_networkProvider.currentPlatform) {
      case BlockchainPlatform.solana:
        return _solanaWallet != null;
      case BlockchainPlatform.ethereum:
        return _ethereumWallet != null;
    }
  }

  /// Handle network changes
  void _onNetworkChanged() {
    // Refresh the wallet balance when the network changes
    refreshBalance();
  }

  /// Load the wallet from secure storage
  Future<void> _loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load Solana wallet
      final hasSolanaWallet = await _solanaWalletService.hasWallet();
      if (hasSolanaWallet) {
        _solanaWallet = await _solanaWalletService.loadWallet();
      }

      // Load Ethereum wallet
      final hasEthereumWallet = await _ethereumWalletService.hasWallet();
      if (hasEthereumWallet) {
        _ethereumWallet = await _ethereumWalletService.loadWallet();
      }

      // Refresh balance for the current platform
      await refreshBalance();
    } catch (e) {
      _error = 'Failed to load wallet: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new wallet for the current platform
  Future<void> createWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (_networkProvider.currentPlatform) {
        case BlockchainPlatform.solana:
          _solanaWallet = await _solanaWalletService.createWallet();
          break;
        case BlockchainPlatform.ethereum:
          _ethereumWallet = await _ethereumWalletService.createWallet();
          break;
      }

      // Get the initial balance
      await refreshBalance();
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
      switch (_networkProvider.currentPlatform) {
        case BlockchainPlatform.solana:
          _solanaWallet = await _solanaWalletService.importWalletFromMnemonic(mnemonic);
          break;
        case BlockchainPlatform.ethereum:
          _ethereumWallet = await _ethereumWalletService.importWalletFromMnemonic(mnemonic);
          break;
      }

      // Get the initial balance
      await refreshBalance();
    } catch (e) {
      _error = 'Failed to import wallet: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Import a wallet from a private key
  Future<void> importWalletFromPrivateKey(String privateKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (_networkProvider.currentPlatform) {
        case BlockchainPlatform.solana:
          _solanaWallet = await _solanaWalletService.importWalletFromPrivateKey(privateKey);
          break;
        case BlockchainPlatform.ethereum:
          _ethereumWallet = await _ethereumWalletService.importWalletFromPrivateKey(privateKey);
          break;
      }

      // Get the initial balance
      await refreshBalance();
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
    if (!hasWallet) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (_networkProvider.currentPlatform) {
        case BlockchainPlatform.solana:
          if (_solanaWallet != null) {
            await _solanaWalletService.getBalance(_solanaWallet!);
          }
          break;
        case BlockchainPlatform.ethereum:
          if (_ethereumWallet != null) {
            await _ethereumWalletService.getBalance(_ethereumWallet!);
          }
          break;
      }
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
    _error = null;
    notifyListeners();

    try {
      switch (_networkProvider.currentPlatform) {
        case BlockchainPlatform.solana:
          await _solanaWalletService.deleteWallet();
          _solanaWallet = null;
          break;
        case BlockchainPlatform.ethereum:
          await _ethereumWalletService.deleteWallet();
          _ethereumWallet = null;
          break;
      }
    } catch (e) {
      _error = 'Failed to delete wallet: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _networkProvider.removeListener(_onNetworkChanged);
    super.dispose();
  }
}
