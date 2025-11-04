import 'package:flutter/material.dart';
import '../models/data_layer.dart';
import '../provider/plan_provider.dart';

class PlanScreen extends StatefulWidget {
  final Plan plan;
  const PlanScreen({super.key, required this.plan});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
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

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.name)),
      body: ValueListenableBuilder<List<Plan>>(
        valueListenable: plansNotifier,
        builder: (context, plans, child) {
          // Selalu cari plan dari provider, fallback ke widget.plan jika belum ada
          final currentPlan = plans.firstWhere(
            (p) => p.name == widget.plan.name,
            orElse: () => widget.plan,
          );

          return Column(
            children: [
              Expanded(child: _buildList(currentPlan, plansNotifier)),
              SafeArea(child: Text(currentPlan.completenessMessage)),
            ],
          );
        },
      ),
      floatingActionButton: _buildAddTaskButton(plansNotifier),
    );
  }

  Widget _buildAddTaskButton(ValueNotifier<List<Plan>> planNotifier) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        final plans = planNotifier.value;
        final planIndex = plans.indexWhere((p) => p.name == widget.plan.name);

        final currentPlan = planIndex != -1 ? plans[planIndex] : widget.plan;
        final updatedTasks = List<Task>.from(currentPlan.tasks)..add(const Task());

        if (planIndex == -1) {
          // Tambah plan baru
          planNotifier.value = [...plans, Plan(name: currentPlan.name, tasks: updatedTasks)];
        } else {
          // Update plan yang ada
          planNotifier.value = plans
            ..[planIndex] = Plan(
              name: currentPlan.name,
              tasks: updatedTasks,
            );
        }
      },
    );
  }

  Widget _buildList(Plan currentPlan, ValueNotifier<List<Plan>> planNotifier) {
    return ListView.builder(
      controller: scrollController,
      itemCount: currentPlan.tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskTile(currentPlan, index, planNotifier);
      },
    );
  }

  Widget _buildTaskTile(Plan currentPlan, int index, ValueNotifier<List<Plan>> planNotifier) {
    final plans = planNotifier.value;
    final planIndex = plans.indexWhere((p) => p.name == widget.plan.name);

    // Jika plan belum ada di provider, jangan izinkan edit
    if (planIndex == -1) {
      return ListTile(
        leading: Checkbox(value: false, onChanged: null),
        title: TextFormField(
          initialValue: currentPlan.tasks[index].description,
          enabled: false,
        ),
      );
    }

    return ListTile(
      leading: Checkbox(
        value: currentPlan.tasks[index].complete,
        onChanged: (selected) {
          final updatedTasks = List<Task>.from(currentPlan.tasks)
            ..[index] = Task(
              description: currentPlan.tasks[index].description,
              complete: selected ?? false,
            );

          planNotifier.value = plans
            ..[planIndex] = Plan(
              name: currentPlan.name,
              tasks: updatedTasks,
            );
        },
      ),
      title: TextFormField(
        initialValue: currentPlan.tasks[index].description,
        onChanged: (text) {
          final updatedTasks = List<Task>.from(currentPlan.tasks)
            ..[index] = Task(
              description: text,
              complete: currentPlan.tasks[index].complete,
            );

          planNotifier.value = plans
            ..[planIndex] = Plan(
              name: currentPlan.name,
              tasks: updatedTasks,
            );
        },
      ),
    );
  }
}
