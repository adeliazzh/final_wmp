import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_wmp/shared/theme.dart';
import 'package:final_wmp/widgets/customized_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EnrollmentPage extends StatefulWidget {
  const EnrollmentPage({super.key});

  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  List<String> subjectNames = [];
  List<int> subjectCredit = [];
  bool isLoading = true;
  List<int> selectedSubject = [];
  int totalCredit = 0;
  String errorMessage = "";
  List<String> chosenSubject = [];
  List<int> chosenCredit = [];
  String userName = "";

  Future<void> fetchUserName() async {
    String? userId = getUserId();
    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      setState(() {
        userName = userDoc['name'] ?? "User";
      });
    }
  }

  Future<void> assignSubjects(String userId) async {
    try {
      chosenSubject.clear();
      chosenCredit.clear();
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      selectedSubject.forEach((subjectIndex) {
        chosenSubject.add(subjectNames[subjectIndex]);
        chosenCredit.add(subjectCredit[subjectIndex]);
      });
      await userDocRef.update(
        {
          'subjectEnrolled.subjectName': FieldValue.arrayUnion(
            chosenSubject,
          ),
          'subjectEnrolled.subjectCredit': chosenCredit
        },
      );
    } catch (e) {
      print('Error handling subject assignment $e');
    }
  }

  String? getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      print("No user!");
      return null;
    }
  }

  bool checkCredit() {
    if (totalCredit >= 24) {
      errorMessage = "You have passed 24!, can not enroll!";
      return true;
    } else if (totalCredit == 0) {
      errorMessage = "Credit can not be empty!";
      return true;
    } else {
      return false;
    }
  }

  void addCredit(int index) {
    totalCredit += subjectCredit[index];
  }

  void removeCredit(int index) {
    totalCredit -= subjectCredit[index];
  }

  void toggleSubject(int index) {
    setState(() {
      if (selectedSubject.contains(index)) {
        selectedSubject.remove(index);
        removeCredit(index);
      } else {
        selectedSubject.add(index);
        addCredit(index);
      }
    });
  }

  Future<void> _fetchSubject() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('subjects')
          .doc('subjectInformation')
          .get();

      if (userDoc.exists) {
        List<dynamic> subjectCreditList = userDoc['subjectCredit'];
        List<dynamic> subjectNameList = userDoc['subjectName'];

        setState(() {
          subjectNames = List<String>.from(subjectNameList);
          subjectCredit = List<int>.from(
              subjectCreditList.map((item) => item is int ? item : 0));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSubject();
    fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(defaultMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 153, 199, 203),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Welcome, $userName!',
                          style: blackTextStyle.copyWith(
                            fontSize: 22,
                            fontWeight: bold,
                          ),
                        ),
                        Text(
                          'Max Credits: 24',
                          style: blackTextStyle.copyWith(
                            fontSize: 18,
                            fontWeight: regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Subject',
                  style: blackTextStyle.copyWith(
                    fontSize: 32,
                    fontWeight: regular,
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(
                  subjectNames.length,
                  (index) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            toggleSubject(index);
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: selectedSubject.contains(index)
                                ? Colors.green.shade100
                                : Colors.white,
                            child: ListTile(
                              title: Text(
                                subjectNames[index],
                                style: blackTextStyle.copyWith(
                                  fontSize: 18,
                                  fontWeight: medium,
                                ),
                              ),
                              trailing: Text(
                                '${subjectCredit[index]} Credits',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: light,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Selected Credits: $totalCredit/24',
                    style: blackTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                CustomizedButton(
                  height: 60,
                  onTap: () {
                    if (!checkCredit()) {
                      assignSubjects(getUserId()!);
                      Navigator.pushReplacementNamed(context, '/enrolled-page');
                    }
                  },
                  text: 'Confirm Selection',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
