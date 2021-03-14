import 'package:contacts_service/contacts_service.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import 'const/gradiant_const.dart';

class ContactPage extends StatefulWidget {
  final String phno;
  final String email;
  ContactPage(this.phno, this.email);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  TextEditingController _email;
  TextEditingController _name;
  TextEditingController _phone;
  double width, height;
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.email);
    _phone = TextEditingController(text: widget.phno);
    _name = TextEditingController();
  }

  Future<void> saveContactInPhone() async {
    try {
      PermissionStatus permission = await Permission.contacts.status;

      if (permission != PermissionStatus.granted) {
        await Permission.contacts.request();
        PermissionStatus permission = await Permission.contacts.status;

        if (permission == PermissionStatus.granted) {
          Contact newContact = new Contact();
          newContact.givenName = _name.text;
          newContact.emails = [Item(label: "email", value: _email.text)];
          // newContact.company = myController2.text;
          newContact.phones = [Item(label: "mobile", value: _phone.text)];
          // newContact.postalAddresses = [
          //   PostalAddress(region: myController6.text)
          // ];
          await ContactsService.addContact(newContact);
        } else {
          //_handleInvalidPermissions(context);
        }
      } else {
        Contact newContact = new Contact();
        newContact.givenName = _name.text;
        newContact.emails = [Item(label: "email", value: _email.text)];
        // newContact.company = myController2.text;
        newContact.phones = [Item(label: "mobile", value: _phone.text)];

        await ContactsService.addContact(newContact);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
        appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              "Scanned detail",
              style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  decorationThickness: 10,
                  fontSize: 30),
            )),
        extendBodyBehindAppBar: true,
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Container(
                height: height,
                decoration: BoxDecoration(gradient: SIGNUP_BACKGROUND),
                padding: EdgeInsets.only(left: 10, right: 10, top: 200),
                child: Column(children: <Widget>[
                  TextFormField(
                    autovalidateMode: AutovalidateMode.disabled,
                    validator: (String value) {
                      if (value.isEmpty)
                        return 'Enter a name';
                      else
                        return null;
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                      ),
                      hintText: 'Enter Name',
                    ),
                    controller: _name,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    validator: (String value) {
                      Pattern pattern =
                          r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$";
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(value))
                        return 'Enter Valid Phone Number';
                      else
                        return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                        ),
                        hintText: 'Phone Number',
                        suffixIcon: IconButton(
                            icon: Icon(Icons.call,
                                color: Color.fromRGBO(7, 7, 7, 1)),
                            color: Colors.greenAccent,
                            onPressed: () async {
                              (await canLaunch("tel:${widget.phno}"))
                                  ? await launch("tel:${widget.phno}")
                                  : throw 'Could not launch ${widget.phno}';
                            })),
                    controller: _phone,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                        ),
                        hintText: 'Email ID',
                        suffixIcon: IconButton(
                            icon: Icon(Icons.mail, color: Colors.green[700]),
                            color: Colors.yellow,
                            onPressed: () async {
                              (await canLaunch("tel:${widget.email}"))
                                  ? await launch("tel:${widget.email}")
                                  : throw 'Could not launch ${widget.email}';
                            })),
                    controller: _email,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 140),
                    child: MaterialButton(
                      child: Text(
                        'Add to Contact',
                        style:
                            TextStyle(color: Colors.yellow[300], fontSize: 20),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.black,
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          saveContactInPhone();
                          print('Added to contact');
                          Navigator.of(context).pop();
                          CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            text: "Contact Added successfully!",
                          );
                        } else {
                          print('Form is not validated');
                        }
                      },
                    ),
                  ),
                ])),
          ),
        ));
  }
}
