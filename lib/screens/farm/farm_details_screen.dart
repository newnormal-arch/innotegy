import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                                      value: selectedUserId,
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
                                        value: selectedStageDocId,
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
                                value: selectedTaskTitle,
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
                                        value: selectedWorkerId,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
            child: _buildSensorMetricsList(),
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
        _buildSensorMetricsList(),
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

  Widget _buildSensorMetricsList() {
    return Column(
      children: const [
        _SensorStatCard(
          title: 'SOIL MOISTURE',
          value: '28.4%',
          icon: Icons.water_drop,
          color: primaryColor,
        ),
        SizedBox(
          height: 10,
        ),
        _SensorStatCard(
          title: 'NITROGEN LEVEL',
          value: '42mg/kg',
          icon: Icons.science_outlined,
          color: Colors.blue,
        ),
        SizedBox(
          height: 10,
        ),
        _SensorStatCard(
          title: 'SOIL TEMP',
          value: '21.5°C',
          icon: Icons.thermostat,
          color: Colors.amber,
        ),
        SizedBox(
          height: 10,
        ),
        _SensorStatCard(
          title: 'PEST RISK',
          value: 'Low',
          icon: Icons.bug_report_outlined,
          color: Colors.grey,
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
          const Row(
            children: [
              Text(
                'Sensor Analytics',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Activity Log',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Divider(
            height: 24,
          ),
          const Text(
            'Real-time Field Monitoring',
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
            ),
            child: CustomPaint(
              painter: _SimpleChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropTimelinePanel() {
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
          const Text(
            'Crop Timeline',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          const _TimelineItem(
            title: 'Seeding',
            date: 'Mar 15, 2024',
            isDone: true,
          ),
          const _TimelineItem(
            title: 'Germination',
            date: 'Mar 28, 2024',
            isDone: true,
          ),
          const _TimelineItem(
            title: 'Vegetative Growth',
            date: 'In Progress',
            isCurrent: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherPanel() {
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Local Weather',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                '24°C',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
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

class _TimelineItem
    extends
        StatelessWidget {
  final String title;
  final String date;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.date,
    this.isDone = false,
    this.isCurrent = false,
    this.isLast = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final color =
        isDone ||
            isCurrent
        ? const Color(
            0xFF1CB026,
          )
        : Colors.grey[400]!;

    return Row(
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
              color: color,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
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
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ],
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
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

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
