import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ocrcustomer/widgets/ingredient_capsule.dart';

class ToxicPage extends StatefulWidget {
  const ToxicPage({Key? key}) : super(key: key);

  @override
  ToxicPageState createState() => ToxicPageState();
}

class ToxicPageState extends State<ToxicPage> {

  //init
  @override
  void initState() {
    super.initState();
    _getCurrentToxicArray();
  }

  List<String> items = [];
  bool isRedSectionVisible = true;
  bool isDoneLoading = false;

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      appBar:
          AppBar(
          title: Text("Scan the text "),
    ),
      body:
      Container(

        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage("images/woodbc.jpg"),
          //   fit: BoxFit.fill,
          // ),
        ),
        child:
        Column(
          children: [
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: List.generate(items.length, (index) {
                      return Dismissible(
                        key: ValueKey(index),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          color: Colors.red,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 16.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        child: CapsuleWidget(
                          text: items[index],
                          onPressed: () {
                            _showDeleteConfirmation(context, index);
                          },
                          onEdit: (){
                            _showEditItemDialog(context, index);
                          },
                        ),
                        onDismissed: (direction) {
                          setState(() {
                            items.removeAt(index);
                          });
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.yellow.shade900,
                          ),
                          onPressed: () async {
                            setState(() {
                              isDoneLoading = true;
                            });
                            await _updateToxicArray();
                            setState(() {
                              isDoneLoading = false;
                            });
                          },
                          child: isDoneLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                              "Done",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                          ),

                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                          ),
                          onPressed: () {
                            _showAddItemDialog(context);
                          },
                          child: isDoneLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                            "Add Ingredients",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        )
                      ),
                    ],
                  ),
                ),
              ),
            )
            ,
          ],
        ),
      ),
    );
  }
  Future<void> _updateToxicArray() async {
    // Get the current user's ID
    String userId = await FirebaseAuth.instance.currentUser?.uid ?? '';
    if(userId.isEmpty) {
      print('User ID is empty');
      return;
    }
    // Update the toxic array in Firestore
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'toxic': items,
    }).then((_) {
      //print('Toxic array updated successfully');
      Navigator.pushNamed(context, "/home");
    }).catchError((error) {
      //print('Error updating toxic array: $error');
    });
  }
  void _showAddItemDialog(BuildContext context) {
    String newItem = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Ingredient'),
          content: TextFormField(
            onChanged: (value) {
              newItem = value.toLowerCase();
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  items.add(newItem);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showEditItemDialog(BuildContext context, int index) {
    String newItem = items[index];
    print(newItem);
    print("dsafdasfdsa");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Ingredient'),
          content: TextFormField(
            initialValue: newItem,
            onChanged: (value) {
              newItem = value.toLowerCase();
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                setState(() {
                  items[index] = newItem;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Ingredient'),
          content: const Text('Are you sure you want to delete this ingredient?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  items.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _getCurrentToxicArray() async {
    // Get the current user's ID
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      // Retrieve the document snapshot from Firestore
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      // Retrieve the 'toxic' array from the document data
      List<String> toxicArray = (snapshot.data() as Map<String, dynamic>)['toxic'].cast<String>();

      // Update the state of the app
      setState(() {
        items = toxicArray;
      });
    } catch (e) {
      //print('Error retrieving toxic array: $e');

    }
  }
}
