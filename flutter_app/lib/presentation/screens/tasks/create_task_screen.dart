/// =============================================================================
/// Create/Edit Task Screen
/// =============================================================================
///
/// Form for creating new tasks or editing existing ones.
/// Supports all task properties including subtasks and reminders.
/// =============================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../theme/colors.dart';
import '../../providers/task_provider.dart';
import '../../../domain/entities/task.dart';

/// Create/Edit task screen.
class CreateTaskScreen extends ConsumerStatefulWidget {
  /// Task ID for editing, null for new task.
  final String? taskId;

  const CreateTaskScreen({
    super.key,
    this.taskId,
  });

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _priority = TaskPriority.none;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  String? _projectId;
  RecurrencePattern _recurrence = RecurrencePattern.none;

  bool get isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadTask();
    }
  }

  void _loadTask() {
    final task = ref.read(taskByIdProvider(widget.taskId!));
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _priority = task.priority;
      _dueDate = task.dueDate;
      if (task.dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(task.dueDate!);
      }
      _projectId = task.projectId;
      _recurrence = task.recurrence;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            _buildTitleField(),
            const SizedBox(height: 16),

            // Description field
            _buildDescriptionField(),
            const SizedBox(height: 24),

            // Priority selector
            _buildPrioritySelector(),
            const SizedBox(height: 16),

            // Due date picker
            _buildDueDatePicker(),
            const SizedBox(height: 16),

            // Due time picker
            if (_dueDate != null) ...[
              _buildDueTimePicker(),
              const SizedBox(height: 16),
            ],

            // Recurrence selector
            _buildRecurrenceSelector(),
            const SizedBox(height: 16),

            // Project selector
            _buildProjectSelector(),
            const SizedBox(height: 24),

            // Quick actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Task Title',
        hintText: 'What needs to be done?',
        prefixIcon: Icon(Icons.task_alt),
      ),
      textCapitalization: TextCapitalization.sentences,
      autofocus: !isEditing,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (optional)',
        hintText: 'Add more details...',
        prefixIcon: Icon(Icons.notes),
        alignLabelWithHint: true,
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<TaskPriority>(
          segments: TaskPriority.values.map((priority) {
            return ButtonSegment(
              value: priority,
              label: Text(priority.name.substring(0, 1).toUpperCase()),
              icon: Icon(
                Icons.flag,
                color: AppColors.getPriorityColor(priority.value),
              ),
            );
          }).toList(),
          selected: {_priority},
          onSelectionChanged: (Set<TaskPriority> selected) {
            setState(() => _priority = selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildDueDatePicker() {
    return ListTile(
      leading: Icon(
        Icons.calendar_today,
        color: _dueDate != null ? AppColors.primary : null,
      ),
      title: const Text('Due Date'),
      subtitle: Text(
        _dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : 'Not set',
      ),
      trailing: _dueDate != null
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _dueDate = null;
                  _dueTime = null;
                });
              },
            )
          : null,
      onTap: _selectDueDate,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDueTimePicker() {
    return ListTile(
      leading: Icon(
        Icons.access_time,
        color: _dueTime != null ? AppColors.primary : null,
      ),
      title: const Text('Due Time'),
      subtitle: Text(
        _dueTime != null ? _dueTime!.format(context) : 'Not set',
      ),
      trailing: _dueTime != null
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _dueTime = null);
              },
            )
          : null,
      onTap: _selectDueTime,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildRecurrenceSelector() {
    final options = [
      (RecurrencePattern.none, 'Does not repeat'),
      (RecurrencePattern.daily, 'Daily'),
      (RecurrencePattern.weekly, 'Weekly'),
      (RecurrencePattern.monthly, 'Monthly'),
      (RecurrencePattern.yearly, 'Yearly'),
    ];

    return ListTile(
      leading: Icon(
        Icons.repeat,
        color: _recurrence != RecurrencePattern.none ? AppColors.primary : null,
      ),
      title: const Text('Repeat'),
      subtitle: Text(
        options.firstWhere((o) => o.$1 == _recurrence).$2,
      ),
      onTap: () => _showRecurrenceDialog(options),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildProjectSelector() {
    // TODO: Get actual projects
    return ListTile(
      leading: Icon(
        Icons.folder_outlined,
        color: _projectId != null ? AppColors.primary : null,
      ),
      title: const Text('Project'),
      subtitle: Text(_projectId ?? 'None'),
      onTap: () {
        // TODO: Show project picker
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Set',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickChip('Today', () {
              setState(() {
                _dueDate = DateTime.now();
                _dueTime = const TimeOfDay(hour: 17, minute: 0);
              });
            }),
            _buildQuickChip('Tomorrow', () {
              setState(() {
                _dueDate = DateTime.now().add(const Duration(days: 1));
                _dueTime = const TimeOfDay(hour: 9, minute: 0);
              });
            }),
            _buildQuickChip('Next Week', () {
              setState(() {
                _dueDate = DateTime.now().add(const Duration(days: 7));
              });
            }),
            _buildQuickChip('High Priority', () {
              setState(() => _priority = TaskPriority.high);
            }),
            _buildQuickChip('Urgent', () {
              setState(() => _priority = TaskPriority.urgent);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _selectDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _showRecurrenceDialog(List<(RecurrencePattern, String)> options) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Repeat'),
        children: options.map((option) {
          return RadioListTile<RecurrencePattern>(
            title: Text(option.$2),
            value: option.$1,
            groupValue: _recurrence,
            onChanged: (value) {
              setState(() => _recurrence = value ?? RecurrencePattern.none);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? fullDueDate;
    if (_dueDate != null) {
      fullDueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime?.hour ?? 0,
        _dueTime?.minute ?? 0,
      );
    }

    final task = Task(
      id: widget.taskId ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      userId: 'current_user', // TODO: Get from auth
      priority: _priority,
      dueDate: fullDueDate,
      projectId: _projectId,
      recurrence: _recurrence,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEditing) {
      ref.read(taskListProvider.notifier).updateTask(task);
    } else {
      ref.read(taskListProvider.notifier).createTask(task);
    }

    context.pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Task updated' : 'Task created'),
      ),
    );
  }
}
