import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

/// Represents an Ethereum wallet with its credentials and mnemonic
class EthereumWallet {
  final EthPrivateKey credentials;
  final String mnemonic;
  double balance = 0.0;

  EthereumWallet({
    required this.credentials,
    required this.mnemonic,
    this.balance = 0.0,
  });

  /// Get the wallet's address as a string
  String get address => credentials.address.hexEip55;

  /// Create a new wallet with a random mnemonic
  static Future<EthereumWallet> create() async {
    // Generate a random mnemonic (12 words by default)
    final mnemonic = bip39.generateMnemonic();
    return fromMnemonic(mnemonic);
  }

  /// Create a wallet from an existing mnemonic
  static Future<EthereumWallet> fromMnemonic(String mnemonic) async {
    // Validate the mnemonic
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }

    // Convert mnemonic to seed
    final seed = bip39.mnemonicToSeed(mnemonic);
    
    // Derive the private key from the seed
    // For simplicity, we're using a simple derivation method
    // In a production app, you would use a proper HD wallet derivation path
    final privateKey = seed.sublist(0, 32);
    
    // Create credentials from the private key
    final credentials = EthPrivateKey.fromHex(HEX.encode(privateKey));

    return EthereumWallet(
      credentials: credentials,
      mnemonic: mnemonic,
    );
  }

  /// Create a wallet from a private key
  static Future<EthereumWallet> fromPrivateKey(String privateKeyHex) async {
    // Remove '0x' prefix if present
    if (privateKeyHex.startsWith('0x')) {
      privateKeyHex = privateKeyHex.substring(2);
    }
    
    // Create credentials from the private key
    final credentials = EthPrivateKey.fromHex(privateKeyHex);

    return EthereumWallet(
      credentials: credentials,
      mnemonic: '', // No mnemonic when creating from private key
    );
  }

  /// Get the wallet's private key as a hex string
  String get privateKeyHex => 
      bytesToHex(credentials.privateKey, include0x: true);
  
  /// Convert bytes to a hex string
  static String bytesToHex(Uint8List bytes, {bool include0x = false}) {
    final hex = HEX.encode(bytes);
    return include0x ? '0x$hex' : hex;
  }

  /// Serialize the wallet to JSON (excluding the private key for security)
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'balance': balance,
      // Note: We don't include the private key or mnemonic in the JSON
      // for security reasons. These should be stored securely elsewhere.
    };
  }

  @override
  String toString() {
    return 'EthereumWallet(address: $address, balance: $balance)';
  }
}
