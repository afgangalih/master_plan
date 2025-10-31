import '../models/data_layer.dart';
import '../provider/plan_provider.dart';
import 'package:flutter/material.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // Hapus variabel plan (karena sekarang data berasal dari PlanProvider)

  // Langkah 10 (Praktikum 1): Deklarasi ScrollController
  late ScrollController scrollController;

  // Langkah 11 (Praktikum 1): Inisialisasi + Listener untuk menghapus fokus saat scroll
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        // Hapus fokus dari TextField saat pengguna scroll
        FocusScope.of(context).requestFocus(FocusNode());
      });
  }

  // Langkah 13 (Praktikum 1): Bersihkan controller saat widget dihapus
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // Langkah 8–9 (Praktikum 2)
  // Ubah build agar menampilkan progress (footer) di bagian bawah menggunakan Column + SafeArea
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Plan Afgan')),
      body: ValueListenableBuilder<Plan>(
        valueListenable: PlanProvider.of(context),
        builder: (context, plan, child) {
          return Column(
            children: [
              // Expanded agar ListView bisa mengisi ruang yang tersedia
              Expanded(child: _buildList(plan)),

              // SafeArea untuk menampilkan pesan progress di bagian bawah layar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(plan.completenessMessage),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildAddTaskButton(context),
    );
  }

  // Langkah 5 (Praktikum 2)
  // Edit _buildAddTaskButton agar menggunakan PlanProvider sebagai sumber data
  Widget _buildAddTaskButton(BuildContext context) {
    ValueNotifier<Plan> planNotifier = PlanProvider.of(context);
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        // Ambil plan saat ini, lalu tambahkan task baru
        Plan currentPlan = planNotifier.value;
        planNotifier.value = Plan(
          name: currentPlan.name,
          tasks: List<Task>.from(currentPlan.tasks)..add(const Task()),
        );
      },
    );
  }

  // Langkah 7 (Praktikum 2)
  // Edit _buildList agar menyesuaikan parameter dan memanggil _buildTaskTile dengan context
  Widget _buildList(Plan plan) {
    return ListView.builder(
      controller: scrollController,
      itemCount: plan.tasks.length,
      itemBuilder: (context, index) =>
          _buildTaskTile(plan.tasks[index], index, context),
    );
  }

  // Langkah 6 (Praktikum 2)
  // Edit _buildTaskTile agar menggunakan PlanProvider dan TextFormField
  Widget _buildTaskTile(Task task, int index, BuildContext context) {
    ValueNotifier<Plan> planNotifier = PlanProvider.of(context);

    return ListTile(
      leading: Checkbox(
        value: task.complete,
        onChanged: (selected) {
          // Perbarui status checkbox task
          Plan currentPlan = planNotifier.value;
          planNotifier.value = Plan(
            name: currentPlan.name,
            tasks: List<Task>.from(currentPlan.tasks)
              ..[index] = Task(
                description: task.description,
                complete: selected ?? false,
              ),
          );
        },
      ),

      // Gunakan TextFormField agar mudah menginisialisasi data dari provider
      title: TextFormField(
        initialValue: task.description,
        onChanged: (text) {
          // Perbarui deskripsi task saat teks berubah
          Plan currentPlan = planNotifier.value;
          planNotifier.value = Plan(
            name: currentPlan.name,
            tasks: List<Task>.from(currentPlan.tasks)
              ..[index] = Task(
                description: text,
                complete: task.complete,
              ),
          );
        },
      ),
    );
  }
}
