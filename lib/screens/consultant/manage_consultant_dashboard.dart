import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:innotegy/constants.dart';
import 'package:innotegy/services/auth_service.dart';

class ManageConsultantDashboard
    extends
        StatefulWidget {
  const ManageConsultantDashboard({
    super.key,
  });

  @override
  State<
    ManageConsultantDashboard
  >
  createState() => _ManageConsultantDashboardState();
}

class _ManageConsultantDashboardState
    extends
        State<
          ManageConsultantDashboard
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
                        'Manage Consultants',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Manage all consultants and their access",
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
                          _newConsultantDialog(
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
                          'Create Consultant Account',
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
                      'consultant',
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

                                        onPressed: () {},
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
_newConsultantDialog(
  BuildContext context,
) {
  final TextEditingController consultantEmailController = TextEditingController();
  final TextEditingController consultantPasswordController = TextEditingController();
  final TextEditingController consultantFullNameController = TextEditingController();
  final TextEditingController consultantPhoneNumberController = TextEditingController();

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
                  'Create Consultant Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: consultantFullNameController,
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
                  controller: consultantPhoneNumberController,
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
                  controller: consultantEmailController,
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
                  controller: consultantPasswordController,
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
                                email: consultantEmailController.text.trim(),
                                password: consultantPasswordController.text.trim(),
                              )
                              .then(
                                (
                                  value,
                                ) {
                                  authService.value.saveConsultantData(
                                    fullName: consultantFullNameController.text,
                                    email: consultantEmailController.text,
                                    phone: consultantPhoneNumberController.text,
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
