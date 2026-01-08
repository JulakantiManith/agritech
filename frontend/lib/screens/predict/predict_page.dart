import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class PredictPage extends StatefulWidget {
  const PredictPage({super.key});

  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  File? _image;
  bool _loading = false;
  String? plant;
  String? disease;
  double? confidence;
  Map<String, dynamic>? treatment;

  Color getConfidenceColor(double confidence) {
    if (confidence >= 70) return Colors.green;
    if (confidence >= 40) return Colors.orange;
    return Colors.red;
  }


  Future<void> predictDisease() async {
    if (_image == null) return;

    setState(() {
      _loading = true;
      plant = null;
      disease = null;
      confidence = null;
      treatment = null;
    });

    try {
      final result = await ApiService.predictImage(_image!);

      setState(() {
        plant = result["plant"];
        disease = result["disease"];
        confidence = result["confidence"];
        treatment = result["treatment"];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prediction failed: $e")),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  final picker = ImagePicker();

  Future<void> pickImageFromCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }


  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Disease Detection"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 📷 Image Preview
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: _image == null
                  ? const Center(
                child: Text(
                  "No image selected",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📂 Pick Image Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Gallery"),
                ),
              ],
            ),


            const SizedBox(height: 30),

            // 🔍 Predict Button (disabled for now)
            ElevatedButton(
              onPressed: _image == null ? null : predictDisease,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Predict Disease",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            if (confidence != null && confidence! < 40)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "⚠️ Low confidence. Please use a clear, close-up leaf image.",
                  style: TextStyle(color: Colors.red),
                ),
              ),


            // 📊 Result Card (UI placeholder)
            if (plant != null && confidence != null && confidence! >= 40)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Prediction Result",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Text("🌱 Plant: $plant"),
                      Text("🦠 Disease: $disease"),
                      Text(
                        "📊 Confidence: ${confidence!.toStringAsFixed(2)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getConfidenceColor(confidence!),
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: confidence! / 100,
                        minHeight: 8,
                        color: getConfidenceColor(confidence!),
                        backgroundColor: Colors.grey.shade300,
                      ),

                      const SizedBox(height: 10),

                      if (treatment != null) ...[
                        const SizedBox(height: 12),
                        const Text(
                          "💊 Treatment",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),

                        Card(
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Chemical: ${treatment!['chemical'].join(', ')}",
                            ),
                          ),
                        ),

                        Card(
                          color: Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Organic: ${treatment!['organic'].join(', ')}",
                            ),
                          ),
                        ),

                      ]
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
