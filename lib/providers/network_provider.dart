import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Enum representing the blockchain platform
enum BlockchainPlatform {
  solana,
  ethereum,
}

/// Extension to provide string values for BlockchainPlatform enum
extension BlockchainPlatformExtension on BlockchainPlatform {
  String get name {
    switch (this) {
      case BlockchainPlatform.solana:
        return 'Solana';
      case BlockchainPlatform.ethereum:
        return 'Ethereum';
    }
  }

  String get value {
    switch (this) {
      case BlockchainPlatform.solana:
        return 'solana';
      case BlockchainPlatform.ethereum:
        return 'ethereum';
    }
  }

  static BlockchainPlatform fromString(String value) {
    switch (value.toLowerCase()) {
      case 'solana':
        return BlockchainPlatform.solana;
      case 'ethereum':
        return BlockchainPlatform.ethereum;
      default:
        return BlockchainPlatform.solana; // Default to Solana
    }
  }
}

/// Enum representing the available Solana networks
enum SolanaNetwork {
  mainnet,
  devnet,
  testnet,
}

/// Extension to provide string values for SolanaNetwork enum
extension SolanaNetworkExtension on SolanaNetwork {
  String get name {
    switch (this) {
      case SolanaNetwork.mainnet:
        return 'Mainnet';
      case SolanaNetwork.devnet:
        return 'Devnet';
      case SolanaNetwork.testnet:
        return 'Testnet';
    }
  }

  String get value {
    switch (this) {
      case SolanaNetwork.mainnet:
        return 'mainnet';
      case SolanaNetwork.devnet:
        return 'devnet';
      case SolanaNetwork.testnet:
        return 'testnet';
    }
  }

  static SolanaNetwork fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mainnet':
        return SolanaNetwork.mainnet;
      case 'devnet':
        return SolanaNetwork.devnet;
      case 'testnet':
        return SolanaNetwork.testnet;
      default:
        return SolanaNetwork.devnet; // Default to devnet
    }
  }
}

/// Enum representing the available Ethereum networks
enum EthereumNetwork {
  mainnet,
  sepolia,
  base,
  arbitrum,
}

/// Extension to provide string values for EthereumNetwork enum
extension EthereumNetworkExtension on EthereumNetwork {
  String get name {
    switch (this) {
      case EthereumNetwork.mainnet:
        return 'Ethereum Mainnet';
      case EthereumNetwork.sepolia:
        return 'Sepolia Testnet';
      case EthereumNetwork.base:
        return 'Base';
      case EthereumNetwork.arbitrum:
        return 'Arbitrum';
    }
  }

  String get value {
    switch (this) {
      case EthereumNetwork.mainnet:
        return 'eth_mainnet';
      case EthereumNetwork.sepolia:
        return 'eth_sepolia';
      case EthereumNetwork.base:
        return 'base';
      case EthereumNetwork.arbitrum:
        return 'arbitrum';
    }
  }

  String get rpcUrl {
    switch (this) {
      case EthereumNetwork.mainnet:
        return 'https://eth-mainnet.public.blastapi.io';
      case EthereumNetwork.sepolia:
        return 'https://eth-sepolia.public.blastapi.io';
      case EthereumNetwork.base:
        return 'https://base-mainnet.public.blastapi.io';
      case EthereumNetwork.arbitrum:
        return 'https://arbitrum-one.public.blastapi.io';
    }
  }

  int get chainId {
    switch (this) {
      case EthereumNetwork.mainnet:
        return 1;
      case EthereumNetwork.sepolia:
        return 11155111;
      case EthereumNetwork.base:
        return 8453;
      case EthereumNetwork.arbitrum:
        return 42161;
    }
  }

  static EthereumNetwork fromString(String value) {
    switch (value.toLowerCase()) {
      case 'eth_mainnet':
        return EthereumNetwork.mainnet;
      case 'eth_sepolia':
        return EthereumNetwork.sepolia;
      case 'base':
        return EthereumNetwork.base;
      case 'arbitrum':
        return EthereumNetwork.arbitrum;
      default:
        return EthereumNetwork.sepolia; // Default to Sepolia testnet
    }
  }
}

/// Provider for managing network settings
class NetworkProvider extends ChangeNotifier {
  static const String _platformKey = 'blockchain_platform';
  static const String _solanaNetworkKey = 'solana_network';
  static const String _ethereumNetworkKey = 'ethereum_network';

  final FlutterSecureStorage _secureStorage;

  BlockchainPlatform _currentPlatform = BlockchainPlatform.solana;
  SolanaNetwork _currentSolanaNetwork = SolanaNetwork.devnet;
  EthereumNetwork _currentEthereumNetwork = EthereumNetwork.sepolia;

  NetworkProvider({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    // Load saved network settings on initialization
    _loadSavedNetworkSettings();
  }

  /// Get the current blockchain platform
  BlockchainPlatform get currentPlatform => _currentPlatform;

  /// Get the current Solana network
  SolanaNetwork get currentSolanaNetwork => _currentSolanaNetwork;

  /// Get the current Ethereum network
  EthereumNetwork get currentEthereumNetwork => _currentEthereumNetwork;

  /// Get the current network name based on the platform
  String get currentNetworkName {
    switch (_currentPlatform) {
      case BlockchainPlatform.solana:
        return _currentSolanaNetwork.name;
      case BlockchainPlatform.ethereum:
        return _currentEthereumNetwork.name;
    }
  }

  /// Get the current network value based on the platform
  String get currentNetworkValue {
    switch (_currentPlatform) {
      case BlockchainPlatform.solana:
        return _currentSolanaNetwork.value;
      case BlockchainPlatform.ethereum:
        return _currentEthereumNetwork.value;
    }
  }

  /// Load the saved network settings from secure storage
  Future<void> _loadSavedNetworkSettings() async {
    try {
      final savedPlatform = await _secureStorage.read(key: _platformKey);
      final savedSolanaNetwork = await _secureStorage.read(key: _solanaNetworkKey);
      final savedEthereumNetwork = await _secureStorage.read(key: _ethereumNetworkKey);

      if (savedPlatform != null) {
        _currentPlatform = BlockchainPlatformExtension.fromString(savedPlatform);
      }

      if (savedSolanaNetwork != null) {
        _currentSolanaNetwork = SolanaNetworkExtension.fromString(savedSolanaNetwork);
      }

      if (savedEthereumNetwork != null) {
        _currentEthereumNetwork = EthereumNetworkExtension.fromString(savedEthereumNetwork);
      }

      notifyListeners();
    } catch (e) {
      print('Error loading saved network settings: $e');
    }
  }

  /// Change the current blockchain platform
  Future<void> changePlatform(BlockchainPlatform platform) async {
    if (_currentPlatform == platform) return;

    _currentPlatform = platform;

    try {
      await _secureStorage.write(
        key: _platformKey,
        value: platform.value,
      );
    } catch (e) {
      print('Error saving platform: $e');
    }

    notifyListeners();
  }

  /// Change the current Solana network
  Future<void> changeSolanaNetwork(SolanaNetwork network) async {
    if (_currentSolanaNetwork == network) return;

    _currentSolanaNetwork = network;

    try {
      await _secureStorage.write(
        key: _solanaNetworkKey,
        value: network.value,
      );
    } catch (e) {
      print('Error saving Solana network: $e');
    }

    notifyListeners();
  }

  /// Change the current Ethereum network
  Future<void> changeEthereumNetwork(EthereumNetwork network) async {
    if (_currentEthereumNetwork == network) return;

    _currentEthereumNetwork = network;

    try {
      await _secureStorage.write(
        key: _ethereumNetworkKey,
        value: network.value,
      );
    } catch (e) {
      print('Error saving Ethereum network: $e');
    }

    notifyListeners();
  }
}
