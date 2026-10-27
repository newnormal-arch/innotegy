import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innotegy/widgets/app_sidebar.dart';

class TaskManagementScreen
    extends
        StatefulWidget {
  const TaskManagementScreen({
    super.key,
  });

  @override
  State<
    TaskManagementScreen
  >
  createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState
    extends
        State<
          TaskManagementScreen
        > {
  static const Color primaryColor = Color(
    0xFF1CB026,
  );

  /// Dialog to add a new stage segment
  void _showAddStageDialog(
    BuildContext context,
  ) {
    final TextEditingController stageNameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (
            context,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              title: const Text(
                'Add New Task Stage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: TextField(
                controller: stageNameController,
                decoration: InputDecoration(
                  hintText: 'Stage Name (e.g., In Progress, Review, Completed)',
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
                    final name = stageNameController.text.trim();
                    if (name.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection(
                            'task_segments',
                          )
                          .add(
                            {
                              'stageName': name,
                              'tasks': [],
                              'createdAt': FieldValue.serverTimestamp(),
                            },
                          );
                      if (context.mounted)
                        Navigator.pop(
                          context,
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
  }

  /// Dialog to add a task under a specific stage document
  void _showAddTaskDialog(
    BuildContext context,
    String stageDocId,
    String stageName,
  ) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (
            context,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              title: Text(
                'Add Task to "$stageName"',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Task Title',
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
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Task Description / Notes',
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
                    ),
                  ),
                ],
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
                    final title = titleController.text.trim();
                    final desc = descController.text.trim();

                    if (title.isNotEmpty) {
                      final newTask = {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': title,
                        'description': desc,
                        'createdAt': DateTime.now().toIso8601String(),
                      };

                      await FirebaseFirestore.instance
                          .collection(
                            'task_segments',
                          )
                          .doc(
                            stageDocId,
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

                      if (context.mounted)
                        Navigator.pop(
                          context,
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
                  child: const Text(
                    'Add Task',
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
  }

  /// Delete an entire stage segment from Firestore
  void _deleteStage(
    String stageDocId,
    String stageName,
  ) {
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: const Text(
              'Delete Stage',
            ),
            content: Text(
              'Are you sure you want to delete "$stageName" and all its tasks?',
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
                  await FirebaseFirestore.instance
                      .collection(
                        'task_segments',
                      )
                      .doc(
                        stageDocId,
                      )
                      .delete();
                  if (context.mounted)
                    Navigator.pop(
                      context,
                    );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Remove a specific task from a stage's tasks array
  void _deleteTask(
    String stageDocId,
    Map<
      String,
      dynamic
    >
    taskMap,
  ) async {
    await FirebaseFirestore.instance
        .collection(
          'task_segments',
        )
        .doc(
          stageDocId,
        )
        .update(
          {
            'tasks': FieldValue.arrayRemove(
              [
                taskMap,
              ],
            ),
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
      drawer: isDesktop
          ? null
          : const AppSidebarDrawer(
              activeRoute: 'Tasks',
            ),
      body: Column(
        children: [
          const _TopNavBar(),
          Expanded(
            child: Row(
              children: [
                if (isDesktop)
                  const SizedBox(
                    width: 220,
                    child: AppSidebarContent(
                      activeRoute: 'Tasks',
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
                        // Header Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Management',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                      0xFF1A1A1A,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Manage operational stages and expand to view assigned sub-tasks.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAddStageDialog(
                                context,
                              ),
                              icon: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Add Stage',
                                style: TextStyle(
                                  color: Colors.white,
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
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),

                        // Collapsible Stages List Stream View
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
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error loading task stages: ${snapshot.error}',
                                    ),
                                  );
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        32.0,
                                      ),
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                }

                                final docs =
                                    snapshot.data?.docs ??
                                    [];

                                if (docs.isEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(
                                      32,
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
                                    child: const Center(
                                      child: Text(
                                        'No task stages found. Click "Add Stage" above to create one.',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
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
                                        final stageData = doc.data();
                                        final stageName =
                                            stageData['stageName'] ??
                                            'Unnamed Stage';
                                        final List rawTasks =
                                            stageData['tasks'] ??
                                            [];
                                        final tasks = rawTasks
                                            .cast<
                                              Map<
                                                String,
                                                dynamic
                                              >
                                            >();

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
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
                                          child: Theme(
                                            data:
                                                Theme.of(
                                                  context,
                                                ).copyWith(
                                                  dividerColor: Colors.transparent,
                                                ),
                                            child: ExpansionTile(
                                              initiallyExpanded:
                                                  index ==
                                                  0,
                                              tilePadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 4,
                                              ),
                                              leading: const CircleAvatar(
                                                radius: 14,
                                                backgroundColor: Color(
                                                  0xFFF2F2F2,
                                                ),
                                                child: Icon(
                                                  Icons.folder_outlined,
                                                  size: 16,
                                                  color: primaryColor,
                                                ),
                                              ),
                                              title: Row(
                                                children: [
                                                  Text(
                                                    stageName,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(
                                                        0xFF1A1A1A,
                                                      ),
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
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${tasks.length} Task${tasks.length == 1 ? '' : 's'}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.add_circle_outline,
                                                      color: primaryColor,
                                                      size: 20,
                                                    ),
                                                    onPressed: () => _showAddTaskDialog(
                                                      context,
                                                      doc.id,
                                                      stageName,
                                                    ),
                                                    tooltip: 'Add Sub-task',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                      size: 20,
                                                    ),
                                                    onPressed: () => _deleteStage(
                                                      doc.id,
                                                      stageName,
                                                    ),
                                                    tooltip: 'Delete Stage',
                                                  ),
                                                ],
                                              ),
                                              children: [
                                                const Divider(
                                                  height: 1,
                                                  color: Color(
                                                    0xFFEFEFEF,
                                                  ),
                                                ),
                                                if (tasks.isEmpty)
                                                  const Padding(
                                                    padding: EdgeInsets.all(
                                                      20.0,
                                                    ),
                                                    child: Text(
                                                      'No tasks added under this stage yet.',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  ListView.separated(
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    padding: const EdgeInsets.all(
                                                      16,
                                                    ),
                                                    itemCount: tasks.length,
                                                    separatorBuilder:
                                                        (
                                                          context,
                                                          idx,
                                                        ) => const SizedBox(
                                                          height: 8,
                                                        ),
                                                    itemBuilder:
                                                        (
                                                          context,
                                                          taskIdx,
                                                        ) {
                                                          final task = tasks[taskIdx];
                                                          final title =
                                                              task['title'] ??
                                                              'Untitled Task';
                                                          final description =
                                                              task['description'] ??
                                                              '';

                                                          return Container(
                                                            padding: const EdgeInsets.all(
                                                              12,
                                                            ),
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
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Icon(
                                                                  Icons.task_alt,
                                                                  size: 18,
                                                                  color: primaryColor,
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
                                                                        style: const TextStyle(
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      if (description.isNotEmpty) ...[
                                                                        const SizedBox(
                                                                          height: 4,
                                                                        ),
                                                                        Text(
                                                                          description,
                                                                          style: TextStyle(
                                                                            fontSize: 11,
                                                                            color: Colors.grey[600],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  icon: const Icon(
                                                                    Icons.close,
                                                                    size: 16,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  onPressed: () => _deleteTask(
                                                                    doc.id,
                                                                    task,
                                                                  ),
                                                                  tooltip: 'Delete Task',
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic Top Navigation Bar
class _TopNavBar
    extends
        StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDesktop =
        MediaQuery.of(
          context,
        ).size.width >=
        1024;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
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
          if (!isDesktop)
            IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              onPressed: () => Scaffold.of(
                context,
              ).openDrawer(),
            ),
          const Spacer(),
          if (currentUser !=
              null)
            StreamBuilder<
              DocumentSnapshot<
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
                  .doc(
                    currentUser.uid,
                  )
                  .snapshots(),
              builder:
                  (
                    context,
                    snapshot,
                  ) {
                    String fullName = 'Manager';
                    String userRole = 'Manager';

                    if (snapshot.hasData &&
                        snapshot.data!.exists) {
                      final data = snapshot.data!.data();
                      fullName =
                          data?['fullName'] ??
                          'Manager';
                      userRole =
                          data?['userRole'] ??
                          'Manager';
                    }

                    return Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userRole,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?img=47',
                          ),
                        ),
                      ],
                    );
                  },
            ),
        ],
      ),
    );
  }
}
