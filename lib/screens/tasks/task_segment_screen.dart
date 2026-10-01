import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';

class TaskSegmentScreen
    extends
        StatelessWidget {
  const TaskSegmentScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Segments',
        ),
        backgroundColor: primaryGreenColor,
        foregroundColor: Colors.white,
      ),
      body:
          StreamBuilder<
            QuerySnapshot
          >(
            stream: FirebaseFirestore.instance
                .collection(
                  'task_segments',
                )
                .orderBy(
                  'createdAt',
                  descending: false,
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
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading task segments: ${snapshot.error}',
                      ),
                    );
                  }

                  final docs =
                      snapshot.data?.docs ??
                      [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.segment,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            'No task stages created yet.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Tap "+ Add New Stage" to create a stage with tasks.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(
                      16.0,
                    ),
                    itemCount: docs.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final doc = docs[index];
                          final data =
                              doc.data()
                                  as Map<
                                    String,
                                    dynamic
                                  >;
                          final String stageName =
                              data['stage'] ??
                              'Unnamed Stage';
                          final List<
                            dynamic
                          >
                          rawTasks =
                              data['tasks'] ??
                              [];
                          final List<
                            String
                          >
                          tasks =
                              List<
                                String
                              >.from(
                                rawTasks,
                              );

                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 16.0,
                            ),
                            elevation: 3,
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
                                children: [
                                  // Stage Header
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryGreenColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          stageName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: primaryGreenColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Add sub-task to existing stage
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: primaryGreenColor,
                                        ),
                                        tooltip: 'Add task to this stage',
                                        onPressed: () => _showAddTaskToStageDialog(
                                          context,
                                          doc.id,
                                          stageName,
                                        ),
                                      ),
                                      // Delete entire stage
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        tooltip: 'Delete Stage',
                                        onPressed: () => _deleteStage(
                                          doc.id,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  const Divider(
                                    height: 1,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),

                                  // List of Tasks under this stage
                                  if (tasks.isEmpty)
                                    const Text(
                                      'No tasks added to this stage yet.',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: tasks.length,
                                      separatorBuilder:
                                          (
                                            context,
                                            i,
                                          ) => const SizedBox(
                                            height: 6,
                                          ),
                                      itemBuilder:
                                          (
                                            context,
                                            taskIndex,
                                          ) {
                                            final task = tasks[taskIndex];
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(
                                                  8,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle_outline,
                                                    size: 18,
                                                    color: primaryGreenColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      task,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  // Delete single sub-task
                                                  InkWell(
                                                    onTap: () => _removeTaskFromStage(
                                                      doc.id,
                                                      task,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 18,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                  );
                },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateStageDialog(
          context,
        ),
        backgroundColor: primaryGreenColor,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Add New Stage',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // DIALOG 1: Create a Stage + Multiple Tasks
  void _showCreateStageDialog(
    BuildContext context,
  ) {
    final TextEditingController stageController = TextEditingController();
    final TextEditingController taskInputController = TextEditingController();
    final List<
      String
    >
    tempTaskList = [];

    showDialog(
      context: context,
      builder:
          (
            dialogContext,
          ) {
            return StatefulBuilder(
              builder:
                  (
                    context,
                    setState,
                  ) {
                    void addTask() {
                      final text = taskInputController.text.trim();
                      if (text.isNotEmpty) {
                        setState(
                          () {
                            tempTaskList.add(
                              text,
                            );
                            taskInputController.clear();
                          },
                        );
                      }
                    }

                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            24.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add Stage & Tasks',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              // Stage Name Input
                              TextField(
                                controller: stageController,
                                decoration: InputDecoration(
                                  labelText: 'Stage Name',
                                  hintText: 'e.g., Planning',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.category_outlined,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              // Task Name Input with (+) Add Button
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: taskInputController,
                                      decoration: InputDecoration(
                                        labelText: 'Task Name',
                                        hintText: 'e.g., Field inspection',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.assignment_outlined,
                                        ),
                                      ),
                                      onSubmitted:
                                          (
                                            _,
                                          ) => addTask(),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  ElevatedButton(
                                    onPressed: addTask,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreenColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              // Preview Chips of added tasks
                              if (tempTaskList.isNotEmpty) ...[
                                const Text(
                                  'Tasks to be included:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: tempTaskList.map(
                                    (
                                      task,
                                    ) {
                                      return Chip(
                                        label: Text(
                                          task,
                                        ),
                                        backgroundColor: primaryGreenColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        deleteIcon: const Icon(
                                          Icons.cancel,
                                          size: 18,
                                        ),
                                        onDeleted: () {
                                          setState(
                                            () {
                                              tempTaskList.remove(
                                                task,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ).toList(),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                              ],

                              // Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.of(
                                      dialogContext,
                                    ).pop(),
                                    child: const Text(
                                      'Cancel',
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final stage = stageController.text.trim();

                                      if (stage.isEmpty) {
                                        EasyLoading.showError(
                                          'Please enter a Stage name',
                                        );
                                        return;
                                      }

                                      EasyLoading.show(
                                        status: 'Saving...',
                                      );
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection(
                                              'task_segments',
                                            )
                                            .add(
                                              {
                                                'stage': stage,
                                                'tasks': tempTaskList,
                                                'createdAt': FieldValue.serverTimestamp(),
                                              },
                                            );

                                        if (context.mounted) {
                                          Navigator.of(
                                            dialogContext,
                                          ).pop();
                                        }
                                        EasyLoading.showSuccess(
                                          'Stage saved!',
                                        );
                                      } catch (
                                        e
                                      ) {
                                        EasyLoading.showError(
                                          'Failed to save stage',
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreenColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Save Stage',
                                      style: TextStyle(
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
                    );
                  },
            );
          },
    );
  }

  // DIALOG 2: Add a new task to an existing Stage
  void _showAddTaskToStageDialog(
    BuildContext context,
    String docId,
    String stageName,
  ) {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (
            dialogContext,
          ) {
            return AlertDialog(
              title: Text(
                'Add Task to "$stageName"',
              ),
              content: TextField(
                controller: taskController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'e.g., Water testing',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(
                    dialogContext,
                  ).pop(),
                  child: const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newTask = taskController.text.trim();
                    if (newTask.isEmpty) return;

                    EasyLoading.show(
                      status: 'Adding task...',
                    );
                    try {
                      await FirebaseFirestore.instance
                          .collection(
                            'task_segments',
                          )
                          .doc(
                            docId,
                          )
                          .update(
                            {
                              'tasks': FieldValue.arrayUnion(
                                [
                                  newTask,
                                ],
                              ),
                            },
                          );

                      if (context.mounted) {
                        Navigator.of(
                          dialogContext,
                        ).pop();
                      }
                      EasyLoading.showSuccess(
                        'Task added!',
                      );
                    } catch (
                      e
                    ) {
                      EasyLoading.showError(
                        'Failed to add task',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreenColor,
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }

  // HELPER: Remove single task from array
  Future<
    void
  >
  _removeTaskFromStage(
    String docId,
    String taskName,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection(
            'task_segments',
          )
          .doc(
            docId,
          )
          .update(
            {
              'tasks': FieldValue.arrayRemove(
                [
                  taskName,
                ],
              ),
            },
          );
      EasyLoading.showToast(
        'Task removed',
      );
    } catch (
      e
    ) {
      EasyLoading.showError(
        'Failed to remove task',
      );
    }
  }

  // HELPER: Delete entire stage
  Future<
    void
  >
  _deleteStage(
    String docId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection(
            'task_segments',
          )
          .doc(
            docId,
          )
          .delete();
      EasyLoading.showToast(
        'Stage deleted',
      );
    } catch (
      e
    ) {
      EasyLoading.showError(
        'Failed to delete stage',
      );
    }
  }
}
