// Purpose: Shared Amharic membership agreement builder and bottom-sheet widget.
// Used by both the group-invite flow (join) and the create-group flow (create).

import 'package:et_digital_equb/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Text builder ────────────────────────────────────────────────────────────

/// Converts an amount to Amharic words (handles up to 999 999 ETB).
String amountInAmharicWords(double amount) {
  final int n = amount.abs().toInt();
  if (n == 0) return 'ዜሮ';

  const ones = [
    '', 'አንድ', 'ሁለት', 'ሦስት', 'አራት', 'አምስት',
    'ስድስት', 'ሰባት', 'ስምንት', 'ዘጠኝ',
  ];
  const tens = [
    '', 'አስር', 'ሃያ', 'ሠላሳ', 'አርባ', 'ሐምሳ',
    'ስድሳ', 'ሰባ', 'ሰማኒያ', 'ዘጠና',
  ];

  String below100(int v) {
    if (v < 10) return ones[v];
    if (v < 20) {
      final o = ones[v - 10];
      return o.isEmpty ? 'አስር' : 'አስር $o';
    }
    final t = tens[v ~/ 10];
    final o = ones[v % 10];
    return o.isEmpty ? t : '$t $o';
  }

  String below1000(int v) {
    if (v < 100) return below100(v);
    final h = ones[v ~/ 100];
    final rest = v % 100;
    if (rest == 0) return '$h መቶ';
    return '$h መቶ ${below100(rest)}';
  }

  if (n < 1000) return below1000(n);
  final thousands = n ~/ 1000;
  final rest = n % 1000;
  final tStr = thousands == 1 ? 'አንድ ሺህ' : '${below1000(thousands)} ሺህ';
  if (rest == 0) return tStr;
  return '$tStr ${below1000(rest)}';
}

String frequencyInAmharic(String freq) {
  switch (freq.toLowerCase()) {
    case 'daily':   return 'ቀን';
    case 'weekly':  return 'ሳምንት';
    case 'monthly': return 'ወር';
    case 'hourly':  return 'ሰዓት';
    default:        return freq;
  }
}

int durationInDays(String frequency, int targetMembers) {
  switch (frequency.toLowerCase()) {
    case 'daily':   return targetMembers;
    case 'weekly':  return targetMembers * 7;
    case 'monthly': return targetMembers * 30;
    default:        return targetMembers * 7;
  }
}

/// Builds the full Amharic membership agreement text with all dynamic fields.
/// Works with raw values so it can be called from both join and create flows.
String buildCashEqubTc({
  required String groupName,
  required double contributionAmount,
  required int targetMembers,
  required String frequency,
  required double serviceChargePercent,
  DateTime? startDate,
}) {
  final startDateStr = startDate != null
      ? '${startDate.day}/${startDate.month}/${startDate.year}'
      : 'የሚወሰን';
  final contributionInt = contributionAmount.toInt();
  final contributionWords = amountInAmharicWords(contributionAmount);
  final freq = frequencyInAmharic(frequency);
  final durationDays = durationInDays(frequency, targetMembers);
  final double payout;
  final String serviceChargeAmount;
  if (frequency == 'daily') {
    payout = contributionAmount * targetMembers;
    serviceChargeAmount = (payout * (serviceChargePercent / 100)).toStringAsFixed(0);
  } else {
    payout = contributionAmount * targetMembers * (1 - serviceChargePercent / 100);
    serviceChargeAmount = ((contributionAmount * targetMembers) - payout).toStringAsFixed(0);
  }
  final payoutStr = 'ብር ${payout.toStringAsFixed(0)}';
  final penaltyAmount = (contributionAmount * 0.05).toStringAsFixed(0);
  const location = 'አዲስ አበባ';
  // Fields the docx leaves blank for which the app has no data point yet.
  const toBeDetermined = 'በድርጅቱ የሚወሰን';

  return '''
በገንዘብ የሚከፈል ዲጂታል ዕቁብ
የዕቁብተኞች የአባልነት ስምምነት (መተዳደሪያ ደንብ)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
መግቢያ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ይህ ስምምነት በዋነኛነት የዕቁብተኞች የአባልነት ደንብና ሁኔታዎችን የሚደነገግ ሲሆን የገንዘብ ዕቁብ አባል መሆን በሚፈልጉት በእርስዎ እና በኢቲዲጂታል ዕቁብ ፋይናንሺል ቴክኖሎጂ ኃ.የተ.የግ.ማህበር (ከዚህ በኃላ "ድርጅት" ተብሎ በሚጠራው) መካከል ተፈፅሟል፡፡

የእቁቡ ስያሜ "$groupName" ተብሎ ይጠራል፡፡

ዕቁቡ መሰብሰብ የሚጀምርበት ቀንና ጊዜ: $startDateStr
የዕቁቡ አባላት ብዛት: $targetMembers (በሰው ወይም በዕጣ)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
የስምምነቱ ተፈፃሚነት
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
የዚህ ስምምነት ውሎች፣ ደንቦች እና ሁኔታዎች እርስዎ ፍቃደኛ ከሚሆኑበት ጊዜ ጀምሮ ዕቁብ እስከሚጠናቀቅ ድረስ ተፈፃሚ ይሆናሉ፡፡

ይህንን የአባልነት ስምምነት በአግባቡ ካነበቡ በኋላ በደንብና ሁኔታዎች ለመገዛት ፍቃደኛ ከሆኑ "ይስማሙ" የሚለውን አማራጭ ይጫኑ፡፡ ይህን ሲያደርጉ ወዲያውኑ የዕቁብ አባል ወይም ዕቁብተኛ ይሆናሉ፡፡

ይህ ውል በኤሌክትሮኒክስ ትራንዛክሽን አዋጅ ቁጥር 1205/2012፣ በኤሌክትሮኒክስ ፊርማ አዋጅ ቁጥር 1072/2010 እና በፍ/ብ/ሕጉ ስለውል በጠቅላላ በተደነገጉት ድንጋጌዎች በተለይ በፍ/ብ/ህ/ቁ 1731 መሠረት በሕግ ፊት የጸና ነው፡፡

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ውሉ የተደረገበት ቦታ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ይህ ዕቁብ የሚሰባሰበው በኤሌክትሮኒክስ መተግበሪያ መንገዶች የተለያየ ቦታ ከሚገኙ በዕቁብ ውሉ ፈቃደኛ ከሆኑ ዕቁብተኞች በመሆኑ ምንም እንኳን የዕቁብ ውሉ፣ ዕጣ አወጣጡ የአከፋፈል ስራዓቱ በኤሌክትሮኒክስ መተግበሪያ አማካኝነት ቢሆንም ውሉ የተደረገበት ቦታ ድርጅቱ የሚገኝበት አድራሻ ማለትም $location እንዲሆን ተዋዋይ ወገኖች ተስማምተናል፡፡

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ስለ ዕቁቡ ጠቅላላ ድንጋጌዎች እና ዓላማ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ይህ የገንዘብ ዕቁብ ከላይ ተዋዋይ በሆኑት ወገኖች ማለትም በዕቁብተኛው እና በድርጅቱ መካከል የተደረገ ሲሆን ዓላማውም ዕቁብተኛው የሚጣል ገንዘብ ዕቁብ አባል በመሆን ለ $durationDays ቀናት (ቅዳሜ እና እሁድን ጨምሮ) በተከታታይ የሚጣል ዕቁብ ለመጣል በመስማማት በውስጡም $targetMembers የዕቁብ አባላት ወይም ዕቁብተኞች ይኖሩታል፡፡

በዚህም በየ${freq}ው የሚጣለው የአንድ ዕቁብ ዕጣ መደበኛ ሙሉ መዋጮ ገንዘብ መጠን ብር $contributionInt ($contributionWords) ዕቁብተኛው ለድርጅቱ ለመክፈል ተስማምቷል፡፡ ድርጅቱም ለዕቁብተኞቹ ዕጣ ሲወጣለት የገንዘብ መጠኑ $payoutStr የሆነ ገንዘብ ዕጣ ለወጣለት ዕቁብተኛ ለመክፈል ተስማምቷል፡፡

ዕቁቡ ድርጅቱ በሚያዘጋጀው የኤሌክትሮኒክስ መተግበሪያ አማካኝነት በቀጥታ የዕጣ ስነ ሥርዓት አማካኝነት በየ${freq}ው በቀኑ ክፍለ ጊዜ በ$toBeDetermined ላይ ለዕቁብተኞች ዕጣ የሚወጣ ሆኖ ዕቁብተኞች በሞባይል ስልኮቻቸው በኩል የዕጣ አወጣጥ ሂደቱን በቀጥታ መከታተል በሚችሉበት ሁኔታ ዕጣ ወጥቶ ድርጅቱ ዕጣ ለወጣለት ዕቁብተኛ ገንዘቡን ድርጅቱ የሚያስቀምጣቸውን የተለያዩ መስፈርቶች፣ ውሎች እና ዋስትና ጉዳዮች እና ተያያዥ ሁኔታዎች ካለቁ በኋላ የሚከፍል ይሆናል፡፡

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
የዕቁብተኛው (የእርሶ) መብትና ግዴታዎች
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• በዕቁቡ ለመሳተፍ የታደሰ ህጋዊ የነዋሪነት መታወቂያ፣ የመስሪያ ቤት መታወቂያ፣ የታደሰ ንግድ ፍቃድና እንደአግባብነቱ ድርጅቱ የሚጠይቃቸውን ሌሎች ተጨማሪ ማስረጃዎችን በሚሰጠው የጊዜ ገደብ ውስጥ ዕቁብተኛው ማቅረብ አለበት፡፡
• የገንዘብ ዕቁብ አባል ለመሆን ለመደበኛ የዕቁብ መዋጮ በቂ የሚሆን ገቢ የሚያስገኝ ህጋዊ ስራ ማለትም በንግድ፣ በአሽከርካሪ ወይም በተለያየ ገቢ በሚያስገኝ ስራ ሊሰማሩ ይገባል፡፡
• ዕቁቡን ለመቀላቀል ያመለከቱበት እና ዕቁብ ለመጣል የተስማሙበት የስልክ መስመር ቁጥር የዕቁብተኛው በስሙ የወጣ ሊሆን ይገባል፤ የሶስተኛ ወገን ስም ከሆነ ውክልና ወይም የሶስተኛ ወገን ፈቃድ ለማያያዝ ፍቃደኛ ሊሆን ይገባል፡፡
• ዕቁብ በድርጅቱ እንዲሰበሰብ ዕቁብተኛው ፍቃደኛ ስለመሆናቸው በኤሌክትሮኒክስ ፊርማ አዋጅ ቁጥር 1072/2010 መሰረት ስምምነታቸውን አረጋግጠዋል፡፡
• የአንድ ዕቁብ ዕጣ መደበኛ መዋጮ ገንዘብ መጠን ብር $contributionInt ($contributionWords) ዕቁብተኛው ለድርጅቱ ለመክፈል ተስማምቷል፡፡
• ዕቁብተኛው ለድርጅቱ የሚከፈለውን የአገልግሎት ክፍያ መጠን ብር $serviceChargeAmount ($serviceChargePercent%) ለመክፈል ተስማምቷል፡፡
• ዕቁብተኛው ለድርጅቱ መከፈል ያለበትን የዕቁብ ክፍያ በዕለቱ የማይከፍል ከሆነ መቀጫ ብር $penaltyAmount ጨምሮ ለድርጅቱ ለመክፈል ተስማምቷል፡፡
• ዕቁብተኛው በጋራ ከዕቁብተኞች ጋር ለመክፈል የተስማሙትን ገንዘብ በየጊዜው በመክፈል በዕጣ በማውጣት ዕጣው ለደረሰው ዕቁብተኛ የእቁብ ገንዘቡ እንዲከፈለው ተስማምቷል፡፡
• ማንኛውም ዕጣ የወጣለት ዕቁብተኛ ዕጣ ከመውጣቱ በፊት ያልከፈለው የዕቁቡ መዋጮና ቅጣት ካለ ከሚከፈለው የዕቁብ ገንዘብ ላይ ያለበት ቀሪ መዋጮና ክፍያ ከነቅጣቱ ተቀንሶ ቀሪው የሚከፈለው ይሆናል፡፡
• በየጊዜው በሚወጣው የዕቁብ ዕጣ ተሳታፊ ለመሆን የዕቁብ መዋጮ ክፍያዎችን ዕጣው ከሚወጣበት ጊዜ አስቀድመው ሊከፍሉ ይገባል፤ ይህንን ካላደረጉ በዕለቱ በሚወጣው ዕጣ ውስጥ ተሳታፊ አይሆኑም፡፡
• የዕቁብ ዕጣ ሲወጣልዎ ከድርጅቱ ጋር ተጨማሪ የውል ስምምነት የሚፈራረሙ ሲሆን ይህን ሳያደርጉ እና ሌሎች በድርጅቱ በኩል የሚጠየቁ ቅድመ ሁኔታዎችን ሳያሟሉ ዕጣ የወጣልዎትን የዕቁብ ገንዘብ እንዲከፈሎ መጠየቅ አይችሉም፡፡
• ለዕቁብተኛው በዕጣ የወጣ የዕቁብ ገንዘብ ኖሮ ዕቁብተኛው ከዚህ ዓለም በሞት ከተለየ የዕቁብተኛው መብትና ግዴታ ወደ ወራሾች የሚተላለፍ ይሆናል፡፡ ወራሾች ተተክተው መቀጠል ካልፈለጉ ዕቁቡ ሲጠናቀቅ ሟች የከፈሉት ክፍያ ይከፈላቸዋል፡፡
• ዕቁብተኛው ዕጣ ወጥቶለት የዕቁብ ገንዘቡን ከተረከበ በኃላ ዕቁቡ እስከሚያልቅ ድረስ የሚጠበቅበትን የዕቁብ ክፍያ የመክፈል ግዴታ አለበት፡፡
• ዕቁቡ ለሁሉም ዕቁብተኞች ተዳርሶ ከመጠናቀቁ በፊት ማቋረጥ በፍፁም የተከለከለ ነው፡፡ የዕቁብ ዕጣ ሳይወጣልዎት ዕቁቡን ካቋረጡ ካወጡት የዕቁብ መዋጮ ላይ ቅጣትና የተለያዩ ክፍያዎች ከተቀነሱ በኃላ ቀሪ የሚሆነው ገንዘብ ተመላሽ የሚደረግሎት ዕቁቡ ከተጠናቀቀ በኃላ ነው፡፡ ተመላሽ በሚደረገው ገንዘብ ላይ ወለድም ሆነ ሌላ ማንኛውም የአይነት ክፍያ መጠየቅ አይቻልም፡፡
• በህገ ወጥ መንገድ የተገኘ ገንዘብ ወደ ድርጅቱ ዕቁብ ስርዓት ማስገባት በፍጹም የተከለከለ ነው፡፡
• ከድርጅቱ በግልጽ ፍቃድ ካልተገኘ በስተቀር የወጣልዎትን የዕቁብ ዕጣ መሸጥ አይችሉም፡፡ በልዩ ሁኔታ ከድርጅቱ ዕጣ ለመሸጥ በግልጽ ፈቃድ ካገኙ ለድርጅቱ ሊከፈል የሚገባው የአገልግሎት ፈቃድ ክፍያ $toBeDetermined በቅድሚያ ዕቁብተኛው ሊከፍል ይገባል፡፡
• የሞባይል መተግበሪያውን ሲጠቀሙ የሚደርስዎትን መረጃ (ፒንኮድ፣ የሚስጥር ቁጥር) የመጠበቅ ግዴታ አለብዎት፡፡ ይህንን ባለማድረግዎ ለሚደርሰው ጉዳት ሙሉ በሙሉ ተጠያቂ ይሆናሉ፡፡
• የዕቁብ ዕጣ ሲወጣልዎት ድርጅቱ ባለው አሰራር መሠረት የሚጠይቀውን የዋስትና ወይም መያዣ አይነት የማቅረብ እንዲሁም ሌሎች ቅድመ ሁኔታዎችን የማሟላት ግዴታ ዕቁብተኛው አለበት፡፡
• ዕቁብተኛው በውሉ መሰረት ግዴታውን ካልተወጣ ድርጅቱ ስልጣን ባለው ፍ/ቤት ክስ መስርቶ የመጠየቅ መብት እንዳለው ዕቁብተኛው ተስማምቷል፡፡

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
የድርጅቱ ኃላፊነት እና ግዴታ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• ዕቁብተኞች በዚህ ደንብ በየጊዜው ለመክፈል የተስማሙትን ገንዘብ በወቅቱ ከዕቁብተኞች ይሰበስባል፡፡
• በዚህ ደንብ በተመለከተው የጊዜ ሰሌዳ መሠረት ወቅቱን ጠብቆ በሞባይል መተግበሪያው አሰራር መሰረት ግልጽ በሆነ ሁኔታ ለዕቁብተኛው ዕጣ ያወጣል፡፡
• ዕጣ ከመውጣቱ በፊት በዕጣው ለመሳተፍ ብቁ የሆኑ የዕቁብተኞች ስም ዝርዝር በሞባይል መተግበሪያው ለዕቁብተኞች ያሳውቃል፤ ከዕቁብተኞች የሚነሱ ቅሬታዎችን ተቀብሎ መፍትሔ ይሰጣል፡፡
• በዚህ ደንብ የተገለጸውን የገንዘብ ዕቁብ ዕጣ ክፍያ ይከፍላል፡፡
• የሞባይል መተግበሪያውን በባለቤትነት ይይዛል፣ ያስተዳድራል፡፡
• የእቁብተኞችን ሰነድና ሚስጥር ይጠብቃል፡፡
• ፋይናንስ ነክ የሆኑና በባንክ በኩል ብቻ መከናወን ያለባቸውን ስራዎች ህጋዊ ፍቃድ ባላቸው ባንኮች እና የፋይናንስ ተቋማት ብቻ እንዲሰሩ ያደርጋል፡፡
• የሞባይል መተግበሪያው ከሶስተኛ ወገኖች ጣልቃ ገብነት ነፃ ሆኖ መስራቱን ይከታተላል፣ ያረጋግጣል፡፡
• የሞባይል መተግበሪያው 24/7 የሚሰራ መሆኑን ያረጋግጣል እንዲሁም ችግር ሲኖር ያስተካክላል፡፡
• የሞባይል መተግበሪያው በህግ የሚጠበቅበትን የደህንነት መግለጫ መሟላቱን ያረጋግጣል፡፡
• ዕጣ የወጣላቸው ዕቁብተኛ በዕቁብ የወጣላቸውን ገንዘብ ከመከፈሉ በፊት ማቅረብ ያለባቸውን የዋስትና እና የመያዣ ዓይነት እንዲሁም ሌሎች ቅድመ ሁኔታዎችን አስቀድሞ ይወስናል፡፡
• የዕቁብተኞች መብት የሚነኩ ጉዳዮች ሲያጋጥሙ አግባብነት ያለውን ህጋዊ እርምጃ ይወስዳል እንዲሁም ስልጣን ባለው አካል ተገቢውን እርምጃ እንዲወስድ ያደርጋል፡፡

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ልዩ ልዩ ድንጋጌዎች
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• ድርጅቱ የዚህን ውል ደንብና ሁኔታዎች ለዕቁብተኞች በማሳወቅ ሊያሻሽል ይችላል፡፡
• ይህ ስምምነት አግባብነት ባላቸው የኢትዮጵያ ህጎች የሚገዛ ይሆናል፡፡
• ከዚህ ውል ጋር በተያያዘ የሚፈጠር አለመግባባት በጋራ ምክክር እንዲፈታ ጥረት ያደርጋል፤ ይህ ካልተሳካ ግን ጉዳዩ ስልጣን ወዳለው ፍርድ ቤት መውሰድ ይቻላል፡፡
• በዚህ ውል ውስጥ በወንድ ጾታ የተገለጸው አገላለጽ በተመሳሳይ መልኩ ለሴትም ጾታ ያገለግላል፤ በሴት ጾታ የተገለጸውም በተመሳሳይ መልኩ ለወንድ ጾታ ያገለግላል፡፡
''';
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

/// Shows the Amharic membership agreement bottom sheet.
/// Returns `true` only when the user explicitly taps "ይስማሙ — I Accept".
Future<bool> showEqubMembershipAgreement(
  BuildContext context,
  String tcText,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EqubTermsSheet(tcText: tcText),
  );
  return result == true;
}

class _EqubTermsSheet extends StatefulWidget {
  const _EqubTermsSheet({required this.tcText});
  final String tcText;

  @override
  State<_EqubTermsSheet> createState() => _EqubTermsSheetState();
}

class _EqubTermsSheetState extends State<_EqubTermsSheet> {
  final _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_hasScrolledToBottom &&
        _scrollController.offset >=
            _scrollController.position.maxScrollExtent - 40) {
      setState(() => _hasScrolledToBottom = true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                const Text(
                  'የአባልነት ስምምነት',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Membership Agreement — please read carefully',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                widget.tcText,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.75,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Scroll-to-bottom hint
          if (!_hasScrolledToBottom)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: Colors.grey[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.grey[500], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'ለማስቀጠል ወደ ታች ይሸብልሉ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          // Action buttons
          Padding(
            padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
            child: Row(
              children: [
                // Decline
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'አልቀበልም',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Accept — enabled only after scrolling to bottom
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _hasScrolledToBottom
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withOpacity(0.35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ይስማሙ — I Accept',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
