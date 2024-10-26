import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare Pro',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF00BFA6),
        scaffoldBackgroundColor: const Color(0xFF0A1128),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF00BFA6),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A1128),
              const Color(0xFF1B3A6B),
              const Color(0xFF16213E).withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          size: 80,
                          color: Color(0xFF00BFA6),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'MediCare Pro',
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your Health, Our Priority',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildTextField(
                        label: 'Email',
                        icon: Icons.email_rounded,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Password',
                        isObscure: true,
                        icon: Icons.lock_rounded,
                        onChanged: (value) {},
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFF00BFA6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleLogin(context),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF00BFA6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    bool isObscure = false,
    IconData? icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: const Color(0xFF00BFA6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    // Add authentication logic here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Implement the UI for the RegisterPage here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: const Center(child: Text('Welcome to Register Page!')),
    );
  }
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const AppointmentsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A1128),
              const Color(0xFF1B3A6B),
              const Color(0xFF16213E).withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Appointments',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF00BFA6),
                child: Text(
                  'JD',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildQuickActions(),
          const SizedBox(height: 32),
          _buildUpcomingAppointments(),
          const SizedBox(height: 32),
          _buildHealthMetrics(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionCard(
              icon: Icons.calendar_today_rounded,
              title: 'Book\nAppointment',
              color: const Color(0xFF00BFA6),
            ),
            _buildActionCard(
              icon: Icons.medication_rounded,
              title: 'My\nPrescriptions',
              color: const Color(0xFF7C4DFF),
            ),
            _buildActionCard(
              icon: Icons.local_hospital_rounded,
              title: 'Find\nHospital',
              color: const Color(0xFFFF4081),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Appointments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Color(0xFF00BFA6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr. Sarah Johnson',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cardiologist',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Today, 2:00 PM',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildHealthMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.favorite_rounded,
                title: 'Heart Rate',
                value: '72',
                unit: 'bpm',
                color: const Color(0xFFFF4081),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Blood Pressure',
                value: '120/80',
                unit: 'mmHg',
                color: const Color(0xFF00BFA6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Appointments',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildAppointmentTabs(),
          const SizedBox(height: 24),
          _buildAppointmentsList(),
        ],
      ),
    );
  }

  Widget _buildAppointmentTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Upcoming',
              isSelected: true,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              label: 'Past',
              isSelected: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String label, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00BFA6) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Column(
      children: [
        _buildAppointmentCard(
          doctorName: 'Dr. Sarah Johnson',
          specialty: 'Cardiologist',
          date: 'Today, 2:00 PM',
          status: 'Confirmed',
          isUpcoming: true,
        ),
        const SizedBox(height: 16),
        _buildAppointmentCard(
          doctorName: 'Dr. Michael Chen',
          specialty: 'Dermatologist',
          date: 'Tomorrow, 10:30 AM',
          status: 'Pending',
          isUpcoming: true,
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required String doctorName,
    required String specialty,
    required String date,
    required String status,
    required bool isUpcoming,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF00BFA6).withOpacity(0.2),
                    child: Text(
                      doctorName.substring(4, 5),
                      style: const TextStyle(
                        color: Color(0xFF00BFA6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        specialty,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status == 'Confirmed'
                      ? const Color(0xFF00BFA6).withOpacity(0.2)
                      : const Color(0xFFFFB74D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Confirmed'
                        ? const Color(0xFF00BFA6)
                        : const Color(0xFFFFB74D),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              if (isUpcoming)
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.message_rounded,
                      label: 'Message',
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.videocam_rounded,
                      label: 'Video Call',
                      isPrimary: true,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFF00BFA6)
            : const Color(0xFF00BFA6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isPrimary ? Colors.white : const Color(0xFF00BFA6),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.white : const Color(0xFF00BFA6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileHeader(),
          const SizedBox(height: 32),
          _buildProfileOptions(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00BFA6),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF00BFA6).withOpacity(0.2),
            child: const Text(
              'JD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00BFA6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'John Doe',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Patient ID: #12345',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildProfileOption(
          icon: Icons.person_rounded,
          title: 'Personal Information',
          subtitle: 'View and edit your personal details',
        ),
        _buildProfileOption(
          icon: Icons.medical_information_rounded,
          title: 'Medical History',
          subtitle: 'View your medical records and history',
        ),
        _buildProfileOption(
          icon: Icons.notifications_rounded,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
        ),
        _buildProfileOption(
          icon: Icons.security_rounded,
          title: 'Privacy & Security',
          subtitle: 'Manage your privacy settings',
        ),
        _buildProfileOption(
          icon: Icons.help_rounded,
          title: 'Help & Support',
          subtitle: 'Get help and view FAQs',
        ),
        _buildProfileOption(
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF00BFA6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
      ],
    );
  }
}
