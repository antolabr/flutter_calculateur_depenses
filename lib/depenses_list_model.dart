import 'dart:collection';
import 'package:scoped_model/scoped_model.dart'; //changer pour provider et retirer la class model
import 'depenses.dart';
import 'database.dart';

class DepensesListModel extends Model {
  DepensesListModel() {
    load();
  }

  final List<Depenses> _depenses = [];
  UnmodifiableListView<Depenses> get depenses => UnmodifiableListView(_depenses);

  void load() {
    Future<List<Depenses>> depenses = SQLiteDbProvider.db.getAllDepenses();
    depenses.then((dbItems) {
      for (var i = 0; i < dbItems.length; i++) {
        _depenses.add(dbItems[i]);
      }
      notifyListeners();
    });
  }

  Future<double> get totalDepenses async {
    return await SQLiteDbProvider.db.getTotalDepenses();
  }

  Future<Depenses?> byId(int id) async {
    return await SQLiteDbProvider.db.getDepensesById(id);
  }

  void insertDepenses(Depenses depenses) async {
    await SQLiteDbProvider.db.insertDepenses(depenses).then(
      (value) {
        _depenses.add(value);
        notifyListeners();
      },
    );
  }

  void updateDepenses(Depenses depenses) async {
    await SQLiteDbProvider.db.updateDepenses(depenses).then(
      (value) {
        var index = _depenses.indexWhere(
          (element) => element.id == depenses.id,
        );
        _depenses[index] = depenses;
        notifyListeners();
      },
    );
  }

  void deleteDepenses(int id) async {
    await SQLiteDbProvider.db.deleteDepenses(id).then(
      (value) {
        _depenses.removeWhere(
          (element) => element.id == id,
        );
        notifyListeners();
      },
    );
  }
}
