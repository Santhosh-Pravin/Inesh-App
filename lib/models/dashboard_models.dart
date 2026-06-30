int    _i(dynamic v, {int fallback = 0})       => (v as num?)?.toInt()    ?? fallback;
double _d(dynamic v, {double fallback = 0.0})  => (v as num?)?.toDouble() ?? fallback;

enum PowerUnit { w, kw, mw }

String formatPower(double watts, PowerUnit unit) {
  switch (unit) {
    case PowerUnit.w:
      return '${watts.toStringAsFixed(watts >= 100 ? 0 : 1)} W';
    case PowerUnit.kw:
      final kw = watts / 1000;
      return '${kw.toStringAsFixed(kw >= 100 ? 0 : 1)} kW';
    case PowerUnit.mw:
      final mw = watts / 1000000;
      return '${mw.toStringAsFixed(mw >= 100 ? 0 : 2)} MW';
  }
}


class DashboardSummary {
  final int totalDCUs;
  final int totalMeters;
  final int activeMeters;
  final int offlineMeters;
  final double mainImportActivePowerW;
  final double mainExportActivePowerW;
  final double mainLagReactivePowerVAR;
  final double mainLeadReactivePowerVAR;
  final double checkImportActivePowerW;
  final double checkExportActivePowerW;
  final double checkLagReactivePowerVAR;
  final double checkLeadReactivePowerVAR;
  final double mainImportActivePowerW_MF;
  final double mainExportActivePowerW_MF;
  final double mainLagReactivePowerVAR_MF;
  final double mainLeadReactivePowerVAR_MF;
  final double checkImportActivePowerW_MF;
  final double checkExportActivePowerW_MF;
  final double checkLagReactivePowerVAR_MF;
  final double checkLeadReactivePowerVAR_MF;

  const DashboardSummary({
    required this.totalDCUs,
    required this.totalMeters,
    required this.activeMeters,
    required this.offlineMeters,
    required this.mainImportActivePowerW,
    required this.mainExportActivePowerW,
    required this.mainLagReactivePowerVAR,
    required this.mainLeadReactivePowerVAR,
    required this.checkImportActivePowerW,
    required this.checkExportActivePowerW,
    required this.checkLagReactivePowerVAR,
    required this.checkLeadReactivePowerVAR,
    required this.mainImportActivePowerW_MF,
    required this.mainExportActivePowerW_MF,
    required this.mainLagReactivePowerVAR_MF,
    required this.mainLeadReactivePowerVAR_MF,
    required this.checkImportActivePowerW_MF,
    required this.checkExportActivePowerW_MF,
    required this.checkLagReactivePowerVAR_MF,
    required this.checkLeadReactivePowerVAR_MF,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> j) {
    return DashboardSummary(
      totalDCUs: _i(j['TotalDCUs']),
      totalMeters: _i(j['TotalMeters']),
      activeMeters: _i(j['ActiveMeters']),
      offlineMeters: _i(j['OfflineMeters']),
      mainImportActivePowerW: _d(j['MainImportActivePowerW']),
      mainExportActivePowerW: _d(j['MainExportActivePowerW']),
      mainLagReactivePowerVAR: _d(j['MainLagReactivePowerVAR']),
      mainLeadReactivePowerVAR: _d(j['MainLeadReactivePowerVAR']),
      checkImportActivePowerW: _d(j['CheckImportActivePowerW']),
      checkExportActivePowerW: _d(j['CheckExportActivePowerW']),
      checkLagReactivePowerVAR: _d(j['CheckLagReactivePowerVAR']),
      checkLeadReactivePowerVAR: _d(j['CheckLeadReactivePowerVAR']),
      mainImportActivePowerW_MF: _d(j['MainImportActivePowerW_MF']),
      mainExportActivePowerW_MF: _d(j['MainExportActivePowerW_MF']),
      mainLagReactivePowerVAR_MF: _d(j['MainLagReactivePowerVAR_MF']),
      mainLeadReactivePowerVAR_MF: _d(j['MainLeadReactivePowerVAR_MF']),
      checkImportActivePowerW_MF: _d(j['CheckImportActivePowerW_MF']),
      checkExportActivePowerW_MF: _d(j['CheckExportActivePowerW_MF']),
      checkLagReactivePowerVAR_MF: _d(j['CheckLagReactivePowerVAR_MF']),
      checkLeadReactivePowerVAR_MF: _d(j['CheckLeadReactivePowerVAR_MF']),
    );
  }

  double totalImportW({bool applyMF = false}) =>
      applyMF ? mainImportActivePowerW_MF : mainImportActivePowerW;

  int get healthPercent =>
      totalMeters == 0 ? 0 : ((activeMeters / totalMeters) * 100).round();
}


enum MeterRole { main, check, unknown }

class MeterReading {
  final String meterCode;
  final String feederName;
  final MeterRole meterRole;
  final int ctPrimary;
  final int ctSecondary;
  final int multiplicationFactorCT;
  final int ptPrimary;
  final int ptSecondary;
  final int multiplicationFactorPT;
  final int multiplicationFactor;
  final double rootFactor;
  final bool applyRootFactor;
  final DateTime systemRTC;
  final DateTime meterRTC;
  final bool isActive;
  final double currentR;
  final double currentY;
  final double currentB;
  final double voltageR;
  final double voltageY;
  final double voltageB;
  final double powerW;
  final double powerVAR;

  const MeterReading({
    required this.meterCode,
    required this.feederName,
    required this.meterRole,
    required this.ctPrimary,
    required this.ctSecondary,
    required this.multiplicationFactorCT,
    required this.ptPrimary,
    required this.ptSecondary,
    required this.multiplicationFactorPT,
    required this.multiplicationFactor,
    required this.rootFactor,
    required this.applyRootFactor,
    required this.systemRTC,
    required this.meterRTC,
    required this.isActive,
    required this.currentR,
    required this.currentY,
    required this.currentB,
    required this.voltageR,
    required this.voltageY,
    required this.voltageB,
    required this.powerW,
    required this.powerVAR,
  });

  factory MeterReading.fromJson(Map<String, dynamic> j) {
    return MeterReading(
      meterCode: j['MeterCode'] as String,
      feederName: j['FeederName'] as String,
      meterRole: _parseRole(j['MeterRole'] as String),
      ctPrimary: _i(j['CTPrimary']),
      ctSecondary: _i(j['CTSecondary']),
      multiplicationFactorCT: _i(j['MultiplicationFactorCT']),
      ptPrimary: _i(j['PTPrimary']),
      ptSecondary: _i(j['PTSecondary']),
      multiplicationFactorPT: _i(j['MultiplicationFactorPT']),
      multiplicationFactor: _i(j['MultiplicationFactor'], fallback: 1),
      rootFactor: _d(j['RootFactor'], fallback: 1.732),
      applyRootFactor: _i(j['ApplyRootFactor']) == 1,
      systemRTC: DateTime.parse(j['SystemRTC'] as String),
      meterRTC: DateTime.parse(j['MeterRTC'] as String),
      isActive: _i(j['IsActive']) == 1,
      currentR: _d(j['CurrentR']),
      currentY: _d(j['CurrentY']),
      currentB: _d(j['CurrentB']),
      voltageR: _d(j['VoltageR']),
      voltageY: _d(j['VoltageY']),
      voltageB: _d(j['VoltageB']),
      powerW: _d(j['PowerW']),
      powerVAR: _d(j['PowerVAR']),
    );
  }

  static MeterRole _parseRole(String s) {
    switch (s.toLowerCase()) {
      case 'main':  return MeterRole.main;
      case 'check': return MeterRole.check;
      default:      return MeterRole.unknown;
    }
  }

  double get _scale => multiplicationFactor * (applyRootFactor ? rootFactor : 1.0);
  double get primaryPowerW    => powerW   * _scale;
  double get primaryPowerVAR  => powerVAR * _scale;
  double get primaryCurrentR  => currentR * multiplicationFactorCT;
  double get primaryCurrentY  => currentY * multiplicationFactorCT;
  double get primaryCurrentB  => currentB * multiplicationFactorCT;
  double get primaryVoltageRkV => (voltageR * multiplicationFactorPT) / 1000.0;
  double get avgPrimaryVoltagekV =>
      ((voltageR + voltageY + voltageB) / 3.0 * multiplicationFactorPT) / 1000.0;
  bool get isExporting => powerW < 0;
}


class DcuData {
  final String dcuId;
  final String dcuName;
  final DateTime lastCommunication;
  final bool isOnline;
  final List<MeterReading> meters;

  const DcuData({
    required this.dcuId,
    required this.dcuName,
    required this.lastCommunication,
    required this.isOnline,
    required this.meters,
  });

  factory DcuData.fromJson(Map<String, dynamic> j) {
    final meterList = (j['Meters'] as List<dynamic>)
        .map((m) => MeterReading.fromJson(m as Map<String, dynamic>))
        .toList();
    return DcuData(
      dcuId: j['DCUId'] as String,
      dcuName: j['DCUName'] as String,
      lastCommunication: DateTime.parse(j['DCULastCommunication'] as String),
      isOnline: (j['Status'] as String).toLowerCase() == 'online',
      meters: meterList,
    );
  }

  int get totalMeters   => meters.length;
  int get activeMeters  => meters.where((m) => m.isActive).length;
  int get offlineMeters => meters.where((m) => !m.isActive).length;

  double get totalMainImportW => meters
      .where((m) => m.meterRole == MeterRole.main && m.isActive && !m.isExporting)
      .fold(0.0, (sum, m) => sum + m.primaryPowerW);

  String get lastSeenLabel {
    final diff = DateTime.now().difference(lastCommunication);
    if (diff.inMinutes < 2)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)   return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }
}

class DashboardResponse {
  final DashboardSummary summary;
  final List<DcuData> dcus;

  const DashboardResponse({required this.summary, required this.dcus});

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      summary: DashboardSummary.fromJson(json['summary'] as Map<String, dynamic>),
      dcus: (json['dcus'] as List<dynamic>)
          .map((d) => DcuData.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}