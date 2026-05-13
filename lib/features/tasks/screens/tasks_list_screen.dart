import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  List<dynamic> tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final response = await Supabase.instance.client
          .from('course_assignments')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        tasks = response as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      debugPrint('ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis tareas'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text('No hay tareas'))
              : RefreshIndicator(
                  onRefresh: fetchTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index] as Map<String, dynamic>;

                      final id = task['id']?.toString();
                      final title = task['title']?.toString() ?? 'Sin título';
                      final description =
                          task['description']?.toString() ?? 'Sin descripción';
                      final type = task['assignment_type']?.toString() ?? 'task';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(description),
                          trailing: Text(
                            type == 'evaluation' ? 'Evaluación' : 'Tarea',
                          ),
                          onTap: id == null
                              ? null
                              : () => context.push('/tasks/$id'),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}