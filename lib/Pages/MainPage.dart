import 'dart:convert';
import 'package:flutter/material.dart';
import 'DiveMasterInboxPage.dart';
import '../models/DiveMasters.dart';
import '../color.dart';
import 'WalletConnection.dart';
import '../models/DiveLocations.dart';
import 'package:http/http.dart' as http;

class Message {
  final String sender;
  final String selectedLocation;
  final String diveMasterWallet;

  Message({required this.sender, required this.selectedLocation, required this.diveMasterWallet});

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'location': selectedLocation,
      'diveMasterWallet': diveMasterWallet
    };
  }
}

class MainPage extends StatefulWidget {
  final String publicKey;
  final bool isConnected;

  MainPage(this.publicKey, this.isConnected, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? selectedLocation;
  String? selectedDiveMaster;
  bool _showInboxButton = false;
  List<DiveMaster> diveMasters = [];

  @override
  void initState() {
    super.initState();
    _checkWalletAddress();
    _fetchDiveMasters();
  }

  Future<void> _navigateToWalletConnection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WalletConnection()),
    );
  }

  Future<void> _checkWalletAddress() async {
    if (widget.isConnected) {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:8080/api/dive-masters'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          diveMasters = data.map((item) => DiveMaster.fromJson(item)).toList();
          _showInboxButton = diveMasters.any((dm) => dm.walletAddress == widget.publicKey);
        });
      } else {
        print('Failed to load dive masters');
      }
    }
  }

  Future<void> _sendMessage() async {
    if (selectedLocation != null &&
        selectedDiveMaster != null &&
        widget.publicKey.isNotEmpty &&
        widget.isConnected) {

      DiveMaster? diveMaster = diveMasters.firstWhere(
            (dm) => dm.name == selectedDiveMaster,
        orElse: () => DiveMaster(
          name: 'null',
          surname: 'null',
          walletAddress: 'null',
        ),
      );

      if (diveMaster.walletAddress != 'null') {
        Message message = Message(
          sender: widget.publicKey,
          selectedLocation: selectedLocation!,
          diveMasterWallet: diveMaster.walletAddress,
        );

        final response = await http.post(
          Uri.parse('http://192.168.1.3:8080/api/messages/sendMessage'),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(message.toJson()),
        );
        final messageJson = jsonEncode(message.toJson());
        print("Sending JSON: $messageJson");

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: Text('ONAYA GÖNDERİLDİ'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to send message: ${response.statusCode}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print("Selected Dive Master not found.");
      }
    } else {
      print("No location or dive master selected");
    }
  }

  Future<void> _fetchDiveMasters() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.3:8080/api/dive-masters'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        diveMasters = data.map((item) => DiveMaster.fromJson(item)).toList();
      });
    } else {
      print('Failed to load dive masters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Diving Notebook",
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: widget.isConnected
                    ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Wallet Connected",
                      style: TextStyle(
                        color: textColor1,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                    : TextButton(
                  onPressed: _navigateToWalletConnection,
                  style: TextButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: textColor1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Connect Wallet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Public Key: ${widget.publicKey}",
                style: TextStyle(color: mainColor, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                "Wallet Connected: ${widget.isConnected ? 'Yes' : 'No'}",
                style: TextStyle(color: mainColor, fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Dive Location Select
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: DropdownButton<String>(
                  value: selectedLocation,
                  hint: Text(
                    'Select Dive Location',
                    style: TextStyle(color: textColor1),
                  ),
                  items: diveLocations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(
                        location,
                        style: TextStyle(color: textColor1),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLocation = newValue;
                    });
                  },
                  dropdownColor: mainColor,
                  iconEnabledColor: textColor1,
                  underline: const SizedBox(),
                ),
              ),
              const SizedBox(height: 20),
              // Dive Master Select
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: DropdownButton<String>(
                  value: selectedDiveMaster,
                  hint: Text(
                    'Select Dive Master',
                    style: TextStyle(color: textColor1),
                  ),
                  items: diveMasters.map((DiveMaster diveMaster) {
                    return DropdownMenuItem<String>(
                      value: diveMaster.name,
                      child: Text(
                        '${diveMaster.name} ${diveMaster.surname}',
                        style: TextStyle(color: textColor1),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDiveMaster = newValue;
                    });
                  },
                  dropdownColor: mainColor,
                  iconEnabledColor: textColor1,
                  underline: const SizedBox(),
                ),
              ),
              const SizedBox(height: 20),
              // Dive Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: TextButton(
                  onPressed: _sendMessage,
                  style: TextButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: textColor1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Dive",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Inbox Button
              if (_showInboxButton)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiveMasterInboxPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: textColor1,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Inbox",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
