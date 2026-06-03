// lib/presentation/screens/measurement/measurement_entry_screen.dart
//
// MEASUREMENT ENTRY SCREEN
// ========================
// The Measurer's primary tool. Designed for use on a construction site:
// - Big buttons (minimum 56px height) for glove-friendly tapping
// - Voice input with noise handling
// - Quick material selection
// - Priority setting
//
// VOICE FLOW:
// 1. User taps the big MIC button (or says wake word "Measure")
// 2. App prompts: "Say your measurement"
// 3. User speaks: "Forty-eight inches by twenty-six inches, quartz countertop"
// 4. App parses, shows large confirmation card
// 5. User taps ✅ (confirm) or ❌ (retry)
//
// MANUAL FALLBACK:
// - Big number pad for dimensions
// - Material dropdown with recent/frequent materials
// - Voice fills the same fields, just as an input method

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../data/models/measurement.dart';
import '../../../core/theme/app_theme.dart';

class MeasurementEntryScreen extends ConsumerStatefulWidget {
  final String projectId;

  const MeasurementEntryScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<MeasurementEntryScreen> createState() =>
      _MeasurementEntryScreenState();
}

class _MeasurementEntryScreenState
    extends ConsumerState<MeasurementEntryScreen> {
  // ── Controllers ──
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _materialController = TextEditingController();
  final _notesController = TextEditingController();

  // ── State ──
  MeasurementUnit _selectedUnit = MeasurementUnit.inches;
  Priority _selectedPriority = Priority.medium;
  bool _isListening = false;
  bool _isSaving = false;
  String _voiceStatus = ''; // Status message for voice input

  // ── Speech to Text ──
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;

  // ── Recent materials (would come from a provider in real app) ──
  final List<String> _recentMaterials = [
    '3/4" Plywood',
    '1/2" Plywood',
    '2x4',
    '2x6',
    '2x8',
    '2x10',
    '4x4',
    '1x4',
    '1x6',
    '5/4 Decking',
    'Drywall 1/2"',
    'Drywall 5/8"',
    'OSB 7/16"',
    'LVL 1-3/4"',
    'Trim 1x3',
    'Trim 1x4',
    'Casing 2-1/4"',
    'Baseboard 3-1/4"',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialize speech recognition
  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            _isListening = status == 'listening';
            _voiceStatus = _getVoiceStatusMessage(status);
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _voiceStatus = 'Couldn\'t hear that. Try again.';
          });
        }
      },
    );
    if (mounted) setState(() {});
  }

  String _getVoiceStatusMessage(String status) {
    switch (status) {
      case 'listening':
        return 'Listening...';
      case 'notListening':
        return '';
      case 'done':
        return '';
      default:
        return status;
    }
  }

  /// Start voice input
  void _startListening() async {
    if (!_speechAvailable) {
      setState(() {
        _voiceStatus = 'Voice input not available on this device';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _voiceStatus = 'Listening...';
    });

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      localeId: 'en_US',
      // Noise handling: use the device's built-in processing
      cancelOnError: true,
    );
  }

  /// Stop voice input
  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _voiceStatus = '';
    });
  }

  /// Handle speech recognition results
  void _onSpeechResult(result) {
    if (!result.hasConfidenceRating || result.confidence > 0.5) {
      final spoken = result.recognizedWords;
      setState(() {
        _isListening = false;
        _voiceStatus = '';
      });
      _parseVoiceInput(spoken);
    } else {
      setState(() {
        _voiceStatus = 'Didn\'t catch that clearly. Please try again.';
        _isListening = false;
      });
    }
  }

  /// Parse voice input into measurement fields
  /// Handles phrases like:
    /// "48 inches by 26 inches quartz countertop"
    /// "two by four ten foot"
    /// "3/4 plywood 4 by 8"
  void _parseVoiceInput(String input) {
    final lower = input.toLowerCase().trim();

    // Parse dimensions - look for patterns like:
    // "48 by 26", "48 x 26", "48 inches by 26 inches"
    final dimPattern = RegExp(
      r'(\d+(?:/\d+)?(?:\s+\d+/\d+)?)\s*(?:inches?|in|feet|ft|cm|m)?\s*(?:by|x|×)\s*(\d+(?:/\d+)?(?:\s+\d+/\d+)?)\s*(?:inches?|in|feet|ft|cm|m)?(?:\s*(?:by|x|×)\s*(\d+(?:/\d+)?)\s*(?:inches?|in|feet|ft|cm|m)?)?',
    );

    final match = dimPattern.firstMatch(lower);
    if (match != null) {
      _lengthController.text = match.group(1)?.trim() ?? '';
      _widthController.text = match.group(2)?.trim() ?? '';
      if (match.group(3) != null) {
        _heightController.text = match.group(3)!.trim();
      }
    }

    // Detect unit
    if (lower.contains('foot') || lower.contains('feet') || lower.contains(' ft')) {
      _selectedUnit = MeasurementUnit.feet;
    } else if (lower.contains('cm') || lower.contains('centimeter')) {
      _selectedUnit = MeasurementUnit.centimeters;
    } else if (lower.contains('meter') || lower.contains(' m ')) {
      _selectedUnit = MeasurementUnit.meters;
    } else {
      _selectedUnit = MeasurementUnit.inches; // default
    }

    // Detect material type
    final materialKeywords = <String, String>{
      'plywood': 'Plywood',
      'drywall': 'Drywall',
      'osb': 'OSB',
      'two by four': '2x4',
      '2x4': '2x4',
      '2x6': '2x6',
      '2x8': '2x8',
      'two by six': '2x6',
      'two by eight': '2x8',
      'two by ten': '2x10',
      'decking': 'Decking',
      'trim': 'Trim',
      'casing': 'Casing',
      'baseboard': 'Baseboard',
      'countertop': 'Countertop',
      'tile': 'Tile',
      'lumber': 'Lumber',
      'lvl': 'LVL',
      'joist': 'Joist',
      'rafter': 'Rafter',
      'stud': 'Stud',
      'beam': 'Beam',
      'concrete': 'Concrete',
      'insulation': 'Insulation',
      'shingle': 'Shingle',
      'flashing': 'Flashing',
    };

    for (final entry in materialKeywords.entries) {
      if (lower.contains(entry.key)) {
        _materialController.text = entry.value;
        break;
      }
    }

    // Detect quantity
    final qtyPattern = RegExp(r'\b(\d+)\s*(?:pieces?|sheets?|boards?|pcs?|qty)\b');
    final qtyMatch = qtyPattern.firstMatch(lower);
    if (qtyMatch != null) {
      _quantityController.text = qtyMatch.group(1)!;
    }

    // Show confirmation
    setState(() {
      _voiceStatus = 'Got it! Check and confirm: "$input"';
    });
  }

  /// Save the measurement
  Future<void> _saveMeasurement() async {
    if (_lengthController.text.isEmpty || _materialController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Length and material type are required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // TODO: Parse dimensions and save to database
    // final measurement = Measurement(
    //   id: uuid.v4(),
    //   projectId: widget.projectId,
    //   measuredByUserId: currentUserId,
    //   dimensions: Dimensions(
    //     length: double.parse(_lengthController.text),
    //     width: _widthController.text.isNotEmpty ? double.parse(_widthController.text) : null,
    //     height: _heightController.text.isNotEmpty ? double.parse(_heightController.text) : null,
    //     unit: _selectedUnit,
    //   ),
    //   materialType: _materialController.text,
    //   quantity: int.parse(_quantityController.text),
    //   priority: _selectedPriority,
    //   notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    //   createdAt: DateTime.now(),
    // );

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Measurement saved: ${_materialController.text}'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      _clearForm();
    }
  }

  /// Clear the form for the next measurement
  void _clearForm() {
    _lengthController.clear();
    _widthController.clear();
    _heightController.clear();
    _quantityController.text = '1';
    _materialController.clear();
    _notesController.clear();
    _selectedUnit = MeasurementUnit.inches;
    _selectedPriority = Priority.medium;
    setState(() {});
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _quantityController.dispose();
    _materialController.dispose();
    _notesController.dispose();
    if (_speech.isListening) _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Measurement'),
        actions: [
          // Save button in app bar
          TextButton(
            onPressed: _isSaving ? null : _saveMeasurement,
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: GestureDetector(
        // Dismiss keyboard when tapping outside
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // ═══ VOICE INPUT SECTION ═══
            _buildVoiceSection(),

            // ═══ MANUAL ENTRY SECTION ═══
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Voice status message
                    if (_voiceStatus.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _voiceStatus,
                                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ═══ DIMENSIONS ═══
                    Text('Dimensions', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    // Dimension inputs row
                    Row(
                      children: [
                        // Length
                        Expanded(
                          child: _DimensionField(
                            label: 'Length *',
                            hint: '48',
                            controller: _lengthController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Width
                        Expanded(
                          child: _DimensionField(
                            label: 'Width',
                            hint: '26',
                            controller: _widthController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Height / Thickness
                        Expanded(
                          child: _DimensionField(
                            label: 'Height',
                            hint: '3/4',
                            controller: _heightController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Unit selector - big buttons
                    _UnitSelector(
                      selected: _selectedUnit,
                      onChanged: (unit) => setState(() => _selectedUnit = unit),
                    ),
                    const SizedBox(height: 24),

                    // ═══ MATERIAL TYPE ═══
                    Text('Material Type', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _materialController,
                      decoration: const InputDecoration(
                        hintText: 'e.g., 3/4" Plywood, 2x4, Tile',
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Recent materials chips - big tap targets
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recentMaterials.map((material) {
                        final isSelected = _materialController.text == material;
                        return ActionChip(
                          label: Text(material),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey[200],
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          onPressed: () {
                            setState(() => _materialController.text = material);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ═══ QUANTITY ═══
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quantity', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              _QuantityStepper(
                                controller: _quantityController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Priority', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              _PrioritySelector(
                                selected: _selectedPriority,
                                onChanged: (p) => setState(() => _selectedPriority = p),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ═══ NOTES ═══
                    Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Any additional notes...',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ═══ SAVE BUTTON (large) ═══
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveMeasurement,
                        icon: const Icon(Icons.check, size: 24),
                        label: Text(_isSaving ? 'SAVING...' : 'SAVE MEASUREMENT'),
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // VOICE SECTION
  // ══════════════════════════════════════════

  Widget _buildVoiceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _isListening
          ? AppTheme.primaryColor.withOpacity(0.08)
          : Colors.grey[50],
      child: Column(
        children: [
          // Big microphone button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isListening ? 120 : 96,
              height: _isListening ? 120 : 96,
              decoration: BoxDecoration(
                color: _isListening ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: _isListening ? 20 : 8,
                    spreadRadius: _isListening ? 4 : 0,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: _isListening ? 56 : 44,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isListening ? '🔴 Listening — say your measurement' : '🎤 Tap to speak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isListening ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Example: "48 inches by 26 inches, 3/4 plywood"',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════
// HELPER WIDGETS
// ══════════════════════════════════════════════════

class _DimensionField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _DimensionField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  final MeasurementUnit selected;
  final ValueChanged<MeasurementUnit> onChanged;

  const _UnitSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MeasurementUnit.values.map((unit) {
        final isSelected = unit == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => onChanged(unit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : AppTheme.textPrimary,
                  elevation: isSelected ? 2 : 0,
                ),
                child: Text(
                  unit.symbol,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final TextEditingController controller;

  const _QuantityStepper({required this.controller});

  @override
  Widget build(BuildContext context) {
    int value = int.tryParse(controller.text) ?? 1;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Decrease button
          SizedBox(
            width: 56,
            height: 56,
            child: IconButton(
              onPressed: () {
                if (value > 1) {
                  controller.text = (--value).toString();
                }
              },
              icon: const Icon(Icons.remove_circle_outline),
              iconSize: 28,
            ),
          ),
          // Value display
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Increase button
          SizedBox(
            width: 56,
            height: 56,
            child: IconButton(
              onPressed: () {
                controller.text = (++value).toString();
              },
              icon: const Icon(Icons.add_circle_outline),
              iconSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final Priority selected;
  final ValueChanged<Priority> onChanged;

  const _PrioritySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((priority) {
        final isSelected = priority == selected;
        final color = AppTheme.priorityColors[priority.name]!;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => onChanged(priority),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? color : color.withOpacity(0.15),
                  foregroundColor: isSelected ? Colors.white : color,
                  elevation: isSelected ? 2 : 0,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  priority.displayName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
