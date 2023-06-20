import 'package:demo_crud_modal_sqllite/database/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  //Get all data from database
  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  //Add Data
  Future<void> _addData() async {
    await SQLHelper.createData(_titleController.text, _descController.text);
    _refreshData();
  }

  //Update data
  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(id, _titleController.text, _descController.text);
    _refreshData();
  }

  //Delete data
  void _deleteData(int id) async {
    await SQLHelper.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Informação deletada"),
          backgroundColor: Colors.redAccent,
      )
    );
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void showBottomSheet(int? id) async {

    //O id não esta null o software entra em modo de edição
    if(id != null) {
      final existingData = _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }

    showModalBottomSheet(
        elevation: 5,
        context: context,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 30,
              left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10
          ),
          child:
          SingleChildScrollView( // Adicionado SingleChildScrollView aqui
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Titulo"
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Descrição"
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if(id == null) {
                        await _addData();
                      }

                      if(id != null) {
                        await _updateData(id);
                      }

                      _titleController.text = "";
                      _descController.text = "";

                      //Hide bottom sheet
                      Navigator.of(context).pop();
                      print("Data Added");
                    },

                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(id == null ? "Salvar" : "Alterar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Contatos SQLLite"),
      ),
      body: _isLoading?
      Center(
        child: CircularProgressIndicator()
      )
      :
      ListView.builder(
        itemCount: _allData.length,
        itemBuilder: (context, index) => Card(
          margin: EdgeInsets.all(15),
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                _allData[index]['title'],
                style: TextStyle(
                    fontSize: 20
                ),
              ),
            ),
            subtitle: Text(_allData[index]['desc']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: (){
                  showBottomSheet(_allData[index]['id']);
                }, icon: Icon(Icons.edit)),
                IconButton(onPressed: (){
                  _deleteData(_allData[index]['id']);
                }, icon: Icon(Icons.delete, color: Colors.redAccent,))
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}