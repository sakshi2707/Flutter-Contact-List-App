import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Contact> contacts = [];
  List<Contact> contactsChanged = [];
  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllContacts();
    searchController.addListener(changeContacts);
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }
  changeContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        print('1');
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        print('2');
        String contactName = contact.displayName.toLowerCase();
        print('3');
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          print('4');
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });

      setState(() {
        contactsChanged = _contacts;
      });
    }
  }


  getAllContacts() async {
    List<Contact> _contacts =
    (await ContactsService.getContacts(withThumbnails: false)).toList();
    print('hi1');
    print(contacts);

    setState(() {
      print('hi2');
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Contacts'),
      ),
      body: Container(
        padding: EdgeInsets.all((20.0)),
        child: Column(
          children: <Widget>[
            Container(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.blue))),
                )),
            Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: isSearching == true
                        ? contactsChanged.length
                        : contacts.length,
                    itemBuilder: (context, index) {
                      Contact contact = isSearching == true
                          ? contactsChanged[index]
                          : contacts[index];
                      return ListTile(
                        title: Text(contact.displayName),
                        subtitle: Text((() {
                          String number = "";
                          contact.phones.forEach((f) {
                            number = f.value;
                          });
                          return number;
                        })()),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
