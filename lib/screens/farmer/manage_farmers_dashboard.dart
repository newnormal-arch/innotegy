import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:innotegy/constants.dart';

import 'package:innotegy/models/farm_model.dart';

import 'package:innotegy/services/auth_service.dart';

class ManageFarmersDashboard
    extends
        StatefulWidget {
  const ManageFarmersDashboard({
    super.key,
  });

  @override
  State<
    ManageFarmersDashboard
  >
  createState() => _ManageFarmersDashboardState();
}

class _ManageFarmersDashboardState
    extends
        State<
          ManageFarmersDashboard
        > {
  final TextEditingController farmerEmailController = TextEditingController();

  final TextEditingController farmerPasswordController = TextEditingController();

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
                        'Manage Farmers',

                        style: TextStyle(
                          fontSize: 24,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Manage all farmers and their access",

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
                          _newFarmerDialog(
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
                          'Create Farmer Account',

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
                        'Full Name',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,

                      child: Text(
                        'Email',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,

                      child: Text(
                        'Role',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,

                      child: Text(
                        'Allocated Farm',

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
                      'farmer',
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
                                        doc['fullName']!,
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,

                                      child: Text(
                                        doc['email']!,

                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,

                                      child: Text(
                                        doc['role']!,
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        doc['allocatedFarm'] ??
                                            '',
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,

                                      child: Text(
                                        doc['status']!,

                                        style: TextStyle(
                                          color:
                                              doc['status'] ==
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
                                          _updateFarmerDetailsDialog(
                                            context,

                                            doc.id,

                                            doc
                                                            .data() !=
                                                        null &&
                                                    (doc.data()
                                                            as Map)
                                                        .containsKey(
                                                          'fullName',
                                                        )
                                                ? doc['fullName']
                                                : 'Unknown',

                                            [],
                                          );
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
_newFarmerDialog(
  BuildContext context,
) {
  final TextEditingController farmerEmailController = TextEditingController();

  final TextEditingController farmerPasswordController = TextEditingController();

  final TextEditingController farmerFullNameController = TextEditingController();

  final TextEditingController farmerPhoneNumberController = TextEditingController();

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
                  'Create Farmer Account',

                  style: TextStyle(
                    fontSize: 30,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(
                  height: 30,
                ),

                TextField(
                  controller: farmerFullNameController,

                  decoration: InputDecoration(
                    labelText: 'Full Name',

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
                  controller: farmerPhoneNumberController,

                  keyboardType: TextInputType.phone,

                  decoration: InputDecoration(
                    labelText: 'Phone Number',

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
                  controller: farmerEmailController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: 'Email Address',

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
                  controller: farmerPasswordController,

                  keyboardType: TextInputType.visiblePassword,

                  decoration: InputDecoration(
                    labelText: 'Password',

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
                        // Handle task creation logic here

                        EasyLoading.show(
                          status: 'Signing Up...',
                        );

                        try {
                          await authService.value
                              .signUp(
                                email: farmerEmailController.text.trim(),

                                password: farmerPasswordController.text.trim(),
                              )
                              .then(
                                (
                                  value,
                                ) {
                                  print(
                                    'User signed up Farmer Successfully',
                                  );

                                  authService.value.saveUserData(
                                    fullName: farmerFullNameController.text,

                                    email: farmerEmailController.text,

                                    phone: farmerPhoneNumberController.text,
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
                        'Create Account',

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

// Update Farmer Details Dialog

Future<
  dynamic
>
_updateFarmerDetailsDialog(
  BuildContext context,

  String docId,

  String fullName,

  List<
    FarmModel
  >
  farms, // Pass the fetched farms list here
) async {
  final List<
    String
  >
  roles = [
    'Planter',

    'Harvester',

    'Driver',
  ];

  final List<
    String
  >
  farmerStatus = [
    'Active',

    'Inactive',
  ];

  // Track current selected options

  String? selectedRole;

  String? selectedStatus;

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
                insetPadding: const EdgeInsets.symmetric(
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
                      const Text(
                        'Update Farmer Details',

                        style: TextStyle(
                          fontSize: 30,

                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      TextField(
                        controller: TextEditingController(
                          text: fullName,
                        ),

                        readOnly: true,

                        enabled: false,

                        decoration: InputDecoration(
                          labelText: 'Full Name',

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      DropdownButtonFormField<
                        String
                      >(
                        initialValue: selectedRole,

                        hint: const Text(
                          'Select Farmer Role',
                        ),

                        decoration: const InputDecoration(
                          labelText: 'User Role',

                          border: OutlineInputBorder(),
                        ),

                        items: roles.map(
                          (
                            String role,
                          ) {
                            return DropdownMenuItem<
                              String
                            >(
                              value: role,

                              child: Text(
                                role,
                              ),
                            );
                          },
                        ).toList(),

                        onChanged:
                            (
                              String? newValue,
                            ) {
                              setState(
                                () {
                                  selectedRole = newValue;
                                },
                              );
                            },

                        validator:
                            (
                              value,
                            ) {
                              if (value ==
                                      null ||
                                  value.isEmpty) {
                                return 'Please select a role to proceed';
                              }

                              return null;
                            },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      DropdownButtonFormField<
                        String
                      >(
                        initialValue: selectedStatus,

                        hint: const Text(
                          'Select Farmer Status',
                        ),

                        decoration: const InputDecoration(
                          labelText: 'Farmer Status',

                          border: OutlineInputBorder(),
                        ),

                        items: farmerStatus.map(
                          (
                            String status,
                          ) {
                            return DropdownMenuItem<
                              String
                            >(
                              value: status,

                              child: Text(
                                status,
                              ),
                            );
                          },
                        ).toList(),

                        onChanged:
                            (
                              String? newValue,
                            ) {
                              setState(
                                () {
                                  selectedStatus = newValue;
                                },
                              );
                            },

                        validator:
                            (
                              value,
                            ) {
                              if (value ==
                                      null ||
                                  value.isEmpty) {
                                return 'Please select status to proceed';
                              }

                              return null;
                            },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // --- ADDED: Farm Dropdown Field ---

                      // Action Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(
                                context,
                              ).pop();
                            },

                            child: const Text(
                              'Cancel',
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          ElevatedButton(
                            onPressed: () async {
                              try {
                                if (selectedRole !=
                                        null &&
                                    selectedStatus !=
                                        null) {
                                  await FirebaseFirestore.instance
                                      .collection(
                                        'farmer',
                                      )
                                      .doc(
                                        docId,
                                      )
                                      .update(
                                        {
                                          'role': selectedRole,

                                          'status': selectedStatus,
                                        },
                                      );

                                  EasyLoading.showSuccess(
                                    'Farmer details updated successfully',
                                  );
                                } else {
                                  EasyLoading.showError(
                                    'Please select role, status, and assigned farm to proceed',
                                  );
                                }
                              } catch (
                                e
                              ) {
                                EasyLoading.showError(
                                  'Failed to update farmer details',
                                );
                              }

                              Navigator.pop(
                                context,
                              );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreenColor,

                              padding: const EdgeInsets.symmetric(
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
                              'Update Details',

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
