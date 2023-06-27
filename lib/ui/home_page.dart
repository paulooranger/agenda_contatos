import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:agenda_contatos/helpers/contato_helper.dart';
import 'package:flutter/material.dart';
import 'contato_page.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContatoHelper helper = ContatoHelper();
  List<Contato> contatos = [];

  @override
  void initState() {
    super.initState();
    _getAllContatos();
  }

  void vazio() {
    print("icone funcionando ok");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda de Contatos"),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showContatoPage();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: contatos.length,
          itemBuilder: (context, index) {
            return _contatoCard(context, index);
          }),
    );
  }

  Widget _contatoCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contatos[index].img != null
                          ? FileImage(File(contatos[index].img!))
                          : const AssetImage("images/usuario.png")
                              as ImageProvider),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contatos[index].nome ?? "Campo vazio",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      contatos[index].telefone ?? "Campo vazio",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      contatos[index].email ?? "Campo vazio",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        showOptions(context, index);
      },
    );
  }

  void showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FloatingActionButton.extended(
                          onPressed: () async {
                            // ignore: deprecated_member_use
                            launch("tel:$contatos[index].phone");
                            Navigator.pop(context);
                          },
                          label: const Text("Ligar"),
                          icon: const Icon(Icons.call),
                          backgroundColor: Colors.green,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FloatingActionButton.extended(
                          label: const Text("Editar"),
                          onPressed: () {
                            Navigator.pop(context);
                            showContatoPage(contato: contatos[index]);
                          },
                          backgroundColor: Colors.orange,
                          icon: const Icon(Icons.edit),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FloatingActionButton.extended(
                          label: Text("Excluir"),
                          backgroundColor: Colors.red,
                          onPressed: () {
                            helper.deletaContato(contatos[index].id!);
                            setState(() {
                              contatos.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  showContatoPage({Contato? contato}) async {
    final recContato = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ContatoPage(
                contato: contato,
              )),
    );
    if (recContato != null) {
      if (contato != null) {
        await helper.updateContato(recContato);
      } else {
        await helper.salvaContato(recContato);
      }
      _getAllContatos();
    }
  }

  void _getAllContatos() {
    helper.getAllContatos().then((list) {
      setState(() {
        contatos = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    setState(() {
      switch (result) {
        case OrderOptions.orderaz:
          contatos.sort((a, b) {
            return a.nome!.toLowerCase().compareTo(b.nome!.toLowerCase());
          });
          break;
        case OrderOptions.orderza:
          contatos.sort((a, b) {
            return b.nome!.toLowerCase().compareTo(a.nome!.toLowerCase());
          });
          break;
      }
    });
  }
}
