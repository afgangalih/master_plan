# Praktikum 1: Dasar State dengan Model-View – Flutter

## Deskripsi
Praktikum ini bertujuan untuk memahami **konsep state dalam Flutter**, dengan menerapkan arsitektur **Model–View** pada aplikasi sederhana bernama **Master Plan**.  
Aplikasi ini memungkinkan pengguna untuk:
- Menambahkan daftar rencana/tugas,
- Mengubah deskripsi tugas,
- Menandai tugas yang sudah selesai,
- Melihat daftar tugas dalam bentuk list yang dapat discroll.

---

## Struktur Folder Proyek

```
master_plan/
│
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── task.dart
│   │   ├── plan.dart
│   │   └── data_layer.dart
│   └── views/
│       └── plan_screen.dart
│
├── pubspec.yaml
└── README.md
```

---

## ⚙️ Langkah-Langkah Praktikum

### **Langkah 1: Membuat Project Baru**
Buat project Flutter baru dengan perintah:
```bash
flutter create master_plan
```
Lalu, buat folder `models` dan `views` di dalam folder `lib/`.

---

### **Langkah 2: Membuat Model `task.dart`**
Model ini merepresentasikan satu tugas (`Task`) dengan dua atribut utama:
```dart
class Task {
  final String description;
  final bool complete;

  const Task({
    this.complete = false,
    this.description = '',
  });
}
```

---

### **Langkah 3: Membuat Model `plan.dart`**
Model `Plan` menyimpan daftar tugas dalam bentuk list.
```dart
import './task.dart';

class Plan {
  final String name;
  final List<Task> tasks;

  const Plan({this.name = '', this.tasks = const []});
}
```

---

### **Langkah 4: Membuat File `data_layer.dart`**
File ini berfungsi untuk mengimpor kedua model agar mudah digunakan:
```dart
export 'plan.dart';
export 'task.dart';
```

---

### **Langkah 5: Mengatur File `main.dart`**
Menentukan halaman utama aplikasi dan tema warna.
```dart
import 'package:flutter/material.dart';
import './views/plan_screen.dart';

void main() => runApp(const MasterPlanApp());

class MasterPlanApp extends StatelessWidget {
  const MasterPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const PlanScreen(),
    );
  }
}
```

---

### **Langkah 6: Membuat View `plan_screen.dart` (Awal)**
Membuat kerangka dasar tampilan dengan StatefulWidget.
```dart
import '../models/data_layer.dart';
import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  Plan plan = const Plan();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Plan Namaku')),
      body: _buildList(),
      floatingActionButton: _buildAddTaskButton(),
    );
  }
}
```

---

### **Langkah 7: Menambahkan Tombol Tambah Task**
```dart
Widget _buildAddTaskButton() {
  return FloatingActionButton(
    child: const Icon(Icons.add),
    onPressed: () {
      setState(() {
        plan = Plan(
          name: plan.name,
          tasks: List<Task>.from(plan.tasks)..add(const Task()),
        );
      });
    },
  );
}
```

---

### **Langkah 8: Membuat Widget List**
```dart
Widget _buildList() {
  return ListView.builder(
    itemCount: plan.tasks.length,
    itemBuilder: (context, index) =>
        _buildTaskTile(plan.tasks[index], index),
  );
}
```

---

### **Langkah 9: Membuat Tile untuk Setiap Task**
```dart
Widget _buildTaskTile(Task task, int index) {
  return ListTile(
    leading: Checkbox(
      value: task.complete,
      onChanged: (selected) {
        setState(() {
          plan = Plan(
            name: plan.name,
            tasks: List<Task>.from(plan.tasks)
              ..[index] = Task(
                description: task.description,
                complete: selected ?? false,
              ),
          );
        });
      },
    ),
    title: TextFormField(
      initialValue: task.description,
      onChanged: (text) {
        setState(() {
          plan = Plan(
            name: plan.name,
            tasks: List<Task>.from(plan.tasks)
              ..[index] = Task(
                description: text,
                complete: task.complete,
              ),
          );
        });
      },
    ),
  );
}
```

---

### **Langkah 10–13: Menambahkan ScrollController**
Agar keyboard tidak menutupi text field terakhir:
```dart
late ScrollController scrollController;

@override
void initState() {
  super.initState();
  scrollController = ScrollController()
    ..addListener(() {
      FocusScope.of(context).requestFocus(FocusNode());
    });
}

@override
void dispose() {
  scrollController.dispose();
  super.dispose();
}

Widget _buildList() {
  return ListView.builder(
    controller: scrollController,
    keyboardDismissBehavior:
        Theme.of(context).platform == TargetPlatform.iOS
            ? ScrollViewKeyboardDismissBehavior.onDrag
            : ScrollViewKeyboardDismissBehavior.manual,
    itemCount: plan.tasks.length,
    itemBuilder: (context, index) =>
        _buildTaskTile(plan.tasks[index], index),
  );
}
```

---

## Konsep yang Dipelajari
1. **StatefulWidget dan State:**  
   Mengubah tampilan secara dinamis ketika data berubah menggunakan `setState()`.
2. **Model-View Separation:**  
   Logika data (`Plan`, `Task`) dipisahkan dari tampilan (`PlanScreen`).
3. **ListView.builder:**  
   Membuat tampilan list yang efisien untuk jumlah data dinamis.
4. **ScrollController:**  
   Mengatur perilaku scroll dan keyboard pada input teks.

---

## Dokumentasi Hasil

### Tampilan Awal


### Menambahkan Tugas


### Menandai Tugas Selesai


---

## Kesimpulan
Dari praktikum ini, kita memahami bahwa:
- **State** adalah inti dari perubahan tampilan dalam Flutter.
- Dengan menerapkan **Model-View pattern**, struktur kode menjadi lebih bersih dan mudah dikembangkan.
- `setState()` bukanlah variabel, melainkan **fungsi** untuk memperbarui tampilan saat data berubah.
