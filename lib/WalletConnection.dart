import 'package:flutter/material.dart';
import 'package:web3modal_flutter/services/w3m_service/w3m_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'MainPage.dart';
import 'color.dart';

class WalletConnection extends StatefulWidget {
  const WalletConnection({super.key});

  @override
  State<WalletConnection> createState() => _WalletConnectionState();

}

class _WalletConnectionState extends State<WalletConnection> {
  late W3MService _w3mService;
  late String publicKey = '';
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() async {
    _w3mService = W3MService(
      projectId: '9fe6461ab274ea61c03732711eae0d9c',
      metadata: const PairingMetadata(
        name: 'Web3Modal Flutter Example',
        description: 'Web3Modal Flutter Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'w3m://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );
    await _w3mService.init();
    setState(() {
      publicKey = _w3mService.session?.address ?? 'No Address';

      isConnected = _w3mService.session != null;

    });
  }



  void _navigateBack() {
    Navigator.pop(context, {
      'publicKey': publicKey,
      'isConnected': isConnected,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wallet Connection",
          style: TextStyle(
            color: textColor1,
            fontFamily: "Playwrite",
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: mainColor,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              W3MConnectWalletButton(service: _w3mService),
              const SizedBox(height: 16),
              W3MNetworkSelectButton(service: _w3mService),
              const SizedBox(height: 16),
              W3MAccountButton(service: _w3mService),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainPage(publicKey,isConnected)),
                    );

                  },
                  style: TextButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: textColor1,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Public Key: $publicKey",
                style: TextStyle(color: mainColor, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                "Wallet Connected: ${isConnected ? 'Yes' : 'No'}",
                style: TextStyle(color: mainColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
