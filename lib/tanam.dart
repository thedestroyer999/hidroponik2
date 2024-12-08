import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Tanam extends StatefulWidget {
  @override
  _TanamState createState() => _TanamState();
}

class _TanamState extends State<Tanam> {
  // Controllers untuk Mulai Tanam
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jamController = TextEditingController();

  // Controllers untuk 1-4 Minggu
  final List<TextEditingController> ambangTdsControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> waktuMulaiControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> waktuBerakhirControllers =
      List.generate(4, (_) => TextEditingController());

  // Fungsi untuk memilih tanggal
  Future<void> _pilihTanggal(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        tanggalController.text = formattedDate;
      });
    }
  }

  // Fungsi untuk memilih jam
  Future<void> _pilihJam(BuildContext context, TextEditingController controller, {bool isMinggu = false}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      String formattedTime;
      if (isMinggu) {
        // Jika untuk Minggu, hanya format jam yang diambil
        formattedTime = "${pickedTime.hour.toString().padLeft(2, '0')}";
      } else {
        // Untuk Mulai Tanam, format lengkap dengan menit
        formattedTime = "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      }

      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  // Fungsi untuk mengirim data "Mulai Tanam"
  Future<void> kirimDataTanam() async {
    final String apiUrl = 'http://192.168.1.18/api/save_tanam.php'; // Ganti URL API

    try {
      if (tanggalController.text.isEmpty || jamController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Harap pilih tanggal dan jam terlebih dahulu!")),
        );
        return;
      }

      String formattedDatetime = "${tanggalController.text} ${jamController.text}:00";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'id_tanam': 1, // ID dummy, ganti sesuai kebutuhan
          'set_waktu': formattedDatetime,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data Mulai Tanam berhasil disimpan!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menyimpan data: ${responseData['message']}")),
          );
        }
      } else {
        throw Exception("Respons server tidak valid!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  // Fungsi untuk menghapus data "Mulai Tanam"
  Future<void> hapusDataTanam() async {
    final String apiUrl = 'http://192.168.1.18/api/delete_tanam.php'; // Ganti URL API

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Semua data tanam berhasil dihapus!")),
          );
          setState(() {
            tanggalController.clear();
            jamController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus data: ${responseData['error']}")),
          );
        }
      } else {
        throw Exception("Respons server tidak valid!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  // Fungsi untuk mengirim data pengukuran
  Future<void> kirimDataPengukuran(int index) async {
    final String apiUrl = 'http://192.168.1.18/api/save_tds.php';

    try {
      String ambangTds = ambangTdsControllers[index].text;
      String waktuMulai = waktuMulaiControllers[index].text;
      String waktuBerakhir = waktuBerakhirControllers[index].text;

      if (ambangTds.isEmpty || waktuMulai.isEmpty || waktuBerakhir.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pastikan semua data diisi untuk minggu ${index + 1}!")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'minggu_ke': index + 1,
          'ambang_tds': int.parse(ambangTds),
          'uv_start_hour': int.parse(waktuMulai),
          'uv_end_hour': int.parse(waktuBerakhir),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data minggu ${index + 1} berhasil disimpan!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menyimpan data: ${responseData['message']}")),
          );
        }
      } else {
        throw Exception("Respons server tidak valid!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  // Fungsi untuk menghapus data pengukuran
  Future<void> hapusDataPengukuran(int index) async {
    final String apiUrl = 'http://192.168.1.18/api/delete_tds.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'minggu_ke': index + 1}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Data minggu ${index + 1} berhasil dihapus!")),
          );
          setState(() {
            ambangTdsControllers[index].clear();
            waktuMulaiControllers[index].clear();
            waktuBerakhirControllers[index].clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus data minggu ${index + 1}: ${responseData['message']}")),
          );
        }
      } else {
        throw Exception("Respons server tidak valid!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Tanam', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Mulai Tanam
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mulai Tanam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tanggalController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Pilih Tanggal',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => _pilihTanggal(context),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: jamController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Pilih Jam',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.access_time),
                                onPressed: () => _pilihJam(context, jamController),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Spacer(),
                        ElevatedButton(
                          onPressed: kirimDataTanam,
                          child: Text("Kirim Data Tanam"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                        onPressed: hapusDataTanam,
                          child: Text("Hapus Data Tanam"),
                          style: ElevatedButton.styleFrom(
                           foregroundColor: Colors.white, backgroundColor: Colors.red, // Warna teks putih
                            ),
                           ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 1-4 Minggu
            for (int i = 0; i < 4; i++)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Minggu ${i + 1}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ambangTdsControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Ambang TDS',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: waktuMulaiControllers[i],
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Waktu Mulai',
                                      border: OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.access_time),
                                        onPressed: () => _pilihJam(context, waktuMulaiControllers[i], isMinggu: true),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: waktuBerakhirControllers[i],
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Waktu Berakhir',
                                      border: OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.access_time),
                                        onPressed: () => _pilihJam(context, waktuBerakhirControllers[i], isMinggu: true),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Spacer(),
                          ElevatedButton(
                            onPressed: () => kirimDataPengukuran(i),
                            child: Text("Kirim Data Minggu ${i + 1}"),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                           onPressed: () => hapusDataPengukuran(i),
                           child: Text("Hapus Data Minggu ${i + 1}"),
                           style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.red, // Warna teks putih
                           ),
                          ),
                        ],
                      ),
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
