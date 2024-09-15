import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:web3modal_flutter/services/w3m_service/w3m_service.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import '../color.dart';
import '../models/Message.dart';

class DiveMasterInboxPage extends StatefulWidget {
  @override
  _DiveMasterInboxPageState createState() => _DiveMasterInboxPageState();
}
class _DiveMasterInboxPageState extends State<DiveMasterInboxPage> {
  Future<List<Message>>? _messages;
  late W3MService _w3mService;
  bool _isLoading = true;
  int? _confirmingMessageId;

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
    _fetchMessages();
  }

  void _fetchMessages() {
    String? walletAddress = _w3mService.getwallet;

    if (walletAddress != null) {
      setState(() {
        _messages = _fetchMessagesFromBackend(walletAddress);
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to retrieve wallet address'),
      ));
    }
  }

  Future<List<Message>> _fetchMessagesFromBackend(String walletAddress) async {
    final String backendUrl = 'http://192.168.1.3:8080/api/messages/$walletAddress';
    final response = await http.get(Uri.parse(backendUrl));
    print('Received JSON data: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Message> allMessages = data.map((json) {
        final message = Message.fromJson(json);
        print('Message: $message');
        return message;
      }).toList();

      List<Message> unconfirmedMessages = allMessages.where((message) => !message.isconfirmed).toList();
      print('Unconfirmed Messages: ${unconfirmedMessages.join(', ')}');

      return unconfirmedMessages;
    } else {
      throw Exception('Failed to load messages');
    }
  }

  final deployedContract = DeployedContract(
    ContractAbi.fromJson(
      jsonEncode([
        {
          "inputs": [
            {
              "internalType": "uint256",
              "name": "num",
              "type": "uint256"
            }
          ],
          "name": "store",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "retrieve",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        }
      ]), // ABI object
      'Storage',
    ),
    EthereumAddress.fromHex('0x20f9E349b60E3d932B90E466AC4570Cf3dabDB43'),
  );



  Future<void> _confirmMessage(Message _message) async {
    final walletAddress = _w3mService.getwallet;

    if (walletAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Wallet address is not available'),
      ));
      return;
    }

    setState(() {
      _confirmingMessageId = _message.id;
    });

    const metamaskUrl = 'metamask://';
    final Uri uri = Uri.parse(metamaskUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    print("***bekliyoruzz");

    try {
      final result = await _w3mService.requestWriteContract(
        topic: _w3mService.session?.topic ?? ' ',
        chainId: 'eip155:11155111',
        deployedContract: deployedContract,
        functionName: 'store',
        transaction: Transaction(
          from: EthereumAddress.fromHex(walletAddress),
        ),
        parameters: [BigInt.from(_message.id)],
      ).timeout(Duration(seconds: 60), onTimeout: () {
        throw TimeoutException('Transaction took too long');
      });

      if (result != null) {
        print('Transaction Hash: $result');
      } else {
        print('Transaction result is null');
      }
    } catch (error) {
      print('Error in requestWriteContract: $error');
    }

    print("++++++bekledik backend'e yolluyoruuz.");

    final updateUrl = 'http://192.168.1.3:8080/api/messages/${_message.id}/confirm';
    final response = await http.put(
      Uri.parse(updateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'is_confirmed': true}),
    ).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Message confirmed on blockchain'),
      ));

      _fetchMessages(); // sayfayı yeniden yüklüyor
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to confirm message'),
      ));
    }

    setState(() {
      _confirmingMessageId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox"),
        backgroundColor: mainColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Message>>(
        future: _messages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No messages'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final message = snapshot.data![index];
                return ListTile(
                  leading: Icon(Icons.mail),
                  title: Text(message.sender, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('id: ${message.id}, ${message.location}'),
                  trailing: message.isconfirmed
                      ? null
                      : _confirmingMessageId == message.id
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () => _confirmMessage(message),
                    child: Text('Confirm', style: TextStyle(color: mainColor)),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
