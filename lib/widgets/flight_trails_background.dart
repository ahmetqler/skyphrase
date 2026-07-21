import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum _PlaneKind { concorde, a380, cessna }
enum _RouteMode { line, curved, heart, show }

/// Bir gösteri uçağının, ekran kesri uzayında zamana göre konumu — girişi,
/// icrası ve çıkışı tek bir kapalı fonksiyonda taşır (bkz. _piecewiseShowPos).
typedef _PosFn = Offset Function(double t);

/// Uygulama genelinde arka planda uçan, iz bırakan minik uçaklar
/// (FlightRadar24'teki uçuş izlerine gönderme). Tamamen dekoratif; hiçbir
/// gerçek uçuş/ilerleme verisiyle ilgisi yok. MaterialApp.builder içinde
/// tek bir kez mount edilip tüm ekranların arkasında sürekli çalışır (bkz.
/// app.dart) — bu yüzden rastgele rotalar sadece uygulama açılışında değil,
/// her uçuş bitiminde de yeniden üretilir, sürekli değişen bir arka plan
/// sağlar. Uçak burnu her zaman gidiş yönünü gösterir çünkü
/// [_PlaneShapePainter] uçağı hep +x eksenine (sağa) bakacak şekilde çizer,
/// döndürme açısı da doğrudan hareket vektöründen (`Offset.direction`)
/// gelir — aradaki tutarlılık sayesinde ekstra bir düzeltme açısına gerek
/// kalmaz.
class FlightTrailsBackground extends StatefulWidget {
  const FlightTrailsBackground({super.key});

  @override
  State<FlightTrailsBackground> createState() => _FlightTrailsBackgroundState();
}

class _PlaneRoute {
  final _PlaneKind kind;
  final double size;
  final int durationSeconds;
  final _RouteMode mode;
  // Düz çizgi modu.
  final Offset start;
  final Offset end;
  // Kalp modu: kalbin merkezi (ekran kesri) ve ekranın kısa kenarına
  // oranlı ölçeği.
  final Offset heartCenter;
  final double heartScale;
  // Periyodik gösteri modu (ay yıldız / kanat açılımı / DNA): bu uçağın
  // giriş+icra+çıkışını tek bir fonksiyonda taşıyan, ekran kesri uzayında
  // önceden üretilmiş konum fonksiyonu, artı izin SADECE icra aralığında
  // ([showTrailStart, showTrailEnd]) çizilmesi için sınırlar — giriş/çıkış
  // uçuşları ekranda görünür bir iz bırakmasın diye (bkz. _triggerShow,
  // _ShowTrailPainter).
  final _PosFn? showPos;
  final double showTrailStart;
  final double showTrailEnd;
  // Eğrisel/çembersel rota modu: ekran kesri uzayında önceden üretilmiş,
  // düz + çembersel dönüş (çeyrek/yarım/tam tur) + düz (dönüşün bıraktığı
  // yeni yönde) parçalarından oluşan tek bir yol (bkz. _buildCurvedRoutePoints).
  final _PolylinePath? curvedPath;
  const _PlaneRoute({
    required this.kind,
    required this.size,
    required this.durationSeconds,
    this.mode = _RouteMode.line,
    this.start = Offset.zero,
    this.end = Offset.zero,
    this.heartCenter = Offset.zero,
    this.heartScale = 0,
    this.showPos,
    this.showTrailStart = 0,
    this.showTrailEnd = 1,
    this.curvedPath,
  });
}

/// Chaikin köşe-kesme algoritması: her doğru parçasının uçlarını 1/4 ve
/// 3/4 noktalarıyla değiştirip yeniden birleştirir. Birkaç tekrar sonunda
/// tüm keskin köşeler yuvarlanmış, akıcı/el yazısı hissi veren bir eğriye
/// dönüşür — herhangi bir kırık çizgiyi yumuşatmak için kullanılabilir.
List<Offset> _chaikinSmooth(List<Offset> points, {int iterations = 3}) {
  var pts = points;
  for (var iter = 0; iter < iterations; iter++) {
    if (pts.length < 3) break;
    final next = <Offset>[pts.first];
    for (var i = 0; i < pts.length - 1; i++) {
      next.add(Offset.lerp(pts[i], pts[i + 1], 0.25)!);
      next.add(Offset.lerp(pts[i], pts[i + 1], 0.75)!);
    }
    next.add(pts.last);
    pts = next;
  }
  return pts;
}

/// Bir nokta dizisini kümülatif yay uzunluğuna göre örnekleyebilen basit
/// bir yardımcı — kalp modundaki kapalı eğri yerine burada açık, düz
/// parçalı bir "yazı" yolu izlenir.
class _PolylinePath {
  final List<Offset> points;
  final List<double> _cumLen;
  final double totalLen;

  _PolylinePath(this.points)
      : _cumLen = _computeCumLen(points),
        totalLen = _computeCumLen(points).last;

  static List<double> _computeCumLen(List<Offset> points) {
    final cum = <double>[0];
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
      cum.add(total);
    }
    return cum;
  }

  Offset pointAt(double t) {
    final target = t.clamp(0.0, 1.0) * totalLen;
    var i = 1;
    while (i < _cumLen.length && _cumLen[i] < target) {
      i++;
    }
    if (i >= points.length) return points.last;
    final segStart = _cumLen[i - 1];
    final segEnd = _cumLen[i];
    final segT = segEnd > segStart ? (target - segStart) / (segEnd - segStart) : 0.0;
    return Offset.lerp(points[i - 1], points[i], segT)!;
  }
}

/// Klasik kalp parametrik eğrisinin (θ: 0..2π) ham örneklenmiş noktaları,
/// birim (1.0 = kısa kenar ölçeği) uzayında. Bu eğrinin θ=0 ve θ=π'de
/// matematiksel olarak gerçek bir çift noktası (cusp) vardır — türev orada
/// tam sıfıra düşer ve uçağın yönü o ana kadar geldiği yönün tam tersine
/// aniden döner. Bu da tam da "uçak keskin dönemez" kuralını bozan bir
/// "yamuk" sıçramaya yol açıyordu. [_chaikinSmooth] ile bu köşeler de
/// yumuşatılır.
List<Offset> _buildHeartUnitPoints() {
  const steps = 200;
  final points = <Offset>[];
  for (var i = 0; i <= steps; i++) {
    final theta = i / steps * 2 * math.pi;
    final hx = 16 * math.pow(math.sin(theta), 3).toDouble();
    final hy = -(13 * math.cos(theta) -
        5 * math.cos(2 * theta) -
        2 * math.cos(3 * theta) -
        math.cos(4 * theta));
    points.add(Offset(hx, hy) / 17.0);
  }
  return _chaikinSmooth(points, iterations: 3);
}

final _heartUnitPath = _PolylinePath(_buildHeartUnitPoints());

Offset _heartPoint(double t, Offset center, double scale) {
  final local = _heartUnitPath.pointAt(t);
  return center + local * scale;
}

double _heartAngle(double t, Offset center, double scale) {
  const eps = 0.004;
  final p1 = _heartPoint((t - eps).clamp(0.0, 1.0), center, scale);
  final p2 = _heartPoint((t + eps).clamp(0.0, 1.0), center, scale);
  return (p2 - p1).direction;
}

/// Hilal (ay) dış hattı: iki çemberin (dış çember, yarıçap 1; iç çember,
/// merkezi sağa kaydırılmış, yarıçap 0.85) kesişim noktalarından hesaplanan
/// açılarla, dış çemberin büyük yayı + iç çemberin kalan yayı birleştirilir
/// — klasik "ay" siluetinin kesişimden kesişime tek bir kapalı yol olarak
/// izlenmesi.
List<Offset> _buildCrescentUnitPoints() {
  const steps = 70;
  final points = <Offset>[];
  const outerStartDeg = 55.15;
  const outerEndDeg = 304.85;
  for (var i = 0; i <= steps; i++) {
    final deg = outerStartDeg + (outerEndDeg - outerStartDeg) * i / steps;
    final a = deg * math.pi / 180;
    points.add(Offset(math.cos(a), math.sin(a)));
  }
  const innerStartDeg = -74.85;
  const innerEndDeg = -285.15;
  for (var i = 0; i <= steps; i++) {
    final deg = innerStartDeg + (innerEndDeg - innerStartDeg) * i / steps;
    final a = deg * math.pi / 180;
    points.add(Offset(0.35 + 0.85 * math.cos(a), 0.85 * math.sin(a)));
  }
  return points;
}

/// Beş köşeli yıldız dış hattı (dış/iç yarıçap sırayla), tepe yukarıda.
List<Offset> _buildStarUnitPoints() {
  const points = 5;
  final pts = <Offset>[];
  const outerR = 1.0, innerR = 0.5;
  for (var i = 0; i <= points * 2; i++) {
    final angle = -math.pi / 2 + i * math.pi / points;
    final r = i.isEven ? outerR : innerR;
    pts.add(Offset(r * math.cos(angle), r * math.sin(angle)));
  }
  return pts;
}

/// Türk bayrağındaki "ay yıldız"ı tek bir sürekli rotada birleştirir: önce
/// hilal, sonra (hilalin açık ağzının içine, sağa ve küçük ölçekte
/// yerleştirilmiş) yıldız. Periyodik gösteri sırasında (bkz. _triggerShow,
/// _buildFlagShowPosFns) her uçak bu hattın kendi payına düşen bir
/// parçasını çizer — hepsi kendi ekran dışı noktasından sıra sıra girer,
/// tek bir ortak başlangıç noktası yoktur. Ham köşeler [_chaikinSmooth] ile
/// hafifçe yumuşatılır — yıldızın uçları tanınabilir kalsın diye sadece 2
/// tekrar (kalp/yazıdan daha az).
List<Offset> _buildFlagUnitPoints() {
  final points = <Offset>[..._buildCrescentUnitPoints()];
  const starScale = 0.45;
  const starOffsetX = 0.85;
  for (final p in _buildStarUnitPoints()) {
    points.add(Offset(starOffsetX + p.dx * starScale, p.dy * starScale));
  }
  return _chaikinSmooth(points, iterations: 2);
}

final _flagUnitPath = _PolylinePath(_buildFlagUnitPoints());

Offset _flagPoint(double t, Offset center, double scale) {
  final local = _flagUnitPath.pointAt(t);
  return center + local * scale;
}

/// Ekran kesri uzayında, görünür alanın hemen dışında (kenarın [margin]
/// kadar ötesinde) rastgele bir nokta — uçaklar ekranın ortasında bir
/// yerde belirmesin, gerçek bir uçuş takip sitesindeki gibi kenardan
/// girip kenardan çıksın diye.
Offset _offscreenPoint(math.Random rnd) {
  const margin = 0.15;
  final along = rnd.nextDouble();
  return switch (rnd.nextInt(4)) {
    0 => Offset(along, -margin), // üst kenarın dışı
    1 => Offset(1 + margin, along), // sağ kenarın dışı
    2 => Offset(along, 1 + margin), // alt kenarın dışı
    _ => Offset(-margin, along), // sol kenarın dışı
  };
}

/// [from] noktasından birim [dir] yönünde ilerleyen bir uçağın,
/// [_offscreenPoint] ile aynı kenar payını (margin) kullanarak ekranın
/// tamamen dışına çıkana kadar alması gereken mesafe — ışın/kutu kesişimi
/// (ekran kesri [-margin, 1+margin] aralığının hangi kenarına önce
/// çarpacağını bulur). Böylece döngüden çıkan uçak, tıpkı düz rotalardaki
/// gibi gerçekten ekranın dışına çıkarak kaybolur.
double _rayExitDistance(Offset from, Offset dir, {double margin = 0.15}) {
  double axisT(double p, double d, double lo, double hi) {
    if (d > 1e-9) return (hi - p) / d;
    if (d < -1e-9) return (lo - p) / d;
    return double.infinity;
  }

  final tx = axisT(from.dx, dir.dx, -margin, 1 + margin);
  final ty = axisT(from.dy, dir.dy, -margin, 1 + margin);
  final t = math.min(tx, ty);
  return t.isFinite && t > 0 ? t : 0.3;
}

/// [_buildArc]'ın sonucu: örneklenmiş yay noktaları (giriş noktası hariç,
/// çıkış noktası dahil) artı çıkıştaki gerçek konum/teğet yön — sonrasına
/// düz bir devam eklenecekse bu ikisi yeterli.
class _ArcResult {
  final List<Offset> points;
  final Offset exitPoint;
  final Offset exitTangent;
  const _ArcResult({required this.points, required this.exitPoint, required this.exitTangent});
}

/// [entryPoint]'ten [entryTangent] yönünde gelen bir uçağın, [radius]
/// yarıçapında ve [sweepFraction] kadar (1.0 = tam tur, 0.5 = yarım, 0.25 =
/// çeyrek) çembersel bir dönüş yapmasını sağlayan noktalar. [side] dönüşün
/// yönünü seçer: +1 girişe göre SOLA, -1 SAĞA kıvrılan bir yay üretir (bu,
/// [entryTangent] ekran kesri uzayında +y aşağı bakacak şekilde
/// hesaplanmıştır — örn. entryTangent=(0,1) iken side=-1 çıkışta tam sağa
/// (1,0) yönlendirir). Giriş açısı her zaman [entryTangent] ile teğet-
/// süreklidir; bu yüzden dönüş öncesi/sonrası hiçbir kırılma olmaz.
_ArcResult _buildArc({
  required Offset entryPoint,
  required Offset entryTangent,
  required double radius,
  required double sweepFraction,
  required double side,
  int steps = 40,
}) {
  final fwd = entryTangent;
  final perp = Offset(-fwd.dy, fwd.dx);
  final center = entryPoint + perp * radius * side;
  final startAngle = (entryPoint - center).direction;
  final sweep = 2 * math.pi * sweepFraction * side;
  final n = math.max(6, (steps * sweepFraction).round());
  final points = <Offset>[];
  var exitPoint = entryPoint;
  for (var i = 1; i <= n; i++) {
    final a = startAngle + sweep * i / n;
    exitPoint = center + Offset(math.cos(a), math.sin(a)) * radius;
    points.add(exitPoint);
  }
  final radial = exitPoint - center;
  final radialLen = radial.distance;
  final radialUnit = radialLen > 0.0001 ? radial / radialLen : fwd;
  final exitTangent = Offset(-radialUnit.dy, radialUnit.dx) * side;
  return _ArcResult(points: points, exitPoint: exitPoint, exitTangent: exitTangent);
}

/// Bazı uçaklar için düz gitmek yerine: düz bir giriş, ardından bir noktada
/// çembersel bir dönüş ([_buildArc]), sonra dönüşün gerçekten bıraktığı
/// yeni yönde düz bir devam — ekran kesri uzayında, tek bir sürekli nokta
/// dizisi olarak.
///
/// [sweepFraction] dönüşün ne kadarının alınacağını belirler. Tam turun
/// girişteki ve çıkıştaki teğet açısı matematiksel olarak birebir aynıdır —
/// yani tam tur uçağın yönünü hiç değiştirmez, sadece dekoratif bir
/// döngüdür. Çeyrek tur yönü tam 90°, yarım tur tam 180° çevirir. Önceki
/// sürüm döngüden sonra bağımsız rastgele bir noktaya yöneliyordu; bu da
/// (özellikle tam turda) döngünün bıraktığı teğetle uyuşmayan, "uçak
/// keskin döndü" hissi veren bir kırılma yaratıyordu — burada çıkış yönü
/// doğrudan döngünün son teğetinden hesaplanıp [_rayExitDistance] ile ekran
/// dışına kadar uzatılır, böylece döngü öncesi/sonrası tüm geçişler teğet-
/// sürekli kalır. Düz-çembere ve çember-düze geçişteki köşeler yine
/// [_chaikinSmooth] ile yumuşatılır.
List<Offset> _buildCurvedRoutePoints(
  Offset start,
  Offset loopEntry,
  math.Random rnd, {
  required double sweepFraction,
}) {
  final points = <Offset>[];
  const straightSteps = 10;
  for (var i = 0; i <= straightSteps; i++) {
    points.add(Offset.lerp(start, loopEntry, i / straightSteps)!);
  }
  final into = loopEntry - start;
  final intoLen = into.distance;
  final fwd = intoLen > 0.0001 ? into / intoLen : const Offset(1, 0);
  final loopRadius = 0.06 + rnd.nextDouble() * 0.05;
  final side = rnd.nextBool() ? 1.0 : -1.0;
  final arc = _buildArc(
    entryPoint: loopEntry,
    entryTangent: fwd,
    radius: loopRadius,
    sweepFraction: sweepFraction,
    side: side,
  );
  points.addAll(arc.points);
  final exitDistance = _rayExitDistance(arc.exitPoint, arc.exitTangent);
  final end = arc.exitPoint + arc.exitTangent * exitDistance;
  for (var i = 1; i <= straightSteps; i++) {
    points.add(Offset.lerp(arc.exitPoint, end, i / straightSteps)!);
  }
  return _chaikinSmooth(points, iterations: 2);
}

/// Periyodik gösterideki (bkz. _triggerShow) bir uçağın paylaşılan [0,1]
/// zaman çizelgesi içindeki kendi giriş/icra/çıkış sınırları.
class _ShowTiming {
  final double approachStart;
  final double approachEnd;
  final double performEnd;
  final double exitEnd;
  const _ShowTiming({
    required this.approachStart,
    required this.approachEnd,
    required this.performEnd,
    required this.exitEnd,
  });
}

/// Gösterideki [count] uçaktan [index]'incisine, hepsinin paylaştığı [0,1]
/// zaman çizelgesi içinde kendi giriş/icra/çıkış aralığını verir. Uçaklar
/// aynı anda değil, index'e göre kademeli olarak girişe başlar — "dışarıdan
/// sıra sıra gelme" etkisi böyle elde edilir. İcra (perform) süresi
/// [performDur] her uçak için AYNIDIR, sadece başlama zamanı kayar; böylece
/// hiçbir uçak diğerinden belirgin şekilde hızlı/yavaş hareket etmez.
_ShowTiming _showTimingFor(int index, int count) {
  const entryDur = 0.14;
  const performDur = 0.45;
  const exitDur = 0.12;
  final spread = (1.0 - entryDur - performDur - exitDur).clamp(0.0, 1.0);
  final gap = count > 1 ? spread / (count - 1) : 0.0;
  final approachStart = gap * index;
  return _ShowTiming(
    approachStart: approachStart,
    approachEnd: approachStart + entryDur,
    performEnd: approachStart + entryDur + performDur,
    exitEnd: approachStart + entryDur + performDur + exitDur,
  );
}

/// [_ShowTiming]'e göre bir uçağın anlık konumu: [timing.approachStart]'a
/// kadar hâlâ ekran dışındaki [entryFrom] noktasında bekler (görünmez),
/// sonra [performPos]'un başına doğru düz uçarak "girer", icra penceresi
/// boyunca [performPos]'u izler, son olarak [performPos]'un sonundan
/// ekran dışındaki [exitTo]'ya doğru düz uçarak "çıkar". Bu, tüm gösteri
/// türlerinin (ay yıldız / kanat açılımı / DNA) ortak iskeletidir —
/// önceki sürümde uçaklar gösteri başlarken doğrudan rotanın üzerine
/// ışınlanıyordu; artık her geçiş ekran dışından gelen/giden düz bir
/// uçuşla yumuşatılır.
Offset _piecewiseShowPos({
  required double t,
  required _ShowTiming timing,
  required Offset entryFrom,
  required Offset Function(double localT) performPos,
  required Offset exitTo,
}) {
  if (t <= timing.approachStart) return entryFrom;
  if (t < timing.approachEnd) {
    final lt = (t - timing.approachStart) / (timing.approachEnd - timing.approachStart);
    return Offset.lerp(entryFrom, performPos(0), lt)!;
  }
  if (t < timing.performEnd) {
    final lt = (t - timing.approachEnd) / (timing.performEnd - timing.approachEnd);
    return performPos(lt);
  }
  if (t < timing.exitEnd) {
    final lt = (t - timing.performEnd) / (timing.exitEnd - timing.performEnd);
    return Offset.lerp(performPos(1), exitTo, lt)!;
  }
  return exitTo;
}

/// Bir gösteri uçağının konum fonksiyonunu ([_PosFn]) kendi [_ShowTiming]'i
/// ile birlikte taşır — [_triggerShow] bunları hem [_PlaneRoute.showPos]
/// hem de izin çizileceği [showTrailStart, showTrailEnd] aralığını
/// belirlemek için kullanır.
class _ShowPlane {
  final _PosFn pos;
  final _ShowTiming timing;
  const _ShowPlane({required this.pos, required this.timing});
}

/// Gösteri türü: "ay yıldız" (Türk bayrağı hattını birlikte çizerler),
/// "kanat açılımı" (yan yana uçup ortada sağa/sola ayrılırlar) veya "DNA"
/// (iki iç içe geçmiş dalga şeridi). Her 10 dakikada bir bunlardan biri
/// rastgele seçilir (bkz. _triggerShow) — böylece gösteri hep aynı
/// olmaz.
enum _ShowKind { flag, wedge, dna }

/// "Ay yıldız" gösterisi: her uçak, hattın kendi payına düşen
/// [flagTStart, flagTEnd] parçasını çizer (bkz. _buildFlagUnitPoints).
List<_ShowPlane> _buildFlagShowPosFns(math.Random rnd, int count) {
  // Bu arka plan tüm ekranların arkasında çalışır; Gökyüzü sekmesindeki
  // saat widget'ı ekranın üst-orta bölgesini (~y 0.2-0.45) kapladığı için
  // merkez o bölgenin altına, alt gezinme çubuğunun üstünde kalan boş
  // alana kaydırılır — bayrak artık saatle çakışıp "arkasında kalmaz".
  final flagCenter = Offset(0.28 + rnd.nextDouble() * 0.3, 0.6 + rnd.nextDouble() * 0.14);
  const flagScale = 0.14;
  return [
    for (var i = 0; i < count; i++) _buildOneFlagPosFn(rnd, i, count, flagCenter, flagScale),
  ];
}

_ShowPlane _buildOneFlagPosFn(
  math.Random rnd,
  int i,
  int count,
  Offset flagCenter,
  double flagScale,
) {
  final timing = _showTimingFor(i, count);
  final tStart = i / count;
  final tEnd = (i + 1) / count;
  final entryFrom = _offscreenPoint(rnd);
  final exitTo = _offscreenPoint(rnd);
  Offset performPos(double lt) {
    final globalT = tStart + lt.clamp(0.0, 1.0) * (tEnd - tStart);
    return _flagPoint(globalT, flagCenter, flagScale);
  }

  return _ShowPlane(
    timing: timing,
    pos: (t) => _piecewiseShowPos(
          t: t,
          timing: timing,
          entryFrom: entryFrom,
          performPos: performPos,
          exitTo: exitTo,
        ),
  );
}

/// "Kanat açılımı" (SoloTürk) gösterisi — herhangi bir uçak sayısı [count]
/// (>= 6) ile çalışır: hepsi yukarıdan yan yana (aynı satırda, farklı
/// x'lerde) süzülerek iner; bir kırılma noktasında MERKEZE en yakın
/// uçak(lar) (tek [count]'ta 1, çift [count]'ta 2 tane) dönüş yapmadan düz
/// yoluna devam eder, geri kalanlar kendi tarafına (soldakiler sola,
/// sağdakiler sağa) çembersel bir dönüş yapar. Dönüş yarıçapı merkeze
/// yakından kenara doğru KÜÇÜLÜR — yani merkeze en yakın dönen uçaklar en
/// geniş çemberi çizer, en dıştakiler daha küçük (ama yine de geniş) bir
/// çember çizer — bkz. [_buildArc]. Sonra hepsi dönüşün bıraktığı yönde
/// ekran dışına çıkar.
List<_ShowPlane> _buildWedgeShowPosFns(math.Random rnd, int count) {
  final centerX = 0.35 + rnd.nextDouble() * 0.3;
  final breakY = 0.28 + rnd.nextDouble() * 0.12;
  final centerIndex = (count - 1) / 2;
  final distances = [for (var i = 0; i < count; i++) (i - centerIndex).abs()];
  final minD = distances.reduce(math.min);
  final turningDistances = distances.where((d) => d - minD > 0.01).toList();
  final turnMinD = turningDistances.isEmpty ? minD : turningDistances.reduce(math.min);
  final turnMaxD = turningDistances.isEmpty ? minD : turningDistances.reduce(math.max);
  return [
    for (var i = 0; i < count; i++)
      _buildOneWedgePosFn(i, count, centerX, breakY, centerIndex, minD, turnMinD, turnMaxD),
  ];
}

_ShowPlane _buildOneWedgePosFn(
  int i,
  int count,
  double centerX,
  double breakY,
  double centerIndex,
  double minD,
  double turnMinD,
  double turnMaxD,
) {
  final timing = _showTimingFor(i, count);
  const laneGap = 0.05;
  final laneOffset = (i - centerIndex) * laneGap;
  final laneX = centerX + laneOffset;
  final formationStart = Offset(laneX, -0.15);
  final breakPoint = Offset(laneX, breakY);
  // Girişi biçim hattıyla aynı x'te, biraz gerisinde tutarak yön kırılması
  // olmadan (teğet-sürekli) satıra "katılmasını" sağlar.
  final entryFrom = Offset(laneX, -0.3);
  const fwd = Offset(0, 1);
  final d = (i - centerIndex).abs();

  if (d - minD < 0.01) {
    // Merkeze en yakın uçak(lar): dönüş yapmadan düz yoluna devam eder.
    final farDist = _rayExitDistance(breakPoint, fwd);
    final farEnd = breakPoint + fwd * farDist;
    return _ShowPlane(
      timing: timing,
      pos: (t) => _piecewiseShowPos(
            t: t,
            timing: timing,
            entryFrom: entryFrom,
            performPos: (lt) => Offset.lerp(formationStart, farEnd, lt)!,
            exitTo: farEnd,
          ),
    );
  }

  final isRight = laneOffset > 0;
  final side = isRight ? -1.0 : 1.0; // -1 sağa, +1 sola kıvrılır (bkz. _buildArc)
  final turnSpan = (turnMaxD - turnMinD).abs() > 0.01 ? (turnMaxD - turnMinD) : 1.0;
  // 0 = merkeze en yakın dönen uçak (en geniş çember), 1 = en dıştaki (daha dar).
  final tOutward = ((d - turnMinD) / turnSpan).clamp(0.0, 1.0);
  const radiusNear = 0.22;
  const radiusFar = 0.14;
  const sweepNear = 0.85;
  const sweepFar = 0.75;
  final radius = radiusNear + (radiusFar - radiusNear) * tOutward;
  final sweepFraction = sweepNear + (sweepFar - sweepNear) * tOutward;
  final arc = _buildArc(
    entryPoint: breakPoint,
    entryTangent: fwd,
    radius: radius,
    sweepFraction: sweepFraction,
    side: side,
  );
  final exitDist = _rayExitDistance(arc.exitPoint, arc.exitTangent);
  final farEnd = arc.exitPoint + arc.exitTangent * exitDist;
  final path = _PolylinePath(
    _chaikinSmooth([formationStart, breakPoint, ...arc.points, farEnd], iterations: 2),
  );

  return _ShowPlane(
    timing: timing,
    pos: (t) => _piecewiseShowPos(
          t: t,
          timing: timing,
          entryFrom: entryFrom,
          performPos: (lt) => path.pointAt(lt),
          exitTo: farEnd,
        ),
  );
}

/// "DNA" gösterisi: uçaklar iki gruba ayrılır (çift/tek index), her grup
/// ekranı yatay olarak baştan sona geçen bir sinüs dalgası izler; iki
/// grubun dalgaları birbirinin aynası (180° faz farkı) olduğu için iki
/// şerit birbirine sarmalanmış bir DNA sarmalı gibi görünür. Aynı gruptaki
/// uçaklar dalga boyunca eşit aralıklarla dizilir (faz kayması ile),
/// böylece o an tek bir noktada üst üste binmezler. Uçak sayısı tek ise
/// (örn. 5) iki şerit eşit büyüklükte olmaz — her uçağın faz hesabı kendi
/// şeridinin GERÇEK boyutunu kullanır (bkz. [strandACount]/[strandBCount]),
/// aksi halde eşit olmayan şeritlerde fazlar birbirine çakışırdı.
List<_ShowPlane> _buildDnaShowPosFns(math.Random rnd, int count) {
  // Tamamen rastgele dikey konum — ay yıldızla artık aynı anda değil,
  // sırayla (birer birer) çalıştığı için sabit bir bölgeye hapsedilmesine
  // gerek yok (bkz. _triggerShow).
  final centerY = 0.32 + rnd.nextDouble() * 0.3;
  const amplitude = 0.09;
  const cycles = 1.6;
  final strandACount = count - count ~/ 2;
  final strandBCount = count ~/ 2;
  return [
    for (var i = 0; i < count; i++)
      _buildOneDnaPosFn(i, count, centerY, amplitude, cycles, strandACount, strandBCount),
  ];
}

_ShowPlane _buildOneDnaPosFn(
  int i,
  int count,
  double centerY,
  double amplitude,
  double cycles,
  int strandACount,
  int strandBCount,
) {
  final timing = _showTimingFor(i, count);
  final strandSign = i.isEven ? 1.0 : -1.0;
  final withinStrand = i ~/ 2;
  final perStrand = i.isEven ? strandACount : strandBCount;
  final phaseX = perStrand > 0 ? withinStrand / perStrand / cycles : 0.0;

  double yAt(double x) =>
      centerY + strandSign * amplitude * math.sin(2 * math.pi * cycles * (x - phaseX));

  const xStart = -0.12;
  const xEnd = 1.12;
  final entryFrom = Offset(xStart - 0.15, yAt(xStart));
  final exitTo = Offset(xEnd + 0.15, yAt(xEnd));

  Offset performPos(double lt) {
    final x = xStart + lt.clamp(0.0, 1.0) * (xEnd - xStart);
    return Offset(x, yAt(x));
  }

  return _ShowPlane(
    timing: timing,
    pos: (t) => _piecewiseShowPos(
          t: t,
          timing: timing,
          entryFrom: entryFrom,
          performPos: performPos,
          exitTo: exitTo,
        ),
  );
}

class _FlightTrailsBackgroundState extends State<FlightTrailsBackground>
    with TickerProviderStateMixin {
  final _rnd = math.Random();
  late final List<_PlaneRoute> _routes;
  late final List<AnimationController> _controllers;
  Timer? _showTimer;
  _ShowKind? _lastShowKind;

  @override
  void initState() {
    super.initState();
    _routes = List.generate(6, (_) => _randomRoute());
    _controllers = [
      for (var i = 0; i < _routes.length; i++) _makeController(i, startNow: true),
    ];
    _scheduleNextShow();
  }

  /// Günün her saatinde, her 10 dakikada bir (:00, :10, :20, ...) SoloTürk
  /// gösterisi gibi rastgele bir görsel şölen tetikler — bkz. [_triggerShow].
  /// Süresi dolan uçak zaten [_makeController] içindeki dinleyici sayesinde
  /// normal rastgele rotaya döner, bu yüzden gösteri sonrası ekstra bir
  /// temizliğe gerek yoktur.
  void _scheduleNextShow() {
    final now = DateTime.now();
    final nextTenMinute = ((now.minute ~/ 10) + 1) * 10;
    final next = nextTenMinute >= 60
        ? DateTime(now.year, now.month, now.day, now.hour + 1)
        : DateTime(now.year, now.month, now.day, now.hour, nextTenMinute);
    _showTimer = Timer(next.difference(now), _triggerShow);
  }

  /// Her seferinde [_enabledShowKinds]'ten TEK bir tür rastgele seçilir —
  /// bir önceki gösteriyle AYNI tür arka arkaya iki kez gelmez (bkz.
  /// [_lastShowKind]). DNA'nın konumu tamamen rastgele (bkz.
  /// _buildDnaShowPosFns); ay yıldız ekranın alt-orta bölgesinde kalır
  /// (bkz. _buildFlagShowPosFns) ki Gökyüzü sekmesindeki saatle çakışmasın.
  /// Katılımcı sayısı ekrandaki TÜM uçaklar (`_routes.length`, en az 6) —
  /// hiçbiri dışarıda bırakılmaz. [_ShowKind.wedge] (kanat açılımı)
  /// kullanıcı isteğiyle geçici olarak devre dışı — kodu silinmedi, tekrar
  /// açmak için bu listeye eklemek yeterli. Her uçağın konumu
  /// [_showTimingFor] ile kademeli (sıra sıra) bir giriş + ortak icra +
  /// çıkış içeren TEK bir fonksiyona (bkz. [_ShowPlane]) bağlanır — önceki
  /// sürümde uçaklar gösteri başlarken bulundukları yerden doğrudan
  /// rotanın üzerine ışınlanıyordu; artık hepsi ekran dışından uçarak
  /// "girer". İz de sadece icra aralığında ([_ShowTiming.approachEnd]..
  /// [_ShowTiming.performEnd]) çizilir (bkz. [_PlaneRoute.showTrailStart]/
  /// [showTrailEnd], [_ShowTrailPainter]) — giriş/çıkış uçuşları iz
  /// bırakmaz.
  static const _enabledShowKinds = [_ShowKind.flag, _ShowKind.dna];

  void _triggerShow() {
    if (!mounted) return;
    const showDurationSeconds = 28;
    final segmentCount = _routes.length;
    final options = _enabledShowKinds.where((k) => k != _lastShowKind).toList();
    final kind = options[_rnd.nextInt(options.length)];
    _lastShowKind = kind;
    debugPrint('[gösteri] $kind tetiklendi (${DateTime.now()})');
    final planes = switch (kind) {
      _ShowKind.flag => _buildFlagShowPosFns(_rnd, segmentCount),
      _ShowKind.wedge => _buildWedgeShowPosFns(_rnd, segmentCount),
      _ShowKind.dna => _buildDnaShowPosFns(_rnd, segmentCount),
    };
    setState(() {
      for (var i = 0; i < segmentCount; i++) {
        _routes[i] = _PlaneRoute(
          kind: _routes[i].kind,
          size: _routes[i].size,
          durationSeconds: showDurationSeconds,
          mode: _RouteMode.show,
          showPos: planes[i].pos,
          showTrailStart: planes[i].timing.approachEnd,
          showTrailEnd: planes[i].timing.performEnd,
        );
        _controllers[i].duration = const Duration(seconds: showDurationSeconds);
        _controllers[i].forward(from: 0);
      }
    });
    _scheduleNextShow();
  }

  /// Bir uçuş bitince (AnimationStatus.completed) o uçak için tamamen
  /// yeni, rastgele bir rota üretip baştan başlatır — böylece her uçuş
  /// bir öncekinden bağımsız, gerçekten tahmin edilemez bir yolculuk olur.
  AnimationController _makeController(int index, {required bool startNow}) {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _routes[index].durationSeconds),
    );
    controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      setState(() => _routes[index] = _randomRoute());
      controller.duration = Duration(seconds: _routes[index].durationSeconds);
      controller.forward(from: 0);
    });
    if (startNow) controller.forward(from: 0);
    return controller;
  }

  _PlaneRoute _randomRoute() {
    final kind = _PlaneKind.values[_rnd.nextInt(_PlaneKind.values.length)];
    // A380 ve Concorde, Cessna'dan belirgin şekilde daha büyük görünsün diye
    // Cessna küçültülür — üst sınır (mevcut en büyük boyut) değişmez, sadece
    // Cessna o aralığın altına iner.
    final baseSize = 9 + _rnd.nextDouble() * 8;
    final size = kind == _PlaneKind.cessna ? baseSize * 0.62 : baseSize;
    // Tüm uygulamada sürekli görünecekleri için ders/tekrar ekranlarında
    // dikkat dağıtmasın diye önceki tek-ekranlı sürümden daha yavaşlar.
    final durationSeconds = 14 + _rnd.nextInt(13);
    final isPink = AppColors.variant == AppThemeVariant.pink;

    // Tatlış Pembe temasında uçaklar çoğunlukla bir kalp (♥) çizer —
    // geri kalanında düz bir rotada uçar.
    final roll = _rnd.nextDouble();
    if (isPink ? roll < 0.65 : false) {
      return _PlaneRoute(
        kind: kind,
        size: size,
        durationSeconds: durationSeconds + 4, // kalbi çizmek biraz daha uzun sürsün
        mode: _RouteMode.heart,
        heartCenter: Offset(0.15 + _rnd.nextDouble() * 0.7, 0.18 + _rnd.nextDouble() * 0.64),
        heartScale: 0.08 + _rnd.nextDouble() * 0.06,
      );
    }

    late Offset start, end;
    do {
      start = _offscreenPoint(_rnd);
      end = _offscreenPoint(_rnd);
    } while ((end - start).distance < 0.5);

    // Uçakların bir kısmı (tamamı değil) düz gitmek yerine yolun bir
    // noktasında çembersel bir dönüş yapıp döngünün bıraktığı yeni yönde
    // devam eder — hepsi aynı düz güzergahı izlemesin diye. Dönüş miktarı
    // (çeyrek/yarım/tam tur) her seferinde rastgele seçilir, böylece üç
    // türü de yapan uçaklar birlikte görülür (bkz. _buildCurvedRoutePoints).
    if (_rnd.nextDouble() < 0.3) {
      final loopEntry = Offset(0.2 + _rnd.nextDouble() * 0.6, 0.2 + _rnd.nextDouble() * 0.6);
      const sweepOptions = [0.25, 0.5, 1.0];
      final sweepFraction = sweepOptions[_rnd.nextInt(sweepOptions.length)];
      return _PlaneRoute(
        kind: kind,
        size: size,
        // Dönüş ne kadar büyükse gösteri o kadar uzun sürsün.
        durationSeconds: durationSeconds + math.max(2, (sweepFraction * 6).round()),
        mode: _RouteMode.curved,
        curvedPath: _PolylinePath(
          _buildCurvedRoutePoints(start, loopEntry, _rnd, sweepFraction: sweepFraction),
        ),
      );
    }

    return _PlaneRoute(
      kind: kind,
      size: size,
      durationSeconds: durationSeconds,
      start: start,
      end: end,
    );
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Seçili renk temasına göre değişir (bkz. AppColors) — uçaklar ve
    // izleri her temada o temanın kendi vurgu rengini kullanır. Tüm
    // ekranların arkasında göründükleri için metin/butonlarla çakışınca
    // okunabilirliği bozmasın diye oldukça soluklar. Tatlış Pembe'de izler
    // gövdeyle aynı tondaki pembe arka planda kaybolduğu için accent
    // (mor) rengiyle, daha belirgin şekilde çizilir.
    final isPink = AppColors.variant == AppThemeVariant.pink;
    final planeColor = AppColors.primary.withValues(alpha: 0.38);
    final trailColor = isPink
        ? AppColors.accent.withValues(alpha: 0.5)
        : AppColors.primary.withValues(alpha: 0.16);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return AnimatedBuilder(
          animation: Listenable.merge(_controllers),
          builder: (context, _) {
            return Stack(
              children: [
                for (var i = 0; i < _routes.length; i++)
                  ..._buildPlane(_routes[i], _controllers[i].value, size, trailColor, planeColor),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPlane(
    _PlaneRoute route,
    double t,
    Size size,
    Color trailColor,
    Color planeColor,
  ) {
    late final Offset pos;
    late final double angle;
    late final CustomPainter trailPainter;

    switch (route.mode) {
      case _RouteMode.heart:
        final center = Offset(route.heartCenter.dx * size.width, route.heartCenter.dy * size.height);
        final scalePx = route.heartScale * math.min(size.width, size.height);
        pos = _heartPoint(t, center, scalePx);
        angle = _heartAngle(t, center, scalePx);
        trailPainter = _HeartTrailPainter(center: center, scale: scalePx, currentT: t, color: trailColor);
      case _RouteMode.show:
        final fn = route.showPos!;
        final local = fn(t);
        pos = Offset(local.dx * size.width, local.dy * size.height);
        const eps = 0.006;
        final l1 = fn((t - eps).clamp(0.0, 1.0));
        final l2 = fn((t + eps).clamp(0.0, 1.0));
        final p1 = Offset(l1.dx * size.width, l1.dy * size.height);
        final p2 = Offset(l2.dx * size.width, l2.dy * size.height);
        angle = (p2 - p1).direction;
        trailPainter = _ShowTrailPainter(
          posFn: fn,
          currentT: t,
          trailStart: route.showTrailStart,
          trailEnd: route.showTrailEnd,
          color: trailColor,
        );
      case _RouteMode.curved:
        final path = route.curvedPath!;
        final local = path.pointAt(t);
        pos = Offset(local.dx * size.width, local.dy * size.height);
        const eps = 0.006;
        final l1 = path.pointAt((t - eps).clamp(0.0, 1.0));
        final l2 = path.pointAt((t + eps).clamp(0.0, 1.0));
        final p1 = Offset(l1.dx * size.width, l1.dy * size.height);
        final p2 = Offset(l2.dx * size.width, l2.dy * size.height);
        angle = (p2 - p1).direction;
        trailPainter = _CurvedTrailPainter(path: path, currentT: t, color: trailColor);
      case _RouteMode.line:
        final start = Offset(route.start.dx * size.width, route.start.dy * size.height);
        final end = Offset(route.end.dx * size.width, route.end.dy * size.height);
        pos = Offset.lerp(start, end, t)!;
        angle = (end - start).direction;
        trailPainter = _TrailPainter(start: start, current: pos, color: trailColor);
    }

    final dispWidth = route.size * 2;
    final dispHeight = dispWidth * _planeAspect(route.kind);

    return [
      CustomPaint(size: size, painter: trailPainter),
      Positioned(
        left: pos.dx - dispWidth / 2,
        top: pos.dy - dispHeight / 2,
        child: Transform.rotate(
          angle: angle,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(planeColor, BlendMode.srcIn),
            child: Image.asset(
              _planeAsset(route.kind),
              width: dispWidth,
              height: dispHeight,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    ];
  }
}

/// Kullanıcının sağladığı gerçek uçak görselinden (Concorde/A380/Cessna)
/// kırpılıp burun +x eksenine (sağa) bakacak şekilde hizalanmış, arka planı
/// şeffaflaştırılmış PNG asset'leri — bkz. assets/images/planes/. Sadece
/// alfa kanalları kullanılır: [ColorFilter.mode]/[BlendMode.srcIn] ile
/// seçili temanın rengine boyanırlar (bkz. build), böylece her temada aynı
/// soluk/tutarlı görünümü korurlar.
String _planeAsset(_PlaneKind kind) {
  switch (kind) {
    case _PlaneKind.concorde:
      return 'assets/images/planes/concorde.png';
    case _PlaneKind.a380:
      return 'assets/images/planes/a380.png';
    case _PlaneKind.cessna:
      return 'assets/images/planes/cessna.png';
  }
}

/// Asset'in orijinal piksel oranı (height/width) — [route.size]'a göre
/// doğru en-boy oranıyla ölçeklenebilsin diye.
double _planeAspect(_PlaneKind kind) {
  switch (kind) {
    case _PlaneKind.concorde:
      return 85 / 202;
    case _PlaneKind.a380:
      return 168 / 187;
    case _PlaneKind.cessna:
      return 136 / 121;
  }
}

class _TrailPainter extends CustomPainter {
  final Offset start;
  final Offset current;
  final Color color;
  const _TrailPainter({required this.start, required this.current, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final total = (current - start).distance;
    if (total < 1) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const dashLen = 4.0;
    const gapLen = 4.0;
    final dir = (current - start) / total;
    var drawn = 0.0;
    while (drawn < total) {
      final segStart = start + dir * drawn;
      final segEnd = start + dir * math.min(drawn + dashLen, total);
      canvas.drawLine(segStart, segEnd, paint);
      drawn += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) =>
      oldDelegate.current != current || oldDelegate.color != color;
}

/// Tatlış Pembe temasında düz iz yerine kalbin o ana kadar çizilmiş
/// kısmını kesikli çizgiyle gösterir.
class _HeartTrailPainter extends CustomPainter {
  final Offset center;
  final double scale;
  final double currentT;
  final Color color;
  const _HeartTrailPainter({
    required this.center,
    required this.scale,
    required this.currentT,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (currentT <= 0.001) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const steps = 120;
    final maxStep = (steps * currentT).floor();
    Offset? prev;
    var drawing = true;
    for (var i = 0; i <= maxStep; i++) {
      final p = _heartPoint(i / steps, center, scale);
      if (prev != null && drawing) {
        canvas.drawLine(prev, p, paint);
      }
      if (i % 3 == 0) drawing = !drawing;
      prev = p;
    }
  }

  @override
  bool shouldRepaint(covariant _HeartTrailPainter oldDelegate) =>
      oldDelegate.currentT != currentT ||
      oldDelegate.color != color ||
      oldDelegate.center != center;
}

/// Periyodik gösterideki bir uçağın SADECE icra aralığında ([trailStart]..
/// [trailEnd]) aldığı yolu düz, kalın bir gösteri/duman izi olarak çizer
/// (kesikli değil) — bkz. [_piecewiseShowPos]. Giriş ve çıkış uçuşları
/// (ekran dışından gelen/giden düz parçalar) kasıtlı olarak İZ BIRAKMAZ —
/// aksi halde örn. ay yıldız gösterisinde her uçağın kendi rastgele
/// giriş/çıkış çizgisi şeklin etrafında karmaşa yaratır, tam bayrak
/// görünmez olurdu.
class _ShowTrailPainter extends CustomPainter {
  final _PosFn posFn;
  final double currentT;
  final double trailStart;
  final double trailEnd;
  final Color color;
  const _ShowTrailPainter({
    required this.posFn,
    required this.currentT,
    required this.trailStart,
    required this.trailEnd,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawEnd = math.min(currentT, trailEnd);
    if (drawEnd - trailStart <= 0.001) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    const steps = 260;
    final startStep = (steps * trailStart).floor();
    final maxStep = (steps * drawEnd).ceil();
    if (maxStep <= startStep) return;

    final pts = <Offset>[
      for (var i = startStep; i <= maxStep; i++) _scaledPos(i / steps, size),
    ];
    if (pts.length < 2) return;

    // Bazı şekiller (örn. ay yıldız: hilal + yıldız) altta yatan noktalar
    // dizisinde birbirine görsel olarak BAĞLI olmayan iki ayrı parça
    // içerir — aradaki "dikiş" tek bir çok uzun düz sıçrama olarak
    // örneklenir. Ardışık noktalar arasındaki tipik (medyan) adımdan çok
    // daha uzun olan segmentleri "kalem kalktı" sayıp çizmeyerek bu
    // sahte bağlantı çizgisini gizleriz.
    final dists = [for (var i = 1; i < pts.length; i++) (pts[i] - pts[i - 1]).distance];
    final sorted = [...dists]..sort();
    final median = sorted[sorted.length ~/ 2];
    final jumpThreshold = math.max(median * 6, 3.0);

    for (var i = 1; i < pts.length; i++) {
      if (dists[i - 1] <= jumpThreshold) {
        canvas.drawLine(pts[i - 1], pts[i], paint);
      }
    }
  }

  Offset _scaledPos(double t, Size size) {
    final local = posFn(t);
    return Offset(local.dx * size.width, local.dy * size.height);
  }

  @override
  bool shouldRepaint(covariant _ShowTrailPainter oldDelegate) =>
      oldDelegate.currentT != currentT ||
      oldDelegate.color != color ||
      oldDelegate.trailStart != trailStart ||
      oldDelegate.trailEnd != trailEnd;
}

/// Eğrisel/çembersel rota modundaki uçağın o ana kadar aldığı yolu,
/// düz mod ile aynı kesikli iz üslubuyla gösterir.
class _CurvedTrailPainter extends CustomPainter {
  final _PolylinePath path;
  final double currentT;
  final Color color;
  const _CurvedTrailPainter({required this.path, required this.currentT, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (currentT <= 0.001) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const steps = 160;
    final maxStep = (steps * currentT).floor();
    Offset? prev;
    var drawing = true;
    for (var i = 0; i <= maxStep; i++) {
      final local = path.pointAt(i / steps);
      final p = Offset(local.dx * size.width, local.dy * size.height);
      if (prev != null && drawing) {
        canvas.drawLine(prev, p, paint);
      }
      if (i % 3 == 0) drawing = !drawing;
      prev = p;
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedTrailPainter oldDelegate) =>
      oldDelegate.currentT != currentT || oldDelegate.color != color;
}
