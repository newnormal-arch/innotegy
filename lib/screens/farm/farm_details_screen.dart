import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:innotegy/models/farm_model.dart';
import 'package:innotegy/services/authentication_service.dart';

class FarmDetailsScreen
    extends
        StatefulWidget {
  final FarmModel farm;

  const FarmDetailsScreen({
    super.key,
    required this.farm,
  });

  @override
  State<
    FarmDetailsScreen
  >
  createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState
    extends
        State<
          FarmDetailsScreen
        > {
  static const Color primaryColor = Color(
    0xFF1CB026,
  );

  /// Displays the Allocate User Dialog
  void _showAllocateUserDialog(
    BuildContext context,
  ) {
    String? selectedUserId;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder:
          (
            context,
          ) {
            return StatefulBuilder(
              builder:
                  (
                    context,
                    setDialogState,
                  ) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      title: Text(
                        'Allocate "${widget.farm.name}"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SizedBox(
                        width: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select an active user to assign this farm to:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            StreamBuilder<
                              QuerySnapshot<
                                Map<
                                  String,
                                  dynamic
                                >
                              >
                            >(
                              stream: FirebaseFirestore.instance
                                  .collection(
                                    'users',
                                  )
                                  .where(
                                    'isActive',
                                    isEqualTo: true,
                                  )
                                  .snapshots(),
                              builder:
                                  (
                                    context,
                                    snapshot,
                                  ) {
                                    if (snapshot.hasError) {
                                      return Text(
                                        'Error loading users: ${snapshot.error}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      );
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            16.0,
                                          ),
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                          ),
                                        ),
                                      );
                                    }

                                    final activeDocs =
                                        snapshot.data?.docs ??
                                        [];

                                    if (activeDocs.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(
                                          12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.shade300,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: Text(
                                                'No active users found in Firestore.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return DropdownButtonFormField<
                                      String
                                    >(
                                      initialValue: selectedUserId,
                                      isExpanded: true,
                                      hint: const Text(
                                        'Select active user...',
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        filled: true,
                                        fillColor: const Color(
                                          0xFFFAFAFA,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                      ),
                                      items: activeDocs.map(
                                        (
                                          doc,
                                        ) {
                                          final data = doc.data();
                                          final name =
                                              data['fullName'] ??
                                              'Unnamed';
                                          final email =
                                              data['email'] ??
                                              '';
                                          final role =
                                              data['userRole'] ??
                                              'No role';

                                          return DropdownMenuItem<
                                            String
                                          >(
                                            value: doc.id,
                                            child: Text(
                                              '$name ($email) - $role',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        },
                                      ).toList(),
                                      onChanged: isSubmitting
                                          ? null
                                          : (
                                              val,
                                            ) {
                                              setDialogState(
                                                () => selectedUserId = val,
                                              );
                                            },
                                    );
                                  },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(
                                  context,
                                ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              (selectedUserId ==
                                      null ||
                                  isSubmitting)
                              ? null
                              : () async {
                                  setDialogState(
                                    () => isSubmitting = true,
                                  );

                                  try {
                                    final authService = AuthenticationService();
                                    await authService.assignFarmToUser(
                                      selectedUserId!,
                                      widget.farm.name,
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pop(
                                      context,
                                    );

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        backgroundColor: primaryColor,
                                        content: Text(
                                          'Successfully assigned "${widget.farm.name}" to user!',
                                        ),
                                      ),
                                    );
                                  } catch (
                                    e
                                  ) {
                                    setDialogState(
                                      () => isSubmitting = false,
                                    );
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          e.toString().replaceAll(
                                            'Exception: ',
                                            '',
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Allocate Farm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
            );
          },
    );
  }

  /// Displays the New Task Dialog
  void _showNewTaskDialog(
    BuildContext context,
  ) {
    String? selectedStageDocId;
    String? selectedStageName;
    List<
      Map<
        String,
        dynamic
      >
    >
    availableTasksForStage = [];
    String? selectedTaskTitle;

    final TextEditingController descController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    String? selectedWorkerId;
    String? selectedWorkerName;

    bool isSubmitting = false;

    showDialog(
      context: context,
      builder:
          (
            context,
          ) {
            return StatefulBuilder(
              builder:
                  (
                    context,
                    setDialogState,
                  ) {
                    // Helper for picking DateTime
                    Future<
                      void
                    >
                    pickDateTime(
                      bool isStart,
                    ) async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                          2024,
                        ),
                        lastDate: DateTime(
                          2030,
                        ),
                      );

                      if (pickedDate !=
                          null) {
                        if (!context.mounted) return;
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime !=
                            null) {
                          final fullDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          setDialogState(
                            () {
                              if (isStart) {
                                startDate = fullDateTime;
                              } else {
                                endDate = fullDateTime;
                              }
                            },
                          );
                        }
                      }
                    }

                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      title: Text(
                        'Create New Task for "${widget.farm.name}"',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: SizedBox(
                        width: 480,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Stage Selection Dropdown from task_segments
                              const Text(
                                'STAGE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              StreamBuilder<
                                QuerySnapshot<
                                  Map<
                                    String,
                                    dynamic
                                  >
                                >
                              >(
                                stream: FirebaseFirestore.instance
                                    .collection(
                                      'task_segments',
                                    )
                                    .snapshots(),
                                builder:
                                    (
                                      context,
                                      snapshot,
                                    ) {
                                      final docs =
                                          snapshot.data?.docs ??
                                          [];

                                      return DropdownButtonFormField<
                                        String
                                      >(
                                        initialValue: selectedStageDocId,
                                        isExpanded: true,
                                        hint: const Text(
                                          'Select Stage...',
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          filled: true,
                                          fillColor: const Color(
                                            0xFFFAFAFA,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        items: docs.map(
                                          (
                                            doc,
                                          ) {
                                            final name =
                                                doc.data()['stageName'] ??
                                                'Unnamed Stage';
                                            return DropdownMenuItem<
                                              String
                                            >(
                                              value: doc.id,
                                              child: Text(
                                                name,
                                              ),
                                            );
                                          },
                                        ).toList(),
                                        onChanged:
                                            (
                                              val,
                                            ) {
                                              final selectedDoc = docs.firstWhere(
                                                (
                                                  d,
                                                ) =>
                                                    d.id ==
                                                    val,
                                              );
                                              final rawTasks =
                                                  selectedDoc.data()['tasks'] ??
                                                  [];

                                              setDialogState(
                                                () {
                                                  selectedStageDocId = val;
                                                  selectedStageName = selectedDoc.data()['stageName'];
                                                  availableTasksForStage =
                                                      List<
                                                        Map<
                                                          String,
                                                          dynamic
                                                        >
                                                      >.from(
                                                        rawTasks,
                                                      );
                                                  selectedTaskTitle = null; // reset selected task
                                                },
                                              );
                                            },
                                      );
                                    },
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              // 2. Dependent Task Selection Dropdown
                              const Text(
                                'TASK NAME',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              DropdownButtonFormField<
                                String
                              >(
                                initialValue: selectedTaskTitle,
                                isExpanded: true,
                                hint: Text(
                                  selectedStageDocId ==
                                          null
                                      ? 'Select Stage First...'
                                      : 'Select Task...',
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: const Color(
                                    0xFFFAFAFA,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                ),
                                items: availableTasksForStage.map(
                                  (
                                    t,
                                  ) {
                                    final title =
                                        t['title'] ??
                                        'Untitled';
                                    return DropdownMenuItem<
                                      String
                                    >(
                                      value: title,
                                      child: Text(
                                        title,
                                      ),
                                    );
                                  },
                                ).toList(),
                                onChanged:
                                    selectedStageDocId ==
                                        null
                                    ? null
                                    : (
                                        val,
                                      ) {
                                        setDialogState(
                                          () => selectedTaskTitle = val,
                                        );
                                      },
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              // 3. Task Description TextField
                              const Text(
                                'TASK DESCRIPTION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              TextField(
                                controller: descController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Add instructions or details for the field worker...',
                                  filled: true,
                                  fillColor: const Color(
                                    0xFFFAFAFA,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              // 4. Start & End Date Time Pickers
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'START DATE & TIME',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        InkWell(
                                          onTap: () => pickDateTime(
                                            true,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFFAFAFA,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                              border: Border.all(
                                                color: Colors.grey[400]!,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  startDate ==
                                                          null
                                                      ? 'Pick Start'
                                                      : '${startDate!.day}/${startDate!.month}/${startDate!.year} ${startDate!.hour}:${startDate!.minute.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        startDate ==
                                                            null
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'END DATE & TIME',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        InkWell(
                                          onTap: () => pickDateTime(
                                            false,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFFAFAFA,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                              border: Border.all(
                                                color: Colors.grey[400]!,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  endDate ==
                                                          null
                                                      ? 'Pick End'
                                                      : '${endDate!.day}/${endDate!.month}/${endDate!.year} ${endDate!.hour}:${endDate!.minute.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        endDate ==
                                                            null
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              // 5. Field Worker Dropdown (Filtered by userRole == 'Field Worker' & farms array contains farm.name)
                              const Text(
                                'ASSIGN FIELD WORKER (ALLOCATED ONLY)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              StreamBuilder<
                                QuerySnapshot<
                                  Map<
                                    String,
                                    dynamic
                                  >
                                >
                              >(
                                stream: FirebaseFirestore.instance
                                    .collection(
                                      'users',
                                    )
                                    .where(
                                      'userRole',
                                      isEqualTo: 'Field Worker',
                                    )
                                    .where(
                                      'isActive',
                                      isEqualTo: true,
                                    )
                                    .where(
                                      'farms',
                                      arrayContains: widget.farm.name,
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
                                              8.0,
                                            ),
                                            child: CircularProgressIndicator(
                                              color: primaryColor,
                                            ),
                                          ),
                                        );
                                      }

                                      final workers =
                                          snapshot.data?.docs ??
                                          [];

                                      if (workers.isEmpty) {
                                        return Container(
                                          padding: const EdgeInsets.all(
                                            12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.amber.shade300,
                                            ),
                                          ),
                                          child: Text(
                                            'No field workers have been allocated to "${widget.farm.name}" yet. Please allocate a field worker first.',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        );
                                      }

                                      return DropdownButtonFormField<
                                        String
                                      >(
                                        initialValue: selectedWorkerId,
                                        isExpanded: true,
                                        hint: const Text(
                                          'Select Allocated Field Worker...',
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          filled: true,
                                          fillColor: const Color(
                                            0xFFFAFAFA,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        items: workers.map(
                                          (
                                            w,
                                          ) {
                                            final name =
                                                w.data()['fullName'] ??
                                                'Worker';
                                            final email =
                                                w.data()['email'] ??
                                                '';
                                            return DropdownMenuItem<
                                              String
                                            >(
                                              value: w.id,
                                              child: Text(
                                                '$name ($email)',
                                              ),
                                            );
                                          },
                                        ).toList(),
                                        onChanged:
                                            (
                                              val,
                                            ) {
                                              final workerDoc = workers.firstWhere(
                                                (
                                                  w,
                                                ) =>
                                                    w.id ==
                                                    val,
                                              );
                                              setDialogState(
                                                () {
                                                  selectedWorkerId = val;
                                                  selectedWorkerName =
                                                      workerDoc.data()['fullName'] ??
                                                      'Worker';
                                                },
                                              );
                                            },
                                      );
                                    },
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(
                                  context,
                                ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              (selectedStageName ==
                                      null ||
                                  selectedTaskTitle ==
                                      null ||
                                  startDate ==
                                      null ||
                                  endDate ==
                                      null ||
                                  selectedWorkerId ==
                                      null ||
                                  isSubmitting)
                              ? null
                              : () async {
                                  setDialogState(
                                    () => isSubmitting = true,
                                  );

                                  try {
                                    final currentUser = FirebaseAuth.instance.currentUser;

                                    // Save as farmTasks in Firestore
                                    await FirebaseFirestore.instance
                                        .collection(
                                          'farmTasks',
                                        )
                                        .add(
                                          {
                                            'farmName': widget.farm.name,
                                            'stageName': selectedStageName,
                                            'taskTitle': selectedTaskTitle,
                                            'description': descController.text.trim(),
                                            'startDate': Timestamp.fromDate(
                                              startDate!,
                                            ),
                                            'endDate': Timestamp.fromDate(
                                              endDate!,
                                            ),
                                            'assignedToUid': selectedWorkerId,
                                            'assignedToName': selectedWorkerName,
                                            'createdByUid':
                                                currentUser?.uid ??
                                                '',
                                            'createdByEmail':
                                                currentUser?.email ??
                                                '',
                                            'createdAt': FieldValue.serverTimestamp(),
                                            'taskProgress': 'Not started',
                                            'startedAtByWorker': null,
                                            'completedAtByWorker': null,
                                          },
                                        );

                                    if (!context.mounted) return;
                                    Navigator.pop(
                                      context,
                                    );

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: primaryColor,
                                        content: Text(
                                          'New farm task assigned successfully!',
                                        ),
                                      ),
                                    );
                                  } catch (
                                    e
                                  ) {
                                    setDialogState(
                                      () => isSubmitting = false,
                                    );
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          'Failed to save task: ${e.toString()}',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Task',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
            );
          },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDesktop =
        MediaQuery.of(
          context,
        ).size.width >=
        1024;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ),
      body: Column(
        children: [
          // Top Header Bar
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(
                    0xFFEFEFEF,
                  ),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                  onPressed: () => Navigator.pop(
                    context,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  widget.farm.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/100?img=68',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(
                    context,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildMapAndStatsSection(
                    isDesktop,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  _buildBottomSection(
                    isDesktop,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // If no user is logged in, default to hiding the buttons
    if (currentUser ==
        null) {
      return Container();
    }

    return StreamBuilder<
      DocumentSnapshot
    >(
      stream: FirebaseFirestore.instance
          .collection(
            'users',
          )
          .doc(
            currentUser.uid,
          )
          .snapshots(),
      builder:
          (
            context,
            snapshot,
          ) {
            // While loading the role, you can hide the buttons or show a tiny loader
            String userRole = '';
            if (snapshot.hasData &&
                snapshot.data!.exists) {
              final data =
                  snapshot.data!.data()
                      as Map<
                        String,
                        dynamic
                      >?;
              userRole =
                  data?['userRole'] ??
                  '';
            }

            bool isOwner =
                userRole ==
                'Owner';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Farm Name & Area (Always visible)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.farm.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(
                              0.15,
                            ),
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      '📐 ${widget.farm.areaInHectares.toStringAsFixed(2)} Hectares',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // Right side: Action buttons (Only visible if isOwner is true)
                if (isOwner)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showNewTaskDialog(
                          context,
                        ),
                        icon: const Icon(
                          Icons.add_task_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'New Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showAllocateUserDialog(
                          context,
                        ),
                        icon: const Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 16,
                          color: primaryColor,
                        ),
                        label: const Text(
                          'Allocate User',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: primaryColor,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
    );
  }

  Widget _buildMapAndStatsSection(
    bool isDesktop,
  ) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: _buildSatelliteMapView(),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 3,
            child: _buildFarmMetricsList(),
          ),
        ],
      );
    }
    return Column(
      children: [
        _buildSatelliteMapView(),
        const SizedBox(
          height: 16,
        ),
        _buildFarmMetricsList(),
      ],
    );
  }

  Widget _buildSatelliteMapView() {
    return Container(
      height: 320,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          12,
        ),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1600&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldTag(
                  '🟢 Block A Boundary',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTag(
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(
          0.6,
        ),
        borderRadius: BorderRadius.circular(
          4,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFarmMetricsList() {
    const Color primaryColor = Color(
      0xFF1CB026,
    );
    final double hectares = widget.farm.areaInHectares;

    return Column(
      children: [
        // 1. Spatial Area (From KML polygon calculation)
        _SensorStatCard(
          title: 'TOTAL AREA',
          value: '${hectares.toStringAsFixed(1)} Ha',
          icon: Icons.map_outlined,
          color: primaryColor,
        ),
        const SizedBox(
          height: 10,
        ),

        // 2. Current Lifecycle Stage (Streamed from Firestore farmTimelines)
        StreamBuilder<
          QuerySnapshot<
            Map<
              String,
              dynamic
            >
          >
        >(
          stream: FirebaseFirestore.instance
              .collection(
                'farmTimelines',
              )
              .where(
                'farmName',
                isEqualTo: widget.farm.name,
              )
              .snapshots(),
          builder:
              (
                context,
                snapshot,
              ) {
                final docs =
                    snapshot.data?.docs ??
                    [];
                String currentStage = 'Not Configured';

                if (docs.isNotEmpty) {
                  // Find the current active stage safely without strict orElse typing issues
                  final matchingDocs = docs
                      .where(
                        (
                          d,
                        ) =>
                            (d.data()['isCurrent'] ??
                                false) ==
                            true,
                      )
                      .toList();
                  final currentDoc = matchingDocs.isNotEmpty
                      ? matchingDocs.first
                      : docs.first;
                  currentStage =
                      currentDoc.data()['title'] ??
                      'Active';
                }

                return _SensorStatCard(
                  title: 'CURRENT STAGE',
                  value: currentStage,
                  icon: Icons.timeline,
                  color: Colors.blue,
                );
              },
        ),
        const SizedBox(
          height: 10,
        ),

        // 3. Active Operations / Tasks Count
        StreamBuilder<
          QuerySnapshot<
            Map<
              String,
              dynamic
            >
          >
        >(
          stream: FirebaseFirestore.instance
              .collection(
                'farmTasks',
              )
              .where(
                'farmName',
                isEqualTo: widget.farm.name,
              )
              .where(
                'taskProgress',
                whereIn: [
                  'In progress',
                  'Done - (Review)',
                ],
              )
              .snapshots(),
          builder:
              (
                context,
                snapshot,
              ) {
                final activeCount =
                    snapshot.data?.docs.length ??
                    0;

                return _SensorStatCard(
                  title: 'ACTIVE TASKS',
                  value: '$activeCount Pending',
                  icon: Icons.assignment_outlined,
                  color: Colors.amber.shade800,
                );
              },
        ),
        const SizedBox(
          height: 10,
        ),

        // 4. Map ID / Reference
        _SensorStatCard(
          title: 'MAPPING SOURCE',
          value: 'Google My Maps',
          icon: Icons.location_on_outlined,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildBottomSection(
    bool isDesktop,
  ) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: _buildAnalyticsPanel(),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildCropTimelinePanel(),
                const SizedBox(
                  height: 16,
                ),
                _buildWeatherPanel(),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        _buildAnalyticsPanel(),
        const SizedBox(
          height: 20,
        ),
        _buildCropTimelinePanel(),
        const SizedBox(
          height: 20,
        ),
        _buildWeatherPanel(),
      ],
    );
  }

  Widget _buildAnalyticsPanel() {
    return _AnalyticsPanelWidget(
      farmName: widget.farm.name,
      latitude: widget.farm.latitude,
      longitude: widget.farm.longitude,
    );
  }

  Widget _buildCropTimelinePanel() {
    const Color primaryColor = Color(
      0xFF1CB026,
    );

    void showManageTimelineDialog(
      BuildContext context,
    ) {
      final TextEditingController stageController = TextEditingController();
      DateTime selectedDate = DateTime.now();

      showDialog(
        context: context,
        builder:
            (
              context,
            ) {
              return StatefulBuilder(
                builder:
                    (
                      context,
                      setDialogState,
                    ) {
                      // Simple date formatter (e.g., "Apr 15, 2026")
                      String formatDate(
                        DateTime dt,
                      ) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
                      }

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        title: Text(
                          'Manage Timeline: ${widget.farm.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: SizedBox(
                          width: 400,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: stageController,
                                decoration: InputDecoration(
                                  labelText: 'Stage Title (e.g., Fertilization, Flowering)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              // Date Picker Trigger Row
                              InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(
                                      2020,
                                    ),
                                    lastDate: DateTime(
                                      2035,
                                    ),
                                    builder:
                                        (
                                          context,
                                          child,
                                        ) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: const ColorScheme.light(
                                                primary: primaryColor,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                  );
                                  if (picked !=
                                      null) {
                                    setDialogState(
                                      () {
                                        selectedDate = picked;
                                      },
                                    );
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Target Date',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ),
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                  ),
                                  child: Text(
                                    formatDate(
                                      selectedDate,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(
                              context,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final stage = stageController.text.trim();
                              final dateStr = formatDate(
                                selectedDate,
                              );

                              if (stage.isNotEmpty) {
                                await FirebaseFirestore.instance
                                    .collection(
                                      'farmTimelines',
                                    )
                                    .add(
                                      {
                                        'farmName': widget.farm.name,
                                        'title': stage,
                                        'date': dateStr,
                                        'isDone': false,
                                        'isCurrent': false,
                                        'createdAt': FieldValue.serverTimestamp(),
                                      },
                                    );

                                if (!context.mounted) return;
                                Navigator.pop(
                                  context,
                                );
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: primaryColor,
                                    content: Text(
                                      'Crop timeline stage added successfully!',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 0,
                            ),
                            child: const Text(
                              'Add Stage',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
              );
            },
      );
    }

    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: const Color(
            0xFFEFEFEF,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crop Timeline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => showManageTimelineDialog(
                  context,
                ),
                icon: const Icon(
                  Icons.add,
                  size: 14,
                  color: primaryColor,
                ),
                label: const Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(
                    50,
                    20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          StreamBuilder<
            QuerySnapshot<
              Map<
                String,
                dynamic
              >
            >
          >(
            stream: FirebaseFirestore.instance
                .collection(
                  'farmTimelines',
                )
                .where(
                  'farmName',
                  isEqualTo: widget.farm.name,
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
                          8.0,
                        ),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      ),
                    );
                  }

                  final docs =
                      snapshot.data?.docs ??
                      [];

                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: Text(
                        'No timeline stages configured. Click "Manage" above to add stages.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final doc = docs[index];
                          final data = doc.data();
                          final title =
                              data['title'] ??
                              'Stage';
                          final date =
                              data['date'] ??
                              '';
                          final isDone =
                              data['isDone'] ??
                              false;
                          final isCurrent =
                              data['isCurrent'] ??
                              (index ==
                                  0);

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      isDone
                                          ? Icons.check_circle
                                          : (isCurrent
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_unchecked),
                                      size: 16,
                                      color:
                                          isDone ||
                                              isCurrent
                                          ? primaryColor
                                          : Colors.grey[400],
                                    ),
                                    if (index <
                                        docs.length -
                                            1)
                                      Container(
                                        width: 2,
                                        height: 20,
                                        color: Colors.grey[300],
                                      ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isCurrent
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        date,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () async {
                                    await doc.reference.delete();
                                  },
                                  tooltip: 'Delete Stage',
                                ),
                              ],
                            ),
                          );
                        },
                  );
                },
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherPanel() {
    return _FarmWeatherPanelContent(
      latitude: widget.farm.latitude, // Adjust property names if your FarmModel differs (e.g. lat / lon)
      longitude: widget.farm.longitude,
    );
  }
}

class _AnalyticsPanelWidget
    extends
        StatefulWidget {
  final String farmName;
  final double latitude;
  final double longitude;

  const _AnalyticsPanelWidget({
    required this.farmName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<
    _AnalyticsPanelWidget
  >
  createState() => _AnalyticsPanelWidgetState();
}

class _AnalyticsPanelWidgetState
    extends
        State<
          _AnalyticsPanelWidget
        > {
  int _selectedTab = 0; // 0 = Sensor Analytics, 1 = Activity Log
  static const Color primaryColor = Color(
    0xFF1CB026,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: const Color(
            0xFFEFEFEF,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interactive Tab Header
          Row(
            children: [
              InkWell(
                onTap: () => setState(
                  () => _selectedTab = 0,
                ),
                child: Text(
                  'Sensor Analytics',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color:
                        _selectedTab ==
                            0
                        ? primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(
                width: 24,
              ),
              InkWell(
                onTap: () => setState(
                  () => _selectedTab = 1,
                ),
                child: Text(
                  'Activity Log',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color:
                        _selectedTab ==
                            1
                        ? primaryColor
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            height: 24,
          ),

          // Tab Content Area
          if (_selectedTab ==
              0) ...[
            const Text(
              'Real-time Field Monitoring & Weather Trends',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFAFAFA,
                ),
                borderRadius: BorderRadius.circular(
                  8,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFEFEFEF,
                  ),
                ),
              ),
              child: CustomPaint(
                painter: _SimpleChartPainter(),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Farm Operational History',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.farmName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              height: 220,
              child:
                  StreamBuilder<
                    QuerySnapshot<
                      Map<
                        String,
                        dynamic
                      >
                    >
                  >(
                    stream: FirebaseFirestore.instance
                        .collection(
                          'farmTasks',
                        )
                        .where(
                          'farmName',
                          isEqualTo: widget.farmName,
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            );
                          }

                          final tasks =
                              snapshot.data?.docs ??
                              [];

                          if (tasks.isEmpty) {
                            return const Center(
                              child: Text(
                                'No activity logged for this farm yet.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: tasks.length,
                            separatorBuilder:
                                (
                                  context,
                                  index,
                                ) => const Divider(
                                  height: 16,
                                ),
                            itemBuilder:
                                (
                                  context,
                                  index,
                                ) {
                                  final taskData = tasks[index].data();
                                  final title =
                                      taskData['taskTitle'] ??
                                      'Task';
                                  final progress =
                                      taskData['taskProgress'] ??
                                      'Not started';
                                  final workerName =
                                      taskData['assignedToName'] ??
                                      'Unassigned';

                                  Color badgeColor = Colors.grey;
                                  if (progress ==
                                      'Done - (Approved)') {
                                    badgeColor = primaryColor;
                                  }
                                  if (progress ==
                                      'Done - (Review)') {
                                    badgeColor = Colors.amber.shade800;
                                  }
                                  if (progress ==
                                      'In progress') {
                                    badgeColor = Colors.blue;
                                  }

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.history_rounded,
                                            size: 16,
                                            color: primaryColor,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Worker: $workerName',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          progress,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: badgeColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                          );
                        },
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SensorStatCard
    extends
        StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SensorStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: const Color(
            0xFFEFEFEF,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(
              0.1,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleChartPainter
    extends
        CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint1 = Paint()
      ..color = const Color(
        0xFF1CB026,
      )
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke; // Corrected style assignment
    final path1 = Path()
      ..moveTo(
        0,
        size.height *
            0.7,
      )
      ..cubicTo(
        size.width *
            0.25,
        size.height *
            0.3,
        size.width *
            0.5,
        size.height *
            0.5,
        size.width,
        size.height *
            0.2,
      );

    canvas.drawPath(
      path1,
      paint1,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}

class _FarmWeatherPanelContent
    extends
        StatefulWidget {
  final double latitude;
  final double longitude;

  const _FarmWeatherPanelContent({
    required this.latitude,
    required this.longitude,
  });

  @override
  State<
    _FarmWeatherPanelContent
  >
  createState() => _FarmWeatherPanelContentState();
}

class _FarmWeatherPanelContentState
    extends
        State<
          _FarmWeatherPanelContent
        > {
  bool _isLoading = true;
  double _temperature = 0.0;
  double _rainProbability = 0.0;
  double _rainAccumulation = 0.0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFarmWeather();
  }

  Future<
    void
  >
  _fetchFarmWeather() async {
    try {
      // Open-Meteo API query targeting the specific farm coordinates
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${widget.latitude}&longitude=${widget.longitude}&current=temperature_2m&hourly=precipitation_probability,precipitation',
      );

      final response = await http.get(
        url,
      );
      if (response.statusCode ==
          200) {
        final data = json.decode(
          response.body,
        );
        final currentTemp =
            data['current']['temperature_2m'] ??
            0.0;

        final hourly = data['hourly'];
        final List<
          dynamic
        >
        probs =
            hourly['precipitation_probability'] ??
            [
              0.0,
            ];
        final List<
          dynamic
        >
        precip =
            hourly['precipitation'] ??
            [
              0.0,
            ];

        if (mounted) {
          setState(
            () {
              _temperature = currentTemp.toDouble();
              _rainProbability =
                  (probs.isNotEmpty
                          ? probs[0]
                          : 0.0)
                      .toDouble();
              _rainAccumulation =
                  (precip.isNotEmpty
                          ? precip[0]
                          : 0.0)
                      .toDouble();
              _isLoading = false;
            },
          );
        }
      } else {
        if (mounted) {
          setState(
            () {
              _isLoading = false;
              _errorMessage = 'Unavailable';
            },
          );
        }
      }
    } catch (
      e
    ) {
      if (mounted) {
        setState(
          () {
            _isLoading = false;
            _errorMessage = 'Error';
          },
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    const Color primaryColor = Color(
      0xFF1CB026,
    );

    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: const Color(
            0xFFEFEFEF,
          ),
        ),
      ),
      child: _isLoading
          ? const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              ),
            )
          : _errorMessage.isNotEmpty
          ? const Text(
              'Weather data unavailable',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Farm Local Weather',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      '${_temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      '🌧️ Rain Prob: ${_rainProbability.toStringAsFixed(0)}% | Rain: ${_rainAccumulation.toStringAsFixed(1)}mm',
                      style: const TextStyle(
                        fontSize: 10,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.wb_sunny_outlined,
                  size: 28,
                  color: primaryColor,
                ),
              ],
            ),
    );
  }
}
