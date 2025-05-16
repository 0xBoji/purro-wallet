import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:solana/solana.dart';

/// Represents a Solana wallet with its keypair and mnemonic
class SolanaWallet {
  final Ed25519HDKeyPair keyPair;
  final String mnemonic;
  double balance = 0.0;

  SolanaWallet({
    required this.keyPair,
    required this.mnemonic,
    this.balance = 0.0,
  });

  /// Get the wallet's public key as a string
  String get publicKey => keyPair.address;

  /// Create a new wallet with a random mnemonic
  static Future<SolanaWallet> create() async {
    // Generate a random mnemonic (12 words by default)
    final mnemonic = bip39.generateMnemonic();
    return fromMnemonic(mnemonic);
  }

  /// Create a wallet from an existing mnemonic
  static Future<SolanaWallet> fromMnemonic(String mnemonic) async {
    // Validate the mnemonic
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }

    // Convert mnemonic to seed
    final seed = bip39.mnemonicToSeed(mnemonic);
    
    // Derive the key pair using BIP44 derivation path for Solana
    // m/44'/501'/0'/0' is the standard derivation path for Solana
    final derivedKey = await ED25519_HD_KEY.derivePath(
      "m/44'/501'/0'/0'",
      seed,
    );

    // Create the key pair from the derived key
    final keyPair = await Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: derivedKey.key,
    );

    return SolanaWallet(
      keyPair: keyPair,
      mnemonic: mnemonic,
    );
  }

  /// Create a wallet from a private key
  static Future<SolanaWallet> fromPrivateKey(Uint8List privateKey) async {
    final keyPair = await Ed25519HDKeyPair.fromPrivateKeyBytes(
      privateKey: privateKey,
    );

    return SolanaWallet(
      keyPair: keyPair,
      mnemonic: '', // No mnemonic when creating from private key
    );
  }

  /// Serialize the wallet to JSON (excluding the private key for security)
  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'balance': balance,
      // Note: We don't include the private key or mnemonic in the JSON
      // for security reasons. These should be stored securely elsewhere.
    };
  }

  @override
  String toString() {
    return 'SolanaWallet(publicKey: $publicKey, balance: $balance)';
  }
}
