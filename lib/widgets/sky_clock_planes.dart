import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum _ClockPlaneKind { concorde, a380, cessna }

String _clockPlaneAsset(_ClockPlaneKind kind) {
  switch (kind) {
    case _ClockPlaneKind.concorde:
      return 'assets/images/planes/concorde.png';
    case _ClockPlaneKind.a380:
      return 'assets/images/planes/a380.png';
    case _ClockPlaneKind.cessna:
      return 'assets/images/planes/cessna.png';
  }
}

double _clockPlaneAspect(_ClockPlaneKind kind) {
  switch (kind) {
    case _ClockPlaneKind.concorde:
      return 85 / 202;
    case _ClockPlaneKind.a380:
      return 168 / 187;
    case _ClockPlaneKind.cessna:
      return 136 / 121;
  }
}

/// Rakamlar, kullanıcının referans aldığı gerçek "double-struck" (𝟙𝟚𝟛…)
/// karakterlerinin (Cambria Math fontu, Unicode Mathematical Alphanumeric
/// Symbols bloğu, U+1D7D8–U+1D7E1) GERÇEK glif dış hatlarından çıkarıldı —
/// kendi elimle tasarlamak yerine PowerShell + System.Drawing
/// (GraphicsPath.AddString) ile her karakterin vektör konturunu çıkardım.
/// 0/6/8/9'un gerçek iç yuvarlak deliği (kontur alanı + yatay merkezleme
/// ile gövde konturundan ayırt edilip) dış kontura, en yakın noktasından
/// kısa bir bağlantı ile eklendi — 8'de iki delik var (üst+alt). Diğer
/// rakamların ikincil konturları (double-struck fontun karakteristik ince
/// "çift çizgi" süslemesi) yuvarlak bir delik olmadığı için eklenmedi. Yay
/// uzunluğuna göre yeniden örneklenip normalize edildi — bkz. extract_v2.ps1
/// / v2_digits_grid.png / v2_layout_preview.png. Her rakam kapalı, tek bir
/// kesintisiz döngü. Rakamlar birbirine BAĞLANMAZ — her biri kendi başına,
/// ayrı bir uçak tarafından çizilir (bkz. SkyClockPlanes) çünkü rakamlar
/// arası bağlantı çizgileri okunabilirliği ciddi şekilde bozuyordu.
const _kClockDigitFont = <String, List<Offset>>{
  '0': [
    Offset(0.4955, 1), Offset(0.4349, 0.997), Offset(0.3751, 0.9866),
    Offset(0.3176, 0.9674), Offset(0.264, 0.9393), Offset(0.2177, 0.9002),
    Offset(0.1804, 0.8525), Offset(0.1514, 0.7993), Offset(0.1303, 0.7425),
    Offset(0.1162, 0.6835), Offset(0.1073, 0.6235), Offset(0.1029, 0.563),
    Offset(0.1019, 0.5023), Offset(0.1043, 0.4417), Offset(0.111, 0.3814),
    Offset(0.1221, 0.3218), Offset(0.1387, 0.2635), Offset(0.1609, 0.2071),
    Offset(0.1911, 0.1545), Offset(0.2295, 0.1077), Offset(0.2755, 0.0683),
    Offset(0.328, 0.038), Offset(0.3847, 0.0166), Offset(0.444, 0.0043),
    Offset(0.5045, 0.0001), Offset(0.5651, 0.003), Offset(0.6249, 0.0131),
    Offset(0.6825, 0.0318), Offset(0.7354, 0.0612), Offset(0.7817, 0.1002),
    Offset(0.8194, 0.1476), Offset(0.848, 0.201), Offset(0.8689, 0.2579),
    Offset(0.8833, 0.3168), Offset(0.8925, 0.3768), Offset(0.897, 0.4373),
    Offset(0.8981, 0.4979), Offset(0.8958, 0.5586), Offset(0.8891, 0.6188),
    Offset(0.878, 0.6784), Offset(0.8613, 0.7367), Offset(0.8389, 0.793),
    Offset(0.8086, 0.8455), Offset(0.7703, 0.8925), Offset(0.7244, 0.9319),
    Offset(0.672, 0.9624), Offset(0.6153, 0.9839), Offset(0.556, 0.9963),
    Offset(0.4955, 1), Offset(0.5018, 0.9162), Offset(0.56, 0.8731),
    Offset(0.5855, 0.8016), Offset(0.5987, 0.7266), Offset(0.6058, 0.6507),
    Offset(0.6089, 0.5745), Offset(0.6097, 0.4983), Offset(0.6084, 0.4221),
    Offset(0.6048, 0.346), Offset(0.5977, 0.2701), Offset(0.5846, 0.1951),
    Offset(0.5578, 0.1241), Offset(0.4971, 0.0837), Offset(0.4383, 0.1255),
    Offset(0.4133, 0.1972), Offset(0.4006, 0.2723), Offset(0.3939, 0.3482),
    Offset(0.3909, 0.4244), Offset(0.3903, 0.5006), Offset(0.3916, 0.5768),
    Offset(0.3952, 0.6529), Offset(0.4024, 0.7288), Offset(0.4157, 0.8038),
    Offset(0.4419, 0.8751), Offset(0.5018, 0.9162),
  ],
  '1': [
    Offset(0.667, 0.819), Offset(0.6733, 0.8868), Offset(0.7142, 0.9382),
    Offset(0.7807, 0.9527), Offset(0.8038, 0.9999), Offset(0.7356, 1),
    Offset(0.6674, 1), Offset(0.5992, 1), Offset(0.5309, 1),
    Offset(0.4627, 1), Offset(0.3945, 1), Offset(0.3262, 1),
    Offset(0.258, 1), Offset(0.2648, 0.9533), Offset(0.3314, 0.9396),
    Offset(0.3776, 0.8927), Offset(0.3865, 0.8253), Offset(0.3867, 0.7571),
    Offset(0.3867, 0.6888), Offset(0.3867, 0.6206), Offset(0.3867, 0.5524),
    Offset(0.3867, 0.4841), Offset(0.3867, 0.4159), Offset(0.3867, 0.3477),
    Offset(0.3867, 0.2794), Offset(0.3655, 0.218), Offset(0.3002, 0.2278),
    Offset(0.2421, 0.2634), Offset(0.2021, 0.2254), Offset(0.2451, 0.1867),
    Offset(0.3038, 0.1518), Offset(0.3624, 0.117), Offset(0.4211, 0.0821),
    Offset(0.4797, 0.0472), Offset(0.5384, 0.0123), Offset(0.6032, 0),
    Offset(0.6711, 0.0003), Offset(0.6682, 0.0684), Offset(0.6672, 0.1366),
    Offset(0.667, 0.2049), Offset(0.667, 0.2731), Offset(0.667, 0.3413),
    Offset(0.667, 0.4096), Offset(0.667, 0.4778), Offset(0.667, 0.546),
    Offset(0.667, 0.6143), Offset(0.667, 0.6825), Offset(0.667, 0.7507),
    Offset(0.667, 0.819),
  ],
  '2': [
    Offset(0.6571, 0.7647), Offset(0.7501, 0.7484), Offset(0.7971, 0.6691),
    Offset(0.8549, 0.7047), Offset(0.849, 0.8003), Offset(0.8432, 0.8958),
    Offset(0.8373, 0.9914), Offset(0.7496, 1), Offset(0.6539, 1),
    Offset(0.5582, 1), Offset(0.4625, 1), Offset(0.3667, 1),
    Offset(0.271, 1), Offset(0.1753, 1), Offset(0.1492, 0.9379),
    Offset(0.1947, 0.8537), Offset(0.248, 0.7743), Offset(0.3044, 0.697),
    Offset(0.364, 0.6221), Offset(0.4242, 0.5476), Offset(0.4803, 0.4701),
    Offset(0.5263, 0.3863), Offset(0.5514, 0.2943), Offset(0.5481, 0.1991),
    Offset(0.5068, 0.1144), Offset(0.4211, 0.0787), Offset(0.3324, 0.109),
    Offset(0.2785, 0.1868), Offset(0.2165, 0.2344), Offset(0.1641, 0.1911),
    Offset(0.1641, 0.0954), Offset(0.2374, 0.0501), Offset(0.3289, 0.0221),
    Offset(0.4231, 0.0058), Offset(0.5186, 0.0002), Offset(0.614, 0.0066),
    Offset(0.7059, 0.0325), Offset(0.7842, 0.0864), Offset(0.8324, 0.168),
    Offset(0.8441, 0.2624), Offset(0.8235, 0.3554), Offset(0.7752, 0.4377),
    Offset(0.7124, 0.5098), Offset(0.6433, 0.5761), Offset(0.5724, 0.6404),
    Offset(0.5023, 0.7056), Offset(0.4657, 0.7647), Offset(0.5614, 0.7647),
    Offset(0.6571, 0.7647),
  ],
  '3': [
    Offset(0.1582, 0.0759), Offset(0.2482, 0.0428), Offset(0.3405, 0.0168),
    Offset(0.4354, 0.0032), Offset(0.5313, 0.0008), Offset(0.6266, 0.0105),
    Offset(0.7172, 0.0409), Offset(0.7914, 0.1001), Offset(0.8291, 0.1872),
    Offset(0.8281, 0.2825), Offset(0.7899, 0.3693), Offset(0.7196, 0.434),
    Offset(0.7234, 0.4825), Offset(0.7983, 0.5416), Offset(0.8446, 0.6247),
    Offset(0.8545, 0.7197), Offset(0.8367, 0.8135), Offset(0.7873, 0.8949),
    Offset(0.7104, 0.9514), Offset(0.6207, 0.9844), Offset(0.5259, 0.9982),
    Offset(0.43, 0.999), Offset(0.3344, 0.9913), Offset(0.2399, 0.975),
    Offset(0.1478, 0.9485), Offset(0.1447, 0.8548), Offset(0.1718, 0.7859),
    Offset(0.2507, 0.8106), Offset(0.3033, 0.8898), Offset(0.3908, 0.9244),
    Offset(0.4838, 0.9077), Offset(0.547, 0.8383), Offset(0.5664, 0.7451),
    Offset(0.5552, 0.6503), Offset(0.5014, 0.573), Offset(0.4134, 0.5371),
    Offset(0.3184, 0.5304), Offset(0.3345, 0.4476), Offset(0.4264, 0.4207),
    Offset(0.503, 0.3647), Offset(0.5409, 0.2779), Offset(0.5397, 0.1825),
    Offset(0.4915, 0.1018), Offset(0.4006, 0.079), Offset(0.3146, 0.1164),
    Offset(0.2657, 0.1982), Offset(0.1942, 0.2317), Offset(0.1582, 0.1718),
    Offset(0.1582, 0.0759),
  ],
  '4': [
    Offset(0.7338, 0.8169), Offset(0.738, 0.8944), Offset(0.7834, 0.9521),
    Offset(0.8159, 1), Offset(0.7382, 1), Offset(0.6605, 1),
    Offset(0.5828, 1), Offset(0.5051, 1), Offset(0.4274, 1),
    Offset(0.3653, 0.9844), Offset(0.4185, 0.9437), Offset(0.4489, 0.8752),
    Offset(0.4511, 0.7976), Offset(0.4511, 0.7199), Offset(0.3878, 0.7055),
    Offset(0.3101, 0.7055), Offset(0.2324, 0.7055), Offset(0.1547, 0.7055),
    Offset(0.0876, 0.6949), Offset(0.1001, 0.6209), Offset(0.1433, 0.5563),
    Offset(0.1864, 0.4917), Offset(0.2295, 0.4271), Offset(0.2727, 0.3625),
    Offset(0.3158, 0.2978), Offset(0.3589, 0.2332), Offset(0.4021, 0.1686),
    Offset(0.4452, 0.104), Offset(0.4884, 0.0393), Offset(0.545, 0),
    Offset(0.6227, 0), Offset(0.7004, 0), Offset(0.7338, 0.0444),
    Offset(0.7338, 0.1221), Offset(0.7338, 0.1998), Offset(0.7338, 0.2774),
    Offset(0.7338, 0.3551), Offset(0.7338, 0.4328), Offset(0.7338, 0.5105),
    Offset(0.7338, 0.5882), Offset(0.7769, 0.6219), Offset(0.8407, 0.5852),
    Offset(0.8895, 0.5437), Offset(0.9094, 0.5984), Offset(0.9052, 0.676),
    Offset(0.8555, 0.7055), Offset(0.7778, 0.7055), Offset(0.7338, 0.7392),
    Offset(0.7338, 0.8169),
  ],
  '5': [
    Offset(0.6744, 0.0456), Offset(0.7512, 0), Offset(0.7896, 0.058),
    Offset(0.7832, 0.1581), Offset(0.7768, 0.2582), Offset(0.688, 0.2704),
    Offset(0.5877, 0.2704), Offset(0.4874, 0.2704), Offset(0.3871, 0.2704),
    Offset(0.3041, 0.2876), Offset(0.3041, 0.3878), Offset(0.315, 0.4738),
    Offset(0.4132, 0.4542), Offset(0.5133, 0.4486), Offset(0.6129, 0.4581),
    Offset(0.7072, 0.491), Offset(0.7839, 0.5541), Offset(0.8269, 0.6438),
    Offset(0.8342, 0.7434), Offset(0.81, 0.8401), Offset(0.749, 0.9186),
    Offset(0.6623, 0.9679), Offset(0.5653, 0.9922), Offset(0.4654, 0.9998),
    Offset(0.3653, 0.9953), Offset(0.2663, 0.9796), Offset(0.1702, 0.9513),
    Offset(0.1645, 0.855), Offset(0.1988, 0.7891), Offset(0.2704, 0.8283),
    Offset(0.3296, 0.9071), Offset(0.4261, 0.9272), Offset(0.512, 0.8815),
    Offset(0.5511, 0.7906), Offset(0.5545, 0.6908), Offset(0.5217, 0.5973),
    Offset(0.4398, 0.5441), Offset(0.34, 0.544), Offset(0.2452, 0.5532),
    Offset(0.2027, 0.4764), Offset(0.2027, 0.3762), Offset(0.2027, 0.2759),
    Offset(0.2027, 0.1756), Offset(0.2027, 0.0753), Offset(0.2733, 0.0456),
    Offset(0.3736, 0.0456), Offset(0.4739, 0.0456), Offset(0.5742, 0.0456),
    Offset(0.6744, 0.0456),
  ],
  '6': [
    Offset(0.7739, 0.0487), Offset(0.7463, 0.0957), Offset(0.6752, 0.1099),
    Offset(0.6079, 0.1375), Offset(0.5476, 0.1779), Offset(0.4963, 0.2292),
    Offset(0.4546, 0.2888), Offset(0.4247, 0.355), Offset(0.4045, 0.4248),
    Offset(0.4693, 0.4051), Offset(0.5403, 0.3894), Offset(0.6128, 0.3866),
    Offset(0.6849, 0.3956), Offset(0.7527, 0.4215), Offset(0.8114, 0.464),
    Offset(0.8556, 0.5214), Offset(0.8822, 0.5889), Offset(0.893, 0.6606),
    Offset(0.8898, 0.7331), Offset(0.8704, 0.8031), Offset(0.8339, 0.8657),
    Offset(0.7828, 0.917), Offset(0.7209, 0.9548), Offset(0.6528, 0.9802),
    Offset(0.5815, 0.9941), Offset(0.509, 0.9995), Offset(0.4363, 0.9968),
    Offset(0.3653, 0.9818), Offset(0.2979, 0.9548), Offset(0.2374, 0.9148),
    Offset(0.1875, 0.8621), Offset(0.1495, 0.8003), Offset(0.1243, 0.7322),
    Offset(0.1101, 0.661), Offset(0.1062, 0.5884), Offset(0.1108, 0.5158),
    Offset(0.1245, 0.4444), Offset(0.147, 0.3752), Offset(0.1786, 0.3098),
    Offset(0.2186, 0.2491), Offset(0.2661, 0.194), Offset(0.3201, 0.1454),
    Offset(0.3796, 0.1036), Offset(0.4436, 0.0689), Offset(0.5107, 0.041),
    Offset(0.5803, 0.0201), Offset(0.6518, 0.0066), Offset(0.7243, 0.0005),
    Offset(0.7739, 0.0487), Offset(0.5365, 0.4885), Offset(0.4925, 0.4767),
    Offset(0.4481, 0.4877), Offset(0.4127, 0.5164), Offset(0.3963, 0.559),
    Offset(0.3918, 0.6048), Offset(0.3908, 0.651), Offset(0.3917, 0.6971),
    Offset(0.3945, 0.7432), Offset(0.3997, 0.7891), Offset(0.4096, 0.8341),
    Offset(0.4268, 0.8768), Offset(0.4558, 0.912), Offset(0.499, 0.9255),
    Offset(0.5428, 0.9131), Offset(0.5735, 0.8793), Offset(0.5907, 0.8366),
    Offset(0.6, 0.7914), Offset(0.6043, 0.7455), Offset(0.6057, 0.6993),
    Offset(0.6039, 0.6532), Offset(0.5987, 0.6074), Offset(0.5881, 0.5625),
    Offset(0.5691, 0.5205), Offset(0.5365, 0.4885),
  ],
  '7': [
    Offset(0.1441, 0.3517), Offset(0.1492, 0.275), Offset(0.1543, 0.1984),
    Offset(0.1593, 0.1218), Offset(0.1644, 0.0451), Offset(0.199, 0),
    Offset(0.2758, 0), Offset(0.3526, 0), Offset(0.4294, 0),
    Offset(0.5062, 0), Offset(0.583, 0), Offset(0.6598, 0),
    Offset(0.7366, 0), Offset(0.8134, 0), Offset(0.8559, 0.0343),
    Offset(0.8379, 0.1071), Offset(0.8052, 0.1766), Offset(0.7725, 0.2461),
    Offset(0.7399, 0.3156), Offset(0.7072, 0.3851), Offset(0.6746, 0.4547),
    Offset(0.6419, 0.5242), Offset(0.6092, 0.5937), Offset(0.5766, 0.6632),
    Offset(0.5439, 0.7327), Offset(0.5113, 0.8022), Offset(0.4786, 0.8717),
    Offset(0.4459, 0.9412), Offset(0.4064, 1), Offset(0.3296, 1),
    Offset(0.3071, 0.9495), Offset(0.3421, 0.8811), Offset(0.3771, 0.8128),
    Offset(0.4121, 0.7444), Offset(0.4472, 0.676), Offset(0.4822, 0.6077),
    Offset(0.5172, 0.5393), Offset(0.5522, 0.471), Offset(0.5872, 0.4026),
    Offset(0.6222, 0.3342), Offset(0.6572, 0.2659), Offset(0.6172, 0.2391),
    Offset(0.5404, 0.2391), Offset(0.4636, 0.2391), Offset(0.3868, 0.2391),
    Offset(0.31, 0.2399), Offset(0.2415, 0.2689), Offset(0.2105, 0.3382),
    Offset(0.1441, 0.3517),
  ],
  '8': [
    Offset(0.2433, 0.486), Offset(0.1966, 0.441), Offset(0.1528, 0.3899),
    Offset(0.1249, 0.3287), Offset(0.1153, 0.262), Offset(0.125, 0.1954),
    Offset(0.1549, 0.1352), Offset(0.2011, 0.0864), Offset(0.2579, 0.05),
    Offset(0.3208, 0.0256), Offset(0.3864, 0.0098), Offset(0.4535, 0.0021),
    Offset(0.521, 0.0004), Offset(0.5885, 0.0042), Offset(0.6552, 0.0143),
    Offset(0.7202, 0.0326), Offset(0.7808, 0.0622), Offset(0.8326, 0.1051),
    Offset(0.8701, 0.1609), Offset(0.8884, 0.2255), Offset(0.8877, 0.2929),
    Offset(0.8702, 0.3578), Offset(0.8324, 0.4134), Offset(0.7819, 0.4583),
    Offset(0.7875, 0.502), Offset(0.8362, 0.5486), Offset(0.8723, 0.6053),
    Offset(0.8908, 0.6701), Offset(0.8933, 0.7374), Offset(0.8796, 0.8032),
    Offset(0.8474, 0.8623), Offset(0.8003, 0.9104), Offset(0.7439, 0.9474),
    Offset(0.6813, 0.9726), Offset(0.6159, 0.9893), Offset(0.5489, 0.9979),
    Offset(0.4814, 0.9995), Offset(0.4139, 0.9955), Offset(0.3473, 0.9846),
    Offset(0.2827, 0.9652), Offset(0.2226, 0.9345), Offset(0.1699, 0.8927),
    Offset(0.1312, 0.8375), Offset(0.1102, 0.7736), Offset(0.1063, 0.7064),
    Offset(0.118, 0.6401), Offset(0.1467, 0.5793), Offset(0.1905, 0.5281),
    Offset(0.2433, 0.486), Offset(0.4349, 0.4126), Offset(0.461, 0.4416),
    Offset(0.4984, 0.4524), Offset(0.5367, 0.4458), Offset(0.5666, 0.4213),
    Offset(0.5839, 0.3861), Offset(0.5925, 0.3477), Offset(0.5964, 0.3085),
    Offset(0.5976, 0.2691), Offset(0.5966, 0.2297), Offset(0.5933, 0.1905),
    Offset(0.5861, 0.1518), Offset(0.572, 0.1152), Offset(0.5463, 0.0858),
    Offset(0.5088, 0.075), Offset(0.4707, 0.082), Offset(0.4414, 0.1073),
    Offset(0.4242, 0.1425), Offset(0.4145, 0.1806), Offset(0.4096, 0.2197),
    Offset(0.4082, 0.2591), Offset(0.4089, 0.2985), Offset(0.4123, 0.3377),
    Offset(0.42, 0.3763), Offset(0.4349, 0.4126), Offset(0.4692, 0.5264),
    Offset(0.4361, 0.5518), Offset(0.4158, 0.5887), Offset(0.4046, 0.6294),
    Offset(0.3996, 0.6715), Offset(0.3981, 0.7138), Offset(0.3991, 0.7562),
    Offset(0.4029, 0.7984), Offset(0.4108, 0.8399), Offset(0.4261, 0.8794),
    Offset(0.4544, 0.9102), Offset(0.4943, 0.9227), Offset(0.5359, 0.9177),
    Offset(0.5698, 0.8937), Offset(0.5885, 0.8559), Offset(0.5974, 0.8146),
    Offset(0.6014, 0.7724), Offset(0.6025, 0.7301), Offset(0.6016, 0.6877),
    Offset(0.5985, 0.6455), Offset(0.5915, 0.6037), Offset(0.5773, 0.564),
    Offset(0.5504, 0.5319), Offset(0.5104, 0.5197), Offset(0.4692, 0.5264),
  ],
  '9': [
    Offset(0.2676, 0.9511), Offset(0.2935, 0.9021), Offset(0.3618, 0.8827),
    Offset(0.4248, 0.8496), Offset(0.4802, 0.805), Offset(0.5252, 0.7499),
    Offset(0.56, 0.6879), Offset(0.5847, 0.6211), Offset(0.5762, 0.5766),
    Offset(0.5093, 0.6007), Offset(0.4391, 0.6119), Offset(0.3679, 0.6122),
    Offset(0.2981, 0.5986), Offset(0.2333, 0.5697), Offset(0.1784, 0.5248),
    Offset(0.1382, 0.4664), Offset(0.114, 0.3996), Offset(0.106, 0.329),
    Offset(0.1135, 0.2582), Offset(0.1347, 0.1904), Offset(0.1723, 0.1302),
    Offset(0.2236, 0.0811), Offset(0.2844, 0.0441), Offset(0.3512, 0.0197),
    Offset(0.421, 0.0058), Offset(0.492, 0.0005), Offset(0.5631, 0.0032),
    Offset(0.6329, 0.0174), Offset(0.6992, 0.043), Offset(0.7589, 0.0814),
    Offset(0.8082, 0.1326), Offset(0.8465, 0.1925), Offset(0.872, 0.2589),
    Offset(0.8872, 0.3284), Offset(0.8933, 0.3994), Offset(0.8915, 0.4705),
    Offset(0.8814, 0.541), Offset(0.8629, 0.6098), Offset(0.8357, 0.6756),
    Offset(0.7999, 0.7372), Offset(0.7564, 0.7935), Offset(0.7056, 0.8435),
    Offset(0.6491, 0.8869), Offset(0.5879, 0.9233), Offset(0.5233, 0.9532),
    Offset(0.4558, 0.976), Offset(0.3863, 0.9913), Offset(0.3155, 0.9993),
    Offset(0.2676, 0.9511), Offset(0.4635, 0.5112), Offset(0.5076, 0.523),
    Offset(0.552, 0.5123), Offset(0.5875, 0.4835), Offset(0.6036, 0.4408),
    Offset(0.6082, 0.395), Offset(0.6092, 0.3488), Offset(0.6083, 0.3026),
    Offset(0.6055, 0.2566), Offset(0.6003, 0.2107), Offset(0.5904, 0.1656),
    Offset(0.5732, 0.123), Offset(0.5442, 0.0877), Offset(0.501, 0.0742),
    Offset(0.4572, 0.0866), Offset(0.4264, 0.1205), Offset(0.4092, 0.1632),
    Offset(0.4, 0.2084), Offset(0.3957, 0.2543), Offset(0.3943, 0.3004),
    Offset(0.3961, 0.3466), Offset(0.401, 0.3925), Offset(0.4117, 0.4373),
    Offset(0.4309, 0.4792), Offset(0.4635, 0.5112),
  ],
};

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

String _formatTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}';

/// Gerçek saatlerde olduğu gibi aynı çiftin (SS veya DD) rakamları birbirine
/// yakın, aradaki boşluk sadece iki nokta üst üste etrafında olsun diye
/// dört rakamın x konumunu rakamın gerçek çizim ölçeğine (scale — rakam
/// yolunun ekrana basıldığı birim, bkz. _digitPoint) göre dinamik
/// hesaplıyoruz. Oranlar (0.75 / 0.46) render edilip gözle doğrulanmış
/// değerlerdir (bkz. clean_layout_preview.png) — rakam kutusunun kendisi
/// [0,1] birim uzayda olsa da yay uçları rx=0.32'ye kadar taştığı için
/// uçağın görsel genişliğinden (dispWidth) çok daha büyük bir ölçek.
List<double> _digitCenterXs(double centerX, double scale) {
  final pitch = scale * 0.75;
  final colonGap = scale * 0.46;
  final d1 = centerX - colonGap;
  final d0 = d1 - pitch;
  final d2 = centerX + colonGap;
  final d3 = d2 + pitch;
  return [d0, d1, d2, d3];
}

/// [origin] noktasından [angle] yönünde ilerleyen bir ışının [bounds]
/// dikdörtgeninin (ekranın) kenarını kestiği mesafeyi (+ küçük bir pay)
/// döndürür. Uçağın ekran dışına gerçekten en kısa yoldan girip çıkması
/// için kullanılır — böylece giriş/çıkış mesafesi ekranın köşegeni kadar
/// abartılı olmaz, uçak çizim hızıyla aynı hızda makul bir sürede girip
/// çıkar.
double _edgeExitDistance(Offset origin, double angle, Size bounds, double margin) {
  final dx = math.cos(angle);
  final dy = math.sin(angle);
  var t = double.infinity;
  if (dx > 1e-6) {
    t = math.min(t, (bounds.width - origin.dx) / dx);
  } else if (dx < -1e-6) {
    t = math.min(t, (0 - origin.dx) / dx);
  }
  if (dy > 1e-6) {
    t = math.min(t, (bounds.height - origin.dy) / dy);
  } else if (dy < -1e-6) {
    t = math.min(t, (0 - origin.dy) / dy);
  }
  if (!t.isFinite || t < 0) t = bounds.width + bounds.height;
  return t + margin;
}

/// Gökyüzü sekmesine özel: dört uçağın her biri, her dakikanın başında
/// ekranın dışından girip şu anki saatin ("HH:MM") kendi rakamını BİR KEZ
/// çizip, çizimi bitirdiği son doğrultuda ilerleyerek tekrar ekranın
/// dışına çıktığı, sadece bu ekranda görünen ayrı bir gösteri katmanı —
/// bkz. SkyWatchScreen. Uçak ekrandan çıktıktan sonra iz (rakam) bir
/// sonraki dakikaya kadar ekranda görünür kalır. Ana arka plan katmanından
/// (FlightTrailsBackground) bağımsız çalışır, uygulamanın geri kalanını
/// etkilemez.
class SkyClockPlanes extends StatefulWidget {
  const SkyClockPlanes({super.key});

  @override
  State<SkyClockPlanes> createState() => _SkyClockPlanesState();
}

class _SkyClockPlanesState extends State<SkyClockPlanes> with TickerProviderStateMixin {
  // Giriş, çizim ve çıkış evrelerinin HEPSİ aynı piksel/saniye hızını
  // kullanır — uçaklar ekrana girerken/çıkarken de tıpkı rakamı çizerkenki
  // hızlarıyla hareket etsin diye (bkz. _computeGeometryForIndex).
  static const double _planeSpeedPxPerSec = 110;
  static const double _offscreenMargin = 50;
  // Saat, ekranın biraz daha üst kısmında görünsün diye 0.4'ten düşürüldü.
  static const double _clockYFrac = 0.30;

  final _rnd = math.Random();
  late List<AnimationController> _controllers;
  late List<_PolylinePath> _digitPaths;
  late List<_ClockPlaneKind> _kinds;
  late List<double> _approachFracs;
  late List<double> _drawEndFracs;
  late List<Offset> _startPos;
  late List<Offset> _endPos;
  late List<double> _startAngle;
  late List<double> _endAngle;
  late List<Offset> _entryPos;
  late List<Offset> _exitPos;
  String _lastTime = '';
  Timer? _minuteWatcher;
  // İlk build'den önce _rebuildDigits çağrıldığında kullanılacak, gerçek
  // ekran boyutu build() içinde her seferinde güncellenir.
  Size _lastSize = const Size(400, 800);
  double _lastScale = 64;

  @override
  void initState() {
    super.initState();
    _kinds = List.generate(4, (_) => _ClockPlaneKind.values[_rnd.nextInt(_ClockPlaneKind.values.length)]);
    _digitPaths = List.generate(4, (_) => _PolylinePath(const [Offset.zero, Offset.zero]));
    _approachFracs = List.filled(4, 0.2);
    _drawEndFracs = List.filled(4, 0.8);
    _startPos = List.filled(4, Offset.zero);
    _endPos = List.filled(4, Offset.zero);
    _startAngle = List.filled(4, 0.0);
    _endAngle = List.filled(4, 0.0);
    _entryPos = List.filled(4, Offset.zero);
    _exitPos = List.filled(4, Offset.zero);
    _controllers = List.generate(4, (_) => AnimationController(vsync: this, duration: const Duration(seconds: 6)));
    _rebuildDigits();
    // Uçaklar dakikanın başında saati BİR KEZ çizer, döngü halinde tekrar
    // tekrar çizmezler — controller.repeat() yerine sadece forward().
    _minuteWatcher = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_formatTime(DateTime.now()) != _lastTime) _rebuildDigits();
    });
  }

  void _rebuildDigits() {
    _lastTime = _formatTime(DateTime.now());
    if (!mounted) return;
    setState(() {
      _digitPaths = [
        for (var i = 0; i < 4; i++) _PolylinePath(_kClockDigitFont[_lastTime[i]]!),
      ];
    });
    for (var i = 0; i < 4; i++) {
      _computeGeometryForIndex(i);
    }
  }

  /// Bir rakamın giriş noktası, çıkış noktası ve üç evrenin (giriş/çizim/
  /// çıkış) süresini — hepsi aynı hızda (_planeSpeedPxPerSec) hareket
  /// edecek şekilde — hesaplayıp o rakamın controller'ını başlatır.
  void _computeGeometryForIndex(int index) {
    final scale = _lastScale;
    final centerXs = _digitCenterXs(_lastSize.width * 0.5, scale);
    final center = Offset(centerXs[index], _lastSize.height * _clockYFrac);
    final startPos = _digitPoint(index, 0, center, scale);
    final startAngle = _digitAngle(index, 0, center, scale);
    final endPos = _digitPoint(index, 1, center, scale);
    final endAngle = _digitAngle(index, 1, center, scale);

    final entryDist = _edgeExitDistance(startPos, startAngle + math.pi, _lastSize, _offscreenMargin);
    final exitDist = _edgeExitDistance(endPos, endAngle, _lastSize, _offscreenMargin);

    _startPos[index] = startPos;
    _endPos[index] = endPos;
    _startAngle[index] = startAngle;
    _endAngle[index] = endAngle;
    _entryPos[index] = startPos - Offset(math.cos(startAngle), math.sin(startAngle)) * entryDist;
    _exitPos[index] = endPos + Offset(math.cos(endAngle), math.sin(endAngle)) * exitDist;

    final drawPixelLen = _digitPaths[index].totalLen * scale;
    final entrySec = entryDist / _planeSpeedPxPerSec;
    final drawSec = drawPixelLen / _planeSpeedPxPerSec;
    final exitSec = exitDist / _planeSpeedPxPerSec;
    final totalSec = entrySec + drawSec + exitSec;

    _approachFracs[index] = totalSec > 0 ? entrySec / totalSec : 0.0;
    _drawEndFracs[index] = totalSec > 0 ? (entrySec + drawSec) / totalSec : 1.0;

    _controllers[index]
      ..duration = Duration(milliseconds: (totalSec * 1000).clamp(800, 20000).round())
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _minuteWatcher?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPink = AppColors.variant == AppThemeVariant.pink;
    final planeColor = AppColors.primary.withValues(alpha: 0.85);
    final trailColor = (isPink ? AppColors.accent : AppColors.primary).withValues(alpha: 0.85);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        // Bir sonraki dakika değişiminde giriş/çıkış mesafesi doğru
        // hesaplansın diye gerçek ekran boyutunu önbelleğe alıyoruz.
        _lastSize = size;
        _lastScale = size.width * 0.16;
        final y = size.height * _clockYFrac;
        final unitScale = _lastScale;
        final centerXs = _digitCenterXs(size.width * 0.5, unitScale);

        return AnimatedBuilder(
          animation: Listenable.merge(_controllers),
          builder: (context, _) {
            return Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _ColonPainter(center: Offset(size.width * 0.5, y), scale: unitScale, color: trailColor),
                ),
                for (var i = 0; i < 4; i++)
                  ..._buildDigitPlane(
                    i,
                    _controllers[i].value,
                    Offset(centerXs[i], y),
                    unitScale,
                    trailColor,
                    planeColor,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Offset _digitPoint(int index, double t, Offset center, double scale) {
    final local = _digitPaths[index].pointAt(t);
    return center + (local - const Offset(0.5, 0.5)) * scale;
  }

  double _digitAngle(int index, double t, Offset center, double scale) {
    const eps = 0.008;
    final p1 = _digitPoint(index, (t - eps).clamp(0.0, 1.0), center, scale);
    final p2 = _digitPoint(index, (t + eps).clamp(0.0, 1.0), center, scale);
    return (p2 - p1).direction;
  }

  List<Widget> _buildDigitPlane(
    int index,
    double t,
    Offset center,
    double scale,
    Color trailColor,
    Color planeColor,
  ) {
    final approachFrac = _approachFracs[index];
    final drawEndFrac = _drawEndFracs[index];

    Offset pos;
    double angle;
    double drawT;
    if (t < approachFrac) {
      final localT = approachFrac > 0 ? (t / approachFrac).clamp(0.0, 1.0) : 1.0;
      pos = Offset.lerp(_entryPos[index], _startPos[index], localT)!;
      angle = _startAngle[index];
      drawT = 0;
    } else if (t < drawEndFrac) {
      final span = drawEndFrac - approachFrac;
      final localT = span > 0 ? ((t - approachFrac) / span).clamp(0.0, 1.0) : 1.0;
      pos = _digitPoint(index, localT, center, scale);
      angle = _digitAngle(index, localT, center, scale);
      drawT = localT;
    } else {
      final span = 1 - drawEndFrac;
      final localT = span > 0 ? ((t - drawEndFrac) / span).clamp(0.0, 1.0) : 1.0;
      pos = Offset.lerp(_endPos[index], _exitPos[index], localT)!;
      angle = _endAngle[index];
      drawT = 1;
    }

    final kind = _kinds[index];
    final dispWidth = scale * 0.4;
    final dispHeight = dispWidth * _clockPlaneAspect(kind);

    return [
      CustomPaint(
        size: Size.infinite,
        painter: _DigitTrailPainter(
          path: _digitPaths[index],
          center: center,
          scale: scale,
          currentT: drawT,
          color: trailColor,
        ),
      ),
      Positioned(
        left: pos.dx - dispWidth / 2,
        top: pos.dy - dispHeight / 2,
        child: Transform.rotate(
          angle: angle,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(planeColor, BlendMode.srcIn),
            child: Image.asset(
              _clockPlaneAsset(kind),
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

class _DigitTrailPainter extends CustomPainter {
  final _PolylinePath path;
  final Offset center;
  final double scale;
  final double currentT;
  final Color color;
  const _DigitTrailPainter({
    required this.path,
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
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    const steps = 120;
    final maxStep = (steps * currentT).floor();
    Offset? prev;
    for (var i = 0; i <= maxStep; i++) {
      final local = path.pointAt(i / steps);
      final p = center + (local - const Offset(0.5, 0.5)) * scale;
      if (prev != null) {
        canvas.drawLine(prev, p, paint);
      }
      prev = p;
    }
  }

  @override
  bool shouldRepaint(covariant _DigitTrailPainter oldDelegate) =>
      oldDelegate.currentT != currentT || oldDelegate.color != color || oldDelegate.path != path;
}

class _ColonPainter extends CustomPainter {
  final Offset center;
  final double scale;
  final Color color;
  const _ColonPainter({required this.center, required this.scale, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final r = scale * 0.05;
    canvas.drawCircle(center + Offset(0, -scale * 0.16), r, paint);
    canvas.drawCircle(center + Offset(0, scale * 0.16), r, paint);
  }

  @override
  bool shouldRepaint(covariant _ColonPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.center != center;
}
