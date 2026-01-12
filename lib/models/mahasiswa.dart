class Mahasiswa {
  final int? id;
  final String nim;
  final String nama;

  Mahasiswa({this.id, required this.nim, required this.nama});


  Map<String, dynamic> toMap() {
    return {'id': id, 'nim': nim, 'nama': nama};
  }

  factory Mahasiswa.fromMap(Map<String, dynamic> map) {
    return Mahasiswa(id: map['id'], nim: map['nim'], nama: map['nama']);
  }
}
