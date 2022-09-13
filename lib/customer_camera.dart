import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/preview_page.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;

  bool isCardID = true;
  bool isPageFirst = true;

  List<XFile> listPicture = [];

  @override
  void dispose() {
    _controller.dispose();
    listPicture = [];
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _controller = CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Future takePicture() async {
    XFile? picture;
    XFile? picture2;
    if (!_controller.value.isInitialized) {
      return null;
    }
    if (_controller.value.isTakingPicture) {
      return null;
    }
    if(isCardID){
      if(isPageFirst){
        picture = await _controller.takePicture();
        listPicture.add(picture);
        isPageFirst = false;
        setState(() {

        });
      }else{
        picture2 = await _controller.takePicture();
        listPicture.add(picture2);
        print("============ ${listPicture.length}");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewPage(
                  picture: listPicture,
                ))).then((_) => setState(() {
                  listPicture.clear();
                  isPageFirst = true;
        }));
      }
    }else{
      try {
        await _controller.setFlashMode(FlashMode.off);
        XFile picture = await _controller.takePicture();
        List<XFile> listPicture = [];
        listPicture.add(picture);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PreviewPage(
                  picture: listPicture,
                )));
        listPicture = [];
      } on CameraException catch (e) {
        debugPrint('Error occured while taking picture: $e');
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            (_controller.value.isInitialized)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: isCardID ? customCameraIDCard() : customCameraPassport(),),
                    ],
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(child: CircularProgressIndicator())),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                    color: Colors.transparent),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            isCardID = true;
                            setState(() {});
                          },
                          child: Text(
                            'Thẻ ID',
                            style: TextStyle(
                              color: isCardID ? Colors.green : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            isCardID = false;
                            setState(() {});
                          },
                          child: Text(
                            'Hộ chiếu',
                            style: TextStyle(
                              color: isCardID ? Colors.black : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Expanded(
                          child: IconButton(
                            onPressed: takePicture,
                            iconSize: 50,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.camera, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {},
                            iconSize: 50,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon:
                                const Icon(Icons.collections, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 50,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget customCameraIDCard() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          bottom: 0,
          child: CameraPreview(_controller),
        ),
        Positioned(
          top: 0,
          right: 0,
          left: 0,
          bottom: 0,
          child: SvgPicture.asset(
            'assets/image/background_camera.svg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 20,
          right: 0,
          left: 0,
          bottom: 0,
          child: Center(
            child: Text(
              isPageFirst ? 'Trang đầu' : 'Trang sau',
              style: const TextStyle(
                color: Colors.white
              ),
              ),
          )
        )
      ],
    );
  }

  Widget customCameraPassport() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 550,
          child: CameraPreview(_controller),
        ),
      ],
    );
  }
}
