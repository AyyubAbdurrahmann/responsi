import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mahasiswa.dart';
import '../database/database_helper.dart';
import 'qr_generator_page.dart';
import 'qr_scanner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Mahasiswa> _mahasiswaList = [];
  List<Mahasiswa> _filteredList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMahasiswa();
  }

  Future<void> _loadMahasiswa() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllMahasiswa();
    print('Loaded mahasiswa: ${data.length} items');
    for (var m in data) {
      print('  NIM: ${m.nim}, Nama: ${m.nama}');
    }
    setState(() {
      _mahasiswaList = data;
      _filteredList = data;
      _isLoading = false;
    });
  }

  void _filterMahasiswa(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredList = _mahasiswaList;
      } else {
        _filteredList = _mahasiswaList.where((mahasiswa) {
          return mahasiswa.nama.toLowerCase().contains(query.toLowerCase()) ||
                 mahasiswa.nim.contains(query);
        }).toList();
      }
    });
  }

  void _showAddDialog() {
    final nimController = TextEditingController();
    final namaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_add, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('Tambah Mahasiswa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nimController,
              decoration: const InputDecoration(
                labelText: 'NIM',
                hintText: 'Masukkan NIM',
                prefixIcon: Icon(Icons.badge),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan Nama Lengkap',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel),
            label: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (nimController.text.isNotEmpty &&
                  namaController.text.isNotEmpty) {
                final nim = nimController.text.trim();
                final nama = namaController.text.trim();
                try {
                  await DatabaseHelper.instance.insertMahasiswa(
                    Mahasiswa(
                      nim: nim,
                      nama: nama,
                    ),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    _loadMahasiswa();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Data berhasil ditambahkan'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print('Error inserting mahasiswa: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: NIM sudah ada atau kesalahan lain'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Mahasiswa'),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: _filterMahasiswa,
                  decoration: InputDecoration(
                    hintText: 'Cari mahasiswa...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _filterMahasiswa(''),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${_mahasiswaList.length} mahasiswa',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Ditampilkan: ${_filteredList.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadMahasiswa,
              child: _filteredList.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isEmpty ? Icons.school : Icons.search_off,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Belum ada data mahasiswa'
                                      : 'Tidak ada mahasiswa yang cocok',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Tekan + untuk menambah'
                                      : 'Coba kata kunci lain',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _filteredList.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final mahasiswa = _filteredList[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                              child: Text(
                                mahasiswa.nama.isNotEmpty ? mahasiswa.nama[0].toUpperCase() : '?',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              mahasiswa.nama,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('NIM: ${mahasiswa.nim}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.qr_code,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            QRGeneratorPage(mahasiswa: mahasiswa),
                                      ),
                                    );
                                  },
                                  tooltip: 'Generate QR',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: Text('Hapus ${mahasiswa.nama}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await DatabaseHelper.instance.deleteMahasiswa(
                                        mahasiswa.id!,
                                      );
                                      _loadMahasiswa();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Data berhasil dihapus'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  tooltip: 'Hapus',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'scan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerPage()),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
