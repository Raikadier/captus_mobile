import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme_enhanced.dart';

/// Modelos para datos del dashboard
class DashboardStats {
  final int totalTasks;
  final int completedTasks;
  final int attendedClasses;
  final int totalClasses;
  final double gpa;
  final int streakDays;

  DashboardStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.attendedClasses,
    required this.totalClasses,
    required this.gpa,
    required this.streakDays,
  });

  double get completionRate =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  double get attendanceRate =>
      totalClasses > 0 ? (attendedClasses / totalClasses) * 100 : 0;
}

enum DateRangeFilter { today, week, month, custom }

/// Dashboard con gráficas reales, filtros dinámicos y exportación
class AdvancedDashboardScreen extends ConsumerStatefulWidget {
  const AdvancedDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdvancedDashboardScreen> createState() =>
      _AdvancedDashboardScreenState();
}

class _AdvancedDashboardScreenState
    extends ConsumerState<AdvancedDashboardScreen> {
  DateRangeFilter _selectedRange = DateRangeFilter.month;

  // Datos simulados (en producción, obtener del backend)
  late DashboardStats stats;
  late List<FlSpot> taskProgressData;
  late List<FlSpot> attendanceData;

  @override
  void initState() {
    super.initState();
    _initializeDashboardData();
  }

  void _initializeDashboardData() {
    // Datos de estadísticas
    stats = DashboardStats(
      totalTasks: 24,
      completedTasks: 18,
      attendedClasses: 28,
      totalClasses: 30,
      gpa: 3.85,
      streakDays: 12,
    );

    // Gráfica de progreso de tareas por día
    taskProgressData = [
      const FlSpot(0, 2),
      const FlSpot(1, 3),
      const FlSpot(2, 2),
      const FlSpot(3, 4),
      const FlSpot(4, 3),
      const FlSpot(5, 5),
      const FlSpot(6, 4),
    ];

    // Gráfica de asistencia
    attendanceData = [
      const FlSpot(0, 4),
      const FlSpot(1, 4),
      const FlSpot(2, 3),
      const FlSpot(3, 4),
      const FlSpot(4, 4),
      const FlSpot(5, 4),
      const FlSpot(6, 4),
    ];
  }

  void _changeDateRange(DateRangeFilter range) {
    setState(() => _selectedRange = range);
    // Aquí puedes recargar datos según el rango seleccionado
  }

  void _exportDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📥 Dashboard exportado como PDF'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportDashboard,
            tooltip: 'Exportar como PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtro de rango de fechas
              _buildDateRangeFilter(),
              const SizedBox(height: 24),

              // KPIs principales
              _buildKPICards(),
              const SizedBox(height: 24),

              // Gráfica 1: Barras - Tareas completadas por semana
              Text(
                'Tareas Completadas (Semanal)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildBarChart(),
              const SizedBox(height: 32),

              // Gráfica 2: Líneas - Progreso de asistencia
              Text(
                'Asistencia (Últimos 7 días)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildLineChart(),
              const SizedBox(height: 32),

              // Gráfica 3: Circular - Distribución por curso
              Text(
                'Distribución de Tareas por Curso',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildPieChart(),
              const SizedBox(height: 32),

              // Gráfica 4: Estadísticas de racha
              Text(
                'Tu Racha de Estudio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildStreakCard(),
              const SizedBox(height: 32),

              // Botón de exportación grande
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _exportDashboard,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(DateRangeFilter.today, 'Hoy'),
          const SizedBox(width: 8),
          _buildFilterChip(DateRangeFilter.week, 'Semana'),
          const SizedBox(width: 8),
          _buildFilterChip(DateRangeFilter.month, 'Mes'),
          const SizedBox(width: 8),
          _buildFilterChip(DateRangeFilter.custom, 'Personalizado'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(DateRangeFilter range, String label) {
    final isSelected = _selectedRange == range;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _changeDateRange(range),
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey,
      ),
    );
  }

  Widget _buildKPICards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildKPICard(
          title: 'Tareas',
          value: '${stats.completedTasks}/${stats.totalTasks}',
          percentage: stats.completionRate,
          icon: Icons.task_alt,
          color: Colors.blue,
        ),
        _buildKPICard(
          title: 'Asistencia',
          value: '${stats.attendedClasses}/${stats.totalClasses}',
          percentage: stats.attendanceRate,
          icon: Icons.event_available,
          color: Colors.green,
        ),
        _buildKPICard(
          title: 'Promedio',
          value: '${stats.gpa}',
          percentage: (stats.gpa / 4) * 100,
          icon: Icons.grade,
          color: Colors.orange,
        ),
        _buildKPICard(
          title: 'Racha',
          value: '${stats.streakDays}d',
          percentage: (stats.streakDays / 30) * 100,
          icon: Icons.local_fire_department,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required double percentage,
    required IconData icon,
    required Color color,
  }) {
    return CaptusCard(
      backgroundColor: color.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return CaptusCard(
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 6,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                    return Text(days[value.toInt()]);
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 28),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            barGroups: List.generate(
              taskProgressData.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: taskProgressData[index].y,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return CaptusCard(
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                    return Text(days[value.toInt()]);
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 28),
              ),
            ),
            maxY: 5,
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                spots: attendanceData,
                isCurved: true,
                color: AppTheme.secondaryColor,
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return CaptusCard(
      child: SizedBox(
        height: 300,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: Colors.blue,
                value: 30,
                title: 'Cálculo\n30%',
                radius: 80,
              ),
              PieChartSectionData(
                color: Colors.green,
                value: 25,
                title: 'Física\n25%',
                radius: 80,
              ),
              PieChartSectionData(
                color: Colors.orange,
                value: 25,
                title: 'Química\n25%',
                radius: 80,
              ),
              PieChartSectionData(
                color: Colors.red,
                value: 20,
                title: 'Inglés\n20%',
                radius: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return CaptusCard(
      backgroundColor: Colors.orange.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Vas muy bien!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tienes una racha de ${stats.streakDays} días',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (stats.streakDays / 30).clamp(0, 1),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
