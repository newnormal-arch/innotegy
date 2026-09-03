import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/services/auth_service.dart';

class FarmDashboard
    extends
        StatelessWidget {
  const FarmDashboard({
    super.key,
  });

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Manage Farms',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Manage all Farms",
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
                          newFarmDialog(
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
                          'Add New Farm',
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
              SizedBox(
                height: 40,
              ),
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Farm Owner',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Farm Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Area/Town',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Size (ha)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              StreamBuilder<
                QuerySnapshot
              >(
                stream: FirebaseFirestore.instance
                    .collection(
                      'farms',
                    )
                    .snapshots(),
                builder:
                    (
                      context,
                      snapshot,
                    ) {
                      if (snapshot.hasData) {
                        final List<
                          DocumentSnapshot
                        >
                        documents = snapshot.data!.docs;
                        return ListView(
                          shrinkWrap: true,
                          children: documents.map(
                            (
                              doc,
                            ) {
                              return Container(
                                // color: rowColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        doc['farmOwner']!,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        doc['farmName']!,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        doc['farmArea']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        doc['farmSize']!,
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        doc['farmStatus']!,
                                        style: TextStyle(
                                          color:
                                              doc['farmStatus'] ==
                                                  'Active'
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        alignment: Alignment.centerLeft,
                                        hoverColor: Colors.transparent,
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          // Handle edit action

                                          // _updateFarmerDetailsDialog(
                                          //   context,
                                          //   doc.id,
                                          //   doc['fullName'],
                                          // );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        alignment: Alignment.centerLeft,
                                        hoverColor: Colors.transparent,
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          // Handle delete action
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                        );
                      }
                      return const CircularProgressIndicator();
                    },
              ),
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
newFarmDialog(
  BuildContext context,
) {
  final TextEditingController farmOwnerController = TextEditingController();
  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController farmAreaController = TextEditingController();
  final TextEditingController farmLocationController = TextEditingController();
  final TextEditingController farmSizeController = TextEditingController();

  return showDialog(
    context: context,
    builder:
        (
          context,
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
                  'Add New Farm',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: farmOwnerController,
                  decoration: InputDecoration(
                    labelText: 'Farm Owner',
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
                  controller: farmNameController,
                  decoration: InputDecoration(
                    labelText: 'Farm Name',
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
                  controller: farmAreaController,
                  decoration: InputDecoration(
                    labelText: 'Farm Area/Town',
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
                  controller: farmLocationController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Farm Address',
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
                  controller: farmSizeController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Farm Size',
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
                        // Handle farm creation logic here
                        EasyLoading.show(
                          status: 'Adding Farm...',
                        );
                        try {
                          await authService.value
                              .saveFarmData(
                                farmOwner: farmOwnerController.text,
                                farmName: farmNameController.text,
                                farmLocation: farmLocationController.text,
                                farmArea: farmAreaController.text,
                                farmSize: farmSizeController.text,
                              )
                              .then(
                                (
                                  value,
                                ) {
                                  print(
                                    'Farm added successfully',
                                  );

                                  Navigator.of(
                                    context,
                                  ).pop();
                                  EasyLoading.dismiss();
                                },
                              );
                        } on FirebaseAuthException catch (
                          e
                        ) {
                          print(
                            'Error: ${e.message}',
                          );
                          EasyLoading.showError(
                            e.message ??
                                'An error occurred',
                          );
                        }
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
                        'Add Farm',
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
  );
}
