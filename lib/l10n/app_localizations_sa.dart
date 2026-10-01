// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sanskrit (`sa`).
class AppLocalizationsSa extends AppLocalizations {
  AppLocalizationsSa([String locale = 'sa']) : super(locale);

  @override
  String get actionCancel => 'निरस्यताम्';

  @override
  String get actionBlock => 'निरुध्यताम्';

  @override
  String get titleBlockedNumbers => 'निरुद्धसङ्ख्याः';

  @override
  String get titleBlockNumber => 'सङ्ख्यानिरोधः';

  @override
  String get labelPhoneNumber => 'दूरभाषसङ्ख्या';

  @override
  String get hintPhoneNumberExample => 'यथा +91 98765 43210';

  @override
  String get errorNotAPhoneNumber => 'एतत् सङ्ख्या इव न भाति।';

  @override
  String msgNumberUnblocked(String number) {
    return '$number इति सङ्ख्या विमुक्ता।';
  }

  @override
  String get labelBlockUnknownCallers => 'अज्ञातसम्भाषकनिरोधः';

  @override
  String get descBlockUnknownCallers =>
      'ये सम्भाषकाः स्वसङ्ख्यां न दर्शयन्ति (गुप्ताः वा गोपनीयाः वा) तेषाम् आह्वानानि निरस्यन्ताम्।';

  @override
  String get descBlockedNumbersInfo =>
      'निरुद्धसङ्ख्याभ्यः आह्वानानि कदापि न ध्वनन्ति। यावत् SreerajP Contacts Sphere भवतः मुख्यः दूरभाषानुप्रयोगः अस्ति, सङ्ख्या च सर्वथा समाना अस्ति, तावदेव निरोधः प्रभवति।';

  @override
  String get actionAddNumber => 'सङ्ख्या योज्यताम्';

  @override
  String get descAddNumber =>
      'तस्याः सङ्ख्यायाः आह्वानानि ध्वननात् पूर्वमेव निरस्यन्ते।';

  @override
  String get emptyBlockedNumbers => 'न काऽपि सङ्ख्या निरुद्धा।';

  @override
  String labelBlockedCount(int count) {
    return 'निरुद्धाः ($count)';
  }

  @override
  String labelBlockedOn(String date) {
    return '$date दिनाङ्के निरुद्धा';
  }

  @override
  String get tooltipUnblock => 'विमुच्यताम्';

  @override
  String get titleLanguage => 'भाषा';

  @override
  String get labelSystemDefault => 'तन्त्रसिद्धम्';

  @override
  String get descLanguageSystemDefault =>
      'दूरवाण्याः भाषा आङ्ग्ला मलयाळं संस्कृतं वा चेत् सा एव उपयुज्यताम्';

  @override
  String semanticsLanguageSetting(String language) {
    return 'भाषा, सम्प्रति $language';
  }

  @override
  String get languageNameEn => 'English';

  @override
  String get languageNameMl => 'മലയാളം';

  @override
  String get languageNameSa => 'संस्कृतम्';

  @override
  String get actionSave => 'रक्ष्यताम्';

  @override
  String get actionDelete => 'लुप्यताम्';

  @override
  String get actionClose => 'पिधीयताम्';

  @override
  String get actionDone => 'समाप्तम्';

  @override
  String get actionTryAgain => 'पुनः प्रयत्यताम्';

  @override
  String get actionSkip => 'त्यज्यताम्';

  @override
  String get actionContinue => 'अनुवर्त्यताम्';

  @override
  String get actionChange => 'परिवर्त्यताम्';

  @override
  String get navContacts => 'सम्पर्काः';

  @override
  String get navDialer => 'आह्वानपटलम्';

  @override
  String get navRecents => 'इतिवृत्तम्';

  @override
  String get navTags => 'चिह्नानि';

  @override
  String get msgSwipeAgainToExit =>
      'निष्क्रमणाय पुनः दक्षिणतः अङ्गुलिः सार्यताम्।';

  @override
  String get tooltipReturnToCall => 'आह्वानं प्रति गम्यताम्';

  @override
  String get msgAddingCallToOngoing => 'प्रचलति आह्वाने अपरम् आह्वानं योज्यते…';

  @override
  String labelContactCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः',
      one: 'एकः सम्पर्कः',
    );
    return '$_temp0';
  }

  @override
  String msgTagMerged(String tag, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः स्थानान्तरिताः',
      one: 'एकः सम्पर्कः स्थानान्तरितः',
    );
    return '#$tag इत्यनेन सह एकीकृतम् ($_temp0)';
  }

  @override
  String msgTagRenamed(String tag) {
    return 'नाम #$tag इति परिवर्तितम्';
  }

  @override
  String errorCouldNotRename(String error) {
    return 'नामपरिवर्तनं न सिद्धम्: $error';
  }

  @override
  String errorCouldNotMerge(String error) {
    return 'एकीकरणं न सिद्धम्: $error';
  }

  @override
  String errorCouldNotDelete(String error) {
    return 'लोपनं न सिद्धम्: $error';
  }

  @override
  String titleDeleteTagConfirm(String tag) {
    return '#$tag लुप्यताम् वा?';
  }

  @override
  String get descDeleteUnusedTag =>
      'न कोऽपि सम्पर्कः इदं चिह्नम् उपयुङ्क्ते, अतः अन्यत् किमपि न परिवर्तते।';

  @override
  String get errorTagInUseAgain =>
      'चिह्नं पुनः उपयुज्यते — प्रथमं तस्य सम्पर्काः अपनीयन्ताम्।';

  @override
  String msgTagDeleted(String tag) {
    return '#$tag लुप्तम्';
  }

  @override
  String get actionRenameTag => 'चिह्ननाम परिवर्त्यताम्';

  @override
  String get actionMergeInto => 'एकीक्रियताम्…';

  @override
  String get descNoOtherTags => 'एकीकरणाय अन्यत् चिह्नं नास्ति।';

  @override
  String get actionDeleteTag => 'चिह्नं लुप्यताम्';

  @override
  String descRemoveContactsFirst(int count) {
    return 'प्रथमं तस्य सम्पर्काः अपनीयन्ताम् ($count)।';
  }

  @override
  String titleRenameTag(String tag) {
    return '#$tag नामपरिवर्तनम्';
  }

  @override
  String get labelTagName => 'चिह्ननाम';

  @override
  String descTagAlreadyExists(String tag) {
    return '#$tag इति चिह्नं पूर्वमेव वर्तते। उभे चिह्ने एकीभविष्यतः।';
  }

  @override
  String actionMergeIntoTag(String tag) {
    return '#$tag इत्यनेन सह एकीक्रियताम्';
  }

  @override
  String get actionRename => 'नाम परिवर्त्यताम्';

  @override
  String titleMergeTagInto(String tag) {
    return '#$tag केन सह एकीक्रियताम्?';
  }

  @override
  String get labelToneGreat => 'उत्तमम्';

  @override
  String get labelToneOkay => 'मध्यमम्';

  @override
  String get labelToneRough => 'कष्टम्';

  @override
  String get labelIntentCatchUp => 'कुशलप्रश्नः';

  @override
  String get labelIntentWork => 'कार्यम्';

  @override
  String get labelIntentScheduling => 'समयनिर्धारणम्';

  @override
  String get labelIntentFollowUp => 'अनुवर्तनम्';

  @override
  String get labelIntentFamily => 'कुटुम्बम्';

  @override
  String get labelIntentUrgent => 'आत्ययिकम्';

  @override
  String get titleHowDidItGo => 'कथम् अभवत्?';

  @override
  String labelCallWith(String name) {
    return '$name इत्यनेन सह आह्वानम्';
  }

  @override
  String get labelWhatWasItAbout => 'कस्मिन् विषये?';

  @override
  String get labelNotes => 'टिप्पण्यः';

  @override
  String get hintAnythingWorthRemembering => 'किमपि स्मर्तव्यम्?';

  @override
  String get labelAddFollowUpReminder => 'अनुस्मारकं योज्यताम्';

  @override
  String get descFollowUpSavedForReference =>
      'सन्दर्भाय रक्ष्यते — सूचनाः शीघ्रम् आगमिष्यन्ति।';

  @override
  String get hintFollowUpExample => 'यथा — अनुबन्धपत्रं प्रेषणीयम्';

  @override
  String get hintPickFollowUpTime => 'दिनाङ्कः समयश्च चीयताम् (वैकल्पिकम्)';

  @override
  String titleSendContacts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः प्रेष्यन्ताम्',
      one: 'एकः सम्पर्कः प्रेष्यताम्',
    );
    return '$_temp0';
  }

  @override
  String get errorBluetoothOff =>
      'Bluetooth निष्क्रियम्। तत् सक्रियीकृत्य पुनः प्रयत्यताम्।';

  @override
  String get errorBleUnsupported =>
      'अयं दूरभाषः Bluetooth LE द्वारा वितरितुं न शक्नोति।';

  @override
  String get errorBluetoothPermissionDenied => 'Bluetooth अनुमतिः निराकृता।';

  @override
  String get errorCouldNotStartBleShare =>
      'Bluetooth वितरणम् आरब्धुं न शक्तम्।';

  @override
  String get errorBleShareFailed => 'Bluetooth वितरणम् असफलम्।';

  @override
  String get actionReceiveViaBluetooth => 'Bluetooth द्वारा गृह्यताम्';

  @override
  String descBleReceiveHowTo(String menuItem) {
    return 'अपरस्मिन् दूरभाषे SreerajP Contacts Sphere उद्घाट्य सम्पर्कसूच्याः “$menuItem” इति चीयताम्।';
  }

  @override
  String get labelIncludePhotos => 'चित्राणि अपि योज्यन्ताम्';

  @override
  String get msgStartingBleShare => 'Bluetooth वितरणम् आरभ्यते…';

  @override
  String get msgWaitingForNearbyPhone => 'समीपस्थः दूरभाषः प्रतीक्ष्यते…';

  @override
  String get msgSending => 'प्रेष्यते…';

  @override
  String msgSendingPercent(int percent) {
    return 'प्रेष्यते… $percent%';
  }

  @override
  String get msgSent => 'प्रेषितम्।';

  @override
  String get errorBlePermissionNeeded =>
      'वितरणाय Bluetooth अनुमतिः आवश्यकी। SreerajP Contacts Sphere कृते “Nearby devices” इति अनुमन्य पुनः प्रयत्यताम्।';

  @override
  String get errorNoPhoneConnected =>
      'न कोऽपि दूरभाषः संयुक्तः। ग्राहके सज्जे सति पुनः प्रयत्यताम्।';

  @override
  String get titleIncomingTransfer => 'आगच्छत् प्रेषणम्';

  @override
  String get descNearbyDeviceWantsToSend =>
      'समीपस्थं किमपि उपकरणं भवते सम्पर्कान् प्रेषयितुम् इच्छति।';

  @override
  String get descReceiveThisTransfer => 'इदं प्रेषणं गृह्यतां वा?';

  @override
  String get actionDecline => 'प्रत्याख्यायताम्';

  @override
  String get actionAccept => 'स्वीक्रियताम्';

  @override
  String get descAuthReasonBleReceive =>
      'Bluetooth प्रेषणं स्वीकर्तुम् अभिज्ञानं प्रमाणीक्रियताम्';

  @override
  String get titleAuthenticateToReceive => 'ग्रहणाय प्रमाणीकरणम्';

  @override
  String get errorAuthFailedBle =>
      'प्रमाणीकरणम् असफलम्। पुनः प्रयत्यतां प्रेषणं वा प्रत्याख्यायताम्।';

  @override
  String get descVerifyIdentityBle =>
      'इदं Bluetooth प्रेषणं स्वीकर्तुं स्वपरिचयः प्रमाणीक्रियताम्।';

  @override
  String get labelVerifying => 'परीक्ष्यते…';

  @override
  String get titleEnterPinToReceive => 'ग्रहणाय PIN दीयताम्';

  @override
  String get errorWrongPinTryAgain => 'अशुद्धः PIN — पुनः प्रयत्यताम्';

  @override
  String get descEnterPinBle =>
      'इदं Bluetooth प्रेषणं स्वीकर्तुम् अनुप्रयोगस्य PIN दीयताम्।';

  @override
  String get errorCouldNotScheduleRetry =>
      'स्वचालितपुनराह्वानं नियोजयितुं न शक्तम्।';

  @override
  String msgAutoRetryAt(String time, String name) {
    return '$time समये $name प्रति स्वचालितपुनराह्वानम्';
  }

  @override
  String get actionView => 'दृश्यताम्';

  @override
  String get titleAllowAlarmsReminders => 'समयसूचनानुमतिः';

  @override
  String get descAlarmsPermission =>
      'अयम् अनुप्रयोगः पिहितः चेदपि निर्धारिते समये पुनराह्वानाय स्वचालितपुनराह्वानस्य “Alarms & reminders” इति अनुमतिः आवश्यकी। अनन्तरम् उद्घाट्यमाने विन्यासपटले SreerajP Contacts Sphere कृते सा सक्रियीक्रियताम्।';

  @override
  String get actionOpenSettings => 'विन्यासः उद्घाट्यताम्';

  @override
  String get errorCouldNotLaunchMessaging =>
      'सन्देशानुप्रयोगः उद्घाटयितुं न शक्तः।';

  @override
  String get titleCallUnanswered => 'अनुत्तरितम् आह्वानम्';

  @override
  String get labelOptionAutoRetry => 'प्रथमः उपायः: पुनराह्वानम्';

  @override
  String get labelOptionReachMe => 'द्वितीयः उपायः: सन्देशः';

  @override
  String actionAutoRetryIn(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes निमेषैः पुनराहूयताम्',
      one: 'एकेन निमेषेण पुनराहूयताम्',
    );
    return '$_temp0';
  }

  @override
  String get tooltipEditMessage => 'सन्देशः सम्पाद्यताम्';

  @override
  String get hintReachMeMessage => 'सन्देशः लिख्यताम्…';

  @override
  String get actionSendReachMeSms => 'सम्पर्कसन्देशः प्रेष्यताम्';

  @override
  String get actionDismiss => 'उपेक्ष्यताम्';

  @override
  String labelMinutesShort(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes निमेषाः',
      one: '1 निमेषः',
    );
    return '$_temp0';
  }

  @override
  String get labelDefaultSim => 'मुख्यं SIM';

  @override
  String get labelSimToDial => 'आह्वानाय SIM:';

  @override
  String get titleSelectSimForRetry => 'पुनराह्वानाय SIM';

  @override
  String get labelFieldName => 'नाम';

  @override
  String get labelFieldPhone => 'दूरभाषः';

  @override
  String get labelFieldEmail => 'विद्युत्पत्रम्';

  @override
  String get labelFieldDesignation => 'पदम्';

  @override
  String get labelFieldCompany => 'संस्था';

  @override
  String get labelFieldStreet => 'वीथिः';

  @override
  String get labelFieldCity => 'नगरम्';

  @override
  String get labelFieldState => 'राज्यम्';

  @override
  String get labelFieldPostalCode => 'पत्रालयसङ्केतः';

  @override
  String get labelFieldCountry => 'देशः';

  @override
  String get labelFieldLink => 'अनुबन्धः';

  @override
  String get titleReadFromCard => 'पत्रात् पठितम्';

  @override
  String get descUntickWrongFields =>
      'यत् अशुद्धं पठितं तस्य चिह्नम् अपनीयताम्। अग्रिमे पटले सर्वं पुनः सम्पादयितुं शक्यते।';

  @override
  String get emptyNoFieldsRead =>
      'अस्मात् पत्रात् किमपि क्षेत्रं पठितुं न शक्तम्।';

  @override
  String descNotPlacedInField(String lines) {
    return 'कस्मिंश्चिदपि क्षेत्रे अस्थापितम्: $lines';
  }

  @override
  String get actionHideScannedText => 'पठितः पाठः गोप्यताम्';

  @override
  String get actionShowScannedText => 'पठितः पाठः दर्श्यताम्';

  @override
  String get emptyNothingRecognized => 'न किमपि अभिज्ञातम्।';

  @override
  String get actionRetake => 'पुनः गृह्यताम्';

  @override
  String get labelRelationshipLabel => 'सम्बन्धनाम';

  @override
  String get hintRelationshipExample => 'यथा पिता';

  @override
  String get titlePickCategory => 'वर्गचयनम्';

  @override
  String titleHowIsRelated(String name) {
    return '$name इत्यस्य सम्बन्धः कः?';
  }

  @override
  String get titleLinkContact => 'सम्पर्कसंयोजनम्';

  @override
  String get hintSearchContacts => 'सम्पर्काः अन्विष्यन्ताम्';

  @override
  String get emptyNoContactsAvailable => 'न कोऽपि सम्पर्कः उपलभ्यते।';

  @override
  String titleWhereBelongs(String name) {
    return '$name कस्मिन् वर्गे अस्ति?';
  }

  @override
  String get errorAirQrPayload =>
      'अस्य सम्पर्कस्य कृते AirQR दत्तांशः निर्मातुं न शक्तः।';

  @override
  String get labelFrameParity => 'परीक्षाखण्डः';

  @override
  String get labelFrameSystematic => 'दत्तांशखण्डः';

  @override
  String descAirGapStream(int count) {
    return 'दृश्यः QR-प्रवाहः ($count खण्डाः)';
  }

  @override
  String get errorFrameRender => 'खण्डप्रदर्शने दोषः';

  @override
  String labelFrameProgress(int current, int total, String type) {
    return 'खण्डः $current / $total • $type';
  }

  @override
  String get tooltipPauseStream => 'प्रवाहः स्थग्यताम्';

  @override
  String get tooltipResumeStream => 'प्रवाहः पुनरारभ्यताम्';

  @override
  String errorCouldNotShareQr(String error) {
    return 'QR वितरितुं न शक्तम्: $error';
  }

  @override
  String get descScanToAddContact =>
      'इमं सम्पर्कं योजयितुं केनापि दूरभाषचित्रग्राहकेण इदं पठ्यताम्।';

  @override
  String get errorContactTooBigForQr =>
      'अस्मिन् सम्पर्के इयत् विवरणम् अस्ति यत् QR-सङ्केते न माति।';

  @override
  String get tooltipAirGapStream => 'पूर्णः QR-प्रवाहः';

  @override
  String get actionShare => 'वितीर्यताम्';

  @override
  String get titleScannedContact => 'पठितः सम्पर्कः';

  @override
  String get titleSecurityCheck => 'सुरक्षापरीक्षा';

  @override
  String labelContactsToImport(int count) {
    return 'आनेयाः सम्पर्काः ($count):';
  }

  @override
  String get labelUnnamedContact => 'अनामकः सम्पर्कः';

  @override
  String labelPhonesList(String numbers) {
    return 'दूरभाषाः: $numbers';
  }

  @override
  String labelEmailsList(String emails) {
    return 'विद्युत्पत्राणि: $emails';
  }

  @override
  String labelWebLinksList(String links) {
    return 'अनुबन्धाः: $links';
  }

  @override
  String get actionImportSafeOnly => 'सुरक्षितम् एव आनीयताम्';

  @override
  String get actionImport => 'आनीयताम्';

  @override
  String get actionImportAll => 'सर्वम् आनीयताम्';

  @override
  String get titleChooseContact => 'सम्पर्कचयनम्';

  @override
  String errorCouldNotLoadContacts(String error) {
    return 'सम्पर्काः आनेतुं न शक्ताः: $error';
  }

  @override
  String get tooltipClearSearch => 'अन्वेषणं रिक्तीक्रियताम्';

  @override
  String get emptyNoContactsWithNumber =>
      'सङ्ख्यायुक्तः कोऽपि सम्पर्कः अद्यापि नास्ति।';

  @override
  String get emptyNoContactsYet => 'अद्यापि कोऽपि सम्पर्कः नास्ति।';

  @override
  String emptyNoContactsMatch(String query) {
    return 'कोऽपि सम्पर्कः “$query” इत्यनेन न सङ्गच्छते।';
  }

  @override
  String get labelNoName => '(अनामकः)';

  @override
  String get emptyNoContactsFound => 'न कोऽपि सम्पर्कः प्राप्तः।';

  @override
  String get actionAdd => 'योज्यताम्';

  @override
  String get labelSuggested => 'सूचिताः';

  @override
  String get labelAllContacts => 'सर्वे सम्पर्काः';

  @override
  String get labelAlreadyAdded => 'पूर्वमेव योजितः';

  @override
  String get tooltipVoiceSearch => 'वाचा अन्वेषणम्';

  @override
  String get errorVoiceUnavailable =>
      'वाचिकनिवेशः अनुपलब्धः — ध्वनिग्राहकस्य अनुमतिः परीक्ष्यताम्।';

  @override
  String get tooltipStopListening => 'श्रवणात् विरम्यताम्';

  @override
  String get labelDefaultPhoneApp => 'मुख्यः दूरभाषानुप्रयोगः';

  @override
  String get descHandlesYourCalls =>
      'भवतः आह्वानानि SreerajP Contacts Sphere निर्वहति।';

  @override
  String get descSetAsDefaultDialer =>
      'SreerajP Contacts Sphere मुख्यः दूरभाषानुप्रयोगः क्रियताम्।';

  @override
  String get errorCallPermissionDenied => 'आह्वानानुमतिः निराकृता।';

  @override
  String errorCouldNotPlaceCall(String error) {
    return 'आह्वानं कर्तुं न शक्तम्: $error';
  }

  @override
  String get labelUsualSimForCall => 'अस्य आह्वानस्य सामान्यं SIM';

  @override
  String get titleCallWith => 'आह्वानसाधनम्';

  @override
  String get descChooseSimForCall => 'अस्य आह्वानस्य कृते SIM चीयताम्।';

  @override
  String titleCallName(String name) {
    return '$name आहूयताम्';
  }

  @override
  String get descChooseNumber => 'सङ्ख्या चीयताम्';

  @override
  String get actionYes => 'आम्';

  @override
  String get actionNo => 'न';

  @override
  String get tooltipSettings => 'विन्यासः';

  @override
  String get labelToday => 'अद्य';

  @override
  String get labelYesterday => 'ह्यः';

  @override
  String labelDurationSeconds(int seconds) {
    return '$seconds क्ष.';
  }

  @override
  String labelDurationMinutes(int minutes) {
    return '$minutes नि.';
  }

  @override
  String labelDurationMinutesSeconds(int minutes, int seconds) {
    return '$minutes नि. $seconds क्ष.';
  }

  @override
  String get labelOutcomeMissed => 'अगृहीतम्';

  @override
  String get labelOutcomeNoAnswer => 'अनुत्तरितम्';

  @override
  String get labelOutcomeBusy => 'व्यस्तम्';

  @override
  String get labelOutcomeDeclined => 'प्रत्याख्यातम्';

  @override
  String get labelOutcomeCancelled => 'निरस्तम्';

  @override
  String get labelOutcomeFailed => 'असफलम्';

  @override
  String get labelBlocked => 'निरुद्धम्';

  @override
  String get titleClearCallHistory => 'आह्वानेतिवृत्तं रिक्तीक्रियतां वा?';

  @override
  String get descClearCallHistory =>
      'SreerajP Contacts Sphere इत्यस्मिन् अभिलिखितानि सर्वाणि आह्वानानि अनेन अपनीयन्ते।';

  @override
  String get tooltipClearHistory => 'इतिवृत्तं रिक्तीक्रियताम्';

  @override
  String get hintSearchCalls => 'आह्वानानि अन्विष्यन्ताम्';

  @override
  String get emptyNoCallsYet =>
      'अद्यापि किमपि आह्वानं नास्ति। भवता कृतानि आह्वानानि अत्र दृश्यन्ते।';

  @override
  String get emptyNoCallsMatch => 'अनेन अन्वेषणेन किमपि आह्वानं न सङ्गच्छते।';

  @override
  String get tooltipCallBack => 'प्रत्याहूयताम्';

  @override
  String get actionBlockNumber => 'सङ्ख्या निरुध्यताम्';

  @override
  String get actionUnblockNumber => 'सङ्ख्या विमुच्यताम्';

  @override
  String get actionMarkAsSpam => 'अवाञ्छितम् इति चिह्न्यताम्';

  @override
  String get actionNotSpam => 'अवाञ्छितं न';

  @override
  String get actionSmartRedialReachMe => 'पुनराह्वानं सन्देशश्च';

  @override
  String get actionCopyNumber => 'सङ्ख्या प्रतिलिख्यताम्';

  @override
  String get actionShareNumber => 'सङ्ख्या वितीर्यताम्';

  @override
  String get actionRemoveFromHistory => 'इतिवृत्तात् अपनीयताम्';

  @override
  String msgNumberBlocked(String number) {
    return '$number निरुद्धा — इतः परं ततः आह्वानं न आगमिष्यति।';
  }

  @override
  String msgMarkedAsSpam(String number) {
    return '$number अवाञ्छिता इति चिह्निता।';
  }

  @override
  String msgNoLongerSpam(String number) {
    return '$number इतः परम् अवाञ्छिता इति न चिह्निता।';
  }

  @override
  String msgCopiedNumber(String number) {
    return '$number प्रतिलिखितम्।';
  }

  @override
  String msgSpeedDialAssigned(String slot, String name) {
    return '$slot इति कुञ्चिका इतः परं $name आह्वास्यति।';
  }

  @override
  String msgCallingName(String name) {
    return '$name आहूयते…';
  }

  @override
  String get actionHideKeypad => 'सङ्ख्यापटलं गोप्यताम्';

  @override
  String get tooltipBack => 'प्रत्यागमनम्';

  @override
  String get titleKeypadDtmf => 'सङ्ख्यापटलम् (DTMF)';

  @override
  String get titleAddCall => 'आह्वानयोजनम्';

  @override
  String get tooltipMore => 'अधिकम्';

  @override
  String get titleSettings => 'विन्यासः';

  @override
  String get hintStartTypingToFind => 'सम्पर्कम् अन्वेष्टुं टङ्क्यताम्';

  @override
  String get tooltipVoiceDialing => 'वाचा आह्वानम्';

  @override
  String labelMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्राप्तानि',
      one: 'एकं प्राप्तम्',
    );
    return '$_temp0';
  }

  @override
  String get emptyNoContactForNumber =>
      'अस्याः सङ्ख्यायाः रक्षितः सम्पर्कः अद्यापि नास्ति।';

  @override
  String emptyNoVoiceMatch(String query) {
    return '“$query” इत्यनेन कोऽपि सम्पर्कः न सङ्गच्छते।';
  }

  @override
  String labelHeardQuery(String query) {
    return 'श्रुतम्: “$query”';
  }

  @override
  String get emptyStarContact => 'अत्र द्रष्टुं सम्पर्कः तारकेण चिह्न्यताम्।';

  @override
  String get labelFavorites => 'प्रियाणि';

  @override
  String get labelFamilyFriends => 'बन्धुमित्राणि';

  @override
  String get labelLikelyToAnswer => 'इदानीं सुलभाः';

  @override
  String get labelTopContacts => 'प्रमुखाः सम्पर्काः';

  @override
  String get actionAddToContacts => 'सम्पर्केषु योज्यताम्';

  @override
  String get tooltipCall => 'आहूयताम्';

  @override
  String get tooltipBackspace => 'लोपः (दीर्घस्पर्शेन निरन्तरम्)';

  @override
  String get labelUnknownCaller => 'अज्ञातः';

  @override
  String get labelIncomingCall => 'आगच्छत् आह्वानम्';

  @override
  String get labelCalling => 'आहूयते…';

  @override
  String get labelOnHold => 'स्थगितम्';

  @override
  String get labelCallEnded => 'आह्वानं समाप्तम्';

  @override
  String get labelConnected => 'संयुक्तम्';

  @override
  String get labelSecondCall => 'द्वितीयम् आह्वानम्';

  @override
  String get tooltipTapToSwitchCall => 'आह्वानपरिवर्तनाय स्पृश्यताम्';

  @override
  String labelNameOnHold(String name) {
    return '$name — स्थगितम्';
  }

  @override
  String get labelAboutThisContact => 'सम्पर्कविवरणम्';

  @override
  String get labelWhyCalling => 'आह्वानकारणम्';

  @override
  String get labelCallerIdNotVerified => 'सम्भाषकः अप्रमाणितः';

  @override
  String get labelReply => 'प्रत्युत्तरम्';

  @override
  String get labelMute => 'मौनम्';

  @override
  String get labelHold => 'स्थगनम्';

  @override
  String get labelSpeaker => 'ध्वनिवर्धकः';

  @override
  String get labelKeypad => 'सङ्ख्यापटलम्';

  @override
  String get labelMerge => 'एकीकरणम्';

  @override
  String get labelSwap => 'विनिमयः';

  @override
  String get labelConferenceCall => 'सम्मेलनाह्वानम्';

  @override
  String labelConferencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जनाः',
      one: 'एकः जनः',
    );
    return '$_temp0';
  }

  @override
  String get labelManage => 'प्रबन्धः';

  @override
  String get titlePeopleOnCall => 'अस्मिन् आह्वाने जनाः';

  @override
  String get actionPrivate => 'एकान्तम्';

  @override
  String get actionDrop => 'अपनय';

  @override
  String get tooltipPrivateTalk => 'अनेन जनेन सह एकान्ते वद';

  @override
  String get tooltipDropFromCall => 'एनं जनम् आह्वानात् अपनय';

  @override
  String get labelBlock => 'निरोधः';

  @override
  String get titleUnblockThisNumber => 'इयं सङ्ख्या विमुच्यतां वा?';

  @override
  String get titleBlockThisNumber => 'इयं सङ्ख्या निरुध्यतां वा?';

  @override
  String descUnblockNumber(String number) {
    return '$number इत्यस्याः आह्वानानि पुनः यथापूर्वं ध्वनिष्यन्ति।';
  }

  @override
  String descBlockNumberFuture(String number) {
    return '$number इत्यस्याः भावीनि आह्वानानि भवतः दूरभाषस्य ध्वननात् पूर्वमेव निरस्यन्ते।';
  }

  @override
  String get descCallWillDisconnect => 'इदम् आह्वानं सद्य एव विच्छिद्यते।';

  @override
  String get descManageBlockedNumbers =>
      'विन्यासः → सम्पर्काः → निरुद्धसङ्ख्याः इत्यत्र निरुद्धसङ्ख्याः व्यवस्थापयितुं शक्यन्ते।';

  @override
  String get actionUnblock => 'विमुच्यताम्';

  @override
  String get titleReplyWithMessage => 'सन्देशेन प्रत्युत्तरम्';

  @override
  String get descDeclinesAndTexts =>
      'आह्वानं प्रत्याख्याय सम्भाषकाय सन्देशं प्रेषयति।';

  @override
  String get actionWriteYourOwn => 'स्वयं लिख्यताम्…';

  @override
  String get titleReplyWith => 'प्रत्युत्तरम्…';

  @override
  String get labelMessage => 'सन्देशः';

  @override
  String get hintTypeMessageToSend => 'प्रेषणीयः सन्देशः लिख्यताम्';

  @override
  String get actionSend => 'प्रेष्यताम्';

  @override
  String get actionHide => 'गोप्यताम्';

  @override
  String get errorRingtoneMissing =>
      'अयम् आह्वानध्वनिः इदानीं न उपलभ्यते — सम्पादने नूतनः चीयताम्।';

  @override
  String get errorRingVolumeMuted =>
      'ध्वनिस्तरः मौनः — श्रोतुं ध्वनिः वर्ध्यताम्।';

  @override
  String get actionShareVcard => 'vCard (.vcf) वितरणम्';

  @override
  String get descShareVcard =>
      'सम्पर्कपत्रं WhatsApp अन्यं वा कमपि अनुप्रयोगं प्रति प्रेष्यताम्।';

  @override
  String get actionShareAsText => 'पाठरूपेण वितीर्यताम्';

  @override
  String get descShareAsText =>
      'नाम दूरभाषसङ्ख्याश्च सन्देशरूपेण प्रेष्यन्ताम्।';

  @override
  String get actionCopyNamePhone => 'नाम दूरभाषश्च प्रतिलिख्यताम्';

  @override
  String get descCopyContactDetails => 'सम्पर्कविवरणं प्रतिलिख्यताम्।';

  @override
  String get actionShareAsQr => 'QR-सङ्केतेन वितीर्यताम्';

  @override
  String get descShareAsQr =>
      'पठनीयः सङ्केतः दर्श्यतां चित्ररूपेण वा प्रेष्यताम्।';

  @override
  String get actionShareViaBluetooth => 'Bluetooth द्वारा वितीर्यताम्';

  @override
  String get descSendToNearbyPhone =>
      'समीपस्थं दूरभाषं प्रति साक्षात् प्रेष्यताम्।';

  @override
  String errorCouldNotShareContact(String error) {
    return 'सम्पर्कः वितरितुं न शक्तः: $error';
  }

  @override
  String errorCouldNotShareText(String error) {
    return 'पाठः वितरितुं न शक्तः: $error';
  }

  @override
  String get msgContactDetailsCopied => 'सम्पर्कविवरणं प्रतिलिखितम्।';

  @override
  String errorCouldNotCopyDetails(String error) {
    return 'सम्पर्कविवरणं प्रतिलेखितुं न शक्तम्: $error';
  }

  @override
  String errorCouldNotCopyNumber(String error) {
    return 'सङ्ख्या प्रतिलेखितुं न शक्ता: $error';
  }

  @override
  String errorFailedToLoadContact(String error) {
    return 'सम्पर्कः आनेतुं न शक्तः: $error';
  }

  @override
  String get errorCouldNotOpenApp => 'अयम् अनुप्रयोगः उद्घाटयितुं न शक्तः।';

  @override
  String errorCouldNotUpdateFavorite(String error) {
    return 'प्रियसूची अद्यतनीकर्तुं न शक्ता: $error';
  }

  @override
  String titleDeleteContactConfirm(String name) {
    return '$name लुप्यतां वा?';
  }

  @override
  String get descDeleteContactAndDevice =>
      'अयं सम्पर्कः अनुप्रयोगात् दूरभाषस्य सम्पर्कसूच्याः च अपनीयते।';

  @override
  String get descDeleteContactApp => 'अयं सम्पर्कः अनुप्रयोगात् अपनीयते।';

  @override
  String errorDeleteFailed(String error) {
    return 'लोपनम् असफलम्: $error';
  }

  @override
  String get labelContact => 'सम्पर्कः';

  @override
  String get tooltipAddToFavorites => 'प्रियेषु योज्यताम्';

  @override
  String get tooltipRemoveFromFavorites => 'प्रियेभ्यः अपनीयताम्';

  @override
  String get actionEdit => 'सम्पाद्यताम्';

  @override
  String get actionRemove => 'अपनीयताम्';

  @override
  String get emptyContactNotFound => 'सम्पर्कः न प्राप्तः।';

  @override
  String get labelBirthday => 'जन्मदिनम्';

  @override
  String get labelAnniversary => 'विवाहवार्षिकम्';

  @override
  String get labelMeetiversary => 'परिचयवार्षिकम्';

  @override
  String get labelGender => 'लिङ्गम्';

  @override
  String get labelFormalName => 'औपचारिकं नाम';

  @override
  String get labelBloodGroup => 'रक्तवर्गः';

  @override
  String get labelCustomRingtone => 'विशिष्टः आह्वानध्वनिः';

  @override
  String get labelRingtone => 'आह्वानध्वनिः';

  @override
  String get tooltipStop => 'विरम्यताम्';

  @override
  String get tooltipPreview => 'श्रूयताम्';

  @override
  String get labelChosenSim => 'चितं SIM';

  @override
  String get descCallsGoOutOnSim => 'आह्वानानि अनेन SIM द्वारा गच्छन्ति।';

  @override
  String get labelCallingCard => 'आह्वानपत्रम्';

  @override
  String get labelRelationships => 'सम्बन्धाः';

  @override
  String get tooltipViewSphere => 'सम्बन्धमण्डलं दृश्यताम्';

  @override
  String get tooltipAddRelationship => 'सम्बन्धः योज्यताम्';

  @override
  String get emptyNoRelationships =>
      'अद्यापि कोऽपि सम्बन्धः नास्ति। सम्पर्कं संयोजयितुम् अनुबन्धचिह्नं स्पृश्यताम्।';

  @override
  String get tooltipEditType => 'प्रकारः सम्पाद्यताम्';

  @override
  String get labelConnectedApps => 'संयुक्ताः अनुप्रयोगाः';

  @override
  String get descBirthdayComingUp => '🎂 सप्ताहाभ्यन्तरे जन्मदिनम्।';

  @override
  String descLastCall(String duration) {
    return 'अन्तिमम् आह्वानम्: $duration';
  }

  @override
  String descTheirTime(String time) {
    return 'तेषां समयः: $time';
  }

  @override
  String descRecentInteractions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अद्यतनाः संवादाः',
      one: 'एकः अद्यतनः संवादः',
    );
    return '$_temp0';
  }

  @override
  String get labelBeforeYouCall => 'आह्वानात् पूर्वम्';

  @override
  String descEphemeralAutoDelete(int count) {
    return 'एकस्मात् आह्वानात् परं स्वयं लुप्यते ($count/1 आह्वानम् अभिलिखितम्)।';
  }

  @override
  String get descEphemeralExpired => 'अवधिः समाप्तः — शीघ्रं स्वयं लुप्यते…';

  @override
  String descEphemeralCountdown(String hours, String minutes, String seconds) {
    return 'स्वयं लोपात् पूर्वम्: $hours होराः $minutes निमेषाः $seconds क्षणाः';
  }

  @override
  String get labelEphemeralContact => 'अल्पकालिकः सम्पर्कः';

  @override
  String get labelSqlcipherLocalOnly => 'SQLCipher · केवलम् अत्र';

  @override
  String get actionAdd24Hours => '+24 होराः';

  @override
  String get actionKeepPermanently => 'स्थायित्वेन रक्ष्यताम्';

  @override
  String get actionScrubNow => 'इदानीं लुप्यताम्';

  @override
  String get errorAuthRequiredSecret =>
      'गुप्तसम्पर्कान् द्रष्टुं प्रमाणीकरणम् आवश्यकम्।';

  @override
  String msgDeletedName(String name) {
    return '$name इति सम्पर्कः लुप्तः';
  }

  @override
  String titleDeleteContactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः लुप्यन्तां वा?',
      one: 'एकः सम्पर्कः लुप्यतां वा?',
    );
    return '$_temp0';
  }

  @override
  String get descDeleteSelected =>
      'एते अनुप्रयोगात्, संयुक्ताः चेत् दूरभाषस्य सम्पर्कसूच्याः अपि, अपनीयन्ते।';

  @override
  String msgDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः लुप्ताः',
      one: 'एकः सम्पर्कः लुप्तः',
    );
    return '$_temp0';
  }

  @override
  String msgDeletedCountFailed(int deleted, int failed) {
    return '$deleted लुप्ताः, $failed असफलाः';
  }

  @override
  String errorNoPhoneFor(String name) {
    return '$name इत्यस्य दूरभाषसङ्ख्या नास्ति।';
  }

  @override
  String errorNoEmailFor(String name) {
    return '$name इत्यस्य विद्युत्पत्रसङ्केतः नास्ति।';
  }

  @override
  String get errorNoEmailApp => 'विद्युत्पत्रानुप्रयोगः नोपलभ्यते।';

  @override
  String get errorCouldNotOpenEmail =>
      'विद्युत्पत्रानुप्रयोगः उद्घाटयितुं न शक्तः।';

  @override
  String get titleImportExport => 'आनयनम् / निर्यापणम्';

  @override
  String get actionImportCsv => 'CSV आनीयताम्';

  @override
  String get actionExportCsv => 'CSV निर्याप्यताम्';

  @override
  String get actionImportVcf => 'vCard (.vcf) आनीयताम्';

  @override
  String get actionExportVcf => 'vCard (.vcf) निर्याप्यताम्';

  @override
  String get titleBluetoothTransfer => 'Bluetooth प्रेषणम्';

  @override
  String get actionSendAllViaBluetooth => 'सर्वं Bluetooth-प्रेषणम्';

  @override
  String msgImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः आनीताः',
      one: 'एकः सम्पर्कः आनीतः',
    );
    return '$_temp0';
  }

  @override
  String get msgNothingImported => 'न किमपि आनीतम्।';

  @override
  String errorImportFailed(String error) {
    return 'आनयनम् असफलम्: $error';
  }

  @override
  String errorExportFailed(String error) {
    return 'निर्यापणम् असफलम्: $error';
  }

  @override
  String get errorNoContactsToSend => 'प्रेषणाय कोऽपि सम्पर्कः नास्ति।';

  @override
  String errorCouldNotStartBleShareDetail(String error) {
    return 'Bluetooth वितरणम् आरब्धुं न शक्तम्: $error';
  }

  @override
  String get tooltipSecretContacts => 'गुप्तसम्पर्काः';

  @override
  String get tooltipRelationStatus => 'सम्बन्धस्थितिः';

  @override
  String get tooltipGroups => 'समूहाः';

  @override
  String get actionMyProfile => 'मम परिचयः';

  @override
  String get actionScanQrCode => 'QR-सङ्केतः पठ्यताम्';

  @override
  String get actionScanBusinessCard => 'व्यापारपत्रं पठ्यताम्';

  @override
  String get actionFindDuplicates => 'द्विरुक्तानि अन्विष्यन्ताम्';

  @override
  String get tooltipCancelSelection => 'चयनं निरस्यताम्';

  @override
  String labelSelectedCount(int count) {
    return '$count चितानि';
  }

  @override
  String get tooltipSelectAll => 'सर्वं चीयताम्';

  @override
  String get tooltipDeleteSelected => 'चितानि लुप्यन्ताम्';

  @override
  String get labelAll => 'सर्वे';

  @override
  String msgSyncingContacts(int processed, int total) {
    return 'सम्पर्काः समन्वीयन्ते… $total मध्ये $processed';
  }

  @override
  String get msgReadingDeviceContacts => 'दूरभाषस्य सम्पर्काः पठ्यन्ते…';

  @override
  String get emptyNoFavorites =>
      'अद्यापि प्रियं किमपि नास्ति।\nअत्र द्रष्टुं सम्पर्कः तारकेण चिह्न्यताम्।';

  @override
  String get emptyNoContactsTapPlus =>
      'अद्यापि कोऽपि सम्पर्कः नास्ति। योजयितुं + स्पृश्यताम्।';

  @override
  String get labelOneCallBadge => '⏱️ एकाह्वानम्';

  @override
  String get labelEphemeralBadge => '⏱️ अल्पकालिकः';

  @override
  String get labelYou => 'भवान्';

  @override
  String get labelProfile => 'परिचयः';

  @override
  String labelDaysAgo(int count) {
    return '$count दिनेभ्यः पूर्वम्';
  }

  @override
  String labelWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सप्ताहेभ्यः पूर्वम्',
      one: 'एकसप्ताहात् पूर्वम्',
    );
    return '$_temp0';
  }

  @override
  String labelMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मासेभ्यः पूर्वम्',
      one: 'एकमासात् पूर्वम्',
    );
    return '$_temp0';
  }

  @override
  String labelYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वर्षेभ्यः पूर्वम्',
      one: 'एकवर्षात् पूर्वम्',
    );
    return '$_temp0';
  }

  @override
  String get labelTypeMobile => 'चलदूरभाषः';

  @override
  String get labelTypeHome => 'गृहम्';

  @override
  String get labelTypeWork => 'कार्यालयः';

  @override
  String get labelTypeMain => 'मुख्यम्';

  @override
  String get labelTypeFax => 'दूरप्रतिलिपिः';

  @override
  String get labelTypeOther => 'अन्यत्';

  @override
  String get labelTypePersonal => 'वैयक्तिकम्';

  @override
  String get labelTypeSchool => 'विद्यालयः';

  @override
  String get labelTypeWebsite => 'जालस्थानम्';

  @override
  String get labelGenderMale => 'पुरुषः';

  @override
  String get labelGenderFemale => 'स्त्री';

  @override
  String get labelGenderNonBinary => 'अद्विलिङ्गम्';

  @override
  String get labelGenderPreferNotToSay => 'न वक्तव्यम्';

  @override
  String get labelAddressPersonal => 'वैयक्तिकसङ्केतः';

  @override
  String get labelAddressOfficial => 'कार्यालयसङ्केतः';

  @override
  String errorCouldNotPickImage(String error) {
    return 'चित्रं चेतुं न शक्तम्: $error';
  }

  @override
  String errorCouldNotPickCard(String error) {
    return 'आह्वानपत्रं चेतुं न शक्तम्: $error';
  }

  @override
  String get actionTakePhoto => 'चित्रं गृह्यताम्';

  @override
  String get actionChooseFromGallery => 'चित्रकोशात् चीयताम्';

  @override
  String get errorCameraPermission =>
      'चित्रग्रहणाय चित्रग्राहकानुमतिः आवश्यकी।';

  @override
  String errorCouldNotPickRingtone(String error) {
    return 'आह्वानध्वनिः चेतुं न शक्तः: $error';
  }

  @override
  String get titlePhoneRingtones => 'दूरभाषस्य ध्वनयः';

  @override
  String get descPhoneRingtones => 'अस्य दूरभाषस्य आह्वानध्वनिभ्यः चीयताम्।';

  @override
  String get titleAudioFile => 'श्रव्यसञ्चिका';

  @override
  String get descAudioFile => 'स्वसम्पुटेभ्यः श्रव्यसञ्चिका चीयताम्।';

  @override
  String get errorRingtoneRevert =>
      'अयम् आह्वानध्वनिः इदानीं न उपलभ्यते — मूलध्वनिः पुनः प्रयुज्यते।';

  @override
  String get titleRemovePhone => 'दूरभाषसङ्ख्या अपनीयतां वा?';

  @override
  String get descRemovePhone => 'इयं दूरभाषसङ्ख्या सम्पर्कात् अपनीयते।';

  @override
  String get titleRemoveEmail => 'विद्युत्पत्रम् अपनीयतां वा?';

  @override
  String get descRemoveEmail => 'इदं विद्युत्पत्रं सम्पर्कात् अपनीयते।';

  @override
  String get titleRemoveSocialLink => 'सामाजिकानुबन्धः अपनीयतां वा?';

  @override
  String get descRemoveSocialLink => 'अयं सामाजिकानुबन्धः सम्पर्कात् अपनीयते।';

  @override
  String get errorFirstNameRequired => 'प्रथमं नाम आवश्यकम्।';

  @override
  String errorInvalidPhoneNumber(String number, String reason) {
    return 'अमान्या दूरभाषसङ्ख्या: $number ($reason)';
  }

  @override
  String get errorPhoneEmpty => 'सङ्ख्या रिक्ता';

  @override
  String get errorPhoneTooShort => 'सङ्ख्या अतिह्रस्वा';

  @override
  String get errorPhoneTooLong => 'सङ्ख्या अतिदीर्घा';

  @override
  String errorPhoneInvalidFormatFor(String code) {
    return '+$code कृते सङ्ख्यारूपम् अशुद्धम्';
  }

  @override
  String get errorPhoneInvalidFormat => 'सङ्ख्यारूपम् अशुद्धम्';

  @override
  String errorSaveFailed(String error) {
    return 'रक्षणम् असफलम्: $error';
  }

  @override
  String get labelPhoneNumbers => 'दूरभाषसङ्ख्याः';

  @override
  String get actionAddPhone => 'दूरभाषसङ्ख्या योज्यताम्';

  @override
  String get labelEmails => 'विद्युत्पत्राणि';

  @override
  String get actionAddEmail => 'विद्युत्पत्रं योज्यताम्';

  @override
  String get labelSocialLinks => 'सामाजिकानुबन्धाः';

  @override
  String get hintUrlOrHandle => 'URL @नाम वा';

  @override
  String get actionAddSocialLink => 'सामाजिकानुबन्धः योज्यताम्';

  @override
  String get titleEditMe => 'मम सम्पादनम्';

  @override
  String get titleAddMe => 'मम योजनम्';

  @override
  String get titleEditContact => 'सम्पर्कसम्पादनम्';

  @override
  String get titleAddContact => 'सम्पर्कयोजनम्';

  @override
  String get actionChangePhoto => 'चित्रं परिवर्त्यताम्';

  @override
  String get actionAddPhoto => 'चित्रं योज्यताम्';

  @override
  String get labelSalutation => 'सम्बोधनम्';

  @override
  String get hintSalutation => 'श्रीः / श्रीमती / वैद्यः';

  @override
  String get labelFirstNameRequired => 'प्रथमं नाम *';

  @override
  String get hintEnterFirstName => 'प्रथमं नाम लिख्यताम्';

  @override
  String get labelMiddleName => 'मध्यनाम';

  @override
  String get labelLastName => 'कुलनाम';

  @override
  String get hintOptional => 'वैकल्पिकम्';

  @override
  String get hintFormalName => 'औपचारिकरूपेण कथं सम्बोध्यते';

  @override
  String get labelPersonalDetails => 'वैयक्तिकविवरणम्';

  @override
  String get labelDateOfBirth => 'जन्मदिनाङ्कः';

  @override
  String get labelMeetiversaryDayYouMet => 'परिचयवार्षिकम् · मेलनदिनम्';

  @override
  String get labelPreferredSim => 'इष्टं SIM';

  @override
  String get descPreferredSim =>
      'अस्मै जनाय केन SIM द्वारा आह्वानं करणीयम्। सामान्यं SIM प्रयोक्तुं मुख्यम् एव त्यज्यताम्।';

  @override
  String get descUseSimInSettings => 'विन्यासे निर्धारितं SIM प्रयुज्यताम्।';

  @override
  String get labelOnThisPhone => 'अस्मिन् दूरभाषे';

  @override
  String get labelSelected => 'चितम्';

  @override
  String get labelNone => 'न किमपि';

  @override
  String get actionAddCallingCard => 'आह्वानपत्रं योज्यताम्';

  @override
  String get descCallingCardShown => 'आह्वानकाले पूर्णपटले दृश्यमानं चित्रम्।';

  @override
  String get labelSelect => 'चीयताम्';

  @override
  String get actionClear => 'रिक्तीक्रियताम्';

  @override
  String get hintDescribe => 'वर्ण्यताम्';

  @override
  String get hintCustom => 'स्वकीयम्';

  @override
  String get actionCustomLabel => '+ स्वकीयम्';

  @override
  String get labelAddTag => 'चिह्नयोजनम्';

  @override
  String get hintTypeAndEnter => 'लिखित्वा Enter नुद्यताम्';

  @override
  String get labelTagSuggestVip => 'विशिष्टः';

  @override
  String get labelTagSuggestMentor => 'मार्गदर्शकः';

  @override
  String get labelTagSuggestClient => 'ग्राहकः';

  @override
  String get labelTagSuggestInvestor => 'निवेशकः';

  @override
  String get labelTagSuggestNeighbor => 'प्रतिवेशी';

  @override
  String get labelAddToGroup => 'समूहे योज्यताम्';

  @override
  String get hintGroupSearch =>
      'अन्वेषणाय लिख्यताम्, सर्वाय *, नूतनं वा योज्यताम्';

  @override
  String get descLinkToPeople => 'अयं सम्पर्कः परिचितैः जनैः सह संयोज्यताम्।';

  @override
  String get actionAddAddress => 'सङ्केतः योज्यताम्';

  @override
  String labelAddressNumber(int index) {
    return 'सङ्केतः $index';
  }

  @override
  String get hintStreet => 'गृहसङ्ख्या, वीथिः';

  @override
  String get labelCityTown => 'नगरं / ग्रामः';

  @override
  String get labelCompanyName => 'संस्थानाम';

  @override
  String get hintWhereTheyWork => 'कार्यस्थानम्';

  @override
  String get labelOfficeStreet => 'कार्यालयः / वीथिः';

  @override
  String get hintBuildingStreet => 'भवनम्, वीथिः';

  @override
  String get labelOfficialDetails => 'आधिकारिकविवरणम्';

  @override
  String get hintJobTitle => 'पदनाम';

  @override
  String get labelDepartment => 'विभागः';

  @override
  String get hintTeam => 'दलम्';

  @override
  String get labelEphemeralToggle => '⏱️ अल्पकालिकः सम्पर्कः';

  @override
  String get descEphemeralToggle => 'अल्पकालिकम्। स्वयमेव लुप्यते।';

  @override
  String get labelExpiryOptions => 'अवधिविकल्पाः';

  @override
  String get labelExpiry2Hours => '2 होरे';

  @override
  String get labelExpiry24Hours => '24 होराः';

  @override
  String get labelExpiry7Days => '7 दिनानि';

  @override
  String get labelExpiryAfterOneCall => 'एकाह्वानानन्तरं लोपः';

  @override
  String get descEphemeralStorage =>
      'केवलं स्थानीये SQLCipher दत्तांशकोशे रक्ष्यते। Google प्रति दूरभाषसम्पर्कान् प्रति वा कदापि न समन्वीयते।';

  @override
  String get labelSecretContact => 'गुप्तसम्पर्कः';

  @override
  String get descHiddenBehindAuth => 'प्रमाणीकरणस्य पृष्ठतः गुप्तः';

  @override
  String get titleSelectCountryCode => 'देशसङ्केतचयनम्';

  @override
  String get hintSearchCountry => 'देशः सङ्केतः वा अन्विष्यताम्';

  @override
  String emptyNoCountriesMatch(String query) {
    return '“$query” इत्यनेन कोऽपि देशः न सङ्गच्छते।';
  }

  @override
  String get titleSecurity => 'सुरक्षा';

  @override
  String get descSecurityCard =>
      'अनुप्रयोगतालकं, पटलचित्रनिरोधः, परिवर्तनलेखः च।';

  @override
  String get titleSpeedDial => 'शीघ्राह्वानम्';

  @override
  String get descSpeedDialCard =>
      'रक्षितं जनम् आह्वातुं सङ्ख्यापटलस्य 1-9 कुञ्चिका दीर्घं स्पृश्यताम्।';

  @override
  String get descContactsCard => 'भवतः परिचयः सम्पर्कविकल्पाः च।';

  @override
  String get titleSyncToAnotherDevice => 'अन्योपकरणेन समन्वयः';

  @override
  String get descSyncCard =>
      'Wi-Fi द्वारा सम्पर्काः प्रेष्यन्तां गृह्यन्तां वा।';

  @override
  String get titleOnlineProviderSync => 'संयुक्तसमन्वयः';

  @override
  String get descOnlineSyncCard =>
      'Google, Microsoft, CardDAV इत्येतैः सह साक्षात् उभयपक्षसमन्वयः।';

  @override
  String get titleBackupRestore => 'प्रतिलिपिरक्षणं पुनःस्थापनं च';

  @override
  String get descBackupCard =>
      'सर्वं दत्तांशं सञ्चिकायां रक्ष्यतां, पुनःस्थाप्यतां वा।';

  @override
  String get titleEncryptedCloudBackup => 'गुप्तमेघप्रतिलिपिः';

  @override
  String get descCloudBackupCard =>
      '.csbak प्रतिलिपिः Google Drive, OneDrive, WebDAV इत्येषु एकस्मिन् रक्ष्यताम्।';

  @override
  String get titleSimCalling => 'SIM आह्वानं च';

  @override
  String get descSimCard =>
      'मुख्यं SIM, सम्भाषकाभिज्ञानम्, अवाञ्छितपरिशोधनं च।';

  @override
  String get descRingtoneCard =>
      'ध्वनिस्तरः, कम्पनम्, प्रतिSIM आह्वानध्वनयः च।';

  @override
  String get titleEmergencyInfo => 'आपत्कालसूचना';

  @override
  String get descEmergencyCard =>
      'तालितपटले सहायकः यत् पठितुं शक्नोति तत् पत्रम्।';

  @override
  String get titleDefaultCountry => 'मुख्यदेशः';

  @override
  String descCountrySubtitle(String country) {
    return '$country · सम्भाषकाभिज्ञानाय';
  }

  @override
  String get titleAppearance => 'रूपम्';

  @override
  String get descAppearanceCard => 'रूपविन्यासः मुख्यवर्णः च।';

  @override
  String get titleFeatures => 'विशेषताः';

  @override
  String get descFeaturesCard =>
      'SreerajP Contacts Sphere इत्यस्य सर्वाः विशेषताः दृश्यन्ताम्।';

  @override
  String get titlePermissions => 'अनुमतयः';

  @override
  String get descPermissionsCard => 'अनुप्रयोगः किं किं प्राप्नोति, किमर्थं च।';

  @override
  String get titleHelp => 'साहाय्यम्';

  @override
  String get descHelpCard => 'समन्वयादयः विशेषताः कथं प्रवर्तन्ते।';

  @override
  String get titleAbout => 'विषयपरिचयः';

  @override
  String get descAboutCard => 'संस्करणं, लेखकः, निर्मितिविवरणं च।';

  @override
  String get descAuthReasonSync => 'दत्तांशसमन्वयाय प्रमाणीक्रियताम्';

  @override
  String get errorAuthRequiredSync => 'दत्तांशसमन्वयाय प्रमाणीकरणम् आवश्यकम्।';

  @override
  String get titleNoScreenLock => 'पटलतालकं नास्ति';

  @override
  String get descNoLockSync =>
      'भवतः उपकरणे पटलतालकं नास्ति, अतः समन्वितः दत्तांशः प्रमाणीकरणेन रक्षितुं न शक्यते। अत्र गुप्तसम्पर्काः अपि भवेयुः। तथापि अनुवर्त्यतां वा?';

  @override
  String get descAuthReasonBackup =>
      'प्रतिलिपिरक्षणाय पुनःस्थापनाय वा प्रमाणीक्रियताम्';

  @override
  String get errorAuthRequiredBackup =>
      'प्रतिलिपिरक्षणाय पुनःस्थापनाय वा प्रमाणीकरणम् आवश्यकम्।';

  @override
  String get descNoLockBackup =>
      'भवतः उपकरणे पटलतालकं नास्ति, अतः प्रतिलिपिः प्रमाणीकरणेन रक्षितुं न शक्यते। प्रतिलिप्यां गुप्तसम्पर्काः अपि भवेयुः। तथापि अनुवर्त्यतां वा?';

  @override
  String get titleDialerTopContacts => 'आह्वानपटले प्रमुखाः';

  @override
  String get labelMostRecent => 'नूतनतमाः';

  @override
  String get descTopRelations => 'सम्बन्धित्वेन संयोजिताः सम्पर्काः।';

  @override
  String get descTopLikely =>
      'दिनस्य अस्मिन् समये प्रायः ये उत्तरं ददति तेषां क्रमेण।';

  @override
  String get descTopRecent => 'अधिकतमं सम्पर्किताः, ततः नूतनतमानि आह्वानानि।';

  @override
  String get titleDialpadScriptLayout => 'पटललिपिः';

  @override
  String get labelScriptAuto => 'स्वतः (उपकरणभाषा)';

  @override
  String get labelScriptMalayalam => 'मलयाळम् (മലയാളം)';

  @override
  String get labelScriptDevanagari => 'देवनागरी';

  @override
  String get labelScriptCyrillic => 'सिरिलिक्';

  @override
  String get labelScriptArabic => 'अरबलिपिः (العربية)';

  @override
  String get labelScriptGreek => 'यवनलिपिः (Ελληνικά)';

  @override
  String get labelScriptNone => 'आङ्ग्लम् एव';

  @override
  String get descScriptAuto => 'उपकरणभाषाम् अनुसरति।';

  @override
  String get descScriptMalayalam => 'आङ्ग्ल-मलयाळलिप्योः युग्मविन्यासः (ക-ങ)।';

  @override
  String get descScriptDevanagari =>
      'आङ्ग्ल-देवनागरीलिप्योः युग्मविन्यासः (क-ङ)।';

  @override
  String get descScriptCyrillic =>
      'आङ्ग्ल-सिरिलिक्लिप्योः युग्मविन्यासः (АБВГ)।';

  @override
  String get descScriptArabic => 'आङ्ग्ल-अरबलिप्योः युग्मविन्यासः (ا ب ت ث)।';

  @override
  String get descScriptGreek => 'आङ्ग्ल-यवनलिप्योः युग्मविन्यासः (ΑΒΓ)।';

  @override
  String get descScriptNone => 'केवलं सामान्याः आङ्ग्लवर्णाः (A-Z)।';

  @override
  String get titleSync => 'समन्वयः';

  @override
  String get labelSaveContactsTo => 'सम्पर्काः कुत्र रक्ष्यन्ताम्';

  @override
  String get labelCallLog => 'आह्वानलेखः';

  @override
  String get errorSyncFailed => 'समन्वयः असफलः।';

  @override
  String get labelWorking => 'प्रवर्तते…';

  @override
  String get errorContactsPermissionSync => 'समन्वयाय सम्पर्कानुमतिः आवश्यकी।';

  @override
  String get actionAddDeviceToApp => 'दूरभाषसम्पर्काः अनुप्रयोगे योज्यन्ताम्';

  @override
  String get descAddDeviceToApp => 'दूरभाषस्य सम्पर्कसूची अनुप्रयोगे आनीयताम्।';

  @override
  String msgContactsSynced(int count) {
    return 'सम्पर्काः समन्विताः — $count योजिताः अद्यतनीकृताः वा।';
  }

  @override
  String get msgContactsUpToDate => 'सम्पर्काः पूर्वमेव अद्यतनाः।';

  @override
  String get actionAddAppToDevice => 'अनुप्रयोगसम्पर्काः दूरभाषे योज्यन्ताम्';

  @override
  String get descAddAppToDevice =>
      'अनुप्रयोगस्य सम्पर्काः दूरभाषे प्रतिलिख्यन्ताम्।';

  @override
  String errorCouldNotSaveTo(String target, int failed) {
    return '$target इत्यत्र रक्षितुं न शक्तम् — $failed असफलाः।';
  }

  @override
  String get msgNoContactsToSyncToDevice =>
      'दूरभाषं प्रति समन्वयाय कोऽपि सम्पर्कः नास्ति।';

  @override
  String msgSavedTo(String target, int total) {
    return '$target इत्यत्र रक्षितम् — $total योजिताः अद्यतनीकृताः वा।';
  }

  @override
  String msgSavedToWithFailed(String target, int total, int failed) {
    return '$target इत्यत्र रक्षितम् — $total योजिताः अद्यतनीकृताः वा ($failed असफलाः)।';
  }

  @override
  String get actionMirrorDeviceToApp => 'दूरभाषः → अनुप्रयोगः (लोपसहितम्)';

  @override
  String get descMirrorDeviceToApp =>
      'अनुप्रयोगः दूरभाषसमः क्रियते — दूरभाषे अविद्यमानाः अनुप्रयोगसम्पर्काः अपनीयन्ते।';

  @override
  String get titleMirrorDeviceToApp => 'दूरभाषः अनुप्रयोगे प्रतिबिम्ब्यतां वा?';

  @override
  String get descMirrorDeviceToAppConfirm =>
      'एतत् दूरभाषस्य सम्पर्कान् आनयति, ततः ये सम्पर्काः दूरभाषात् आगताः किन्तु इदानीं तत्र न सन्ति तान् अनुप्रयोगात् लुम्पति।\n\nभवतः \"अहम्\" सम्पर्कः, गुप्तसम्पर्काः, केवलम् अनुप्रयोगे सृष्टाः सम्पर्काः च कदापि न लुप्यन्ते।';

  @override
  String get actionMirror => 'प्रतिबिम्ब्यताम्';

  @override
  String msgMirroredFromDevice(int removed) {
    return 'दूरभाषात् प्रतिबिम्बितम् — $removed अपनीताः।';
  }

  @override
  String get msgMirroredFromDeviceNone =>
      'दूरभाषात् प्रतिबिम्बितम् — अपनेयं किमपि नास्ति।';

  @override
  String get actionMirrorAppToDevice => 'अनुप्रयोगः → दूरभाषः (लोपसहितम्)';

  @override
  String get descMirrorAppToDevice =>
      'दूरभाषः अनुप्रयोगसमः क्रियते — अनुप्रयोगे अविद्यमानाः दूरभाषसम्पर्काः अपनीयन्ते।';

  @override
  String get titleMirrorAppToDevice => 'अनुप्रयोगः दूरभाषे प्रतिबिम्ब्यतां वा?';

  @override
  String get descMirrorAppToDeviceConfirm =>
      'एतत् अनुप्रयोगस्य सम्पर्कान् दूरभाषे प्रतिलिखति, ततः अनुप्रयोगे अविद्यमानान् दूरभाषसम्पर्कान् लुम्पति।\n\nभवतः \"अहम्\" सम्पर्केण गुप्तसम्पर्केण वा समानाः दूरभाषसम्पर्काः कदापि न लुप्यन्ते।';

  @override
  String msgMirroredTo(String target, int removed) {
    return '$target इत्यत्र प्रतिबिम्बितम् — $removed अपनीताः।';
  }

  @override
  String msgMirroredToNone(String target) {
    return '$target इत्यत्र प्रतिबिम्बितम् — अपनेयं किमपि नास्ति।';
  }

  @override
  String get actionImportCallLog => 'दूरभाषस्य आह्वानलेखः अनुप्रयोगे योज्यताम्';

  @override
  String get descImportCallLog =>
      'दूरभाषस्य पुरातनम् आह्वानेतिवृत्तम् इतिवृत्ते आनीयताम्।';

  @override
  String get errorCouldNotReadCallLog =>
      'दूरभाषस्य आह्वानलेखः पठितुं न शक्तः — Android विन्यासे “Call logs” अनुमतिः दीयताम्।';

  @override
  String get msgCallLogUpToDate => 'आह्वानलेखः पूर्वमेव अद्यतनः।';

  @override
  String labelCountAdded(int count) {
    return '$count योजिताः';
  }

  @override
  String labelCountUpdated(int count) {
    return '$count अद्यतनीकृताः';
  }

  @override
  String msgCallLogImported(String parts) {
    return 'आह्वानलेखः आनीतः — $parts';
  }

  @override
  String get actionReplaceCallLog => 'आह्वानलेखः दूरभाषात् (लोपसहितम्)';

  @override
  String get descReplaceCallLog =>
      'इतिवृत्तं दूरभाषस्य आह्वानेतिवृत्तेन परिवर्त्यताम्।';

  @override
  String get titleReplaceCallHistory => 'आह्वानेतिवृत्तं परिवर्त्यतां वा?';

  @override
  String get descReplaceCallHistoryConfirm =>
      'एतत् अनुप्रयोगस्य आह्वानेतिवृत्तं रिक्तीकृत्य दूरभाषस्य आह्वानलेखात् पुनः निर्माति। अनुप्रयोगे रक्षिताः आह्वानटिप्पण्यः प्रतिक्रियाः च नश्यन्ति।';

  @override
  String get actionReplace => 'परिवर्त्यताम्';

  @override
  String msgCallLogReplaced(int count) {
    return 'आह्वानलेखः परिवर्तितः — $count योजिताः।';
  }

  @override
  String get labelContactCountsIndex => 'गणना अन्वेषणसूची च';

  @override
  String get descContactCountsIndex =>
      'दूरभाषस्य अनुप्रयोगस्य च सम्पर्कगणना अन्वेषणसूच्याः स्थितिः च दृश्यताम्।';

  @override
  String get labelMyProfileAddMe => 'मम परिचयः';

  @override
  String get descMyProfileAddMe =>
      'स्वकीयं सम्पर्कपत्रं सृज्यतां सम्पाद्यतां वा।';

  @override
  String get labelDisplayFormatting => 'प्रदर्शनं रूपं च';

  @override
  String get descDisplayFormatting => 'क्रमः, नामरूपं, प्रदर्शनपरिशोधकाः च।';

  @override
  String get labelDeviceCloudSync => 'दूरभाष-मेघसमन्वयः';

  @override
  String get descDeviceCloudSync =>
      'दूरभाषप्रतिबिम्बनं मेघोपयोक्तृविवरणानि च विन्यस्यन्ताम्।';

  @override
  String get labelCustomRelationshipLabels => 'स्वकीयसम्बन्धनामानि';

  @override
  String get descCustomRelationshipLabels =>
      'सम्पर्काणां स्वकीयसम्बन्धनामानि व्यवस्थाप्यन्ताम्।';

  @override
  String get descBlockedNumbersCard =>
      'ध्वननात् निरुद्धाः सङ्ख्याः दृश्यन्तां व्यवस्थाप्यन्तां च।';

  @override
  String get labelSecretContactsExport => 'गुप्तसम्पर्काः निर्यापणं च';

  @override
  String get descSecretContactsExport =>
      'निर्यापणविकल्पाः गुप्तसम्पर्कनिर्यापणनियन्त्रणानि च।';

  @override
  String msgSyncedWith(String name) {
    return '$name इत्यनेन सह सफलतया समन्वितम्।';
  }

  @override
  String get msgSyncCompleted => 'समन्वयः समाप्तः।';

  @override
  String get titleAddOnlineAccount => 'संयुक्तोपयोक्तृविवरणयोजनम्';

  @override
  String get labelProvider => 'सेवाप्रदाता';

  @override
  String get labelAccountEmailName => 'विद्युत्पत्रं / नाम';

  @override
  String get labelServerUrl => 'सेवकस्य URL';

  @override
  String get labelUsername => 'उपयोक्तृनाम';

  @override
  String get labelAccount => 'उपयोक्तृविवरणम्';

  @override
  String get descOnlineSyncIntro =>
      'Google, Microsoft, CardDAV इत्येतैः सह ऐच्छिकः उभयपक्षसमन्वयः। न कोऽपि गुप्तसङ्ग्रहः, केवलं साक्षात् API अनुरोधाः।';

  @override
  String get labelConfiguredProviders => 'विन्यस्ताः सेवाप्रदातारः';

  @override
  String get actionAddAccount => 'उपयोक्तृविवरणं योज्यताम्';

  @override
  String get emptyNoCloudAccounts =>
      'न किमपि मेघसमन्वयोपयोक्तृविवरणं विन्यस्तम्।';

  @override
  String descProviderLastSynced(String provider, String when) {
    return 'सेवाप्रदाता: $provider\nअन्तिमसमन्वयः: $when';
  }

  @override
  String get labelNever => 'कदापि न';

  @override
  String get tooltipSyncNow => 'इदानीं समन्वीयताम्';

  @override
  String get labelSimCardsAccounts => 'SIM पत्राणि विवरणानि च';

  @override
  String get descSimCardsAccounts =>
      'मुख्यं SIM, प्रत्याह्वानं प्रश्नः, SIM वर्णाः च।';

  @override
  String get labelIdentification => 'अभिज्ञानम्';

  @override
  String get descIdentification => 'सम्भाषकाभिज्ञानम् अवाञ्छितपरिशोधनं च।';

  @override
  String get labelSpokenAnnouncement => 'सम्भाषकनामोच्चारणम्';

  @override
  String get descSpokenAnnouncement =>
      'आह्वानध्वनिना सह सम्भाषकस्य नाम उच्चार्यताम्।';

  @override
  String get labelTierQuietHours => 'सम्बन्धस्तरानुसारं शान्तिकालः';

  @override
  String get descTierQuietHours =>
      'चितान् सम्बन्धस्तरान् विहाय रात्रौ आह्वानानि मौनीक्रियन्ताम्।';

  @override
  String get labelQuickReplies => 'शीघ्रप्रत्युत्तराणि';

  @override
  String get descQuickReplies =>
      'आह्वानं सन्देशेन प्रत्याख्याने दीयमानाः सन्देशाः।';

  @override
  String get labelPostCallOptions => 'आह्वानोत्तरविकल्पाः';

  @override
  String get descPostCallOptions => 'आह्वानोत्तरप्रतिक्रियापत्रं विन्यस्यताम्।';

  @override
  String get titleSmartRedialReachMe => 'पुनराह्वानं सन्देशश्च';

  @override
  String get descSmartRedialCard =>
      'आह्वानम् अनुत्तरितं चेत् स्वचालितपुनराह्वानं सन्देशश्च।';

  @override
  String get descSmartRedialIntro =>
      'आह्वानम् अनुत्तरितं चेत् एकस्पर्शेन पुनराह्वानं सन्देशं च अर्प्यताम्।';

  @override
  String get labelDefaultRetryDelay => 'मुख्यः प्रतीक्षाकालः';

  @override
  String get labelPresetReachMe => 'पूर्वनिर्धारितः सन्देशः';

  @override
  String get labelActiveScheduledRedials => 'सक्रियपुनराह्वानानि';

  @override
  String labelActiveCount(int count) {
    return '$count सक्रियाणि';
  }

  @override
  String labelMinutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निमेषाः',
      one: 'एकः निमेषः',
    );
    return '$_temp0';
  }

  @override
  String get hintPresetReachMe => 'पूर्वनिर्धारितः सन्देशः लिख्यताम्…';

  @override
  String get titleActiveAutoRedials => 'सक्रियस्वचालितपुनराह्वानानि';

  @override
  String get emptyNoActiveRedials => 'न किमपि सक्रियं पुनराह्वानम्।';

  @override
  String labelRedialIn(String number, int minutes) {
    return '$number · $minutes निमेषेषु';
  }

  @override
  String get errorEnterPassphrase => 'प्रतिलिपेः गुप्तवाक्यं दीयताम्।';

  @override
  String msgBackupUploadedFile(String file) {
    return 'गुप्ता प्रतिलिपिः सफलतया आरोपिता: $file';
  }

  @override
  String get msgBackupUploaded => 'प्रतिलिपिः आरोपिता।';

  @override
  String errorUploadFailed(String error) {
    return 'आरोपणम् असफलम्: $error';
  }

  @override
  String get descCloudBackupIntro =>
      'अनुप्रयोगस्य सम्पूर्णः दत्तांशः (.csbak) भवतः गुप्तवाक्येन PBKDF2 (300k आवृत्तयः) + AES-GCM-256 द्वारा आद्यन्तं गुप्तीकृत्य भवतः मेघकोशे रक्ष्यते।';

  @override
  String get emptyNoCloudStorage =>
      'न किमपि मेघसङ्ग्रहोपयोक्तृविवरणं विन्यस्तम्।';

  @override
  String get actionAddAccountInProviderSync =>
      'संयुक्तसमन्वये विवरणं योज्यताम्';

  @override
  String get labelTargetCloudAccount => 'लक्ष्यमेघविवरणम्';

  @override
  String get labelEncryptionPassphrase => 'गुप्तीकरणवाक्यम्';

  @override
  String get hintPassphrase => '.csbak गुप्तीकरणाय गुप्तवाक्यं दीयताम्';

  @override
  String get actionUploadBackupNow => 'इदानीम् आरोप्यताम्';

  @override
  String get labelRemoteCloudBackups => 'मेघस्थाः प्रतिलिपयः';

  @override
  String get emptyNoCloudBackups =>
      'अस्मिन् विवरणे न काऽपि मेघप्रतिलिपिः प्राप्ता।';

  @override
  String descBackupSizeDate(int bytes, String date) {
    return 'परिमाणम्: $bytes बाइट् | दिनाङ्कः: $date';
  }

  @override
  String get labelCallerIdentification => 'सम्भाषकाभिज्ञानम्';

  @override
  String get descCallerIdentification =>
      'भवतः सम्पर्केषु अविद्यमानाः सम्भाषकाः चिह्न्यन्ताम् — विपणनसेवासङ्ख्याः, भवता अवाञ्छिताः इति चिह्निताः सङ्ख्याः च।';

  @override
  String get labelFilterSuspectedSpam => 'शङ्कितावाञ्छितपरिशोधनम्';

  @override
  String get descFilterSpam =>
      'शङ्कितानि अवाञ्छिताह्वानानि मौनेन आगच्छन्ति। तानि इतिवृत्ते दृश्यन्ते, स्वीकर्तुं च शक्यन्ते।';

  @override
  String get labelHowIdentificationWorks => 'अभिज्ञानं कथम्';

  @override
  String get descHowIdentificationWorks =>
      'अभिज्ञानं भवतः दूरभाषे एव भवति — किमपि कुत्रापि न प्रेष्यते। SreerajP Contacts Sphere पञ्जीकृताः विपणन- (140…) सेवा- (160…) सङ्ख्याश्रेणीः, भवता इतिवृत्तात् अवाञ्छिताः इति चिह्निताः सङ्ख्याः च अभिजानाति; सम्भाषकस्य सङ्ख्या प्रमाणीकर्तुं न शक्ता इति जालं यदा सूचयति तदा पूर्वसूचनां च दर्शयति।\n\nचलदूरभाषजालानि सम्भाषकस्य सङ्ख्याम् एव ददति, न नाम; अतः भवतः सम्पर्केभ्यः बहिःस्थाः सम्भाषकाः नाम्ना अभिज्ञातुं न शक्यन्ते। अवाञ्छितपरिशोधनाय SreerajP Contacts Sphere भवतः मुख्यः दूरभाषानुप्रयोगः भवेत्।';

  @override
  String get titleAccentColor => 'मुख्यवर्णः';

  @override
  String get labelLivePreview => 'सद्यःप्रदर्शनम्';

  @override
  String get labelSampleText => 'निदर्शनपाठः';

  @override
  String get labelPresets => 'पूर्वनिर्धारिताः';

  @override
  String get labelCustomColorWheel => 'स्वकीयवर्णचक्रम्';

  @override
  String get actionResetDarkToDefault => 'श्यामरूपं पुनःसज्जीक्रियताम्';

  @override
  String get actionResetLightToDefault => 'दीप्तरूपं पुनःसज्जीक्रियताम्';

  @override
  String get descContrastAuto => 'पठनसौकर्याय पाठवर्णभेदः स्वयमेव समायोज्यते।';

  @override
  String get labelSortOrder => 'क्रमः';

  @override
  String get descSortOrder => 'आवलीषु सम्पर्काणां क्रमः।';

  @override
  String get labelFirstName => 'प्रथमं नाम';

  @override
  String get labelHideNoPhone => 'सङ्ख्यारहिताः गोप्यन्ताम्';

  @override
  String get descHideNoPhone =>
      'केवलं विद्युत्पत्रं सङ्केतः वा येषां ते सम्पर्काः मुख्यावल्यां न दृश्यन्ते।';

  @override
  String get titleThemeMode => 'रूपविन्यासप्रकारः';

  @override
  String get labelLight => 'दीप्तरूपम्';

  @override
  String get labelDark => 'श्यामरूपम्';

  @override
  String get labelSystem => 'तन्त्रसिद्धम्';

  @override
  String get descSystemTheme =>
      'तन्त्रप्रकारः भवतः उपकरणस्य श्यामरूपविन्यासं स्वयम् अनुसरति।';

  @override
  String get labelVolumeVibration => 'ध्वनिस्तरः कम्पनं च';

  @override
  String get descVolumeVibration => 'आह्वानध्वनेः स्तरः आगच्छदाह्वानकम्पनं च।';

  @override
  String get labelPerSimRingtones => 'प्रतिSIM आह्वानध्वनयः';

  @override
  String get descPerSimRingtones =>
      'प्रत्येकस्मिन् SIM मध्ये आगतेभ्यः आह्वानेभ्यः भिन्नाः आह्वानध्वनयः दीयन्ताम्।';

  @override
  String get titleTypography => 'अक्षररूपं परिमाणं च';

  @override
  String get labelFont => 'अक्षररूपम्';

  @override
  String get labelTextSize => 'अक्षरपरिमाणम्';

  @override
  String get labelScaleSmall => 'लघु';

  @override
  String get labelScaleDefault => 'मूलम्';

  @override
  String get labelScaleLarge => 'बृहत्';

  @override
  String get labelScaleLarger => 'बृहत्तरम्';

  @override
  String get titleScreenshotGuard => 'पटलचित्ररक्षा';

  @override
  String get labelBlockScreenshots => 'पटलचित्राणि निरुध्यन्ताम्';

  @override
  String get descBlockScreenshots =>
      'सम्पर्कविवरणानि आह्वानानि च पटलचित्रेषु पटलाभिलेखेषु सद्यःअनुप्रयोगदर्शने च न दृश्यन्ते।';

  @override
  String get featureC0Name => 'चतुरम् आह्वानपटलम् आह्वानं च';

  @override
  String get featureC0Subtitle =>
      'शीघ्रं T9 अन्वेषणं, द्वि-SIM नियन्त्रणानि, बुद्धिमन्ति आह्वानसाधनानि च';

  @override
  String get featureC0F0Title => 'बहुलिपि-T9 सङ्ख्यापटलान्वेषणम्';

  @override
  String get featureC0F0Desc =>
      'आह्वानपटले सङ्ख्याः वर्णान् वा टङ्कयित्वा क्षणेन सम्पर्काः अन्विष्यन्ताम्। आङ्ग्लं, मलयाळं (स्वराः चिल्लक्षराणि च सहितम्), देवनागरी इत्यादयः पूर्णतया समर्थिताः।';

  @override
  String get featureC0F0H0 => 'आङ्ग्लं मलयाळं च';

  @override
  String get featureC0F0H1 => 'बहुलिपि-लिप्यन्तरणम्';

  @override
  String get featureC0F0H2 => 'उभयथा नामानि मेलयति';

  @override
  String get featureC0F1Title => 'शीघ्राह्वानम्';

  @override
  String get featureC0F1Desc =>
      'सङ्ख्यापटलस्य 1 तः 9 पर्यन्तं कुञ्चिकासु कञ्चित् जनं रक्षतु, ततः तां कुञ्चिकां दीर्घं स्पृष्ट्वा तम् आह्वयतु। सङ्ख्यापेटिका रिक्ता चेत् एव दीर्घस्पर्शः कार्यं करोति; नियुक्तासु कुञ्चिकासु लघु बिन्दुः दृश्यते। गुप्तसम्पर्काः कदापि कुञ्चिकायां न स्थाप्यन्ते।';

  @override
  String get featureC0F1H0 => '1-9 कुञ्चिकाः';

  @override
  String get featureC0F1H1 => 'दीर्घस्पर्शेन आह्वानम्';

  @override
  String get featureC0F1H2 => 'पटलात् विन्यासात् वा नियोजनम्';

  @override
  String get featureC0F2Title => 'वाचा आह्वानम्';

  @override
  String get featureC0F2Desc =>
      'आह्वानपटले ध्वनिग्राहकं स्पृष्ट्वा सङ्ख्यां नाम वा वदतु। भवतः दूरभाषे एव, आङ्ग्लेन मलयाळेन वा, वाक् पाठरूपेण परिवर्त्यते; \"आह्वय\" इत्यादयः आरम्भशब्दाः स्वयं त्यज्यन्ते।';

  @override
  String get featureC0F2H0 => 'सङ्ख्यां नाम वा वदतु';

  @override
  String get featureC0F2H1 => 'आङ्ग्लं मलयाळं च';

  @override
  String get featureC0F2H2 => 'दूरभाषे एव वागभिज्ञानम्';

  @override
  String get featureC0F3Title => 'सम्पाद्यम् आह्वानपटलं सूक्ष्मसम्पादनं च';

  @override
  String get featureC0F3Desc =>
      'टङ्कितसङ्ख्यायां यत्र कुत्रापि स्पृष्ट्वा सूचकं चालयतु, अङ्कान् चिनोतु, दूरभाषसङ्ख्याः सुलभं प्रतिलिखतु स्थापयतु च।';

  @override
  String get featureC0F3H0 => 'सूचकस्थानम्';

  @override
  String get featureC0F3H1 => 'सङ्ख्यास्थापनम्';

  @override
  String get featureC0F3H2 => 'सूचकस्थाने लोपः';

  @override
  String get featureC0F4Title => 'प्रमुखसम्पर्काः सुलभाः';

  @override
  String get featureC0F4Desc =>
      'एकस्पर्शाह्वानाय आह्वानपटलस्य उपरि एका पङ्क्तिः। तत्र किं भवेत् इति चिनोतु: अधिकतमं सम्पर्किताः जनाः, भवता संयोजिताः बन्धवः मित्राणि च, अथवा दिनस्य अस्मिन् समये प्रायः ये उत्तरं ददति ते।';

  @override
  String get featureC0F4H0 => 'प्रियजनपङ्क्तिः';

  @override
  String get featureC0F4H1 => 'बन्धुमित्रपरिशोधकः';

  @override
  String get featureC0F4H2 => 'इदानीं सुलभाः';

  @override
  String get featureC0F5Title => 'द्वि-SIM आह्वाननियन्त्रणानि';

  @override
  String get featureC0F5Desc =>
      'प्रत्याह्वानं SIM 1 SIM 2 वा चिनोतु, अथवा प्रतिवारं प्रश्नं विना मुख्यं SIM निर्धारयतु। प्रत्येकः सम्पर्कः स्वकीयम् इष्टं SIM अपि धारयितुं शक्नोति, तत् मुख्यात् पूर्वं प्रयुज्यते। प्रत्येकस्य SIM स्वकीयः वर्णः अस्ति, इतिवृत्ते च केन SIM आह्वानं कृतम् इति दृश्यते।';

  @override
  String get featureC0F5H0 => 'SIM 1 / SIM 2 चयनम्';

  @override
  String get featureC0F5H1 => 'मुख्यं SIM प्रतिवारं प्रश्नः वा';

  @override
  String get featureC0F5H2 => 'प्रतिसम्पर्कम् इष्टं SIM';

  @override
  String get featureC0F5H3 => 'इतिवृत्ते SIM दृश्यते';

  @override
  String get featureC0F6Title => 'चतुरपुनराह्वानं \"सम्पर्कय\" प्रकारश्च';

  @override
  String get featureC0F6Desc =>
      'यदा आह्वानम् अनुत्तरितं व्यस्तं वा भवति, तदा भवता चितात् कालात् परं पुनराह्वानं नियोजयतु, अथवा एकस्पर्शेन पूर्वनिर्धारितं \"सम्पर्कं कर्तुं प्रयते\" इति सन्देशं प्रेषयतु।';

  @override
  String get featureC0F6H0 => 'भवतः कालात् परं पुनराह्वानम्';

  @override
  String get featureC0F6H1 => 'एकस्पर्श-SMS';

  @override
  String get featureC0F6H2 => 'प्रतीक्षमाणं पुनराह्वानं निरसनीयम्';

  @override
  String get featureC0F7Title => 'सम्भाषकनामोच्चारणम्';

  @override
  String get featureC0F7Desc =>
      'दूरभाषे ध्वनति रक्षितस्य सम्भाषकस्य नाम उच्चैः श्रूयते — वाहनचालने शिरःश्रावकधारणे वा उत्तमम्। मलयाळनाम मलयाळेन एव उच्चार्यते।';

  @override
  String get featureC0F7H0 => 'वाचिकम् अभिज्ञानम्';

  @override
  String get featureC0F7H1 => 'मलयाळेन उच्चारणम्';

  @override
  String get featureC0F7H2 => 'शान्तिकाले अपवादः';

  @override
  String get featureC0F8Title => 'शीघ्रप्रत्याख्यान-SMS प्रत्युत्तराणि';

  @override
  String get featureC0F8Desc =>
      '\"सभायाम् अस्मि, शीघ्रं प्रत्याह्वास्यामि\" इत्यादिभिः पूर्वनिर्धारितैः एकस्पर्श-SMS सन्देशैः आगच्छन्ति आह्वानानि सविनयं प्रत्याख्यायन्ताम्।';

  @override
  String get featureC0F8H0 => 'एकस्पर्शप्रत्याख्यान-SMS';

  @override
  String get featureC0F8H1 => 'स्वकीयाः लघुप्रतिरूपाः';

  @override
  String get featureC0F8H2 => 'सद्यः प्रेषणम्';

  @override
  String get featureC1Name => 'आह्वानमध्ये सम्भाषकबोधः च';

  @override
  String get featureC1Subtitle =>
      'समृद्धेन सन्दर्भेण सुगमैः आह्वाननियन्त्रणैः च कः आह्वयति इति ज्ञायताम्';

  @override
  String get featureC1F0Title => 'आधुनिकम् आह्वानपटलं सम्मेलनाह्वानं च';

  @override
  String get featureC1F0Desc =>
      'मौनं, ध्वनिवर्धकः, आह्वानस्थगनं, सङ्ख्यापटलं, सक्रियाह्वानविनिमयः, बहुजनसम्मेलनाह्वानानाम् एकीकरणं च इत्येतैः युक्तं सुन्दरम् आह्वानपटलम्।';

  @override
  String get featureC1F0H0 => 'ध्वनिवर्धकः मौनं च';

  @override
  String get featureC1F0H1 => 'स्थगनं विनिमयः च';

  @override
  String get featureC1F0H2 => 'सम्मेलनैकीकरणम्';

  @override
  String get featureC1F0H3 => 'पूर्णपटले आगच्छदाह्वानम्';

  @override
  String get featureC1F1Title => 'सम्बन्धसन्दर्भपत्राणि';

  @override
  String get featureC1F1Desc =>
      'दूरभाषे ध्वनति एव सम्भाषकस्य सम्बन्धचिह्नं, अन्तिमसंवादात् कति दिनानि, वैयक्तिकटिप्पण्यः, आगामिजन्मदिनानि च दृश्यन्ताम्।';

  @override
  String get featureC1F1H0 => 'सम्बन्धचिह्नम्';

  @override
  String get featureC1F1H1 => 'अन्तिमसंवाददिनानि';

  @override
  String get featureC1F1H2 => 'टिप्पणीनां सद्यःदर्शनम्';

  @override
  String get featureC1F2Title => 'आह्वानात् पूर्वं सारांशः';

  @override
  String get featureC1F2Desc =>
      'कञ्चित् आह्वानात् पूर्वम्, अन्तिमः संवादः कदा, तत् आह्वानं कियत्कालं, भवता किं टिप्पितम्, सङ्केतः रक्षितः चेत् तस्य नगरस्य स्थानीयसमयः च दृश्यन्ताम्।';

  @override
  String get featureC1F2H0 => 'पुनःसम्पर्कस्मारणम्';

  @override
  String get featureC1F2H1 => 'तेषां स्थानीयसमयः';

  @override
  String get featureC1F2H2 => 'संवादकालरेखा';

  @override
  String get featureC1F3Title => 'आह्वानोत्तरटिप्पण्यः वाग्लेखनं च';

  @override
  String get featureC1F3Desc =>
      'आह्वानसमाप्त्यनन्तरम् एव, कुञ्जीपटलेन उच्चैः वचनेन स्वयं पाठरूपेण वा, संवादविषयः शीघ्रं टिप्प्यताम्।';

  @override
  String get featureC1F3H0 => 'वाचः पाठः';

  @override
  String get featureC1F3H1 => 'आह्वानोत्तरप्रश्नः';

  @override
  String get featureC1F3H2 => 'अनुस्मारकम्';

  @override
  String get featureC2Name => 'सम्पर्कव्यवस्था सम्बन्धाः च';

  @override
  String get featureC2Subtitle =>
      'भवतः सम्बन्धजालं सार्थकेषु मण्डलेषु व्यवस्थाप्यताम्';

  @override
  String get featureC2F0Title => 'समृद्धाः सम्पर्कपरिचयाः';

  @override
  String get featureC2F0Desc =>
      'बहवः दूरभाषसङ्ख्याः, विद्युत्पत्राणि, गृह/कार्यालयसङ्केताः, जन्मदिनानि, विवाहवार्षिकाणि, सामाजिकानुबन्धाः, आधिकारिकविवरणानि, उच्चारणनामानि च रक्ष्यन्ताम्।';

  @override
  String get featureC2F0H0 => 'बहुदूरभाषाः विद्युत्पत्राणि च';

  @override
  String get featureC2F0H1 => 'जन्मदिनस्मारकाणि';

  @override
  String get featureC2F0H2 => 'स्वकीयनामानि';

  @override
  String get featureC2F1Title => 'सप्त सम्बन्धमण्डलानि';

  @override
  String get featureC2F1Desc =>
      'भवता रक्षितः प्रत्येकः सम्बन्धः सप्तसु वर्गेषु एकस्मिन् भवति: समीपकुटुम्बं, विस्तृतकुटुम्बं, विवाहबन्धवः, वृत्तिः, शिक्षणं, सामाजिकं, सेवा च। तस्य अन्तः नाम — \"पिता\", \"प्रबन्धकः\" — यत् भवान् लिखति तदेव।';

  @override
  String get featureC2F1H0 => 'सप्त नियताः वर्गाः';

  @override
  String get featureC2F1H1 => 'स्वकीयानि सम्बन्धनामानि';

  @override
  String get featureC2F1H2 => 'उभयोः सम्पर्कयोः रक्षितम्';

  @override
  String get featureC2F2Title => 'सम्बन्धशान्तिकालः (DND परिशोधकः)';

  @override
  String get featureC2F2Desc =>
      'भवता निर्धारितयोः समययोः मध्ये आह्वानानि मौनीक्रियन्ताम्, के तथापि आगच्छेयुः इति आवल्यां लिख्यताम् — तारकचिह्निताः, सम्पूर्णाः सम्बन्धवर्गाः, एकं चिह्नं, नामतः जनाः वा। अन्ये सर्वे मौनाः।';

  @override
  String get featureC2F2H0 => 'शान्तिकालः निर्धार्यताम्';

  @override
  String get featureC2F2H1 => 'अनुमतावली, न निरोधावली';

  @override
  String get featureC2F2H2 => 'वर्गः, चिह्नं, जनः वा';

  @override
  String get featureC2F3Title => 'चिह्नानि स्वकीयसमूहाः च';

  @override
  String get featureC2F3Desc =>
      'स्वकीयैः लघुशब्दैः सम्पर्काः चिह्न्यन्ताम्, स्वकीयाह्वानध्वनियुक्ताः समूहाः (\"परियोजनादलम्\", \"पुस्तकमण्डली\" इव) च रच्यन्ताम्।';

  @override
  String get featureC2F3H0 => 'चिह्नमेघः';

  @override
  String get featureC2F3H1 => 'स्वकीयसमूहाः';

  @override
  String get featureC2F3H2 => 'समूहाह्वानध्वनयः';

  @override
  String get featureC2F4Title => 'द्विरुक्तान्वेषणं चतुरैकीकरणं च';

  @override
  String get featureC2F4Desc =>
      'दूरभाषसङ्ख्यया नाम्ना च — अन्यलिप्यां लिखितानि नामानि अपि — द्विरुक्तानि अन्विष्यन्ताम्, किमपि विवरणं विना नाशं शुद्धम् एकीक्रियन्ताम्।';

  @override
  String get featureC2F4H0 => 'नामसङ्ख्यामेलनम्';

  @override
  String get featureC2F4H1 => 'सुरक्षितम् एकीकरणम्';

  @override
  String get featureC2F4H2 => 'एकीकरणात् पूर्वं परीक्षा';

  @override
  String get featureC2F5Title => 'अल्पकालिकाः सम्पर्काः';

  @override
  String get featureC2F5Desc =>
      'वितरकं सकृत् विक्रेतारं वा अल्पकालिकसम्पर्करूपेण रक्षतु, सः स्वयं लुप्यते — 2 होरयोः, 24 होराणां, 7 दिनानां, एकस्य आह्वानस्य वा अनन्तरम्।';

  @override
  String get featureC2F5H0 => 'स्वयंलोपी';

  @override
  String get featureC2F5H1 => 'अवधिपट्टिका';

  @override
  String get featureC2F5H2 => 'स्थायित्वेन रक्षणम्';

  @override
  String get featureC2F6Title => 'संयुक्ताः सन्देशानुप्रयोगाः';

  @override
  String get featureC2F6Desc =>
      'सम्पर्के येषु सन्देशानुप्रयोगेषु सः प्राप्यः ते दृश्यन्ते — WhatsApp, Telegram, Arattai इत्यादयः — भवतः दूरभाषस्य सम्पर्कसूच्याः पठिताः। एकं स्पृष्ट्वा तत्र संवादः उद्घाट्यते।';

  @override
  String get featureC2F6H0 => 'साक्षात् संवादोद्घाटनम्';

  @override
  String get featureC2F6H1 => 'दूरभाषात् पठितम्';

  @override
  String get featureC2F6H2 => 'उपयोक्तृविवरणं न आवश्यकम्';

  @override
  String get featureC3Name => 'गोपनीयता, सुरक्षा, गुप्तकोशः च';

  @override
  String get featureC3Subtitle =>
      'भवतः संवेदनशीलाः सम्पर्काः निजसंवादाः च रक्ष्यन्ताम्';

  @override
  String get featureC3F0Title => 'गुप्तसम्पर्ककोशः';

  @override
  String get featureC3F0Desc =>
      'वैयक्तिकाः व्यावसायिकाः वा संवेदनशीलाः सम्पर्काः रक्षिते कोशे गोप्यन्ताम्। उद्घाटनपर्यन्तं ते मुख्यावल्यां सर्वथा अदृश्याः।';

  @override
  String get featureC3F0H0 => 'जैवमितिः / PIN उद्घाटनम्';

  @override
  String get featureC3F0H1 => 'मुख्यावल्यां गुप्ताः';

  @override
  String get featureC3F0H2 => 'गुप्तीकृतः दत्तांशकोशः';

  @override
  String get featureC3F1Title =>
      'अनुप्रयोगतालकम्: निष्क्रियम्, उपकरणतालकम्, अनुप्रयोग-PIN वा';

  @override
  String get featureC3F1Desc =>
      'दूरभाषस्य अङ्गुलिमुद्रया मुखेन वा, सकृत्प्रत्यानयनसङ्केतयुक्तेन 4–6 अङ्कात्मकेन अनुप्रयोग-PIN द्वारा वा सम्पूर्णः अनुप्रयोगः ताल्यताम्। गुप्तसम्पर्काः, प्रतिलिपयः, समन्वयः च तदुपरि पुनः पृच्छन्ति।';

  @override
  String get featureC3F1H0 => 'अङ्गुलिमुद्रया मुखेन च उद्घाटनम्';

  @override
  String get featureC3F1H1 => 'पृथक् अनुप्रयोग-PIN';

  @override
  String get featureC3F1H2 => 'सकृत्प्रत्यानयनसङ्केतः';

  @override
  String get featureC3F2Title => 'पटलचित्ररक्षा';

  @override
  String get featureC3F2Desc =>
      'यदा निजदत्तांशयुक्ते पटले भवान् अस्ति — सम्पर्कविवरणानि, प्रचलत् आह्वानं, तालपटलं, गुप्तसम्पर्काः, परिवर्तनलेखः च — तदा पटलचित्राणि, पटलाभिलेखनं, सद्यःअनुप्रयोगदर्शनं च निरुध्यन्ते।';

  @override
  String get featureC3F2H0 => 'पटलचित्रनिरोधः';

  @override
  String get featureC3F2H1 => 'पटलाभिलेखनरक्षा';

  @override
  String get featureC3F2H2 => 'सद्यःदर्शनं गुप्तम्';

  @override
  String get featureC3F3Title => 'सम्पर्कपरिवर्तनलेखः';

  @override
  String get featureC3F3Desc =>
      'सृष्टस्य सम्पादितस्य लुप्तस्य च प्रत्येकस्य सम्पर्कस्य, पूर्वं पश्चात् च कीदृशः आसीत् इति सहितः, हस्तक्षेपप्रकाशकः निजेतिहासः — प्रमादकृतं परिवर्तनं प्रत्यावर्तयितुं शक्यते।';

  @override
  String get featureC3F3H0 => 'पूर्वोत्तरस्थितिः';

  @override
  String get featureC3F3H1 => 'परिवर्तनप्रत्यावर्तनम्';

  @override
  String get featureC3F3H2 => 'हस्ताक्षरितं निर्यापणम्';

  @override
  String get featureC4Name => 'सद्यःवितरणं पठनं च';

  @override
  String get featureC4Subtitle =>
      'टङ्कनं विना सम्पर्कपत्राणि शीघ्रं विनिमीयन्ताम्';

  @override
  String get featureC4F0Title => 'vCard QR-सङ्केतनिर्माणं पठनं च';

  @override
  String get featureC4F0Desc =>
      'अन्ये क्षणेन पठेयुः इति स्वसम्पर्कपत्रस्य QR-सङ्केतः निर्मीयताम्, अथवा चित्रग्राहकेण कस्यापि QR-सम्पर्कपत्रं पठित्वा रक्ष्यताम्।';

  @override
  String get featureC4F0H0 => 'सद्यः QR vCard';

  @override
  String get featureC4F0H1 => 'अन्तर्निर्मितं चित्रग्राहकपाठकम्';

  @override
  String get featureC4F0H2 => 'एकस्पर्शेन सम्पर्कसूच्याम्';

  @override
  String get featureC4F1Title => 'AirQR चलसङ्केतप्रवाहः';

  @override
  String get featureC4F1Desc =>
      'चित्रं दीर्घं सम्पर्कपत्रं वा एकस्मिन् QR-सङ्केते न माति। AirQR तत् बहुषु खण्डेषु विभज्य अपरदूरभाषस्य चित्रग्राहकेण पठनाय चलचित्ररूपेण दर्शयति — न Bluetooth, न जालं, न युग्मनम्।';

  @override
  String get featureC4F1H0 => 'चित्राणि पूर्णपत्राणि च प्रेषयति';

  @override
  String get featureC4F1H1 => 'केवलं चित्रग्राहकेण प्रेषणम्';

  @override
  String get featureC4F1H2 => 'प्रवाहकाले सद्यःप्रगतिः';

  @override
  String get featureC4F2Title => 'दूरभाषस्थं व्यापारपत्रपाठकम्';

  @override
  String get featureC4F2Desc =>
      'कस्यापि व्यापारपत्रस्य चित्रं गृहीत्वा नाम, दूरभाषः, विद्युत्पत्रं, संस्थाविवरणं च सद्यः निष्कास्यन्ताम् — मेघम् आरोपणं विना 100% भवतः दूरभाषे एव।';

  @override
  String get featureC4F2H0 => 'दूरभाषस्थम् AI OCR';

  @override
  String get featureC4F2H1 => 'मेघम् आरोपणं नास्ति';

  @override
  String get featureC4F2H2 => 'चितक्षेत्राणाम् एव योजनम्';

  @override
  String get featureC4F3Title => 'असंयुक्तं Bluetooth LE वितरणम्';

  @override
  String get featureC4F3Desc =>
      'समीपस्थानि ContactSphere उपकरणानि अन्विष्य, अन्तर्जालं युग्मनसङ्केतं वा विना, Bluetooth Low Energy द्वारा साक्षात् सम्पर्काः प्रेष्यन्ताम्।';

  @override
  String get featureC4F3H0 => 'अन्तर्जालं न आवश्यकम्';

  @override
  String get featureC4F3H1 => 'उपकरणानि स्वयम् अन्विष्यति';

  @override
  String get featureC4F3H2 => 'ग्राहकेण स्थिरीकरणीयम्';

  @override
  String get featureC4F4Title => 'CSV, vCard आनयनं / निर्यापणं';

  @override
  String get featureC4F4Desc =>
      'CSV vCard (.vcf) वा सञ्चिकायाः सम्पर्काः आनीयन्ताम्, अथवा भवतः सम्पर्कसूची तादृश्यां सञ्चिकायां लिख्यताम्, ततः तन्त्रस्य वितरणपत्रेण कुत्र गच्छेत् इति चीयताम्।';

  @override
  String get featureC4F4H0 => 'CSV अन्तः बहिः च';

  @override
  String get featureC4F4H1 => 'vCard (.vcf) अन्तः बहिः च';

  @override
  String get featureC4F4H2 => 'गुप्तसम्पर्काः वर्ज्यन्ते';

  @override
  String get featureC5Name => 'दत्तांशसमन्वयः प्रतिलिपिरक्षणं च';

  @override
  String get featureC5Subtitle =>
      'भवतः सम्पर्काः सुरक्षिताः समन्विताः सर्वत्र प्रत्यानेयाः च रक्ष्यन्ताम्';

  @override
  String get featureC5F0Title => 'दूरभाषसम्पर्क-आह्वानलेखसमन्वयः';

  @override
  String get featureC5F0Desc =>
      'अनुप्रयोगस्य दूरभाषसम्पर्कसूच्याः च मध्ये भवता चितायां दिशि सम्पर्काः प्रतिलिख्यन्ताम् — प्रत्येकं भवान् एव प्रवर्तयति। दूरभाषस्य आह्वानलेखः स्वयम् इतिवृत्तं प्रविशति।';

  @override
  String get featureC5F0H0 => 'उभयदिशि, इच्छानुसारम्';

  @override
  String get featureC5F0H1 => 'योजयति अद्यतनीकरोति च, कदापि न लुम्पति';

  @override
  String get featureC5F0H2 => 'आह्वानलेखः स्वयम् आगच्छति';

  @override
  String get featureC5F1Title => 'स्थानीय-Wi-Fi उपकरणसमन्वयः';

  @override
  String get featureC5F1Desc =>
      'एकस्मिन् Wi-Fi जाले द्वयोः दूरभाषयोः मध्ये, पटलात् कदापि न निर्गच्छता युग्मनसङ्केतेन गुप्तीकृत्य, सम्पर्काः प्रेष्यन्ताम्। किमपि न आरोप्यते, ग्राहकदूरभाषे च किमपि न लुप्यते।';

  @override
  String get featureC5F1H0 => 'दूरभाषात् दूरभाषं साक्षात्';

  @override
  String get featureC5F1H1 => 'QR युग्मनसङ्केतेन गुप्तीकृतम्';

  @override
  String get featureC5F1H2 => 'मेघः न आवश्यकः';

  @override
  String get featureC5F2Title => 'संयुक्तसमन्वयः गुप्तमेघप्रतिलिपिः च';

  @override
  String get featureC5F2Desc =>
      'इच्छया Google, Microsoft, CardDAV सेवकेन वा सह सम्पर्काः समन्वीयन्ताम्, गुप्तवाक्येन गुप्तीकृता प्रतिलिपिसञ्चिका Google Drive, OneDrive, स्वकीये WebDAV कोशे वा आरोप्यताम्।';

  @override
  String get featureC5F2H0 => 'Google, Microsoft, WebDAV च';

  @override
  String get featureC5F2H1 => 'गुप्तवाक्येन गुप्तीकृता सञ्चिका';

  @override
  String get featureC5F2H2 => 'गुप्तसम्पर्काः कदापि न आरोप्यन्ते';

  @override
  String get featureC5F3Title => 'असंयुक्ताः प्रतिलिपि-पुनःस्थापनसञ्चिकाः';

  @override
  String get featureC5F3Desc =>
      'सर्वं — सम्पर्काः, आह्वानेतिवृत्तं, चित्राणि, विन्यासाः, आपत्कालपत्रं च — गुप्तवाक्येन तालितायाम् एकस्यां सञ्चिकायां रक्षित्वा कस्मिन्नपि दूरभाषे पुनःस्थाप्यताम्। गुप्तवाक्यम् एव कुञ्चिका; अनुप्रयोगः तत् कदापि न रक्षति।';

  @override
  String get featureC5F3H0 => 'सञ्चिकां प्रति निर्यापणम्';

  @override
  String get featureC5F3H1 => 'सुरक्षितं गुप्तीकृतं रूपम्';

  @override
  String get featureC5F3H2 => 'पुनःस्थापनं सर्वं परिवर्तयति';

  @override
  String get featureC6Name => 'आह्वानरक्षा अवाञ्छितनिरोधः च';

  @override
  String get featureC6Subtitle =>
      'अवाञ्छिताह्वानेभ्यः अनिष्टसङ्ख्याभ्यः च आत्मा रक्ष्यताम्';

  @override
  String get featureC6F0Title => 'स्वचालिताह्वानपरीक्षा';

  @override
  String get featureC6F0Desc =>
      'दूरभाषध्वननात् पूर्वम् अन्तर्निर्मिता परीक्षासेवा प्रत्येकाम् आगच्छन्तीं सङ्ख्यां परीक्ष्य निरुद्धावल्यां स्थिताः प्रत्याख्याति — सर्वथा अस्मिन् दूरभाषे, भवतः स्वकीयया आवल्या सह।';

  @override
  String get featureC6F0H0 => 'ध्वननात् पूर्वं प्रत्याख्यातम्';

  @override
  String get featureC6F0H1 => 'संयुक्ते किमपि न अन्विष्यते';

  @override
  String get featureC6F0H2 => 'मुख्यदूरभाषानुप्रयोगेन सह';

  @override
  String get featureC6F1Title => 'निरुद्धसङ्ख्याव्यवस्था';

  @override
  String get featureC6F1Desc =>
      'इतिवृत्ते दीर्घस्पर्शेन, आह्वानमध्ये निरोधनियन्त्रणेन, स्वयं टङ्कनेन वा सङ्ख्या निरुध्यताम्। प्रचलत्याह्वाने निरोधः तत् सद्यः विच्छिनत्ति; कः प्रयतितवान् इति द्रष्टुं निरुद्धाह्वानानि इतिवृत्ते दृश्यन्ते एव।';

  @override
  String get featureC6F1H0 => 'इतिवृत्तात् आह्वानमध्ये वा निरोधः';

  @override
  String get featureC6F1H1 => 'निरोधावलीव्यवस्था';

  @override
  String get featureC6F1H2 => 'कदापि विमोचनम्';

  @override
  String get featureC6F2Title => 'अज्ञातसम्भाषकनिरोधः';

  @override
  String get featureC6F2Desc =>
      'सङ्ख्यां विना गुप्तसङ्ख्यया वा आगच्छन्ति आह्वानानि प्रत्याख्यायन्ताम्। ध्वननात् पूर्वं तानि प्रत्याख्यायन्ते, तथापि निरुद्धानि इति इतिवृत्ते अभिलिख्यन्ते।';

  @override
  String get featureC6F2H0 => 'गुप्तसङ्ख्याः प्रत्याख्याताः';

  @override
  String get featureC6F2H1 => 'तथापि इतिवृत्ते अभिलिखिताः';

  @override
  String get featureC6F2H2 => 'एकेन स्पर्शेन सक्रियम्';

  @override
  String get featureC6F3Title => 'सम्भाषकाभिज्ञानम् अवाञ्छितपरिशोधकः च';

  @override
  String get featureC6F3Desc =>
      'स्थानीयतया ज्ञातुं शक्यैः भवतः सम्पर्केषु अविद्यमानाः सम्भाषकाः चिह्न्यन्ताम् — विपणनसेवासङ्ख्याश्रेणयः, भवता अवाञ्छिताः इति चिह्निताः सङ्ख्याः, जालस्य प्रमाणितसम्भाषकचिह्नं च। चिह्निताः उच्चैः न, मौनेन ध्वनितुं शक्नुवन्ति।';

  @override
  String get featureC6F3H0 => 'अज्ञातसम्भाषकान् चिह्नयति';

  @override
  String get featureC6F3H1 => 'अवाञ्छितं मौनेन ध्वनति';

  @override
  String get featureC6F3H2 => 'सङ्ख्या अवाञ्छिता इति चिह्न्यताम्';

  @override
  String get featureC7Name => 'वैयक्तिकीकरणं सुलभता च';

  @override
  String get featureC7Subtitle =>
      'रूपं, ध्वनिः, प्रादेशिकविन्यासाः च भवतः रुच्यनुसारं समायोज्यन्ताम्';

  @override
  String get featureC7F0Title => 'रूपविन्यासः, मुख्यवर्णः, अक्षररूपं च';

  @override
  String get featureC7F0Desc =>
      'दीप्त-श्याम-तन्त्रप्रकारेषु अन्यतमः चीयतां, मुख्यवर्णः चीयतां, अक्षररूपम् अक्षरपरिमाणं च निर्धार्यताम्। अनुप्रयोगेण सह त्रीणि अक्षररूपाणि मलयाळम् आङ्ग्लं च धारयन्ति।';

  @override
  String get featureC7F0H0 => 'श्यामं दीप्तं च रूपम्';

  @override
  String get featureC7F0H1 => 'चितवर्णसमूहाः';

  @override
  String get featureC7F0H2 => 'अक्षररूपं परिमाणं च';

  @override
  String get featureC7F1Title => 'प्रतिSIM-समूह-सम्पर्कम् आह्वानध्वनयः';

  @override
  String get featureC7F1Desc =>
      'SIM 1 SIM 2 च, समूहाय, एकस्मै सम्पर्काय वा भिन्नाः आह्वानध्वनयः दीयन्ताम्। विशिष्टतमः जयति: सम्पर्कस्य, ततः तस्य समूहस्य, ततः SIM इत्यस्य।';

  @override
  String get featureC7F1H0 => 'प्रतिSIM भिन्नः ध्वनिः';

  @override
  String get featureC7F1H1 => 'समूहाह्वानध्वनयः';

  @override
  String get featureC7F1H2 => 'प्रतिसम्पर्कम् आह्वानध्वनयः';

  @override
  String get featureC7F2Title => 'आपत्कालसूचना-तालपटलपत्रम्';

  @override
  String get featureC7F2Desc =>
      'प्रमुखाः आरोग्यसूचनाः (रक्तवर्गः, प्रत्यूर्जताः, आपत्कालसम्पर्काः) उद्घाटनं विना प्रथमसहायकैः तालपटले दृश्याः इति सज्जीक्रियन्ताम्।';

  @override
  String get featureC7F2H0 => 'तालपटले सुलभम्';

  @override
  String get featureC7F2H1 => 'प्रतिक्षेत्रं गोपनीयतानियन्त्रणम्';

  @override
  String get featureC7F2H2 => 'साक्षात् आपत्कालाह्वानम्';

  @override
  String get featureC7F3Title => 'मुख्यदेशस्य आह्वानसङ्केतः';

  @override
  String get featureC7F3Desc =>
      'पूर्वसङ्केतरहिताः साधारणसङ्ख्याः कस्य देशस्य इति अनुप्रयोगाय कथ्यताम्। +91 98765 43210 तः आह्वानं भवतः सम्पर्केषु 98765 43210 इति अभिज्ञायते अनेन एव; निरुद्धसङ्ख्यामेलनाय अपि एतत् प्रयुज्यते।';

  @override
  String get featureC7F3H0 => 'स्वतः देशपूर्वसङ्केतः';

  @override
  String get featureC7F3H1 => 'अन्ताराष्ट्रियरूपम्';

  @override
  String get featureC7F3H2 => 'सम्भाषकान् सम्पर्कैः मेलयति';

  @override
  String get featureC7F4Title => 'सम्पर्कगणना अन्वेषणसूची च';

  @override
  String get featureC7F4Desc =>
      'दूरभाषे अनुप्रयोगे च कति सम्पर्काः सन्ति इति दृश्यताम्, T9 नामान्वेषणं च शीघ्रं करोति या अन्वेषणसूची तस्याः स्वास्थ्यं परीक्ष्यताम्। कश्चित् सम्पर्कः अन्वेषणे न दृश्यते चेत् क्षणेन सा पुनर्निर्मीयताम्।';

  @override
  String get featureC7F4H0 => 'दूरभाष-अनुप्रयोगगणना';

  @override
  String get featureC7F4H1 => 'सूचीस्वास्थ्यपरीक्षा';

  @override
  String get featureC7F4H2 => 'एकस्पर्शेन पुनर्निर्माणम्';

  @override
  String get featureC7F5Title => 'अनुप्रयोगान्तःसाहाय्यं मार्गदर्शिकाः च';

  @override
  String get featureC7F5Desc =>
      'अत्रत्यां प्रत्येकां विशेषतां — आह्वानं, निरोधः, समन्वयः, प्रतिलिपयः, गोपनीयता, वितरणम् इत्यादि — सरलतया व्याख्याताः विंशत्यधिकाः मार्गदर्शिकाः, सह प्रश्नोत्तराणि समस्यापरिहारपृष्ठं च। सर्वम् असंयुक्तम्, अनुप्रयोगस्य अन्तः।';

  @override
  String get featureC7F5H0 => 'प्रतिविशेषतं मार्गदर्शिका';

  @override
  String get featureC7F5H1 => 'प्रश्नोत्तराणि समस्यापरिहारः च';

  @override
  String get featureC7F5H2 => 'असंयुक्तं कार्यं करोति';

  @override
  String get titleFeaturesHeader => 'SreerajP Contacts Sphere विशेषताः';

  @override
  String get descFeaturesHeader =>
      'भवदर्थं निर्मितानि सर्वाणि बुद्धिमन्ति साधनानि, गोपनीयतारक्षाः, आह्वानविशेषताः च दृश्यन्ताम्।';

  @override
  String get msgSavedCardOff => 'रक्षितम्। तालपटलपत्रं निष्क्रियम्।';

  @override
  String get msgSavedNothingOn =>
      'रक्षितम्। दर्शनाय अद्यापि किमपि सक्रियं नास्ति।';

  @override
  String get msgSavedCardOn => 'रक्षितम्। पत्रं भवतः तालपटले अस्ति।';

  @override
  String errorCouldNotSave(String error) {
    return 'रक्षितुं न शक्तम्: $error';
  }

  @override
  String get titleLeaveWithoutSaving => 'अरक्षित्वा निर्गम्यतां वा?';

  @override
  String get descUnsavedEmergency =>
      'आपत्कालपत्रे भवतः परिवर्तनानि न रक्षितानि।';

  @override
  String get actionKeepEditing => 'सम्पादनम् अनुवर्त्यताम्';

  @override
  String get actionDiscard => 'त्यज्यताम्';

  @override
  String get errorNothingToShare => 'वितरणाय पत्रे किमपि सक्रियं नास्ति।';

  @override
  String get descShareFormatted =>
      'व्यवस्थितं विवरणं सन्देशेन विद्युत्पत्रेण वा प्रेष्यताम्।';

  @override
  String get actionShareAsCardImage => 'पत्रचित्ररूपेण वितीर्यताम्';

  @override
  String get descShareCardImage => 'ICE पत्रस्य चित्रं (PNG) प्रेष्यताम्।';

  @override
  String get tooltipShareIceCard => 'ICE पत्रं वितीर्यताम्';

  @override
  String get descEmergencyWarning =>
      'अत्र भवता सक्रियीकृतं सर्वं भवतः PIN विना दूरभाषधारकः कोऽपि पठितुं शक्नोति। आपत्कालपत्रस्य प्रयोजनम् एतदेव — अतः अपरिचितेन यत् द्रष्टव्यं तदेव सक्रियीक्रियताम्।';

  @override
  String get labelShowOnLockScreen => 'तालपटले दर्श्यताम्';

  @override
  String get descShowOnLockScreen =>
      'एकस्पर्शापत्कालाह्वानयुक्तां स्थिरसूचनां योजयति। उच्चवर्णभेदयुक्तेन आपत्काल-QR-सङ्केतेन सह तालपटलस्य उपरि पत्रम् उद्घाटयति।';

  @override
  String get labelNameOnCard => 'पत्रे दृश्यं नाम';

  @override
  String get labelShowTheName => 'नाम दर्श्यताम्';

  @override
  String get descNotificationsOff =>
      'अस्य अनुप्रयोगस्य सूचनाः निष्क्रियाः, अतः पत्रं कुत्रापि न दृश्यते।';

  @override
  String get descNotificationSilent =>
      'इयं सूचना मौना इति निर्धारिता। बहुषु दूरभाषेषु तालपटलं मौनसूचनाः गोपयति।';

  @override
  String get actionOpenNotificationSettings => 'सूचनाविन्यासः उद्घाट्यताम्';

  @override
  String get titleNotSeeingOnLock => 'तालपटले न दृश्यते वा?';

  @override
  String get descLockScreenTips =>
      'तालपटले काः सूचनाः दृश्येरन् इति दूरभाषः एव निश्चिनोति। इदं तन्त्रविन्यासं परीक्ष्यताम्:\n\nSettings → Notifications → Notifications on lock screen\n\n\"Show conversations, default and silent\" इति चीयताम्। यदि \"Hide silent notifications\" \"Don\'t show any notifications\" वा निर्धारितम्, तर्हि आपत्कालपत्रं तत्र न दृश्यते — कोऽपि अनुप्रयोगः तत् अतिक्रमितुं न शक्नोति।';

  @override
  String get labelMedicalDetails => 'आरोग्यविवरणम्';

  @override
  String get labelAllergies => 'प्रत्यूर्जताः';

  @override
  String get labelMedicines => 'औषधानि';

  @override
  String get labelConditions => 'रोगाः';

  @override
  String get labelAddressField => 'सङ्केतः';

  @override
  String get hintAllergies => 'यथा पेनिसिलिन्, भूचणकाः';

  @override
  String get hintMedicines => 'नियमेन सेव्यमानानि औषधानि';

  @override
  String get hintConditions => 'यथा मधुमेहः, अपस्मारः';

  @override
  String get hintHomeAddress => 'गृहसङ्केतः';

  @override
  String get hintEmergencyNotes => 'सहायकेन ज्ञातव्यम् अन्यत् किमपि';

  @override
  String get labelOrganDonor => 'अङ्गदाता';

  @override
  String get labelShowOrganDonor => '\"अङ्गदाता\" इति दर्श्यताम्';

  @override
  String get labelPeopleToCall => 'आह्वातव्याः जनाः';

  @override
  String get descPeopleToCall =>
      'प्रत्येकस्मै पत्रे आह्वानकुञ्चिका भवति। तालपटलात् साक्षात् आह्वानं क्रियते।';

  @override
  String get emptyNoOneAdded => 'अद्यापि कोऽपि न योजितः।';

  @override
  String get actionFromContacts => 'सम्पर्केभ्यः';

  @override
  String get actionTypeANumber => 'सङ्ख्या लिख्यताम्';

  @override
  String get tooltipShownOnCard => 'पत्रे दृश्यते';

  @override
  String get tooltipHidden => 'गुप्तम्';

  @override
  String get labelWhatStrangerSees => 'अपरिचितः यत् पश्यति';

  @override
  String get descCardSwitchedOff => 'न किमपि — पत्रं निष्क्रियम्।';

  @override
  String get descNothingYetFill =>
      'अद्यापि न किमपि। एकं क्षेत्रं पूरयित्वा सक्रियीक्रियताम्।';

  @override
  String get descTapSaveToApply =>
      'तालपटले परिवर्तनानि प्रयोक्तुं \"रक्ष्यताम्\" स्पृश्यताम्।';

  @override
  String get titleChoosePersonToCall => 'आह्वातव्यजनचयनम्';

  @override
  String get titleAddPerson => 'जनयोजनम्';

  @override
  String get titleEditPerson => 'जनसम्पादनम्';

  @override
  String get labelNumber => 'सङ्ख्या';

  @override
  String get labelRelationOptional => 'सम्बन्धः (वैकल्पिकः)';

  @override
  String get hintRelationExample => 'यथा पत्नी, वैद्यः';

  @override
  String get errorNameAndNumberNeeded => 'नाम सङ्ख्या च उभे आवश्यके।';

  @override
  String get labelNotSet => 'अनिर्धारितम्';

  @override
  String errorFailedLoadGroups(String error) {
    return 'समूहाः आनेतुं न शक्ताः: $error';
  }

  @override
  String get errorCouldNotCreateGroup =>
      'समूहः स्रष्टुं न शक्तः (नाम पूर्वमेव स्यात्)।';

  @override
  String get titleGroupName => 'समूहनाम';

  @override
  String get hintGroupExample => 'यथा कुटुम्बम्';

  @override
  String get actionOk => 'अस्तु';

  @override
  String errorCouldNotSaveRingtone(String error) {
    return 'आह्वानध्वनिः रक्षितुं न शक्तः: $error';
  }

  @override
  String errorCouldNotClearRingtone(String error) {
    return 'आह्वानध्वनिः अपनेतुं न शक्तः: $error';
  }

  @override
  String get errorNoContactsToAdd => 'योजनाय कोऽपि सम्पर्कः नास्ति।';

  @override
  String titleAddToGroup(String name) {
    return '\"$name\" इत्यत्र योज्यताम्';
  }

  @override
  String get msgNoNewContactsAdded => 'न कोऽपि नूतनः सम्पर्कः योजितः।';

  @override
  String msgContactsAddedToGroup(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः \"$name\" इत्यत्र योजिताः',
      one: 'एकः सम्पर्कः \"$name\" इत्यत्र योजितः',
    );
    return '$_temp0';
  }

  @override
  String errorCouldNotAddContacts(String error) {
    return 'सम्पर्काः योजयितुं न शक्ताः: $error';
  }

  @override
  String titleDeleteGroupConfirm(String name) {
    return '\"$name\" लुप्यतां वा?';
  }

  @override
  String get descDeleteGroup => 'समूहः अपनीयते; तस्य सम्पर्काः न लुप्यन्ते।';

  @override
  String get emptyNoGroups => 'अद्यापि कोऽपि समूहः नास्ति।';

  @override
  String get actionAddContactsEllipsis => 'सम्पर्काः योज्यन्ताम्…';

  @override
  String get actionRingtoneEllipsis => 'आह्वानध्वनिः…';

  @override
  String get actionClearRingtone => 'आह्वानध्वनिः अपनीयताम्';

  @override
  String get emptyNoTags =>
      'अद्यापि किमपि चिह्नं नास्ति। सम्पर्काय चिह्नानि योज्यन्तां, तानि अत्र दृश्यन्ते।';

  @override
  String get descTagCloudHint =>
      'चिह्नस्य सम्पर्कान् द्रष्टुं तत् स्पृश्यताम्। नामपरिवर्तनाय एकीकरणाय लोपाय वा दीर्घं स्पृश्यताम्।';

  @override
  String titleAddToTag(String tag) {
    return '#$tag इत्यत्र योज्यताम्';
  }

  @override
  String msgContactsAddedToTag(int count, String tag) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः #$tag इत्यत्र योजिताः',
      one: 'एकः सम्पर्कः #$tag इत्यत्र योजितः',
    );
    return '$_temp0';
  }

  @override
  String titleRemoveTagConfirm(String tag) {
    return '#$tag अपनीयतां वा?';
  }

  @override
  String descRemoveTagFrom(String name) {
    return '$name इत्यस्मात् चिह्नम् अपनीयते। सम्पर्कः स्वयं न लुप्यते।';
  }

  @override
  String get descRemoveTagFromThis =>
      'अस्मात् सम्पर्कात् चिह्नम् अपनीयते। सम्पर्कः स्वयं न लुप्यते।';

  @override
  String msgRemovedTag(String tag) {
    return '#$tag अपनीतम्';
  }

  @override
  String errorCouldNotRemove(String error) {
    return 'अपनेतुं न शक्तम्: $error';
  }

  @override
  String get tooltipRenameMergeDeleteTag => 'नामपरिवर्तनम्, एकीकरणं, लोपः';

  @override
  String get actionAddContacts => 'सम्पर्काः योज्यन्ताम्';

  @override
  String get emptyTagNoContacts =>
      'कस्यापि सम्पर्कस्य इदं चिह्नं नास्ति।\n\nअधः केचन योज्यन्ताम्, उपरितनसूच्याः चिह्नं वा लुप्यताम्।';

  @override
  String get tooltipRemoveTagFromContact => 'सम्पर्कात् चिह्नम् अपनीयताम्';

  @override
  String get labelNoPhone => 'दूरभाषः नास्ति';

  @override
  String errorFailedFindDuplicates(String error) {
    return 'द्विरुक्तानि अन्वेष्टुं न शक्तम्: $error';
  }

  @override
  String get titleMergeThisSet => 'अयं समूहः एकीक्रियतां वा?';

  @override
  String descMergeThisSet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'चितः सम्पर्कः रक्ष्यते, अन्ये $count तस्मिन् एकीक्रियन्ते। इदं प्रत्यावर्तयितुं न शक्यते।',
      one:
          'चितः सम्पर्कः रक्ष्यते, अन्यः एकः तस्मिन् एकीक्रियते। इदं प्रत्यावर्तयितुं न शक्यते।',
    );
    return '$_temp0';
  }

  @override
  String msgMergedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काः एकीकृताः',
      one: 'एकः सम्पर्कः एकीकृतः',
    );
    return '$_temp0';
  }

  @override
  String errorMergeFailed(String error) {
    return 'एकीकरणम् असफलम्: $error';
  }

  @override
  String get errorNothingSelectedToMerge => 'एकीकरणाय किमपि न चितम्।';

  @override
  String get titleMergeAllSets => 'सर्वे समूहाः एकीक्रियन्तां वा?';

  @override
  String descMergeAllSets(int sets, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets समूहानाम्',
      one: 'एकस्य समूहस्य',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total सम्पर्काणाम्',
      one: 'एकस्य सम्पर्कस्य',
    );
    return '$_temp0 समाधानम्; $_temp1 रक्षितेषु एकीकरणम्। इदं प्रत्यावर्तयितुं न शक्यते।';
  }

  @override
  String get actionMerge => 'एकीक्रियताम्';

  @override
  String get labelScanning => 'अन्विष्यते…';

  @override
  String labelDuplicateSetsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count द्विरुक्तसमूहाः प्राप्ताः',
      one: 'एकः द्विरुक्तसमूहः प्राप्तः',
    );
    return '$_temp0';
  }

  @override
  String get labelNoDuplicates => 'द्विरुक्तानि न सन्ति';

  @override
  String get descTapToKeep =>
      'कः रक्षणीयः इति चेतुं सम्पर्कः स्पृश्यताम्; अन्येषां चिह्नम् अपनीयताम्।';

  @override
  String get labelAllCleanedUp => 'सर्वं शुद्धम्';

  @override
  String get descNoMoreDuplicates =>
      'द्विरुक्ताः सम्पर्काः न सन्ति। भवतः सम्पर्कसूची सुव्यवस्थिता।';

  @override
  String get labelUnnamed => 'अनामकः';

  @override
  String get labelKeep => 'रक्ष्यताम्';

  @override
  String labelKeepingMerging(int count) {
    return 'एकः रक्ष्यते · $count एकीक्रियन्ते';
  }

  @override
  String get labelNothingSelected => 'किमपि न चितम्';

  @override
  String get labelToMerge => 'एकीकरणाय';

  @override
  String get actionMergeAllSets => 'सर्वे समूहाः एकीक्रियन्ताम्';

  @override
  String msgAuditExported(int count) {
    return 'हस्ताक्षरितः परिवर्तनलेखः सफलतया निर्यापितः ($count प्रविष्टयः प्रमाणिताः)।';
  }

  @override
  String get titleClearAuditLog => 'परिवर्तनलेखः रिक्तीक्रियतां वा?';

  @override
  String get descClearAuditLog =>
      'भवतः सम्पर्काः न स्पृश्यन्ते — केवलं तेषां परिवर्तनलेखः। अद्यापि अप्रत्यावर्तितं किमपि इतः परं प्रत्यावर्तयितुं न शक्यते।';

  @override
  String get msgAuditCleared => 'परिवर्तनलेखः रिक्तीकृतः।';

  @override
  String get titleAuditLog => 'परिवर्तनलेखः';

  @override
  String get actionExportSignedAuditLog => 'हस्ताक्षरितलेखः निर्याप्यताम्';

  @override
  String get tooltipHideSecret => 'गुप्तसम्पर्काः गोप्यन्ताम्';

  @override
  String get tooltipShowSecret => 'गुप्तसम्पर्काः दर्श्यन्ताम्';

  @override
  String get actionClearLog => 'लेखः रिक्तीक्रियताम्';

  @override
  String descAuditIntro(int days) {
    return 'योजितः सम्पादितः लुप्तः वा प्रत्येकः सम्पर्कः SHA-256 गूढहैश-शृङ्खलया सह $days दिनानि अत्र अभिलिख्यते। परिवर्तनानि द्रष्टुं प्रविष्टिः स्पृश्यतां, निर्यापणाय वा \"हस्ताक्षरितलेखः निर्याप्यताम्\" स्पृश्यताम्।';
  }

  @override
  String descChainVerified(int verified, int total) {
    return 'हस्तक्षेपरोधिशृङ्खला प्रमाणिता ($verified / $total प्रविष्टयः संयुक्ताः)';
  }

  @override
  String descChainTampered(String row) {
    return 'सुरक्षापूर्वसूचना: #$row पङ्क्तौ हस्तक्षेपः दृष्टः!';
  }

  @override
  String get labelAuditAdded => 'योजितानि';

  @override
  String get labelAuditEdited => 'सम्पादितानि';

  @override
  String get labelAuditDeleted => 'लुप्तानि';

  @override
  String get emptyAuditNothing =>
      'अद्यापि किमपि न अभिलिखितम्। भवतः सम्पर्कपरिवर्तनानि अत्र दृश्यन्ते।';

  @override
  String get emptyAuditFilter => 'अस्मिन् परिशोधके किमपि न अभिलिखितम्।';

  @override
  String get labelSourceManual => 'अनुप्रयोगे';

  @override
  String get labelSourceDeviceSync => 'दूरभाषसम्पर्कसमन्वयः';

  @override
  String get labelSourceMerge => 'एकीकृतानि द्विरुक्तानि';

  @override
  String get labelSourceRestore => 'प्रतिलिपिपुनःस्थापनम्';

  @override
  String get labelSourceP2pSync => 'अन्योपकरणात् समन्वयः';

  @override
  String get labelSourceImport => 'सञ्चिकानयनम्';

  @override
  String get labelSourceUndo => 'लेखात् प्रत्यावर्तनम्';

  @override
  String get labelSourceUnknown => 'अज्ञातम्';

  @override
  String get titleUndoThisChange => 'इदं परिवर्तनं प्रत्यावर्त्यतां वा?';

  @override
  String get actionUndo => 'प्रत्यावर्त्यताम्';

  @override
  String get msgContactRemovedAgain => 'सम्पर्कः पुनः अपनीतः।';

  @override
  String get msgChangeUndone => 'परिवर्तनं प्रत्यावर्तितम्।';

  @override
  String errorUndoFailed(String error) {
    return 'प्रत्यावर्तनम् असफलम्: $error';
  }

  @override
  String get titleChangeDetails => 'परिवर्तनविवरणम्';

  @override
  String get descNoVisibleChange =>
      'लेखे दृश्यं किमपि क्षेत्रं भिन्नं नास्ति। अस्मिन् सम्पर्के किञ्चित् लिखितम् इति परिवर्तनम् अभिलिखितम्।';

  @override
  String get labelWhatChanged => 'किं परिवर्तितम्';

  @override
  String get labelBefore => 'पूर्वम्';

  @override
  String get labelAfter => 'पश्चात्';

  @override
  String get descUndone =>
      'इदं परिवर्तनं प्रत्यावर्तितम्। प्रत्यावर्तनम् अपि नूतनप्रविष्टिरूपेण अभिलिखितम्।';

  @override
  String get descCannotUndo =>
      'इयं प्रविष्टिः प्रत्यावर्तयितुं न शक्यते — पूर्वरूपस्य रक्षिता प्रतिलिपिः नास्ति।';

  @override
  String get labelUndone => 'प्रत्यावर्तितम्';

  @override
  String get actionUndoThisChange => 'परिवर्तनं प्रत्यावर्त्यताम्';

  @override
  String get titleOpenThisContact => 'अयं सम्पर्कः उद्घाट्यताम्';

  @override
  String get descSeeContactNow => 'सम्पर्कः इदानीन्तनरूपेण दृश्यताम्।';

  @override
  String get descUndoCreate => 'प्रत्यावर्तनेन अयं सम्पर्कः पुनः लुप्यते।';

  @override
  String get descUndoUpdate => 'प्रत्यावर्तनेन पुरातनं विवरणं पुनः स्थाप्यते।';

  @override
  String get descUndoDelete =>
      'प्रत्यावर्तनेन अयं सम्पर्कः पुनः सृज्यते। तस्य नूतनः id भवति, अतः पुरातनम् आह्वानेतिवृत्तम् असंयुक्तं तिष्ठति; येषां सम्बन्धानाम् अपरः जनः अद्यापि वर्तते ते एव पुनः आगच्छन्ति।';

  @override
  String get labelPhoto => 'चित्रम्';

  @override
  String get labelSecret => 'गुप्तम्';

  @override
  String get labelFavourite => 'प्रियम्';

  @override
  String get labelSelf => 'स्वयम्';

  @override
  String get labelPhoneContactsLink => 'दूरभाषसम्पर्कसम्बन्धः';

  @override
  String get labelAddresses => 'सङ्केताः';

  @override
  String get labelWorkDetails => 'कार्यविवरणम्';

  @override
  String get actionBackUpNow => 'इदानीं प्रतिलिपिः क्रियताम्';

  @override
  String get descBackUpNow =>
      'सर्वे सम्पर्काः चित्राणि विन्यासाः च गुप्तशब्दरक्षितायाम् एकस्यां सञ्चिकायां रक्ष्यन्ताम्।';

  @override
  String get actionRestoreFromFile => 'सञ्चिकातः पुनःस्थाप्यताम्';

  @override
  String get descRestoreFromFile =>
      'प्रतिलिपिसञ्चिका आनीयताम्। एतत् अनुप्रयोगे विद्यमानं सर्वं प्रतिस्थापयति।';

  @override
  String get descBackupPasswordNote =>
      'प्रतिलिपिः भवतः गुप्तशब्देन पिहिता। सः सुरक्षितः स्थाप्यताम् — तेन विना सञ्चिका अस्मिन् अन्यस्मिन् वा दूरभाषे उद्घाटयितुं न शक्यते। नूतने दूरभाषे पुनःस्थापनाय अपि सः एव गुप्तशब्दः आवश्यकः।';

  @override
  String get msgCreatingBackup => 'प्रतिलिपिः क्रियते…';

  @override
  String get msgBackupReady => 'प्रतिलिपिः सज्जा। कुत्र रक्षणीया इति चीयताम्।';

  @override
  String errorBackupFailed(String error) {
    return 'प्रतिलिपिः असफला: $error';
  }

  @override
  String get msgRestoring => 'पुनःस्थाप्यते…';

  @override
  String get msgRestoreComplete => 'पुनःस्थापनं सम्पूर्णम्।';

  @override
  String errorRestoreFailed(String error) {
    return 'पुनःस्थापनम् असफलम्: $error';
  }

  @override
  String get titleReplaceAllData => 'सर्वः दत्तांशः प्रतिस्थाप्यतां वा?';

  @override
  String get descReplaceAllData =>
      'पुनःस्थापनेन अनुप्रयोगे विद्यमानं सर्वं — सर्वे सम्पर्काः, आह्वानेतिवृत्तं, समूहाः, विन्यासाः च — लुप्यते, प्रतिलिप्या च प्रतिस्थाप्यते। एतत् प्रत्यावर्तयितुं न शक्यते।';

  @override
  String errorPasswordTooShort(int count) {
    return 'न्यूनातिन्यूनं $count अक्षराणि प्रयुज्यन्ताम्।';
  }

  @override
  String get errorPasswordsDontMatch => 'गुप्तशब्दौ न मिलतः।';

  @override
  String get errorEnterBackupPassword => 'प्रतिलिपेः गुप्तशब्दः दीयताम्।';

  @override
  String get titleSetBackupPassword => 'प्रतिलिपिगुप्तशब्दः स्थाप्यताम्';

  @override
  String get titleBackupPassword => 'प्रतिलिपिगुप्तशब्दः';

  @override
  String get labelPassword => 'गुप्तशब्दः';

  @override
  String get labelEnterPassword => 'गुप्तशब्दः दीयताम्';

  @override
  String get labelConfirmPassword => 'गुप्तशब्दः पुनः दीयताम्';

  @override
  String get actionBackUp => 'प्रतिलिपिः क्रियताम्';

  @override
  String get actionRestore => 'पुनःस्थाप्यताम्';

  @override
  String get titleSendToDevice => 'अन्योपकरणं प्रति प्रेष्यताम्';

  @override
  String get descSendToDevice =>
      'Wi-Fi द्वारा भवतः सम्पर्काः (अन्यत् च) अन्येन दूरभाषेण सह विभज्यन्ताम्।';

  @override
  String get titleReceiveFromDevice => 'अन्योपकरणात् गृह्यताम्';

  @override
  String get descReceiveFromDevice =>
      'अन्यस्य दूरभाषस्य सम्पर्काः अस्मिन् दूरभाषे योज्यन्ताम्। अत्र विद्यमानं किमपि न परिवर्त्यते न अपनीयते।';

  @override
  String get descSyncFooter =>
      'उभौ दूरभाषौ एकस्मिन् एव Wi-Fi जाले स्याताम्, इमम् अनुप्रयोगं च चालयेताम्।';

  @override
  String get descSameWifi => 'उभौ दूरभाषौ एकस्मिन् एव Wi-Fi जाले स्याताम्।';

  @override
  String get msgConnecting => 'संयुज्यते…';

  @override
  String get msgWaitingForSender => 'संयुक्तम् — प्रेषकस्य चयनं प्रतीक्ष्यते…';

  @override
  String get titleReceived => 'प्राप्तम्';

  @override
  String descReceivedSummary(int added, int skipped) {
    return '$added नूतनाः सम्पर्काः योजिताः (अस्मिन् दूरभाषे पूर्वमेव स्थिताः $skipped रक्षिताः)। किमपि न अपनीतम्।';
  }

  @override
  String get titleCouldNotReceive => 'ग्रहणम् असफलम्';

  @override
  String get errorEnterAddressPortCode =>
      'सङ्केतः, पोर्ट्, युग्मनसङ्केतः च दीयन्ताम्';

  @override
  String get descReceiveAddsOnly =>
      'एतत् अपरस्य दूरभाषस्य सम्पर्कान् अस्मिन् दूरभाषे योजयति। विद्यमानाः सम्पर्काः यथावत् रक्ष्यन्ते — अत्र किमपि न परिवर्त्यते न अपनीयते।';

  @override
  String get actionScanOtherPhoneQr => 'अपरदूरभाषस्य QR परीक्ष्यताम्';

  @override
  String get descOrEnterByHand => 'अथवा हस्तेन दीयताम्';

  @override
  String get labelOtherPhoneAddress => 'अपरदूरभाषसङ्केतः';

  @override
  String get labelPort => 'पोर्ट्';

  @override
  String get labelPairingCode => 'युग्मनसङ्केतः';

  @override
  String get hintShownOnOtherPhone => 'अपरदूरभाषे दर्शितः';

  @override
  String get actionConnect => 'संयुज्यताम्';

  @override
  String get errorNotPairingCode =>
      'एषः SreerajP Contacts Sphere युग्मनसङ्केतः नास्ति';

  @override
  String get titleScanPairingCode => 'युग्मनसङ्केतः परीक्ष्यताम्';

  @override
  String get titleSent => 'प्रेषितम्';

  @override
  String descSentSummary(int contacts, int groups, int callLogs) {
    return '$contacts सम्पर्काः, $groups समूहाः, $callLogs आह्वानलेखाः च अपरदूरभाषं प्रति प्रेषिताः।';
  }

  @override
  String get titleCouldNotSend => 'प्रेषणम् असफलम्';

  @override
  String get descSendIntro =>
      'अस्य दूरभाषस्य SreerajP Contacts Sphere दत्तांशः तस्मिन् एव Wi-Fi जाले स्थितेन अन्येन दूरभाषेण सह विभज्यताम्। अधः आरभ्यतां, ततः अपरस्मिन् दूरभाषे QR परीक्ष्यतां (सङ्केतः वा लिख्यताम्)। संयोगात् परं किं प्रेषणीयम् इति चीयताम्।';

  @override
  String get actionStart => 'आरभ्यताम्';

  @override
  String get descScanThisCode =>
      'अपरस्मिन् दूरभाषे \"गृह्यताम्\" इति चित्वा अयं सङ्केतः परीक्ष्यताम्:';

  @override
  String get descEnterTheseByHand => '…अथवा एतानि हस्तेन दीयन्ताम्:';

  @override
  String get labelThisPhoneAddress => 'अस्य दूरभाषस्य सङ्केतः';

  @override
  String get actionCopyCode => 'सङ्केतः प्रतिलिख्यताम्';

  @override
  String get msgAddressCopied => 'सङ्केतः प्रतिलिखितः';

  @override
  String get msgCodeCopied => 'युग्मनसङ्केतः प्रतिलिखितः';

  @override
  String get msgWaitingForOtherPhone => 'अपरः दूरभाषः प्रतीक्ष्यते…';

  @override
  String get labelOtherPhoneConnected => 'अपरदूरभाषः संयुक्तः';

  @override
  String get labelCallHistory => 'आह्वानेतिवृत्तम्';

  @override
  String get labelBlockedSpamNumbers => 'अवरुद्धाः अनिष्टाः च सङ्ख्याः';

  @override
  String get labelEmergencyInfoCard => 'आपत्कालसूचनापत्रम्';

  @override
  String get labelAppSettings => 'अनुप्रयोगविन्यासाः';

  @override
  String get titleChooseWhatToShare => 'किं विभजनीयम् इति चीयताम्';

  @override
  String get descNeverOverrides =>
      'एतत् अपरदूरभाषे पूर्वं स्थितं किमपि कदापि न अधिलिखति। विरोधे सति अपरः दूरभाषः स्वदत्तांशं रक्षति।';

  @override
  String get actionFullSyncNewPhone => 'पूर्णसमन्वयः (नूतनदूरभाषाय)';

  @override
  String get labelOrSendOnly => 'अथवा केवलम् एतानि प्रेष्यन्ताम्:';

  @override
  String get labelAlwaysIncluded => 'सर्वदा अन्तर्भूतम्';

  @override
  String get actionSendSelected => 'चितानि प्रेष्यन्ताम्';

  @override
  String get titleFullSync => 'पूर्णसमन्वयः वा?';

  @override
  String get descFullSync =>
      'सर्वं प्रेष्यताम् (सम्पर्काः, समूहाः, आह्वानेतिवृत्तं, सम्बन्धाः, अवरुद्धसङ्ख्याः, विन्यासाः च)। नूतनदूरभाषाय उत्तमम्। अपरः दूरभाषः पूर्वस्थितं दत्तांशं रक्षति एव।';

  @override
  String get actionSendEverything => 'सर्वं प्रेष्यताम्';

  @override
  String get descScreenshotGuardRow =>
      'पटलचित्राणि, अभिलेखनानि, अद्यतनसूच्यां पूर्वदृश्यं च निरुध्यन्ताम्।';

  @override
  String get descAuditLogRow =>
      'भवतः सम्पर्केषु किं परिवर्तितं, तत् कथं प्रत्यावर्तनीयम् इति।';

  @override
  String get descLockOff => 'निष्क्रियम् — अनुप्रयोगः तालकं विना उद्घाट्यते';

  @override
  String get descLockDevice => 'सक्रियम् — उपकरणतालकेन उद्घाट्यताम्';

  @override
  String get descLockAppPin =>
      'सक्रियम् — अनुप्रयोगस्य PIN इत्यनेन उद्घाट्यताम्';

  @override
  String get titleAppLock => 'अनुप्रयोगतालकम्';

  @override
  String get labelLockOff => 'निष्क्रियम्';

  @override
  String get descLockOffOption => 'अनुप्रयोगोद्घाटने तालकं नास्ति';

  @override
  String get labelDeviceLock => 'उपकरणतालकम्';

  @override
  String get descDeviceLockOption => 'अङ्गुलिमुद्रा, मुखं, उपकरणस्य PIN वा';

  @override
  String get descDeviceLockUnavailable =>
      'एतस्य प्रयोगाय उपकरणे पटलतालकं स्थाप्यताम्';

  @override
  String get labelAppPin => 'अनुप्रयोगस्य PIN';

  @override
  String get descAppPinOption => 'केवलम् अस्मै अनुप्रयोगाय पृथक् PIN';

  @override
  String get descUnlockReason => 'SreerajP Contacts Sphere उद्घाट्यताम्';

  @override
  String get titleAppLocked => 'SreerajP Contacts Sphere पिहितम्';

  @override
  String get descUnlockDevice =>
      'अनुवर्तनाय अङ्गुलिमुद्रया मुखेन उपकरणस्य PIN इत्यनेन वा उद्घाट्यताम्';

  @override
  String get labelUnlocking => 'उद्घाट्यते…';

  @override
  String get actionUnlock => 'उद्घाट्यताम्';

  @override
  String get descEnterAppPin => 'अनुवर्तनाय अनुप्रयोगस्य PIN दीयताम्';

  @override
  String get actionForgotPin => 'PIN विस्मृतः वा?';

  @override
  String get titleEnterRecoveryCode => 'पुनर्लाभसङ्केतः दीयताम्';

  @override
  String get descEnterRecoveryCode =>
      'PIN स्थापनकाले रक्षितः पुनर्लाभसङ्केतः दीयताम्। एतेन अनुप्रयोगतालकं निष्क्रियं भवति, येन नूतनः PIN स्थापयितुं शक्यते।';

  @override
  String get labelRecoveryCode => 'पुनर्लाभसङ्केतः';

  @override
  String get errorIncorrectCode => 'अशुद्धः सङ्केतः';

  @override
  String get titleSetAppPin => 'अनुप्रयोगस्य PIN स्थाप्यताम्';

  @override
  String get titleConfirmPin => 'PIN पुनः दीयताम्';

  @override
  String get titleSaveRecoveryCode => 'पुनर्लाभसङ्केतः रक्ष्यताम्';

  @override
  String get descChoosePin =>
      'अनुप्रयोगोद्घाटनाय 4 तः 6 अङ्कपर्यन्तं PIN चीयताम्';

  @override
  String get descEnterSamePin => 'स एव PIN पुनः दीयताम्';

  @override
  String get descRecoveryCodeInfo =>
      'PIN विस्मृते सति अनेन सङ्केतेन पुनः प्रवेष्टुं शक्यते। एषः लिखित्वा सुरक्षितः स्थाप्यताम् — एकवारम् एव दर्श्यते।';

  @override
  String get errorCouldNotSavePin =>
      'PIN रक्षितुं न अशक्नोत्। पुनः प्रयत्यताम्।';

  @override
  String get errorPinsDidntMatch => 'PIN द्वयं न मिलितम् — पुनः आरभ्यताम्';

  @override
  String get actionConfirm => 'निश्चीयताम्';

  @override
  String get msgRecoveryCodeCopied => 'पुनर्लाभसङ्केतः प्रतिलिखितः';

  @override
  String get actionCopy => 'प्रतिलिख्यताम्';

  @override
  String get actionSavedTurnOnLock => 'रक्षितम् — अनुप्रयोगतालकं सक्रियताम्';

  @override
  String get descThemeModeRow => 'प्रकाश-अन्धकार-प्रणालीरूपेषु एकं चीयताम्';

  @override
  String get descTypographyRow => 'अनुप्रयोगस्य अक्षररूपम् अक्षरपरिमाणं च';

  @override
  String get descAccentColorRow =>
      'स्वकीयवर्णाः, पूर्वनिश्चितवर्णाः, सद्यःपूर्वदृश्यं च';

  @override
  String titleSpeedDialSlot(int slot) {
    return 'त्वरितसङ्ख्या $slot';
  }

  @override
  String get descSpeedDialIntro =>
      'आह्वानपटले कञ्चित् कुञ्जिकां धृत्वा तस्यां रक्षितः जनः आहूयते। सङ्ख्यापेटिका रिक्ता चेत् एव एतत् कार्यं करोति। गुप्तसम्पर्काः कुञ्जिकायां रक्षितुं न शक्यन्ते।';

  @override
  String get descTapToChooseContact => 'सम्पर्कचयनाय स्पृश्यताम्';

  @override
  String tooltipRemoveFromKey(int slot) {
    return '$slot कुञ्जिकातः अपनीयताम्';
  }

  @override
  String get descDefaultCountryInfo =>
      'आगताः आहूताः च सङ्ख्याः भवतः सम्पर्कैः सह मेलयितुं प्रयुज्यते';

  @override
  String get tooltipOpenSystemSettings => 'प्रणालीविन्यासाः उद्घाट्यन्ताम्';

  @override
  String get labelExplicitPerms => 'स्पष्टानुमतयः';

  @override
  String get descExplicitPerms =>
      'उपयोक्त्रा साक्षात् अनुमन्तव्याः अनुमतयः प्रणालीभूमिकाः च।';

  @override
  String get labelImplicitPerms => 'स्वतःअनुमतयः';

  @override
  String get descImplicitPerms =>
      'अनुप्रयोगे घोषिताः; स्थापनकाले प्रणाल्या स्वतः अनुमताः।';

  @override
  String get labelGranted => 'अनुमतम्';

  @override
  String get labelDenied => 'निषिद्धम्';

  @override
  String get labelPermDialer => 'मूलदूरभाषानुप्रयोगः';

  @override
  String get descPermDialer =>
      'SreerajP Contacts Sphere स्वकीयम् आह्वानपटलम् आह्वानपरीक्षणनियन्त्रणानि च दर्शयेत् इति प्रणाल्याः आह्वानानुप्रयोगः भवतु।';

  @override
  String get labelPermContacts => 'सम्पर्काः';

  @override
  String get descPermContacts =>
      'उपकरणस्य सम्पर्कपुस्तकात् सम्पर्काणां पठनाय समन्वयाय च।';

  @override
  String get labelPermPhone => 'दूरभाषः आह्वानलेखः च';

  @override
  String get descPermPhone =>
      'आह्वानानि कर्तुं स्वीकर्तुं नियन्त्रयितुं च, आह्वानलेखात् वास्तविकावधिं मेलयितुं च।';

  @override
  String get labelPermMicrophone => 'ध्वनिग्राहकम्';

  @override
  String get descPermMicrophone => 'टिप्पणीयोजनकाले वाचा लेखनाय।';

  @override
  String get labelPermLocation => 'स्थानम्';

  @override
  String get descPermLocation =>
      'सम्पर्केषु स्थानचिह्नाय, पुरातने Android मध्ये BLE अन्वेषणाय च।';

  @override
  String get labelPermNotifications => 'सूचनाः';

  @override
  String get descPermNotifications =>
      'जन्मदिनानाम्, अनुवर्तनानाम्, अप्राप्ताह्वानानां च स्मारकाणि दर्शयितुम्।';

  @override
  String get labelPermAlarms => 'अलार्म्-स्मारकाणि';

  @override
  String get descPermAlarms =>
      'अनुप्रयोगे पिहिते अपि Smart Redial निर्धारितकाले पुनः आह्वयेत् इति।';

  @override
  String get labelPermPhotos => 'चित्राणि माध्यमानि च';

  @override
  String get descPermPhotos => 'चित्रसञ्चयात् सम्पर्काय चित्रचयनाय।';

  @override
  String get labelPermCamera => 'छायाचित्रयन्त्रम्';

  @override
  String get descPermCamera =>
      'सम्पर्काय नूतनचित्रग्रहणाय QR सङ्केतपरीक्षणाय वा।';

  @override
  String get labelPermBtScan => 'Bluetooth अन्वेषणम्';

  @override
  String get descPermBtScan =>
      'Bluetooth द्वारा सम्पर्कं विभजमानं समीपस्थं दूरभाषं अन्वेष्टुम् (neverForLocation सह घोषितम्)।';

  @override
  String get labelPermBtConnect => 'Bluetooth संयोगः';

  @override
  String get descPermBtConnect =>
      'Bluetooth द्वारा सम्पर्कप्रेषणाय अन्येन दूरभाषेण संयोजनाय।';

  @override
  String get labelPermBtAdvertise => 'Bluetooth प्रकाशनम्';

  @override
  String get descPermBtAdvertise =>
      'Bluetooth द्वारा सम्पर्कविभजनकाले अयं दूरभाषः अन्यैः दृश्येत इति।';

  @override
  String get labelPermBiometrics => 'जैवमितिः';

  @override
  String get descPermBiometrics =>
      'अङ्गुलिमुद्रया मुखेन वा गुप्तसम्पर्काणाम् उद्घाटनाय, तेषां निर्यापणात् समन्वयात् वा पूर्वं प्रमाणीकरणाय च।';

  @override
  String get labelPermProximity => 'कर्णसमीपे पटलनिरोधः';

  @override
  String get descPermProximity =>
      'आह्वानकाले दूरभाषे कर्णसमीपं धृते कपोलः नियन्त्रणानि न स्पृशेत् इति पटलं निरुध्यते।';

  @override
  String get labelPermCallService => 'आह्वानसेवा घण्टानादः च';

  @override
  String get descPermCallService =>
      'सक्रियाह्वानसेवाः, पूर्णपटलागमनसूचनाः, आह्वानागमने कम्पनं च चालयति।';

  @override
  String get labelPermBtLegacy => 'Bluetooth (पुरातनम्)';

  @override
  String get descPermBtLegacy =>
      'Android 11 तथा ततः अधस्तनेषु Bluetooth प्रयोगः।';

  @override
  String get labelPermBoot => 'पुनरारम्भानन्तरं प्रारम्भः';

  @override
  String get descPermBoot =>
      'दूरभाषस्य पुनरारम्भानन्तरं आपत्कालसूचनापत्रं तालपटले पुनः स्थापयति। अन्यस्मै किमपि न प्रयुज्यते।';

  @override
  String get labelPermInternet => 'अन्तर्जालं Wi-Fi च';

  @override
  String get descPermInternet =>
      'P2P समन्वयकाले स्थानीय-Wi-Fi द्वारा भवतः दत्तांशम् अन्यं दूरभाषं प्रति प्रतिलिखति। कोऽपि मेघसेवकः न सम्पृच्यते।';

  @override
  String get tooltipRefreshSims => 'SIM पुनः पठ्यन्ताम्';

  @override
  String get emptyNoSims =>
      'कोऽपि SIM न दृष्टः। बहु-SIM विकल्पानां कृते दूरभाषानुमतिः न्यूनातिन्यूनम् एकेन SIM युक्तम् उपकरणं च आवश्यकम्। दूरभाषानुमतिं दत्त्वा पुनःपठनं स्पृश्यताम्।';

  @override
  String get descDefaultSimInfo =>
      'प्रत्याह्वानं न चितं चेत् बहिर्गामि-आह्वानानि यं SIM प्रयुञ्जते';

  @override
  String get descLetAndroidChoose => 'Android चिनोतु';

  @override
  String get labelAskSimEachCall => 'प्रत्याह्वानं पूर्वं SIM पृच्छ्यताम्';

  @override
  String get descAskSimEachCall => 'प्रत्याह्वानं SIM चयनपत्रं दर्श्यताम्';

  @override
  String get descNeedsMoreThanOneSim => 'एकाधिकः SIM आवश्यकः';

  @override
  String get labelSimColours => 'SIM वर्णाः';

  @override
  String get descSimColoursInfo => 'आह्वानपटले SIM नाम अनेन वर्णेन दृश्यते';

  @override
  String get labelDefaultColour => 'मूलवर्णः';

  @override
  String titleColourFor(String name) {
    return '$name इत्यस्य वर्णः';
  }

  @override
  String get actionUseDefault => 'मूलं प्रयुज्यताम्';

  @override
  String get titlePerSimRingtones => 'प्रति-SIM घण्टानादाः';

  @override
  String get emptyNoSimsRingtone =>
      'कोऽपि SIM न दृष्टः। प्रति-SIM घण्टानादाय दूरभाषानुमतिः न्यूनातिन्यूनम् एकेन SIM युक्तम् उपकरणं च आवश्यकम्। दूरभाषानुमतिं दत्त्वा पुनःपठनं स्पृश्यताम्।';

  @override
  String get labelPerSimRingtone => 'प्रति-SIM घण्टानादः';

  @override
  String get descPerSimRingtone =>
      'प्रत्येकस्मिन् SIM मध्ये आगताह्वानेभ्यः घण्टानादः';

  @override
  String get tooltipChangeRingtone => 'घण्टानादः परिवर्त्यताम्';

  @override
  String get tooltipPickRingtone => 'घण्टानादः चीयताम्';

  @override
  String get descPerContactRingtoneNote =>
      'एकस्मै सम्पर्काय निर्दिष्टः घण्टानादः प्रति-SIM घण्टानादात् प्राधान्यं लभते। सम्पर्कसम्पादनपटलात् सः स्थाप्यताम्।';

  @override
  String descSlotDefaultRingtone(String slot) {
    return '$slot · मूलघण्टानादः';
  }

  @override
  String descSlotDefaultTone(String slot, String tone) {
    return '$slot · मूलम् · $tone';
  }

  @override
  String get titleVolumeVibration => 'ध्वनिमानं कम्पनं च';

  @override
  String get labelRingtoneVolume => 'घण्टानादध्वनिमानम्';

  @override
  String get descRingtoneMuted =>
      'निःशब्दम् — घण्टानादः न श्रूयते, किन्तु अधः कम्पनं सक्रियं चेत् दूरभाषः कम्पते एव';

  @override
  String descRingtoneVolumePercent(int value) {
    return 'आगताह्वानघण्टानादान् दूरभाषस्य घण्टाध्वनिमानस्य $value% मात्रया वादयति';
  }

  @override
  String get labelVibrateIncoming => 'आगताह्वानेषु कम्पनम्';

  @override
  String get descVibrateIncoming =>
      'दूरभाषस्य विन्यासाः प्रथमाः: निःशब्दरूपं, मा विघ्नय, दूरभाषस्य स्वकीयः “आह्वानेषु कम्पनम्” विन्यासः च एतत् अतिक्रामन्ति';

  @override
  String get descQuietHoursSwitch =>
      'चितान् अनुमतसम्पर्कान् विहाय रात्रौ आह्वानानि निःशब्दीक्रियन्ताम्';

  @override
  String get labelQuietHoursRange => 'शान्तकालावधिः';

  @override
  String get labelAllowedRingThrough => 'अनुमतसम्पर्काः (घण्टा नदति)';

  @override
  String get descAllowedRingThrough =>
      'अनुमतसम्बन्धेषु चिह्नेषु वा स्थिताः चिताः सम्पर्काः च उच्चैः नदन्ति; अन्ये निःशब्दीक्रियन्ते।';

  @override
  String get labelAllowedRelationships => 'अनुमतसम्बन्धाः वर्गाः च';

  @override
  String get labelEmergencyContactsIce => 'आपत्कालसम्पर्काः (ICE)';

  @override
  String get labelStarredContacts => 'तारकितसम्पर्काः';

  @override
  String get actionAddRelationship => 'सम्बन्धः योज्यताम्';

  @override
  String get labelAllowedTags => 'अनुमतचिह्नानि';

  @override
  String get actionAddTag => 'चिह्नं योज्यताम्';

  @override
  String get labelSpecificContacts => 'विशिष्टसम्पर्काः';

  @override
  String labelContactNumber(int id) {
    return 'सम्पर्कः #$id';
  }

  @override
  String get actionAddContact => 'सम्पर्कः योज्यताम्';

  @override
  String labelAllowedActiveNumbers(int count) {
    return 'अनुमताः सक्रियसङ्ख्याः: $count';
  }

  @override
  String get titleSelectAllowedRelationships => 'अनुमतसम्बन्धाः चीयन्ताम्';

  @override
  String get titleSelectAllowedTags => 'अनुमतचिह्नानि चीयन्ताम्';

  @override
  String get emptyNoTagsInContacts =>
      'सम्पर्केषु चिह्नानि न सन्ति। प्रथमं सम्पर्केषु चिह्नानि रच्यन्ताम्।';

  @override
  String get titleSelectAllowedContacts => 'अनुमतसम्पर्काः चीयन्ताम्';

  @override
  String get hintQuietStartTime => 'शान्तकालस्य आरम्भसमयः चीयताम्';

  @override
  String get hintQuietEndTime => 'शान्तकालस्य समाप्तिसमयः चीयताम्';

  @override
  String get titleNewQuickReply => 'नूतनं द्रुतोत्तरम्';

  @override
  String get titleEditQuickReply => 'द्रुतोत्तरं सम्पाद्यताम्';

  @override
  String get hintQuickReplyExample =>
      'उदा. इदानीं वक्तुं न शक्नोमि। पश्चात् आह्वयामि।';

  @override
  String get titleResetQuickReplies => 'द्रुतोत्तराणि पुनःस्थाप्यन्तां वा?';

  @override
  String get descResetQuickReplies =>
      'भवतः स्वकीयसन्देशाः मूलसन्देशैः प्रतिस्थाप्यन्ते।';

  @override
  String get actionReset => 'पुनःस्थाप्यताम्';

  @override
  String get tooltipResetToDefaults => 'मूलरूपं प्रति नीयताम्';

  @override
  String get descQuickRepliesInfo =>
      'आगताह्वानं सन्देशेन सह निराक्रियते चेत् द्रुतोत्तराणि दृश्यन्ते। यस्मिन् SIM मध्ये आह्वानम् आगतं ततः आह्वात्रे SMS रूपेण उत्तरं प्रेष्यते।';

  @override
  String get actionAddReply => 'उत्तरं योज्यताम्';

  @override
  String get descAddReply => 'आह्वाननिराकरणकाले दातुं सन्देशः लिख्यताम्';

  @override
  String get emptyNoQuickReplies =>
      'अद्यापि द्रुतोत्तराणि न सन्ति। एकं योज्यताम्, अथवा उपरि दक्षिणतः मूलरूपं प्रति नीयताम्।';

  @override
  String labelRepliesCount(int count) {
    return 'उत्तराणि ($count)';
  }

  @override
  String get labelCatImmediateFamily => 'निकटकुटुम्बम्';

  @override
  String get labelCatExtendedFamily => 'विस्तृतकुटुम्बम्';

  @override
  String get labelCatFamilyByMarriage => 'विवाहसम्बन्धिनः';

  @override
  String get labelCatProfessional => 'व्यावसायिकम्';

  @override
  String get labelCatEducational => 'शैक्षिकम्';

  @override
  String get labelCatSocial => 'सामाजिकम्';

  @override
  String get labelCatService => 'सेवा';

  @override
  String get titleNewRelationship => 'नूतनः सम्बन्धः';

  @override
  String get titleEditRelationship => 'सम्बन्धः सम्पाद्यताम्';

  @override
  String get labelRelationshipName => 'सम्बन्धनाम';

  @override
  String get errorRelationshipExists => 'सः सम्बन्धः पूर्वमेव वर्तते';

  @override
  String get titleResetRelationshipNames =>
      'सम्बन्धनामानि पुनःस्थाप्यन्तां वा?';

  @override
  String get descResetRelationshipNames =>
      'भवतः स्वकीयसूची अन्तर्निहितसम्बन्धनामभिः प्रतिस्थाप्यते।';

  @override
  String get titleRelationshipNames => 'सम्बन्धनामानि';

  @override
  String get descRelationshipNamesInfo =>
      'द्वयोः सम्पर्कयोः संयोजनकाले एतानि नामानि सप्तसु वर्गेषु स्वस्वर्गे चिप्-रूपेण दृश्यन्ते। इष्टं किमपि नाम लेखितुं शक्यते। अत्र सम्पादनेन रक्षिताः सम्बन्धाः न परिवर्तन्ते।';

  @override
  String get actionAddRelationshipName => 'सम्बन्धः योज्यताम्';

  @override
  String get descAddRelationshipName => 'सम्पर्कसंयोजनकाले दातुं नाम योज्यताम्';

  @override
  String get emptyNoRelationshipNames =>
      'अद्यापि सम्बन्धनामानि न सन्ति। एकं योज्यताम्, अथवा उपरि दक्षिणतः मूलरूपं प्रति नीयताम्।';

  @override
  String labelRelationshipsCount(int count) {
    return 'सम्बन्धाः ($count)';
  }

  @override
  String get labelContactCounts => 'सम्पर्कसङ्ख्या';

  @override
  String get descGrantContactsToCount =>
      'उपकरणसम्पर्कगणनाय सम्पर्कानुमतिः दीयताम्';

  @override
  String descDeviceAppCounts(String device, String app) {
    return 'उपकरणम्: $device  ·  अनुप्रयोगः: $app';
  }

  @override
  String get labelSearchIndex => 'अन्वेषणसूची';

  @override
  String get msgCheckingSearchIndex => 'अन्वेषणसूची परीक्ष्यते...';

  @override
  String get descIndexHealthy => 'सूची स्वस्था — सर्वे सम्पर्काः अन्वेषणीयाः';

  @override
  String descIndexStale(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सम्पर्काणाम् अन्वेषणकुञ्जिकाः पुरातनाः',
      one: '1 सम्पर्कस्य अन्वेषणकुञ्जिकाः पुरातनाः',
    );
    return '$_temp0';
  }

  @override
  String get actionRebuild => 'पुनर्निर्मीयताम्';

  @override
  String get descAuthExportSecret => 'गुप्तसम्पर्कनिर्यापणाय प्रमाणीक्रियताम्';

  @override
  String get errorAuthRequiredExportSecret =>
      'गुप्तसम्पर्कनिर्यापणाय प्रमाणीकरणम् आवश्यकम्';

  @override
  String msgExportedSecretTo(String path) {
    return 'गुप्तसम्पर्काः $path इत्यत्र निर्यापिताः';
  }

  @override
  String errorExportSecretFailed(String error) {
    return 'गुप्तसम्पर्कनिर्यापणम् असफलम्: $error';
  }

  @override
  String get titleSecretContactsExport => 'गुप्तसम्पर्काः निर्यापणं च';

  @override
  String get labelIncludeSecretInExport =>
      'निर्यापणे गुप्तसम्पर्काः अन्तर्भाव्यन्ताम्';

  @override
  String get descIncludeSecretInExport =>
      'निष्क्रियं चेत् सामान्य-VCF निर्यापणे गुप्ततया चिह्निताः सम्पर्काः त्यज्यन्ते';

  @override
  String get labelExportSecretContacts => 'गुप्तसम्पर्काः निर्याप्यन्ताम्';

  @override
  String get descExportSecretContacts =>
      'केवलं गुप्तसम्पर्कयुक्ता पृथक् VCF सञ्चिका रक्ष्यताम् (प्रमाणीकरणेन सह)';

  @override
  String get titleSpokenAnnouncement => 'आह्वातृनामोच्चारणम्';

  @override
  String get descSpokenAnnouncementSwitch =>
      'घण्टानादेन सह आह्वातुः नाम उच्चार्यताम् (\"Amma calling\" / \"അമ്മ വിളിക്കുന്നു\")';

  @override
  String get descSuppressDuringQuiet => 'शान्तकाले नामोच्चारणं निरुध्यताम्';

  @override
  String get labelTestAnnouncement => 'नामोच्चारणं परीक्ष्यताम्';

  @override
  String get descTestAnnouncement => 'आङ्ग्ल-मलयाल-भाषयोः उच्चारणं श्रूयताम्';

  @override
  String get hintQuietStartTimeGeneric => 'शान्तकालस्य आरम्भसमयः चीयताम्';

  @override
  String get hintQuietEndTimeGeneric => 'शान्तकालस्य समाप्तिसमयः चीयताम्';

  @override
  String get descEnterCallerNameToTest => 'परीक्षणाय आह्वातुः नाम दीयताम्:';

  @override
  String get hintCallerNameExample => 'उदा. Amma अथवा അമ്മ';

  @override
  String get actionPlayTest => 'श्रूयताम्';

  @override
  String get titlePostCallOptions => 'आह्वानोत्तरविकल्पाः';

  @override
  String get labelAskAfterCalls => 'आह्वानानन्तरं पृच्छ्यताम्';

  @override
  String get descAskAfterCalls =>
      'आह्वानसमाप्तौ “कथम् अभवत्?” इति पत्रं दर्श्यताम्';

  @override
  String get hintRelationshipNameExample => 'उदा. मार्गदर्शकः';

  @override
  String get helpHomeText1 => 'सहायता मार्गदर्शिकाः च';

  @override
  String get helpHomeHeading1 => 'आह्वानम् आह्वानपटलं च';

  @override
  String get helpHomeTitle1 => 'T9 आह्वानं मलयालं च';

  @override
  String get helpHomeSub1 =>
      'बहुलिपि-T9 अन्वेषणं कथं कार्यं करोति, मलयालस्वराः (അ तः അഃ पर्यन्तम्) कुत्र स्थापिताः।';

  @override
  String get helpHomeTitle2 => 'आह्वानम् आह्वानमध्यनियन्त्रणानि च';

  @override
  String get helpHomeSub2 =>
      'सम्मेलनैकीकरणं, स्थगनं, परिवर्तनं, द्वि-SIM विकल्पाः, Smart Redial, आह्वातृनामोच्चारणं च।';

  @override
  String get helpHomeTitle3 => 'आह्वानपरीक्षणं निरोधः च';

  @override
  String get helpHomeSub3 =>
      'घण्टानादात् पूर्वं सङ्ख्यानिरोधः, अज्ञातानां निरोधः, मूलाह्वानानुप्रयोगभूमिका किमर्थम् आवश्यकी।';

  @override
  String get helpHomeTitle4 => 'आह्वातृपरिचयः अनिष्टपरिशोधकः च';

  @override
  String get helpHomeSub4 =>
      'अज्ञाताह्वातॄणां चिह्नीकरणं, शङ्कितानिष्टानां निःशब्दघण्टानादः, सङ्ख्यायाः अनिष्टत्वेन चिह्नीकरणं च।';

  @override
  String get helpHomeTitle5 => 'आह्वानसन्दर्भः टिप्पण्यः च';

  @override
  String get helpHomeSub5 =>
      'आह्वानात् पूर्वं सारांशः, \"इदानीं स्वीकर्तुं सम्भाव्यम्\", आह्वानानन्तरं भवता लिखिताः टिप्पण्यः च।';

  @override
  String get helpHomeHeading2 => 'व्यवस्था विभजनं च';

  @override
  String get helpHomeTitle6 => 'सम्बन्धमण्डलानि';

  @override
  String get helpHomeSub6 =>
      'निकटकुटुम्बात् सेवापर्यन्तं 7 वर्गाः, भवतः स्वकीयनामानि, शान्तकालः च।';

  @override
  String get helpHomeTitle7 => 'समूहाः चिह्नानि च';

  @override
  String get helpHomeSub7 =>
      'समूहनिर्माणं, समूहघण्टानादाः, चिह्नमेघः, बहूनां सम्पर्काणां युगपत् चयनं च।';

  @override
  String get helpHomeTitle8 => 'द्विरुक्तसम्पर्काः एकीकरणं च';

  @override
  String get helpHomeSub8 =>
      'समाननामानि दूरभाषाः ईमेल्-सङ्केताः च कथं ज्ञायन्ते, दत्तांशहानिं विना एकीक्रियन्ते च।';

  @override
  String get helpHomeTitle9 => 'विभजनं पत्रपरीक्षणं च';

  @override
  String get helpHomeSub9 =>
      'QR सम्पर्कसङ्केताः, उपकरणस्थः व्यापारपत्रपरीक्षकः, Bluetooth द्वारा विभजनं च।';

  @override
  String get helpHomeTitle10 => 'सञ्चिकानयनं निर्यापणं च';

  @override
  String get helpHomeSub10 =>
      'CSV vCard सञ्चिकाः अन्तः बहिः च, एकस्मिन् QR सङ्केते अमान्तं प्रेषयितुं AirQR च।';

  @override
  String get helpHomeHeading3 => 'गोपनीयता संरक्षणं च';

  @override
  String get helpHomeTitle11 => 'गोपनीयता, सुरक्षा, गुप्तकोशः च';

  @override
  String get helpHomeSub11 =>
      'गुप्तसम्पर्ककोशः, जैवमिति/PIN संरक्षणं, पटलचित्ररक्षा, सुरक्षापरिवर्तनलेखः च।';

  @override
  String get helpHomeTitle12 => 'जैवमितितालकविवरणम्';

  @override
  String get helpHomeSub12 =>
      'अनुप्रयोगः यत्र यत्र अङ्गुलिमुद्रां मुखं वा पृच्छति, पटलतालकाभावे किं भवति इति च।';

  @override
  String get helpHomeTitle13 => 'अनुप्रयोगतालकं PIN च';

  @override
  String get helpHomeSub13 =>
      'त्रीणि तालकरूपाणि, अनुप्रयोगस्य PIN स्थापनं, विस्मृते पुनर्लाभसङ्केतः च।';

  @override
  String get helpHomeTitle14 => 'अनुमतीनां व्याख्या';

  @override
  String get helpHomeSub14 =>
      'प्रत्येका अनुमतिः किमर्था, काः ऐच्छिकाः, निषेधे किं न कार्यं करोति इति।';

  @override
  String get helpHomeTitle15 => 'आपत्कालसूचनापत्रम्';

  @override
  String get helpHomeSub15 =>
      'प्रथमसहायकेभ्यः तालपटले आरोग्यविवरणानाम् आपत्कालसम्पर्काणां च स्थापनम्।';

  @override
  String get helpHomeHeading4 => 'समन्वयः प्रतिलिपयः च';

  @override
  String get helpHomeTitle16 => 'स्थानीय-Wi-Fi P2P उपकरणसमन्वयः';

  @override
  String get helpHomeSub16 =>
      'आद्यन्तगूढलेखनेन मेघं विना उपकरणात् उपकरणं प्रति साक्षात् Wi-Fi प्रेषणं कथम्।';

  @override
  String get helpHomeTitle17 => 'सम्पर्कपुस्तक-आह्वानलेखसमन्वयः';

  @override
  String get helpHomeSub17 =>
      'सम्पर्काणाम् आह्वानेतिवृत्तस्य च Android प्रणालीकोशेन सह एकीकरणं प्रतिबिम्बनं वा।';

  @override
  String get helpHomeTitle18 => 'मेघसमन्वयः Google Drive च';

  @override
  String get helpHomeSub18 =>
      'उभयदिक्-जालसमन्वयः, गूढमेघप्रतिलिपयः, WebDAV स्थापनं, गुप्तकोशगोपनीयता च।';

  @override
  String get helpHomeTitle19 => 'जालरहितप्रतिलिपिः पुनःस्थापनं च';

  @override
  String get helpHomeSub19 =>
      'गूढप्रतिलिपिसञ्चिकानां निर्यापणं, गुप्तशब्दसुरक्षा, नूतनदूरभाषे पुनःस्थापनं च।';

  @override
  String get helpHomeHeading5 => 'वैयक्तिकीकरणं साधनानि च';

  @override
  String get helpHomeTitle20 => 'रूपं, ध्वनिः, प्रदेशः च';

  @override
  String get helpHomeSub20 =>
      'विषयः प्रधानवर्णः च, अक्षररूपम् अक्षरपरिमाणं च, घण्टानादः कम्पनं च, मूलदेशः च।';

  @override
  String get helpHomeTitle21 => 'सम्पर्कसाधनानि';

  @override
  String get helpHomeSub21 =>
      'स्वयंलुप्यमानाः तात्कालिकसम्पर्काः, संयुक्तसन्देशानुप्रयोगाः, अन्वेषणसूची च।';

  @override
  String get helpHomeHeading6 => 'नित्यप्रश्नाः';

  @override
  String get helpHomeTitle22 => 'नित्यप्रश्नाः समस्यापरिहारः च';

  @override
  String get helpHomeSub22 =>
      'मुख्यप्रश्नानां साक्षात् उत्तराणि: अनुमतयः, मूलाह्वानानुप्रयोगः, शान्तकालः, अन्वेषणसूची च।';

  @override
  String get helpHomeText2 => 'सहायताकेन्द्रं ज्ञानकोशः च';

  @override
  String get helpHomeText3 =>
      'SreerajP Contacts Sphere इत्यस्य सर्वविशेषतानां विस्तृतमार्गदर्शिकाः समाधानानि च दृश्यन्ताम्।';

  @override
  String get helpGroupsTagsTitle1 => 'समूहाः चिह्नानि च';

  @override
  String get helpGroupsTagsIntro =>
      'समूहाः चिह्नानि च एकस्य एव सम्पर्कपुस्तकस्य व्यवस्थापनस्य द्वौ भिन्नौ मार्गौ। सम्पर्कः भवता हस्तेन रचितेषु समूहेषु अन्तर्भवति, लघुनामरूपेण भवता लिखितानि चिह्नानि च धारयति। उभयं भवतः एव — अनुप्रयोगः स्वयं किमपि न रचयति।';

  @override
  String get helpGroupsTagsTitle2 => 'समूहाः';

  @override
  String get helpGroupsTagsBullet1 =>
      'सर्वान् समूहान् द्रष्टुं सम्पर्कपटलम् उद्घाट्य उपरितनपट्टिकायां समूहचिह्नं स्पृश्यताम्।';

  @override
  String get helpGroupsTagsBullet2 =>
      'समूहं रचयित्वा नाम दत्त्वा सदस्याः योज्यन्ताम्। एकः सम्पर्कः अनेकेषु समूहेषु भवितुम् अर्हति।';

  @override
  String get helpGroupsTagsBullet3 =>
      'समूहस्य स्वकीयः घण्टानादः भवितुम् अर्हति। दूरभाषस्य घण्टानादेभ्यः सञ्चिकाकोशस्थात् ध्वनिसञ्चिकायाः वा चीयताम्।';

  @override
  String get helpGroupsTagsBullet4 =>
      'येषां सदस्यानां स्वकीयः घण्टानादः नास्ति तेभ्यः समूहघण्टानादः प्रयुज्यते। सम्पर्कस्य घण्टानादः सर्वदा प्राधान्यं लभते।';

  @override
  String get helpGroupsTagsTitle3 => 'चिह्नानि';

  @override
  String get helpGroupsTagsBullet5 =>
      'सम्पादनकाले सम्पर्के योजितः लघुशब्दः चिह्नम् — \"नलकारः\", \"विद्यालयः\", \"पर्वतारोहणसङ्घः\"। निश्चिता सूची नास्ति; यत् उचितं तत् लिख्यताम्।';

  @override
  String get helpGroupsTagsBullet6 =>
      'अनुप्रयोगस्य अधः स्थितं चिह्नपटलं प्रयुक्तानि सर्वाणि चिह्नानि मेघरूपेण दर्शयति। अधिकसम्पर्केषु प्रयुक्तं चिह्नं बृहत्तरं दृश्यते।';

  @override
  String get helpGroupsTagsBullet7 =>
      'चिह्नं स्पृष्ट्वा तद्धारिणः सर्वे दृश्यन्ते। ततः कमपि आह्वातुं, सन्देशं प्रेषयितुम्, उद्घाटयितुं वा शक्यते।';

  @override
  String get helpGroupsTagsBullet8 =>
      'शान्तकालस्य अपवादसूचीरूपेण अपि चिह्नानि कार्यं कुर्वन्ति, अतः सम्पूर्णचिह्नधारिभ्यः घण्टानादः अनुमन्तुं शक्यते।';

  @override
  String get helpGroupsTagsTitle4 => 'युगपत् बहुषु सम्पर्केषु कार्यम्';

  @override
  String get helpGroupsTagsBullet9 =>
      'चयनम् आरब्धुं सूच्यां कञ्चित् सम्पर्कं दीर्घं स्पृश्यताम्। चयने योजयितुम् अन्ये सम्पर्काः स्पृश्यन्ताम्।';

  @override
  String get helpGroupsTagsBullet10 =>
      'तदा उपरितनपट्टिका \"सर्वं चीयताम्\", \"चितानि लुप्यन्ताम्\" इति ददाति, येन एकपदे बहवः सम्पर्काः अपनेतुं शक्यन्ते।';

  @override
  String get helpGroupsTagsBullet11 =>
      'किमपि अपरिवर्त्य चयनरूपात् निर्गन्तुम् उपरितनपट्टिकायां गुणनचिह्नं स्पृश्यताम्।';

  @override
  String get helpGroupsTagsFooter =>
      'सूचना: समुच्चयः स्थिरः, तस्मै एकः घण्टानादः इष्टः चेत् समूहः प्रयुज्यताम्। केवलं पश्चात् तान् पुनः अन्वेष्टुम् इच्छा चेत् चिह्नं प्रयुज्यताम्।';

  @override
  String get helpAppLockTitle1 => 'अनुप्रयोगतालकं PIN च';

  @override
  String get helpAppLockIntro =>
      'अनुप्रयोगोद्घाटने अनुप्रयोगतालकं सम्पूर्णानुप्रयोगस्य पुरतः एकं पटलं स्थापयति। कथम् उद्घाटनीयम् इति विन्यासाः → सुरक्षा → अनुप्रयोगतालकम् इत्यत्र चीयताम्। त्रयः विकल्पाः सन्ति।';

  @override
  String get helpAppLockTitle2 => 'त्रीणि रूपाणि';

  @override
  String get helpAppLockBullet1 =>
      'निष्क्रियम् — अनुप्रयोगः सद्यः उद्घाट्यते। गुप्तसम्पर्काः तथापि पृथक् उद्घाटनं पृच्छन्ति।';

  @override
  String get helpAppLockBullet2 =>
      'उपकरणतालकम् — दूरभाषस्य स्वकीयाम् अङ्गुलिमुद्रां, मुखं, पटलतालकस्य PIN वा प्रयुङ्क्ते। Android विन्यासेषु पटलतालकस्थापनपर्यन्तम् अयं विकल्पः अनुपलब्धः।';

  @override
  String get helpAppLockBullet3 =>
      'अनुप्रयोगस्य PIN — केवलम् अस्मै अनुप्रयोगाय पृथक् PIN, अनुप्रयोगान्तःस्थे अङ्कपटले लिख्यमानः। अन्ये भवतः दूरभाषस्य PIN जानन्ति चेत् उपयोगी।';

  @override
  String get helpAppLockTitle3 => 'अनुप्रयोगस्य PIN स्थापनम्';

  @override
  String get helpAppLockBullet4 =>
      '4 तः 6 अङ्कपर्यन्तं PIN चित्वा पुनः दीयताम्।';

  @override
  String get helpAppLockBullet5 =>
      'ततः एकवारिकः पुनर्लाभसङ्केतः दर्श्यते। सः लिख्यतां सुरक्षितस्थाने प्रतिलिख्यतां वा — एकवारम् एव दर्श्यते, पुनः कदापि न।';

  @override
  String get helpAppLockBullet6 =>
      'PIN यथा लिखितः तथा न रक्ष्यते, कोऽपि तम् अनुप्रयोगात् पुनः पठितुं न शक्नोति।';

  @override
  String get helpAppLockTitle4 => 'अनुप्रयोगस्य PIN विस्मृतः चेत्';

  @override
  String get helpAppLockBullet7 =>
      'तालपटले \"PIN विस्मृतः वा?\" इति स्पृष्ट्वा पुनर्लाभसङ्केतः दीयताम्।';

  @override
  String get helpAppLockBullet8 =>
      'शुद्धः सङ्केतः अनुप्रयोगतालकं निष्क्रियं कृत्वा प्रवेशयति। तालकम् अद्यापि इष्टं चेत् पश्चात् नूतनः PIN स्थाप्यताम्।';

  @override
  String get helpAppLockBullet9 =>
      'पुनर्लाभसङ्केतं विना तालकम् अतिक्रमितुं कोऽपि मार्गः नास्ति। तत् बुद्धिपूर्वकम् — भवते पृष्ठद्वारं सर्वेभ्यः पृष्ठद्वारं भवेत्।';

  @override
  String get helpAppLockTitle5 => 'पुनः कदा पृच्छ्यते';

  @override
  String get helpAppLockBullet10 =>
      'अनुप्रयोगं त्यक्त्वा पुनः आगमने तालपटलं पुनः आगच्छति, न तु अन्तःस्थे प्रत्येकपटले।';

  @override
  String get helpAppLockBullet11 =>
      'प्रत्यागमनसङ्केतेन तत् अपनेतुं न शक्यते। शुद्धम् उद्घाटनं पुनर्लाभसङ्केतः वा एव प्रवेशयति।';

  @override
  String get helpAppLockFooter =>
      'अनुप्रयोगतालकं द्वारं रक्षति। गुप्तसम्पर्काणां, प्रतिलिपीनां, समन्वयस्य च तदुपरि स्वकीयम् उद्घाटनम् अस्ति — जैवमितितालकमार्गदर्शिका दृश्यताम्।';

  @override
  String get helpContactToolsTitle1 => 'सम्पर्कसाधनानि';

  @override
  String get helpContactToolsIntro =>
      'सुलभं दृष्टिम् अतीत्य गच्छन्ति त्रीणि लघुसाधनानि: स्वयं लुप्यमानाः सम्पर्काः, येषु सम्पर्कः प्राप्यः ते सन्देशानुप्रयोगाः, आह्वानपटलं शीघ्रं जनान् अन्वेष्टुं साहाय्यं कुर्वती अन्वेषणसूची च।';

  @override
  String get helpContactToolsTitle2 => 'क्षणिकाः (तात्कालिकाः) सम्पर्काः';

  @override
  String get helpContactToolsBullet1 =>
      'सम्पर्कयोजने सम्पादने वा \"क्षणिकः सम्पर्कः\" सक्रियतां नीयताम्। पश्चात् सा प्रविष्टिः स्वयम् अपगच्छति।';

  @override
  String get helpContactToolsBullet2 =>
      'कियत्कालं तिष्ठेत् इति चीयताम्: 2 होराः, 24 होराः, 7 दिनानि, \"1 आह्वानानन्तरं स्वयं लोपः\" वा।';

  @override
  String get helpContactToolsBullet3 =>
      'वितरकाय, यानचालकाय, एकवारिकविक्रेत्रे वा उत्तमम् — आवश्यके सङ्ख्या अस्ति, पश्चात् गता।';

  @override
  String get helpContactToolsBullet4 =>
      'सम्पर्कोद्घाटने अपनयनपर्यन्तं कालं गणयत् पताकापत्रं दृश्यते। ततः अन्याः 24 होराः योजयितुं, स्थायित्वेन रक्षितुं वा स्पर्शः कर्तुं शक्यते।';

  @override
  String get helpContactToolsBullet5 =>
      'अनुप्रयोगः प्रायः प्रतिनिमेषम् एकवारं परीक्षते, अतः कालसमाप्तेः किञ्चित् पश्चात् सम्पर्कः अपगच्छति, न तु यथावत् क्षणे।';

  @override
  String get helpContactToolsTitle3 => 'संयुक्तानुप्रयोगाः';

  @override
  String get helpContactToolsBullet6 =>
      'WhatsApp, Telegram, Arattai इत्यादिः सन्देशानुप्रयोगः भवतः दूरभाषस्थेन सम्पर्केण सह समन्वितः चेत्, तस्मिन् सम्पर्के तेषाम् अनुप्रयोगाणां पङ्क्तिः दृश्यते।';

  @override
  String get helpContactToolsBullet7 =>
      'तस्मिन् अनुप्रयोगे साक्षात् संवादम् आह्वानं वा उद्घाटयितुम् एकं स्पृश्यताम्। अयम् अनुप्रयोगः किमपि न प्रेषयति — केवलम् अपरम् उद्घाटयति।';

  @override
  String get helpContactToolsBullet8 =>
      'इयं पङ्क्तिः दूरभाषस्य स्वकीयात् सम्पर्कपुस्तकात् पठ्यते, अतः उपकरणसम्पर्केण संयुक्तेषु एव, सम्पर्कानुमतौ सत्याम् एव दृश्यते।';

  @override
  String get helpContactToolsTitle4 => 'सम्पर्कसङ्ख्या अन्वेषणसूची च';

  @override
  String get helpContactToolsBullet9 =>
      'विन्यासाः → सम्पर्काः → सम्पर्कसङ्ख्या अन्वेषणसूची च इत्यत्र दूरभाषे अनुप्रयोगे च कति सम्पर्काः सन्ति इति दृश्यते — समन्वयः सफलः वा इति ज्ञातुं शीघ्रतमः मार्गः।';

  @override
  String get helpContactToolsBullet10 =>
      'T9 अङ्कपटलान्वेषणं, लिप्यन्तरितान्वेषणं, नामान्वेषणं च शीघ्रं करोति अन्वेषणसूची।';

  @override
  String get helpContactToolsBullet11 =>
      'पटलं \"सूची स्वस्था — सर्वे सम्पर्काः अन्वेषणीयाः\" इति, कति सम्पर्काणाम् अन्वेषणकुञ्जिकाः पुरातनाः इति वा वदति।';

  @override
  String get helpContactToolsBullet12 =>
      'काश्चन पुरातनाः चेत् \"पुनर्निर्मीयताम्\" इति गण्डः दृश्यते। तं स्पृष्ट्वा सम्पूर्णसम्पर्कपुस्तकाय कुञ्जिकाः पुनः निर्मीयन्ते।';

  @override
  String get helpContactToolsBullet13 =>
      'रक्षितः इति ज्ञातः सम्पर्कः अन्वेषणे न लभ्यते चेत्, पुरातनप्रतिलिपेः पुनःस्थापनानन्तरं वा एषा पुनर्निर्मीयताम्।';

  @override
  String get helpContactToolsFooter =>
      'सूचना: कालसमाप्तौ क्षणिकः सम्पर्कः वस्तुतः लुप्यते। सङ्ख्या पश्चात् आवश्यकी स्यात् चेत्, अपगमनात् पूर्वं पताकापत्रे \"स्थायित्वेन रक्ष्यताम्\" इति स्पृश्यताम्।';

  @override
  String get helpCallerIntelligenceTitle1 => 'आह्वानसन्दर्भः टिप्पण्यः च';

  @override
  String get helpCallerIntelligenceIntro =>
      'कस्यचित् आह्वानात् पूर्वं, तस्य आह्वानकाले, आह्वानसमाप्तौ च तं विषये किञ्चित् वक्तुम् अनुप्रयोगः भवतः स्वकीयम् आह्वानेतिवृत्तं पठति। एतत् सर्वं भवतः विद्यमानदत्तांशात् अस्मिन् एव दूरभाषे गण्यते।';

  @override
  String get helpCallerIntelligenceTitle2 => 'आह्वानात् पूर्वम्';

  @override
  String get helpCallerIntelligenceBullet1 =>
      'सम्पर्कोद्घाटने लघुसारांशः दृश्यते: अन्तिमवारं कदा उक्तं, तत् आह्वानं कियत्कालं प्रवृत्तं, तद्विषये भवता किं टिप्पितम्।';

  @override
  String get helpCallerIntelligenceBullet2 =>
      'सम्पर्के नगरयुक्तः सङ्केतः अस्ति चेत्, सारांशः तत्रत्यं स्थानीयसमयम् अपि दर्शयति — अन्यदेशस्थस्य आह्वानात् पूर्वम् उपयोगी।';

  @override
  String get helpCallerIntelligenceBullet3 =>
      'पर्याप्तम् इतिवृत्तम् अस्ति चेत्, अयं जनः प्रायः दिनस्य कस्मिन् काले स्वीकरोति इति सूचयति।';

  @override
  String get helpCallerIntelligenceTitle3 => '\"इदानीं स्वीकर्तुं सम्भाव्यम्\"';

  @override
  String get helpCallerIntelligenceBullet4 =>
      'आह्वानपटलम् अङ्कपटलस्य उपरि सम्पर्काणां लघुपङ्क्तिं दर्शयति। तस्यां किं भवेत् इति विन्यासाः → आह्वानपटलस्य अग्रसम्पर्काः इत्यत्र चीयताम्: नवीनतमाः, कुटुम्बं मित्राणि च, इदानीं स्वीकर्तुं सम्भाव्यं वा।';

  @override
  String get helpCallerIntelligenceBullet5 =>
      '\"इदानीं स्वीकर्तुं सम्भाव्यम्\" अस्यां होरायां प्रायः स्वीकुर्वतः जनान् प्रथमं स्थापयति। दिनस्य अस्मिन् काले आह्वानानि कतिवारं स्वीकृतानि इति भवतः अद्यतनलेखात् गण्यते।';

  @override
  String get helpCallerIntelligenceBullet6 =>
      'एतत् पङ्क्तेः क्रमम् एव परिवर्तयति। अनुप्रयोगः अत्र स्वयं न आह्वयति — प्रत्येकम् आह्वानं भवता कृतः स्पर्शः एव।';

  @override
  String get helpCallerIntelligenceTitle4 => 'दूरभाषे नदति सति';

  @override
  String get helpCallerIntelligenceBullet7 =>
      'रक्षितसम्पर्कस्य कृते आह्वानपटलं तस्य सम्बन्धं, अन्तिमसंवादात् कियान् कालः गतः, आगामि जन्मदिनं वार्षिकोत्सवं वा दर्शयितुं शक्नोति।';

  @override
  String get helpCallerIntelligenceBullet8 =>
      'तस्मै जनाय भवता स्थापितं शेषस्मारकम् अपि दर्श्यते, येन किमर्थं वक्तुम् ऐच्छः इति स्मर्यते।';

  @override
  String get helpCallerIntelligenceTitle5 => 'आह्वानानन्तरम्';

  @override
  String get helpCallerIntelligenceBullet9 =>
      'आह्वानसमाप्तौ \"कथम् अभवत्?\" इति पत्रं दृश्येत। आह्वानं कथम् अभवत् इति टिप्प्यतां, चर्चितं लिख्यताम्, अनुवर्तनस्मारकं स्थाप्यताम्।';

  @override
  String get helpCallerIntelligenceBullet10 =>
      'टिप्पणीं लेखनस्य स्थाने वक्तुं शक्यते — ध्वनिग्राहकं स्पृष्ट्वा उच्यताम्। वाक् दूरभाषे एव लेखरूपं नीयते।';

  @override
  String get helpCallerIntelligenceBullet11 =>
      'भवता रक्षितं सर्वं तस्य सम्पर्कस्य कालरेखायां योज्यते, आगामिसारांशः तत् एव पठति।';

  @override
  String get helpCallerIntelligenceBullet12 =>
      'प्रश्नः न इष्टः चेत्, विन्यासाः → SIM आह्वानं च → आह्वानोत्तरविकल्पाः इत्यत्र पत्रं निष्क्रियं क्रियताम्।';

  @override
  String get helpCallerIntelligenceFooter =>
      'गोपनीयता: एतेषु किमपि दूरभाषं न त्यजति। पृष्ठतः कापि अन्वेषणसेवा नास्ति — अनुप्रयोगः स्वस्य गूढदत्तांशकोशात् भवतः सम्पर्कान्, आह्वानलेखं, टिप्पणीः च एव पठति।';

  @override
  String get helpBiometricsText => 'जैवमितितालकम्';

  @override
  String get helpBiometricsIntro =>
      'भवतः अतिगोपनीयदत्तांशस्य प्रदर्शनात् स्थानान्तरणात् वा पूर्वं SreerajP Contacts Sphere अङ्गुलिमुद्रां मुखं वा प्रष्टुं शक्नोति। एतत् दूरभाषस्य स्वकीयं तालकं प्रयुङ्क्ते — अनुप्रयोगः भवतः अङ्गुलिमुद्रां मुखं वा कदापि न पश्यति न रक्षति।';

  @override
  String get helpBiometricsTitle1 => 'कुत्र पृच्छ्यते';

  @override
  String get helpBiometricsBullet1 =>
      'गुप्तसम्पर्कदर्शने। उद्घाटनपर्यन्तम् एते सामान्यसम्पर्कसूचितः गुप्ताः।';

  @override
  String get helpBiometricsBullet2 =>
      'गुप्तसम्पर्कनिर्यापणे, येन भवतः अनुमतिं विना गोपनीयः सम्पर्कः अनुप्रयोगात् बहिः न प्रेष्येत।';

  @override
  String get helpBiometricsBullet3 =>
      '\"अन्योपकरणेन समन्वयः\" इत्यस्य उद्घाटने, यतः समन्वये गुप्तसम्पर्काः अन्तर्भवितुम् अर्हन्ति।';

  @override
  String get helpBiometricsBullet4 =>
      '\"प्रतिलिपिरक्षणं पुनःस्थापनं च\" इत्यस्य उद्घाटने, यतः प्रतिलिप्याम् अपि ते भवितुम् अर्हन्ति।';

  @override
  String get helpBiometricsBullet5 =>
      'परिवर्तनलेखस्य उद्घाटने, यस्मिन् सम्पर्काणां पूर्वापरयोः पूर्णः अभिलेखः अस्ति।';

  @override
  String get helpBiometricsBullet6 =>
      'केनचित् Bluetooth द्वारा प्रेषितस्य सम्पर्कस्य स्वीकारे।';

  @override
  String get helpBiometricsBullet7 =>
      'विन्यासाः → सुरक्षा इत्यत्र अनुप्रयोगतालकं \"उपकरणतालकम्\" इति स्थापितं चेत्, अनुप्रयोगोद्घाटने एव।';

  @override
  String get helpBiometricsTitle2 => '\"भवान्\" इति किं गण्यते';

  @override
  String get helpBiometricsBullet8 =>
      'दूरभाषे भवता स्थापिता का अपि अङ्गुलिमुद्रा मुखं वा स्वीक्रियते।';

  @override
  String get helpBiometricsBullet9 =>
      'अङ्गुलिमुद्रा मुखं वा न स्थापितं चेत्, दूरभाषः पटलतालकस्य PIN, प्रतिरूपं, गुप्तशब्दं वा प्रयुङ्क्ते।';

  @override
  String get helpBiometricsBullet10 =>
      'अनुप्रयोगतालकं तस्य स्थाने दूरभाषतालकात् पृथक् अनुप्रयोगस्य PIN प्रयोक्तुं शक्नोति। सः अनुप्रयोगेण एव परीक्ष्यते — \"अनुप्रयोगतालकं PIN च\" मार्गदर्शिका दृश्यताम्।';

  @override
  String get helpBiometricsTitle3 => 'भवतः गोपनीयता';

  @override
  String get helpBiometricsBullet11 =>
      'परीक्षणं Android करोति, न तु SreerajP Contacts Sphere। उद्घाटनं सफलम् असफलं वा इति एव अनुप्रयोगः जानाति।';

  @override
  String get helpBiometricsBullet12 =>
      'एतत् जालं विना कार्यं करोति। भवतः अङ्गुलिमुद्राविषये मुखविषये वा किमपि दूरभाषं कदापि न त्यजति।';

  @override
  String get helpBiometricsFooter =>
      'सूचना: Android विन्यासेषु पटलतालकम् (अङ्गुलिमुद्रा, मुखं, PIN वा) स्थाप्यताम्। तालकाभावे परीक्षणं न प्रवर्तते, अतः समन्वयः प्रतिलिपिः च पूर्वसूचनां दत्त्वा अनुवर्तनीयं वा इति भवन्तं पृच्छतः।';

  @override
  String get helpBackupText => 'प्रतिलिपिरक्षणं पुनःस्थापनं च';

  @override
  String get helpBackupIntro =>
      'प्रतिलिपिः अनुप्रयोगस्थं सर्वं भवता रक्ष्यमाणायाम् एकस्यां सञ्चिकायां रक्षति। नूतनं दूरभाषं गन्तुं, पुनर्विन्यासानन्तरं पुनः प्राप्तुं वा तस्याः प्रयोगः शक्यः — नूतनः अनुप्रयोगः अन्यस्रोतसः स्थापितः चेत् अपि।';

  @override
  String get helpBackupTitle1 => 'प्रतिलिप्यां किम् अस्ति';

  @override
  String get helpBackupBullet1 =>
      'सर्वे सम्पर्काः तेषां विवरणानि च, आह्वानेतिवृत्तं, समूहाः, सम्बन्धाः, अवरुद्धाः / अनिष्टाः सङ्ख्याः च।';

  @override
  String get helpBackupBullet2 =>
      'सम्पर्कचित्राणि आह्वानपत्रचित्राणि च सञ्चिकायाम् अन्तर्भवन्ति।';

  @override
  String get helpBackupBullet3 =>
      'विषयः प्रधानवर्णः इत्यादयः भवतः अनुप्रयोगविन्यासाः।';

  @override
  String get helpBackupBullet4 =>
      'आपत्कालसम्पर्कैः \"तालपटले दर्श्यताम्\" इति परिवर्तकैः च सह भवतः आपत्कालसूचनापत्रम्।';

  @override
  String get helpBackupBullet5 =>
      'स्वकीयघण्टानादाः न अन्तर्भवन्ति — ते अस्मिन् दूरभाषे स्थिताः सञ्चिकाः निर्दिशन्ति, याः अन्यत्र न स्युः।';

  @override
  String get helpBackupTitle2 => 'भवतः गुप्तशब्दः एव कुञ्जिका';

  @override
  String get helpBackupBullet6 =>
      'प्रतिलिपिसञ्चिका भवता चितेन गुप्तशब्देन पिधीयते। अनुप्रयोगः तं कुत्रापि न रक्षति।';

  @override
  String get helpBackupBullet7 =>
      'पुनःस्थापनाय सः एव गुप्तशब्दः आवश्यकः — अस्मिन् अन्यस्मिन् वा दूरभाषे। सः सुरक्षितः स्थाप्यताम्।';

  @override
  String get helpBackupBullet8 =>
      'गुप्तशब्दनाशे सञ्चिका उद्घाटयितुं न शक्यते। पुनर्लाभस्य कोऽपि मार्गः नास्ति — तत् एव भवतः दत्तांशं गोपनीयं रक्षति।';

  @override
  String get helpBackupTitle3 => 'पुनःस्थापनं सर्वं प्रतिस्थापयति';

  @override
  String get helpBackupBullet9 =>
      'पुनःस्थापनम् अनुप्रयोगे विद्यमानं लोपयित्वा प्रतिलिपेः यथावत् प्रतिरूपेण पुनः निर्माति।';

  @override
  String get helpBackupBullet10 =>
      'एतत् एकीकरणं नास्ति। दत्तांशहानिं विना द्वौ दूरभाषौ संयोजयितुम् इच्छा चेत्, तस्य स्थाने \"अन्योपकरणेन समन्वयः\" प्रयुज्यताम्।';

  @override
  String get helpBackupBullet11 =>
      'तस्याः एव अनुप्रयोगसंस्करणस्य प्रतिलिपिः पुनःस्थाप्यताम्। अतिभिन्नसंस्करणस्य प्रतिलिपिः निराक्रियेत।';

  @override
  String get helpBackupFooter =>
      'सूचना: प्रतिलिपिनिर्माणानन्तरम् अनुप्रयोगः विभजनपत्रम् उद्घाटयति, येन सञ्चिका Files Drive वा इत्यत्र रक्षितुं, स्वस्मै प्रेषयितुं वा शक्यते। अस्मात् दूरभाषात् अन्यत्र सा रक्ष्यताम्।';

  @override
  String get helpT9DialingText => 'T9 आह्वानं मलयालं च';

  @override
  String get helpT9DialingIntro =>
      'SreerajP Contacts Sphere मध्ये बहुलिपिज्ञः T9 अङ्कपटलः अस्ति। आङ्ग्लैः प्रादेशिकलिपिभिः (मलयालं, देवनागरी इत्यादि) वा कुञ्जिकास्पर्शैः सम्पर्काः सुलभम् अन्वेष्टुं शक्यन्ते।';

  @override
  String get helpT9DialingTitle1 =>
      'मलयालस्वराणां स्थानानि (അ तः അഃ पर्यन्तम्)';

  @override
  String get helpT9DialingBullet1 =>
      'कुञ्जिका 2 (ക-ങ): स्वराः അ, ആ + मात्राः ാ, ി, ീ';

  @override
  String get helpT9DialingBullet2 =>
      'कुञ्जिका 3 (ച-ഞ): स्वराः ഉ, ഊ, ഋ + मात्राः ു, ൂ, ൃ';

  @override
  String get helpT9DialingBullet3 =>
      'कुञ्जिका 4 (ട-ണ): स्वराः എ, ഏ, ഐ + मात्राः െ, േ, ൈ';

  @override
  String get helpT9DialingBullet4 =>
      'कुञ्जिका 5 (ത-ന): स्वराः ഒ, ഓ, ഔ + मात्राः ൊ, ോ, ൌ, ൗ';

  @override
  String get helpT9DialingBullet5 =>
      'कुञ्जिका 9 (ള-റ): अनुस्वारः विसर्गः च (ം, ഃ) + चिल्लक्षराणि (ൺ, ൻ, ർ, ൽ, ൾ, ൿ)';

  @override
  String get helpT9DialingTitle2 => 'स्वराः कुञ्जिकासु किमर्थं न मुद्रिताः';

  @override
  String get helpT9DialingBullet6 =>
      'अङ्कपटलः स्वच्छः सुपठः च भवेत् इति कुञ्जिकासु व्यञ्जनवर्गाः (उदा. ക-ങ, ച-ഞ) एव दर्श्यन्ते।';

  @override
  String get helpT9DialingBullet7 =>
      'गण्डेषु अमुद्रिताः अपि सर्वे स्वराः (അ-ഔ), मात्राः, चिल्लक्षराणि च T9 अन्वेषणे पूर्णतया स्थापितानि सक्रियाणि च।';

  @override
  String get helpT9DialingTitle3 => 'आङ्ग्ललिपिना मलयालान्वेषणं लिप्यन्तरणं च';

  @override
  String get helpT9DialingBullet8 =>
      'आङ्ग्ल-T9 कुञ्जिकास्पर्शाः मलयालनामभिः सह स्वयं मिलन्ति। यथा, 2-6-4-5 (A-N-I-L) इति लेखने \"Anil\" \"അനിൽ\" च उभे लभ्येते।';

  @override
  String get helpT9DialingBullet9 =>
      'कुञ्जिकासु दर्शितां लिपिं परिवर्तयितुं मुख्यविन्यासपृष्ठे \"अङ्कपटललिपिः\" इति पत्रं प्रयुज्यताम्।';

  @override
  String get helpT9DialingFooter =>
      'सूचना: \"अङ्कपटललिपिः\" इति पत्रं स्वयंचालितं, मलयालं, देवनागरी, सिरिलिक्, अरबी, ग्रीक्, न किमपि वा इति ददाति। स्वयंचालितम् अनुप्रयोगभाषाम् अनुसरति। यत् किमपि चीयते, अन्वेषणं सर्वाः लिपीः मेलयति एव — अयं विन्यासः कुञ्जिकासु मुद्रितम् एव परिवर्तयति।';

  @override
  String get helpCloudSyncText => 'मेघसमन्वयः प्रतिलिपिः च';

  @override
  String get helpCloudSyncIntro =>
      'SreerajP Contacts Sphere Google, Microsoft, CardDAV/WebDAV सेवकैः सह संयुज्यते। एकां सेवां, पृथक्कृताः सेवाः वा प्रयोक्तुं शक्यते — सजीवसम्पर्कान् एकया सह समन्वीय, गूढदत्तांशकोशस्य प्रतिलिपिम् अन्यस्यां रक्षितुं शक्यते।';

  @override
  String get helpCloudSyncTitle1 => 'सम्पर्कसमन्वयः मेघप्रतिलिपिः च — भेदः';

  @override
  String get helpCloudSyncBullet1 =>
      'जालसम्पर्कसमन्वयः (सजीवः उभयदिक्): प्रत्येकं सम्पर्कपत्रं (नामानि, दूरभाषसङ्ख्याः, ईमेल्-सङ्केताः) Google People API, Microsoft Graph Contacts, CardDAV सम्पर्कपुस्तकैः वा सह साक्षात् समन्वेति। समन्विताः सम्पर्काः भवतः जालसम्पर्कपुस्तके दृश्यन्ते।';

  @override
  String get helpCloudSyncBullet2 =>
      'गूढमेघप्रतिलिपिः: भवतः सम्पूर्णदत्तांशकोशयुक्तां (सर्वे सम्पर्काः, आह्वानेतिवृत्तम्, आह्वानटिप्पण्यः, चिह्नानि, विन्यासाः, आपत्कालसूचनाः च) गुप्तशब्देन गूढां .csbak सञ्चिकां मेघसञ्चिकाकोशं (Google Drive AppData, Microsoft OneDrive, WebDAV वा) प्रति निर्यापयति।';

  @override
  String get helpCloudSyncTitle2 => 'मेघसेवानां मिश्रणम्';

  @override
  String get helpCloudSyncBullet3 =>
      'सजीवसम्पर्कसमन्वयाय Google प्रयुज्य, गूढमेघप्रतिलिपयः Microsoft OneDrive मध्ये स्वचालिते WebDAV सेवके वा रक्षितुं शक्यन्ते।';

  @override
  String get helpCloudSyncBullet4 =>
      'विन्यासाः → जालसेवासमन्वयः इत्यत्र भवतः Google खाताय \"सम्पर्कसमन्वयः: सक्रियः\", \"मेघप्रतिलिपिः: निष्क्रिया\" इति स्थाप्यताम्।';

  @override
  String get helpCloudSyncBullet5 =>
      'Microsoft WebDAV वा खातं पृथक् योजयित्वा, विन्यासाः → गूढमेघप्रतिलिपिः इत्यत्र प्रतिलिप्यारोपणकाले तत् चीयताम्।';

  @override
  String get helpCloudSyncTitle3 => 'गोपनीयता सुरक्षा च';

  @override
  String get helpCloudSyncBullet6 =>
      'गुप्तकोशसम्पर्काः: SreerajP Contacts Sphere मध्ये गुप्तत्वेन रक्षिताः सम्पर्काः अनुप्रयोगे एव सन्ति, जालसम्पर्कसेवासु (Google Contacts, Outlook, CardDAV) कदापि न आरोप्यन्ते न समन्वीयन्ते।';

  @override
  String get helpCloudSyncBullet7 =>
      'गूढसामग्री: मेघप्रतिलिपिसञ्चिकाः (.csbak) आरोपणात् पूर्वं भवतः वैयक्तिकगुप्तवाक्येन PBKDF2 AES-GCM च प्रयुज्य दूरभाषे एव गूढीक्रियन्ते। मेघसेवा भवतः प्रतिलिपिदत्तांशं पठितुं न शक्नोति।';

  @override
  String get helpCloudSyncFooter =>
      'सूचना: सर्वाणि स्थापितखातानि विन्यासाः → जालसेवासमन्वयः इत्यत्र नियन्त्रयितुं शक्यन्ते। प्रत्येकस्य खातस्य सजीवसम्पर्कसमन्वयाय मेघप्रतिलिपये च पृथक् परिवर्तकाः सन्ति।';

  @override
  String get helpPersonalizationTitle1 => 'रूपं, ध्वनिः, प्रदेशः च';

  @override
  String get helpPersonalizationIntro =>
      'अनुप्रयोगस्य रूपं, ध्वनिः, दूरभाषसङ्ख्यानां पठनरीतिः च प्रायः सर्वं परिवर्तयितुं शक्यते। प्रत्येकः विन्यासः कुत्र इति अत्र।';

  @override
  String get helpPersonalizationTitle2 => 'विषयः वर्णः च';

  @override
  String get helpPersonalizationBullet1 =>
      'विन्यासाः → रूपम् → विषयरूपम्: प्रकाशः, अन्धकारः, प्रणाली वा। प्रणाली दूरभाषस्य स्वकीयम् अन्धकाररूपविन्यासम् अनुसरति।';

  @override
  String get helpPersonalizationBullet2 =>
      'विन्यासाः → रूपम् → प्रधानवर्णः: पूर्वनिश्चितवर्णः चीयतां स्वकीयवर्णः वा रच्यताम्। चयनकाले पूर्वदृश्यं नवीक्रियते।';

  @override
  String get helpPersonalizationTitle3 => 'अक्षररूपम् अक्षरपरिमाणं च';

  @override
  String get helpPersonalizationBullet3 =>
      'विन्यासाः → रूपम् → अक्षररूपम् अक्षरपरिमाणं च इत्यत्र अक्षररूपम् अक्षराणां परिमाणं च स्थाप्यते।';

  @override
  String get helpPersonalizationBullet4 =>
      'मलयालक्षमाणि त्रीणि अक्षररूपाणि अन्तर्निहितानि — Manjari, Anek Malayalam, Noto Sans Malayalam। प्रत्येकं मलयालम् आङ्ग्लं च दर्शयति, अतः कस्याम् अपि लिप्यां नामानि पठनीयानि।';

  @override
  String get helpPersonalizationBullet5 =>
      'अक्षररूपाणि अनुप्रयोगेन सह एव आगच्छन्ति। किमपि न अवतार्यते, अन्तर्जालं विना अपि कार्यं करोति।';

  @override
  String get helpPersonalizationTitle4 => 'सम्पर्कसूची कथं दृश्यते';

  @override
  String get helpPersonalizationBullet6 =>
      'विन्यासाः → सम्पर्काः → प्रदर्शनं स्वरूपणं च इत्यत्र क्रमः (प्रथमनाम्ना अन्तिमनाम्ना वा) स्थाप्यते।';

  @override
  String get helpPersonalizationBullet7 =>
      'तस्मिन् एव पटले दूरभाषसङ्ख्याहीनाः सम्पर्काः गोपयितुं शक्यन्ते, येन ईमेल्-खातात् आनीता सूची स्वच्छा भवति।';

  @override
  String get helpPersonalizationTitle5 => 'घण्टानादः, ध्वनिमानं, कम्पनं च';

  @override
  String get helpPersonalizationBullet8 =>
      'विन्यासाः → घण्टानादः → ध्वनिमानं कम्पनं च इत्यत्र घण्टानादध्वनिमानम् आगताह्वानेषु कम्पनं वा इति च स्थाप्यते।';

  @override
  String get helpPersonalizationBullet9 =>
      'विन्यासाः → घण्टानादः → प्रति-SIM घण्टानादाः इत्यत्र SIM 1 SIM 2 च भिन्नध्वनी लभेते, येन का पङ्क्तिः नदति इति ज्ञायते।';

  @override
  String get helpPersonalizationBullet10 =>
      'समूहस्य स्वकीयः घण्टानादः भवितुम् अर्हति, कस्मै अपि सम्पर्काय सम्पादनकाले एकः दातुं शक्यते।';

  @override
  String get helpPersonalizationBullet11 =>
      'अनेकेषु प्रयोज्येषु विशिष्टतमः प्राधान्यं लभते: प्रथमं सम्पर्कस्य स्वकीयः ध्वनिः, ततः तस्य समूहस्य, ततः SIM इत्यस्य।';

  @override
  String get helpPersonalizationBullet12 =>
      'घण्टानादाः प्रतिलिप्याम् अन्यदूरभाषसमन्वये वा न अन्तर्भवन्ति, यतः ते अस्मिन् दूरभाषे स्थितां ध्वनिसञ्चिकां निर्दिशन्ति।';

  @override
  String get helpPersonalizationTitle6 => 'मूलदेशः';

  @override
  String get helpPersonalizationBullet13 =>
      'विन्यासाः → मूलदेशः इति उपसर्गरहिताः सामान्यसङ्ख्याः कस्य देशस्य इति अनुप्रयोगं वदति।';

  @override
  String get helpPersonalizationBullet14 =>
      '+91 98765 43210 इत्यस्मात् आह्वानं भवतः सम्पर्केषु रक्षितः 98765 43210 एव जनः इति अनुप्रयोगः अनेन एव जानाति।';

  @override
  String get helpPersonalizationBullet15 =>
      'अवरुद्धसङ्ख्याः अपि तथैव मेल्यन्ते, अतः स्थानीयरूपेण अवरुद्धा सङ्ख्या अन्ताराष्ट्रियरूपम् अपि निरुणद्धि।';

  @override
  String get helpPersonalizationBullet16 =>
      'रक्षितः सम्पर्कः अज्ञाताह्वातृत्वेन दृश्यते चेत् प्रायः अस्य अशुद्धं स्थापनम् एव कारणम्।';

  @override
  String get helpPersonalizationFooter =>
      'सूचना: विषयः, प्रधानवर्णः, अक्षररूपाणि, मूलदेशः च समन्वये अन्यदूरभाषं गच्छन्ति। घण्टानादाः SIM चयनानि च अस्य दूरभाषस्य इति अत्र एव तिष्ठन्ति।';

  @override
  String get helpCallerIdSpamTitle1 => 'आह्वातृपरिचयः अनिष्टपरिशोधकः च';

  @override
  String get helpCallerIdSpamIntro =>
      'भवतः सम्पर्केषु अविद्यमाना सङ्ख्या यदा आह्वयति, तदा अनुप्रयोगः तद्विषये किञ्चित् उपयोगि वक्तुं प्रयतते, शङ्कितानिष्टाह्वानं च उच्चैः न, निःशब्दं नादयितुं शक्नोति। उभौ भवता नियन्त्रितौ परिवर्तकौ, उभौ पूर्णतया अस्मिन् दूरभाषे कार्यं कुरुतः।';

  @override
  String get helpCallerIdSpamTitle2 => 'आह्वातृपरिचयः';

  @override
  String get helpCallerIdSpamBullet1 =>
      'विन्यासाः → SIM आह्वानं च → परिचयः → \"आह्वातृपरिचयः\" इत्यत्र सक्रियः क्रियताम्।';

  @override
  String get helpCallerIdSpamBullet2 =>
      'अज्ञाताह्वात्रे स्थानीयतया ज्ञेयात् एकं नाम दीयते: दूरविपणन-सेवासङ्ख्याश्रेण्यः, भवता स्वयम् अनिष्टत्वेन चिह्निताः सङ्ख्याः, जालं प्रेषयति चेत् तस्य प्रमाणिताह्वातृचिह्नं च।';

  @override
  String get helpCallerIdSpamBullet3 =>
      'आह्वानपटले चिह्नं दृश्यते — शङ्कितानिष्टाय रक्तं, दूरविपणन-सेवासङ्ख्यायै मृदुतरवर्णः।';

  @override
  String get helpCallerIdSpamBullet4 =>
      'का अपि सङ्ख्या अन्तर्जाले न अन्विष्यते। पृष्ठतः कोऽपि आह्वातृपरिचयदत्तांशकोशः नास्ति, किमपि न आरोप्यते।';

  @override
  String get helpCallerIdSpamTitle3 => 'शङ्कितानिष्टानां परिशोधनम्';

  @override
  String get helpCallerIdSpamBullet5 =>
      'तस्मिन् एव पटले द्वितीयः परिवर्तकः, \"शङ्कितानिष्टाः परिशोध्यन्ताम्\", चिह्नितान् आह्वातॄन् उच्चैः न, निःशब्दं नादयति।';

  @override
  String get helpCallerIdSpamBullet6 =>
      'आह्वानं तथापि आगच्छति, अद्यतनलेखे च अभिलिख्यते। केवलं भवतः विघ्नः न भवति।';

  @override
  String get helpCallerIdSpamBullet7 =>
      'कः आहूतवान् इति द्रष्टुम् इच्छा, किन्तु विघ्नः न इष्टः चेत् एतत् प्रयुज्यताम्। आह्वानम् एव न इष्टं चेत् निरोधः प्रयुज्यताम्।';

  @override
  String get helpCallerIdSpamTitle4 => 'अज्ञातानां निरोधः';

  @override
  String get helpCallerIdSpamBullet8 =>
      'विन्यासाः → सम्पर्काः → अवरुद्धसङ्ख्याः इत्यत्र सङ्ख्यां विना गुप्तसङ्ख्यया वा आगताह्वानेभ्यः \"अज्ञाताः निरुध्यन्ताम्\" इति परिवर्तकः अस्ति।';

  @override
  String get helpCallerIdSpamBullet9 =>
      'सक्रिये सति तानि आह्वानानि दूरभाषनादात् पूर्वं निराक्रियन्ते, तथापि अभवन् इति द्रष्टुम् अवरुद्धत्वेन अद्यतनलेखे लिख्यन्ते।';

  @override
  String get helpCallerIdSpamBullet10 =>
      'भवता अरक्षितां सङ्ख्यां एतत् न प्रभावयति — आह्वातृसङ्ख्यारहितानि आह्वानानि एव।';

  @override
  String get helpCallerIdSpamTitle5 => 'सङ्ख्यायाः अनिष्टत्वेन चिह्नीकरणम्';

  @override
  String get helpCallerIdSpamBullet11 =>
      'अद्यतनलेखे आह्वानं दीर्घं स्पृष्ट्वा \"अनिष्टत्वेन चिह्न्यताम्\" इति चीयताम्। पश्चात् तत्र \"अनिष्टं न\" इति दृश्यते, येन चिह्नम् अपनेतुं शक्यते।';

  @override
  String get helpCallerIdSpamBullet12 =>
      'अनिष्टचिह्नं निरोधात् पृथक्। सङ्ख्या तथापि आह्वातुं शक्नोति — इदानीं सा चिह्निता, सः परिवर्तकः सक्रियः चेत् परिशोधकः तां निःशब्दीकरोति।';

  @override
  String get helpCallerIdSpamBullet13 =>
      'भवतः स्वकीयचिह्नानि परिचयनाम्नि योज्यन्ते, येन तस्याः सङ्ख्यायाः आगामि आह्वानं परिचीयते।';

  @override
  String get helpCallerIdSpamFooter =>
      'सूचना: परिचयाय अनिष्टपरिशोधनाय च अनुप्रयोगः भवतः मूलदूरभाषानुप्रयोगः भवेत्, यतः नादात् पूर्वम् आह्वानपरीक्षणं Android केवलं मूलाह्वानानुप्रयोगाय अनुमन्यते।';

  @override
  String get helpImportExportTitle1 => 'सञ्चिकानयनं निर्यापणं च';

  @override
  String get helpImportExportIntro =>
      'सम्पर्काः सामान्यसञ्चिकारूपेण अनुप्रयोगं प्रति बहिः च नेतुं शक्यन्ते — सारणीपत्रे उद्घाटनीया CSV, कस्य अपि दूरभाषस्य सङ्गणकस्य वा सम्पर्कपुस्तकेन अवगम्या vCard (.vcf) वा।';

  @override
  String get helpImportExportTitle2 => 'कुत्र लभ्यते';

  @override
  String get helpImportExportBullet1 =>
      'सम्पर्कपटलम् उद्घाट्य, उपरितनपट्टिकायां त्रिबिन्दुसूचीं स्पृष्ट्वा, \"आनयनं / निर्यापणम्\" इति चीयताम्।';

  @override
  String get helpImportExportBullet2 =>
      'चत्वारः विकल्पाः दृश्यन्ते: CSV आनयनं, CSV निर्यापणं, vCard (.vcf) आनयनं, vCard (.vcf) निर्यापणं च।';

  @override
  String get helpImportExportTitle3 => 'आनयनम्';

  @override
  String get helpImportExportBullet3 =>
      'प्रणालीसञ्चिकाचयनकेन भवान् एव सञ्चिकां चिनोति। अनुप्रयोगः स्वयं भवतः कोशं न अन्विष्यति।';

  @override
  String get helpImportExportBullet4 =>
      'आनीताः सम्पर्काः अनुप्रयोगे योज्यन्ते। आनयनसमाप्तौ कति आगताः इति उच्यते।';

  @override
  String get helpImportExportBullet5 =>
      'सञ्चिका पूर्वविद्यमानान् जनान् आनयति चेत्, पश्चात् सम्पर्काः → सूची → \"द्विरुक्तानि अन्विष्यन्ताम्\" इति प्रयुज्य स्वच्छीक्रियताम्।';

  @override
  String get helpImportExportTitle4 => 'निर्यापणम्';

  @override
  String get helpImportExportBullet6 =>
      'निर्यापणं सञ्चिकां लिखित्वा प्रणालीविभजनपत्रम् उद्घाटयति, कुत्र गच्छेत् इति भवान् निश्चिनोति।';

  @override
  String get helpImportExportBullet7 =>
      'निर्यापणसञ्चिका सामान्या, गुप्तशब्दरक्षिता नास्ति। तां सम्पर्कपुस्तकस्य प्रतिलिपिं मत्वा कार्यसमाप्तौ लोपयतु।';

  @override
  String get helpImportExportBullet8 =>
      'विन्यासाः → सम्पर्काः → गुप्तसम्पर्काः निर्यापणं च इत्यत्र \"निर्यापणे गुप्तसम्पर्काः अन्तर्भाव्यन्ताम्\" इति न सक्रियं चेत् सामान्यनिर्यापणे गुप्तसम्पर्काः त्यज्यन्ते।';

  @override
  String get helpImportExportBullet9 =>
      'तस्मिन् एव पटले \"गुप्तसम्पर्काः निर्याप्यन्ताम्\" इति अस्ति, यत् केवलं गुप्तसम्पर्कयुक्तां पृथक् सञ्चिकां रक्षति। प्रथमं अङ्गुलिमुद्रां, मुखं, PIN वा पृच्छति।';

  @override
  String get helpImportExportBullet10 =>
      'सर्वस्य — आह्वानेतिवृत्तं, चित्राणि, विन्यासाः सर्वं — गुप्तशब्दपिहितायै पूर्णप्रतिलिप्यै तस्य स्थाने विन्यासाः → प्रतिलिपिरक्षणं पुनःस्थापनं च प्रयुज्यताम्।';

  @override
  String get helpImportExportTitle5 =>
      'AirQR: एकस्मिन् QR सङ्केते अमान्तस्य प्रेषणम्';

  @override
  String get helpImportExportBullet11 =>
      'एकस्मिन् QR सङ्केते चित्रं दीर्घं सम्पर्कपत्रं वा न माति। AirQR दत्तांशं बहुषु चित्रखण्डेषु विभज्य चलत्-QR सङ्केतरूपेण दर्शयति।';

  @override
  String get helpImportExportBullet12 =>
      'सम्पर्कम् उद्घाट्य \"QR सङ्केतरूपेण विभज्यताम्\" इति चित्वा, तस्मिन् संवादपत्रे Air-Gap Stream गण्डं स्पृष्ट्वा चलनम् आरभ्यताम्।';

  @override
  String get helpImportExportBullet13 =>
      'अपरस्मिन् दूरभाषे सम्पर्काः → सूची → \"QR सङ्केतः परीक्ष्यताम्\" इति उद्घाट्य छायाचित्रयन्त्रं चलनाभिमुखं धार्यताम्। खण्डागमनकाले प्रगतिः दृश्यते, सर्वेषु आगतेषु सम्पर्कः रक्ष्यते।';

  @override
  String get helpImportExportBullet14 =>
      'Bluetooth, Wi-Fi, अन्तर्जालं वा द्वारा किमपि न प्रेष्यते — छायाचित्रयन्त्रस्य पटलदर्शनम् एव मार्गः। समाप्तिपर्यन्तम् उभौ दूरभाषौ स्थिरौ धार्येताम्।';

  @override
  String get helpImportExportFooter =>
      'सूचना: अन्यदूरभाषं गन्तुं vCard (.vcf) सुरक्षिततरा, यतः सा बहूः सङ्ख्याः, ईमेल्-सङ्केतान्, चित्राणि च रक्षति। सूचीं सारणीपत्रे उद्घाटयितुम् इच्छा चेत् CSV उत्तमा।';

  @override
  String get helpPrivacySecurityText => 'गोपनीयता, सुरक्षा, गुप्तकोशः च';

  @override
  String get helpPrivacySecurityIntro =>
      'अविचलितगोपनीयतां, गूढस्थानीयकोशं, सूक्ष्मसुरक्षानियन्त्रणानि च निश्चेतुं मूलतः एव निर्मितम् SreerajP Contacts Sphere।';

  @override
  String get helpPrivacySecurityTitle1 => 'गुप्तसम्पर्ककोशः';

  @override
  String get helpPrivacySecurityBullet1 =>
      'गुप्तसम्पर्कः कः? \"गुप्तम्\" इति चिह्नितः कः अपि सम्पर्कः मुख्यसूचितः, T9 आह्वानपटलान्वेषणात्, सामान्यनिर्यापणसञ्चिकाभ्यः च पूर्णतया गुप्तः भवति।';

  @override
  String get helpPrivacySecurityBullet2 =>
      'तान् द्रष्टुम्: सम्पर्कपटलस्य उपरितनपट्टिकायां तालकचिह्नं स्पृष्ट्वा अङ्गुलिमुद्रया, मुखेन, उपकरणस्य PIN इत्यनेन वा उद्घाट्यताम्। ततः सूची अन्यैः सह गुप्तसम्पर्कान् अपि दर्शयति।';

  @override
  String get helpPrivacySecurityBullet3 =>
      'गोपनाय तालकं पुनः स्पृश्यताम्। सम्पर्कसूचीत्यागे अपि ते गुप्ताः भवन्ति, अतः भवतः गमनानन्तरं कदापि दृश्याः न तिष्ठन्ति।';

  @override
  String get helpPrivacySecurityTitle2 => 'जैवमिति-अनुप्रयोगPIN-संरक्षणम्';

  @override
  String get helpPrivacySecurityBullet4 =>
      'उपकरणस्य जैवमितिसंवेदकैः (अङ्गुलिमुद्रा / मुखम्) सम्पूर्णम् अनुप्रयोगं संवेदनशीलभागान् वा सुरक्षितान् कर्तुं शक्यते।';

  @override
  String get helpPrivacySecurityBullet5 =>
      'दूरभाषे जैवमितियन्त्रं नास्ति चेत्, दूरभाषPIN-तः पृथक् सङ्केतः इष्टः चेत् वा, विन्यासाः → सुरक्षा → अनुप्रयोगतालकम् इत्यत्र अनुप्रयोगस्य PIN स्थाप्यताम्। \"अनुप्रयोगतालकं PIN च\" मार्गदर्शिका दृश्यताम्।';

  @override
  String get helpPrivacySecurityTitle3 => 'पटलचित्ररक्षा';

  @override
  String get helpPrivacySecurityBullet6 =>
      'गोपनीयदत्तांशयुक्ते पटले स्थिते सति पटलचित्ररक्षा पटलचित्राणि, पटलाभिलेखनम्, अद्यतनसूच्याम् Android दर्शितं पूर्वदृश्यं च निरुणद्धि।';

  @override
  String get helpPrivacySecurityBullet7 =>
      'विन्यासाः → सुरक्षा → पटलचित्ररक्षा इत्यत्र सक्रियां निष्क्रियां वा कर्तुं शक्यते।';

  @override
  String get helpPrivacySecurityTitle4 => 'सुरक्षापरिवर्तनलेखः';

  @override
  String get helpPrivacySecurityBullet8 =>
      'सम्पर्कस्य प्रत्येकं परिवर्तनं — सृष्टं, सम्पादितं, लुप्तं वा — पूर्वं पश्चात् च कीदृशम् आसीत् इत्यनेन सह परिवर्तनलेखः अभिलिखति।';

  @override
  String get helpPrivacySecurityBullet9 =>
      'किं परिवर्तितम् इति यथावत् द्रष्टुं प्रविष्टिः उद्घाट्यतां, परिवर्तनं प्रमादः चेत् प्रत्यावर्त्यताम्।';

  @override
  String get helpPrivacySecurityBullet10 =>
      'प्रविष्टयः गूढहैशेन शृङ्खलिताः, अतः काचित् प्रविष्टिः अज्ञाततया परिवर्तयितुम् अपनेतुं वा न शक्यते।';

  @override
  String get helpPrivacySecurityBullet11 =>
      'विन्यासाः → सुरक्षा → परिवर्तनलेखः; प्रथमम् उद्घाटनं पृच्छति। लेखस्य हस्ताक्षरितप्रतिलिपिं निर्यापयितुम् अपि शक्नोति।';

  @override
  String get helpPrivacySecurityFooter =>
      'सुरक्षातत्त्वम्: सर्वम् अस्मिन् दूरभाषे, दूरभाषस्य यन्त्रकुञ्जिकाकोशे स्थितया कुञ्जिकया गूढे दत्तांशकोशे रक्ष्यते। अनुसरणं नास्ति, विज्ञापनं नास्ति, अस्माकं कोऽपि सेवकः नास्ति।';

  @override
  String get helpContactSharingText => 'विभजनं पत्रपरीक्षणं च';

  @override
  String get helpContactSharingIntro =>
      'आधुनिकैः QR सङ्केतैः, उपकरणस्थेन व्यापारपत्र-OCR-परीक्षणेन, जालरहितेन Bluetooth LE इत्यनेन च सम्पर्कसूचनाः शीघ्रं विनिमीयन्ताम्।';

  @override
  String get helpContactSharingTitle1 => 'QR सङ्केतविभजनं परीक्षकः च';

  @override
  String get helpContactSharingBullet1 =>
      'QR सङ्केतं दर्शयितुम्: सम्पर्कम् उद्घाट्य \"विभज्यताम्\" स्पृष्ट्वा \"QR सङ्केतरूपेण विभज्यताम्\" इति चीयताम्। अन्यः परीक्षेत इति सामान्यः vCard QR पटले दृश्यते।';

  @override
  String get helpContactSharingBullet2 =>
      'QR सङ्केतं परीक्षितुम्: सम्पर्कपटलम् उद्घाट्य त्रिबिन्दुसूचीं स्पृष्ट्वा \"QR सङ्केतः परीक्ष्यताम्\" इति चित्वा छायाचित्रयन्त्रम् उद्घाट्यताम्।';

  @override
  String get helpContactSharingBullet3 =>
      'परीक्षितं प्रथमं भवते दर्श्यते। अवलोकनानन्तरम् एव नूतनसम्पर्करूपेण रक्ष्यते।';

  @override
  String get helpContactSharingTitle2 => 'व्यापारपत्रपरीक्षकः (उपकरणस्थः AI)';

  @override
  String get helpContactSharingBullet4 =>
      'दूरभाषस्य छायाचित्रयन्त्रेण कस्य अपि कागदव्यापारपत्रस्य चित्रं गृह्यताम्।';

  @override
  String get helpContactSharingBullet5 =>
      'ContactSphere इत्यस्य अक्षरपरिचयः (OCR) चित्रं क्षणेषु पठित्वा नामानि, दूरभाषसङ्ख्याः, ईमेल्-सङ्केतान्, सङ्केतान्, संस्थापदानि च निष्कासयति।';

  @override
  String get helpContactSharingBullet6 =>
      'सम्पर्कपुस्तके रक्षणात् पूर्वं किमपि क्षेत्रं परीक्षितुं, सम्पादयितुं, त्यक्तुं वा शक्यते।';

  @override
  String get helpContactSharingBullet7 =>
      '100% उपकरणस्था गोपनीयता: पत्रचित्रं भवतः दूरभाषे एव संसाध्यते, कस्मिन् अपि मेघसेवके कदापि न आरोप्यते।';

  @override
  String get helpContactSharingTitle3 => 'जालरहितं Bluetooth LE विभजनम्';

  @override
  String get helpContactSharingBullet8 =>
      'अन्तर्जालं युग्मनसङ्केतं वा विना ContactSphere युक्तैः समीपस्थैः Android उपकरणैः सह साक्षात् सम्पर्काः विभज्यन्ताम्।';

  @override
  String get helpContactSharingBullet9 =>
      'प्रेषकः सम्पर्कम् उद्घाट्य \"विभज्यताम्\" स्पृष्ट्वा \"Bluetooth द्वारा विभज्यताम्\" इति चिनोति। ग्राहकः सम्पर्कपटलम् उद्घाट्य त्रिबिन्दुसूचीं स्पृष्ट्वा \"Bluetooth प्रेषणम्\" इति चिनोति।';

  @override
  String get helpContactSharingBullet10 =>
      'ग्राहकदूरभाषः भवता निश्चेतव्यं परीक्षणं दर्शयति, अतः भवतः सम्मतिं विना सम्पर्कः दूरभाषे बलात् न प्रवेशयितुं शक्यते।';

  @override
  String get helpContactSharingBullet11 =>
      'उपकरणानि परस्परं स्वयम् अन्विष्य अल्पशक्तितरङ्गैः सम्पर्कं सुरक्षितं प्रेषयन्ति।';

  @override
  String get helpContactSharingFooter =>
      'सूचना: अत्रत्याः सर्वाः विभजनरीतयः सामान्यं vCard रूपं प्रयुञ्जते, यत् Android, iOS, सङ्गणकसम्पर्कपुस्तकानि च सर्वाणि अवगच्छन्ति। सम्पूर्णं सम्पर्कपुस्तकं सञ्चिकारूपेण प्रेषयितुम् आनयन-निर्यापणमार्गदर्शिका दृश्यताम्।';

  @override
  String get helpDuplicateMergeText => 'द्विरुक्तसम्पर्काः एकीकरणं च';

  @override
  String get helpDuplicateMergeIntro =>
      'ContactSphere इत्यस्य बुद्धिमता द्विरुक्तपरिचयेन सुरक्षितेन एकस्पर्शैकीकरणेन च सम्पर्कपुस्तकं स्वच्छं रक्ष्यताम्।';

  @override
  String get helpDuplicateMergeTitle1 => 'द्विरुक्तानि कथं ज्ञायन्ते';

  @override
  String get helpDuplicateMergeBullet1 =>
      'समाना दूरभाषसङ्ख्या: द्वयोः सम्पर्कयोः समानाः अङ्काः, पूर्णान्ताराष्ट्रियरूपे समाना सङ्ख्या वा।';

  @override
  String get helpDuplicateMergeBullet2 =>
      'समानं नाम: द्वयोः सम्पर्कयोः समानं पूर्णनाम, लिप्यन्तरणे समानं नाम वा — अतः \"Anil\" \"അനിൽ\" च एकः जनः इति दृश्यते।';

  @override
  String get helpDuplicateMergeBullet3 =>
      'मेलनं समुच्चये प्रसरति: A B इत्यनेन, B C इत्यनेन च मिलति चेत्, त्रयः एकसमुच्चयरूपेण सह दर्श्यन्ते।';

  @override
  String get helpDuplicateMergeBullet4 =>
      'ईमेल्-सङ्केताः बुद्धिपूर्वकं न प्रयुज्यन्ते, समध्वनिनामसङ्केताः अपि न। उभे असम्बद्धजनानाम् अशुद्धम् एकीकरणम् अकुरुताम्।';

  @override
  String get helpDuplicateMergeTitle2 => 'बुद्धिमदेकीकरणप्रक्रिया';

  @override
  String get helpDuplicateMergeBullet5 =>
      'सम्पर्कपटलम् उद्घाट्य त्रिबिन्दुसूचीं स्पृष्ट्वा \"द्विरुक्तानि अन्विष्यन्ताम्\" इति चीयताम्।';

  @override
  String get helpDuplicateMergeBullet6 =>
      'प्रत्येकः समुच्चयः एकपत्ररूपेण दृश्यते। रक्ष्यमाणः सम्पर्कः उपरि; अन्ये तस्मिन् एकीकरणाय चिह्निताः।';

  @override
  String get helpDuplicateMergeBullet7 =>
      'समुच्चये अनर्हाणां चिह्नम् अपनीयताम्, अन्यं रक्षितुं तां पङ्क्तिं वा स्पृश्यताम्।';

  @override
  String get helpDuplicateMergeBullet8 =>
      'समुच्चयस्थाः सर्वाः भिन्नदूरभाषसङ्ख्याः, ईमेल्-सङ्केताः, सङ्केताः, जन्मदिनानि, टिप्पण्यः च रक्ष्यमाणसम्पर्कं प्रति नीयन्ते। किमपि न त्यज्यते।';

  @override
  String get helpDuplicateMergeBullet9 =>
      'एकः समुच्चयः स्वकीयेन \"एकीक्रियताम्\" गण्डेन एकीक्रियताम्, सम्पूर्णसूचीं युगपत् कर्तुम् अधः \"सर्वे समुच्चयाः एकीक्रियन्ताम्\" इति वा प्रयुज्यताम्।';

  @override
  String get helpDuplicateMergeTitle3 => 'सुरक्षा प्रत्यावर्तनं च';

  @override
  String get helpDuplicateMergeBullet10 =>
      'सर्वस्य युगपत् एकीकरणात् पूर्वं विन्यासाः → प्रतिलिपिरक्षणं पुनःस्थापनं च इत्यत्र प्रतिलिपिः क्रियताम्। द्विरुक्तपटलात् एकीकरणं प्रत्यावर्तयितुं न शक्यते।';

  @override
  String get helpDuplicateMergeBullet11 =>
      'एकीकरणम् अशुद्धं चेत्, रक्षितसम्पर्कम् उद्घाट्य सम्पाद्यताम् — अधिकसङ्ख्याः विवरणानि च सर्वाणि तत्र एव सन्ति, तानि नूतनसम्पर्कं प्रति पुनः नेतुं शक्यन्ते।';

  @override
  String get helpDuplicateMergeFooter =>
      'सूचना: सम्पर्कपुस्तकसमन्वयात् सञ्चिकानयनात् वा परं \"द्विरुक्तानि अन्विष्यन्ताम्\" प्रवर्त्यताम् — प्रायः तदा एव द्विरुक्तानि दृश्यन्ते।';

  @override
  String get helpContactSyncText => 'सम्पर्कसमन्वयः';

  @override
  String get helpContactSyncIntro =>
      'समन्वयः अनुप्रयोगं दूरभाषं च समानौ रक्षति। प्रत्येकां दिशं भवान् एव नियन्त्रयति — अत्र किमपि स्वयं न प्रवर्तते। विन्यासाः → सम्पर्काः → उपकरण-मेघसमन्वयः इत्यतः उद्घाट्यताम्।';

  @override
  String get helpContactSyncTitle1 => 'द्वे सामान्यकार्ये';

  @override
  String get helpContactSyncBullet1 =>
      'उपकरणसम्पर्काः अनुप्रयोगे योज्यन्ताम्: दूरभाषस्य सम्पर्कपुस्तकम् अनुप्रयोगे प्रतिलिखति। केवलं योजयति नवीकरोति वा — कदापि न लोपयति।';

  @override
  String get helpContactSyncBullet2 =>
      'अनुप्रयोगसम्पर्काः उपकरणे योज्यन्ताम्: अनुप्रयोगसम्पर्कान् दूरभाषे प्रतिलिखति। केवलं योजयति नवीकरोति वा — कदापि न लोपयति। भवतः \"अहम्\" सम्पर्कः गुप्तसम्पर्काः च दूरभाषं प्रति कदापि न प्रेष्यन्ते।';

  @override
  String get helpContactSyncTitle2 => 'लोपसहितः समन्वयः';

  @override
  String get helpContactSyncBullet3 =>
      'द्वे \"(लोपसहितम्)\" कार्ये लक्ष्यं स्रोतसः यथावत् प्रतिरूपं कुरुतः। योजनेन नवीकरणेन च सह अधिकानि लोपयतः — अतः सावधानं प्रयुज्येताम्। प्रत्येकं प्रथमं निश्चयं पृच्छति।';

  @override
  String get helpContactSyncBullet4 =>
      'उपकरणसम्पर्काः अनुप्रयोगं प्रति (लोपसहितम्): आनयनानन्तरं, दूरभाषात् आगताः किन्तु इदानीं तत्र अविद्यमानाः अनुप्रयोगसम्पर्काः लुप्यन्ते। भवतः \"अहम्\" सम्पर्कः, गुप्तसम्पर्काः, केवलम् अनुप्रयोगे रचिताः सम्पर्काः च कदापि न लुप्यन्ते।';

  @override
  String get helpContactSyncBullet5 =>
      'अनुप्रयोगसम्पर्काः उपकरणं प्रति (लोपसहितम्): प्रतिलेखनानन्तरं, अनुप्रयोगे अविद्यमानाः उपकरणसम्पर्काः लुप्यन्ते। भवतः \"अहम्\" सम्पर्केण गुप्तसम्पर्केण वा मिलन्तः उपकरणसम्पर्काः कदापि न लुप्यन्ते, यद्यपि ते दूरभाषं प्रति कदापि न प्रतिलिख्यन्ते।';

  @override
  String get helpContactSyncTitle3 => 'आह्वानलेखः';

  @override
  String get helpContactSyncBullet6 =>
      'दूरभाषस्य आह्वानलेखः स्वयम् अद्यतनलेखे समन्वेति — अनुप्रयोगारम्भे, अद्यतनोद्घाटने, आह्वानसमाप्तौ च। अन्याह्वानानुप्रयोगात् अनुप्रयोगे पिहिते वा कृतानि आह्वानानि एवम् आगच्छन्ति। भवता किमपि न कर्तव्यम्।';

  @override
  String get helpContactSyncBullet7 =>
      'उपकरणाह्वानलेखः अनुप्रयोगे योज्यताम्: स्वयंसमन्वयात् पुरातनतरम् आह्वानेतिवृत्तम् एकपदे आनयति। अनुप्रयोगे विद्यमानानि आह्वानानि त्यजति, अतः पुनः प्रवर्तनं सुरक्षितम्।';

  @override
  String get helpContactSyncBullet8 =>
      'उपकरणाह्वानलेखः अनुप्रयोगं प्रति (लोपसहितम्): अद्यतनलेखं रिक्तीकृत्य दूरभाषस्य आह्वानलेखात् पुनः निर्माति। अनुप्रयोगे रक्षिताः आह्वानटिप्पण्यः प्रतिक्रियाः च नश्यन्ति।';

  @override
  String get helpContactSyncBullet9 =>
      'आह्वानलेखाय \"अनुप्रयोगात् उपकरणं प्रति\" नास्ति: दूरभाषस्य आह्वानलेखः Android इत्यस्य, सः स्वयम् आह्वानानि अभिलिखति।';

  @override
  String get helpContactSyncFooter =>
      'सूचना: लोपसहितः समन्वयः प्रत्यावर्तयितुं न शक्यते। संशये सति प्रथमं प्रतिलिपिः क्रियताम् (विन्यासाः → प्रतिलिपिरक्षणं पुनःस्थापनं च)।';

  @override
  String get helpCallScreeningText => 'आह्वानपरीक्षणं निरोधः च';

  @override
  String get helpCallScreeningIntro =>
      'दूरभाषनादात् पूर्वम् अनुप्रयोगः आह्वानं प्रत्यावर्तयितुं शक्नोति। निरोधः भवता स्वयं रचिता सूची, आगतसङ्ख्यया सह अस्मिन् एव दूरभाषे मेल्यते — अन्यत्र किमपि न अन्विष्यते।';

  @override
  String get helpCallScreeningTitle1 => 'आह्वानपरीक्षणं कथं कार्यं करोति';

  @override
  String get helpCallScreeningBullet1 =>
      'आह्वानागमने दूरभाषनादात् पूर्वम् Android सङ्ख्याम् अनुप्रयोगस्य आह्वानपरीक्षणसेवायै ददाति।';

  @override
  String get helpCallScreeningBullet2 =>
      'सङ्ख्या भवतः अवरुद्धसूच्याम् अस्ति चेत् आह्वानं सद्यः निराक्रियते — नादः नास्ति, कम्पनं नास्ति, आगमनपटलं नास्ति।';

  @override
  String get helpCallScreeningBullet3 =>
      'मूलदेशं प्रयुज्य पूर्णान्ताराष्ट्रियरूपं नीत्वा सङ्ख्याः मेल्यन्ते, अतः 98765 43210 इति अवरुद्धा सङ्ख्या +91 98765 43210 इत्यपि निरुणद्धि।';

  @override
  String get helpCallScreeningBullet4 =>
      'अवरुद्धम् आह्वानम् अपि \"अवरुद्धम्\" इति चिह्नेन अद्यतनलेखे लिख्यते, येन कः प्रयतितवान् इति दृश्यते।';

  @override
  String get helpCallScreeningTitle2 => 'सङ्ख्यानिरोधः';

  @override
  String get helpCallScreeningBullet5 =>
      'अद्यतनलेखात्: आह्वानं दीर्घं स्पृष्ट्वा \"सङ्ख्या निरुध्यताम्\" इति चीयताम्। ततः तत्र \"निरोधः अपनीयताम्\" इति दृश्यते।';

  @override
  String get helpCallScreeningBullet6 =>
      'आह्वानकाले: आह्वानपटले \"निरुध्यताम्\" इति स्पृश्यताम्। नादकाले संवादकाले च एतत् कार्यं करोति।';

  @override
  String get helpCallScreeningBullet7 =>
      'हस्तेन: विन्यासाः → सम्पर्काः → अवरुद्धसङ्ख्याः, ततः सङ्ख्या स्वयं योज्यताम्।';

  @override
  String get helpCallScreeningBullet8 =>
      'इदानीम् आह्वाने स्थितां सङ्ख्यां निरुध्य, कुतः अपि निरुद्धा चेत्, तत् आह्वानं सद्यः समाप्यते।';

  @override
  String get helpCallScreeningTitle3 => 'सङ्ख्याहीनाः आह्वातारः';

  @override
  String get helpCallScreeningBullet9 =>
      'गुप्तया निगृहीतया वा सङ्ख्यया आगताह्वानेभ्यः विन्यासाः → सम्पर्काः → अवरुद्धसङ्ख्याः इत्यत्र \"अज्ञाताः निरुध्यन्ताम्\" इति परिवर्तकः अपि अस्ति।';

  @override
  String get helpCallScreeningBullet10 =>
      'तानि आह्वानानि नादात् पूर्वं निराक्रियन्ते, तथापि अवरुद्धत्वेन अद्यतनलेखे अभिलिख्यन्ते।';

  @override
  String get helpCallScreeningBullet11 =>
      'भवता अरक्षिताः सामान्यसङ्ख्याः एतत् न प्रभावयति — सङ्ख्यारहितानि आह्वानानि एव।';

  @override
  String get helpCallScreeningTitle4 => 'निरोधस्य स्थाने निःशब्दीकरणम्';

  @override
  String get helpCallScreeningBullet12 =>
      'आह्वानं द्रष्टुम् इच्छा, किन्तु विघ्नः न इष्टः चेत्, विन्यासाः → SIM आह्वानं च → परिचयः इत्यत्र \"शङ्कितानिष्टाः परिशोध्यन्ताम्\" इति प्रयुज्यताम्। ततः चिह्निताः आह्वातारः निःशब्दं नदन्ति।';

  @override
  String get helpCallScreeningBullet13 =>
      'आह्वाता कथं चिह्न्यते इति ज्ञातुं \"आह्वातृपरिचयः अनिष्टपरिशोधकः च\" मार्गदर्शिका दृश्यताम्।';

  @override
  String get helpCallScreeningTitle5 => 'मूलदूरभाषानुप्रयोगः आवश्यकः';

  @override
  String get helpCallScreeningBullet14 =>
      'नादात् पूर्वम् आह्वानपरीक्षणं Android केवलं मूलदूरभाषानुप्रयोगाय अनुमन्यते। तां भूमिकां विना निरोधः पर्याप्तं शीघ्रं न भवितुम् अर्हति।';

  @override
  String get helpCallScreeningBullet15 =>
      'अनुप्रयोगस्य सा भूमिका अस्ति वा इति विन्यासाः → अनुमतयः दर्शयति, तां प्रार्थयितुम् अपि अनुमन्यते।';

  @override
  String get helpCallScreeningFooter =>
      'गोपनीयताटिप्पणी: परीक्षणं पूर्णतया अस्मिन् दूरभाषे, भवतः स्वकीयसूच्या सह भवति। का अपि दूरभाषसङ्ख्या सेवकं प्रति कदापि न प्रेष्यते, पृष्ठतः सामूहिकः अनिष्टदत्तांशकोशः नास्ति।';

  @override
  String get helpPermissionsTitle1 => 'अनुमतीनां व्याख्या';

  @override
  String get helpPermissionsIntro =>
      'विन्यासाः → अनुमतयः इत्यत्र अनुप्रयोगेन प्राप्यं सर्वं प्रत्येकस्य सजीवस्थित्या सह दृश्यते। प्रत्येकं किमर्थं, निषेधे किं न कार्यं करोति इति च इदं पृष्ठं व्याचष्टे।';

  @override
  String get helpPermissionsTitle2 => 'द्विविधाः अनुमतयः';

  @override
  String get helpPermissionsBullet1 =>
      'स्पष्टाः — Android भवन्तं पृच्छति, निषेद्धुं पश्चात् मतिं परिवर्तयितुं च शक्यते। \"अनुमतम् / निषिद्धम्\" इति पार्श्वे दृश्यमानाः एताः एव।';

  @override
  String get helpPermissionsBullet2 =>
      'स्वतः — अनुप्रयोगनिर्माणकाले घोषिताः स्थापनकाले प्रणाल्या अनुमताः च। प्रश्नः नास्ति, यतः ताः स्वयं भवतः वैयक्तिकदत्तांशं प्राप्तुं न शक्नुवन्ति।';

  @override
  String get helpPermissionsTitle3 => 'आह्वानाय';

  @override
  String get helpPermissionsBullet3 =>
      'मूलदूरभाषानुप्रयोगः — एतं प्रणाल्याः आह्वानानुप्रयोगं करोति, येन स्वकीयम् आह्वानपटलं, पूर्णपटलागमनसूचनाः, नादात् पूर्वम् आह्वानपरीक्षणं च शक्यम्। तां विना आह्वानं शक्यं, किन्तु निरोधः परीक्षणं च न कार्यं कुरुतः।';

  @override
  String get helpPermissionsBullet4 =>
      'दूरभाषः आह्वानलेखः च — आह्वानानि कर्तुं स्वीकर्तुं नियन्त्रयितुं च, अद्यतनलेखाय आह्वानस्य वास्तविकावधिं पठितुं च।';

  @override
  String get helpPermissionsBullet5 =>
      'आह्वानसेवा घण्टानादः च — आह्वानं जीवितं रक्षति, अनुप्रयोगं नादयितुम् आगमनपटलं दर्शयितुं च अनुमन्यते।';

  @override
  String get helpPermissionsBullet6 =>
      'कर्णसमीपे पटलनिरोधः — दूरभाषे कर्णसंलग्ने कपोलः गण्डान् न पीडयेत् इति पटलं निरुणद्धि।';

  @override
  String get helpPermissionsTitle4 => 'सम्पर्केभ्यः';

  @override
  String get helpPermissionsBullet7 =>
      'सम्पर्काः — दूरभाषस्य सम्पर्कपुस्तकस्य पठनाय समन्वयाय च। तां विना अनुप्रयोगः स्वकीयसम्पर्कान् रक्षति, किन्तु दूरभाषस्थान् द्रष्टुं नवीकर्तुं वा न शक्नोति।';

  @override
  String get helpPermissionsBullet8 =>
      'चित्राणि माध्यमानि च — चित्रसञ्चयात् चित्रचयनाय।';

  @override
  String get helpPermissionsBullet9 =>
      'छायाचित्रयन्त्रम् — सम्पर्कचित्रग्रहणाय, QR सङ्केतस्य कागदव्यापारपत्रस्य वा परीक्षणाय।';

  @override
  String get helpPermissionsBullet10 =>
      'ध्वनिग्राहकम् — आह्वानटिप्पणीं लेखनस्य स्थाने वक्तुम्।';

  @override
  String get helpPermissionsBullet11 =>
      'स्थानम् — सम्पर्के स्थानचिह्नाय; पुरातनेषु Android संस्करणेषु Bluetooth अन्वेषणाय अपि आवश्यकम्।';

  @override
  String get helpPermissionsTitle5 => 'स्मारकेभ्यः आपत्कालपत्राय च';

  @override
  String get helpPermissionsBullet12 =>
      'सूचनाः — जन्मदिनानाम्, अनुवर्तनानाम्, अप्राप्ताह्वानानां च स्मारकाणि दर्शयितुं, आपत्कालसूचनापत्रं तालपटले धारयितुं च।';

  @override
  String get helpPermissionsBullet13 =>
      'अलार्म्-स्मारकाणि — अनुप्रयोगे पिहिते अपि भवता निश्चिते काले Smart Redial पुनः आह्वयेत् इति।';

  @override
  String get helpPermissionsBullet14 =>
      'पुनरारम्भानन्तरं प्रारम्भः — दूरभाषस्य पुनरारम्भानन्तरम् आपत्कालसूचनापत्रं तालपटले पुनः स्थापयति।';

  @override
  String get helpPermissionsTitle6 => 'विभजनाय समन्वयाय च';

  @override
  String get helpPermissionsBullet15 =>
      'Bluetooth अन्वेषणं, संयोगः, प्रकाशनं च — Bluetooth द्वारा सम्पर्कविभजनकाले समीपस्थं दूरभाषम् अन्वेष्टुं, संयोजयितुं, अन्वेषणीयः भवितुं च।';

  @override
  String get helpPermissionsBullet16 =>
      'अन्तर्जालं Wi-Fi च — उपकरणसमन्वयकाले भवतः स्वकीय-स्थानीय-Wi-Fi द्वारा अन्यदूरभाषं प्रति दत्तांशप्रतिलेखनाय एव। जालसमन्वयं मेघप्रतिलिपिं वा भवान् स्वयं न स्थापयति चेत् कोऽपि मेघसेवकः न सम्पृच्यते।';

  @override
  String get helpPermissionsBullet17 =>
      'जैवमितिः — गुप्तसम्पर्काणाम् उद्घाटनाय, तद्युक्तस्य दत्तांशस्य निर्यापणात् समन्वयात् वा पूर्वं प्रमाणीकरणाय च।';

  @override
  String get helpPermissionsTitle7 => 'निषेधः मतिपरिवर्तनं च';

  @override
  String get helpPermissionsBullet18 =>
      'प्रत्येका अनुमतिः तदपेक्षिविशेषतायाः प्रथमप्रयोगे एव पृच्छ्यते। स्थापनकाले किमपि न प्रार्थ्यते।';

  @override
  String get helpPermissionsBullet19 =>
      'एकस्याः निषेधे सा विशेषता एव निष्क्रिया भवति। अनुप्रयोगस्य शेषं कार्यं करोति एव।';

  @override
  String get helpPermissionsBullet20 =>
      'द्विवारं निषिद्धा अनुमतिः \"अवरुद्धम्\" इति दृश्यते। Android पुनः न पृच्छति — हस्तेन परिवर्तयितुम् अनुमतिपटलस्य उपरितनपट्टिकायां विन्यासगण्डः प्रयुज्यताम्।';

  @override
  String get helpPermissionsFooter =>
      'अनुप्रयोगे विज्ञापन-विश्लेषणसङ्केतः नास्ति, अस्माकं कोऽपि सेवकः न सम्पृच्यते। दूरभाषं त्यजत् किमपि भवता समन्वयस्य, विभजनस्य, मेघप्रतिलिपेः वा स्थापनात् एव त्यजति।';

  @override
  String get helpEmergencyInfoText => 'आपत्कालसूचनाः';

  @override
  String get helpEmergencyInfoIntro =>
      'भवन्तम् अस्वस्थं पश्यतः साहाय्यं कुर्युः इति कानिचित् तथ्यानि आपत्कालपत्रे सन्ति — रक्तवर्गः, प्रत्यूर्जाः, कः आह्वातव्यः च। PIN विना तालपटले एतत् पठितुं शक्यते।';

  @override
  String get helpEmergencyInfoTitle1 => '\"अनुद्घाट्य\" इत्यस्य अर्थः';

  @override
  String get helpEmergencyInfoBullet1 =>
      'पत्रे सक्रिये \"आपत्कालसूचनाः\" इति सूचना तालपटले तिष्ठति। तां स्पृष्ट्वा पत्रं सद्यः उद्घाट्यते — PIN, अङ्गुलिमुद्रा, मुखं वा न आवश्यकम्।';

  @override
  String get helpEmergencyInfoBullet2 =>
      'दूरभाषः पिहितः एव तिष्ठति। केवलं पत्रम् उद्घाट्यते; अनुप्रयोगस्य शेषं, दूरभाषस्थम् अन्यत् सर्वं च पिहितम् एव।';

  @override
  String get helpEmergencyInfoBullet3 =>
      'तालपटलस्य आपत्कालगण्डस्य पृष्ठतः Android इत्यस्य स्वकीयं \"आपत्कालसूचनाः\" पृष्ठम् अस्ति। तत् दूरभाषनिर्मातुः, कोऽपि अनुप्रयोगः तत्र लेखितुं न शक्नोति — अतः एव SreerajP Contacts Sphere स्वकीयां सूचनां प्रयुङ्क्ते।';

  @override
  String get helpEmergencyInfoTitle2 => 'प्रत्येकां पङ्क्तिं भवान् चिनोति';

  @override
  String get helpEmergencyInfoBullet4 =>
      'भवता सक्रियीकरणपर्यन्तं सम्पूर्णा विशेषता निष्क्रिया।';

  @override
  String get helpEmergencyInfoBullet5 =>
      'प्रत्येकस्य क्षेत्रस्य स्वकीयः \"तालपटले दर्श्यताम्\" इति परिवर्तकः अस्ति। निष्क्रियं त्यक्तं क्षेत्रम् अनुप्रयोगं कदापि न त्यजति।';

  @override
  String get helpEmergencyInfoBullet6 =>
      'सम्पादनपटलस्य अधः पूर्वदृश्यम् अपरिचितः यत् पश्येत् तत् यथावत् दर्शयति।';

  @override
  String get helpEmergencyInfoBullet7 =>
      'पत्रनिष्क्रियीकरणेन सूचना अपगच्छति, तालपटलेन पठ्यमाना प्रतिलिपिः च मार्ज्यते। भवता लिखितम् अनुप्रयोगे रक्षितं तिष्ठति।';

  @override
  String get helpEmergencyInfoTitle3 => 'साहाय्याय आह्वानम्';

  @override
  String get helpEmergencyInfoBullet8 =>
      'भवता योजितः प्रत्येकः जनः पत्रे \"आह्वयतु\" गण्डं लभते। तं स्पृष्ट्वा तालपटलात् सद्यः सः आहूयते।';

  @override
  String get helpEmergencyInfoBullet9 =>
      'सम्पर्केभ्यः चिताः जनाः एकेन नाम्ना एकया सङ्ख्यया च पत्रे प्रतिलिख्यन्ते। तस्य सम्पर्कस्य पश्चात् सम्पादनेन पत्रं न परिवर्तते — इदं पटलम् उद्घाट्य पुनः रक्ष्यताम्।';

  @override
  String get helpEmergencyInfoTitle4 => 'तालपटले पत्रं न दृश्यते चेत्';

  @override
  String get helpEmergencyInfoBullet10 =>
      'तालपटलं काः सूचनाः दर्शयेत् इति भवतः दूरभाषः निश्चिनोति। विन्यासाः → सूचनाः → तालपटले सूचनाः इति उद्घाट्य \"संवादाः, मूलाः, निःशब्दाः च दर्श्यन्ताम्\" इति चीयताम्।';

  @override
  String get helpEmergencyInfoBullet11 =>
      'तत् \"निःशब्दसूचनाः गोप्यन्ताम्\" \"काः अपि सूचनाः मा दर्श्यन्ताम्\" वा इति स्थापितं चेत् पत्रं तत्र न दृश्यते। कोऽपि अनुप्रयोगः तत् चयनम् अतिक्रमितुं न शक्नोति।';

  @override
  String get helpEmergencyInfoBullet12 =>
      'SreerajP Contacts Sphere इत्यस्य सूचनाः सक्रियाः, \"आपत्कालसूचनाः\" इति सूचना निःशब्दीकृता नास्ति इति च परीक्ष्यताम्। अनयोः एकं सत्यं चेत् सम्पादनपटलं पूर्वसूचयति, तत्रत्यः गण्डः च उचितं विन्यासपृष्ठम् उद्घाटयति।';

  @override
  String get helpEmergencyInfoBullet13 =>
      'पत्रं बुद्धिपूर्वकं सर्वदा सूचनाफलके तिष्ठति — एकस्पर्शदूरे भवेत् इति, प्रमादेन अपसारयितुं न शक्यते।';

  @override
  String get helpEmergencyInfoTitle5 => 'कथं रक्ष्यते';

  @override
  String get helpEmergencyInfoBullet14 =>
      'भवतः पूर्णाभिलेखः अन्यसम्पर्कवत् अनुप्रयोगस्य गूढदत्तांशकोशे एव तिष्ठति।';

  @override
  String get helpEmergencyInfoBullet15 =>
      'भवता सक्रियीकृताः पङ्क्तयः एव, दूरभाषे पिहिते तालपटलपत्रेण पठनीयायां लघ्व्यां सामान्यसञ्चिकायां प्रतिलिख्यन्ते। सा प्रतिलिपिः गूढीकर्तुं न शक्यते — पिहितदूरभाषस्य अपरिचिताय ताम् उद्घाटयितुं मार्गः नास्ति।';

  @override
  String get helpEmergencyInfoBullet16 =>
      'सा प्रतिलिपिः अनुप्रयोगस्य गोपनीयकोशे एव। अन्ये अनुप्रयोगाः तां पठितुं न शक्नुवन्ति, दूरभाषप्रतिलिपिषु सा न अन्तर्भवति।';

  @override
  String get helpEmergencyInfoBullet17 =>
      'पत्रं गुप्तशब्दरक्षितायां SreerajP Contacts Sphere प्रतिलिप्यां रक्ष्यते, अतः नूतनदूरभाषे पुनःस्थापनेन पुनः आगच्छति।';

  @override
  String get helpEmergencyInfoBullet18 =>
      'अन्यदूरभाषं प्रति पूर्णसमन्वये, विभजनीयचयनकाले \"आपत्कालसूचनापत्रम्\" चिह्निते च एतत् गच्छति। अपरदूरभाषस्य स्वकीयं पत्रं नास्ति चेत् एव सः तत् स्वीकरोति — भवतः पत्रम् अन्यस्य पत्रं कदापि न प्रतिस्थापयति।';

  @override
  String get helpEmergencyInfoFooter =>
      'सूचना: संक्षिप्तं स्थाप्यताम्। रक्तवर्गः, गम्भीराः प्रत्यूर्जाः, आह्वातव्याः एकः द्वौ वा जनौ — दीर्घात् आरोग्येतिवृत्तात् सहायकाय एते बहुमूल्याः।';

  @override
  String get descCatImmediateFamily => 'यैः सह भवान् वसति, यैः सह वृद्धः वा।';

  @override
  String get descCatExtendedFamily => 'निकटकुटुम्बात् बहिः रक्तसम्बन्धिनः।';

  @override
  String get descCatFamilyByMarriage => 'विवाहसम्बन्धिनः सापत्न्यसम्बन्धिनः च।';

  @override
  String get descCatProfessional => 'यैः सह भवान् कार्यं व्यापारं वा करोति।';

  @override
  String get descCatEducational =>
      'विद्यालयात्, महाविद्यालयात्, प्रशिक्षणात् वा परिचिताः।';

  @override
  String get descCatSocial => 'मित्राणि, प्रतिवेशिनः, अन्ये सम्बन्धाः च।';

  @override
  String get descCatService => 'येषां सेवाः भवान् प्रयुङ्क्ते।';

  @override
  String helpRelationshipCategoriesExample(
    String description,
    String examples,
  ) {
    return '$description उदा. $examples।';
  }

  @override
  String get helpCallManagementText => 'आह्वानम् आह्वानमध्यनियन्त्रणानि च';

  @override
  String get helpCallManagementIntro =>
      'बहुपक्षनियन्त्रणैः, द्वि-SIM व्यवस्थया, स्वयंपुनराह्वानसाहाय्येन, आह्वातृनामोच्चारणेन च SreerajP Contacts Sphere बुद्धिमत् आह्वानानुभवं ददाति।';

  @override
  String get helpCallManagementTitle1 =>
      'आह्वानमध्यनियन्त्रणानि सम्मेलनाह्वानं च';

  @override
  String get helpCallManagementBullet1 =>
      'निःशब्दं ध्वनिवर्धकं च: ध्वनिग्राहकं निःशब्दीकर्तुं \"निःशब्दम्\" स्पृश्यतां, हस्तरहितोच्चध्वनये \"ध्वनिवर्धकम्\" स्पृश्यताम्।';

  @override
  String get helpCallManagementBullet2 =>
      'स्थगनम् अङ्कपटलः च: सक्रियाह्वानानि स्थग्यन्ताम्, IVR सूच्यङ्कान् दातुम् अङ्कपटलः वा उद्घाट्यताम् (आङ्ग्लाय 1 इति यथा)।';

  @override
  String get helpCallManagementBullet3 =>
      'आह्वानयोजनम् आह्वानपरिवर्तनं च: प्रथमाह्वानं स्थगयित्वा द्वितीयः सहभागी योज्यताम्। सक्रियाह्वातॄणां मध्ये परिवर्तनाय \"परिवर्त्यताम्\" स्पृश्यताम्।';

  @override
  String get helpCallManagementBullet4 =>
      'सम्मेलनैकीकरणम्: उभे आह्वाने एकस्मिन् सम्मेलनाह्वाने संयोजयितुं \"एकीक्रियताम्\" स्पृश्यताम्। जालं सम्मेलनाह्वानं समर्थयति चेत् एव तत् दृश्यते। आह्वाने के सन्ति इति द्रष्टुम्, एकं जनम् अपनेतुम्, एकेन सह एकान्ते वक्तुं वा \"प्रबन्धः\" स्पृश्यताम्।';

  @override
  String get helpCallManagementTitle2 => 'त्वरितसङ्ख्या';

  @override
  String get helpCallManagementBullet5 =>
      'अङ्कपटलस्य 1 तः 9 पर्यन्तं प्रत्येकस्यां कुञ्जिकायाम् एकः जनः स्थापयितुं शक्यते। तम् आह्वातुम् आह्वानपटले कुञ्जिका धार्यताम्।';

  @override
  String get helpCallManagementBullet6 =>
      'सङ्ख्यापेटिका रिक्ता चेत् एव धारणं कार्यं करोति, अतः लेखनकाले दीर्घस्पर्शः कदापि आह्वानं न आरभते।';

  @override
  String get helpCallManagementBullet7 =>
      'कुञ्जिकास्थापनाय: आह्वानपटले रिक्तकुञ्जिकां धृत्वा सम्पर्कः चीयतां, विन्यासाः → त्वरितसङ्ख्या इति वा गम्यताम्। सम्पर्कस्य अनेकाः सङ्ख्याः सन्ति चेत् का रक्षणीया इति पृच्छ्यते।';

  @override
  String get helpCallManagementBullet8 =>
      'जनधारिण्यां कुञ्जिकायाम् अङ्कस्य उपरि लघुः वर्णबिन्दुः दृश्यते।';

  @override
  String get helpCallManagementBullet9 =>
      'गुप्तसम्पर्काः कुञ्जिकायां स्थापयितुं न शक्यन्ते, कुञ्जिकास्थस्य सम्पर्कस्य लोपे गुप्तीकरणे वा कुञ्जिका स्वयं रिक्ता भवति।';

  @override
  String get helpCallManagementTitle3 => 'द्वि-SIM आह्वानं प्राधान्यानि च';

  @override
  String get helpCallManagementBullet10 =>
      'द्वि-SIM दूरभाषेषु आह्वानपटलं सद्यःचयनाय SIM 1 SIM 2 च आह्वानगण्डौ ददाति।';

  @override
  String get helpCallManagementBullet11 =>
      'विन्यासाः → SIM आह्वानं च → SIM पत्राणि खातानि च इत्यत्र बहिर्गाम्याह्वानेभ्यः मूल-SIM स्थाप्यते, प्रतिवारं प्रश्नाय \"प्रत्याह्वानं पूर्वं पृच्छ्यताम्\" इति वा सक्रियं क्रियते।';

  @override
  String get helpCallManagementBullet12 =>
      'एकस्य जनस्य स्वकीयं SIM भवितुम् अर्हति: सम्पर्कम् उद्घाट्य \"सम्पाद्यताम्\" स्पृष्ट्वा \"इष्ट-SIM\" इत्यत्र चीयताम्। ततः तस्य आह्वानानि मूल-SIM स्थाने तत् SIM प्रयुञ्जते।';

  @override
  String get helpCallManagementBullet13 =>
      '\"प्रत्याह्वानं पूर्वं पृच्छ्यताम्\" सक्रियं चेत् तथापि पृच्छ्यते, किन्तु तेन आह्वानेन प्रयोक्ष्यमाणं SIM पूर्वमेव चिह्नितं, अतः एकः स्पर्शः पर्याप्तः।';

  @override
  String get helpCallManagementBullet14 =>
      'तत् SIM पश्चात् दूरभाषात् अपनीतं चेत्, आह्वानानि शान्तं मूल-SIM प्रति प्रत्यागच्छन्ति।';

  @override
  String get helpCallManagementBullet15 =>
      'तत् एव पटलं प्रत्येकस्मै SIM स्वकीयं वर्णं ददाति, येन आह्वानं कस्यां पङ्क्तौ इति एकदृष्ट्या ज्ञायते।';

  @override
  String get helpCallManagementBullet16 =>
      'प्रत्येकस्य आगतस्य, बहिर्गतस्य, अप्राप्तस्य वा आह्वानस्य कृते किं SIM प्रयुक्तम् इति अद्यतनलेखः दर्शयति।';

  @override
  String get helpCallManagementTitle4 => 'Smart Redial \"माम् आह्वयतु\" SMS च';

  @override
  String get helpCallManagementBullet17 =>
      'बहिर्गाम्याह्वानं व्यस्तम् अस्वीकृतं वा चेत्, किञ्चित्कालानन्तरं सङ्ख्यां पुनः आह्वातुम् अनुप्रयोगः प्रस्तौति।';

  @override
  String get helpCallManagementBullet18 =>
      'तस्य स्थाने, प्रयतितम् इति वक्तुम् एकस्पर्शेन पूर्वनिश्चितः \"माम् आह्वयतु\" सन्देशः प्रेषयितुं शक्यते।';

  @override
  String get helpCallManagementBullet19 =>
      'विन्यासाः → SIM आह्वानं च → Smart Redial \"माम् आह्वयतु\" च इत्यत्र मूलप्रतीक्षाकालः पूर्वनिश्चितसन्देशः च स्थाप्येते, प्रतीक्षमाणपुनराह्वानानां सूची च दृश्यते।';

  @override
  String get helpCallManagementBullet20 =>
      'निर्धारितं पुनराह्वानम् एव अनुप्रयोगः यत्र स्वयम् आह्वयति तत् एकमात्रं स्थानं, तदपि भवता स्वयं कालनिर्धारणात् एव। प्रतीक्षमाणं पुनराह्वानं तस्याः एव सूच्याः निरस्यताम्।';

  @override
  String get helpCallManagementTitle5 => 'आह्वातृनामोच्चारणम्';

  @override
  String get helpCallManagementBullet21 =>
      'विन्यासाः → SIM आह्वानं च → आह्वातृनामोच्चारणम् इत्यत्र सक्रियं क्रियताम्। ततः अनुप्रयोगः घण्टानादेन सह आह्वातुः नाम वदति — \"अम्बा आह्वयति\"।';

  @override
  String get helpCallManagementBullet22 =>
      'मलयालनाम मलयालभाषया उच्चार्यते। वास्तविकाह्वानात् पूर्वं नाम कथं श्रूयते इति ज्ञातुं तस्मिन् पटले परीक्षणगण्डः प्रयुज्यताम्।';

  @override
  String get helpCallManagementBullet23 =>
      'दूरभाषे नदति अपि रात्रौ नामोच्चारणं न भवेत् इति शान्तकालापवादः सक्रियः क्रियतां, तस्य कालावधिः च स्थाप्यताम्।';

  @override
  String get helpCallManagementTitle6 => 'द्रुत-SMS निराकरणोत्तराणि';

  @override
  String get helpCallManagementBullet24 =>
      'इदानीं स्वीकर्तुं न शक्यते वा? आह्वानं निराकृत्य पूर्वनिश्चितसन्देशं प्रेषयितुम् आगमनपटले \"उत्तरम्\" स्पृश्यताम्।';

  @override
  String get helpCallManagementBullet25 =>
      'विन्यासाः → SIM आह्वानं च → द्रुतोत्तराणि इत्यत्र स्वकीयसन्देशाः लिख्यन्ताम्।';

  @override
  String get helpCallManagementFooter =>
      'सूचना: एतं मूलदूरभाषानुप्रयोगं करोतु — इदानीम् अस्ति वा इति विन्यासाः → अनुमतयः दर्शयति। तां भूमिकां विना Android आह्वानमध्यनियन्त्रणानि पूर्णपटलागमनसूचनां वा न ददाति।';

  @override
  String get helpRelationshipCategoriesText1 => 'सम्बन्धवर्गाः';

  @override
  String get helpRelationshipCategoriesIntro =>
      'भवता रक्षितस्य प्रत्येकस्य सम्बन्धस्य द्वौ भागौ: वर्गः नाम च। वर्गः सप्तसु निश्चितसमुच्चयेषु एकः। नाम यत् भवान् वक्तुम् इच्छति तत् — \"पिता\", \"पितृव्यपुत्रः\", \"प्रबन्धकः\"।';

  @override
  String get helpRelationshipCategoriesTitle1 => 'वर्गाः किमर्थम्';

  @override
  String get helpRelationshipCategoriesBullet1 =>
      'पूर्वं मण्डलं प्रत्येकभिन्ननाम्ने एकं बिन्दुम् अलिखत्। विंशतेः अधिकेषु सम्बन्धेषु तत् जनसम्मर्दः अभवत्।';

  @override
  String get helpRelationshipCategoriesBullet2 =>
      'इदानीं मण्डलं सप्त बिन्दून् यावत् एव लिखति — प्रतिवर्गम् एकम्। बिन्दोः अन्तः सङ्ख्या तस्मिन् कति सम्पर्काः इति।';

  @override
  String get helpRelationshipCategoriesBullet3 =>
      'बिन्दुं स्पृष्ट्वा तदन्तःस्थाः सर्वे स्वस्वनाम्ना सह दृश्यन्ते। किमपि न गुप्तम्; केवलं स्वच्छतरम्।';

  @override
  String get helpRelationshipCategoriesTitle2 => 'सम्बन्धयोजनम्';

  @override
  String get helpRelationshipCategoriesBullet4 => 'संयोजनीयः सम्पर्कः चीयताम्।';

  @override
  String get helpRelationshipCategoriesBullet5 => 'सप्तसु वर्गेषु एकः चीयताम्।';

  @override
  String get helpRelationshipCategoriesBullet6 =>
      'नाम लिख्यतां, सूचितचिप्-एषु एकं वा स्पृश्यताम्। चिप्-आः लघुमार्गाः एव — इष्टः कः अपि शब्दः स्वीक्रियते।';

  @override
  String get helpRelationshipCategoriesTitle3 => 'सप्त वर्गाः';

  @override
  String get helpRelationshipCategoriesTitle4 => 'उभयपक्षे एकः वर्गः';

  @override
  String get helpRelationshipCategoriesBullet7 =>
      'सम्बन्धः उभयोः सम्पर्कयोः रक्ष्यते। कञ्चित् पितृत्वेन रक्षति चेत्, तस्य पक्षे भवान् पुत्रः पुत्री वा इति दृश्यते।';

  @override
  String get helpRelationshipCategoriesBullet8 =>
      'प्रतिपक्षः तम् एव वर्गं धारयति, अतः इदं युग्मम् उभयोः मण्डलयोः एकस्मिन् एव समुच्चये तिष्ठति।';

  @override
  String get helpRelationshipCategoriesTitle5 => 'पूर्वरक्षिताः सम्बन्धाः';

  @override
  String get helpRelationshipCategoriesBullet9 =>
      'पुरातनसम्बन्धानां वर्गः न आसीत्। अस्य नवीकरणस्य अनन्तरं प्रथमारम्भे प्रत्येकः स्वनाम्ना व्यवस्थाप्यते — \"Father\" निकटकुटुम्बं प्रति, \"Colleague\" व्यावसायिकं प्रति, एवम्।';

  @override
  String get helpRelationshipCategoriesBullet10 =>
      'अनुप्रयोगेन अपरिचितं नाम सामाजिकं प्रति गच्छति। किमपि न लुप्यते, कः अपि सम्बन्धः स्पृष्ट्वा \"परिवर्त्यताम्\" इति चित्वा अन्यवर्गं प्रति नेतुं शक्यते।';

  @override
  String get helpRelationshipCategoriesTitle6 =>
      'शान्तकालः एतान् वर्गान् प्रयुङ्क्ते';

  @override
  String get helpRelationshipCategoriesBullet11 =>
      'विन्यासाः → SIM आह्वानं च → सम्बन्धस्तरीयशान्तकालः भवता निश्चितयोः कालयोः मध्ये आह्वानानि निःशब्दीकरोति।';

  @override
  String get helpRelationshipCategoriesBullet12 =>
      'एषा अनुमतिसूची, न निरोधसूची। भवता योजितान् विहाय सर्वे निःशब्दीक्रियन्ते — तारकितसम्पर्काः, निकटकुटुम्बम् इत्यादयः सम्पूर्णवर्गाः, एकं चिह्नं, नामनिर्दिष्टाः जनाः वा।';

  @override
  String get helpRelationshipCategoriesBullet13 =>
      'अतः एव वर्गः महत्त्वपूर्णः: \"निकटकुटुम्बम्\" अनुमन्यते चेत्, प्रत्येकस्मै दत्तं नाम यत् किमपि स्यात्, तस्मिन् समुच्चये सर्वे सम्पर्काः नदन्ति।';

  @override
  String get helpRelationshipCategoriesFooter =>
      'सूचना: कः कुत्र अर्हति इति संशये सति, पश्चात् भवान् यत्र अन्विष्येत् तं वर्गं चिनोतु। विवरणं नाम वहति।';

  @override
  String get helpP2pSyncText => 'अन्योपकरणेन समन्वयः';

  @override
  String get helpP2pSyncIntro =>
      'एकेन एव Wi-Fi जालेन भवतः सम्पर्काः (अन्यत् च) एकस्मात् दूरभाषात् अन्यं प्रति प्रतिलिख्यन्ताम्। अन्तर्जालं, मेघः, खातं वा न आवश्यकम् — उभौ दूरभाषौ साक्षात् संवदतः। उभयोः अयम् अनुप्रयोगः चलेत्।';

  @override
  String get helpP2pSyncTitle1 => 'आरम्भात् पूर्वम्';

  @override
  String get helpP2pSyncBullet1 =>
      'उभौ दूरभाषौ एकस्मिन् एव Wi-Fi जाले स्थाप्येताम्।';

  @override
  String get helpP2pSyncBullet2 =>
      'उभयोः अस्य अनुप्रयोगस्य समानं संस्करणम् इति निश्चीयताम्। संस्करणे न मिलतः चेत् समन्वयः विरमति, उभौ नवीकर्तुं च प्रार्थयते।';

  @override
  String get helpP2pSyncBullet3 =>
      'उभयोः दूरभाषयोः विन्यासाः → अन्योपकरणेन समन्वयः इति उद्घाट्यताम्। समन्वये गुप्तसम्पर्काः अन्तर्भवितुम् अर्हन्ति इति प्रथमम् अङ्गुलिमुद्रां, मुखं, PIN वा पृच्छति।';

  @override
  String get helpP2pSyncBullet4 =>
      'प्रेषकदूरभाषे \"अन्योपकरणं प्रति प्रेष्यताम्\" स्पृश्यताम्। ग्राहकदूरभाषे \"अन्योपकरणात् गृह्यताम्\" स्पृश्यताम्।';

  @override
  String get helpP2pSyncTitle2 => 'द्वौ दूरभाषौ कथं संयुज्येते';

  @override
  String get helpP2pSyncBullet5 =>
      'प्रेषकदूरभाषः युग्मनसङ्केतं QR सङ्केतं च दर्शयति।';

  @override
  String get helpP2pSyncBullet6 =>
      'ग्राहकदूरभाषः तं QR सङ्केतं परीक्षते, युग्मनसङ्केतः हस्तेन वा लिख्यते।';

  @override
  String get helpP2pSyncBullet7 =>
      'युग्मनसङ्केतः पटले एव दर्श्यते — जालेन कदापि न प्रेष्यते। सम्पूर्णं प्रेषणं तेन सङ्केतेन गूढीक्रियते, अतः अशुद्धसङ्केते संयोगः असफलः भवति।';

  @override
  String get helpP2pSyncTitle3 => 'पूर्णसमन्वयः चयनितसमन्वयः च';

  @override
  String get helpP2pSyncBullet8 =>
      'पूर्णसमन्वयः अधः उक्तं सर्वम् एकपदे प्रेषयति। प्रेषकस्य अनुप्रयोगविन्यासाः ग्राहकस्य विन्यासान् प्रतिस्थापयन्ति, प्रेषकस्य स्वकीयं परिचयपत्रं (\"स्वयम्\") ग्राहके सामान्यसम्पर्करूपेण योज्यते (ग्राहकस्य स्वपरिचयं कदापि न प्रतिस्थापयति)।';

  @override
  String get helpP2pSyncBullet9 =>
      'चयनितसमन्वयः भवता चितान् दत्तांशवर्गान् एव प्रेषयति। सम्पर्काः सर्वदा अन्तर्भवन्ति। विन्यासाः रिक्तानि एव पूरयन्ति (ग्राहकेण स्थापितं कदापि न अधिलिखन्ति), प्रेषकस्य \"स्वयम्\" पत्रं न प्रेष्यते।';

  @override
  String get helpP2pSyncTitle4 => 'किं समन्वीयते';

  @override
  String get helpP2pSyncBullet10 =>
      'सम्पर्काः तेषां विवरणानि च: दूरभाषसङ्ख्याः, ईमेल्-सङ्केताः, सङ्केताः, आधिकारिकविवरणानि, सामाजिकसम्बन्धाः, चिह्नानि च।';

  @override
  String get helpP2pSyncBullet11 => 'सम्पर्कचित्राणि आह्वानपत्रचित्राणि च।';

  @override
  String get helpP2pSyncBullet12 =>
      'आह्वानेतिवृत्तम्: आह्वानलेखाः, संवादाः, स्मारकाणि च।';

  @override
  String get helpP2pSyncBullet13 => 'समूहाः तेषां सदस्याः च।';

  @override
  String get helpP2pSyncBullet14 => 'सम्पर्काणां मध्ये सम्बन्धाः।';

  @override
  String get helpP2pSyncBullet15 => 'अवरुद्धसङ्ख्याः।';

  @override
  String get helpP2pSyncBullet16 =>
      'भवतः आपत्कालसूचनापत्रम् — पूर्णसमन्वये, विभजनीयचयनकाले चिह्निते वा। ग्राहकदूरभाषस्य स्वकीयं पत्रं नास्ति चेत् एव सः तत् स्वीकरोति, अतः कस्य अपि आरोग्यविवरणं न प्रतिस्थाप्यते।';

  @override
  String get helpP2pSyncBullet17 =>
      'विशिष्टदूरभाषेण असम्बद्धाः अनुप्रयोगविन्यासाः — विषयः, प्रधानवर्णः, मूलदेशः, द्रुतोत्तराणि, आह्वानव्यवहारविकल्पाः इत्यादयः।';

  @override
  String get helpP2pSyncTitle5 => 'कदापि न समन्वीयमानम्';

  @override
  String get helpP2pSyncBullet18 =>
      'घण्टानादाः। घण्टानादः प्रेषकदूरभाषस्थां सञ्चिकां निर्दिशति, या अपरस्मिन् दूरभाषे न स्यात्।';

  @override
  String get helpP2pSyncBullet19 =>
      'SIM-विशिष्टविन्यासाः, यथा मूल-SIM प्रति-SIM घण्टानादाः वर्णाः च। एते प्रेषकदूरभाषस्थानि भौतिक-SIM पत्राणि निर्दिशन्ति।';

  @override
  String get helpP2pSyncTitle6 => 'ग्राहकदूरभाषे किमपि न लुप्यते';

  @override
  String get helpP2pSyncBullet20 =>
      'समन्वयः केवलं योजयति। ग्राहकदूरभाषः स्वं सर्वं दत्तांशं रक्षति — आगतैः सम्पर्कैः किमपि न मार्ज्यते न अधिलिख्यते।';

  @override
  String get helpP2pSyncBullet21 =>
      'भवतः पूर्वविद्यमानः सम्पर्कः (समानं नाम, न्यूनातिन्यूनम् एका सामान्यदूरभाषसङ्ख्या च) त्यज्यते, न द्विरुच्यते। नूतनसम्पर्काः एव योज्यन्ते, तेषां विवरणानि आह्वानेतिवृत्तं च सह आगच्छन्ति।';

  @override
  String get helpP2pSyncBullet22 =>
      'विद्यमानसम्पर्कः त्यज्यते इति तस्य कृते प्रेषकस्य आह्वानेतिवृत्तं न एकीक्रियते — नूतनसम्पर्काः एव इतिवृत्तम् आनयन्ति।';

  @override
  String get helpP2pSyncTitle7 => 'भवतः दत्तांशः गोपनीयः तिष्ठति';

  @override
  String get helpP2pSyncBullet23 =>
      'प्रेषणं भवतः स्थानीय-Wi-Fi मध्ये द्वयोः दूरभाषयोः साक्षात् भवति। अन्तर्जालं कञ्चित् सेवकं वा प्रति किमपि न आरोप्यते।';

  @override
  String get helpP2pSyncBullet24 =>
      'दत्तांशे गुप्तसम्पर्काः अन्तर्भवितुम् अर्हन्ति इति समन्वयोद्घाटनम् उपकरणतालकेन रक्षितम्।';

  @override
  String get helpP2pSyncFooter =>
      'सूचना: समन्वयसमाप्तिपर्यन्तम् उभौ दूरभाषौ जागृतौ एकस्मिन् एव Wi-Fi मध्ये च स्थाप्येताम्।';

  @override
  String get helpFaqTroubleshootingText => 'नित्यप्रश्नाः समस्यापरिहारः च';

  @override
  String get helpFaqTroubleshootingIntro =>
      'अनुमतयः, मूलाह्वानानुप्रयोगस्थापनं, गोपनीयता, समन्वयविकल्पाः, ContactSphere मध्ये समस्यापरिहारसोपानानि च इति विषयेषु सामान्यप्रश्नानां शीघ्रोत्तराणि अन्विष्यन्ताम्।';

  @override
  String get helpFaqTroubleshootingTitle1 => 'सामान्यम् अनुमतयः च';

  @override
  String get helpFaqTroubleshootingQ1 =>
      'ContactSphere कृते मूलदूरभाषानुप्रयोगानुमतिः किमर्थम् आवश्यकी?';

  @override
  String get helpFaqTroubleshootingA1 =>
      'आगमनसूचनाः दर्शयितुं, सम्मेलनैकीकरणम् आह्वानपरिवर्तनं च सम्भावयितुम्, अनिष्टाह्वानानि स्वयं परीक्ष्य निरोद्धुं च अनुप्रयोगः मूलदूरभाषानुप्रयोगः भवेत् इति Android अपेक्षते।';

  @override
  String get helpFaqTroubleshootingQ2 =>
      'मम सम्पर्काः बाह्यसेवकेषु आरोप्यन्ते वा?';

  @override
  String get helpFaqTroubleshootingA2 =>
      'न। ContactSphere जालरहितप्राथम्येन निर्मितम्। सर्वे सम्पर्काः, आह्वानलेखाः, टिप्पण्यः, चित्राणि च भवतः गूढे स्थानीय-SQLite दत्तांशकोशे सन्ति। भवतः वैयक्तिक-Google Drive / WebDAV मेघप्रतिलिपिं भवान् स्पष्टं न स्थापयति चेत् कोऽपि दत्तांशः बाह्यसेवकान् प्रति न प्रेष्यते।';

  @override
  String get helpFaqTroubleshootingQ3 => 'काश्चन अनुमतयः ऐच्छिकाः किमर्थम्?';

  @override
  String get helpFaqTroubleshootingA3 =>
      'Bluetooth (समीपविभजनाय), छायाचित्रयन्त्रम् (QR व्यापारपत्रपरीक्षणाय च), ध्वनिग्राहकम् (आह्वानटिप्पणीवचनाय) इत्यादयः अनुमतयः तस्याः विशेषतायाः प्रथमप्रयोगे एव पृच्छ्यन्ते। एकस्याः निषेधे सा विशेषता एव निष्क्रिया भवति। पूर्णसूच्यै \"अनुमतीनां व्याख्या\" मार्गदर्शिका दृश्यताम्।';

  @override
  String get helpFaqTroubleshootingTitle2 => 'आह्वानपटलम् आह्वानं च';

  @override
  String get helpFaqTroubleshootingQ4 =>
      'T9 मध्ये मलयाल-देवनागरीनामानि कथम् अन्वेष्टव्यानि?';

  @override
  String get helpFaqTroubleshootingA4 =>
      'व्यञ्जनवर्गस्य कुञ्जिकाः स्पृश्यन्ताम्, नाम आङ्ग्लभाषायां यथा श्रूयते तथा लिख्यतां वा (2-6-4-5 इति लेखने \"Anil\" \"അനിൽ\" च उभे लभ्येते)। अङ्कपटलेन दर्शितां लिपिं परिवर्तयितुं मुख्यविन्यासपृष्ठे \"अङ्कपटललिपिः\" इति पत्रं प्रयुज्यताम्।';

  @override
  String get helpFaqTroubleshootingQ5 =>
      'कस्मात् SIM आह्वातव्यम् इति कथं चेयम्?';

  @override
  String get helpFaqTroubleshootingA5 =>
      'द्वि-SIM दूरभाषेषु आह्वानपटलं SIM 1 SIM 2 च पृथक् आह्वानगण्डौ ददाति। प्रतिवारं चयनं न इष्टं चेत् विन्यासाः → SIM आह्वानं च → SIM पत्राणि खातानि च इत्यत्र मूल-SIM स्थाप्यतां, तत्र \"प्रत्याह्वानं पूर्वं पृच्छ्यताम्\" इति वा सक्रियं क्रियताम्।';

  @override
  String get helpFaqTroubleshootingQ6 => 'शान्तकाले आह्वानं किमर्थं न अनदत्?';

  @override
  String get helpFaqTroubleshootingA6 =>
      'शान्तकालः भवता अनुमतान् विहाय सर्वं निःशब्दीकरोति। विन्यासाः → SIM आह्वानं च → सम्बन्धस्तरीयशान्तकालः इति उद्घाट्य ये प्राप्नुयुः ते योज्यन्ताम् — तारकितसम्पर्काः, सम्पूर्णसम्बन्धवर्गाः, एकं चिह्नं, नामनिर्दिष्टाः जनाः वा। तस्यां सूच्याम् अविद्यमानाः शान्तकालसमाप्तिपर्यन्तं निःशब्दीक्रियन्ते।';

  @override
  String get helpFaqTroubleshootingTitle3 => 'समन्वयः, मेघः, प्रतिलिपयः च';

  @override
  String get helpFaqTroubleshootingQ7 =>
      'स्थानीय-Wi-Fi समन्वयस्य मेघसमन्वयस्य च कः भेदः?';

  @override
  String get helpFaqTroubleshootingA7 =>
      'स्थानीय-Wi-Fi समन्वयः अन्तर्जालं खातं च विना एकजालस्थात् दूरभाषात् अन्यं प्रति साक्षात् दत्तांशं प्रतिलिखति। जालसमन्वयः मेघप्रतिलिपिः च भवता स्वयं योजितानि खातानि प्रयुञ्जाते — Google, Microsoft, CardDAV/WebDAV सेवकः वा — एकस्य स्थापनपर्यन्तं ते निष्क्रिये।';

  @override
  String get helpFaqTroubleshootingQ8 =>
      'प्रतिलिपिगुप्तशब्दः विस्मृतः चेत् किं भवति?';

  @override
  String get helpFaqTroubleshootingA8 =>
      'प्रतिलिपिसञ्चिका भवता चितेन गुप्तशब्देन गूढा, अनुप्रयोगः तं कदापि न रक्षति। प्रष्टुं कोऽपि सेवकः नास्ति, अतः गुप्तशब्दनाशे सञ्चिका उद्घाटयितुं न शक्यते। आवश्यकतायाः पूर्वं सः सुरक्षितस्थाने लिख्यताम्।';

  @override
  String get helpFaqTroubleshootingQ9 =>
      'दूरभाषसम्पर्कैः सह समन्वयः किमपि लोपयति वा?';

  @override
  String get helpFaqTroubleshootingA9 =>
      'सामान्यसमन्वयः नूतनान् नवीकृतान् च सम्पर्कान् सुरक्षितम् एकीकरोति। लोपसहितः / प्रतिबिम्बसमन्वयः कस्य अपि सम्पर्कस्य प्रतिस्थापनात् अपनयनात् वा पूर्वं स्पष्टं पूर्वसूचयति।';

  @override
  String get helpFaqTroubleshootingTitle4 => 'गोपनीयता गुप्तसम्पर्काः च';

  @override
  String get helpFaqTroubleshootingQ10 =>
      'जैवमित्युद्घाटनम् असफलं चेत् प्रवेशः कथं पुनः प्राप्यः?';

  @override
  String get helpFaqTroubleshootingA10 =>
      'दूरभाषस्य स्वकीयम् उद्घाटनपटलं भवतः पटलतालकस्य PIN, प्रतिरूपं, गुप्तशब्दं वा प्रति गच्छति। तस्य स्थाने अनुप्रयोगस्य PIN प्रयुङ्क्ते, तं विस्मृतवान् च चेत्, तालपटले \"PIN विस्मृतः वा?\" इति स्पृष्ट्वा स्थापनकाले लब्धः पुनर्लाभसङ्केतः दीयताम्।';

  @override
  String get helpFaqTroubleshootingQ11 =>
      'अनुप्रयोगपरिवर्तनकाले पटलं किमर्थं कृष्णं भवति?';

  @override
  String get helpFaqTroubleshootingA11 =>
      'पटलचित्ररक्षा संवेदनशीलदृश्यानि Android इत्यस्य अद्यतनानुप्रयोगपूर्वदृश्ये पृष्ठभूम्यभिलेखनसाधनैः वा ग्रहणात् रक्षति।';

  @override
  String get helpFaqTroubleshootingTitle5 => 'समस्यापरिहारः परिपालनं च';

  @override
  String get helpFaqTroubleshootingQ12 =>
      'अन्वेषणं मन्दम्, नूतनसम्पर्काः वा न लभ्यन्ते। कथं समाधेयम्?';

  @override
  String get helpFaqTroubleshootingA12 =>
      'विन्यासाः → सम्पर्काः → सम्पर्कसङ्ख्या अन्वेषणसूची च इति उद्घाट्यताम्। केषाञ्चित् सम्पर्काणाम् अन्वेषणकुञ्जिकाः पुरातनाः चेत् \"पुनर्निर्मीयताम्\" गण्डः दृश्यते — तं स्पृष्ट्वा कतिपयक्षणेषु कुञ्जिकाः पुनः निर्मीयन्ते।';

  @override
  String get helpFaqTroubleshootingQ13 =>
      'अवरुद्धा सङ्ख्या अद्यतनलेखे अद्यापि दृश्यते। सा नदति वा?';

  @override
  String get helpFaqTroubleshootingA13 =>
      'न। अवरुद्धम् आह्वानं दूरभाषनादात् पूर्वं निराक्रियते, किन्तु कश्चित् प्रयतितवान् इति द्रष्टुं \"अवरुद्धम्\" इति चिह्नेन अद्यतनलेखे लिख्यते। आह्वानं द्रष्टुम् इच्छा, केवलं विघ्नः न इष्टः चेत्, निरोधस्य स्थाने \"शङ्कितानिष्टाः परिशोध्यन्ताम्\" प्रयुज्यताम्।';

  @override
  String get helpFaqTroubleshootingQ14 =>
      'कश्चित् सम्पर्कः स्वयम् अदृश्यः अभवत्। किमर्थम्?';

  @override
  String get helpFaqTroubleshootingA14 =>
      'सः सम्भवतः क्षणिक(तात्कालिक)सम्पर्करूपेण रक्षितः, यः 2 होराभ्यः, 24 होराभ्यः, 7 दिनेभ्यः, एकस्मात् आह्वानात् वा परं स्वयं लुप्यते। तादृशसम्पर्कोद्घाटने \"स्थायित्वेन रक्ष्यताम्\" गण्डेन सह कालगणनपताकापत्रं दृश्यते।';

  @override
  String get helpFaqTroubleshootingQ15 => 'समूहाः चिह्नानि च कुत्र?';

  @override
  String get helpFaqTroubleshootingA15 =>
      'समूहाः सम्पर्कपटलस्य उपरितनपट्टिकायां समूहचिह्नस्य पृष्ठतः सन्ति। चिह्नानाम् अनुप्रयोगस्य अधः स्वकीयं पटलम् अस्ति, मेघरूपेण, यत्र अधिकजनैः प्रयुक्तं चिह्नं बृहत्तरं दृश्यते।';

  @override
  String get helpFaqTroubleshootingQ16 =>
      'द्विरुक्तसम्पर्काः कथं स्वच्छीकार्याः?';

  @override
  String get helpFaqTroubleshootingA16 =>
      'सम्पर्कपटलम् उद्घाट्य त्रिबिन्दुसूचीं स्पृष्ट्वा \"द्विरुक्तानि अन्विष्यन्ताम्\" इति चीयताम्। दूरभाषसङ्ख्यया नाम्ना च (लिप्यन्तरितनामसहितम्) मेलनं भवति। प्रत्येकं समुच्चयं परीक्ष्य एकीक्रियतां, \"सर्वे समुच्चयाः एकीक्रियन्ताम्\" इति वा प्रयुज्यताम्।';

  @override
  String get helpFaqTroubleshootingFooter =>
      'अद्यापि समस्या वा? सहायतायाम् उचितमार्गदर्शिका उद्घाट्यतां, विशेषतायाः अनुमतिः न्यूना वा इति विन्यासाः → अनुमतयः इत्यत्र परीक्ष्यतां वा।';

  @override
  String get aboutDetailAuthor => 'रचयिता';

  @override
  String get aboutDetailEmail => 'ईमेल्';

  @override
  String get aboutDetailLicense => 'अनुज्ञापत्रम्';

  @override
  String get aboutDetailAiUsed => 'प्रयुक्तः AI';

  @override
  String get aboutDetailIdeUsed => 'प्रयुक्तः IDE';

  @override
  String get labelVersion => 'संस्करणम्';

  @override
  String get labelBuildDate => 'निर्माणतिथिः';

  @override
  String labelVersionBuild(String version, String build) {
    return '$version (निर्माणम् $build)';
  }

  @override
  String get tabDetails => 'विवरणम्';

  @override
  String get tabHistory => 'इतिवृत्तम्';

  @override
  String get tabAddContact => 'सम्पर्कयोजनम्';

  @override
  String get emptyNoCallsWithContact =>
      'अनेन सम्पर्केण सह अद्यापि किमपि आह्वानं नास्ति।';

  @override
  String get emptyNoCallsWithNumber =>
      'अनया सङ्ख्यया सह अद्यापि किमपि आह्वानं नास्ति।';

  @override
  String get tooltipCheckAgain => 'पुनः परीक्ष्यताम्';

  @override
  String get tooltipCreateGroup => 'समूहः सृज्यताम्';

  @override
  String get tooltipCentreSphere => 'अत्र केन्द्रीक्रियताम्';

  @override
  String get tooltipOpenProfile => 'परिचयः उद्घाट्यताम्';

  @override
  String get tooltipCancelRedial => 'पुनराह्वानं निरस्यताम्';

  @override
  String get tooltipScanAgain => 'पुनः अन्विष्यताम्';

  @override
  String get tooltipShowPassword => 'गुप्तशब्दः दर्श्यताम्';

  @override
  String get tooltipHidePassword => 'गुप्तशब्दः गोप्यताम्';

  @override
  String get tooltipRemoveAccount => 'उपयोक्तृविवरणम् अपनीयताम्';
}
