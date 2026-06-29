// ignore_for_file: non_constant_identifier_names

enum PowerUnit {w, kw, mw}

String formatPower(double watts, PowerUnit unit){
  switch (unit){
    case PowerUnit.w:
      return '${watts.toStringAsFixed(watts >= 100 ? 0 : 1)} W';
    case PowerUnit.kw:
      final kw = watts/1000;
      return '${kw.toStringAsFixed(kw >= 100 ? 0 : 1)} kW';
    case PowerUnit.mw:
      final mw = watts/1000000;
      return '${mw.toStringAsFixed(mw >= 100 ? 0 : 2)} MW';
  }
}
class DashboardSummary{
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

  factory DashboardSummary.fromJson(Map<String, dynamic> j){
    return DashboardSummary(
      totalDCUs: j['TotalDCUs'] as int , 
      totalMeters: j['TotalMeters'] as int, 
      activeMeters: j['ActiveMeters'] as int, 
      offlineMeters: j['OfflineMeters'] as int, 
      mainImportActivePowerW: (j['MainImportActivePowerW'] as num).toDouble(), 
      mainExportActivePowerW: (j['MainExportActivePowerW'] as num).toDouble(), 
      mainLagReactivePowerVAR: (j['MainLagReactivePowerVAR'] as num).toDouble(), 
      mainLeadReactivePowerVAR: (j['MainLeadReactivePowerVAR'] as num).toDouble(), 
      checkImportActivePowerW: (j['CheckImportActivePowerW'] as num).toDouble(), 
      checkExportActivePowerW: (j['CheckExportActivePowerW'] as num).toDouble(), 
      checkLagReactivePowerVAR: (j['CheckLagReactivePowerVAR'] as num).toDouble(), 
      checkLeadReactivePowerVAR: (j['CheckLeadReactivePowerVAR'] as num).toDouble(), 
      mainImportActivePowerW_MF: (j['MainImportActivePowerW_MF'] as num).toDouble(), 
      mainExportActivePowerW_MF: (j['MainExportActivePowerW_MF'] as num).toDouble(), 
      mainLagReactivePowerVAR_MF: (j['MainLagReactivePowerVAR_MF'] as num).toDouble(), 
      mainLeadReactivePowerVAR_MF: (j['MainLeadReactivePowerVAR_MF'] as num).toDouble(), 
      checkImportActivePowerW_MF: (j['CheckImportActivePowerW_MF'] as num).toDouble(), 
      checkExportActivePowerW_MF: (j['CheckExportActivePowerW_MF'] as num).toDouble(), 
      checkLagReactivePowerVAR_MF: (j['CheckLagReactivePowerVAR_MF'] as num).toDouble(), 
      checkLeadReactivePowerVAR_MF: (j['CheckLeadReactivePowerVAR_MF'] as num).toDouble(),
    );
  }

  double totalImportW({bool applyMF = false}) => applyMF ? mainImportActivePowerW_MF : mainImportActivePowerW;

  int get healthPercent => totalMeters == 0 ? 0 : ((activeMeters/totalMeters) * 100).round();
}

enum MeterRole{main, check, unknown}

class MeterReading{
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
  final bool applyRootFcator;
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
    required this.applyRootFcator,
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
    required this.powerVAR
  });

  factory MeterReading.fromJson(Map<String, dynamic> j){
    return MeterReading(
      meterCode: j['MeterCode'] as String, 
      feederName: j['FeederName'] as String, 
      meterRole: _parseRole(j['MeterRole'] as String), 
      ctPrimary: j['CTPrimary'] as int, 
      ctSecondary: j['CTSecondary'] as int, 
      multiplicationFactorCT: j['MultiplicationFactorCT'] as int, 
      ptPrimary: j['PTPrimary'] as int, 
      ptSecondary: j['PTSecondary'] as int, 
      multiplicationFactorPT: j['MultiplicationFactorPT'] as int, 
      multiplicationFactor: j['MultiplicationFactor'] as int, 
      rootFactor: (j['RootFactor'] as num).toDouble(), 
      applyRootFcator: (j['ApplyRootFcator'] as int) == 1, 
      systemRTC: DateTime.parse(j['SystemRTC']as String), 
      meterRTC: DateTime.parse(j['MeterRTC'] as String), 
      isActive: (j['IsActive'] as int) == 1, 
      currentR: (j['CurrentR'] as num).toDouble(), 
      currentY: (j['CurrentY'] as num).toDouble(), 
      currentB: (j['CurrentB'] as num).toDouble(), 
      voltageR: (j['VoltageR'] as num).toDouble(), 
      voltageY: (j['VoltageY'] as num).toDouble(), 
      voltageB: (j['VoltageB'] as num).toDouble(), 
      powerW: (j['PowerW'] as num).toDouble(), 
      powerVAR: (j['PowerVAR'] as num).toDouble(),
    );
  }

  static MeterRole _parseRole(String s){
    switch (s.toLowerCase()){
      case 'main' : return MeterRole.main;
      case 'check' : return MeterRole.check;
      default : return MeterRole.unknown;
    }
  }

  double get _scale => multiplicationFactor * (applyRootFcator ? rootFactor : 1.0);
  double get primaryPowerW => powerW * _scale;
  double get primaryPowerVAR => powerVAR * _scale;
  double get primaryCurrentR => currentR * multiplicationFactorCT;
  double get primaryCurrentY => currentY * multiplicationFactorCT;
  double get primaryCurrentB => currentB * multiplicationFactorCT;
  double get  primaryVoltageRkV => (voltageR * multiplicationFactorPT)/ 1000;
  double get avgPrimaryVoltagekV => ((voltageR + voltageY + voltageB)/3 * multiplicationFactorPT)/1000;
  bool get isExporting => powerW < 0;
}

class DcuData{
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

  factory DcuData.fromJson(Map<String, dynamic> j){
    final meterList = (j['Meters'] as List<dynamic>).map((m)=>MeterReading.fromJson(m as Map<String, dynamic>)).toList();

    return DcuData(
      dcuId: j['DCUId'] as String, 
      dcuName: j['DCUName'] as String, 
      lastCommunication: DateTime.parse(j['DCULastCommunication'] as String), 
      isOnline: (j['Status'] as String).toLowerCase() == 'online', 
      meters: meterList,
    );
  }

  int get totalMeters => meters.length;
  int get activeMeters => meters.where((m) => m.isActive).length;
  int get offlineMeters => meters.where((m) => !m.isActive).length;

  double get totalMainImportW => meters.where((m) => m.meterRole == MeterRole.main && m.isActive && !m.isExporting).fold(0, (sum, m) => sum + m.primaryPowerW);

  String get lastSeenLabel{
    final diff = DateTime.now().difference(lastCommunication);
    if (diff.inMinutes<2) return 'Just Now';
    if(diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if(diff.inHours > 1 && diff.inHours <2) return '${diff.inHours} hr ago';
    if(diff.inHours < 24 && diff.inHours >= 2) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }
}

class DashboardResponse{
  final DashboardSummary summary;
  final List<DcuData> dcus;

  const DashboardResponse({
    required this.summary,
    required this.dcus,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json){
    return DashboardResponse(
      summary: DashboardSummary.fromJson(json['summary'] as Map<String, dynamic>), 
      dcus: (json['dcus'] as List<dynamic>).map((d) => DcuData.fromJson(d as Map<String, dynamic>)).toList(),
    );
  }
}

