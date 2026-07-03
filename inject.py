import re

amharic_keys = """  'privacy_policy_title': 'የግላዊነት መመሪያ',
  'privacy_policy_subtitle': 'መረጃዎን እንዴት እንደምንጠብቅ',
  'privacy_intro': 'ወደ ኢቲ ዲጂታል እቁብ እንኳን በደህና መጡ። ይህ የግላዊነት መመሪያ በእኛ የሞባይል መተግበሪያ ወይም ድህረ ገጽ በመጠቀም በዲጂታል ባህላዊ የኢትዮጵያ እቁብ ላይ ሲሳተፉ መረጃዎን እንዴት እንደምንሰበስብ፣ እንደምናስኬድ፣ እንደምንጠቀም እና እንደምንጠብቅ ያብራራል። የኢቲ ዲጂታል እቁብ አገልግሎትን በመጠቀም፣ በዚህ የግላዊነት መመሪያ ውሎች ተስማምተዋል። ካልተስማሙ፣ እባክዎ አገልግሎቶቻችንን አይጠቀሙ።',
  'privacy_section_1_title': 'I. ትርጓሜዎች',
  'privacy_section_1_service': 'አገልግሎት፡ የኢቲ ዲጂታል እቁብ የሞባይል መተግበሪያ እና/ወይም ድህረ ገጽ።',
  'privacy_section_1_protected': 'የተጠበቀ መረጃ፡ ስምዎን፣ የመታወቂያ ሰነዶችዎን እና የፋይናንስ ሂሳብ ዝርዝሮችን ጨምሮ እርስዎን ለመለየት የሚያገለግል የግል ውሂብ።',
  'privacy_section_1_user': 'ተጠቃሚ፡ ለኢቲ ዲጂታል እቁብ አገልግሎቶች የሚመዘገብ ወይም የሚጠቀም ማንኛውም ግለሰብ።',
  'privacy_section_2_title': 'II. የምንሰበስበው መረጃ',
  'privacy_section_2_intro': 'ደህንነቱ የተጠበቀ እና አስተማማኝ የቁጠባ አካባቢን ለመጠበቅ የሚከተሉትን እንሰበስባለን፡',
  'privacy_section_2_identity': 'የማንነት ውሂብ፡ ሙሉ ስም፣ የትውልድ ቀን፣ እና የብሄራዊ መታወቂያዎ ወይም የቀበሌ መታወቂያዎ ዲጂታል ቅጂ።',
  'privacy_section_2_contact': 'የእውቂያ ውሂብ፡ የሞባይል ስልክ ቁጥር (ከቴሌብር፣ ኤም-ፔሳ፣ ወይም ከአገር ውስጥ ባንክ ጋር የተገናኘ መሆን አለበት) እና የኢሜይል አድራሻ።',
  'privacy_section_2_financial': 'የፋይናንስ ውሂብ፡ የባንክ ሂሳብ ቁጥሮች፣ የሞባይል የኪስ ቦርሳ መታወቂያዎች፣ እና በመድረኩ ውስጥ የገቡት አስተዋጽዖዎች እና ክፍያዎች ታሪክ።',
  'privacy_section_2_geolocation': 'የአካባቢ መረጃ (Geolocation Data)፡ ከመተግበሪያው ጋር ሲገናኙ ወይም የግብይት አፈጻጸም በሚደረግበት ጊዜ በየጊዜው የሚሰበሰብ ትክክለኛ አካባቢ (የጂፒኤስ መጋጠሚያዎች ወይም በአይፒ (IP) ላይ የተመሰረተ የአካባቢ ውሂብ)።',
  'privacy_section_2_usage': 'የአጠቃቀም መረጃ፡ ስለ መሳሪያዎ ቴክኒካዊ ውሂብ፣ የአይፒ አድራሻ እና ከመተግበሪያችን ጋር ያለዎት የግንኙነት ታሪክ።',
  'privacy_section_3_title': 'III. የተሰበሰበውን መረጃ መጠቀም',
  'privacy_section_3_intro': 'ለሚከተሉት ዓላማዎች የእርስዎን ውሂብ እናስኬዳለን፡',
  'privacy_section_3_cycle': 'የዑደት አስተዳደር፡ አውቶማቲክ "የእጣ ማውጣትን" ማመቻቸት፣ የገንዘብ ዝውውርን ማስተዳደር እና አሸናፊዎችን ማሳወቅ።',
  'privacy_section_3_kyc': 'የKYC ተገዢነት፡ ማጭበርበርን ለመከላከል እና የኢትዮጵያ ብሔራዊ ባንክ (NBE) የፀረ-ገንዘብ ማጭበርበር (AML) መስፈርቶችን ለማሟላት ማንነትዎን ማረጋገጥ።',
  'privacy_section_3_communication': 'ግንኙነት፡ ስለ ክፍያ ገደቦች፣ የስርዓት ዝመናዎች እና የተሳካ እጣዎች በአገር ውስጥ ጌትዌይ በኩል የኤስኤምኤስ ማንቂያዎችን መላክ።',
  'privacy_section_4_title': 'IV. የቡድን ግልፅነት እና ግላዊነት',
  'privacy_section_4_intro': 'በባህላዊ እቁብ ውስጥ እምነት ወሳኝ ነው። በኢቲ ዲጂታል እቁብ ላይ ግላዊነትዎን በሚከተለው መልኩ እንጠብቃለን፡',
  'privacy_section_4_confidentiality': 'ምስጢራዊነት፡ የእርስዎ ብሔራዊ መታወቂያ ቁጥር፣ የተወሰኑ የባንክ ሂሳብ ዝርዝሮች፣ እና በሌሎች ቡድኖች ውስጥ ያለዎት አጠቃላይ ቀሪ ሂሳብ በጥብቅ ምስጢራዊ ሆነው ይቆያሉ። ይህ መረጃ ለሌሎች አባላት ፈጽሞ አይጋራም።',
  'privacy_section_4_limited': 'ውስን ተጋላጭነት፡ ለቡድን ቅንጅት አስፈላጊ የሆነው መረጃ ብቻ ለሌሎች የቡድን አባላት ይታያል።',
  'privacy_section_5_title': 'V. ውሂብ ማጋራት እና ይፋ ማድረግ',
  'privacy_section_5_intro': 'የእርስዎን የግል ውሂብ ለሶስተኛ ወገኖች አንሸጥም፣ አናከራይም፣ ወይም አንነግድም። በሚከተሉት ሁኔታዎች ውስጥ ብቻ ውሂብን እናጋራለን፡',
  'privacy_section_5_regulatory': 'ተቆጣጣሪ አካላት፡ በኢትዮጵያ ብሔራዊ ባንክ (NBE) ወይም በኢትዮጵያ ኮሙኒኬሽን ባለስልጣን (ECA) ከተጠየቀ።',
  'privacy_section_5_legal': 'ህጋዊ አስፈላጊነት፡ ክፍያ መፈጸም ካልተቻለ ወይም ማጭበርበር ከተከሰተ፣ በህግ በተፈቀደው መሰረት ከህግ ተወካዮች ወይም ከተፈቀደላቸው የዕዳ ማስመለሻ አገልግሎቶች ጋር ውሂብ ልናጋራ እንችላለን።',
  'privacy_section_6_title': 'VI. የውሂብ ደህንነት እና ሉዓላዊነት',
  'privacy_section_6_storage': 'ማከማቻ፡ በተቻለ መጠን በአገር ውስጥ የኢትዮጵያ ውሂብ ማከማቻን ቅድሚያ በመስጠት፣ የእርስዎ ውሂብ ደህንነቱ በተጠበቀ አገልጋዮች ላይ ይስተናገዳል።',
  'privacy_section_6_encryption': 'ምስጠራ (Encryption)፡ ሁሉም የፋይናንስ ግንኙነቶች እና የውሂብ ዝውውሮች በኢንዱስትሪ-ደረጃ በሆነው SSL/TLS ምስጠራ ደህንነታቸው የተጠበቀ ናቸው።',
  'privacy_section_6_retention': 'ማቆየት፡ የፋይናንስ መዝገቦች በኢትዮጵያ የፋይናንስ ደንቦች በሚጠይቀው መሰረት ቢያንስ ለ10 ዓመታት ይቀመጣሉ።',
  'privacy_section_7_title': 'VII. የእርስዎ መብቶች (በአዋጅ 1321/2024 መሰረት)',
  'privacy_section_7_intro': 'የሚከተሉት መብቶች አልዎት፡',
  'privacy_section_7_access': 'መዳረሻ፡ የግል ውሂብዎን ቅጂ መጠየቅ።',
  'privacy_section_7_correction': 'እርማት፡ በመገለጫዎ ውስጥ ያለውን ትክክል ያልሆነ መረጃ ማዘመን ወይም ማረም ይችላሉ።',
  'privacy_section_7_deletion': 'መሰረዝ፡ ማንኛቸውም ንቁ የሆኑ የእቁብ ዑደቶች ከተጠናቀቁ እና አስገዳጅ የህግ ማቆያ ጊዜዎች ካለፉ በኋላ ውሂብዎ እንዲሰረዝ መጠየቅ ይችላሉ።',
  'privacy_section_7_optout': 'መውጣት፡ ለገበያ ማስተዋወቂያ ግንኙነቶች የሰጡትን ፈቃድ ማንሳት ይችላሉ።',
  'privacy_section_8_title': 'VIII. በዚህ መመሪያ ላይ የሚደረጉ ለውጦች',
  'privacy_section_8_content': 'በአሰራራችን ላይ የሚደረጉ ለውጦችን ለማንፀባረቅ ይህንን የግላዊነት መመሪያ ልናዘምነው እንችላለን። ማናቸውንም ቁልፍ ለውጦች በመተግበሪያው ወይም በኢሜይል በኩል እናሳውቆታለን። ይህንን ገጽ በየጊዜው እንዲገመግሙት እናበረታታዎታለን።',
  'privacy_section_9_title': 'IX. ያግኙን',
  'privacy_section_9_content': 'ለማንኛውም ከግላዊነት ጋር ለተያያዙ ጥያቄዎች፣ እባክዎ የኢቲ ዲጂታል እቁብ የቅሬታ ሰሚ ሀላፊን ያግኙ፡',
  'privacy_contact_office': 'ቢሮ፡',
  'privacy_contact_phone': 'ስልክ፡',
  'privacy_contact_email': 'ኢሜይል፡',
"""

filepath = 'lib/translations/am_et.dart'
with open(filepath, 'r') as f:
    content = f.read()

# Replace the last closing brace with the new keys + closing brace
# Assuming it ends with `};\n` or similar
if '};\n' in content:
    new_content = content.replace('};\n', amharic_keys + '};\n', 1)
elif '}' in content[-5:]:
    # Find last brace
    idx = content.rfind('}')
    new_content = content[:idx] + amharic_keys + content[idx:]
else:
    print("Could not find closing brace")
    exit(1)

with open(filepath, 'w') as f:
    f.write(new_content)

print("Injected successfully!")
