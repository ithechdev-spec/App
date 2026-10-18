// ============================================================================
//  ⬧ ALHA — بوت العرض والطلب الصافي (Native Flutter Android Application)
//  Supply & Demand · Pure Price Action · Binance Spot (Paper & Real HMAC-SHA256)
//  بناء 2.1 — يدعم:
//   1) محرك العرض والطلب الصافي (بيفوت K=3 · نافذة 60 · ليمت المنتصف ج4 · RR>2.5)
//   2) فلتر حجم الكسر الصاعد (BOS Volume 1.5× متوسط آخر 20 شمعة)
//   3) التأمين التلقائي عند % من الهدف (Auto-Breakeven 50%)
//   5) الحاسبة التاريخية الشاملة (Backtest Simulator) + شارت الشموع التفاعلي + 4 ثيمات
// ============================================================================

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const AlhaQuantumApp());
}

// ═════════════════════════════════════════════════════════════════════════════
//  1. نظام الثيمات الأربعة (ALHA QUANTUM THEMES)
// ═════════════════════════════════════════════════════════════════════════════
class AlhaThemePalette {
  final String id;
  final String nameAr;
  final bool isLight;
  final Color bgVoid;
  final Color bgDeep;
  final Color bgInput;
  final Color bgPanel;
  final Color bgElev;
  final Color txMain;
  final Color txSub;
  final Color txDim;
  final Color acPri;
  final Color acSec;
  final Color acTer;
  final Color up;
  final Color dn;
  final Color warn;
  final Color bdrSubtle;
  final Color bdrGlow;
  final Color chartBg;

  const AlhaThemePalette({
    required this.id,
    required this.nameAr,
    required this.isLight,
    required this.bgVoid,
    required this.bgDeep,
    required this.bgInput,
    required this.bgPanel,
    required this.bgElev,
    required this.txMain,
    required this.txSub,
    required this.txDim,
    required this.acPri,
    required this.acSec,
    required this.acTer,
    required this.up,
    required this.dn,
    required this.warn,
    required this.bdrSubtle,
    required this.bdrGlow,
    required this.chartBg,
  });

  static const Map<String, AlhaThemePalette> palettes = {
    'quantum-cyan': AlhaThemePalette(
      id: 'quantum-cyan',
      nameAr: 'النيون السماوي',
      isLight: false,
      bgVoid: Color(0xFF050811),
      bgDeep: Color(0xFF0A1020),
      bgInput: Color(0xFF070C18),
      bgPanel: Color(0xFF0E1629),
      bgElev: Color(0xFF141E38),
      txMain: Color(0xFFF4F8FF),
      txSub: Color(0xFF9EB2D4),
      txDim: Color(0xFF687EA3),
      acPri: Color(0xFF00E5FF),
      acSec: Color(0xFFA855F7),
      acTer: Color(0xFF38BDF8),
      up: Color(0xFF10B981),
      dn: Color(0xFFF43F5E),
      warn: Color(0xFFF59E0B),
      bdrSubtle: Color(0x298EA3C8),
      bdrGlow: Color(0x5C00E5FF),
      chartBg: Color(0xFF060A15),
    ),
    'solar-gold': AlhaThemePalette(
      id: 'solar-gold',
      nameAr: 'الذهبي الدافئ',
      isLight: false,
      bgVoid: Color(0xFF090704),
      bgDeep: Color(0xFF120E08),
      bgInput: Color(0xFF0D0A05),
      bgPanel: Color(0xFF18120B),
      bgElev: Color(0xFF241B10),
      txMain: Color(0xFFFFF9ED),
      txSub: Color(0xFFD4BE98),
      txDim: Color(0xFF8F7956),
      acPri: Color(0xFFFBBF24),
      acSec: Color(0xFFF97316),
      acTer: Color(0xFFFDE047),
      up: Color(0xFF10B981),
      dn: Color(0xFFF43F5E),
      warn: Color(0xFFF59E0B),
      bdrSubtle: Color(0x29D4BE98),
      bdrGlow: Color(0x61FBBF24),
      chartBg: Color(0xFF0A0805),
    ),
    'crimson-matrix': AlhaThemePalette(
      id: 'crimson-matrix',
      nameAr: 'القرمزي الداكن',
      isLight: false,
      bgVoid: Color(0xFF090408),
      bgDeep: Color(0xFF130811),
      bgInput: Color(0xFF0E050C),
      bgPanel: Color(0xFF1A0B16),
      bgElev: Color(0xFF2A1022),
      txMain: Color(0xFFFFF0F8),
      txSub: Color(0xFFD49BC0),
      txDim: Color(0xFF8F587C),
      acPri: Color(0xFFFF2A85),
      acSec: Color(0xFF00E5FF),
      acTer: Color(0xFFC084FC),
      up: Color(0xFF10B981),
      dn: Color(0xFFF43F5E),
      warn: Color(0xFFF59E0B),
      bdrSubtle: Color(0x29D49BC0),
      bdrGlow: Color(0x61FF2A85),
      chartBg: Color(0xFF0C050A),
    ),
    'crystal-day': AlhaThemePalette(
      id: 'crystal-day',
      nameAr: 'النهاري الفاتح',
      isLight: true,
      bgVoid: Color(0xFFEEF3F9),
      bgDeep: Color(0xFFE1E8F2),
      bgInput: Color(0xFFFFFFFF),
      bgPanel: Color(0xFFFFFFFF),
      bgElev: Color(0xFFF1F5FB),
      txMain: Color(0xFF090E1A),
      txSub: Color(0xFF28354A),
      txDim: Color(0xFF52637A),
      acPri: Color(0xFF0284C7),
      acSec: Color(0xFF6D28D9),
      acTer: Color(0xFF0369A1),
      up: Color(0xFF047857),
      dn: Color(0xFFBE123C),
      warn: Color(0xFFB45309),
      bdrSubtle: Color(0x220F172A),
      bdrGlow: Color(0x6B0284C7),
      chartBg: Color(0xFFFFFFFF),
    ),
  };
}

// ═════════════════════════════════════════════════════════════════════════════
//  2. نماذج البيانات (MODELS)
// ═════════════════════════════════════════════════════════════════════════════
class KlineBar {
  final int openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final int closeTime;
  double volRatio;
  bool isBos;
  bool bosOk;

  KlineBar({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
    this.volRatio = 0.0,
    this.isBos = false,
    this.bosOk = false,
  });
}

class PendingZone {
  final String symbol;
  final String interval;
  final String side;
  final double zb;
  final double zt;
  final double mid;
  final double sl;
  final double tp;
  final int cr;
  final int crT;
  double closePx;
  final double rrEst;

  PendingZone({
    required this.symbol,
    required this.interval,
    required this.side,
    required this.zb,
    required this.zt,
    required this.mid,
    required this.sl,
    required this.tp,
    required this.cr,
    required this.crT,
    required this.closePx,
    required this.rrEst,
  });

  double get distPct => (closePx > 0 && mid > 0) ? ((closePx - mid) / mid) * 100.0 : 999.0;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'interval': interval,
        'side': side,
        'zb': zb,
        'zt': zt,
        'mid': mid,
        'sl': sl,
        'tp': tp,
        'cr': cr,
        'cr_t': crT,
        'close_px': closePx,
        'rr_est': rrEst,
      };

  factory PendingZone.fromJson(Map<String, dynamic> j, String fallbackIv) {
    final zb = (j['zb'] as num?)?.toDouble() ?? 0.0;
    final zt = (j['zt'] as num?)?.toDouble() ?? 0.0;
    return PendingZone(
      symbol: (j['symbol'] ?? '').toString(),
      interval: (j['interval'] ?? fallbackIv).toString(),
      side: (j['side'] ?? 'L').toString(),
      zb: zb,
      zt: zt,
      mid: (j['mid'] as num?)?.toDouble() ?? (0.5 * (zb + zt)),
      sl: (j['sl'] as num?)?.toDouble() ?? (zb * 0.999),
      tp: (j['tp'] as num?)?.toDouble() ?? 0.0,
      cr: (j['cr'] as num?)?.toInt() ?? 0,
      crT: (j['cr_t'] as num?)?.toInt() ?? 0,
      closePx: (j['close_px'] as num?)?.toDouble() ?? 0.0,
      rrEst: (j['rr_est'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TradeRecord {
  final String id;
  final double ts;
  final String timeStr;
  final String symbol;
  final String interval;
  final String side;
  double entryPrice;
  String entrySrc;
  final double eventClose;
  final int entryCandle;
  final int zoneCrT;
  final double zoneB;
  final double zoneT;
  double sl;
  double tp;
  double rr;
  final double qtyUsd;
  String status;
  bool be;
  bool modified;
  double? peakPct;
  double? tsClose;
  String? timeClose;
  double? exitPrice;
  String? exitReason;
  double? pct;
  double? pnlUsd;
  double? daysHeld;
  Map<String, dynamic>? realInfo;
  String? realCloseErr;

  TradeRecord({
    required this.id,
    required this.ts,
    required this.timeStr,
    required this.symbol,
    required this.interval,
    this.side = 'L',
    required this.entryPrice,
    this.entrySrc = 'live',
    required this.eventClose,
    required this.entryCandle,
    required this.zoneCrT,
    required this.zoneB,
    required this.zoneT,
    required this.sl,
    required this.tp,
    required this.rr,
    required this.qtyUsd,
    this.status = 'open',
    this.be = false,
    this.modified = false,
    this.peakPct,
    this.tsClose,
    this.timeClose,
    this.exitPrice,
    this.exitReason,
    this.pct,
    this.pnlUsd,
    this.daysHeld,
    this.realInfo,
    this.realCloseErr,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ts': ts,
        'time_str': timeStr,
        'symbol': symbol,
        'interval': interval,
        'side': side,
        'entry_price': entryPrice,
        'entry_src': entrySrc,
        'event_close': eventClose,
        'entry_candle': entryCandle,
        'zone_cr_t': zoneCrT,
        'zone_b': zoneB,
        'zone_t': zoneT,
        'sl': sl,
        'tp': tp,
        'rr': rr,
        'qty_usd': qtyUsd,
        'status': status,
        'be': be,
        'modified': modified,
        'peak_pct': peakPct,
        'ts_close': tsClose,
        'time_close': timeClose,
        'exit_price': exitPrice,
        'exit_reason': exitReason,
        'pct': pct,
        'pnl_usd': pnlUsd,
        'days_held': daysHeld,
        'real': realInfo,
        'real_close_err': realCloseErr,
      };

  factory TradeRecord.fromJson(Map<String, dynamic> j) => TradeRecord(
        id: (j['id'] ?? '').toString(),
        ts: (j['ts'] as num?)?.toDouble() ?? 0.0,
        timeStr: (j['time_str'] ?? '').toString(),
        symbol: (j['symbol'] ?? '').toString(),
        interval: (j['interval'] ?? '4h').toString(),
        side: (j['side'] ?? 'L').toString(),
        entryPrice: (j['entry_price'] as num?)?.toDouble() ?? 0.0,
        entrySrc: (j['entry_src'] ?? 'live').toString(),
        eventClose: (j['event_close'] as num?)?.toDouble() ?? 0.0,
        entryCandle: (j['entry_candle'] as num?)?.toInt() ?? 0,
        zoneCrT: (j['zone_cr_t'] as num?)?.toInt() ?? 0,
        zoneB: (j['zone_b'] as num?)?.toDouble() ?? 0.0,
        zoneT: (j['zone_t'] as num?)?.toDouble() ?? 0.0,
        sl: (j['sl'] as num?)?.toDouble() ?? 0.0,
        tp: (j['tp'] as num?)?.toDouble() ?? 0.0,
        rr: (j['rr'] as num?)?.toDouble() ?? 0.0,
        qtyUsd: (j['qty_usd'] as num?)?.toDouble() ?? 2500.0,
        status: (j['status'] ?? 'open').toString(),
        be: j['be'] == true,
        modified: j['modified'] == true,
        peakPct: (j['peak_pct'] as num?)?.toDouble(),
        tsClose: (j['ts_close'] as num?)?.toDouble(),
        timeClose: j['time_close']?.toString(),
        exitPrice: (j['exit_price'] as num?)?.toDouble(),
        exitReason: j['exit_reason']?.toString(),
        pct: (j['pct'] as num?)?.toDouble(),
        pnlUsd: (j['pnl_usd'] as num?)?.toDouble(),
        daysHeld: (j['days_held'] as num?)?.toDouble(),
        realInfo: j['real'] is Map ? Map<String, dynamic>.from(j['real']) : null,
        realCloseErr: j['real_close_err']?.toString(),
      );
}

class LiveEvent {
  final int id;
  final String timeStr;
  final String symbol;
  final String type;
  final String msg;
  final String sev;

  LiveEvent({
    required this.id,
    required this.timeStr,
    required this.symbol,
    required this.type,
    required this.msg,
    required this.sev,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'time_str': timeStr,
        'symbol': symbol,
        'type': type,
        'msg': msg,
        'sev': sev,
      };

  factory LiveEvent.fromJson(Map<String, dynamic> j) => LiveEvent(
        id: (j['id'] as num?)?.toInt() ?? 0,
        timeStr: (j['time_str'] ?? '').toString(),
        symbol: (j['symbol'] ?? '').toString(),
        type: (j['type'] ?? 'info').toString(),
        msg: (j['msg'] ?? '').toString(),
        sev: (j['sev'] ?? 'info').toString(),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
//  3. محرك العرض والطلب الصافي (PURE PRICE ACTION S&D ENGINE — 100% EXACT)
// ═════════════════════════════════════════════════════════════════════════════
class SdEngineResult {
  final List<Map<String, dynamic>> trades;
  final List<Map<String, dynamic>> tradesExt;
  final int trend;
  final Map<String, dynamic>? pend;
  final Map<String, dynamic>? pos;

  SdEngineResult({
    required this.trades,
    required this.tradesExt,
    required this.trend,
    this.pend,
    this.pos,
  });
}

class SdEngine {
  static const int kPivot = 3;
  static const double minRr = 2.5;
  static const int lookback = 60;
  static const int fetchBars = 490;
  static const int minBars = 330;
  static const double feeRtDef = 0.20;
  static const double slipIn = 0.0005;
  static const double slipTp = 0.0005;
  static const double slipSl = 0.001;
  static const double zoneBufLo = 0.999;
  static const double zoneBufHi = 1.001;
  static const int volWin = 20;

  static double fillPct(String side, double ef, double xf, [double feeRt = feeRtDef]) {
    if (side == 'L') {
      return (xf / ef - 1.0) * 100.0 - feeRt;
    }
    return (1.0 - xf / ef) * 100.0 - feeRt;
  }

  /// تشغيل آلة الحالة الحرفية لفحص 97/98/100/101/104/106 (مطابق 100% لبناء 2.0)
  static SdEngineResult? runSym(
    List<KlineBar> bars, {
    String interval = '4h',
    double volmult = 1.5,
    double autoBePct = 50.0,
    bool slGuard = true,
    double feeRt = feeRtDef,
    bool liveLimitMode = false,
  }) {
    final int n = bars.length;
    if (n < 300) return null;

    const int K = kPivot;
    const int W = 2 * K + 1;

    final List<bool> isPh = List<bool>.filled(n, false);
    final List<bool> isPl = List<bool>.filled(n, false);

    for (int c = K; c < n - K; c++) {
      double mxH = -1e18;
      double mnL = 1e18;
      for (int w = c - K; w <= c + K; w++) {
        if (bars[w].high > mxH) mxH = bars[w].high;
        if (bars[w].low < mnL) mnL = bars[w].low;
      }
      if (bars[c].high >= mxH) isPh[c] = true;
      if (bars[c].low <= mnL) isPl[c] = true;
    }

    final List<double> smav = List<double>.filled(n, double.nan);
    if (volmult > 0) {
      double runSum = 0.0;
      for (int idx = 0; idx < n; idx++) {
        if (idx >= volWin) {
          smav[idx] = runSum / volWin;
          runSum -= bars[idx - volWin].volume;
        }
        runSum += bars[idx].volume;
      }
    }

    final List<Map<String, dynamic>> trades = [];
    final List<Map<String, dynamic>> tradesExt = [];

    double structHigh = double.nan;
    double structLow = double.nan;
    double validLow = double.nan;
    double validHigh = double.nan;
    int phIdx = -1;
    int plIdx = -1;
    int trend = 0;
    bool armedUp = true;
    bool armedDn = true;
    Map<String, dynamic>? pend;
    Map<String, dynamic>? pos;

    for (int j = K + 1; j < n; j++) {
      final int i = j - K;
      if (i >= K) {
        if (isPh[i]) {
          structHigh = bars[i].high;
          phIdx = i;
          armedUp = true;
        }
        if (isPl[i]) {
          structLow = bars[i].low;
          plIdx = i;
          armedDn = true;
        }
      }

      // ── انعكاس الترند ──
      if (trend >= 0 && validLow.isFinite && bars[j].close < validLow) {
        trend = -1;
        if (pend != null && pend['side'] == 'L') pend = null;
        if (structHigh.isFinite) validHigh = structHigh;
        if (validLow.isFinite) structLow = validLow;
        armedDn = true;
      } else if (trend <= 0 && validHigh.isFinite && bars[j].close > validHigh) {
        trend = 1;
        if (pend != null && pend['side'] == 'S') pend = null;
        if (structLow.isFinite) validLow = structLow;
        if (validHigh.isFinite) structHigh = validHigh;
        armedUp = true;
      }

      // ── كسر هيكل صاعد (BOS) → منطقة طلب ──
      if (trend >= 0 && armedUp && structHigh.isFinite && bars[j].close > structHigh) {
        final int a = plIdx >= 0 ? math.max(plIdx, j - lookback) : math.max(0, j - lookback);
        if (j - 1 > a) {
          int m = a;
          double minLow = bars[a].low;
          for (int k = a + 1; k < j; k++) {
            if (bars[k].low < minLow) {
              minLow = bars[k].low;
              m = k;
            }
          }
          bool okV = true;
          if (volmult > 0) {
            okV = smav[j].isFinite && bars[j].volume > volmult * smav[j];
          }
          bars[j].isBos = true;
          bars[j].bosOk = okV;
          if (smav[j].isFinite && smav[j] > 0) {
            bars[j].volRatio = bars[j].volume / smav[j];
          }
          if (okV) {
            pend = {
              'side': 'L',
              'zb': bars[m].low,
              'zt': bars[m].high,
              'tp': structHigh,
              'cr': j,
              'cr_t': bars[j].openTime,
            };
          }
          validLow = bars[m].low;
        }
        armedUp = false;
      }

      // ── كسر هيكل هابط (BOS) → منطقة عرض (لتتبع البنية بدقة) ──
      if (trend <= 0 && armedDn && structLow.isFinite && bars[j].close < structLow) {
        final int a = phIdx >= 0 ? math.max(phIdx, j - lookback) : math.max(0, j - lookback);
        if (j - 1 > a) {
          int m = a;
          double maxHigh = bars[a].high;
          for (int k = a + 1; k < j; k++) {
            if (bars[k].high > maxHigh) {
              maxHigh = bars[k].high;
              m = k;
            }
          }
          pend = {
            'side': 'S',
            'zb': bars[m].low,
            'zt': bars[m].high,
            'tp': structLow,
            'cr': j,
            'cr_t': bars[j].openTime,
          };
          validHigh = bars[m].high;
        }
        armedDn = false;
      }

      // ── إدارة الصفقة المفتوحة ──
      if (pos != null && j > (pos['eb'] as int)) {
        if (pos['side'] == 'L') {
          final double sl = pos['sl'] as double;
          final double tp = pos['tp'] as double;
          final double ef = pos['ef'] as double;
          final int eb = pos['eb'] as int;
          final bool wasBe = pos['be'] == true;

          if (bars[j].low <= sl) {
            final double xf = sl * (wasBe ? 1.0 : (1.0 - slipSl));
            final double pctV = (xf / ef - 1.0) * 100.0 - feeRt;
            trades.add({
              't_in': bars[eb].openTime,
              't_out': bars[j].openTime,
              'pct': pctV,
              'side': 'L',
              'reason': 'SL',
            });
            tradesExt.add({
              't_in': bars[eb].openTime,
              't_out': bars[j].openTime,
              'pct': pctV,
              'side': 'L',
              'reason': wasBe ? 'BE' : 'SL',
              'raw_reason': 'SL',
              'be': wasBe,
              'ef': ef,
              'xf': xf,
              'sl': pos['orig_sl'] ?? sl,
              'exit_sl': sl,
              'tp': tp,
              'rr': pos['rr'] ?? 0.0,
              'zb': pos['zb'],
              'zt': pos['zt'],
              'cr_t': pos['cr_t'],
            });
            pos = null;
          } else if (bars[j].high >= tp) {
            final double xf = tp * (1.0 - slipTp);
            final double pctV = (xf / ef - 1.0) * 100.0 - feeRt;
            trades.add({
              't_in': bars[eb].openTime,
              't_out': bars[j].openTime,
              'pct': pctV,
              'side': 'L',
              'reason': 'TP',
            });
            tradesExt.add({
              't_in': bars[eb].openTime,
              't_out': bars[j].openTime,
              'pct': pctV,
              'side': 'L',
              'reason': 'TP',
              'raw_reason': 'TP',
              'be': wasBe,
              'ef': ef,
              'xf': xf,
              'sl': pos['orig_sl'] ?? sl,
              'exit_sl': sl,
              'tp': tp,
              'rr': pos['rr'] ?? 0.0,
              'zb': pos['zb'],
              'zt': pos['zt'],
              'cr_t': pos['cr_t'],
            });
            pos = null;
          } else {
            // فحص التأمين التلقائي (Auto-BE)
            if (autoBePct > 0 && !wasBe) {
              final double beTrig = ef + (tp - ef) * (autoBePct / 100.0);
              if (bars[j].high >= beTrig) {
                final double beSl = ef * (1.0 + feeRt / 100.0 + slipIn);
                if (beSl > sl) {
                  pos['sl'] = beSl;
                  pos['be'] = true;
                }
              }
            }
          }
        } else {
          // إدارة صفقات البيع الداخلية (للحفاظ على تطابق آلة الحالة 100%)
          final double sl = pos['sl'] as double;
          final double tp = pos['tp'] as double;
          if (bars[j].high >= sl || bars[j].low <= tp) {
            pos = null;
          }
        }
      }

      // ── الدخول عند رجوع السعر لمنتصف المنطقة (ج4) + فلتر RR > 2.5 ──
      if (pos == null && pend != null && j > (pend['cr'] as int)) {
        final p = pend;
        if (p['side'] == 'L' && trend == 1) {
          final double zb = p['zb'] as double;
          final double zt = p['zt'] as double;
          final double mid = 0.5 * (zb + zt);
          if (bars[j].low <= mid && bars[j].open > zb) {
            final double ef = math.min(mid, bars[j].open) * (1.0 + slipIn);
            final double sl = zb * zoneBufLo;
            final double tp = p['tp'] as double;
            if (!liveLimitMode && slGuard && (bars[j].low <= sl || bars[j].close < zb)) {
              pend = null;
            } else {
              if (tp > ef && (ef - sl) > 0) {
                final double rr = (tp - ef) / (ef - sl);
                if (rr > minRr) {
                  if (liveLimitMode && bars[j].low <= sl) {
                    final double xf = sl * (1.0 - slipSl);
                    final double pctV = (xf / ef - 1.0) * 100.0 - feeRt;
                    trades.add({
                      't_in': bars[j].openTime,
                      't_out': bars[j].openTime,
                      'pct': pctV,
                      'side': 'L',
                      'reason': 'SL',
                    });
                    tradesExt.add({
                      't_in': bars[j].openTime,
                      't_out': bars[j].openTime,
                      'pct': pctV,
                      'side': 'L',
                      'reason': 'SL',
                      'raw_reason': 'SL',
                      'be': false,
                      'ef': ef,
                      'xf': xf,
                      'sl': sl,
                      'exit_sl': sl,
                      'tp': tp,
                      'rr': rr,
                      'zb': zb,
                      'zt': zt,
                      'cr_t': p['cr_t'],
                    });
                  } else {
                    pos = {
                      'side': 'L',
                      'eb': j,
                      'ef': ef,
                      'sl': sl,
                      'orig_sl': sl,
                      'tp': tp,
                      'rr': rr,
                      'zb': zb,
                      'zt': zt,
                      'cr': p['cr'],
                      'cr_t': p['cr_t'],
                      'be': false,
                    };
                  }
                }
              }
              pend = null;
            }
          }
        } else if (p['side'] == 'S' &&
            trend == -1 &&
            bars[j].high >= (p['zb'] as double) &&
            bars[j].open < (p['zt'] as double)) {
          final double zb = p['zb'] as double;
          final double zt = p['zt'] as double;
          final double ef = math.max(zb, bars[j].open) * (1.0 - slipIn);
          final double sl = zt * zoneBufHi;
          final double tp = p['tp'] as double;
          if (tp < ef && (sl - ef) > 0) {
            final double rr = (ef - tp) / (sl - ef);
            if (rr > minRr) {
              pos = {
                'side': 'S',
                'eb': j,
                'ef': ef,
                'sl': sl,
                'orig_sl': sl,
                'tp': tp,
                'rr': rr,
                'zb': zb,
                'zt': zt,
                'cr': p['cr'],
                'cr_t': p['cr_t'],
                'be': false,
              };
            }
          }
          pend = null;
        }
      }
    }

    if (pos != null) {
      final int j = n - 1;
      if (pos['side'] == 'L') {
        final double ef = pos['ef'] as double;
        final int eb = pos['eb'] as int;
        final double xf = bars[j].close * (1.0 - slipTp);
        final double pctV = (xf / ef - 1.0) * 100.0 - feeRt;
        trades.add({
          't_in': bars[eb].openTime,
          't_out': bars[j].openTime,
          'pct': pctV,
          'side': 'L',
          'reason': 'EOD',
        });
        tradesExt.add({
          't_in': bars[eb].openTime,
          't_out': bars[j].openTime,
          'pct': pctV,
          'side': 'L',
          'reason': 'EOD',
          'raw_reason': 'EOD',
          'be': pos['be'] == true,
          'ef': ef,
          'xf': xf,
          'sl': pos['orig_sl'] ?? pos['sl'],
          'exit_sl': pos['sl'],
          'tp': pos['tp'],
          'rr': pos['rr'] ?? 0.0,
          'zb': pos['zb'],
          'zt': pos['zt'],
          'cr_t': pos['cr_t'],
        });
      }
    }

    return SdEngineResult(
      trades: trades,
      tradesExt: tradesExt,
      trend: trend,
      pend: pend != null ? Map<String, dynamic>.from(pend) : null,
      pos: pos != null ? Map<String, dynamic>.from(pos) : null,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  4. خدمة بايننس سبوت (BINANCE SPOT API + RATE BUCKET + HMAC-SHA256)
// ═════════════════════════════════════════════════════════════════════════════
class BinanceService {
  static const String spotUrl = 'https://api.binance.com';
  static const String testnetUrl = 'https://testnet.binance.vision';

  static const Set<String> stableBases = {
    'USDC', 'FDUSD', 'TUSD', 'USDP', 'DAI', 'USDE', 'USDS', 'USD1',
    'XUSD', 'PYUSD', 'BFUSD', 'EUR', 'EURI', 'AEUR', 'GBP', 'TRY',
    'BRL', 'AUD', 'JPY', 'RUB', 'ZAR', 'MXN', 'CAD',
  };

  double _tokens = 180.0;
  DateTime _lastRefill = DateTime.now();
  DateTime _penaltyUntil = DateTime.fromMillisecondsSinceEpoch(0);
  int _timeOffsetMs = 0;

  List<String> _cachedSymbols = [];
  DateTime _symbolsCacheTime = DateTime.fromMillisecondsSinceEpoch(0);
  Map<String, double> _livePxCache = {};
  DateTime _livePxTime = DateTime.fromMillisecondsSinceEpoch(0);

  static bool isStable(String symbol) {
    String base = symbol.endsWith('USDT') ? symbol.substring(0, symbol.length - 4) : symbol;
    if (base.startsWith('1000')) base = base.substring(4);
    return stableBases.contains(base.toUpperCase());
  }

  Future<void> _throttle(int weight) async {
    while (true) {
      final now = DateTime.now();
      if (now.isBefore(_penaltyUntil)) {
        final waitMs = _penaltyUntil.difference(now).inMilliseconds.clamp(50, 2000);
        await Future.delayed(Duration(milliseconds: waitMs));
        continue;
      }
      final elapsedSec = now.difference(_lastRefill).inMilliseconds / 1000.0;
      _tokens = math.min(180.0, _tokens + elapsedSec * 40.0);
      _lastRefill = now;
      if (_tokens >= weight) {
        _tokens -= weight;
        return;
      }
      final waitSec = (weight - _tokens) / 40.0;
      await Future.delayed(Duration(milliseconds: (waitSec * 1000).clamp(20, 1000).toInt()));
    }
  }

  Future<List<String>> getSpotSymbols() async {
    if (_cachedSymbols.isNotEmpty &&
        DateTime.now().difference(_symbolsCacheTime).inMinutes < 10) {
      return List<String>.from(_cachedSymbols);
    }
    await _throttle(20);
    try {
      final res = await http
          .get(Uri.parse('$spotUrl/api/v3/exchangeInfo'))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final symbols = (data['symbols'] as List<dynamic>? ?? []);
        final out = <String>[];
        for (final s in symbols) {
          final m = s as Map<String, dynamic>;
          final sym = (m['symbol'] ?? '').toString();
          if (m['status'] == 'TRADING' &&
              m['quoteAsset'] == 'USDT' &&
              m['isSpotTradingAllowed'] != false &&
              !isStable(sym)) {
            out.add(sym);
          }
        }
        out.sort();
        _cachedSymbols = out;
        _symbolsCacheTime = DateTime.now();
        return out;
      }
    } catch (_) {}
    return _cachedSymbols;
  }

  Future<List<KlineBar>?> getClosedKlines(String symbol, String interval, {int limit = 490}) async {
    await _throttle(limit <= 1000 ? 2 : 5);
    try {
      final uri = Uri.parse('$spotUrl/api/v3/klines').replace(queryParameters: {
        'symbol': symbol,
        'interval': interval,
        'limit': limit.toString(),
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode == 429 || res.statusCode == 418) {
        _penaltyUntil = DateTime.now().add(Duration(seconds: res.statusCode == 418 ? 60 : 10));
        return null;
      }
      if (res.statusCode != 200) return null;
      final raw = jsonDecode(res.body) as List<dynamic>;
      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      final out = <KlineBar>[];
      for (final row in raw) {
        final r = row as List<dynamic>;
        final int closeT = (r[6] as num).toInt();
        if (closeT <= nowMs) {
          out.add(KlineBar(
            openTime: (r[0] as num).toInt(),
            open: double.parse(r[1].toString()),
            high: double.parse(r[2].toString()),
            low: double.parse(r[3].toString()),
            close: double.parse(r[4].toString()),
            volume: double.parse(r[5].toString()),
            closeTime: closeT,
          ));
        }
      }
      return out.length >= SdEngine.minBars ? out : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, double>> getLivePricesSnapshot([Iterable<String>? symbols]) async {
    if (_livePxCache.isEmpty ||
        DateTime.now().difference(_livePxTime).inMilliseconds > 2500) {
      try {
        final res = await http
            .get(Uri.parse('$spotUrl/api/v3/ticker/price'))
            .timeout(const Duration(seconds: 12));
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body) as List<dynamic>;
          final map = <String, double>{};
          for (final item in list) {
            final m = item as Map<String, dynamic>;
            final s = m['symbol']?.toString();
            final p = double.tryParse(m['price']?.toString() ?? '');
            if (s != null && p != null) map[s] = p;
          }
          if (map.isNotEmpty) {
            _livePxCache = map;
            _livePxTime = DateTime.now();
          }
        }
      } catch (_) {}
    }
    if (symbols == null) return _livePxCache;
    final want = symbols.map((e) => e.toUpperCase()).toSet();
    final filtered = <String, double>{};
    for (final s in want) {
      if (_livePxCache.containsKey(s)) filtered[s] = _livePxCache[s]!;
    }
    return filtered;
  }

  // ── التداول الحقيقي على بايننس سبوت (HMAC-SHA256) ──
  String _signQuery(String query, String secret) {
    final hmacSha256 = Hmac(sha256, utf8.encode(secret));
    return hmacSha256.convert(utf8.encode(query)).toString();
  }

  Future<void> _resyncServerTime(bool testnet) async {
    final base = testnet ? testnetUrl : spotUrl;
    try {
      final r = await http.get(Uri.parse('$base/api/v3/time')).timeout(const Duration(seconds: 10));
      if (r.statusCode == 200) {
        final serverTime = (jsonDecode(r.body)['serverTime'] as num).toInt();
        _timeOffsetMs = serverTime - DateTime.now().millisecondsSinceEpoch;
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> testAndFetchUsdtBalance({
    required String apiKey,
    required String apiSecret,
    required bool testnet,
  }) async {
    final base = testnet ? testnetUrl : spotUrl;
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final ts = DateTime.now().millisecondsSinceEpoch + _timeOffsetMs;
        final qs = 'recvWindow=10000&timestamp=$ts';
        final sig = _signQuery(qs, apiSecret);
        final uri = Uri.parse('$base/api/v3/account?$qs&signature=$sig');
        final r = await http.get(uri, headers: {'X-MBX-APIKEY': apiKey}).timeout(const Duration(seconds: 15));
        if (r.statusCode >= 400) {
          if (r.body.contains('-1021') && attempt == 0) {
            await _resyncServerTime(testnet);
            continue;
          }
          return {'ok': false, 'err': 'HTTP ${r.statusCode}: ${r.body}'};
        }
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        final balances = data['balances'] as List<dynamic>? ?? [];
        for (final b in balances) {
          final bm = b as Map<String, dynamic>;
          if (bm['asset'] == 'USDT') {
            final free = double.tryParse(bm['free']?.toString() ?? '0') ?? 0.0;
            return {'ok': true, 'balance': free};
          }
        }
        return {'ok': true, 'balance': 0.0};
      } catch (e) {
        return {'ok': false, 'err': e.toString()};
      }
    }
    return {'ok': false, 'err': 'فشل الاتصال بعد إعادة المحاولة'};
  }

  Future<Map<String, dynamic>> placeSpotMarketOrder({
    required String symbol,
    required String side, // BUY or SELL
    double? quoteOrderQty,
    double? quantity,
    required String apiKey,
    required String apiSecret,
    required bool testnet,
  }) async {
    final base = testnet ? testnetUrl : spotUrl;
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final ts = DateTime.now().millisecondsSinceEpoch + _timeOffsetMs;
        final params = <String, String>{
          'symbol': symbol,
          'side': side,
          'type': 'MARKET',
          'newOrderRespType': 'RESULT',
          'recvWindow': '10000',
          'timestamp': ts.toString(),
        };
        if (side == 'BUY' && quoteOrderQty != null) {
          params['quoteOrderQty'] = quoteOrderQty.toStringAsFixed(2);
        } else if (quantity != null) {
          params['quantity'] = quantity.toStringAsFixed(6);
        }
        final sortedKeys = params.keys.toList()..sort();
        final qs = sortedKeys.map((k) => '$k=${Uri.encodeQueryComponent(params[k]!)}').join('&');
        final sig = _signQuery(qs, apiSecret);
        final uri = Uri.parse('$base/api/v3/order?$qs&signature=$sig');
        final r = await http.post(uri, headers: {'X-MBX-APIKEY': apiKey}).timeout(const Duration(seconds: 20));
        if (r.statusCode >= 400) {
          if (r.body.contains('-1021') && attempt == 0) {
            await _resyncServerTime(testnet);
            continue;
          }
          return {'ok': false, 'err': 'HTTP ${r.statusCode}: ${r.body}'};
        }
        final d = jsonDecode(r.body) as Map<String, dynamic>;
        final execQty = double.tryParse(d['executedQty']?.toString() ?? '0') ?? 0.0;
        final cumQuote = double.tryParse(d['cummulativeQuoteQty']?.toString() ?? '0') ?? 0.0;
        if (execQty <= 0 || cumQuote <= 0) {
          return {'ok': false, 'err': 'الأمر لم يُنفذ بكمية صالحة'};
        }
        return {
          'ok': true,
          'qty': execQty,
          'avg': cumQuote / execQty,
          'order_id': d['orderId'],
        };
      } catch (e) {
        return {'ok': false, 'err': e.toString()};
      }
    }
    return {'ok': false, 'err': 'فشل إرسال الأمر'};
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  5. خدمة إشعارات تيليجرام (TELEGRAM BOT SERVICE)
// ═════════════════════════════════════════════════════════════════════════════
class TelegramService {
  String token = '';
  String chatId = '';
  bool enabled = false;
  Map<String, bool> cats = {
    'open': true,
    'close': true,
    'protect': true,
    'scan': true,
    'sys': true,
  };
  int sentCount = 0;
  int failedCount = 0;
  String lastErr = '';

  final Queue<String> _queue = Queue<String>();
  bool _sending = false;

  void queueMessage(String text, String category) {
    if (!enabled || token.trim().isEmpty || chatId.trim().isEmpty) return;
    if (cats[category] == false) return;
    if (_queue.length >= 100) _queue.removeFirst();
    _queue.addLast(text);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_sending) return;
    _sending = true;
    while (_queue.isNotEmpty) {
      final msg = _queue.removeFirst();
      final res = await sendDirect(msg);
      if (res['ok'] == true) {
        sentCount++;
      } else {
        failedCount++;
        lastErr = (res['err'] ?? '').toString();
      }
      await Future.delayed(const Duration(milliseconds: 850));
    }
    _sending = false;
  }

  Future<Map<String, dynamic>> sendDirect(String text) async {
    final tok = token.trim();
    final cid = chatId.trim();
    if (tok.isEmpty || cid.isEmpty) {
      return {'ok': false, 'err': 'ناقص توكن البوت أو معرف المحادثة'};
    }
    try {
      final r = await http
          .post(
            Uri.parse('https://api.telegram.org/bot$tok/sendMessage'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'chat_id': cid,
              'text': text,
              'disable_web_page_preview': true,
            }),
          )
          .timeout(const Duration(seconds: 12));
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      if (r.statusCode == 200 && data['ok'] == true) {
        return {'ok': true};
      }
      return {'ok': false, 'err': data['description']?.toString() ?? 'HTTP ${r.statusCode}'};
    } catch (e) {
      return {'ok': false, 'err': e.toString()};
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  6. المتحكم المركزي للبوت (ALHA STATE CONTROLLER)
// ═════════════════════════════════════════════════════════════════════════════
class AlhaController extends ChangeNotifier {
  final BinanceService binance = BinanceService();
  final TelegramService telegram = TelegramService();

  String themeId = 'quantum-cyan';
  AlhaThemePalette get palette =>
      AlhaThemePalette.palettes[themeId] ?? AlhaThemePalette.palettes['quantum-cyan']!;

  // إعدادات رأس المال والفلتر والتأمين التلقائي
  double tradeUsd = 2500.0;
  int maxOpen = 4;
  bool bosvolOn = true;
  double bosvolMult = 1.5;
  bool autoBeOn = true;
  double autoBePct = 50.0;
  String blacklistRaw = '';

  // التداول الحقيقي
  String tradingMode = 'paper'; // 'paper' or 'real'
  String apiKey = '';
  String apiSecret = '';
  bool testnet = false;
  double? realUsdtBalance;
  String realStatusErr = '';

  // حالة الفريمات والدفتر
  Map<String, bool> autoScan = {'4h': false, '1d': false};
  Map<String, bool> scanning = {'4h': false, '1d': false};
  Map<String, int> scanDone = {'4h': 0, '1d': 0};
  Map<String, int> scanTotal = {'4h': 0, '1d': 0};
  Map<String, DateTime?> lastScanTime = {'4h': null, '1d': null};
  Map<String, int> lastBoundaryMs = {'4h': 0, '1d': 0};

  List<TradeRecord> openTrades = [];
  List<TradeRecord> closedLog = [];
  List<List<double>> equityPts = [];
  double equityCum = 0.0;
  int skippedCount = 0;

  Map<String, List<PendingZone>> zones = {'4h': [], '1d': []};
  Map<String, int> enteredGuard = {};
  Set<String> pinnedSyms = {};
  List<LiveEvent> events = [];
  int _eventSeq = 0;

  Map<String, double> livePrices = {};
  bool isConnected = true;

  // حالة المحاكي التاريخي (Backtest Simulator)
  bool btRunning = false;
  bool btCancelReq = false;
  int btDone = 0;
  int btTotal = 1;
  String btPhase = 'جاهز';
  Map<String, dynamic>? lastBtResult;

  Timer? _monitorTimer;
  Timer? _schedTimer;
  Timer? _clockTimer;

  AlhaController() {
    _init();
  }

  double get baseEquity => tradeUsd * maxOpen;
  double get currentEquity => baseEquity + equityCum;

  Set<String> get blacklistSet {
    final out = <String>{};
    for (final part in blacklistRaw.split(RegExp(r'[\s,;،]+'))) {
      final p = part.trim().toUpperCase();
      if (p.isEmpty) continue;
      out.add(p);
      if (!p.endsWith('USDT')) out.add('${p}USDT');
    }
    return out;
  }

  Future<void> _init() async {
    await _loadStorage();
    _monitorTimer = Timer.periodic(const Duration(seconds: 5), (_) => _monitorTick());
    _schedTimer = Timer.periodic(const Duration(seconds: 20), (_) => _schedTick());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
    await _monitorTick();
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    _schedTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      themeId = prefs.getString('alha_theme') ?? 'quantum-cyan';
      tradeUsd = prefs.getDouble('trade_usd') ?? 2500.0;
      maxOpen = prefs.getInt('max_open') ?? 4;
      bosvolOn = prefs.getBool('bosvol_on') ?? true;
      bosvolMult = prefs.getDouble('bosvol_mult') ?? 1.5;
      autoBeOn = prefs.getBool('auto_be_on') ?? true;
      autoBePct = prefs.getDouble('auto_be_pct') ?? 50.0;
      blacklistRaw = prefs.getString('blacklist') ?? '';

      tradingMode = prefs.getString('real_mode') ?? 'paper';
      apiKey = prefs.getString('real_key') ?? '';
      apiSecret = prefs.getString('real_sec') ?? '';
      testnet = prefs.getBool('real_testnet') ?? false;

      telegram.token = prefs.getString('tg_token') ?? '';
      telegram.chatId = prefs.getString('tg_chat') ?? '';
      telegram.enabled = prefs.getBool('tg_on') ?? false;

      final pins = prefs.getStringList('pinned_syms') ?? [];
      pinnedSyms = pins.toSet();

      final rawState = prefs.getString('alha_sd_state');
      if (rawState != null && rawState.isNotEmpty) {
        final d = jsonDecode(rawState) as Map<String, dynamic>;
        autoScan['4h'] = d['auto']?['4h'] == true;
        autoScan['1d'] = d['auto']?['1d'] == true;
        equityCum = (d['equity_cum'] as num?)?.toDouble() ?? 0.0;
        skippedCount = (d['skipped'] as num?)?.toInt() ?? 0;

        openTrades = ((d['trades'] as List<dynamic>?) ?? [])
            .map((x) => TradeRecord.fromJson(Map<String, dynamic>.from(x)))
            .where((t) => t.status == 'open')
            .toList();
        closedLog = ((d['closed_log'] as List<dynamic>?) ?? [])
            .map((x) => TradeRecord.fromJson(Map<String, dynamic>.from(x)))
            .toList();
        equityPts = ((d['equity'] as List<dynamic>?) ?? [])
            .map((pt) => [(pt[0] as num).toDouble(), (pt[1] as num).toDouble()])
            .toList();

        final zMap = d['zones'] as Map<String, dynamic>? ?? {};
        zones['4h'] = ((zMap['4h'] as List<dynamic>?) ?? [])
            .map((z) => PendingZone.fromJson(Map<String, dynamic>.from(z), '4h'))
            .toList();
        zones['1d'] = ((zMap['1d'] as List<dynamic>?) ?? [])
            .map((z) => PendingZone.fromJson(Map<String, dynamic>.from(z), '1d'))
            .toList();

        final ent = d['entered'] as Map<String, dynamic>? ?? {};
        enteredGuard = ent.map((k, v) => MapEntry(k, (v as num).toInt()));
      }

      final rawEvs = prefs.getString('alha_events');
      if (rawEvs != null && rawEvs.isNotEmpty) {
        final list = jsonDecode(rawEvs) as List<dynamic>;
        events = list.map((e) => LiveEvent.fromJson(Map<String, dynamic>.from(e))).toList();
        if (events.isNotEmpty) {
          _eventSeq = events.map((e) => e.id).reduce(math.max);
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> saveStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alha_theme', themeId);
      await prefs.setDouble('trade_usd', tradeUsd);
      await prefs.setInt('max_open', maxOpen);
      await prefs.setBool('bosvol_on', bosvolOn);
      await prefs.setDouble('bosvol_mult', bosvolMult);
      await prefs.setBool('auto_be_on', autoBeOn);
      await prefs.setDouble('auto_be_pct', autoBePct);
      await prefs.setString('blacklist', blacklistRaw);

      await prefs.setString('real_mode', tradingMode);
      await prefs.setString('real_key', apiKey);
      await prefs.setString('real_sec', apiSecret);
      await prefs.setBool('real_testnet', testnet);

      await prefs.setString('tg_token', telegram.token);
      await prefs.setString('tg_chat', telegram.chatId);
      await prefs.setBool('tg_on', telegram.enabled);
      await prefs.setStringList('pinned_syms', pinnedSyms.toList());

      final stateObj = {
        'auto': autoScan,
        'trades': openTrades.map((t) => t.toJson()).toList(),
        'closed_log': closedLog.reversed.take(500).toList().reversed.map((t) => t.toJson()).toList(),
        'equity': equityPts,
        'equity_cum': equityCum,
        'zones': {
          '4h': (zones['4h'] ?? []).map((z) => z.toJson()).toList(),
          '1d': (zones['1d'] ?? []).map((z) => z.toJson()).toList(),
        },
        'entered': enteredGuard,
        'skipped': skippedCount,
      };
      await prefs.setString('alha_sd_state', jsonEncode(stateObj));
      await prefs.setString(
        'alha_events',
        jsonEncode(events.take(200).map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  void cycleTheme() {
    const keys = ['quantum-cyan', 'solar-gold', 'crimson-matrix', 'crystal-day'];
    final idx = keys.indexOf(themeId);
    themeId = keys[(idx + 1) % keys.length];
    saveStorage();
    notifyListeners();
  }

  void togglePin(String sym) {
    if (pinnedSyms.contains(sym)) {
      pinnedSyms.remove(sym);
    } else {
      pinnedSyms.add(sym);
    }
    saveStorage();
    notifyListeners();
  }

  void logEvent(String symbol, String type, String msg, [String sev = 'info']) {
    final now = DateTime.now();
    final tStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _eventSeq++;
    events.insert(
      0,
      LiveEvent(
        id: _eventSeq,
        timeStr: tStr,
        symbol: symbol,
        type: type,
        msg: msg,
        sev: sev,
      ),
    );
    if (events.length > 250) events.removeRange(250, events.length);
  }

  static int nextCloseMs(String iv) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final step = iv == '1d' ? 86400000 : 14400000;
    return ((nowMs ~/ step) + 1) * step;
  }

  static int lastCloseMs(String iv) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final step = iv == '1d' ? 86400000 : 14400000;
    return (nowMs ~/ step) * step;
  }

  // ── المجدول التلقائي (بعد 90 ثانية من إغلاق كل شمعة 4h / 1d) ──
  Future<void> _schedTick() async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    for (final iv in ['4h', '1d']) {
      if (autoScan[iv] != true) continue;
      final lc = lastCloseMs(iv);
      final target = lc + 90 * 1000;
      if (nowMs >= target &&
          (nowMs - target) <= 900000 &&
          lastBoundaryMs[iv] != lc &&
          scanning[iv] != true) {
        lastBoundaryMs[iv] = lc;
        runScan(iv, source: 'auto');
      }
    }
  }

  // ── المراقبة الحية كل 5 ثوانٍ (الستوب/الهدف/التأمين التلقائي/الليمت اللحظي) ──
  Future<void> _monitorTick() async {
    final allSyms = <String>{
      ...openTrades.map((t) => t.symbol),
      ...(zones['4h'] ?? []).map((z) => z.symbol),
      ...(zones['1d'] ?? []).map((z) => z.symbol),
    };
    if (allSyms.isEmpty) return;

    final snap = await binance.getLivePricesSnapshot(allSyms);
    if (snap.isEmpty) {
      isConnected = false;
      notifyListeners();
      return;
    }
    isConnected = true;
    livePrices.addAll(snap);

    final nowSec = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final toClose = <Map<String, dynamic>>[];
    bool dirty = false;

    for (final t in List<TradeRecord>.from(openTrades)) {
      final px = snap[t.symbol] ?? 0.0;
      if (px <= 0) continue;

      final curPct = SdEngine.fillPct('L', t.entryPrice, px * (1.0 - SdEngine.slipTp));
      if (t.peakPct == null || curPct > t.peakPct!) {
        t.peakPct = curPct;
      }

      if (px <= t.sl) {
        final xf = t.sl * (t.be ? 1.0 : (1.0 - SdEngine.slipSl));
        toClose.add({'trade': t, 'xf': xf, 'reason': t.be ? 'BE' : 'SL'});
      } else if (px >= t.tp) {
        final xf = t.tp * (1.0 - SdEngine.slipTp);
        toClose.add({'trade': t, 'xf': xf, 'reason': 'TP'});
      } else {
        // فحص التأمين التلقائي (Auto-BE)
        if (autoBeOn && !t.be && t.entryPrice > 0 && t.tp > t.entryPrice && px > t.entryPrice) {
          final progPct = 100.0 * (px - t.entryPrice) / (t.tp - t.entryPrice);
          if (progPct >= autoBePct) {
            final beSl = t.entryPrice * (1.0 + SdEngine.feeRtDef / 100.0 + SdEngine.slipIn);
            if (px > beSl && beSl > t.sl) {
              t.sl = beSl;
              t.be = true;
              dirty = true;
              final msg =
                  '🛡 تأمين تلقائي ${t.symbol} (${t.interval == '4h' ? '4 ساعات' : 'يومي'}) عند ${progPct.toStringAsFixed(1)}% من الهدف';
              logEvent(t.symbol, 'protect', msg, 'open');
              telegram.queueMessage(msg, 'protect');
            }
          }
        }
      }
    }

    // تحديث أسعار المناطق المعلقة وتنفيذ الليمت اللحظي عند تفعيل التلقائي
    final bl = blacklistSet;
    for (final iv in ['1d', '4h']) {
      final list = zones[iv] ?? [];
      final kept = <PendingZone>[];
      final curBarT = lastCloseMs(iv);
      for (final z in list) {
        if (bl.contains(z.symbol)) {
          dirty = true;
          continue;
        }
        final px = snap[z.symbol] ?? 0.0;
        if (px > 0) z.closePx = px;
        if (px > 0 && px <= z.sl) {
          enteredGuard['${z.symbol}|$iv|z|${z.crT}'] = nowSec.toInt();
          dirty = true;
          continue;
        }
        if (px > 0 && px <= z.mid && autoScan[iv] == true) {
          dirty = true;
          final zKey = '${z.symbol}|$iv|z|${z.crT}';
          final bKey = '${z.symbol}|$iv|$curBarT';
          if (enteredGuard.containsKey(zKey) || enteredGuard.containsKey(bKey)) {
            continue;
          }
          enteredGuard[zKey] = nowSec.toInt();
          enteredGuard[bKey] = nowSec.toInt();
          final ef = math.min(z.mid, px) * (1.0 + SdEngine.slipIn);
          if (z.tp > ef && (ef - z.sl) > 0) {
            final rr = (z.tp - ef) / (ef - z.sl);
            if (rr > SdEngine.minRr) {
              if (!openTrades.any((o) => o.symbol == z.symbol) && openTrades.length < maxOpen) {
                await _openNewTrade(
                  symbol: z.symbol,
                  interval: iv,
                  ef: ef,
                  sl: z.sl,
                  tp: z.tp,
                  rr: rr,
                  zb: z.zb,
                  zt: z.zt,
                  crT: z.crT,
                  px: px,
                  src: 'live_limit',
                );
              } else {
                skippedCount++;
              }
            }
          }
          continue;
        }
        kept.add(z);
      }
      zones[iv] = kept;
    }

    for (final item in toClose) {
      await _executeCloseTrade(
        item['trade'] as TradeRecord,
        item['xf'] as double,
        item['reason'] as String,
      );
      dirty = true;
    }

    if (dirty) await saveStorage();
    notifyListeners();
  }

  Future<bool> _openNewTrade({
    required String symbol,
    required String interval,
    required double ef,
    required double sl,
    required double tp,
    required double rr,
    required double zb,
    required double zt,
    required int crT,
    required double px,
    required String src,
  }) async {
    final lockedUsd = openTrades.fold<double>(0.0, (s, x) => s + x.qtyUsd);
    final freeUsd = currentEquity - lockedUsd;
    final actUsd = math.min(tradeUsd, freeUsd);
    if (actUsd < math.max(10.0, tradeUsd * 0.20)) {
      skippedCount++;
      return false;
    }

    Map<String, dynamic>? realData;
    double finalEf = ef;
    String finalSrc = src;

    if (tradingMode == 'real' && apiKey.isNotEmpty && apiSecret.isNotEmpty) {
      final rb = await binance.placeSpotMarketOrder(
        symbol: symbol,
        side: 'BUY',
        quoteOrderQty: actUsd,
        apiKey: apiKey,
        apiSecret: apiSecret,
        testnet: testnet,
      );
      if (rb['ok'] != true) {
        logEvent(symbol, 'warn', 'فشل الشراء الحقيقي: ${rb['err']}', 'warn');
        return false;
      }
      realData = rb;
      if ((rb['avg'] as num?) != null && (rb['avg'] as num) > 0) {
        finalEf = (rb['avg'] as num).toDouble();
        finalSrc = 'real';
      }
    }

    final nowSec = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final nowDt = DateTime.now();
    final timeStr =
        '${nowDt.year}-${nowDt.month.toString().padLeft(2, '0')}-${nowDt.day.toString().padLeft(2, '0')} ${nowDt.hour.toString().padLeft(2, '0')}:${nowDt.minute.toString().padLeft(2, '0')}';

    final rec = TradeRecord(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(16).substring(4),
      ts: nowSec,
      timeStr: timeStr,
      symbol: symbol,
      interval: interval,
      entryPrice: finalEf,
      entrySrc: finalSrc,
      eventClose: px,
      entryCandle: lastCloseMs(interval),
      zoneCrT: crT,
      zoneB: zb,
      zoneT: zt,
      sl: sl,
      tp: tp,
      rr: double.parse(rr.toStringAsFixed(2)),
      qtyUsd: double.parse(actUsd.toStringAsFixed(2)),
      realInfo: realData,
    );

    openTrades.add(rec);
    livePrices[symbol] = px;

    final tfAr = interval == '4h' ? '4 ساعات' : 'يومي';
    final msg =
        '🎯 دخول $symbol ($tfAr) · شراء · ${finalEf.toStringAsPrecision(5)} · ستوب ${sl.toStringAsPrecision(5)} · هدف ${tp.toStringAsPrecision(5)} · RR ${rec.rr}';
    logEvent(symbol, 'signal', msg, 'open');
    telegram.queueMessage(msg, 'open');
    await saveStorage();
    notifyListeners();
    return true;
  }

  Future<bool> _executeCloseTrade(TradeRecord t, double xfEst, String reason) async {
    double xfFinal = xfEst;
    if (t.realInfo != null && tradingMode == 'real' && apiKey.isNotEmpty && apiSecret.isNotEmpty) {
      final qty = (t.realInfo!['qty'] as num?)?.toDouble() ?? 0.0;
      if (qty > 0) {
        final rs = await binance.placeSpotMarketOrder(
          symbol: t.symbol,
          side: 'SELL',
          quantity: qty,
          apiKey: apiKey,
          apiSecret: apiSecret,
          testnet: testnet,
        );
        if (rs['ok'] != true) {
          t.realCloseErr = rs['err']?.toString() ?? 'فشل البيع على بايننس';
          logEvent(t.symbol, 'warn', 'فشل بيع حقيقي: ${t.realCloseErr}', 'warn');
          notifyListeners();
          return false;
        }
        if ((rs['avg'] as num?) != null && (rs['avg'] as num) > 0) {
          xfFinal = (rs['avg'] as num).toDouble();
        }
      }
    }

    final nowSec = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final nowDt = DateTime.now();
    final timeStr =
        '${nowDt.year}-${nowDt.month.toString().padLeft(2, '0')}-${nowDt.day.toString().padLeft(2, '0')} ${nowDt.hour.toString().padLeft(2, '0')}:${nowDt.minute.toString().padLeft(2, '0')}';

    final pct = SdEngine.fillPct('L', t.entryPrice, xfFinal);
    final pnl = t.qtyUsd * pct / 100.0;
    final days = math.max(0.0, (nowSec - t.ts) / 86400.0);

    t.status = 'closed';
    t.tsClose = nowSec;
    t.timeClose = timeStr;
    t.exitPrice = xfFinal;
    t.exitReason = reason;
    t.pct = double.parse(pct.toStringAsFixed(3));
    t.pnlUsd = double.parse(pnl.toStringAsFixed(2));
    t.daysHeld = double.parse(days.toStringAsFixed(2));

    equityCum += pnl;
    equityPts.add([nowSec * 1000.0, double.parse(equityCum.toStringAsFixed(2))]);
    if (equityPts.length > 500) equityPts.removeAt(0);

    openTrades.removeWhere((x) => x.id == t.id);
    closedLog.add(t);
    if (closedLog.length > 500) closedLog.removeAt(0);

    final tfAr = t.interval == '4h' ? '4 ساعات' : 'يومي';
    final msg =
        '📕 إغلاق ${t.symbol} ($tfAr) · $reason · ${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}% (${pnl >= 0 ? '+' : ''}${pnl.toStringAsFixed(2)}\$)';
    logEvent(t.symbol, 'close', msg, pnl >= 0 ? 'win' : 'loss');
    telegram.queueMessage(msg, 'close');
    await saveStorage();
    notifyListeners();
    return true;
  }

  // ── مسح السوق الكامل لفريم (4h أو 1d) ──
  Future<void> runScan(String interval, {String source = 'manual'}) async {
    if (scanning[interval] == true) return;
    scanning[interval] = true;
    scanDone[interval] = 0;
    scanTotal[interval] = 0;
    notifyListeners();

    try {
      final allSyms = await binance.getSpotSymbols();
      final bl = blacklistSet;
      final syms = allSyms.where((s) => !bl.contains(s)).toList();
      scanTotal[interval] = syms.length;
      notifyListeners();

      final double vm = bosvolOn ? bosvolMult : 0.0;
      final double abe = autoBeOn ? autoBePct : 0.0;

      final newZones = <PendingZone>[];
      int entries = 0;

      const int batchSize = 8;
      for (int i = 0; i < syms.length; i += batchSize) {
        final chunk = syms.sublist(i, math.min(i + batchSize, syms.length));
        await Future.wait(chunk.map((sym) async {
          final bars = await binance.getClosedKlines(sym, interval);
          scanDone[interval] = (scanDone[interval] ?? 0) + 1;
          if (bars == null || bars.isEmpty) return;

          final res = SdEngine.runSym(
            bars,
            interval: interval,
            volmult: vm,
            autoBePct: abe,
            slGuard: true,
          );
          if (res == null) return;

          final lastBar = bars.last;
          // فحص المناطق المعلقة
          if (res.pend != null && res.pend!['side'] == 'L') {
            final p = res.pend!;
            final zb = (p['zb'] as num).toDouble();
            final zt = (p['zt'] as num).toDouble();
            final tp = (p['tp'] as num).toDouble();
            final crT = (p['cr_t'] as num).toInt();
            final zKey = '$sym|$interval|z|$crT';
            if (!enteredGuard.containsKey(zKey)) {
              final midPx = 0.5 * (zb + zt);
              final efEst = midPx * (1.0 + SdEngine.slipIn);
              final slPx = zb * SdEngine.zoneBufLo;
              final rrEst = (tp - efEst) / math.max(1e-12, efEst - slPx);
              if (rrEst > 1.2) {
                newZones.add(PendingZone(
                  symbol: sym,
                  interval: interval,
                  side: 'L',
                  zb: zb,
                  zt: zt,
                  mid: midPx,
                  sl: slPx,
                  tp: tp,
                  cr: (p['cr'] as num).toInt(),
                  crT: crT,
                  closePx: lastBar.close,
                  rrEst: double.parse(rrEst.toStringAsFixed(2)),
                ));
              }
            }
          }

          // فحص إشارات الدخول الجديدة على آخر شمعة مغلقة
          if (res.pos != null && res.pos!['side'] == 'L') {
            final p = res.pos!;
            final eb = (p['eb'] as num).toInt();
            if (bars[eb].openTime == lastBar.openTime) {
              final crT = (p['cr_t'] as num).toInt();
              final zKey = '$sym|$interval|z|$crT';
              if (!enteredGuard.containsKey(zKey)) {
                enteredGuard[zKey] = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
                if (!openTrades.any((o) => o.symbol == sym) && openTrades.length < maxOpen) {
                  final ok = await _openNewTrade(
                    symbol: sym,
                    interval: interval,
                    ef: (p['ef'] as num).toDouble(),
                    sl: (p['sl'] as num).toDouble(),
                    tp: (p['tp'] as num).toDouble(),
                    rr: (p['rr'] as num).toDouble(),
                    zb: (p['zb'] as num).toDouble(),
                    zt: (p['zt'] as num).toDouble(),
                    crT: crT,
                    px: lastBar.close,
                    src: 'scan',
                  );
                  if (ok) entries++;
                } else {
                  skippedCount++;
                }
              }
            }
          }
        }));
        notifyListeners();
      }

      newZones.sort((a, b) => b.rrEst.compareTo(a.rrEst));
      zones[interval] = newZones.take(80).toList();
      lastScanTime[interval] = DateTime.now();

      final msg =
          '📉 مسحة ${interval == '4h' ? '4 ساعات' : 'اليومي'}: ${syms.length} رمز · دخول $entries · مناطق ${zones[interval]!.length}';
      logEvent('النظام', 'scan', msg, 'info');
      if (source == 'auto') telegram.queueMessage(msg, 'scan');
      await saveStorage();
    } finally {
      scanning[interval] = false;
      notifyListeners();
    }
  }

  // ── إجراءات المستخدم اليدوية (تأمين / إغلاق / تعديل مستويات / دخول فوري) ──
  Future<String?> moveToBreakeven(String tradeId) async {
    final idx = openTrades.indexWhere((t) => t.id == tradeId);
    if (idx < 0) return 'الصفقة غير موجودة';
    final t = openTrades[idx];
    final beSl = t.entryPrice * (1.0 + SdEngine.feeRtDef / 100.0 + SdEngine.slipIn);
    final px = livePrices[t.symbol] ?? t.eventClose;
    if (px > 0 && px <= beSl) {
      return 'السعر الحي حالياً تحت نقطة التعادل — التأمين متاح عندما تكون الصفقة رابحة';
    }
    t.sl = beSl;
    t.be = true;
    final msg = '🛡 تأمين يدوي ${t.symbol}: رفع الستوب إلى التعادل ${beSl.toStringAsPrecision(5)}';
    logEvent(t.symbol, 'protect', msg, 'open');
    telegram.queueMessage(msg, 'protect');
    await saveStorage();
    notifyListeners();
    return null;
  }

  Future<bool> closeTradeManual(String tradeId) async {
    final idx = openTrades.indexWhere((t) => t.id == tradeId);
    if (idx < 0) return false;
    final t = openTrades[idx];
    final snap = await binance.getLivePricesSnapshot([t.symbol]);
    final px = snap[t.symbol] ?? livePrices[t.symbol] ?? t.eventClose;
    if (px <= 0) return false;
    final xf = px * (1.0 - SdEngine.slipTp);
    return _executeCloseTrade(t, xf, 'يدوي');
  }

  Future<int> closeAllTrades() async {
    int count = 0;
    for (final t in List<TradeRecord>.from(openTrades)) {
      final ok = await closeTradeManual(t.id);
      if (ok) count++;
    }
    return count;
  }

  Future<void> modifyTradeLevels(String tradeId, double newTp, double newSl) async {
    final idx = openTrades.indexWhere((t) => t.id == tradeId);
    if (idx < 0) return;
    final t = openTrades[idx];
    if (newTp <= newSl || newTp <= 0 || newSl <= 0) return;
    t.tp = newTp;
    t.sl = newSl;
    t.be = newSl >= t.entryPrice;
    t.modified = true;
    if (t.entryPrice > newSl && newTp > t.entryPrice) {
      t.rr = double.parse(((newTp - t.entryPrice) / (t.entryPrice - newSl)).toStringAsFixed(2));
    }
    logEvent(t.symbol, 'protect', 'تعديل مستويات ${t.symbol} على الشارت (RR ${t.rr})', 'info');
    await saveStorage();
    notifyListeners();
  }

  Future<String?> manualOpenZone(PendingZone z) async {
    if (openTrades.any((t) => t.symbol == z.symbol)) {
      return 'العملة مفتوحة بالفعل في الدفتر';
    }
    if (openTrades.length >= maxOpen) {
      return 'الخانات ممتلئة (${openTrades.length}/$maxOpen)';
    }
    final snap = await binance.getLivePricesSnapshot([z.symbol]);
    final px = snap[z.symbol] ?? (z.closePx > 0 ? z.closePx : z.mid);
    final ef = px * (1.0 + SdEngine.slipIn);
    final sl = z.sl < ef ? z.sl : ef * 0.98;
    final tp = z.tp > ef ? z.tp : ef * 1.06;
    final rr = (tp - ef) / math.max(1e-12, ef - sl);

    final ok = await _openNewTrade(
      symbol: z.symbol,
      interval: z.interval,
      ef: ef,
      sl: sl,
      tp: tp,
      rr: rr,
      zb: z.zb,
      zt: z.zt,
      crT: z.crT,
      px: px,
      src: 'manual',
    );
    if (!ok) return 'تعذر فتح الصفقة (تأكد من السيولة أو الاتصال)';
    zones[z.interval]?.removeWhere((x) => x.symbol == z.symbol);
    await saveStorage();
    notifyListeners();
    return null;
  }

  Future<void> resetScope(String scope) async {
    if (scope == 'book') {
      openTrades.clear();
      closedLog.clear();
      equityPts.clear();
      equityCum = 0.0;
      skippedCount = 0;
      logEvent('النظام', 'sys', 'تصفير الدفتر بالكامل', 'warn');
    } else {
      zones = {'4h': [], '1d': []};
      enteredGuard.clear();
      logEvent('النظام', 'sys', 'تصفير الإشارات والمناطق المعلقة', 'warn');
    }
    await saveStorage();
    notifyListeners();
  }

  // ── محاكي الباك تيست الشامل (REAL BINANCE BACKTEST SIMULATOR) ──
  Future<void> runBacktest({
    required double size,
    required int slots,
    required double cap,
    required String tfFilter, // 'all', '4h', '1d'
    required double feeRt,
    required bool useBosVol,
    required double bosVolMult,
    required bool useAutoBe,
    required double autoBeTriggerPct,
    int maxSymbolsToScan = 60,
  }) async {
    if (btRunning) return;
    btRunning = true;
    btCancelReq = false;
    btDone = 0;
    btTotal = 1;
    btPhase = 'جاري جلب قائمة عملات بايننس السبوت…';
    notifyListeners();

    try {
      final allSyms = await binance.getSpotSymbols();
      final bl = blacklistSet;
      final syms = allSyms.where((s) => !bl.contains(s)).take(maxSymbolsToScan).toList();
      final ivs = tfFilter == 'all' ? ['4h', '1d'] : [tfFilter];
      btTotal = syms.length * ivs.length;
      btPhase = 'جاري فحص الشموع وتشغيل محرك العرض والطلب…';
      notifyListeners();

      final signals = <Map<String, dynamic>>[];

      for (final sym in syms) {
        if (btCancelReq) break;
        for (final iv in ivs) {
          if (btCancelReq) break;
          final bars = await binance.getClosedKlines(sym, iv, limit: 490);
          btDone++;
          if (bars != null && bars.length >= 300) {
            final res = SdEngine.runSym(
              bars,
              interval: iv,
              volmult: useBosVol ? bosVolMult : 0.0,
              autoBePct: useAutoBe ? autoBeTriggerPct : 0.0,
              slGuard: true,
              feeRt: feeRt,
            );
            if (res != null) {
              for (final tx in res.tradesExt) {
                if (tx['side'] == 'L' && tx['reason'] != 'EOD') {
                  signals.add({
                    'sym': sym,
                    'tf': iv,
                    'tfv': iv == '1d' ? 1 : 0,
                    't_in': tx['t_in'] as int,
                    't_out': tx['t_out'] as int,
                    'pct': (tx['pct'] as num).toDouble(),
                    'rr': (tx['rr'] as num).toDouble(),
                    'reason': tx['reason'].toString(),
                  });
                }
              }
            }
          }
          if (btDone % 4 == 0) notifyListeners();
        }
      }

      signals.sort((a, b) {
        final c1 = (a['t_in'] as int).compareTo(b['t_in'] as int);
        if (c1 != 0) return c1;
        final c2 = (b['tfv'] as int).compareTo(a['tfv'] as int);
        if (c2 != 0) return c2;
        return (b['rr'] as double).compareTo(a['rr'] as double);
      });

      // محاكاة المحفظة الزمنية
      final ev = <Map<String, dynamic>>[];
      for (int idx = 0; idx < signals.length; idx++) {
        final s = signals[idx];
        ev.add({'t': s['t_in'], 'kind': 1, 'idx': idx, 'sig': s});
        ev.add({'t': s['t_out'], 'kind': 0, 'idx': idx, 'sig': s});
      }
      ev.sort((a, b) {
        final c = (a['t'] as int).compareTo(b['t'] as int);
        if (c != 0) return c;
        return (a['kind'] as int).compareTo(b['kind'] as int);
      });

      double freeCash = cap;
      double lockedCash = 0.0;
      double equity = cap;
      double peakEq = cap;
      double maxDdPct = 0.0;
      double maxDdUsd = 0.0;
      final active = <String, Map<String, dynamic>>{};
      final eqCurve = <List<double>>[];
      int closedN = 0;
      int wins = 0;
      int beSaves = 0;
      int skipSlots = 0;
      double grossWin = 0.0;
      double grossLoss = 0.0;
      double totalFees = 0.0;
      final recentTrades = <Map<String, dynamic>>[];

      for (final e in ev) {
        final sig = e['sig'] as Map<String, dynamic>;
        final sym = sig['sym'] as String;
        final idx = e['idx'] as int;
        if (e['kind'] == 0) {
          if (active.containsKey(sym) && active[sym]!['idx'] == idx) {
            final rec = active.remove(sym)!;
            final notional = rec['notional'] as double;
            final pct = sig['pct'] as double;
            final pnl = notional * (pct / 100.0);
            lockedCash = math.max(0.0, lockedCash - notional);
            freeCash += notional + pnl;
            equity = freeCash + lockedCash;
            if (equity > peakEq) peakEq = equity;
            final dd = peakEq > 0 ? (peakEq - equity) / peakEq * 100.0 : 0.0;
            if (dd > maxDdPct) maxDdPct = dd;
            if (peakEq - equity > maxDdUsd) maxDdUsd = peakEq - equity;

            eqCurve.add([(e['t'] as int).toDouble(), equity]);
            closedN++;
            totalFees += notional * (feeRt / 100.0);
            if (pnl > 0) {
              wins++;
              grossWin += pnl;
            } else {
              grossLoss += pnl.abs();
            }
            if (sig['reason'] == 'BE') beSaves++;
            recentTrades.add({
              'sym': sym,
              'tf': sig['tf'],
              'reason': sig['reason'],
              'rr': sig['rr'],
              'pct': pct,
              'pnl': pnl,
              'eq': equity,
            });
          }
        } else {
          if (active.containsKey(sym)) continue;
          if (active.length >= slots) {
            skipSlots++;
            continue;
          }
          final notional = math.min(size, freeCash);
          if (notional < math.max(10.0, size * 0.20)) continue;
          freeCash -= notional;
          lockedCash += notional;
          active[sym] = {'idx': idx, 'notional': notional};
        }
      }

      final net = equity - cap;
      final wr = closedN > 0 ? (wins / closedN) * 100.0 : 0.0;
      final pf = grossLoss > 0 ? (grossWin / grossLoss) : (grossWin > 0 ? 99.0 : 0.0);

      lastBtResult = {
        'base_eq': cap,
        'end_eq': equity,
        'net': net,
        'roi': cap > 0 ? (net / cap) * 100.0 : 0.0,
        'closed': closedN,
        'signals': signals.length,
        'wins': wins,
        'losses': closedN - wins,
        'wr': wr,
        'pf': pf,
        'max_dd': maxDdPct,
        'max_dd_usd': maxDdUsd,
        'be_saves': beSaves,
        'skip_slots': skipSlots,
        'fees': totalFees,
        'scanned_syms': syms.length,
        'eq_curve': eqCurve,
        'recent': recentTrades.reversed.take(30).toList(),
      };
    } finally {
      btRunning = false;
      notifyListeners();
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  7. التطبيق الرئيسي والواجهات (FLUTTER QUANTUM UI)
// ═════════════════════════════════════════════════════════════════════════════
class AlhaQuantumApp extends StatefulWidget {
  const AlhaQuantumApp({super.key});

  @override
  State<AlhaQuantumApp> createState() => _AlhaQuantumAppState();
}

class _AlhaQuantumAppState extends State<AlhaQuantumApp> {
  late final AlhaController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = AlhaController();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final p = ctrl.palette;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ALHA',
          locale: const Locale('ar', 'AE'),
          supportedLocales: const [Locale('ar', 'AE'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            brightness: p.isLight ? Brightness.light : Brightness.dark,
            scaffoldBackgroundColor: p.bgVoid,
            primaryColor: p.acPri,
            colorScheme: ColorScheme(
              brightness: p.isLight ? Brightness.light : Brightness.dark,
              primary: p.acPri,
              onPrimary: p.isLight ? Colors.white : const Color(0xFF030816),
              secondary: p.acSec,
              onSecondary: Colors.white,
              error: p.dn,
              onError: Colors.white,
              surface: p.bgPanel,
              onSurface: p.txMain,
            ),
            useMaterial3: true,
          ),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: AlhaHomeShell(ctrl: ctrl),
          ),
        );
      },
    );
  }
}

class AlhaHomeShell extends StatefulWidget {
  final AlhaController ctrl;
  const AlhaHomeShell({super.key, required this.ctrl});

  @override
  State<AlhaHomeShell> createState() => _AlhaHomeShellState();
}

class _AlhaHomeShellState extends State<AlhaHomeShell> {
  int _tabIndex = 0;
  String _zoneTab = '4h';
  bool _zoneNearOnly = false;
  bool _zoneFavOnly = false;
  String _zoneSearch = '';

  AlhaController get c => widget.ctrl;
  AlhaThemePalette get p => c.palette;

  String _fmtN(num? v, [int d = 2]) {
    if (v == null || v.isNaN) return '—';
    return v.toStringAsFixed(d);
  }

  String _fmtPx(num? v) {
    if (v == null || v.isNaN || v == 0) return '—';
    final a = v.abs();
    if (a >= 100) return v.toStringAsFixed(2);
    if (a >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: p.bgVoid,
      body: Stack(
        children: [
          // محتوى التبويبات
          SafeArea(
            child: Column(
              children: [
                _buildHudHeader(),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      _buildOpsTab(),
                      _buildPerfTab(),
                      _buildCalcTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // شريط التنقل السفلي العائم (Spatial Dock)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildSpatialDock(),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. الهيدر العلوي المتجاوب ──
  Widget _buildHudHeader() {
    final now = DateTime.now();
    final clockStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final isReal = c.tradingMode == 'real' && c.apiKey.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: p.bgPanel.withOpacity(0.92),
        border: Border(bottom: BorderSide(color: p.bdrSubtle)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(colors: [p.acPri, p.acSec]),
            ),
            child: Icon(
              Icons.candlestick_chart_rounded,
              color: p.isLight ? Colors.white : const Color(0xFF030816),
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ALHA',
            style: TextStyle(
              color: p.txMain,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 10),
          // كبسولة الحالة والساعة
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: p.bgDeep,
                border: Border.all(color: p.bdrGlow),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.isConnected ? p.up : p.dn,
                      boxShadow: [
                        BoxShadow(
                          color: (c.isConnected ? p.up : p.dn).withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Binance Spot · $clockStr',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: p.txMain,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // شارة نوع التداول
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: (isReal ? p.warn : p.up).withOpacity(0.14),
              border: Border.all(color: (isReal ? p.warn : p.up).withOpacity(0.45)),
            ),
            child: Row(
              children: [
                Icon(
                  isReal ? Icons.currency_exchange_rounded : Icons.shield_rounded,
                  size: 15,
                  color: isReal ? p.warn : p.up,
                ),
                const SizedBox(width: 4),
                Text(
                  isReal ? (c.testnet ? 'Testnet' : 'حقيقي') : 'تجريبي',
                  style: TextStyle(
                    color: isReal ? p.warn : p.up,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // تبديل الثيم
          InkWell(
            onTap: () {
              c.cycleTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('الثيم: ${c.palette.nameAr}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: p.bgElev,
                border: Border.all(color: p.bdrSubtle),
              ),
              child: Icon(Icons.palette_outlined, size: 18, color: p.acPri),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. التبويب الأول: العمليات (OPERATIONS) ──
  Widget _buildOpsTab() {
    final wins = c.closedLog.where((t) => (t.pnlUsd ?? 0) > 0).length;
    final losses = c.closedLog.length - wins;
    final wr = c.closedLog.isNotEmpty ? (wins / c.closedLog.length) * 100.0 : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
      children: [
        // بطاقة رصيد المحفظة وصافي الربح
        _holoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet_rounded, size: 16, color: p.acPri),
                          const SizedBox(width: 5),
                          Text('رصيد المحفظة', style: TextStyle(color: p.txSub, fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_fmtN(c.currentEquity, 2)}',
                        style: TextStyle(color: p.txMain, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: (c.equityCum >= 0 ? p.up : p.dn).withOpacity(0.12),
                      border: Border.all(color: (c.equityCum >= 0 ? p.up : p.dn).withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('صافي الربح', style: TextStyle(color: p.txSub, fontSize: 10.5, fontWeight: FontWeight.w700)),
                        Text(
                          '${c.equityCum >= 0 ? '+' : ''}\$${_fmtN(c.equityCum, 2)}',
                          style: TextStyle(
                            color: c.equityCum >= 0 ? p.up : p.dn,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: p.bdrSubtle, height: 1),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _pill('الأساس: \$${_fmtN(c.baseEquity, 0)}', p.txSub),
                  _pill('نسبة الفوز: ${wr != null ? '${_fmtN(wr, 1)}%' : '—'} ($winsر / $lossesخ)', p.up),
                  _pill('الخانات: ${c.openTrades.length}/${c.maxOpen}', p.acSec),
                  _pill('فلتر الحجم: ${c.bosvolOn ? '${c.bosvolMult}×' : 'معطل'}', p.acPri),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // بطاقتا الفريمات (4 ساعات + يومي)
        Row(
          children: [
            Expanded(child: _buildFrameCard('4h', 'فريم 4 ساعات', p.acPri)),
            const SizedBox(width: 10),
            Expanded(child: _buildFrameCard('1d', 'الفريم اليومي', p.acSec)),
          ],
        ),
        const SizedBox(height: 18),

        // الصفقات المفتوحة
        Row(
          children: [
            Icon(Icons.workspaces_rounded, color: p.acPri, size: 20),
            const SizedBox(width: 6),
            Text(
              'الصفقات المفتوحة (${c.openTrades.length}/${c.maxOpen})',
              style: TextStyle(color: p.txMain, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            if (c.openTrades.isNotEmpty)
              TextButton.icon(
                onPressed: () => c.closeAllTrades(),
                icon: Icon(Icons.close_rounded, size: 16, color: p.dn),
                label: Text('إغلاق الكل', style: TextStyle(color: p.dn, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (c.openTrades.isEmpty)
          _emptyBox(Icons.hourglass_empty_rounded, 'لا توجد صفقات مفتوحة حالياً')
        else
          ...c.openTrades.map(_buildOpenTradeCard),

        const SizedBox(height: 18),

        // المناطق المعلقة
        Row(
          children: [
            Icon(Icons.my_location_rounded, color: p.acPri, size: 20),
            const SizedBox(width: 6),
            Text(
              'المناطق المعلقة',
              style: TextStyle(color: p.txMain, fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildZonesToolbar(),
        const SizedBox(height: 10),
        ..._buildZonesList(),
      ],
    );
  }

  Widget _buildFrameCard(String iv, String title, Color accent) {
    final nextMs = AlhaController.nextCloseMs(iv);
    final remSec = math.max(0, (nextMs - DateTime.now().millisecondsSinceEpoch) ~/ 1000);
    final h = remSec ~/ 3600;
    final m = (remSec % 3600) ~/ 60;
    final s = remSec % 60;
    final isRunning = c.scanning[iv] == true;
    final isAuto = c.autoScan[iv] == true;

    return _holoCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: p.txMain, fontSize: 13.5, fontWeight: FontWeight.w800)),
              _pill(iv.toUpperCase(), accent),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isRunning
                ? '⏳ يمسح ${c.scanDone[iv]}/${c.scanTotal[iv]}…'
                : 'الإغلاق: ${h}س ${m.toString().padLeft(2, '0')}د:${s.toString().padLeft(2, '0')}ث',
            style: TextStyle(color: accent, fontSize: 12.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isRunning ? null : () => c.runScan(iv, source: 'manual'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    side: BorderSide(color: p.bdrSubtle),
                  ),
                  child: Text('مسح', style: TextStyle(color: p.txMain, fontSize: 11.5, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    c.autoScan[iv] = !isAuto;
                    c.saveStorage();
                    c.notifyListeners();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAuto ? p.up.withOpacity(0.2) : accent.withOpacity(0.18),
                    foregroundColor: isAuto ? p.up : accent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: Text(
                    isAuto ? 'تلقائي ✓' : 'تلقائي',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpenTradeCard(TradeRecord t) {
    final px = c.livePrices[t.symbol] ?? t.eventClose;
    final livePct = px > 0 ? SdEngine.fillPct('L', t.entryPrice, px * (1.0 - SdEngine.slipTp)) : 0.0;
    final liveUsd = t.qtyUsd * livePct / 100.0;
    final prog = (t.tp > t.entryPrice && px > 0)
        ? ((px - t.entryPrice) / (t.tp - t.entryPrice)).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _holoCard(
        onTap: () => _openChartDialog(t.symbol, t.interval),
        child: Column(
          children: [
            Row(
              children: [
                Text(t.symbol, style: TextStyle(color: p.txMain, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                _pill(t.interval == '4h' ? '4 ساعات' : 'يومي', t.interval == '4h' ? p.acPri : p.acSec),
                if (t.be) ...[
                  const SizedBox(width: 6),
                  _pill('مؤمّنة BE', p.up),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () => _openChartDialog(t.symbol, t.interval),
                  icon: Icon(Icons.candlestick_chart_rounded, color: p.acPri, size: 20),
                  tooltip: 'الشارت وتعديل المستويات',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metricCell('دخول', _fmtPx(t.entryPrice), p.txMain),
                _metricCell('السعر الحي', _fmtPx(px), p.acPri),
                _metricCell('ستوب SL', _fmtPx(t.sl), t.be ? p.up : p.dn),
                _metricCell('هدف TP', _fmtPx(t.tp), p.up),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: prog,
                minHeight: 6,
                backgroundColor: p.bgDeep,
                valueColor: AlwaysStoppedAnimation<Color>(livePct >= 0 ? p.up : p.dn),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${livePct >= 0 ? '+' : ''}${_fmtN(livePct, 2)}% (${liveUsd >= 0 ? '+' : ''}\$${_fmtN(liveUsd, 2)})',
                  style: TextStyle(
                    color: livePct >= 0 ? p.up : p.dn,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    if (!t.be)
                      OutlinedButton.icon(
                        onPressed: () async {
                          final err = await c.moveToBreakeven(t.id);
                          if (err != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                          }
                        },
                        icon: Icon(Icons.shield_outlined, size: 15, color: p.acPri),
                        label: Text('تأمين', style: TextStyle(color: p.acPri, fontSize: 12)),
                      ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: () => c.closeTradeManual(t.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.dn.withOpacity(0.15),
                        foregroundColor: p.dn,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 15),
                      label: const Text('إغلاق', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonesToolbar() {
    final z4Len = (c.zones['4h'] ?? []).length;
    final z1Len = (c.zones['1d'] ?? []).length;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChoiceChip(
          label: Text('4 ساعات ($z4Len)'),
          selected: _zoneTab == '4h',
          onSelected: (_) => setState(() => _zoneTab = '4h'),
        ),
        ChoiceChip(
          label: Text('يومي ($z1Len)'),
          selected: _zoneTab == '1d',
          onSelected: (_) => setState(() => _zoneTab = '1d'),
        ),
        ChoiceChip(
          label: Text('الكل (${z4Len + z1Len})'),
          selected: _zoneTab == 'all',
          onSelected: (_) => setState(() => _zoneTab = 'all'),
        ),
        FilterChip(
          label: const Text('🎯 القريبة (<2.5%)'),
          selected: _zoneNearOnly,
          onSelected: (v) => setState(() => _zoneNearOnly = v),
        ),
        FilterChip(
          label: const Text('⭐ المفضلة'),
          selected: _zoneFavOnly,
          onSelected: (v) => setState(() => _zoneFavOnly = v),
        ),
        SizedBox(
          width: 150,
          height: 36,
          child: TextField(
            onChanged: (v) => setState(() => _zoneSearch = v.trim().toUpperCase()),
            decoration: InputDecoration(
              hintText: 'بحث رمز…',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              filled: true,
              fillColor: p.bgInput,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildZonesList() {
    List<PendingZone> list = [];
    if (_zoneTab == '4h') {
      list = List.from(c.zones['4h'] ?? []);
    } else if (_zoneTab == '1d') {
      list = List.from(c.zones['1d'] ?? []);
    } else {
      list = [...(c.zones['4h'] ?? []), ...(c.zones['1d'] ?? [])];
    }

    if (_zoneNearOnly) {
      list = list.where((z) => z.distPct >= -0.5 && z.distPct <= 2.5).toList();
    }
    if (_zoneFavOnly) {
      list = list.where((z) => c.pinnedSyms.contains(z.symbol)).toList();
    }
    if (_zoneSearch.isNotEmpty) {
      list = list.where((z) => z.symbol.contains(_zoneSearch)).toList();
    }

    if (list.isEmpty) {
      return [
        _emptyBox(Icons.my_location_rounded, 'لا توجد مناطق معلقة مطابقة — اضغط «مسح» لفحص السوق'),
      ];
    }

    return list.take(30).map((z) {
      final isPinned = c.pinnedSyms.contains(z.symbol);
      final dist = z.distPct;
      final isNear = dist >= 0 && dist <= 2.5;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _holoCard(
          onTap: () => _openChartDialog(z.symbol, z.interval),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => c.togglePin(z.symbol),
                    icon: Icon(
                      isPinned ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isPinned ? p.warn : p.txDim,
                    ),
                  ),
                  Text(z.symbol, style: TextStyle(color: p.txMain, fontSize: 15.5, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 6),
                  _pill(z.interval == '4h' ? '4 ساعات' : 'يومي', z.interval == '4h' ? p.acPri : p.acSec),
                  const SizedBox(width: 6),
                  _pill('RR ${_fmtN(z.rrEst, 1)}', p.up),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final err = await c.manualOpenZone(z);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err ?? '⚡ تم فتح صفقة ${z.symbol} بنجاح ✓')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.acPri.withOpacity(0.16),
                      foregroundColor: p.acPri,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: const Icon(Icons.bolt_rounded, size: 15),
                    label: const Text('دخول', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metricCell('دخول (منتصف)', _fmtPx(z.mid), p.up),
                  _metricCell('السعر الحي', _fmtPx(z.closePx), p.acPri),
                  _metricCell('ستوب SL', _fmtPx(z.sl), p.dn),
                  _metricCell('هدف TP', _fmtPx(z.tp), p.acPri),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('المنطقة: ${_fmtPx(z.zb)} — ${_fmtPx(z.zt)}', style: TextStyle(color: p.txSub, fontSize: 11.5)),
                  Text(
                    'المسافة: ${dist >= 0 ? '+' : ''}${_fmtN(dist, 2)}%',
                    style: TextStyle(
                      color: isNear ? p.warn : p.txSub,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ── 3. التبويب الثاني: الأداء والأرشيف (PERFORMANCE & ARCHIVE) ──
  Widget _buildPerfTab() {
    final closed = c.closedLog.reversed.toList();
    final wins = closed.where((t) => (t.pnlUsd ?? 0) > 0).toList();
    final losses = closed.where((t) => (t.pnlUsd ?? 0) <= 0).toList();
    final gp = wins.fold<double>(0.0, (s, t) => s + (t.pnlUsd ?? 0));
    final gl = losses.fold<double>(0.0, (s, t) => s + (t.pnlUsd ?? 0).abs());
    final pf = gl > 0 ? gp / gl : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _statTile('إجمالي الصفقات المغلقة', '${closed.length}', p.txMain),
            _statTile('الرابحة / الخاسرة', '${wins.length} / ${losses.length}', p.up),
            _statTile('معامل الربح (PF)', pf != null ? _fmtN(pf, 2) : '—', p.acPri),
            _statTile('صافي الربح التراكمي', '${c.equityCum >= 0 ? '+' : ''}\$${_fmtN(c.equityCum, 2)}', c.equityCum >= 0 ? p.up : p.dn),
          ],
        ),
        const SizedBox(height: 16),
        _holoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('منحنى الرصيد التراكمي', style: TextStyle(color: p.txMain, fontSize: 14.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              SizedBox(
                height: 170,
                width: double.infinity,
                child: CustomPaint(
                  painter: EquityCurvePainter(
                    pts: c.equityPts,
                    baseEq: c.baseEquity,
                    palette: p,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('أرشيف الصفقات المغلقة (${closed.length})', style: TextStyle(color: p.txMain, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (closed.isEmpty)
          _emptyBox(Icons.history_rounded, 'لا توجد صفقات مغلقة بعد')
        else
          ...closed.take(60).map((t) {
            final isWin = (t.pnlUsd ?? 0) >= 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _holoCard(
                padding: const EdgeInsets.all(12),
                onTap: () => _openChartDialog(t.symbol, t.interval),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(t.symbol, style: TextStyle(color: p.txMain, fontWeight: FontWeight.w800, fontSize: 14.5)),
                            const SizedBox(width: 6),
                            _pill(t.exitReason ?? 'TP', isWin ? p.up : p.dn),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${t.timeClose ?? ''} · ${t.daysHeld ?? 0} يوم', style: TextStyle(color: p.txSub, fontSize: 11)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(t.pct ?? 0) >= 0 ? '+' : ''}${_fmtN(t.pct, 2)}%',
                          style: TextStyle(color: isWin ? p.up : p.dn, fontWeight: FontWeight.w800, fontSize: 14.5),
                        ),
                        Text(
                          '${(t.pnlUsd ?? 0) >= 0 ? '+' : ''}\$${_fmtN(t.pnlUsd, 2)}',
                          style: TextStyle(color: isWin ? p.up : p.dn, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ── 4. التبويب الثالث: الحاسبة الشاملة (BACKTEST SIMULATOR) ──
  Widget _buildCalcTab() {
    final res = c.lastBtResult;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
      children: [
        _holoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate_rounded, color: p.acPri),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'محاكي الأرباح الشامل على شموع بايننس سبوت',
                      style: TextStyle(color: p.txMain, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _metricCell('حجم الصفقة', '\$${_fmtN(c.tradeUsd, 0)}', p.acPri),
                  ),
                  Expanded(
                    child: _metricCell('أقصى خانات', '${c.maxOpen}', p.acSec),
                  ),
                  Expanded(
                    child: _metricCell('فلتر حجم الكسر', c.bosvolOn ? '${c.bosvolMult}×' : 'معطل', p.up),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: c.btRunning
                      ? null
                      : () => c.runBacktest(
                            size: c.tradeUsd,
                            slots: c.maxOpen,
                            cap: c.baseEquity,
                            tfFilter: 'all',
                            feeRt: 0.20,
                            useBosVol: c.bosvolOn,
                            bosVolMult: c.bosvolMult,
                            useAutoBe: c.autoBeOn,
                            autoBeTriggerPct: c.autoBePct,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.acPri,
                    foregroundColor: p.isLight ? Colors.white : const Color(0xFF030816),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    c.btRunning
                        ? 'جاري الفحص (${c.btDone}/${c.btTotal})…'
                        : 'تشغيل المحاكاة الشاملة الآن',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (res != null) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statTile('الرصيد النهائي', '\$${_fmtN(res['end_eq'], 0)}', p.up),
              _statTile('صافي الربح', '${(res['net'] as num) >= 0 ? '+' : ''}\$${_fmtN(res['net'], 0)} (${_fmtN(res['roi'], 1)}%)', (res['net'] as num) >= 0 ? p.up : p.dn),
              _statTile('نسبة الفوز و PF', '${_fmtN(res['wr'], 1)}% · PF ${_fmtN(res['pf'], 2)}', p.acPri),
              _statTile('أقصى تراجع (DD)', '${_fmtN(res['max_dd'], 1)}%', p.dn),
              _statTile('الصفقات المنفذة', '${res['closed']} (حماية تعادل: ${res['be_saves']})', p.txMain),
              _statTile('الأجور المدفوعة', '-\$${_fmtN(res['fees'], 0)}', p.warn),
            ],
          ),
        ],
      ],
    );
  }

  // ── 5. التبويب الرابع: الإعدادات (SETTINGS) ──
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
      children: [
        _holoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رأس المال وفلتر الحجم والتأمين التلقائي', style: TextStyle(color: p.txMain, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: c.tradeUsd.toStringAsFixed(0),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'حجم الصفقة (\$)', border: OutlineInputBorder()),
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null && parsed >= 10) {
                          c.tradeUsd = parsed;
                          c.saveStorage();
                          c.notifyListeners();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: c.maxOpen.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'أقصى صفقات', border: OutlineInputBorder()),
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null && parsed >= 1 && parsed <= 20) {
                          c.maxOpen = parsed;
                          c.saveStorage();
                          c.notifyListeners();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('فلتر حجم الكسر (BOS Volume ${c.bosvolMult}×)', style: TextStyle(color: p.txMain, fontSize: 13.5, fontWeight: FontWeight.w700)),
                value: c.bosvolOn,
                activeColor: p.acPri,
                onChanged: (v) {
                  c.bosvolOn = v;
                  c.saveStorage();
                  c.notifyListeners();
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('التأمين التلقائي عند ${c.autoBePct.toStringAsFixed(0)}% من الهدف', style: TextStyle(color: p.txMain, fontSize: 13.5, fontWeight: FontWeight.w700)),
                value: c.autoBeOn,
                activeColor: p.up,
                onChanged: (v) {
                  c.autoBeOn = v;
                  c.saveStorage();
                  c.notifyListeners();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // إعدادات تيليجرام
        _holoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('إشعارات تيليجرام', style: TextStyle(color: p.txMain, fontSize: 15, fontWeight: FontWeight.w800)),
                  Switch(
                    value: c.telegram.enabled,
                    activeColor: p.acPri,
                    onChanged: (v) {
                      c.telegram.enabled = v;
                      c.saveStorage();
                      c.notifyListeners();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: c.telegram.token,
                decoration: const InputDecoration(labelText: 'Bot Token', border: OutlineInputBorder()),
                onChanged: (v) {
                  c.telegram.token = v.trim();
                  c.saveStorage();
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: c.telegram.chatId,
                decoration: const InputDecoration(labelText: 'Chat ID', border: OutlineInputBorder()),
                onChanged: (v) {
                  c.telegram.chatId = v.trim();
                  c.saveStorage();
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final res = await c.telegram.sendDirect('🟢 نبضة تجربة من تطبيق ALHA Flutter — الإشعارات جاهزة ✓');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res['ok'] == true ? 'وصلت رسالة الاختبار بنجاح ✓' : 'خطأ: ${res['err']}')),
                    );
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('إرسال رسالة اختبار'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // إعدادات التداول الحقيقي Binance Spot
        _holoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('التداول الحقيقي (Binance Spot)', style: TextStyle(color: p.txMain, fontSize: 15, fontWeight: FontWeight.w800)),
                  Switch(
                    value: c.tradingMode == 'real',
                    activeColor: p.warn,
                    onChanged: (v) {
                      c.tradingMode = v ? 'real' : 'paper';
                      c.saveStorage();
                      c.notifyListeners();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: c.apiKey,
                decoration: const InputDecoration(labelText: 'API Key', border: OutlineInputBorder()),
                onChanged: (v) {
                  c.apiKey = v.trim();
                  c.saveStorage();
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: c.apiSecret,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'API Secret', border: OutlineInputBorder()),
                onChanged: (v) {
                  c.apiSecret = v.trim();
                  c.saveStorage();
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('بيئة التجربة (Testnet)', style: TextStyle(color: p.txMain, fontSize: 13)),
                value: c.testnet,
                onChanged: (v) {
                  c.testnet = v;
                  c.saveStorage();
                  c.notifyListeners();
                },
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final res = await c.binance.testAndFetchUsdtBalance(
                    apiKey: c.apiKey,
                    apiSecret: c.apiSecret,
                    testnet: c.testnet,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          res['ok'] == true
                              ? 'الاتصال ناجح ✓ — الرصيد المتاح: ${_fmtN(res['balance'], 2)} USDT'
                              : 'فشل الاتصال: ${res['err']}',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.cable_rounded, size: 16),
                label: const Text('فحص الاتصال والرصيد'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 6. شارت الشموع التفاعلي مع المسطرة وسحب الهدف/الستوب ──
  Future<void> _openChartDialog(String symbol, String interval) async {
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: p.bgVoid,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: InteractiveChartScreen(
            ctrl: c,
            symbol: symbol,
            initialInterval: interval,
          ),
        ),
      ),
    );
  }

  // ── شريط التنقل السفلي العائم ──
  Widget _buildSpatialDock() {
    final items = [
      {'icon': Icons.space_dashboard_rounded, 'label': 'العمليات', 'badge': c.openTrades.length},
      {'icon': Icons.analytics_rounded, 'label': 'الأداء', 'badge': c.closedLog.length},
      {'icon': Icons.calculate_rounded, 'label': 'الحاسبة', 'badge': 0},
      {'icon': Icons.tune_rounded, 'label': 'الإعدادات', 'badge': 0},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: p.bgPanel.withOpacity(0.95),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: p.bdrGlow, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (i) {
          final selected = _tabIndex == i;
          final it = items[i];
          final bdg = it['badge'] as int;
          return GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: selected ? LinearGradient(colors: [p.acPri, p.acTer]) : null,
              ),
              child: Row(
                children: [
                  Icon(
                    it['icon'] as IconData,
                    size: 19,
                    color: selected ? (p.isLight ? Colors.white : const Color(0xFF030816)) : p.txSub,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    it['label'] as String,
                    style: TextStyle(
                      color: selected ? (p.isLight ? Colors.white : const Color(0xFF030816)) : p.txSub,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                  if (bdg > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: selected ? Colors.black26 : p.acPri.withOpacity(0.18),
                      ),
                      child: Text(
                        '$bdg',
                        style: TextStyle(
                          color: selected ? Colors.white : p.acPri,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── أدوات مساعدة للبطاقات ──
  Widget _holoCard({required Widget child, EdgeInsetsGeometry? padding, VoidCallback? onTap}) {
    return Material(
      color: p.bgPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.bdrSubtle),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.13),
        border: Border.all(color: color.withOpacity(0.38)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _metricCell(String label, String val, Color valColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: p.txSub, fontSize: 10.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(color: valColor, fontSize: 12.5, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _statTile(String label, String val, Color col) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.bgPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.bdrSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: p.txSub, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(color: col, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _emptyBox(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.bdrSubtle),
        color: p.bgDeep.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: p.acPri, size: 30),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: p.txSub, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  8. شاشة الشارت التفاعلي (CANDLESTICK CHART + RULER + TP/SL DRAG)
// ═════════════════════════════════════════════════════════════════════════════
class InteractiveChartScreen extends StatefulWidget {
  final AlhaController ctrl;
  final String symbol;
  final String initialInterval;

  const InteractiveChartScreen({
    super.key,
    required this.ctrl,
    required this.symbol,
    required this.initialInterval,
  });

  @override
  State<InteractiveChartScreen> createState() => _InteractiveChartScreenState();
}

class _InteractiveChartScreenState extends State<InteractiveChartScreen> {
  late String interval;
  List<KlineBar> bars = [];
  bool loading = true;
  bool showVol = true;
  bool rulerMode = false;
  Offset? rulerStart;
  Offset? rulerEnd;
  int startIdx = 0;
  int endIdx = 0;

  @override
  void initState() {
    super.initState();
    interval = widget.initialInterval;
    _loadChart();
  }

  Future<void> _loadChart() async {
    setState(() => loading = true);
    final loaded = await widget.ctrl.binance.getClosedKlines(widget.symbol, interval, limit: 350);
    if (loaded != null && loaded.isNotEmpty) {
      SdEngine.runSym(
        loaded,
        interval: interval,
        volmult: widget.ctrl.bosvolOn ? widget.ctrl.bosvolMult : 0.0,
        autoBePct: widget.ctrl.autoBeOn ? widget.ctrl.autoBePct : 0.0,
      );
      bars = loaded;
      endIdx = bars.length;
      startIdx = math.max(0, endIdx - 90);
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.ctrl.palette;
    final z = (widget.ctrl.zones[interval] ?? []).where((x) => x.symbol == widget.symbol).firstOrNull;
    final op = widget.ctrl.openTrades.where((x) => x.symbol == widget.symbol && x.interval == interval).firstOrNull;

    return Scaffold(
      backgroundColor: p.bgVoid,
      appBar: AppBar(
        backgroundColor: p.bgPanel,
        title: Text('${widget.symbol} · ${interval == '4h' ? '4 ساعات' : 'يومي'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              rulerMode = !rulerMode;
              rulerStart = null;
              rulerEnd = null;
            }),
            icon: Icon(Icons.straighten_rounded, color: rulerMode ? p.acPri : p.txSub),
            tooltip: 'أداة المسطرة',
          ),
          IconButton(
            onPressed: () => setState(() => showVol = !showVol),
            icon: Icon(Icons.bar_chart_rounded, color: showVol ? p.acPri : p.txSub),
            tooltip: 'الفوليوم و BOS',
          ),
          TextButton(
            onPressed: () {
              interval = interval == '4h' ? '1d' : '4h';
              _loadChart();
            },
            child: Text(interval == '4h' ? '1D' : '4H', style: TextStyle(color: p.acPri, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bars.isEmpty
              ? Center(child: Text('تعذر جلب الشموع لـ ${widget.symbol}', style: TextStyle(color: p.txSub)))
              : Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onPanStart: (d) {
                          if (rulerMode) {
                            setState(() {
                              rulerStart = d.localPosition;
                              rulerEnd = d.localPosition;
                            });
                          }
                        },
                        onPanUpdate: (d) {
                          if (rulerMode) {
                            setState(() => rulerEnd = d.localPosition);
                          } else {
                            final count = endIdx - startIdx;
                            final shift = (-d.delta.dx * 0.25).round();
                            setState(() {
                              startIdx = (startIdx + shift).clamp(0, math.max(0, bars.length - count));
                              endIdx = startIdx + count;
                            });
                          }
                        },
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: CandlestickChartPainter(
                            bars: bars.sublist(startIdx, endIdx),
                            zone: z,
                            openTrade: op,
                            showVol: showVol,
                            rulerStart: rulerStart,
                            rulerEnd: rulerEnd,
                            palette: p,
                          ),
                        ),
                      ),
                    ),
                    if (z != null && op == null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final err = await widget.ctrl.manualOpenZone(z);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err ?? '⚡ تم فتح صفقة ${z.symbol} فوراً ✓')),
                                );
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.bolt_rounded),
                            label: const Text('دخول فوري بسعر السوق الحي'),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  9. رسامات الشارت والمنحنى (CUSTOM PAINTERS)
// ═════════════════════════════════════════════════════════════════════════════
class EquityCurvePainter extends CustomPainter {
  final List<List<double>> pts;
  final double baseEq;
  final AlhaThemePalette palette;

  EquityCurvePainter({required this.pts, required this.baseEq, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) {
      final p = Paint()
        ..color = palette.txDim.withOpacity(0.4)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
      return;
    }
    final vs = pts.map((e) => baseEq + e[1]).toList();
    double mn = vs.reduce(math.min);
    double mx = vs.reduce(math.max);
    if ((mx - mn).abs() < 1e-6) {
      mx += 1;
      mn -= 1;
    }
    final path = Path();
    for (int i = 0; i < vs.length; i++) {
      final x = size.width * i / (vs.length - 1);
      final y = size.height - 10 - (size.height - 20) * (vs[i] - mn) / (mx - mn);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final isUp = vs.last >= vs.first;
    final col = isUp ? palette.up : palette.dn;
    final strokePaint = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant EquityCurvePainter oldDelegate) => true;
}

class CandlestickChartPainter extends CustomPainter {
  final List<KlineBar> bars;
  final PendingZone? zone;
  final TradeRecord? openTrade;
  final bool showVol;
  final Offset? rulerStart;
  final Offset? rulerEnd;
  final AlhaThemePalette palette;

  CandlestickChartPainter({
    required this.bars,
    this.zone,
    this.openTrade,
    required this.showVol,
    this.rulerStart,
    this.rulerEnd,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    double lo = bars.map((b) => b.low).reduce(math.min);
    double hi = bars.map((b) => b.high).reduce(math.max);
    if (zone != null) {
      lo = math.min(lo, zone!.sl);
      hi = math.max(hi, zone!.tp);
    }
    if (openTrade != null) {
      lo = math.min(lo, openTrade!.sl);
      hi = math.max(hi, openTrade!.tp);
    }
    final margin = (hi - lo) * 0.06;
    lo -= margin;
    hi += margin;

    const double padL = 10;
    const double padR = 64;
    const double padT = 16;
    const double padB = 20;
    final double iw = size.width - padL - padR;
    final double ih = size.height - padT - padB;

    double X(int i) => padL + iw * (i + 0.5) / bars.length;
    double Y(double v) => padT + ih * (1.0 - (v - lo) / math.max(1e-12, hi - lo));

    // رسم منطقة الطلب المعلقة
    if (zone != null) {
      final yTop = Y(math.max(zone!.zb, zone!.zt));
      final yBot = Y(math.min(zone!.zb, zone!.zt));
      final rect = Rect.fromLTRB(padL, yTop, size.width - padR, math.max(yTop + 3, yBot));
      canvas.drawRect(rect, Paint()..color = palette.acPri.withOpacity(0.14));
      canvas.drawRect(
        rect,
        Paint()
          ..color = palette.acPri.withOpacity(0.55)
          ..style = PaintingStyle.stroke,
      );
    }

    final bw = math.max(2.0, iw / bars.length * 0.65);

    // رسم الفوليوم
    if (showVol) {
      final maxV = bars.map((b) => b.volume).reduce(math.max);
      if (maxV > 0) {
        for (int i = 0; i < bars.length; i++) {
          final b = bars[i];
          final vh = (b.volume / maxV) * (ih * 0.18);
          final col = (b.isBos && b.bosOk)
              ? palette.warn.withOpacity(0.7)
              : (b.close >= b.open ? palette.up.withOpacity(0.22) : palette.dn.withOpacity(0.22));
          canvas.drawRect(
            Rect.fromLTWH(X(i) - bw / 2, size.height - padB - vh, bw, vh),
            Paint()..color = col,
          );
        }
      }
    }

    // رسم الشموع
    for (int i = 0; i < bars.length; i++) {
      final b = bars[i];
      final isUp = b.close >= b.open;
      final col = (b.isBos && b.bosOk && showVol) ? palette.acPri : (isUp ? palette.up : palette.dn);
      final x = X(i);
      canvas.drawLine(Offset(x, Y(b.high)), Offset(x, Y(b.low)), Paint()..color = col);
      final yo = Y(b.open);
      final yc = Y(b.close);
      canvas.drawRect(
        Rect.fromLTRB(x - bw / 2, math.min(yo, yc), x + bw / 2, math.max(math.min(yo, yc) + 1.5, math.max(yo, yc))),
        Paint()..color = col,
      );
    }

    // رسم أداة المسطرة
    if (rulerStart != null && rulerEnd != null) {
      final rRect = Rect.fromPoints(rulerStart!, rulerEnd!);
      canvas.drawRect(rRect, Paint()..color = palette.acPri.withOpacity(0.18));
      canvas.drawRect(
        rRect,
        Paint()
          ..color = palette.acPri
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CandlestickChartPainter oldDelegate) => true;
}
