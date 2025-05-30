import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/water_provider.dart';
import '../widgets/water_progress_card.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../../../../shared/widgets/animated_error_display.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addWaterEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim();

    try {
      await Provider.of<WaterProvider>(
        context,
        listen: false,
      ).addWaterEntry(amount, note: note.isNotEmpty ? note : null);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Water intake recorded')));
        _amountController.clear();
        _noteController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording water intake: $e')),
        );
      }
    }
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ShimmerLoading(height: 150),
          const SizedBox(height: 24.0),
          const ShimmerLoading(height: 200),
          const SizedBox(height: 24.0),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ShimmerLoading(height: 72),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Water Tracker'),
      actions: [
        Consumer<WaterProvider>(
          builder: (context, provider, child) {
            if (provider.isNetworkOperation) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<WaterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          return Column(
            children: [
              if (provider.error != null)
                AnimatedErrorDisplay(
                  message: provider.error!,
                  onRetry:
                      provider.error!.contains('sync')
                          ? () => provider.syncEntries()
                          : null,
                  onDismiss: () => provider.clearError(),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.initialize();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const WaterProgressCard(),
                        const SizedBox(height: 24.0),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Water Intake',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: _amountController,
                                    decoration: const InputDecoration(
                                      labelText: 'Amount (ml)',
                                      border: OutlineInputBorder(),
                                      suffixText: 'ml',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an amount';
                                      }
                                      final amount = double.tryParse(value);
                                      if (amount == null || amount <= 0) {
                                        return 'Please enter a valid amount';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16.0),
                                  TextFormField(
                                    controller: _noteController,
                                    decoration: const InputDecoration(
                                      labelText: 'Note (optional)',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: _addWaterEntry,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48.0),
                                    ),
                                    child: const Text('Add Entry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (provider.getTodayEntries().isNotEmpty) ...[
                          const SizedBox(height: 24.0),
                          Text(
                            'Today\'s Entries',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8.0),
                          ...provider.getTodayEntries().map(
                            (entry) => Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: const Icon(Icons.water_drop),
                                title: Text(
                                  '${entry.amount.toStringAsFixed(0)}ml',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat.jm().format(entry.date),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (entry.note?.isNotEmpty ?? false)
                                      Text(entry.note!),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed:
                                      () => provider.deleteWaterEntry(entry),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
