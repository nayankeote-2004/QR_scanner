import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR/Barcode Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String scannedData = "";
  bool scanning = false;
  bool isLoading = false; 

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  Future<void> _storeScanHistory(String data, String name) async {
    final timestamp = DateTime.now();
    await FirebaseFirestore.instance.collection('scan_history').add({
      'data': data,
      'name': name,
      'timestamp': timestamp,
    });
  }

  void _onQRViewCreated(QRViewController qrController) {
    this.controller = qrController;
    controller!.scannedDataStream.listen((scanData) async {
      if (!scanning) {
        scanning = true;
        setState(() {
          isLoading = true;
        });

        scannedData = scanData.code!;
        Vibration.vibrate(duration: 200, amplitude: 120);

        String qrName = 'Unknown'; 
        bool isValid = Uri.tryParse(scannedData)?.hasAbsolutePath ?? false;

        if (isValid) {
          try {
            Uri uri = Uri.parse(scannedData);
            qrName = uri.host;

            if (uri.scheme == 'upi') {
              final url = Uri.parse(scannedData);
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              final url = Uri.parse(scannedData);
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }

            setState(() {
              isLoading = false; 
              scanning = false; 
            });
          } catch (e) {
            _showMessage("Error opening URL");
            setState(() {
              isLoading = false; 
              scanning = false; 
            });
          }
        } else {
          _showMessage("Invalid QR code");
          setState(() {
            isLoading = false; 
            scanning = false; 
          });
        }

        await _storeScanHistory(scannedData, qrName);
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR/Barcode Scanner'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanHistoryScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                if (isLoading) CircularProgressIndicator(), 
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scannedData.isEmpty
                  ? Text(
                      'Scan a QR/Barcode',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  : Text(
                      'Last Scanned: $scannedData',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan History'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scan_history')
            .orderBy('timestamp', descending: true) 
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var historyDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: historyDocs.length,
            itemBuilder: (context, index) {
              var scan = historyDocs[index].data() as Map<String, dynamic>;
              var timestamp = (scan['timestamp'] as Timestamp).toDate();
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    scan['data'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
