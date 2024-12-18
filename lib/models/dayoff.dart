class Dayoff {
  //final int employeeId;
  final String dayoffDateText;
  final String dayoffType;
  final String requestStatus;
  final String requestDate;
  final String requestKey;
  final int? supervisorId;
  final String requestComment;
  final String? answerComment;


  Dayoff({
    //required this.employeeId,
    required this.dayoffDateText,
    required this.dayoffType,
    required this.requestStatus,
    required this.requestDate,
    required this.requestKey,
    this.supervisorId,
    required this.requestComment,
    this.answerComment,
  });

  factory Dayoff.fromJson(Map<String, dynamic> json) {
    return Dayoff(
      //employeeId: json['employeeId'] as int,
      dayoffDateText: json['dayoffDateText'],
      dayoffType: json['dayoffType'],
      requestStatus: json['requestStatus'] as String,
      requestDate: json['requestDate'],
      requestKey: json['requestKey'],
      supervisorId: json['supervisorId'] as int?,
      requestComment: json['requestComment'],
      answerComment: json['answerComment'] as String?,
    );
  }
}
