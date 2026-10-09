import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innotegy/constants.dart';

Widget
buildTaskList() {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  return Column(
    children: [
      SizedBox(
        width: 450,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),

                if (currentUserId ==
                    null)
                  const Text(
                    'Please log in to view your tasks.',
                  )
                else
                  StreamBuilder<
                    QuerySnapshot
                  >(
                    stream: FirebaseFirestore.instance
                        .collection(
                          'tasks',
                        )
                        .where(
                          'farmerId',
                          isEqualTo: currentUserId,
                        )
                        .snapshots(),
                    builder:
                        (
                          context,
                          snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(
                                  16.0,
                                ),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text(
                              'Error loading tasks: ${snapshot.error}',
                            );
                          }

                          final taskDocs =
                              snapshot.data?.docs ??
                              [];

                          if (taskDocs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Text(
                                'No tasks assigned to you yet.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: taskDocs.length,
                            separatorBuilder:
                                (
                                  context,
                                  index,
                                ) => const Divider(),
                            itemBuilder:
                                (
                                  context,
                                  index,
                                ) {
                                  final task =
                                      taskDocs[index].data()
                                          as Map<
                                            String,
                                            dynamic
                                          >;
                                  final String taskName =
                                      task['taskName'] ??
                                      'Unnamed Task';
                                  final String farmName =
                                      task['farmName'] ??
                                      'N/A';
                                  final DateTime? startDate =
                                      (task['startDate']
                                              as Timestamp?)
                                          ?.toDate();
                                  final DateTime? endDate =
                                      (task['endDate']
                                              as Timestamp?)
                                          ?.toDate();

                                  final String taskStatus =
                                      task['taskStatus'] ??
                                      'N/A';

                                  String formatDate(
                                    DateTime? date,
                                  ) {
                                    if (date ==
                                        null) {
                                      return '';
                                    }
                                    return '${date.day}/${date.month}/${date.year}';
                                  }

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Icon(
                                        Icons.task,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      taskName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Farm: $farmName\nDuration: ${formatDate(startDate)} - ${formatDate(endDate)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        taskStatus ==
                                                'Completed'
                                            ? const Text(
                                                'Task completed successfully!',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : taskStatus ==
                                                  'In Progress'
                                            ? TextButton(
                                                onPressed: () {
                                                  // Update the task status to "Completed" in Firestore
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                        'tasks',
                                                      )
                                                      .doc(
                                                        taskDocs[index].id,
                                                      )
                                                      .update(
                                                        {
                                                          'taskStatus': 'Completed',
                                                          'isCompleted': true,
                                                          'taskCompletionDate': Timestamp.now(),
                                                        },
                                                      );
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: backgroundGreenColor,
                                                  textStyle: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Mark as Done',
                                                ),
                                              )
                                            : TextButton(
                                                onPressed: () {
                                                  // Update the task status to "In Progress" in Firestore
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                        'tasks',
                                                      )
                                                      .doc(
                                                        taskDocs[index].id,
                                                      )
                                                      .update(
                                                        {
                                                          'taskStatus': 'In Progress',
                                                          'taskStartDate': Timestamp.now(),
                                                        },
                                                      );
                                                },
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: primaryOliveColor,
                                                  textStyle: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Start Task',
                                                ),
                                              ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            showTaskDetailsDialog(
                                              context,
                                              task,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            overlayColor: Colors.transparent,

                                            splashFactory: NoSplash.splashFactory,
                                            textStyle: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            padding: const EdgeInsets.all(
                                              0,
                                            ),
                                          ),
                                          child: Text(
                                            'View Details',
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      taskStatus,
                                      style: TextStyle(
                                        color:
                                            taskStatus ==
                                                'Completed'
                                            ? Colors.green
                                            : taskStatus ==
                                                  'In Progress'
                                            ? Colors.orange
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                          );
                        },
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

void
showTaskDetailsDialog(
  BuildContext context,
  Map<
    String,
    dynamic
  >
  task,
) {
  showDialog(
    context: context,
    builder:
        (
          BuildContext context,
        ) {
          return AlertDialog(
            title: Text(
              task['taskName'] ??
                  'Task Details',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm: ${task['farmName'] ?? 'N/A'}',
                ),
                Text(
                  'Stage: ${task['stage'] ?? 'N/A'}',
                ),
                Text(
                  'Description: ${task['taskDescription'] ?? 'N/A'}',
                ),
                Text(
                  'Start Date: ${task['startDate'] != null ? (task['startDate'] as Timestamp).toDate().toLocal().toString() : 'N/A'}',
                ),
                Text(
                  'End Date: ${task['endDate'] != null ? (task['endDate'] as Timestamp).toDate().toLocal().toString() : 'N/A'}',
                ),
                Text(
                  'Status: ${task['taskStatus'] ?? 'N/A'}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop();
                },
                child: const Text(
                  'Close',
                ),
              ),
            ],
          );
        },
  );
}
