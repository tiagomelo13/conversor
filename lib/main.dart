import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

const request = 'https://economia.awesomeapi.com.br/last/USD-BRL,EUR-BRL';

void main() async {
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    double dolarNum = double.parse(dolar);
    double euroNum = double.parse(euro);
    double real = double.parse(text);
    dolarController.text = (real / dolarNum).toStringAsFixed(2);
    euroController.text = (real / euroNum).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolarNum = double.parse(dolar);
    double euroNum = double.parse(euro);
    double dolar1 = double.parse(text);
    realController.text = (dolar1 * dolarNum).toStringAsFixed(2);
    euroController.text = ((dolarNum / euroNum) * dolar1).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double dolarNum = double.parse(dolar);
    double euroNum = double.parse(euro);
    double euro1 = double.parse(text);
    realController.text = (euro1 * dolarNum).toStringAsFixed(2);
    dolarController.text = ((dolarNum / euroNum) * euro1).toStringAsFixed(2);
  }

  String dolar = '';
  String euro = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('\$ Conversor \$'),
          centerTitle: true,
          backgroundColor: Colors.amber,
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    'Carregando Dados...',
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Erro ao carregar dados...',
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dolar = snapshot.data?["USDBRL"]["high"];

                    euro = snapshot.data?["EURBRL"]["high"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.monetization_on,
                              size: 130, color: Colors.amber),
                          buildTextField(
                              'Reais', 'R\$', realController, _realChanged),
                          Divider(),
                          buildTextField(
                              'Dolares', 'U\$', dolarController, _dolarChanged),
                          Divider(),
                          buildTextField(
                              'Euros', '€\$', euroController, _euroChanged)
                        ],
                      ),
                    );
                  }
              }
            }));
  }

  Widget buildTextField(
      String label, String prefix, TextEditingController c, Function f) {
    return TextField(
      controller: c,
      onChanged: (text) {
        //a função onChanged não funciona sem criar variavel auxiliar
        double.parse(text);
        f(text);
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix,
      ),
      style: TextStyle(color: Colors.amber),
    );
  }
}
