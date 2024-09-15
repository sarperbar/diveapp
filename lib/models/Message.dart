class Message {
  final int id;
  final String sender;
  final String location;
  final bool isconfirmed;

  Message({
    required this.id,
    required this.sender,
    required this.location,
    required this.isconfirmed,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: json['sender'],
      location: json['location'],
      isconfirmed: json['confirmed'] ?? false,
    );
  }


  @override
  String toString() {
    return 'Message(id: $id, sender: $sender, location: $location, isconfirmed: $isconfirmed)';
  }
}
