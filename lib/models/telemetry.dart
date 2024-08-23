class Telemetry {
  final int ts;
  final String value;

  Telemetry({
    required this.ts,
    required this.value,
  });

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(
      ts: json["ts"],
      value: json["value"],
    );
  }
}
