import 'package:flutter/material.dart';
import 'package:phoebe_admin/blocs/admin_bloc.dart';
import 'package:phoebe_admin/utils/dialog.dart';
import 'package:phoebe_admin/utils/styles.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final formKey = GlobalKey<FormState>();
  var passwordOldCtrl = TextEditingController();
  var passwordNewCtrl = TextEditingController();
  bool changeStarted = false;

  Future handleChange() async {
    final ab = context.read<AdminBloc>();
    if (ab.userType == 'tester') {
      openDialog(context, 'You are a Tester', 'Only Admin can change password');
    } else {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        setState(() {
          changeStarted = true;
        });
        await context
            .read<AdminBloc>()
            .saveNewAdminPassword(passwordNewCtrl.text)
            .then((value) =>
                openDialog(context, 'Password has changed successfully!', ''));
        setState(() {
          changeStarted = false;
        });
        clearTextFields();
      }
    }
  }

  clearTextFields() {
    passwordOldCtrl.clear();
    passwordNewCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final String? adminPass = context.watch<AdminBloc>().adminPass;
    final double w = MediaQuery.of(context).size.width;
    return Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 30),
        padding: EdgeInsets.only(
          left: w * 0.05,
          right: w * 0.20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[300]!, blurRadius: 10, offset: Offset(3, 3))
          ],
        ),
        child: Container(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Text(
                  "Change Admin Password",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 10),
                  height: 3,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.indigoAccent,
                      borderRadius: BorderRadius.circular(15)),
                ),
                SizedBox(
                  height: 60,
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: passwordOldCtrl,
                        decoration: inputDecoration('Enter old password',
                            'Old Password', passwordOldCtrl),
                        validator: (String? value) {
                          if (value!.isEmpty) return 'Old password is empty!';
                          if (value != adminPass)
                            return 'Old Password is wrong. Try again';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: passwordNewCtrl,
                        decoration: inputDecoration('Enter new password',
                            'New Password', passwordNewCtrl),
                        obscureText: true,
                        validator: (String? value) {
                          if (value!.isEmpty) return 'New password is empty!';
                          if (value == adminPass)
                            return 'Please use a different password';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.deepPurpleAccent,
                          height: 45,
                          child: changeStarted == true
                              ? Center(
                                  child: Container(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator()),
                                )
                              : TextButton(
                                  child: Text(
                                    'Update Password',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () async {
                                    handleChange();
                                  })),
                    ],
                  ),
                )
              ],
            )));
  }
}
