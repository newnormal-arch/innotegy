import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

                                  String formatDate(
                                    DateTime? date,
                                  ) {
                                    if (date ==
                                        null)
                                      return '';
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
                                    subtitle: Text(
                                      'Farm: $farmName\nDuration: ${formatDate(startDate)} - ${formatDate(endDate)}',
                                      style: const TextStyle(
                                        fontSize: 13,
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
