import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../models/ethereum_wallet.dart';
import '../providers/network_provider.dart';

/// Service for managing Ethereum wallet operations
class EthereumWalletService {
  static const String _mnemonicKey = 'ethereum_wallet_mnemonic';
  static const String _privateKeyKey = 'ethereum_wallet_private_key';
  
  final FlutterSecureStorage _secureStorage;
  Web3Client? _web3Client;
  NetworkProvider? _networkProvider;
  
  EthereumWalletService({
    FlutterSecureStorage? secureStorage,
    Web3Client? web3Client,
    NetworkProvider? networkProvider,
  }) : 
    _secureStorage = secureStorage ?? const FlutterSecureStorage(),
    _web3Client = web3Client,
    _networkProvider = networkProvider {
      // Initialize Web3Client if not provided
      _initializeWeb3Client();
      
      // Listen for network changes if provider is available
      _networkProvider?.addListener(_onNetworkChanged);
    }
  
  /// Initialize the Web3Client with the current network
  void _initializeWeb3Client() {
    if (_networkProvider != null) {
      final rpcUrl = _networkProvider!.currentEthereumNetwork.rpcUrl;
      _web3Client = Web3Client(rpcUrl, http.Client());
      print('Initialized Ethereum client with RPC URL: $rpcUrl');
    } else {
      // Default to Sepolia testnet if no network provider
      _web3Client = Web3Client(
        'https://eth-sepolia.public.blastapi.io',
        http.Client(),
      );
    }
  }
  
  /// Handle network changes
  void _onNetworkChanged() {
    if (_networkProvider != null && 
        _networkProvider!.currentPlatform == BlockchainPlatform.ethereum) {
      // Update the Web3Client with the new network
      final rpcUrl = _networkProvider!.currentEthereumNetwork.rpcUrl;
      _web3Client?.dispose();
      _web3Client = Web3Client(rpcUrl, http.Client());
      print('Network changed to: ${_networkProvider!.currentEthereumNetwork.name}');
    }
  }
  
  /// Dispose of resources
  void dispose() {
    _web3Client?.dispose();
    _networkProvider?.removeListener(_onNetworkChanged);
  }
  
  /// Create a new wallet and store it securely
  Future<EthereumWallet> createWallet() async {
    // Create a new wallet
    final wallet = await EthereumWallet.create();
    
    // Store the mnemonic securely
    await _secureStorage.write(
      key: _mnemonicKey,
      value: wallet.mnemonic,
    );
    
    // Store the private key securely
    await _secureStorage.write(
      key: _privateKeyKey,
      value: wallet.privateKeyHex,
    );
    
    return wallet;
  }
  
  /// Import a wallet from a seed phrase (mnemonic) and store it securely
  Future<EthereumWallet> importWalletFromMnemonic(String mnemonic) async {
    // Create a wallet from the mnemonic
    final wallet = await EthereumWallet.fromMnemonic(mnemonic);
    
    // Store the mnemonic securely
    await _secureStorage.write(
      key: _mnemonicKey,
      value: mnemonic,
    );
    
    // Store the private key securely
    await _secureStorage.write(
      key: _privateKeyKey,
      value: wallet.privateKeyHex,
    );
    
    return wallet;
  }
  
  /// Import a wallet from a private key and store it securely
  Future<EthereumWallet> importWalletFromPrivateKey(String privateKeyHex) async {
    try {
      // Create a wallet from the private key
      final wallet = await EthereumWallet.fromPrivateKey(privateKeyHex);
      
      // Store the private key securely
      await _secureStorage.write(
        key: _privateKeyKey,
        value: wallet.privateKeyHex,
      );
      
      return wallet;
    } catch (e) {
      throw Exception('Invalid private key: ${e.toString()}');
    }
  }
  
  /// Load the wallet from secure storage
  Future<EthereumWallet?> loadWallet() async {
    try {
      // Try to load the mnemonic
      final mnemonic = await _secureStorage.read(key: _mnemonicKey);
      
      if (mnemonic != null && mnemonic.isNotEmpty) {
        // If we have a mnemonic, create the wallet from it
        return await EthereumWallet.fromMnemonic(mnemonic);
      }
      
      // If no mnemonic, try to load from private key
      final privateKeyHex = await _secureStorage.read(key: _privateKeyKey);
      if (privateKeyHex != null && privateKeyHex.isNotEmpty) {
        return await EthereumWallet.fromPrivateKey(privateKeyHex);
      }
      
      // No wallet found
      return null;
    } catch (e) {
      print('Error loading Ethereum wallet: $e');
      return null;
    }
  }
  
  /// Check if a wallet exists in secure storage
  Future<bool> hasWallet() async {
    final mnemonic = await _secureStorage.read(key: _mnemonicKey);
    final privateKey = await _secureStorage.read(key: _privateKeyKey);
    return (mnemonic != null && mnemonic.isNotEmpty) || 
           (privateKey != null && privateKey.isNotEmpty);
  }
  
  /// Delete the wallet from secure storage
  Future<void> deleteWallet() async {
    await _secureStorage.delete(key: _mnemonicKey);
    await _secureStorage.delete(key: _privateKeyKey);
  }
  
  /// Get the balance of the wallet
  Future<double> getBalance(EthereumWallet wallet) async {
    if (_web3Client == null) {
      _initializeWeb3Client();
    }
    
    try {
      print('Fetching balance for Ethereum address: ${wallet.address}');
      
      // Ensure we have a valid address
      if (wallet.address.isEmpty) {
        print('Error: Empty Ethereum address');
        return 0.0;
      }
      
      // Get the balance in Wei
      final balanceInWei = await _web3Client!.getBalance(
        EthereumAddress.fromHex(wallet.address),
      );
      
      // Convert Wei to Ether (1 Ether = 10^18 Wei)
      final balanceInEther = balanceInWei.getValueInUnit(EtherUnit.ether);
      
      // Update the wallet's balance
      wallet.balance = balanceInEther;
      
      print('Ethereum balance: $balanceInEther ETH');
      return balanceInEther;
    } catch (e) {
      print('Error getting Ethereum balance: $e');
      return 0.0;
    }
  }
}
