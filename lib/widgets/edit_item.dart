import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_shopping_list/data/categories.dart';
import 'package:flutter_shopping_list/models/category.dart';
import 'package:flutter_shopping_list/models/grocery_item.dart';

class EditItem extends StatefulWidget {
  const EditItem({super.key, required this.groceryItemUpdate});

  final GroceryItem groceryItemUpdate;

  @override
  State<StatefulWidget> createState() {
    return _EditItemState();
  }
}

class _EditItemState extends State<EditItem> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _quantityController = new TextEditingController();
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.groceryItemUpdate.name;
    _quantityController.text = widget.groceryItemUpdate.quantity.toString();
    _selectedCategory = widget.groceryItemUpdate.category;
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print(_nameController.text);
      print(int.parse(_quantityController.text));
      print(_selectedCategory.title);
      final url = Uri.https(
          'flutter-shopping-list-2b013-default-rtdb.firebaseio.com',
          'shopping-list/${widget.groceryItemUpdate.id}.json');
      // Patch request.
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _nameController.text,
            'quantity': int.parse(_quantityController.text),
            'category': _selectedCategory.title,
          },
        ),
      );
      print(response.body);
      print(response.statusCode);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_nameController.text),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters.';
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      // Quantity
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid, positive number.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: categories.entries
                            .firstWhere(
                              (entry) =>
                                  entry.value.title ==
                                  widget.groceryItemUpdate.category.title,
                            )
                            .value,
                        // Category.
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  category.value.icon,
                                  Text(category.value.title)
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color.fromARGB(255, 84, 24, 215),
                      ),
                      child: IconButton(
                        iconSize: 25,
                        icon: const Icon(Icons.check),
                        onPressed: _saveItem,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
