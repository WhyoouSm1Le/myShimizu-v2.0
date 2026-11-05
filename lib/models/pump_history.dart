class PumpHistory {
  final String id;
  final String user;
  final DateTime startedAt;
  final int durationMinutes;
  
  const PumpHistory({
    required this.id,
    required this.user,
    required this.startedAt,
    required this.durationMinutes
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'startedAt': startedAt.toIso8601String(),
    'durationMinutes': durationMinutes,
  };

  factory PumpHistory.fromJSon(Map<String, dynamic> json) => PumpHistory(
    id: json['id'] as String, 
    user: json['user'] as String,  
    startedAt: DateTime.parse(json['startedAt'] as String), 
    durationMinutes: json['durationMinutes'] as int,
  );
}