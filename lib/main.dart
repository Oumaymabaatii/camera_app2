import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // permet d’accéder à la caméra de l’appareil
import 'dart:io'; //pour effectuer des opérations sur les fichiers
import 'package:path/path.dart'; // Pour manipuler les chemins de fichiers

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Nécessaire pour attendre le async
  final cameras = await availableCameras();  //Cherche toutes les caméras
  final firstCamera = cameras.first; // Prend la première

  runApp(MyApp(camera: firstCamera)); //Lance l'appli avec la caméra choisie
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;  // La caméra à utiliser est passée à l'application
  const MyApp({Key? key, required this.camera}) : super(key: key); // Constructeur qui reçoit la caméra
  // Fonction qui construit l'interface de l'application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(camera: camera),// Affiche l'écran principal avec la camér
    );
  }
}
// Déclaration d'un widget avec état pour gérer l'affichage de la caméra
class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({Key? key, required this.camera}) : super(key: key);// Constructeur de la classe CameraScreen

  @override
  _CameraScreenState createState() => _CameraScreenState();// Création de l'état associé à ce widget
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;//Déclare un contrôleur de caméra pour gérer la capture des images.
  late Future<void> _initializeControllerFuture;//Déclare un Future pour attendre l'initialisation du contrôleur.
  bool _isCapturing = false;  // Suivi de l'état de la capture

  @override
  void initState() {
    super.initState();// Initialisation du contrôleur de la caméra avec une résolution définie
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();// Initialisation du contrôleur.
  }

  @override
  void dispose() {
    _controller.dispose();// Libère les ressources lorsque l'écran est fermé.
    super.dispose();
  }

  // Fonction pour obtenir le dossier DCIM/Images
  Future<String> _getDCIMDirectory() async {
    final directory = Directory('/storage/emulated/0/DCIM/Images');
    if (!await directory.exists()) {
      await directory.create(recursive: true); // Créer le dossier s'il n'existe pas
    }
    return directory.path;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Affiche la caméra sur tout l'écran
                SizedBox.expand(
                  child: CameraPreview(_controller),
                ),
                // Bouton de capture en bas centré
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                      onPressed: _isCapturing
                          ? null
                          : () async {
                        setState(() {
                          _isCapturing = true;
                        });
                        try {
                          final image = await _controller.takePicture();
                          final directoryPath = await _getDCIMDirectory();
                          final fileName = basename(image.path);
                          final newImagePath = '$directoryPath/$fileName';
                          await File(image.path).copy(newImagePath);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Photo enregistrée dans: $newImagePath')),
                          );
                        } catch (e) {
                          print('Erreur lors de la prise de photo: $e');
                        } finally {
                          setState(() {
                            _isCapturing = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('📸 Prendre une photo'),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

}
