import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contato_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ContatoPage extends StatefulWidget {
  ContatoPage({this.contato});

  final Contato? contato;

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  Contato? contatoEdit;
  bool userEdited = false;

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();

  final _nomeFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.contato == null) {
      contatoEdit = Contato();
    } else {
      contatoEdit = Contato.fromMap(widget.contato!.toMap());

      nomeController.text = contatoEdit!.nome!;
      emailController.text = contatoEdit!.email!;
      telefoneController.text = contatoEdit!.telefone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _requestPop(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 54, 133, 244),
          title: Text(contatoEdit?.nome ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (contatoEdit!.nome != null && contatoEdit!.nome!.isNotEmpty) {
              Navigator.pop(context, contatoEdit);
            } else {
              FocusScope.of(context).requestFocus(_nomeFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Color.fromARGB(255, 54, 133, 244),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contatoEdit?.img != null
                            ? FileImage(File(contatoEdit!.img!))
                            : const AssetImage("images/usuario.png")
                                as ImageProvider),
                  ),
                ),
                onTap: () {
                  ImagePicker()
                      .pickImage(source: ImageSource.camera)
                      .then((file) {
                    if (file == null) return;
                    setState(() {
                      contatoEdit!.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Nome"),
                controller: nomeController,
                focusNode: _nomeFocus,
                onChanged: (text) {
                  userEdited = true;
                  setState(
                    () {
                      contatoEdit?.nome = text;
                    },
                  );
                },
                keyboardType: TextInputType.name,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Email"),
                controller: emailController,
                onChanged: (text) {
                  userEdited = true;
                  contatoEdit?.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Telefone"),
                controller: telefoneController,
                onChanged: (text) {
                  userEdited = true;
                  contatoEdit?.telefone = text;
                },
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Descartar alterações?"),
              content: const Text("Se sair, as alterações serão perdidas!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Sim"),
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
