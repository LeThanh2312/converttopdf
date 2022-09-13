import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/customer_camera.dart';

class ConvertImageToDPF extends StatefulWidget {
  const ConvertImageToDPF({Key? key}) : super(key: key);

  @override
  _ConvertImageToDPFState createState() => _ConvertImageToDPFState();
}

class _ConvertImageToDPFState extends State<ConvertImageToDPF> {
  final picker = ImagePicker();
  final List<File> _image = [];

  late List<FileSystemEntity> _folders;
  Future<void> getValueOnFolders() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = directory.path;
    String folderDirectory = '$dir/';
    final myDir = Directory(folderDirectory);
    setState(() {
      _folders = myDir.listSync(recursive: true, followLinks: false);
    });
  }

  @override
  void initState() {
    _folders = [];
    getValueOnFolders();
    super.initState();
  }

  final folderController = TextEditingController();
  late String nameOfFolder;
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: const [
              Text(
                'ADD FOLDER',
                textAlign: TextAlign.left,
              ),
              Text(
                'Type a folder name to add',
                style: TextStyle(
                  fontSize: 14,
                ),
              )
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                controller: folderController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Enter folder name'),
                onChanged: (val) {
                  setState(() {
                    nameOfFolder = folderController.text;
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (nameOfFolder.isNotEmpty) {
                  await callFolderCreationMethod(nameOfFolder);
                  setState(() {
                    folderController.clear();
                    nameOfFolder = "";
                  });
                  getValueOnFolders();
                  Navigator.of(context).pop();
                }
              },
            ),
            ElevatedButton(
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  callFolderCreationMethod(String folderInAppDocDir) async {
    String actualFileName = await createFolderInAppDocDir(folderInAppDocDir);
    setState(() {});
  }

  Future<String> createFolderInAppDocDir(String folderName) async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder = Directory('${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
      await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All"),
        actions: [
          IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                createPDF();
                savePDF();
              }),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showMyDialog();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          await availableCameras().then((value) => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
                        },
                        child: const Text(
                          "Camera",
                        )
                    ),
                    ElevatedButton(
                        onPressed: (){
                          getImageFromGallery();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Gallery",
                        )
                    ),
                  ],
                );
          });
        }
      ),
      body:  _folders != null
        ? GridView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return Material(
            elevation: 6.0,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      FutureBuilder(
                          future: getFileType(_folders[index]),
                          builder: (ctx,snapshot){

                            if(snapshot.hasData)
                            {
                              FileStat f=snapshot.data as FileStat;
                              print("file.stat() ${f.type}");
                              if(f.type.toString().contains("file"))
                              {
                                return  const Icon(
                                  Icons.file_copy_outlined,
                                  size: 100,
                                  color: Colors.orange,
                                );
                              }else
                              {
                                return  InkWell(
                                  onTap: (){
                                    // Navigator.push(context, new MaterialPageRoute(builder: (builder){
                                    //   return InnerFolder(filespath:_folders[index].path);
                                    // }));
                                  },
                                  child: const Icon(
                                    Icons.folder,
                                    size: 100,
                                    color: Colors.orange,
                                  ),
                                );
                              }
                            }
                            return const Icon(
                              Icons.file_copy_outlined,
                              size: 100,
                              color: Colors.orange,
                            );
                          }),

                      Text(
                        _folders[index].path.split('/').last,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      _showDeleteDialog(index);
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          );
        },
        itemCount: _folders.length,
      )
        : Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.not_interested,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          )
    );
  }
  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure to delete this folder?',
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () async {
                await _folders[index].delete();
                getValueOnFolders();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  getImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    setState(() {

    });
    File(pickedFile.path).copy('${directory.path}/image_${DateTime.now()}.png');
    getValueOnFolders();
  }

  getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image.add(File(pickedFile.path));
      } else {

      }
    });
  }

  createPDF() async {
    // for (var img in _image) {
    //   final image = pw.MemoryImage(img.readAsBytesSync());
    //
    //   pdf.addPage(pw.Page(
    //       pageFormat: PdfPageFormat.a4,
    //       build: (pw.Context contex) {
    //         return pw.Center(child: pw.Image(image));
    //       }));
    // }
  }

  savePDF() async {
    // try {
    //   final dir = await getExternalStorageDirectory();
    //   final file = File('${dir?.path}/filename.pdf');
    //   await file.writeAsBytes(await pdf.save());
    //   showPrintedMessage('success', 'saved to documents');
    // } catch (e) {
    //   showPrintedMessage('error', e.toString());
    // }
  }

  showPrintedMessage(String title, String msg) {
    Flushbar(
      title: title,
      message: msg,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.info,
        color: Colors.blue,
      ),
    ).show(context);
  }

  Future getFileType(file)
  {
    return file.stat();
  }

}