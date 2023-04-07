import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models_and_providers/product.dart';
import '../models_and_providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final priceFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final imageUrlFocusNode = FocusNode();
  final imageUrlController = TextEditingController();

  final _form = GlobalKey<FormState>();

  bool isInit = true;
  bool isEditing = false;
  bool isLoading = false;

  var initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": ""
  };

  var editedProduct =
      Product(id: "new_id", title: "", description: "", price: 0, imageUrl: "");

  @override
  void dispose() {
    // TODO: implement dispose
    imageUrlFocusNode.removeListener(updateImageUrl);
    priceFocusNode.dispose();
    descriptionFocusNode.dispose();
    imageUrlController.dispose();
    imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    imageUrlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        isEditing = true;
        editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productId as String);
        initValues = {
          "title": editedProduct.title,
          "description": editedProduct.description,
          "price": editedProduct.price.toString(),
          "imageUrl": "",
        };
        imageUrlController.text = editedProduct.imageUrl;
      }
      isInit = false;
    }
    super.didChangeDependencies();
  }

  void updateImageUrl() {
    if (!imageUrlFocusNode.hasFocus) {
      if (imageUrlController.text.isEmpty) {
        setState(() {});
        return;
      }
      if (!(imageUrlController.text).startsWith("http") &&
          !(imageUrlController.text).startsWith("https")) {
        return;
      }
      if (!imageUrlController.text.endsWith(".png") &&
          !imageUrlController.text.endsWith(".jpg") &&
          !imageUrlController.text.endsWith(".jpeg")) {
        return;
      }
      setState(() {});
    }
  }

  Future<dynamic> errorDialog(error) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error Occurred!"),
        content: Text(error.toString()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  Future<void> saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!(isValid as bool)) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      isLoading = true;
    });
    if (editedProduct.id == "new_id") {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(editedProduct);
      } catch (error) {
        await errorDialog(error);
      } finally {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .updateProducts(editedProduct.id, editedProduct);
      } catch (error) {
        await errorDialog(error);
      } finally {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEditing
            ? const Text("Edit the Product")
            : const Text("Add a Product"),
        actions: [
          IconButton(
            onPressed: saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: initValues["title"],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          labelText:
                              "Title", /*errorStyle:this can also be configured*/
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if ((value as String).isEmpty) {
                            return "The field cannot be empty.";
                          } else {
                            return null;
                          }
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(priceFocusNode);
                        },
                        onSaved: (value) {
                          editedProduct = Product(
                              id: editedProduct.id,
                              title: value as String,
                              description: editedProduct.description,
                              price: editedProduct.price,
                              imageUrl: editedProduct.imageUrl,
                              isFavourite: editedProduct.isFavourite);
                        },
                      ),
                      TextFormField(
                        initialValue: initValues["price"],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(labelText: "Price"),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(descriptionFocusNode);
                        },
                        onSaved: (value) {
                          editedProduct = Product(
                              id: editedProduct.id,
                              title: editedProduct.title,
                              description: editedProduct.description,
                              price: double.parse(value!),
                              imageUrl: editedProduct.imageUrl,
                              isFavourite: editedProduct.isFavourite);
                        },
                        validator: (value) {
                          if ((value as String).isEmpty) {
                            return "Please enter the price.";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number.";
                          }
                          if (double.parse(value) <= 0) {
                            return "The price should be greater than zero.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: initValues["description"],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration:
                            const InputDecoration(labelText: "Description"),
                        maxLines: 3,
                        // textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.multiline,
                        focusNode: descriptionFocusNode,
                        onSaved: (value) {
                          editedProduct = Product(
                              id: editedProduct.id,
                              title: editedProduct.title,
                              description: value as String,
                              price: editedProduct.price,
                              imageUrl: editedProduct.imageUrl,
                              isFavourite: editedProduct.isFavourite);
                        },
                        validator: (value) {
                          if ((value as String).isEmpty) {
                            return "Please enter a description.";
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: imageUrlController.text.isEmpty
                                ? const Text("Enter a URL")
                                : FittedBox(
                                    child: Image.network(
                                      imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: "Image URL"),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: imageUrlController,
                              focusNode: imageUrlFocusNode,
                              onFieldSubmitted: (value) {
                                // saveForm();
                              },
                              onSaved: (value) {
                                editedProduct = Product(
                                    id: editedProduct.id,
                                    title: editedProduct.title,
                                    description: editedProduct.description,
                                    price: editedProduct.price,
                                    imageUrl: value as String,
                                    isFavourite: editedProduct.isFavourite);
                              },
                              validator: (value) {
                                if ((value as String).isEmpty) {
                                  return "Please enter a URL.";
                                }
                                if (!(value).startsWith("http") &&
                                    !(value).startsWith("https")) {
                                  return "Please enter a valid URL.";
                                }
                                if (!value.endsWith(".png") &&
                                    !value.endsWith(".jpg") &&
                                    !value.endsWith(".jpeg")) {
                                  return "Please enter a valid URL.";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      ElevatedButton(
                        onPressed: saveForm,
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary),
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
