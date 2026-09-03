import 'package:flutter/material.dart';
import 'package:innotegy/constants.dart';

class MainConsultantDashboard
    extends
        StatefulWidget {
  const MainConsultantDashboard({
    super.key,
  });

  @override
  State<
    MainConsultantDashboard
  >
  createState() => _MainConsultantDashboardState();
}

class _MainConsultantDashboardState
    extends
        State<
          MainConsultantDashboard
        > {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 80,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manager Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Good morning, Arthur. Here's what's happening on your farms today.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _newConsultantTaskDialog(
                            context,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreenColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Add Task',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Add your dashboard content here
            ],
          ),
        ),
      ),
    );
  }
}

Future<
  dynamic
>
_newConsultantTaskDialog(
  BuildContext context,
) async {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController completionDateController = TextEditingController();
  DateTime? selectedStartDate;
  DateTime? selectedCompletionDate;

  Future<
    void
  >
  pickDate({
    required BuildContext context,
    required TextEditingController controller,
    required void Function(
      DateTime,
    )
    onPicked,
    DateTime? firstDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:
          firstDate ??
          DateTime(
            2000,
          ),
      lastDate: DateTime(
        2100,
      ),
    );

    if (picked !=
        null) {
      onPicked(
        picked,
      );
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  return showDialog(
    context: context,
    builder:
        (
          context,
        ) => StatefulBuilder(
          builder:
              (
                context,
                setState,
              ) => Dialog(
                insetPadding: EdgeInsets.symmetric(
                  horizontal: 300,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Task',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Task Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Task Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      // START DATE
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startDateController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          IconButton.outlined(
                            onPressed: () {
                              pickDate(
                                context: context,
                                controller: startDateController,
                                firstDate: DateTime(
                                  2000,
                                ),
                                onPicked:
                                    (
                                      date,
                                    ) {
                                      setState(
                                        () {
                                          selectedStartDate = date;
                                        },
                                      );
                                    },
                              );
                            },
                            icon: Icon(
                              Icons.calendar_month_outlined,
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(
                                  8,
                                ),
                              ),
                              padding: const EdgeInsets.all(
                                12,
                              ),
                              iconColor: primaryGreenColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      // COMPLETION DATE
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: completionDateController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Completion Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          IconButton.outlined(
                            onPressed: () {
                              pickDate(
                                context: context,
                                controller: completionDateController,
                                // don't let completion date be before the start date
                                firstDate:
                                    selectedStartDate ??
                                    DateTime(
                                      2000,
                                    ),
                                onPicked:
                                    (
                                      date,
                                    ) {
                                      setState(
                                        () {
                                          selectedCompletionDate = date;
                                        },
                                      );
                                    },
                              );
                            },
                            icon: Icon(
                              Icons.calendar_month_outlined,
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(
                                  8,
                                ),
                              ),
                              padding: const EdgeInsets.all(
                                12,
                              ),
                              iconColor: primaryGreenColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Assigned To',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(
                                context,
                              ).pop();
                            },
                            child: Text(
                              'Cancel',
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // selectedStartDate / selectedCompletionDate are
                              // available here for validation + submission
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreenColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                              ),
                            ),
                            child: Text(
                              'Create Task',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ),
  );
}

// Future<
//   dynamic
// >
// _newConsultantTaskDialog(
//   BuildContext context,
// ) async {
//   // final TextEditingController consultantEmailController = TextEditingController();
//   // final TextEditingController consultantPasswordController = TextEditingController();
//   // final TextEditingController consultantFullNameController = TextEditingController();
//   // final TextEditingController consultantPhoneNumberController = TextEditingController();

//   return showDialog(
//     context: context,
//     builder:
//         (
//           context,
//         ) => Dialog(
//           insetPadding: EdgeInsets.symmetric(
//             horizontal: 300,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 60,
//               vertical: 40,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Create New Task',
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 TextField(
//                   // controller: consultantFullNameController,
//                   decoration: InputDecoration(
//                     labelText: 'Task Name',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(
//                         8,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 TextField(
//                   // controller: consultantPhoneNumberController,
//                   keyboardType: TextInputType.phone,
//                   decoration: InputDecoration(
//                     labelText: 'Task Description',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(
//                         8,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         // controller: consultantEmailController,
//                         enabled: false,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           labelText: 'Start Date',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(
//                               8,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 16,
//                     ),
//                     IconButton.outlined(
//                       onPressed: () {},
//                       icon: Icon(
//                         Icons.calendar_month_outlined,
//                       ),
//                       style: OutlinedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadiusGeometry.circular(
//                             8,
//                           ),
//                         ),
//                         // side: const BorderSide(
//                         //   width: 1,
//                         // ),
//                         padding: const EdgeInsets.all(
//                           12,
//                         ),
//                         iconColor: primaryGreenColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         // controller: consultantPasswordController,
//                         enabled: false,
//                         keyboardType: TextInputType.visiblePassword,
//                         decoration: InputDecoration(
//                           labelText: 'Completion Date',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(
//                               8,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 16,
//                     ),
//                     IconButton.outlined(
//                       onPressed: () {},
//                       icon: Icon(
//                         Icons.calendar_month_outlined,
//                       ),
//                       style: OutlinedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadiusGeometry.circular(
//                             8,
//                           ),
//                         ),
//                         // side: const BorderSide(
//                         //   width: 1,
//                         // ),
//                         padding: const EdgeInsets.all(
//                           12,
//                         ),
//                         iconColor: primaryGreenColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 TextField(
//                   // controller: consultantPasswordController,
//                   keyboardType: TextInputType.visiblePassword,
//                   decoration: InputDecoration(
//                     labelText: 'Assigned To',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(
//                         8,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () async {
//                         Navigator.of(
//                           context,
//                         ).pop();
//                       },
//                       child: Text(
//                         'Cancel',
//                       ),
//                     ),
//                     SizedBox(
//                       width: 8,
//                     ),
//                     ElevatedButton(
//                       onPressed: () async {
//                         // Handle task creation logic here
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryGreenColor,
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 40,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                             8,
//                           ),
//                         ),
//                       ),
//                       child: Text(
//                         'Create Task',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//   );
// }
