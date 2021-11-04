import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class adicionarColeta extends StatefulWidget {
  @override
  _adicionarColetaState createState() => _adicionarColetaState();
}

class _adicionarColetaState extends State<adicionarColeta> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  TextEditingController _Descricao = new TextEditingController();
  TextEditingController _Bairro = new TextEditingController();
  TextEditingController _Rua = new TextEditingController();
  TextEditingController _Numero = new TextEditingController();
  TextEditingController _DescricaoAdicional = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Nova Coleta | Pet99"),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Center(
              child: Form(
                key: _key,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _Descricao,
                          validator: validarNomeTarefa,
                          decoration: InputDecoration(
                            labelText: "Descrição",
                            hintText: "Cachorro Pequeno, Macho",
                            hintStyle: TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _Bairro,
                          validator: validarBairroTarefa,
                          decoration: InputDecoration(
                            labelText: "Bairro",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.67,
                                  child: TextFormField(
                                      validator: validarRuaTarefa,
                                      controller: _Rua,
                                      decoration: InputDecoration(
                                          labelText: 'Rua',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      15.0)))),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.23,
                                  child: TextFormField(
                                      validator: validarNumero,
                                      controller: _Numero,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          labelText: 'Nº',
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      15.0)))),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _DescricaoAdicional,
                          decoration: InputDecoration(
                            labelText: "Descrição Adicional",
                            hintText:
                                "Proprietária deseja que a coleta seja as 14Hrs",
                            hintStyle: TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FlatButton(
                              color: Colors.red.shade700,
                              child: Text("Cancelar"),
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: Text('Confirmar'),
                                onPressed: _sendForm),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _Descricao.text.trim();
      newToDo["bairro"] = _Bairro.text.trim();
      newToDo["endereco"] = _Rua.text.trim();
      newToDo["numero"] = _Numero.text.trim();
      newToDo["DescricaoAdicional"] = _DescricaoAdicional.text.trim();
      _Descricao.clear();
      _Bairro.clear();
      _Rua.clear();
      _Numero.clear();
      _DescricaoAdicional.clear();
      newToDo["ok"] = false;
      toDoList.add(newToDo);

      _saveData();
    });
  }

  Future<File> _saveData() async {
    String data = json.encode(toDoList);

    final file = await getFile();
    return file.writeAsString(data);
  }

  String validarNomeTarefa(String value) {
    String patttern = r'^[a-zA-Z0-9.a-zA-Z0-9`´ ]';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe a Descrição";
    } else if (!regExp.hasMatch(value)) {
      return "Descrição inválida";
    }
    return null;
  }

  String validarBairroTarefa(String value) {
    String patttern = r'^[a-zA-Z0-9.a-zA-Z0-9`´ ]';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o Bairro";
    } else if (!regExp.hasMatch(value)) {
      return "Bairro inválido";
    }
    return null;
  }

  String validarRuaTarefa(String value) {
    String patttern = r'^[a-zA-Z0-9.a-zA-Z0-9`´ ]';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe a Rua";
    } else if (!regExp.hasMatch(value)) {
      return "Endereço inválido";
    }
    return null;
  }

  String validarNumero(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe";
    } else if (!regExp.hasMatch(value)) {
      return "Apenas números";
    } else {
      return null;
    }
  }

  _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _key.currentState.save();
      _addToDo();
      Navigator.of(context).pop();
    } else {
      // erro de validação
      setState(() {
        _validate = true;
      });
    }
  }
}
