import 'package:get/get.dart';

class Language extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'app_header_title': 'My Shetra',
          'choose_language_snackbar_title': 'Choose Language',
          'choose_language_snackbar_sub_title':
              'Please select language as per your choice',
          'choose_language_snackbar_submit_button': 'Choose',
          'choose_language_snackbar_english_option': 'English',
          'choose_language_snackbar_hindi_option': 'Hindi',
          'choose_language_snackbar_punjabi_option': 'Punjabi',
          'initial_screen_title': 'Together we shape future',
          'initial_screen_sub_title': 'Some sub title',
          'initial_screen_signup_button_text': 'Sign Up',
          'initial_screen_login_button_text': 'Login',
          'login_screen_title': 'Login Your Account',
          'valid_up_to': 'Valid up to @time seconds',
          'resend_otp': 'Resend OTP',
          'attempts_left': 'You have @attempts Attempts left',
          'login_screen_sub_title':
              'Please enter your number to sign up in shetra account',
          'login_screen_mobile_input_placeholder': 'Enter your phone number',
          'login_screen_mobile_submit_button_text': 'Log In',
          'login_screen_donot_have_account_question': 'Don’t have an account?',
          'login_screen_signup_hyperlink_text': 'Sign Up',
          'verify_login_otp_title': 'Verify login details',
          'mobile_number_available': 'Mobile number available',
          'mobile_not_number_available': 'Mobile number not available',
          'verify_login_otp_sub_title': 'We have sent a verification code to',
          'verify_login_resend_counter_text':
              'You can resend the code in 56 seconds',
          'verify_login_resend_hyperlink': 'Resend Code',
          'verify_login_resend_attempt_prefix': 'You have',
          'verify_login_resend_attempt_suffix': 'Attempts Left',
          'verify_login_otp_check_button_text': 'Check',
          'create_account_title': 'Personal Details',
          'create_account_sub_title': 'Please enter your details',
          'create_account_full_name_placeholder': 'Enter your full name',
          'create_account_mobile_number_placeholder': 'Enter Phone Number',
          'create_account_gender_select_placeholder': 'Select your gender',
          'create_account_dob_select_placeholder': 'Enter your Date of Birth',
          'create_account_dob_modal_text': 'Select Date of Birth',
          'create_account_button_text': 'Create Account',
          'signup_screen_already_have_account_question':
              'Already have an account?',
          'signup_screen_login_hyperlink_text': 'Login',
          'signup_screen_signup_conditions_pretext':
              'By signing up, you agree to our',
          'signup_screen_signup_conditions_terms_hyperlink': 'Terms',
          'signup_screen_signup_conditions_policy_hyperlink': 'Privacy Policy',
          'signup_screen_signup_conditions_separator': 'and',
          'signup_screen_signup_conditions_cookie_use_hyperlink': 'Cookie Use',
          'choose_location_title': 'Select your Shetra',
          'choose_location_sub_title':
              "Discover what's happening and connect with representatives in your Shetra",
          'choose_location_snackbar_title': 'Your Representatives',
          'choose_location_snackbar_not_your_representatives_text':
              'Not your representatives?',
          'choose_location_snackbar_no_representative_text': 'No representative found in your Area',
          'choose_location_snackbar_enter_manually_text': 'Choose manually',
          'choose_location_snackbar_button_text': 'Next',
          'choose_location_manually_snackbar_title': 'Enter Manually',
          'choose_location_manually_snackbar_state_placeholder': 'Select State',
          'choose_location_manually_snackbar_district_placeholder':
              'Select District',
          'choose_location_manually_snackbar_sub_district_placeholder':
              'Select Sub District',
          'choose_location_manually_snackbar_ward_placeholder':
              'Select Ward',
          'choose_location_manually_snackbar_button_text':
              'Check Representatives',
          'select_organization_title': 'Party Details',
          'select_organization_sub_title':
              'If you belong to any party, please select and upload the proof for the same',
          'select_organization_select_placeholder': 'Select Organization',
          'select_organization_upload_proof': 'Upload Proof',
          'select_organization_take_photo': 'Take Photo',
          'select_organization_next_button_text': 'Next',
          'select_organization_skip_button_text': 'Skip',
          'enter_position_title': 'Position Details',
          'enter_position_sub_title':
              'If you hold any position, please type and upload the proof for the same',
          'enter_position_placeholder': 'Enter the position name',
          'enter_position_upload_proof': 'Upload Proof',
          'enter_position_take_photo': 'Take Photo',
          'enter_position_next_button_text': 'Next',
          'enter_position_skip_button_text': 'Skip',
          'edit_profile_header_title': 'Profile',
          'edit_profile_name_ttitle': 'Name',
          'edit_profile_name_bio': 'Bio',
          'edit_profile_header_name_ttitle': 'Handle Name',
          'edit_profile_national_division_title': 'Parliamentary Constituency',
          'edit_profile_regional_division_title': 'Legislative Constituency',
          'edit_profile_local_division_title': 'Municipal Ward',
          'edit_profile_dob_title': 'Date of Birth',
          'edit_profile_position_title': 'Position',
          'edit_profile_organization_title': 'Party',
          'change_number': 'Change Number?', // English translation
        },
        'hi_IN': {
          'app_header_title': 'मेरा क्षेत्र',
          'choose_location_title': 'अपना क्षेत्र चुनें',
          'choose_location_sub_title':
              'अपने क्षेत्र में हो रही घटनाओं को जानें और अपने प्रतिनिधियों से जुड़ें',
          'choose_language_snackbar_submit_button': 'चुनें',
          'choose_location_snackbar_title': 'आपके प्रतिनिधि',
          'choose_location_snackbar_not_your_representatives_text':
              'आपके प्रतिनिधि नहीं?',
          'choose_location_snackbar_enter_manually_text':
              'मैन्युअल रूप से चुनें',
          'choose_language_snackbar_title': 'भाषा चुनें',
          'choose_language_snackbar_sub_title':
              'कृपया अपनी पसंद के अनुसार भाषा चुनें',
          'choose_language_snackbar_english_option': 'अंग्रेजी',
          'choose_language_snackbar_hindi_option': 'हिन्दी',
          'choose_language_snackbar_punjabi_option': 'पंजाबी',
          'initial_screen_title': 'साथ में हम भविष्य को आकार देते हैं',
          'initial_screen_sub_title': 'कुछ उपशीर्षक',
          'initial_screen_signup_button_text': 'साइन अप करें',
          'initial_screen_login_button_text': 'लॉगिन करें',
          'login_screen_title': 'अपने खाते में लॉगिन करें',
          'valid_up_to': 'मान्य @time सेकंड तक',
          'resend_otp': 'ओटीपी फिर से भेजें',
          'attempts_left': 'आपके पास @attempts प्रयास शेष हैं',
          'change_number': 'नंबर बदलें', // Hindi translation
          'login_screen_sub_title':
              'कृपया शेत्र खाते में साइन अप करने के लिए अपना नंबर दर्ज करें',
          'login_screen_mobile_input_placeholder': 'अपना फोन नंबर दर्ज करें',
          'login_screen_mobile_submit_button_text': 'लॉग इन करें',
          'login_screen_donot_have_account_question': 'खाता नहीं है?',
          'login_screen_signup_hyperlink_text': 'साइन अप करें',
          'verify_login_otp_title': 'लॉगिन विवरण सत्यापित करें',
          'verify_login_otp_sub_title':
              'हमने आपके नंबर पर एक सत्यापन कोड भेजा है',
          'verify_login_resend_counter_text':
              'आप 56 सेकंड में कोड को फिर से भेज सकते हैं',
          'verify_login_resend_hyperlink': 'कोड फिर से भेजें',
          'verify_login_resend_attempt_prefix': 'आपके पास',
          'verify_login_resend_attempt_suffix': 'प्रयास शेष हैं',
          'verify_login_otp_check_button_text': 'जांचें',
          'create_account_title': 'व्यक्तिगत जानकारी',
          'create_account_sub_title': 'कृपया अपनी जानकारी दर्ज करें',
          'create_account_full_name_placeholder': 'अपना पूरा नाम दर्ज करें',
          'create_account_mobile_number_placeholder': 'फोन नंबर दर्ज करें',
          'create_account_gender_select_placeholder': 'अपना लिंग चुनें',
          'create_account_dob_select_placeholder': 'अपनी जन्मतिथि दर्ज करें',
          'create_account_dob_modal_text': 'जन्म तिथि चुनें ',
          'create_account_button_text': 'खाता बनाएं',
          'mobile_number_available': 'मोबाइल नंबर उपलब्ध',
          'mobile_not_number_available': 'मोबाइल नंबर उपलब्ध नहीं है',
          'signup_screen_already_have_account_question': 'पहले से खाता है?',
          'signup_screen_login_hyperlink_text': 'लॉगिन करें',
          'signup_screen_signup_conditions_pretext':
              'साइन अप करने पर, आप हमारे',
          'signup_screen_signup_conditions_terms_hyperlink': 'नियमों',
          'signup_screen_signup_conditions_policy_hyperlink': 'गोपनीयता नीति',
          'signup_screen_signup_conditions_separator': 'और',
          'signup_screen_signup_conditions_cookie_use_hyperlink': 'कुकी उपयोग',
          'choose_location_snackbar_button_text': 'अगला',
          'choose_location_snackbar_no_representative_text':
              'आपके क्षेत्र में कोई प्रतिनिधि नहीं मिला',
          'choose_location_manually_snackbar_title':
              'मैन्युअल रूप से दर्ज करें',
          'choose_location_manually_snackbar_state_placeholder': 'राज्य चुनें',
          'choose_location_manually_snackbar_district_placeholder':
              'जिला चुनें',
          'choose_location_manually_snackbar_sub_district_placeholder':
              'उप जिला चुनें',
          'choose_location_manually_snackbar_ward_placeholder':
              'वार्ड चुनें',
          'choose_location_manually_snackbar_button_text':
              'प्रतिनिधियों की जांच करें',
          'select_organization_title': 'पार्टी विवरण',
          'select_organization_sub_title':
              'यदि आप किसी पार्टी से संबंधित हैं, तो कृपया चुनें और प्रमाण अपलोड करें',
          'select_organization_select_placeholder': 'संगठन चुनें',
          'select_organization_upload_proof': 'प्रमाण अपलोड करें',
          'select_organization_take_photo': 'फोटो खींचे',
          'select_organization_next_button_text': 'अगला',
          'select_organization_skip_button_text': 'छोड़ें',
          'enter_position_title': 'पद विवरण',
          'enter_position_sub_title':
              'यदि आपके पास कोई पद है, तो कृपया दर्ज करें और प्रमाण अपलोड करें',
          'enter_position_placeholder': 'पद का नाम दर्ज करें',
          'enter_position_upload_proof': 'प्रमाण अपलोड करें',
          'enter_position_take_photo': 'फोटो खींचे',
          'enter_position_next_button_text': 'अगला',
          'enter_position_skip_button_text': 'छोड़ें',
          'edit_profile_header_title': 'प्रोफ़ाइल',
          'edit_profile_name_ttitle': 'नाम',
          'edit_profile_name_bio': 'बायो',
          'edit_profile_header_name_ttitle': 'हैंडल नाम',
          'edit_profile_national_division_title': 'संसदीय क्षेत्र',
          'edit_profile_regional_division_title': 'विधानसभा क्षेत्र',
          'edit_profile_local_division_title': 'नगर पालिका वार्ड',
          'edit_profile_dob_title': 'जन्म तिथि',
          'edit_profile_position_title': 'पद',
          'edit_profile_organization_title': 'पार्टी',
        },
        'pa_IN': {
          'app_header_title': 'ਮੇਰਾ ਖੇਤਰ',
          'choose_language_snackbar_title': 'ਭਾਸ਼ਾ ਚੁਣੋ',
          'choose_language_snackbar_sub_title':
              'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣੀ ਪਸੰਦ ਦੇ ਅਨੁਸਾਰ ਭਾਸ਼ਾ ਚੁਣੋ',
          'choose_language_snackbar_submit_button': 'ਚੁਣੋ',
          'choose_language_snackbar_english_option': 'ਅੰਗਰੇਜ਼ੀ',
          'choose_language_snackbar_hindi_option': 'ਹਿੰਦੀ',
          'choose_language_snackbar_punjabi_option': 'ਪੰਜਾਬੀ',
          'initial_screen_title': 'ਸਾਥ ਵਿੱਚ ਅਸਤਿਤਵ ਨੂੰ ਸ਼ਕਲ ਦਿਓ',
          'initial_screen_sub_title': 'ਕੁਝ ਉਪ ਸਿਰਲੇਖ',
          'initial_screen_signup_button_text': 'ਸਾਈਨ ਅਪ ਕਰੋ',
          'initial_screen_login_button_text': 'ਲੌਗਿਨ ਕਰੋ',
          'login_screen_title': 'ਆਪਣੇ ਖਾਤੇ ਵਿੱਚ ਲੌਗਿਨ ਕਰੋ',
          'change_number': 'ਨੰਬਰ ਬਦਲੋ', // Punjabi translation
          'login_screen_sub_title':
              'ਸ਼ੇਤਰ ਖਾਤੇ ਵਿੱਚ ਸਾਈਨ ਅਪ ਕਰਨ ਲਈ ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਨੰਬਰ ਦਰਜ ਕਰੋ',
          'login_screen_mobile_input_placeholder': 'ਆਪਣਾ ਫੋਨ ਨੰਬਰ ਦਰਜ ਕਰੋ',
          'login_screen_mobile_submit_button_text': 'ਲੌਗਿਨ ਕਰੋ',
          'login_screen_donot_have_account_question': 'ਖਾਤਾ ਨਹੀਂ ਹੈ?',
          'login_screen_signup_hyperlink_text': 'ਸਾਈਨ ਅਪ ਕਰੋ',
          'verify_login_otp_title': 'ਲੌਗਿਨ ਵੇਰਵੇ ਪੜਤਾਲੋ',
          'verify_login_otp_sub_title':
              'ਅਸੀਂ ਤੁਹਾਡੇ ਨੰਬਰ ਤੇ ਇੱਕ ਪੜਤਾਲ ਕੋਡ ਭੇਜਿਆ ਹੈ',
          'verify_login_resend_counter_text':
              'ਤੁਸੀਂ 56 ਸਕਿੰਟ ਵਿੱਚ ਕੋਡ ਨੂੰ ਦੁਬਾਰਾ ਭੇਜ ਸਕਦੇ ਹੋ',
          'verify_login_resend_hyperlink': 'ਕੋਡ ਦੁਬਾਰਾ ਭੇਜੋ',
          'verify_login_resend_attempt_prefix': 'ਤੁਹਾਡੇ ਕੋਲ',
          'verify_login_resend_attempt_suffix': 'ਕੋਸ਼ਿਸ਼ਾਂ ਬਾਕੀ ਹਨ',
          'verify_login_otp_check_button_text': 'ਚੈੱਕ ਕਰੋ',
          'create_account_title': 'ਨਿੱਜੀ ਵੇਰਵੇ',
          'create_account_sub_title': 'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਵੇਰਵਾ ਦਰਜ ਕਰੋ',
          'create_account_full_name_placeholder': 'ਆਪਣਾ ਪੂਰਾ ਨਾਮ ਦਰਜ ਕਰੋ',
          'create_account_mobile_number_placeholder': 'ਫੋਨ ਨੰਬਰ ਦਰਜ ਕਰੋ',
          'create_account_gender_select_placeholder': 'ਆਪਣਾ ਜੈਂਡਰ ਚੁਣੋ',
          'create_account_dob_select_placeholder': 'ਆਪਣੀ ਜਨਮਤਾਰੀਖ ਦਰਜ ਕਰੋ',
          'create_account_button_text': 'ਖਾਤਾ ਬਣਾਓ',
          'signup_screen_already_have_account_question': 'ਪਹਿਲਾਂ ਤੋਂ ਖਾਤਾ ਹੈ?',
          'signup_screen_login_hyperlink_text': 'ਲੌਗਿਨ ਕਰੋ',
          'signup_screen_signup_conditions_pretext':
              'ਸਾਈਨ ਅਪ ਕਰਨ ਨਾਲ, ਤੁਸੀਂ ਸਾਡੀਆਂ',
          'valid_up_to': '@time ਸਕਿੰਟਾਂ ਲਈ ਵੈਧ ਹੈ',
          'resend_otp': 'OTP ਮੁੜ ਭੇਜੋ',
          'attempts_left': 'ਤੁਹਾਡੇ ਕੋਲ @attempts ਕੋਸ਼ਿਸ਼ਾਂ ਬਾਕੀ ਹਨ',
          'signup_screen_signup_conditions_terms_hyperlink': 'ਸ਼ਰਤਾਂ',
          'signup_screen_signup_conditions_policy_hyperlink': 'ਨਿੱਜਤਾ ਨੀਤੀ',
          'signup_screen_signup_conditions_separator': 'ਅਤੇ',
          'signup_screen_signup_conditions_cookie_use_hyperlink': 'ਕੁਕੀ ਵਰਤੋਂ',
          'choose_location_title': 'ਆਪਣਾ ਖੇਤਰ ਚੁਣੋ',
          'choose_location_sub_title':
              'ਆਪਣੇ ਖੇਤਰ ਵਿੱਚ ਹੋ ਰਹੀਆਂ ਘਟਨਾਵਾਂ ਨੂੰ ਜਾਣੋ ਅਤੇ ਆਪਣੇ ਪ੍ਰਤਿਨਿਧੀਆਂ ਨਾਲ ਜੁੜੋ',
          'choose_location_snackbar_title': 'ਤੁਹਾਡੇ ਪ੍ਰਤਿਨਿਧੀ',
          'choose_location_snackbar_not_your_representatives_text':
              'ਤੁਹਾਡੇ ਪ੍ਰਤਿਨਿਧੀ ਨਹੀਂ?',
          'choose_location_snackbar_enter_manually_text': 'ਹੱਥੋਂ ਹੱਥ ਚੁਣੋ',
          'choose_location_snackbar_button_text': 'ਅਗਲਾ',
          'choose_location_snackbar_no_representative_text':
              'ਤੁਹਾਡੇ ਖੇਤਰ ਵਿੱਚ ਕੋਈ ਨੁਮਾਇੰਦਾ ਨਹੀਂ ਮਿਲਿਆ',
          'choose_location_manually_snackbar_title': 'ਹੱਥੋਂ ਦਰਜ ਕਰੋ',
          'choose_location_manually_snackbar_state_placeholder': 'ਰਾਜ ਚੁਣੋ',
          'choose_location_manually_snackbar_district_placeholder':
              'ਜ਼ਿਲ੍ਹਾ ਚੁਣੋ',
          'choose_location_manually_snackbar_sub_district_placeholder':
              'ਉਪ-ਜ਼ਿਲ੍ਹਾ ਚੁਣੋ',
          'choose_location_manually_snackbar_ward_placeholder':
              'ਵਾਰਡ ਚੁਣੋ',
          'choose_location_manually_snackbar_button_text': 'ਪ੍ਰਤੀਨਿਧੀ ਚੈੱਕ ਕਰੋ',
          'select_organization_title': 'ਪਾਰਟੀ ਵੇਰਵਾ',
          'select_organization_sub_title':
              'ਜੇਕਰ ਤੁਸੀਂ ਕਿਸੇ ਪਾਰਟੀ ਨਾਲ ਸਬੰਧਤ ਹੋ, ਤਾਂ ਕਿਰਪਾ ਕਰਕੇ ਚੁਣੋ ਅਤੇ ਪ੍ਰਮਾਣ ਪੱਤਰ ਅੱਪਲੋਡ ਕਰੋ',
          'select_organization_select_placeholder': 'ਸੰਗਠਨ ਚੁਣੋ',
          'create_account_dob_modal_text': 'ਜਨਮ ਮਿਤੀ ਚੁਣੋ',
          'mobile_number_available': 'ਮੋਬਾਈਲ ਨੰਬਰ ਉਪਲਬਧ',
          'mobile_not_number_available': 'ਮੋਬਾਈਲ ਨੰਬਰ ਉਪਲਬਧ ਨਹੀਂ ਹੈ',
          'select_organization_upload_proof': 'ਪ੍ਰਮਾਣ ਅੱਪਲੋਡ ਕਰੋ',
          'select_organization_take_photo': 'ਫੋਟੋ ਖੀਚੋ',
          'select_organization_next_button_text': 'ਅਗਲਾ',
          'select_organization_skip_button_text': 'ਛੱਡੋ',
          'enter_position_title': 'ਪਦ ਵੇਰਵਾ',
          'enter_position_sub_title':
              'ਜੇਕਰ ਤੁਹਾਡੇ ਕੋਲ ਕੋਈ ਪਦ ਹੈ, ਤਾਂ ਕਿਰਪਾ ਕਰਕੇ ਦਰਜ ਕਰੋ ਅਤੇ ਪ੍ਰਮਾਣ ਅੱਪਲੋਡ ਕਰੋ',
          'enter_position_placeholder': 'ਪਦ ਦਾ ਨਾਮ ਦਰਜ ਕਰੋ',
          'enter_position_upload_proof': 'ਪ੍ਰਮਾਣ ਅੱਪਲੋਡ ਕਰੋ',
          'enter_position_take_photo': 'ਫੋਟੋ ਖੀਚੋ',
          'enter_position_next_button_text': 'ਅਗਲਾ',
          'enter_position_skip_button_text': 'ਛੱਡੋ',
          'edit_profile_header_title': 'ਪਰੋਫ਼ਾਈਲ',
          'edit_profile_name_ttitle': 'ਨਾਮ',
          'edit_profile_name_bio': 'बायो ਬਾਇਓ',
          'edit_profile_header_name_ttitle': 'ਹੈਂਡਲ ਨਾਮ',
          'edit_profile_national_division_title': 'ਸੰਸਦੀ ਹਲਕਾ',
          'edit_profile_regional_division_title': 'ਵਿਧਾਨ ਸਭਾ ਹਲਕਾ',
          'edit_profile_local_division_title': 'ਨਗਰ ਪਾਲਿਕਾ ਵਾਰਡ',
          'edit_profile_dob_title': 'ਜਨਮ ਤਾਰੀਖ',
          'edit_profile_position_title': 'ਪਦ',
          'edit_profile_organization_title': 'ਪਾਰਟੀ',
        },
      };
}
