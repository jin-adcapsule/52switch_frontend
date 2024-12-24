import 'package:flutter/material.dart';
import '../services/supervisor_service.dart';
import '../services/push_service.dart';
import '../screens/config_screen.dart';

class AnswerRequestScreen extends StatefulWidget {
  final String? objectId;
  final int employeeId;
  final String employeeName;
  final String requestType;
  final String requestDate;
  final String? requestComment;
  final int supervisorId;
  final String requestKey;

  const AnswerRequestScreen({
    super.key,
    required this.objectId,
    required this.employeeId,
    required this.employeeName,
    required this.requestType,
    required this.requestDate,
    this.requestComment,
    required this.supervisorId,
    required this.requestKey
  });

  @override
  AnswerRequestScreenState createState() => AnswerRequestScreenState();
}

class AnswerRequestScreenState extends State<AnswerRequestScreen> {
  final TextEditingController _answerCommentController = TextEditingController();
  final List<String> _statuses = ['대기중', '승인', '반려'];
  String defaultStatus = '대기중';
  static const String defaultComment = '다음과 같이 답변드립니다';
  String? _selectedStatus ; //set initial status oprtion

  @override
  void initState() {
    super.initState();
    _selectedStatus = defaultStatus; // Set initial status in initState

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요청 상세'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => clearForm(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                //mainAxisSize: MainAxisSize.min, // Ensures the Column doesn't expand unnecessarily
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request Details Section
                  _buildRequestDetailsSection(),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 20),

                  // Answer Comment Input Section
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.black),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _answerCommentController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: defaultComment,
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1, color: Colors.grey),
                  const SizedBox(height: 20),

                  // Status Selection Section
                  Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.black),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          items: _statuses
                              .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ]
              )
            )
          ),


          // Submit Button
          GestureDetector(
            onTap: _onSubmit,
            child: Container(
              width: double.infinity, // Ensures full width
              color: _selectedStatus == null||_selectedStatus == defaultStatus
                  ? Colors.grey // Gray background if conditions are not met
                  : Colors.black, // Dark background if all conditions are met
              padding: const EdgeInsets.symmetric(vertical: 50), // Add some vertical space
              alignment: Alignment.center, // Center the text
              child: const Text(
                '제출', // Button label
                style: TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold, // Bold font for better visibility
                  fontSize: 24, // Font size
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

  // Build Request Details Section
  Widget _buildRequestDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('신청자', widget.employeeName, Icons.person),
        const SizedBox(height: 10),
        _buildDetailRow('요청 유형', widget.requestType, Icons.request_page),
        const SizedBox(height: 10),
        _buildDetailRow('신청 일자', widget.requestDate, Icons.calendar_today),
        const SizedBox(height: 10),
        _buildDetailRow('신청 메모', widget.requestComment ?? '없음', Icons.comment),
      ],
    );
  }

  // Helper Method to Build a Detail Row
  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$title: $value',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // Handle Submit Button Tap
  void _onSubmit() async {
    if ( _selectedStatus == null||_selectedStatus == defaultStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변을 생성하십시오')),
      );
      return;
    }


    // Simulate an API call or save operation
    try {
      final supervisorService = SupervisorService();
      final String answerComment = _answerCommentController.text.isEmpty
          ? defaultComment
          : _answerCommentController.text.trim();
      final String status = _selectedStatus!;
      //await Future.delayed(const Duration(seconds: 1)); // Simulate async operation
      await supervisorService.answerRequest(
        widget.objectId!,
        status,
        answerComment,
        widget.requestKey,
      );
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('답변이 생성되었습니다.')),
        );
      }
      //send Notification with employeeOid
      PushService.sendPushToEmployeeId(widget.employeeId, "${widget.requestType} $status", "${AppConfig.employeeName}님이 처리하였습니다.");

      // Clear inputs and reset state
      clearForm();
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('에러 발생: ${e.toString()}')),
        );
      }
    }
  }
  // Clear inputs and reset state
  void clearForm(){
    // Clear inputs and reset state
    setState(() {
      _answerCommentController.clear();
      _selectedStatus = '대기중';
    });
    _answerCommentController.clear();
    // Navigate back
    Navigator.pop(context);
  }
}
