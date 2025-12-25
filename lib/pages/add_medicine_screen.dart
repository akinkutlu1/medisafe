import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/notification_service.dart';
import '../services/medicine_catalog_service.dart';
import '../l10n/app_localizations.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  List<MedicineSuggestion> _nameSuggestions = [];
  String? _selectedImageFileName;
  bool _isScanningCamera = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String? _type;
  bool _alarmOn = false;
  String _regimen = 'Saatlik'; // Will be set to localized value in initState
  int? _intervalHours = 6; // null = test modu
  bool _mMorning = false;
  bool _mNoon = false;
  bool _mEvening = false;
  TimeOfDay? _tMorning;
  TimeOfDay? _tNoon;
  TimeOfDay? _tEvening;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize regimen with localized value after the first frame
      final localizations = AppLocalizations.of(context);
      setState(() {
        _regimen = localizations!.hourly;
      });
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _scanMedicineFromCamera() async {
    if (_isScanningCamera) return;
    setState(() => _isScanningCamera = true);
    try {
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (image == null) {
        setState(() => _isScanningCamera = false);
        return;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final scannedText = recognizedText.text.trim();
      if (scannedText.isEmpty) {
        setState(() => _isScanningCamera = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.textNotDetected)),
        );
        return;
      }

      // OCR sonucunu direkt input alanına yaz
      setState(() {
        _nameController.text = scannedText;
        _selectedImageFileName = null;
        _isScanningCamera = false;
      });

      // OCR metnini input alanına yazdıktan sonra arama yap
      if (scannedText.length >= 2) {
        final suggestions = await MedicineCatalogService.instance
            .searchByWords(scannedText);
        if (!mounted) return;
        setState(() {
          _nameSuggestions = suggestions;
        });
      }

      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameController.text.length),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isScanningCamera = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cameraReadFailed)),
        );
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.sessionRequired)),
      );
      return;
    }
    // Klavyeyi kapat
    FocusScope.of(context).unfocus();

    final localizations = AppLocalizations.of(context);
    final List<String>? mealTimes = _regimen == localizations!.mealBased
        ? [
            if (_mMorning && _tMorning != null)
              _formatTimeOfDay(_tMorning!),
            if (_mNoon && _tNoon != null)
              _formatTimeOfDay(_tNoon!),
            if (_mEvening && _tEvening != null)
              _formatTimeOfDay(_tEvening!),
          ]
        : null;

    if (_regimen == localizations!.mealBased && (mealTimes == null || mealTimes.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations!.selectAtLeastOneMeal)),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations!.endDateCannotBeBeforeStart)),
      );
      return;
    }

    final DateTime now = DateTime.now();
    DateTime? firstReminder;

    // Test modu aktifse (intervalHours null) 1 dakika sonrasına ayarla ve alarm'ı aç
    if (_intervalHours == null && _regimen == localizations!.hourly) {
      _alarmOn = true; // Test modu aktifken alarm'ı otomatik aç
      firstReminder = now.add(const Duration(minutes: 1));
    } else {
      firstReminder = _regimen == localizations!.hourly
          ? _calculateFirstHourlyReminder(now)
          : (mealTimes != null && mealTimes.isNotEmpty
              ? _findNextMealReminder(mealTimes, _startDate, now, _endDate)
              : null);
    }

    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'type': _type,
      'regimen': _regimen,
      'intervalHours': _regimen == localizations!.hourly ? _intervalHours : null,
      'mealTimes': mealTimes,
      'startDate': Timestamp.fromDate(DateTime(_startDate.year, _startDate.month, _startDate.day)),
      'endDate': Timestamp.fromDate(DateTime(_endDate.year, _endDate.month, _endDate.day)),
      'firstReminder': firstReminder != null ? Timestamp.fromDate(firstReminder) : null,
      'alarmOn': _alarmOn,
      'imageFileName': _selectedImageFileName,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
    };

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .add(data)
        .then((doc) async {
      // Schedule first notification if enabled and time selected
      if (_alarmOn) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations!.settingUpAlarm)));
        try {
          await _scheduleReminders(
            doc.id,
            docRef: doc,
            nextReminder: firstReminder,
          );
        } catch (_) {}
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations!.medicineSaved)),
      );
      Navigator.of(context).maybePop();
    }).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations!.couldNotSave)),
      );
    });
  }

  Future<void> _scheduleReminders(
    String id, {
    required DocumentReference<Map<String, dynamic>> docRef,
    DateTime? nextReminder,
  }) async {
    final DateTime endLimit = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
    DateTime? at = nextReminder;

    if (at != null && at.isBefore(DateTime.now())) {
      at = DateTime.now().add(const Duration(minutes: 1));
    }
    if (at != null && at.isAfter(endLimit)) {
      at = null;
    }

    await docRef.update({
      'firstReminder': at != null ? Timestamp.fromDate(at) : null,
    });

    if (at == null) {
      return;
    }

    final localizations = AppLocalizations.of(context);
    final String body = _regimen == localizations!.hourly
        ? localizations!.takeMedicine
        : localizations!.takeAfterMeal;

    await NotificationService.instance.scheduleMedicineReminder(
      docPath: docRef.path,
      medicineName: _nameController.text.trim(),
      at: at,
      body: body,
      imageFileName: _selectedImageFileName,
    );
  }

  String _formatTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseTimeString(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  DateTime? _findNextMealReminder(
    List<String> times,
    DateTime startDate,
    DateTime now,
    DateTime endDate,
  ) {
    if (times.isEmpty) return null;
    final DateTime base = DateTime(startDate.year, startDate.month, startDate.day);
    final DateTime today = DateTime(now.year, now.month, now.day);
    int offsetStart = today.difference(base).inDays;
    if (offsetStart < 0) offsetStart = 0;
    final DateTime endLimit = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    DateTime? candidate;

    for (int offset = offsetStart; offset < offsetStart + 7; offset++) {
      final DateTime day = base.add(Duration(days: offset));
      for (final entry in times) {
        final parsed = _parseTimeString(entry);
        if (parsed == null) continue;
        final DateTime dt = DateTime(day.year, day.month, day.day, parsed.hour, parsed.minute);
        if (dt.isAfter(now) && !dt.isAfter(endLimit)) {
          if (candidate == null || dt.isBefore(candidate)) {
            candidate = dt;
          }
        }
      }
      if (candidate != null) break;
    }

    return candidate;
  }

  DateTime? _calculateFirstHourlyReminder(DateTime now) {
    if (_intervalHours == null) return null; // Test modu
    final DateTime endLimit = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
    DateTime anchor = now;
    final DateTime startDay = DateTime(_startDate.year, _startDate.month, _startDate.day);
    if (startDay.isAfter(DateTime(now.year, now.month, now.day))) {
      anchor = DateTime(startDay.year, startDay.month, startDay.day, now.hour, now.minute);
    }
    DateTime candidate = anchor.add(Duration(hours: _intervalHours!));
    if (candidate.isBefore(now)) {
      candidate = now.add(Duration(hours: _intervalHours!));
    }
    if (candidate.isAfter(endLimit)) {
      return null;
    }
    return candidate;
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF1E66A6);
    final localizations = AppLocalizations.of(context);
    final InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.addNewMedicine),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations!.fillInfoAndSave,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                // Başlangıç tarihi
                InkWell(
                  onTap: () async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 0)),
                      lastDate: DateTime(DateTime.now().year + 3),
                      initialDate: _startDate,
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                        if (_endDate.isBefore(date)) {
                          _endDate = date;
                        }
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: localizations!.startDate,
                      border: border,
                      enabledBorder: border,
                    ),
                    child: Text(
                      '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: _startDate,
                      lastDate: DateTime(DateTime.now().year + 3),
                      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: localizations!.endDate,
                      border: border,
                      enabledBorder: border,
                    ),
                    child: Text(
                      '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: InputDecoration(
                    labelText: localizations!.name,
                    hintText: localizations!.enterMedicineName,
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                    suffixIcon: IconButton(
                      onPressed:
                          _isScanningCamera ? null : () => _scanMedicineFromCamera(),
                      icon: _isScanningCamera
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt),
                    ),
                  ),
                  onChanged: (value) async {
                    // İlaç adını yazdıkça önerileri getir
                    if (value.trim().length < 2) {
                      setState(() {
                        _nameSuggestions = [];
                        _selectedImageFileName = null;
                      });
                      return;
                    }
                    // Metindeki kelimelere göre yakın ilaçları bul
                    final suggestions = await MedicineCatalogService.instance
                        .searchByWords(value);
                    if (!mounted) return;
                    setState(() {
                      _nameSuggestions = suggestions;
                      _selectedImageFileName = null;
                    });
                  },
                  validator: (v) => (v == null || v.trim().isEmpty) ? localizations!.required : null,
                ),
                if (_nameSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _nameSuggestions.length,
                      itemBuilder: (context, index) {
                        final item = _nameSuggestions[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            item.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () {
                            setState(() {
                              _nameController.text = item.name;
                              _selectedImageFileName = item.imageFileName;
                              _nameSuggestions = [];
                            });
                            // İmleci sona al
                            _nameController.selection =
                                TextSelection.fromPosition(
                              TextPosition(offset: _nameController.text.length),
                            );
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  items: [
                    DropdownMenuItem(value: 'Tablet', child: Text(localizations!.tablet)),
                    DropdownMenuItem(value: 'Şurup', child: Text(localizations!.syrup)),
                    DropdownMenuItem(value: 'Kapsül', child: Text(localizations!.capsule)),
                    DropdownMenuItem(value: 'Enjeksiyon', child: Text(localizations!.injection)),
                  ],
                  onChanged: (v) => setState(() => _type = v),
                  decoration: InputDecoration(
                    labelText: localizations!.type,
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(color: primaryBlue),
                    ),
                  ),
                  validator: (v) => (v == null) ? localizations!.selectType : null,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 20),
                Text(
                  localizations!.reminders,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                // Rejim seçimi
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: localizations!.hourly, label: Text(localizations!.hourly)),
                    ButtonSegment(value: localizations!.mealBased, label: Text(localizations!.mealBased)),
                  ],
                  selected: {_regimen},
                  onSelectionChanged: (s) => setState(() => _regimen = s.first),
                ),
                const SizedBox(height: 12),
                // Öğün modunda genel tarih-saat seçimi kaldırıldı; her öğün için ayrı saat seçiliyor
                if (_regimen == localizations!.hourly) ...[
                  Row(
                    children: [
                      Text('${localizations!.interval}: '),
                      DropdownButton<int?>(
                        value: _intervalHours,
                        onChanged: (v) => setState(() => _intervalHours = v),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('Test (1 dk)')),
                          ...List<int>.generate(9, (i) => i + 4)
                              .map((e) => DropdownMenuItem<int?>(value: e, child: Text('$e ${localizations!.hours}')))
                              .toList(),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  _MealSelector(
                    title: localizations!.morning,
                    value: _mMorning,
                    time: _tMorning,
                    onChanged: (v) => setState(() => _mMorning = v),
                    onPickTime: () async {
                      final t = await showTimePicker(context: context, initialTime: _tMorning ?? const TimeOfDay(hour: 8, minute: 0));
                      if (t != null) setState(() => _tMorning = t);
                    },
                  ),
                  _MealSelector(
                    title: localizations!.afternoon,
                    value: _mNoon,
                    time: _tNoon,
                    onChanged: (v) => setState(() => _mNoon = v),
                    onPickTime: () async {
                      final t = await showTimePicker(context: context, initialTime: _tNoon ?? const TimeOfDay(hour: 12, minute: 30));
                      if (t != null) setState(() => _tNoon = t);
                    },
                  ),
                  _MealSelector(
                    title: localizations!.evening,
                    value: _mEvening,
                    time: _tEvening,
                    onChanged: (v) => setState(() => _mEvening = v),
                    onPickTime: () async {
                      final t = await showTimePicker(context: context, initialTime: _tEvening ?? const TimeOfDay(hour: 19, minute: 0));
                      if (t != null) setState(() => _tEvening = t);
                    },
                  ),
                ],
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _alarmOn,
                  onChanged: (v) => setState(() => _alarmOn = v),
                  title: Text(localizations!.alarmEnabled),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(localizations!.save, style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealSelector extends StatelessWidget {
  const _MealSelector({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.onPickTime,
    required this.time,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onPickTime;
  final TimeOfDay? time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
        Text(title),
        const SizedBox(width: 12),
        if (value)
          OutlinedButton.icon(
            onPressed: onPickTime,
            icon: const Icon(Icons.schedule),
            label: Text(
              time != null
                  ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
                  : AppLocalizations.of(context)!.selectTime,
            ),
          ),
      ],
    );
  }
}
