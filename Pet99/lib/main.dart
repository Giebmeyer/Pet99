import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'addColeta_Page.dart';

List toDoList = [];
Future<File> getFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File("${directory.path}/data.json");
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        /* primarySwatch: Colors.green, */
        ),
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  TextEditingController _Descricao = new TextEditingController();
  TextEditingController _Bairro = new TextEditingController();
  TextEditingController _Endereco = new TextEditingController();

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState() {
    _readData().then((data) {
      setState(() {
        toDoList = json.decode(data);
      });
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Coletas | Pet99"),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            Divider(
              endIndent: 15,
              indent: 15,
            ),
            Text("Pressione sobre a coleta para mais detalhes",
                style: TextStyle(fontSize: 15), textAlign: TextAlign.center),
            Divider(
              endIndent: 15,
              indent: 15,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: toDoList.length,
                    itemBuilder: buildItem),
              ),
            ),
            Divider(
              endIndent: 15,
              indent: 15,
            ),
          ],
        ),
      ),
      floatingActionButton: botaoAddCard(),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return InkWell(
      onLongPress: () {
        setState(() {
          _exibirDialogo(index);
        });
      },
      child: Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: CheckboxListTile(
          title: Text(toDoList[index]["tipoAnimal"] +
              ", " +
              toDoList[index]["porteAnimal"]),
          subtitle: Text("Rua: " +
              toDoList[index]["rua"] +
              ", Nº" +
              toDoList[index]["numero"] +
              "\n" +
              "Bairro: " +
              toDoList[index]["bairro"]),
          value: toDoList[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(toDoList[index]["ok"] ? Icons.check : Icons.error),
          ),
          onChanged: (c) {
            setState(() {
              toDoList[index]["ok"] = c;
              _saveData();
            });
          },
        ),
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(toDoList[index]);
            _lastRemovedPos = index;
            toDoList.removeAt(index);
            _saveData();

            final snack = SnackBar(
              content: Text("Tarefa removida!"),
              action: SnackBarAction(
                  label: "Desfazer",
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      toDoList.insert(_lastRemovedPos, _lastRemoved);
                      _saveData();
                    });
                  }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.blueAccent,
              duration: Duration(seconds: 2),
            );

            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(snack);
          });
        },
      ),
    );
  }

  Future<String> _readData() async {
    try {
      final file = await getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(toDoList);

    final file = await getFile();
    return file.writeAsString(data);
  }

  Widget botaoAddCard() {
    return SizedBox(
      child: FloatingActionButton(
        heroTag: "Add Entrega",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => adicionarColeta()),
          ).whenComplete(initState);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _exibirDialogo(int index) {
    // configura o button
    Widget okButton = Align(
      alignment: Alignment.center,
      child: FlatButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text('Ok'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Align(
        alignment: Alignment.center,
        child: Text(
          "Dados da coleta",
        ),
      ),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Status: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(verificaColeta(index)),
              ],
            ),
            Divider(
              endIndent: 10,
              indent: 10,
            ),
            Row(
              children: [
                Text(
                  "Tipo do animal: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(toDoList[index]["tipoAnimal"]),
              ],
            ),
            Row(
              children: [
                Text(
                  "Porte: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(toDoList[index]["porteAnimal"]),
              ],
            ),
            Divider(
              endIndent: 10,
              indent: 10,
            ),
            Row(
              children: [
                Text(
                  "Rua: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(toDoList[index]["rua"] + ", "),
                Text(
                  "Nº ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(toDoList[index]["numero"]),
              ],
            ),
            Divider(
              endIndent: 10,
              indent: 10,
            ),
            Row(
              children: [
                Text(
                  "Bairro: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(toDoList[index]["bairro"]),
              ],
            ),
            Divider(
              endIndent: 10,
              indent: 10,
            ),
            Row(
              children: [
                Text(
                  "Observações: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(verificaDescricao(index)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        okButton,
      ],
    );
    // exibe o dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

  verificaColeta(int index) {
    return toDoList[index]["ok"] ? "Coletado!" : "Pendente...";
  }

  verificaDescricao(int index) {
    return toDoList[index]["DescricaoAdicional"] ?? "...";
  }
}
