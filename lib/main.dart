import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './depenses_list_model.dart';
import './depenses.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculateur de Dépenses',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Calculateur de Dépenses'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ScopedModelDescendant<DepensesListModel>(
        builder: (context, child, model) {
          return ListView.separated(
            itemCount: model.depenses.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: Text(
                    'total des dépenses : ' + model.totalDepenses.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                index = index - 1;
                return Dismissible(
                  key: Key(model.depenses[index].id.toString()),
                  onDismissed: (direction) {
                    model.deleteDepenses(model.depenses[index].id);
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Item id : " + model.depenses[index].id.toString() + " supprimé",
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormPage(
                            id: model.depenses[index].id,
                            depenses: model,
                          ),
                        ),
                      );
                    },
                    leading: const Icon(Icons.monetization_on),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    title: Text(
                      model.depenses[index].categorie +
                          " : " +
                          model.depenses[index].id.toString() +
                          " " +
                          model.depenses[index].formattedDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          );
        },
      ),
      floatingActionButton: ScopedModelDescendant<DepensesListModel>(
        builder: (context, child, model) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScopedModelDescendant<DepensesListModel>(
                    builder: (context, chil, model) {
                      return FormPage(
                        id: 0,
                        depenses: model,
                      );
                    },
                  ),
                ),
              );
            },
            tooltip: 'increment',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({
    Key? key,
    required this.id,
    required this.depenses,
  });
  final int id;
  final DepensesListModel depenses;
  @override
  _FormPageState createState() => _FormPageState(
        id: id,
        depenses: depenses,
      );
}

class _FormPageState extends State<FormPage> {
  _FormPageState({
    Key? key,
    required this.id,
    required this.depenses,
  });
  final int id;
  final DepensesListModel depenses;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late double _montant;
  late DateTime _date;
  late String _category;

  void envoyer() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (id == 0) {
        depenses.insertDepenses(Depenses(0, _montant, _date, _category));
      } else {
        depenses.updateDepenses(Depenses(0, _montant, _date, _category));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('déclarer ses dépenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: Icon(Icons.monetization_on),
                  labelText: 'Montant',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                validator: (val) {
                  RegExp regExp = RegExp(r'^[0-9]\d*(\.\d+)?$');
                  if (!regExp.hasMatch(val ?? '')) {
                    //si val est nul => ''
                    return 'Montant Invalide';
                  } else {
                    return null;
                  }
                },
                initialValue: id == 0 ? '' : depenses.depenses[id].montant.toString(),
                onSaved: (val) => _montant = double.parse(val ?? ''),
              ),
              TextFormField(
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Date',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                validator: (val) {
                  RegExp regExp = RegExp(r'^\d{4}\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])$');
                  if (!regExp.hasMatch(val ?? '')) {
                    //si val est nul => ''
                    return 'Date Invalide';
                  } else {
                    return null;
                  }
                },
                initialValue: id == 0 ? '' : depenses.depenses[id].date.toString(),
                onSaved: (val) => _date = DateTime.parse(val ?? ''),
              ),
              TextFormField(
                style: const TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: Icon(Icons.category),
                  labelText: 'Catégorie',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                validator: (val) {
                  RegExp regExp = RegExp(r'^[a-zA-Z0-9_]+$');
                  if (!regExp.hasMatch(val ?? '')) {
                    //si val est nul => ''
                    return 'Catégorie Invalide';
                  } else {
                    return null;
                  }
                },
                initialValue: id == 0 ? '' : depenses.depenses[id].categorie.toString(),
                onSaved: (val) => _date = DateTime.parse(val ?? ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
