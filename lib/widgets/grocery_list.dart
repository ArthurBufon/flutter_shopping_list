import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shopping_list/data/categories.dart';
import 'package:flutter_shopping_list/models/category.dart';
import 'package:flutter_shopping_list/widgets/edit_item.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_shopping_list/models/grocery_item.dart';
import 'package:flutter_shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // Load all items.
  void _loadItems() async {
    final url = Uri.https(
        'flutter-shopping-list-2b013-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      _loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = _loadedItems;
    });
  }

  // Add new item.
  void _addItem() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    _loadItems();
  }

  // Edit Item.
  void _editItem(GroceryItem groceryItemUpdate) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EditItem(groceryItemUpdate: groceryItemUpdate),
      ),
    );

    _loadItems();
  }

  // Delete Item.
  void _removeItem(GroceryItem item) async {
    // Delete Request.
    final url = Uri.https(
        'flutter-shopping-list-2b013-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(
      url,
    );
    print(response.body);
    print(response.statusCode);

    // Refresh state.
    setState(() async {
      _groceryItems.remove(item);
      _loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet!'));

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: Card(
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: _groceryItems[index].category.icon,
              trailing: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromARGB(255, 84, 24, 215),
                  ),
                ),
                onPressed: () {
                  _editItem(_groceryItems[index]);
                },
                child: const Icon(
                  Icons.edit,
                  size: 25,
                  color: Color.fromARGB(255, 182, 148, 255),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(
                  Color.fromARGB(255, 84, 24, 215)),
            ),
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
