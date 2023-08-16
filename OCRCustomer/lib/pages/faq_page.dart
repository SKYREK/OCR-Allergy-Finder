import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> allergyData = [
    {
      'name': 'Peanuts',
      'description': 'Administer epinephrine auto-injector (EpiPen) if available, call emergency services.'
    },
    {
      'name': 'Tree nuts',
      'description': 'Seek immediate medical attention and avoid any further consumption.'
    },
    {
      'name': 'Wheat',
      'description': "Remove the allergen from the person's diet, provide antihistamines if necessary."
    },
    {
      'name': 'Soybeans',
      'description': 'Monitor symptoms and seek medical advice if severe reaction occurs.'
    },
    {
      'name': 'Milk',
      'description': 'Avoid dairy products, consider alternatives like lactose-free or plant-based milk.'
    },
    {
      'name': 'Eggs',
      'description': 'Avoid consuming eggs and products containing eggs, carry an epinephrine auto-injector.'
    },
    {
      'name': 'Fish',
      'description': 'Seek medical help, monitor for difficulty breathing, and consider antihistamines if mild symptoms occur.'
    },
    {
      'name': 'Shellfish',
      'description': 'Call emergency services if experiencing difficulty breathing or severe symptoms.'
    },
    {
      'name': 'Sesame seeds',
      'description': 'Remove sesame products from the diet, carry antihistamines for mild reactions.'
    },
    {
      'name': 'Mustard',
      'description': 'Avoid mustard and products containing it, seek medical attention for severe symptoms.'
    },
    {
      'name': 'Sulphites',
      'description': 'Limit exposure and read food labels carefully, consult a doctor if symptoms worsen.'
    },
    {
      'name': 'Gluten',
      'description': 'Follow a gluten-free diet, consult a healthcare professional for proper guidance.'
    },
    {
      'name': 'Lupin',
      'description': 'Avoid lupin-containing products, seek medical advice if symptoms arise.'
    },
    {
      'name': 'Celery',
      'description': 'Remove celery from the diet and seek medical help if severe symptoms occur.'
    },
    {
      'name': 'Mollusks',
      'description': 'Call emergency services if experiencing anaphylaxis, avoid further consumption.'
    },
    {
      'name': 'Corn',
      'description': 'Consult a doctor, eliminate corn and corn-derived ingredients from the diet.'
    },
    {
      'name': 'Strawberries',
      'description': 'Seek medical attention for severe allergic reactions, consider antihistamines for mild symptoms.'
    },
    {
      'name': 'Tomatoes',
      'description': 'Remove tomatoes from the diet and consult a healthcare professional.'
    },
    {
      'name': 'Kiwi',
      'description': 'Avoid kiwi fruit and products containing it, carry an epinephrine auto-injector if necessary.'
    },
    {
      'name': 'Avocado',
      'description': 'Monitor for symptoms and seek medical advice if severe allergic reaction occurs.'
    },
  ];


  List<Map<String, String>> filteredAllergyData = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredAllergyData = List.from(allergyData);
  }

  void _filterAllergyData(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredAllergyData = allergyData
            .where((allergy) =>
            allergy['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        filteredAllergyData = List.from(allergyData);
      }
    });
  }

  void _resetAllergyData() {
    setState(() {
      filteredAllergyData = List.from(allergyData);
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Allergy Information'),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAllergyData,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Search Allergies'),
                    content: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                      ),
                      onChanged: _filterAllergyData,
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Search'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body:
      Container(
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage("images/woodbc.jpg"),
          //   fit: BoxFit.fill,
          // ),
        ),
        child: ListView.builder(
          itemCount: filteredAllergyData.length,
          itemBuilder: (BuildContext context, int index) {
            String name = filteredAllergyData[index]['name']!;
            String description = filteredAllergyData[index]['description']!;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.red.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Center(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(name),
                        content: Text(description),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
