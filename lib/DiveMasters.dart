
class DiveMaster {
  final String name;
  final String surname;
  final String walletAddress;

  DiveMaster({
    required this.name,
    required this.surname,
    required this.walletAddress,
  });

  @override
  String toString() {
    return 'Name: $name, Surname: $surname, Wallet: $walletAddress';
  }
}


final List<DiveMaster> diveMasters = [
  DiveMaster(
    name: 'John',
    surname: 'Doe',
    walletAddress: '0x1234567890abcdef',
  ),
  DiveMaster(
    name: 'Jane',
    surname: 'Smith',
    walletAddress: '0xabcdef1234567890',
  ),
];
