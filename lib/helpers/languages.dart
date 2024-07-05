import 'package:get/get.dart';

class Langugae extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'title' : 'My Shetra',
      'language title' : 'Choose your preferred language',
      'language subtitle' : ''
    },
    'hi_IN' : {
      'title' : 'मेरा शेत्र',
      'language title' : 'अपनी पसंदीदा भाषा चुनें',
      'language subtitle' : 'सुविधा के लिए अनुवाद उपलब्ध कराये गये हैं। हम निरंतर सुधार के लिए प्रतिबद्ध हैं। आधिकारिक ऐप के नियम और शर्तें केवल अंग्रेज़ी में मान्य हैं।'
    }
  };
}
