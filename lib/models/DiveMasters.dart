class DiveMaster {
  final String walletAddress;
  final String name;
  final String surname;

  DiveMaster({
    required this.walletAddress,
    required this.name,
    required this.surname,
  });

  factory DiveMaster.fromJson(Map<String, dynamic> json) {
    return DiveMaster(
      walletAddress: json['walletAddress'],
      name: json['name'],
      surname: json['surname'],
    );
  }
}
