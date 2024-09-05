import 'package:flutter/material.dart';
import 'package:web3modal_flutter/widgets/w3m_account_button.dart';
import 'color.dart';
import 'WalletConnection.dart';
import 'DiveLocations.dart';
import 'DiveMasters.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? selectedLocation;
  String? selectedDiveMaster;
  var publicKey;
  var isConnected = false;
  //final WalletConnection _walletService = WalletConnection();

  Future<void> _navigateToWalletConnection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WalletConnection()),
    );
    if (result != null) {
      setState(() {
        publicKey = result['publicKey'];
        isConnected = result['isConnected'];
      });
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
              onPressed: _navigateToWalletConnection,
              style: TextButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: textColor1,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                "Connect Wallet",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Public Key: ${publicKey ?? 'Not Connected'}",
            style: TextStyle(color: mainColor, fontSize: 16),
          ),
          SizedBox(height: 20),
          Text(
            "Wallet Connected: ${isConnected ? 'Yes' : 'No'}",
            style: TextStyle(color: mainColor, fontSize: 16),
          ),

              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
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
                  underline: SizedBox(),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
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
                  underline: SizedBox(),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: TextButton(
                  onPressed: () {
                    if (selectedLocation != null && selectedDiveMaster != null) {
                      DiveMaster? diveMaster = diveMasters.firstWhere(
                            (dm) => dm.name == selectedDiveMaster,
                        orElse: () => DiveMaster(name: 'null', surname: 'null', walletAddress: 'null'),
                      );

                      if (diveMaster.walletAddress != 'null') {
                        print("Dive master: ${diveMaster.name} ${diveMaster.surname}, Wallet: ${diveMaster.walletAddress}");
                      } else {
                        print("Selected Dive Master not found.");
                      }
                    } else {
                      print("No location or dive master selected");
                    }

                  },
                  style: TextButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: textColor1,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "Dive",
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
