class Request {
  final String employeeOid; //requested employee
  final String employeeName; //requested employee
  final String requestType; //dayoff, earlyLeave....
  final String requestStatus; // Pending, Approved, Denied
  final String supervisorOid;
  final String requestKey;
  final String requestDate; //
  final String requestComment;

  final String? answerComment;


  final String? dayoffDateText;
  final String? dayoffType;





  Request({
    //required this.employeeId,
    required this.employeeOid,
    required this.employeeName,
    required this.requestType,
    required this.requestStatus,
    required this.supervisorOid,
    required this.requestKey,
    required this.requestDate,
    required this.requestComment,

    this.answerComment,

    this.dayoffDateText,
    this.dayoffType
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      employeeOid: json['employeeOid'] as String,
      employeeName: json['employeeName'],
      requestType: json['requestType'],
      requestStatus: json['requestStatus'] as String,
      requestDate: json['requestDate'],
      requestKey: json['requestKey'],
      supervisorOid: json['supervisorOid'] as String,
      requestComment: json['requestComment'],

      answerComment: json['answerComment'] as String?,
      dayoffDateText: json['dayoffDateText'] as String?,
      dayoffType: json['dayoffType'] as String?,
    );
  }
}
