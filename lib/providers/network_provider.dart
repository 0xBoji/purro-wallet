import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

/// Provider for managing network settings
class NetworkProvider extends ChangeNotifier {
  static const String _networkKey = 'solana_network';
  final FlutterSecureStorage _secureStorage;
  
  SolanaNetwork _currentNetwork = SolanaNetwork.devnet;
  
  NetworkProvider({FlutterSecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    // Load saved network on initialization
    _loadSavedNetwork();
  }
  
  /// Get the current network
  SolanaNetwork get currentNetwork => _currentNetwork;
  
  /// Get the current network as a string
  String get currentNetworkName => _currentNetwork.name;
  
  /// Get the current network value
  String get currentNetworkValue => _currentNetwork.value;
  
  /// Load the saved network from secure storage
  Future<void> _loadSavedNetwork() async {
    try {
      final savedNetwork = await _secureStorage.read(key: _networkKey);
      
      if (savedNetwork != null) {
        _currentNetwork = SolanaNetworkExtension.fromString(savedNetwork);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading saved network: $e');
    }
  }
  
  /// Change the current network
  Future<void> changeNetwork(SolanaNetwork network) async {
    if (_currentNetwork == network) return;
    
    _currentNetwork = network;
    
    try {
      await _secureStorage.write(
        key: _networkKey,
        value: network.value,
      );
    } catch (e) {
      print('Error saving network: $e');
    }
    
    notifyListeners();
  }
}
