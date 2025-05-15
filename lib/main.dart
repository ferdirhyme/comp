import 'dart:io'; // Required for File operations
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:excel/excel.dart'; // Import the excel package
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

// Initialize Supabase client
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for Supabase initialization

  // Replace with your actual Supabase URL and anonymous key
  // Make sure this key is correct and has the necessary permissions configured in Supabase RLS.
  const String supabaseUrl = 'https://ykafrmaikuqliitrgizm.supabase.co';
  const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrYWZybWFpa3VxbGlpdHJnaXptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYzMTQ5MDksImV4cCI6MjA2MTg5MDkwOX0.cj6NhnfXzrLRgNCJzOgToToVEF7Fhckh2LiK8PLa5Wk';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: true, // Set to false in production
  );

  runApp(const TeacherDataCollectionApp());
}

// Access the Supabase client instance
final supabase = Supabase.instance.client;

class TeacherDataCollectionApp extends StatelessWidget {
  const TeacherDataCollectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Data Collection',
      theme: ThemeData(
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 14.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      home: const TeacherDataForm(),
    );
  }
}

class TeacherDataForm extends StatefulWidget {
  const TeacherDataForm({super.key});

  @override
  _TeacherDataFormState createState() => _TeacherDataFormState();
}

class _TeacherDataFormState extends State<TeacherDataForm> {
  final _formKey = GlobalKey<FormState>();
  // Keep _schoolNameController for Autocomplete field
  final _schoolNameController = TextEditingController();
  // District controller is no longer needed for user input, but keep for value
  final _districtController = TextEditingController(
    text: 'Tema Metro',
  ); // Set default value
  final _regionController = TextEditingController();

  final List<String> _schoolLevelOptions = [
    'PRIMARY',
    'JHS',
    'SHS',
    'SHTS',
    'TVET',
  ];
  List<String> _selectedSchoolLevels = [];
  String?
  _selectedSchoolType; // School type will be set by school name selection

  final List<Map<String, dynamic>> _teachersData = [];
  final List<Map<String, dynamic>> _nonProfessionalTeachersData = [];

  final List<String> _ghanaRegions = [
    "Ahafo Region",
    "Ashanti Region",
    "Bono Region",
    "Bono East Region",
    "Central Region",
    "Eastern Region",
    "Greater Accra Region",
    "Northern Region",
    "Oti Region",
    "Savannah Region",
    "Upper East Region",
    "Upper West Region",
    "Volta Region",
    "Western Region",
    "Western North Region",
    "North East Region",
  ];

  // Map of school names to their type (Public/Private) based on the image
  final Map<String, String> _schoolsList = {
    'TEMA METRO OFFICE STAFF': 'PUBLIC',
    'PRESBYTERIAN SHS': 'PUBLIC',
    'CHEMU SENIOR HIGH/TECH': 'PUBLIC',
    'ALDERSGATE SCHOOL COMPLEX': 'PRIVATE',
    'ANDY MEMORIAL SCHOOL': 'PRIVATE',
    'BERT SCHOOL COMPLEX': 'PRIVATE',
    'BETHEL METHODIST SCHOOL': 'PRIVATE',
    'BETHEL METHODIST SCHOOL-ANNEX': 'PRIVATE',
    'BEXHILL INT . SCH COMPLEX': 'PRIVATE',
    'CAMBRIDGE UNIVERSAL SCHOOL': 'PRIVATE',
    'CAMPRESCO ACADEMY': 'PRIVATE',
    'CANADIAN SPLENDOUR KIDS SCHOOL': 'PRIVATE',
    'CREATOR SCHOOLS': 'PRIVATE',
    'DATUS COMPLEX JHS': 'PRIVATE',
    'DEKS EDUCATIONAL INSTITUTE': 'PRIVATE',
    'FIRST STAR ACADEMY': 'PRIVATE',
    'GOLDEN TREASURES SCHOOL': 'PRIVATE',
    'JIFIS INTERNATIONAL SCHOOL': 'PRIVATE',
    'JOB SCHOOL COMPLEX': 'PRIVATE',
    'MARBS INTERNATIONAL SCHOOL': 'PRIVATE',
    'MAZON GRACE ACADEMY': 'PRIVATE',
    'ROBERT MEMORIAL SCHOOL': 'PRIVATE',
    'ROYAL SCHOOL TEMA': 'PRIVATE',
    'SHILOH COMMUNITY SCHOOL': 'PRIVATE',
    'SHINING STAR INTERNATIONAL SCHOOL': 'PRIVATE',
    'SOS HERMANN GMEINER SCHOOL': 'PRIVATE',
    'ST . JOHN METHODIST SCHOOL COMPLEX': 'PRIVATE',
    'TEMA HAPPY HOME SCHOOL COMPLEX': 'PRIVATE',
    'TEMA PARENTS\' ASSOCIATION SCHOOL ( BASIC )': 'PRIVATE',
    'TEMA REGULAR BAPTIST ACADEMY': 'PRIVATE',
    'ROSHARON MONTESSORI SCHOOL': 'PRIVATE',
    'ST . STEPHEN ANGLICAN SCHOOL': 'PRIVATE',
    'MANHEAN METHODIST BASIC SCHOOL': 'PUBLIC',
    'MANHEAN S.D.A BASIC SCHOOL': 'PUBLIC',
    'NAVAL BASE PRIMARY': 'PUBLIC',
    'NII ADJETEY ANSAH MEMORIAL J.H.S': 'PUBLIC',
    'MANHEAN COMMUNITY PRIMARY': 'PUBLIC',
    'MANHEAN TMA 1 JHS': 'PUBLIC',
    'ARCHBISHOP ANDOH R/C BASIC': 'PUBLIC',
    'REDEMPTION VALLEY PRIMARY AND K.G': 'PUBLIC',
    'REPUBLIC ROAD PRIMARY': 'PUBLIC',
    'COMMUNITY 7 NO.1 BASIC': 'PUBLIC',
    'REPUBLIC ROAD J.H.S': 'PUBLIC',
    'COMMUNITY 8 NO.4 J.H.S': 'PUBLIC',
    'COMMUNITY ONE PRESBYTERIAN PRIMARY SCHOOL': 'PUBLIC',
    'ONINKU DRIVE 1 J.H.S': 'PUBLIC',
    'AKODZO J.H.S': 'PUBLIC',
    'ST . PAUL METHODIST J.H.S': 'PUBLIC',
    'TWEDAASE J.H.S': 'PUBLIC',
    'MANHEAN SEC/TECH': 'PUBLIC',
    'ABIS EARLY CHILDHOOD CENTRE': 'PRIVATE',
    'AMEN BASIC SCHOOL TEMA MANHEAN': 'PRIVATE',
    'ANGELS SPECIALIST SCHOOL INTERNATIONAL': 'PRIVATE',
    'BENJAMIN STAR ACADEMY': 'PRIVATE',
    'CHARLOTTE\'S MEMORIAL SCHOOL': 'PRIVATE',
    'CHRIST REVELATION STAR ACADEMY': 'PRIVATE',
  };

  bool _isLoading = false; // State variable for loading indicator
  final String _downloadPassword =
      'your_secure_password'; // Replace with a strong password

  @override
  void initState() {
    super.initState();
    _addInitialTeacherRow();
    _addInitialNonProfessionalTeacherRow();
    // Set the district controller text once on init
    _districtController.text = 'Tema Metro';
  }

  void _addInitialTeacherRow() {
    _teachersData.add({
      'name': TextEditingController(),
      'gender': null,
      'contact': TextEditingController(),
      'licenseNo': TextEditingController(),
      'licenseRenewed': null,
      'registrationActive': null,
      'cpdDay': null,
      'plcs': null,
      'cpdPoints': TextEditingController(),
    });
  }

  void _addInitialNonProfessionalTeacherRow() {
    _nonProfessionalTeachersData.add({
      'name': TextEditingController(),
      'gender': null,
      'contact': TextEditingController(),
      'nonProfessional': false,
      'teacherEducation': null,
      'certificateAuth': null,
      'nationalCpdDay': null,
    });
  }

  void addTeacherRow() {
    setState(() {
      _teachersData.add({
        'name': TextEditingController(),
        'gender': null,
        'contact': TextEditingController(),
        'licenseNo': TextEditingController(),
        'licenseRenewed': null,
        'registrationActive': null,
        'cpdDay': null,
        'plcs': null,
        'cpdPoints': TextEditingController(),
      });
    });
  }

  void removeTeacherRow(int index) {
    setState(() {
      if (_teachersData.length > 1) {
        final removedTeacher = _teachersData.removeAt(index);
        (removedTeacher['name'] as TextEditingController).dispose();
        (removedTeacher['contact'] as TextEditingController).dispose();
        (removedTeacher['licenseNo'] as TextEditingController).dispose();
        (removedTeacher['cpdPoints'] as TextEditingController).dispose();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('At least one professional teacher row is required.'),
          ),
        );
      }
    });
  }

  void addNonProfessionalTeacherRow() {
    setState(() {
      _nonProfessionalTeachersData.add({
        'name': TextEditingController(),
        'gender': null,
        'contact': TextEditingController(),
        'nonProfessional': false,
        'teacherEducation': null,
        'certificateAuth': null,
        'nationalCpdDay': null,
      });
    });
  }

  void removeNonProfessionalTeacherRow(int index) {
    setState(() {
      if (_nonProfessionalTeachersData.length > 1) {
        final removedTeacher = _nonProfessionalTeachersData.removeAt(index);
        (removedTeacher['name'] as TextEditingController).dispose();
        (removedTeacher['contact'] as TextEditingController).dispose();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'At least one non-professional teacher row is required.',
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _districtController.dispose();
    _regionController.dispose();
    for (var teacherData in _teachersData) {
      (teacherData['name'] as TextEditingController).dispose();
      (teacherData['contact'] as TextEditingController).dispose();
      (teacherData['licenseNo'] as TextEditingController).dispose();
      (teacherData['cpdPoints'] as TextEditingController).dispose();
    }
    for (var teacherData in _nonProfessionalTeachersData) {
      (teacherData['name'] as TextEditingController).dispose();
      (teacherData['contact'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        // Check if a school with the same name, district, and region already exists
        final List<Map<String, dynamic>> existingSchools = await supabase
            .from('schools')
            .select('id')
            .eq('school_name', _schoolNameController.text)
            .eq(
              'district',
              _districtController.text,
            ) // Use the fixed district value
            .eq('region', _regionController.text);

        if (existingSchools.isNotEmpty) {
          // School already exists, show a message and stop
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This school has already been submitted.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isLoading = false; // Stop loading
          });
          return; // Stop the submission process
        }

        // 1. Insert School Data into the 'schools' table
        final List<Map<String, dynamic>> schoolInsertResponse =
            await supabase.from('schools').insert(
              [
                {
                  'school_name': _schoolNameController.text,
                  'district':
                      _districtController.text, // Use the fixed district value
                  'school_type':
                      _selectedSchoolType, // Use the selected school type
                  'region': _regionController.text,
                },
              ],
            ).select(); // Use .select() to return the inserted row, including the generated ID

        // Check if school insertion was successful and get the school ID
        if (schoolInsertResponse.isEmpty ||
            schoolInsertResponse.first['id'] == null) {
          throw const PostgrestException(
            message: 'Failed to insert school data and retrieve ID.',
          );
        }

        final String schoolId = schoolInsertResponse.first['id'];
        print('School data inserted with ID: $schoolId');

        // 2. Get the IDs of the selected school levels from the 'school_levels' table
        final List<Map<String, dynamic>>? levelIdsResponse = await supabase
            .from('school_levels')
            .select('id')
            .filter('level_name', 'in', _selectedSchoolLevels);

        if (levelIdsResponse == null || levelIdsResponse.isEmpty) {
          // Handle case where selected levels are not found (shouldn't happen if levels are pre-populated)
          print('Warning: Selected school levels not found in database.');
        } else {
          // 3. Insert into the 'school_school_levels' join table
          final List<Map<String, dynamic>> schoolSchoolLevelsData =
              levelIdsResponse.map((level) {
                return {
                  'school_id': schoolId, // Link to the newly created school
                  'level_id': level['id'], // Link to the school level ID
                };
              }).toList();

          if (schoolSchoolLevelsData.isNotEmpty) {
            await supabase
                .from('school_school_levels')
                .insert(schoolSchoolLevelsData);
            print('School-School Levels data inserted.');
          }
        }

        // 4. Insert Professional Teachers Data into the 'professional_teachers' table
        final List<Map<String, dynamic>> professionalTeachersData =
            _teachersData.map((teacherData) {
              return {
                'school_id': schoolId, // Link to the newly created school
                'name': (teacherData['name'] as TextEditingController).text,
                'gender': teacherData['gender'],
                'contact':
                    (teacherData['contact'] as TextEditingController).text,
                'license_no':
                    (teacherData['licenseNo'] as TextEditingController).text,
                'license_renewed': teacherData['licenseRenewed'],
                'registration_active': teacherData['registrationActive'],
                'participated_national_cpd_day': teacherData['cpdDay'],
                'participates_in_plcs': teacherData['plcs'],
                'cpd_points':
                    int.tryParse(
                      (teacherData['cpdPoints'] as TextEditingController).text,
                    ) ??
                    0,
              };
            }).toList();

        // Only attempt insert if there are professional teachers to add
        if (professionalTeachersData.isNotEmpty) {
          await supabase
              .from('professional_teachers')
              .insert(professionalTeachersData);
          print('Professional teachers data inserted.');
        }

        // 5. Insert Non-Professional Teachers Data into the 'non_professional_teachers' table
        final List<Map<String, dynamic>> nonProfessionalTeachersData =
            _nonProfessionalTeachersData.map((teacherData) {
              return {
                'school_id': schoolId, // Link to the newly created school
                'name': (teacherData['name'] as TextEditingController).text,
                'gender': teacherData['gender'],
                'contact':
                    (teacherData['contact'] as TextEditingController).text,
                'non_professional': teacherData['nonProfessional'],
                'teacher_education': teacherData['teacherEducation'],
                'certificate_auth': teacherData['certificateAuth'],
                'national_cpd_day': teacherData['nationalCpdDay'],
              };
            }).toList();

        // Only attempt insert if there are non-professional teachers to add
        if (nonProfessionalTeachersData.isNotEmpty) {
          await supabase
              .from('non_professional_teachers')
              .insert(nonProfessionalTeachersData);
          print('Non-professional teachers data inserted.');
        }

        print('All data submitted successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data submitted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        // Optionally clear the form here after successful submission
        // _formKey.currentState!.reset();
        // Clear controllers and teacher lists
      } on PostgrestException catch (e) {
        // Handle Supabase specific errors
        print('Supabase PostgrestException: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting data: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        // Handle any other unexpected errors
        print('An unexpected error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Stop loading in all cases
        });
      }
    } else {
      // Form validation failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
    }
  }

  // Function to retrieve and process data for Excel
  Future<void> _downloadData() async {
    // Request storage permission
    var status = await Permission.storage.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to download the file.'),
        ),
      );
      return;
    }

    String? enteredPassword = await _showPasswordDialog();
    if (enteredPassword == null || enteredPassword != _downloadPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect password.')));
      return;
    }

    setState(() {
      _isLoading = true; // Start loading for download
    });

    try {
      // Fetch all schools
      final List<Map<String, dynamic>> schools = await supabase
          .from('schools')
          .select('*');

      if (schools.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data found to download.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create a new Excel file
      var excel = Excel.createExcel();
      Sheet sheetObject =
          excel['Teacher Data']; // Create a sheet named 'Teacher Data'

      // Add headers
      List<String> headers = [
        'School Name',
        'District',
        'School Type',
        'Region',
        'School Levels',
        'Professional Teacher Name',
        'Professional Teacher Gender',
        'Professional Teacher Contact',
        'Professional Teacher License No.',
        'Professional Teacher License Renewed',
        'Professional Teacher Registration Active',
        'Professional Teacher Participated National CPD Day',
        'Professional Teacher Participates in PLCs',
        'Professional Teacher No of CPD Points',
        'Non-Professional Teacher Name',
        'Non-Professional Teacher Gender',
        'Non-Professional Teacher Contact',
        'Non-Professional Teacher Status',
        'Non-Professional Teacher Undergoing Education',
        'Non-Professional Teacher Certificate of Authorization',
        'Non-Professional Teacher Participated National CPD Day',
      ];

      // Add headers to the first row
      sheetObject.insertRowIterables(headers, 0);

      int rowIndex = 1; // Start from the second row for data

      // Iterate through each school and fetch related data
      for (var school in schools) {
        final String schoolId = school['id'];

        // Fetch school levels for this school
        final List<Map<String, dynamic>>? schoolLevelsResponse = await supabase
            .from('school_school_levels')
            .select(
              'level_id, school_levels(level_name)',
            ) // Select level_id and join to get level_name
            .eq('school_id', schoolId);

        final List<String> schoolLevels =
            (schoolLevelsResponse ?? [])
                .map((level) => level['school_levels']['level_name'] as String)
                .toList();

        // Fetch professional teachers for this school
        final List<Map<String, dynamic>>? professionalTeachers = await supabase
            .from('professional_teachers')
            .select('*')
            .eq('school_id', schoolId);

        // Fetch non-professional teachers for this school
        final List<Map<String, dynamic>>? nonProfessionalTeachers =
            await supabase
                .from('non_professional_teachers')
                .select('*')
                .eq('school_id', schoolId);

        // Combine school data with teacher data for each teacher
        // This approach will create multiple rows for a school if it has multiple teachers
        // You might need to adjust this logic based on how you want the data structured in Excel
        // For simplicity, let's create a row for each teacher, repeating school info.

        // Determine the maximum number of teachers for this school to ensure all are included
        int maxTeachers = 0;
        if (professionalTeachers != null)
          maxTeachers = professionalTeachers.length;
        if (nonProfessionalTeachers != null &&
            nonProfessionalTeachers.length > maxTeachers) {
          maxTeachers = nonProfessionalTeachers.length;
        }

        if (maxTeachers == 0) {
          // If no teachers, still add a row for the school info
          List<dynamic> rowData = [
            school['school_name'],
            school['district'],
            school['school_type'],
            school['region'],
            schoolLevels.join(', '), // Join levels into a single string
            // Empty fields for teacher data
            '', '', '', '', '', '', '', '', '',
            '', '', '', '', '', '', '',
          ];
          sheetObject.insertRowIterables(rowData, rowIndex++);
        } else {
          for (int i = 0; i < maxTeachers; i++) {
            List<dynamic> rowData = [
              // School Information (repeated for each teacher row)
              school['school_name'],
              school['district'],
              school['school_type'],
              school['region'],
              schoolLevels.join(', '), // Join levels into a single string
              // Professional Teacher Data
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['name']
                  : '',
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['gender']
                  : '',
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['contact']
                  : '',
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['license_no']
                  : '',
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['license_renewed']
                  : '',
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['registration_active']
                  : '',
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['participated_national_cpd_day']
                  : '',
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['participates_in_plcs']
                  : '',
              i < (professionalTeachers?.length ?? 0)
                  ? professionalTeachers![i]['cpd_points']
                  : '',

              // Non-Professional Teacher Data
              i < (nonProfessionalTeachers?.length ?? 0)
                  ? nonProfessionalTeachers![i]['name']
                  : '',
              i < (nonProfessionalTeachers?.length ?? 0)
                  ? nonProfessionalTeachers![i]['gender']
                  : '',
              i < (nonProfessionalTeachers?.length ?? 0)
                  ? nonProfessionalTeachers![i]['contact']
                  : '',
              i < (nonProfessionalTeachers?.length ?? 0)
                  ? nonProfessionalTeachers![i]['non_professional']
                  : '',
              i < (nonProfessionalTeachers?.length ?? 0)
                  ? nonProfessionalTeachers![i]['teacher_education']
                  : '',
              i < (nonProfessionalTeachers?.length ?? 0)
                  ? nonProfessionalTeachers![i]['certificate_auth']
                  : '',
              i < (nonProfessionalTeachers?.length ?? 0)
                  ? nonProfessionalTeachers![i]['national_cpd_day']
                  : '',
            ];
            sheetObject.insertRowIterables(rowData, rowIndex++);
          }
        }
      }

      // Save the Excel file
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/teacher_data.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      print('Data downloaded to: $filePath');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data downloaded to: $filePath')));
    } on PostgrestException catch (e) {
      print('Supabase PostgrestException during download: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading data: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('An unexpected error occurred during download: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  // Password dialog for download
  Future<String?> _showPasswordDialog() async {
    String? password;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password to Download'),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
            onChanged: (value) {
              password = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Download'),
              onPressed: () {
                Navigator.of(context).pop(password);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Data Collection'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Section One - Data of School'),
                _buildSchoolNameAutocomplete(), // Use the new autocomplete for school name
                _buildSchoolLevelCheckboxes(),
                // District field is now fixed to "Tema Metro" and not editable
                _buildTextField(
                  controller: _districtController,
                  label: 'DISTRICT',
                  readOnly: true, // Make the field read-only
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'District cannot be empty'; // Should not happen with default value
                    }
                    return null;
                  },
                ),
                _buildSchoolTypeRadio(), // Keep the radio buttons, their state will be set by school selection
                _buildRegionAutocomplete(),
                _buildSectionTitle(
                  'Section Two - Data of Professional Teachers',
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    // Adjusted column widths to prevent overflow and ensure consistency
                    columnWidths: const <int, TableColumnWidth>{
                      // Explicitly use TableColumnWidth
                      0: FixedColumnWidth(50),
                      1: IntrinsicColumnWidth(),
                      2: FixedColumnWidth(125),
                      3: IntrinsicColumnWidth(),
                      4: IntrinsicColumnWidth(),
                      5: FixedColumnWidth(130),
                      6: FixedColumnWidth(130),
                      7: FixedColumnWidth(180),
                      8: FixedColumnWidth(130),
                      9: IntrinsicColumnWidth(),
                      10: FixedColumnWidth(100),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _buildTeachersTableHeaderRow(),
                      ..._buildTeacherRows(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildAddTeacherButton(),
                _buildSectionTitle(
                  'Section Three - Data of Non-Professional Teachers',
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    // Adjusted column widths to prevent overflow and ensure consistency
                    columnWidths: const <int, TableColumnWidth>{
                      // Explicitly use TableColumnWidth
                      0: FixedColumnWidth(50),
                      1: IntrinsicColumnWidth(),
                      2: FixedColumnWidth(120),
                      3: IntrinsicColumnWidth(),
                      4: FixedColumnWidth(160),
                      5: FixedColumnWidth(190),
                      6: FixedColumnWidth(190),
                      7: FixedColumnWidth(190),
                      8: FixedColumnWidth(100),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _buildNonProfessionalTeachersTableHeaderRow(),
                      ..._buildNonProfessionalTeacherRows(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildAddNonProfessionalTeacherButton(),
                const SizedBox(height: 24),
                // Conditionally show loading indicator or submit button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSubmitButton(),
                const SizedBox(height: 16),
                // Download button
                ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : _downloadData, // Disable when loading
                  icon: const Icon(Icons.download),
                  label: const Text('Download All Data (Excel)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blueGrey, // Different color for download button
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the Autocomplete field for selecting the school name
  Widget _buildSchoolNameAutocomplete() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          // Filter the school list based on user input (case-insensitive)
          return _schoolsList.keys.where((String option) {
            return option.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            );
          });
        },
        onSelected: (String selection) {
          // Update the school name controller when a suggestion is selected
          _schoolNameController.text = selection;
          // Set the school type based on the selected school
          setState(() {
            _selectedSchoolType = _schoolsList[selection];
          });
          print('Selected School: $selection, Type: $_selectedSchoolType');
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
        ) {
          // Keep the internal _schoolNameController in sync with the Autocomplete's controller
          _schoolNameController.text = fieldTextEditingController.text;
          return TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: 'SCHOOL NAME',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
              floatingLabelStyle:
                  Theme.of(context).inputDecorationTheme.floatingLabelStyle,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter or select a school name';
              }
              return null;
            },
            onChanged: (value) {
              // Keep _schoolNameController in sync with the text field
              _schoolNameController.text = value;
              // If the user types a school name not in the list, clear the selected school type
              if (!_schoolsList.containsKey(value)) {
                setState(() {
                  _selectedSchoolType = null;
                });
              } else {
                // If the user types a school name that matches, set the type
                setState(() {
                  _selectedSchoolType = _schoolsList[value];
                });
              }
            },
          );
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                height: 200.0, // Constrain the height of the suggestion list
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(
                        title: Text(option),
                        trailing: Text(
                          _schoolsList[option] ?? '',
                        ), // Show school type
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Builds the Autocomplete field for selecting the region
  Widget _buildRegionAutocomplete() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          return _ghanaRegions.where((String option) {
            return option.toLowerCase().contains(
              textEditingValue.text.toLowerCase(),
            );
          });
        },
        onSelected: (String selection) {
          _regionController.text = selection;
          print('Selected Region: $selection');
        },
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted,
        ) {
          // Update the internal _regionController with the field's text
          _regionController.text = fieldTextEditingController.text;
          return TextFormField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: 'REGION',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
              floatingLabelStyle:
                  Theme.of(context).inputDecorationTheme.floatingLabelStyle,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter or select a region';
              }
              // Optional: Validate if the entered text is in the region list
              if (!_ghanaRegions.contains(value)) {
                return 'Please select a valid region from the suggestions';
              }
              return null;
            },
            onChanged: (value) {
              // Keep _regionController in sync with the text field
              _regionController.text = value;
            },
          );
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                height: 200.0,
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(title: Text(option)),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  TableRow _buildTeachersTableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: [
        _buildHeaderCell('S/N'),
        _buildHeaderCell('Name of Teacher'),
        _buildHeaderCell('Gender'),
        _buildHeaderCell('Contact'),
        _buildHeaderCell('License No.'),
        _buildHeaderCell('License Renewed'),
        _buildHeaderCell('Registration Active'),
        _buildHeaderCell('Participated in National CPD Day'),
        _buildHeaderCell('Participates in PLCs'),
        _buildHeaderCell('No of CPD Points'),
        _buildHeaderCell('Action'),
      ],
    );
  }

  List<TableRow> _buildTeacherRows() {
    // Ensure the number of cells in each row matches the columnWidths (11 columns)
    return _teachersData.asMap().entries.map((entry) {
      final index = entry.key;
      final teacherData = entry.value;

      return TableRow(
        key: ValueKey('teacher_row_$index'),
        children: [
          _buildTableCell(Center(child: Text('${index + 1}'))), // 1
          _buildTableCell(
            TextFormField(
              controller: teacherData['name'],
              decoration: _tableInputDecoration(hint: 'Name'),
              validator:
                  (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ), // 2
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Gender'),
              value: teacherData['gender'],
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('MALE')),
                DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['gender'] = value;
                });
              },
              validator: (value) => value == null ? 'Select gender' : null,
            ),
          ), // 3
          _buildTableCell(
            TextFormField(
              controller: teacherData['contact'],
              decoration: _tableInputDecoration(hint: 'Contact'),
              keyboardType: TextInputType.phone,
              validator:
                  (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ), // 4
          _buildTableCell(
            TextFormField(
              controller: teacherData['licenseNo'],
              decoration: _tableInputDecoration(hint: 'License No.'),
            ),
          ), // 5
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Select'),
              value: teacherData['licenseRenewed'],
              items: const [
                DropdownMenuItem(value: 'YES', child: Text('YES')),
                DropdownMenuItem(value: 'NO', child: Text('NO')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['licenseRenewed'] = value;
                });
              },
              validator: (value) => value == null ? 'Select' : null,
            ),
          ), // 6
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Select'),
              value: teacherData['registrationActive'],
              items: const [
                DropdownMenuItem(value: 'YES', child: Text('YES')),
                DropdownMenuItem(value: 'NO', child: Text('NO')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['registrationActive'] = value;
                });
              },
              validator: (value) => value == null ? 'Select' : null,
            ),
          ), // 7
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Select'),
              value: teacherData['cpdDay'],
              items: const [
                DropdownMenuItem(value: 'YES', child: Text('YES')),
                DropdownMenuItem(value: 'NO', child: Text('NO')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['cpdDay'] = value;
                });
              },
              validator: (value) => value == null ? 'Select' : null,
            ),
          ), // 8
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Select'),
              value: teacherData['plcs'],
              items: const [
                DropdownMenuItem(value: 'YES', child: Text('YES')),
                DropdownMenuItem(value: 'NO', child: Text('NO')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['plcs'] = value;
                });
              },
              validator: (value) => value == null ? 'Select' : null,
            ),
          ), // 9
          _buildTableCell(
            TextFormField(
              controller: teacherData['cpdPoints'],
              decoration: _tableInputDecoration(hint: 'Points'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (int.tryParse(value) == null) {
                  return 'Invalid #';
                }
                return null;
              },
            ),
          ), // 10
          TableCell(
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Remove Teacher',
              onPressed: () => removeTeacherRow(index),
            ),
          ), // 11
        ],
      );
    }).toList();
  }

  Widget _buildAddTeacherButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : addTeacherRow, // Disable when loading
      icon: const Icon(Icons.add),
      label: const Text('Add Professional Teacher'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  TableRow _buildNonProfessionalTeachersTableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade200),
      children: [
        _buildHeaderCell('S/N'),
        _buildHeaderCell('Name of Teacher'),
        _buildHeaderCell('Gender'),
        _buildHeaderCell('Contact'),
        _buildHeaderCell('Non-Professional Teacher'),
        _buildHeaderCell('Undergoing Teacher Education?'),
        _buildHeaderCell('Has Certificate of Authorization?'),
        _buildHeaderCell('Participated in National CPD Day?'),
        _buildHeaderCell('Action'),
      ],
    );
  }

  List<TableRow> _buildNonProfessionalTeacherRows() {
    // Ensure the number of cells in each row matches the columnWidths (9 columns)
    return _nonProfessionalTeachersData.asMap().entries.map((entry) {
      final index = entry.key;
      final teacherData = entry.value;

      return TableRow(
        key: ValueKey('non_prof_teacher_row_$index'),
        children: [
          _buildTableCell(Center(child: Text('${index + 1}'))), // 1
          _buildTableCell(
            TextFormField(
              controller: teacherData['name'],
              decoration: _tableInputDecoration(hint: 'Name'),
              validator:
                  (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ), // 2
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Gender'),
              value: teacherData['gender'],
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('MALE')),
                DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['gender'] = value;
                });
              },
              validator: (value) => value == null ? 'Select gender' : null,
            ),
          ), // 3
          _buildTableCell(
            TextFormField(
              controller: teacherData['contact'],
              decoration: _tableInputDecoration(hint: 'Contact'),
              keyboardType: TextInputType.phone,
              validator:
                  (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ), // 4
          _buildTableCell(
            Center(
              child: Checkbox(
                value: teacherData['nonProfessional'],
                onChanged: (value) {
                  setState(() {
                    teacherData['nonProfessional'] = value ?? false;
                  });
                },
              ),
            ),
          ), // 5
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Select'),
              value: teacherData['teacherEducation'],
              items: const [
                DropdownMenuItem(value: 'YES', child: Text('YES')),
                DropdownMenuItem(value: 'NO', child: Text('NO')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['teacherEducation'] = value;
                });
              },
              validator: (value) => value == null ? 'Select' : null,
            ),
          ), // 6
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Select'),
              value: teacherData['certificateAuth'],
              items: const [
                DropdownMenuItem(value: 'YES', child: Text('YES')),
                DropdownMenuItem(value: 'NO', child: Text('NO')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['certificateAuth'] = value;
                });
              },
              validator: (value) => value == null ? 'Select' : null,
            ),
          ), // 7
          _buildTableCell(
            DropdownButtonFormField<String>(
              decoration: _tableInputDecoration(hint: 'Select'),
              value: teacherData['nationalCpdDay'],
              items: const [
                DropdownMenuItem(value: 'YES', child: Text('YES')),
                DropdownMenuItem(value: 'NO', child: Text('NO')),
              ],
              onChanged: (value) {
                setState(() {
                  teacherData['nationalCpdDay'] = value;
                });
              },
              validator: (value) => value == null ? 'Select' : null,
            ),
          ), // 8
          TableCell(
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Remove Teacher',
              onPressed:
                  _isLoading
                      ? null
                      : () => removeNonProfessionalTeacherRow(
                        index,
                      ), // Disable when loading
            ),
          ), // 9
        ],
      );
    }).toList();
  }

  Widget _buildAddNonProfessionalTeacherButton() {
    return ElevatedButton.icon(
      onPressed:
          _isLoading
              ? null
              : addNonProfessionalTeacherRow, // Disable when loading
      icon: const Icon(Icons.add),
      label: const Text('Add Non-Professional Teacher'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTableCell(Widget child) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        child: child,
      ),
    );
  }

  static Widget _buildHeaderCell(String text) {
    return TableCell(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Center(
          child: Text(
            text,
            style: _tableHeaderStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  static const _tableHeaderStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  InputDecoration _tableInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 10.0,
      ),
      border: InputBorder.none,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorStyle: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontSize: 12,
      ), // Explicitly define error style
      errorMaxLines: 2, // Allow error text to wrap
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm, // Disable when loading
      child: const Text('Submit Data'),
    );
  }

  // Helper methods
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
      ),
    );
  }

  Widget _buildSchoolLevelCheckboxes() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<List<String>>(
        initialValue: _selectedSchoolLevels,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select at least one school level.';
          }
          return null;
        },
        builder: (FormFieldState<List<String>> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the appropriate school level(s):',
                style: Theme.of(context).inputDecorationTheme.labelStyle,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 0.0,
                children:
                    _schoolLevelOptions.map((level) {
                      final isSelected = field.value?.contains(level) ?? false;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  if (!_selectedSchoolLevels.contains(level)) {
                                    _selectedSchoolLevels.add(level);
                                  }
                                } else {
                                  _selectedSchoolLevels.remove(level);
                                }
                                field.didChange(
                                  List.from(_selectedSchoolLevels),
                                );
                              });
                            },
                          ),
                          Text(level),
                        ],
                      );
                    }).toList(),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSchoolTypeRadio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<String>(
        initialValue: _selectedSchoolType,
        validator: (value) {
          if (value == null) {
            return 'Please select a school type.';
          }
          return null;
        },
        builder: (FormFieldState<String> field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'School Type:',
                style: Theme.of(context).inputDecorationTheme.labelStyle,
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'PUBLIC',
                    groupValue: field.value,
                    // Disable onChanged as school type is set by autocomplete
                    onChanged:
                        _selectedSchoolType == 'PUBLIC'
                            ? (value) {
                              field.didChange(value);
                            }
                            : null,
                  ),
                  const Text('PUBLIC'),
                  const SizedBox(width: 16),
                  Radio<String>(
                    value: 'PRIVATE',
                    groupValue: field.value,
                    // Disable onChanged as school type is set by autocomplete
                    onChanged:
                        _selectedSchoolType == 'PRIVATE'
                            ? (value) {
                              field.didChange(value);
                            }
                            : null,
                  ),
                  const Text('PRIVATE'),
                ],
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 0.0, left: 12.0),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
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
