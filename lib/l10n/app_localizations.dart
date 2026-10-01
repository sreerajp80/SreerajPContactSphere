import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_sa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
    Locale('sa'),
  ];

  /// Dialog action button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Dialog action button that adds the typed phone number to the blocked list. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get actionBlock;

  /// App bar title of the blocked-numbers screen. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Blocked numbers'**
  String get titleBlockedNumbers;

  /// Title of the dialog that asks for a phone number to block. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Block a number'**
  String get titleBlockNumber;

  /// Text field label in the block-a-number dialog. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get labelPhoneNumber;

  /// Text field hint showing an example phone number. Descriptive text, not chrome; the digits are an example and may be replaced with one that reads naturally in the language.
  ///
  /// In en, this message translates to:
  /// **'e.g. +91 98765 43210'**
  String get hintPhoneNumberExample;

  /// Snackbar shown when the text typed into the block-a-number dialog cannot be read as a phone number. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look like a number'**
  String get errorNotAPhoneNumber;

  /// Snackbar confirming a number was removed from the blocked list. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{number} unblocked'**
  String msgNumberUnblocked(String number);

  /// Switch label. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Block unknown'**
  String get labelBlockUnknownCallers;

  /// Subtitle under the Block unknown switch, explaining what it does. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Reject calls that don’t show a number (hidden or private callers)'**
  String get descBlockUnknownCallers;

  /// Explainer card on the blocked-numbers screen telling the user the two conditions blocking needs. Descriptive text. SreerajP Contacts Sphere is the app name and stays untranslated.
  ///
  /// In en, this message translates to:
  /// **'Blocked numbers never ring. Blocking works while SreerajP Contacts Sphere is your default phone app and matches the exact number.'**
  String get descBlockedNumbersInfo;

  /// Title of the tappable card that opens the block-a-number dialog. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Add a number'**
  String get actionAddNumber;

  /// Subtitle under the Add a number card. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Calls from it will be rejected before ringing'**
  String get descAddNumber;

  /// Empty state shown when the blocked list has no entries. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No blocked numbers yet.'**
  String get emptyBlockedNumbers;

  /// Heading above the list of blocked numbers, with how many there are. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Blocked ({count})'**
  String labelBlockedCount(int count);

  /// Row subtitle giving the date a number was blocked. UI chrome — keep to one or two words. The date arrives already formatted by MaterialLocalizations.formatShortDate, not as an ARB DateTime placeholder: the intl package ships no CLDR date data for Sanskrit, so DateFormat.yMMMd('sa') throws. Keep this a String placeholder until that data exists.
  ///
  /// In en, this message translates to:
  /// **'Blocked {date}'**
  String labelBlockedOn(String date);

  /// Tooltip on the icon-only button that removes a number from the blocked list. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get tooltipUnblock;

  /// Title of the Settings row that opens the language picker, and the app bar title of the picker screen. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get titleLanguage;

  /// First option in the language picker: follow the phone's language instead of a fixed one. Also shown as the Settings row subtitle when this option is chosen. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get labelSystemDefault;

  /// Subtitle under the System default option in the language picker, explaining what it does. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Use the phone’s language when it is English, Malayalam or Sanskrit'**
  String get descLanguageSystemDefault;

  /// Screen-reader label for the Settings row that opens the language picker. Read aloud, never shown. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Language, currently {language}'**
  String semanticsLanguageSetting(String language);

  /// The English language, written in its own script (endonym). Never translate: it must read the same in every language so a user can find their language in the picker.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// The Malayalam language, written in its own script (endonym). Never translate: it must read the same in every language so a user can find their language in the picker.
  ///
  /// In en, this message translates to:
  /// **'മലയാളം'**
  String get languageNameMl;

  /// The Sanskrit language, written in its own script (endonym). Never translate: it must read the same in every language so a user can find their language in the picker.
  ///
  /// In en, this message translates to:
  /// **'संस्कृतम्'**
  String get languageNameSa;

  /// Button that saves. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Button or dialog action that deletes. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Button that closes a dialog or sheet. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Button that closes a dialog or ends editing once the work is finished. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Button that retries a failed step. Shared across screens. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// Button that skips an optional step. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// Button that goes on to the next step. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Button that changes a chosen value (a SIM, a category). Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get actionChange;

  /// Bottom navigation tab that shows the contact list. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get navContacts;

  /// Bottom navigation tab that shows the phone keypad. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Dialer'**
  String get navDialer;

  /// Bottom navigation tab that shows recent calls (the call history). UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Recents'**
  String get navRecents;

  /// Bottom navigation tab that shows the tag cloud. A tag is a short label the user puts on contacts. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get navTags;

  /// Snackbar after the first right swipe on the home screen; a second swipe closes the app. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Swipe right again to exit'**
  String get msgSwipeAgainToExit;

  /// Tooltip on the back arrow shown while the user is picking a second number to add to a live call. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Return to call'**
  String get tooltipReturnToCall;

  /// Banner at the top of the home screen while the user picks a second number to add to a live call. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Adding call to ongoing call…'**
  String get msgAddingCallToOngoing;

  /// How many contacts carry a tag or belong to a list. The =1 form is used instead of 'one' because intl has no plural rules for Sanskrit. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 contact} other{{count} contacts}}'**
  String labelContactCount(int count);

  /// Snackbar after one tag was merged into another. {tag} is the surviving tag name, shown after a # sign. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Merged into #{tag} ({count, plural, =1{1 contact moved} other{{count} contacts moved}})'**
  String msgTagMerged(String tag, int count);

  /// Snackbar after a tag was renamed. {tag} is the new name, shown after a # sign. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Renamed to #{tag}'**
  String msgTagRenamed(String tag);

  /// Snackbar when renaming failed. {error} is the technical reason and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not rename: {error}'**
  String errorCouldNotRename(String error);

  /// Snackbar when merging two tags failed. {error} is the technical reason and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not merge: {error}'**
  String errorCouldNotMerge(String error);

  /// Snackbar when deleting failed. {error} is the technical reason and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String errorCouldNotDelete(String error);

  /// Title of the dialog confirming a tag deletion. {tag} is the tag name, shown after a # sign. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Delete #{tag}?'**
  String titleDeleteTagConfirm(String tag);

  /// Body of the dialog confirming a tag deletion. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contact uses this tag, so nothing else changes.'**
  String get descDeleteUnusedTag;

  /// Snackbar when a contact was given the tag between opening the sheet and tapping delete. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tag is in use again — remove its contacts first'**
  String get errorTagInUseAgain;

  /// Snackbar after a tag was deleted. {tag} is the tag name, shown after a # sign. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Deleted #{tag}'**
  String msgTagDeleted(String tag);

  /// Row in the tag actions sheet. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get actionRenameTag;

  /// Row in the tag actions sheet that opens a list of tags to merge this one into. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Merge into…'**
  String get actionMergeInto;

  /// Subtitle under the disabled Merge into row when there is only one tag. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No other tags to merge into'**
  String get descNoOtherTags;

  /// Row in the tag actions sheet. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Delete tag'**
  String get actionDeleteTag;

  /// Subtitle under the disabled Delete tag row, with how many contacts still carry the tag. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Remove its contacts first ({count})'**
  String descRemoveContactsFirst(int count);

  /// Title of the rename-tag dialog. {tag} is the current name, shown after a # sign. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Rename #{tag}'**
  String titleRenameTag(String tag);

  /// Text field label in the rename-tag dialog. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get labelTagName;

  /// Warning in the rename-tag dialog when the typed name is already another tag. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'#{tag} already exists. Both tags become one.'**
  String descTagAlreadyExists(String tag);

  /// Confirm button of the rename-tag dialog when the typed name already exists, so the rename becomes a merge. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Merge into #{tag}'**
  String actionMergeIntoTag(String tag);

  /// Confirm button of the rename-tag dialog. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// Title of the dialog that lists the tags this one can be merged into. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Merge #{tag} into'**
  String titleMergeTagInto(String tag);

  /// Post-call mood choice: the call went well. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get labelToneGreat;

  /// Post-call mood choice: the call was neither good nor bad. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get labelToneOkay;

  /// Post-call mood choice: the call went badly. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Rough'**
  String get labelToneRough;

  /// Post-call topic chip: a friendly catch-up. Only the label is translated; the saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Catch-up'**
  String get labelIntentCatchUp;

  /// Post-call topic chip. Only the label is translated; the saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get labelIntentWork;

  /// Post-call topic chip: arranging a time to meet. Only the label is translated; the saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Scheduling'**
  String get labelIntentScheduling;

  /// Post-call topic chip: following up on something earlier. Only the label is translated; the saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get labelIntentFollowUp;

  /// Post-call topic chip. Only the label is translated; the saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get labelIntentFamily;

  /// Post-call topic chip. Only the label is translated; the saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get labelIntentUrgent;

  /// Heading of the sheet shown after a call ends, asking how the call went. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get titleHowDidItGo;

  /// Subheading of the post-call sheet. {name} is the contact's name or the phone number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Call with {name}'**
  String labelCallWith(String name);

  /// Section heading above the post-call topic chips. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'What was it about?'**
  String get labelWhatWasItAbout;

  /// Section heading above a notes field. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelNotes;

  /// Hint inside the post-call notes field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Anything worth remembering?'**
  String get hintAnythingWorthRemembering;

  /// Switch label on the post-call sheet. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Follow-up reminder'**
  String get labelAddFollowUpReminder;

  /// Subtitle under the follow-up reminder switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Saved for reference — notifications coming soon'**
  String get descFollowUpSavedForReference;

  /// Hint inside the follow-up reminder text field, giving an example. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Send the contract'**
  String get hintFollowUpExample;

  /// Tappable placeholder that opens the date and time pickers for a follow-up reminder. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Pick date & time (optional)'**
  String get hintPickFollowUpTime;

  /// Title of the Bluetooth share dialog when sending the whole contact book. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send 1 contact} other{Send {count} contacts}}'**
  String titleSendContacts(int count);

  /// Error in the Bluetooth share dialog. Bluetooth is a brand name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is off. Turn it on and try again.'**
  String get errorBluetoothOff;

  /// Error in the Bluetooth share dialog when the phone has no Bluetooth Low Energy advertising. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This phone can\'t share over Bluetooth LE.'**
  String get errorBleUnsupported;

  /// Error in the Bluetooth share dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission was denied.'**
  String get errorBluetoothPermissionDenied;

  /// Error in the Bluetooth share dialog for any other start failure. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not start Bluetooth sharing.'**
  String get errorCouldNotStartBleShare;

  /// Error in the Bluetooth share dialog when the transfer broke. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth sharing failed.'**
  String get errorBleShareFailed;

  /// Contact-list menu item that opens the Bluetooth receive screen. Also quoted inside descBleReceiveHowTo, so the two always match. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Get via Bluetooth'**
  String get actionReceiveViaBluetooth;

  /// Hint in the Bluetooth share dialog telling the user what to do on the receiving phone. {menuItem} is actionReceiveViaBluetooth. SreerajP Contacts Sphere is the app name and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'On the other phone, open SreerajP Contacts Sphere and choose “{menuItem}” from the contacts menu.'**
  String descBleReceiveHowTo(String menuItem);

  /// Checkbox label in the Bluetooth share dialog. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Include photos'**
  String get labelIncludePhotos;

  /// Status line in the Bluetooth share dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Starting Bluetooth sharing…'**
  String get msgStartingBleShare;

  /// Status line in the Bluetooth share dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a nearby phone…'**
  String get msgWaitingForNearbyPhone;

  /// Status line while data is being sent. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get msgSending;

  /// Status line while data is being sent, with how much is done. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Sending… {percent}%'**
  String msgSendingPercent(int percent);

  /// Status line once the transfer finished. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Sent.'**
  String get msgSent;

  /// Shown when the Bluetooth permissions were refused. 'Nearby devices' is the Android permission name; use the name the phone's own settings show in that language (Android has no Sanskrit UI, so the Sanskrit keeps the English name). Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission is needed to share. Allow Nearby devices for SreerajP Contacts Sphere and try again.'**
  String get errorBlePermissionNeeded;

  /// Shown when Bluetooth sharing timed out with nobody connecting. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No phone connected. Try again when the receiver is ready.'**
  String get errorNoPhoneConnected;

  /// Title of the dialog asking whether to accept contacts sent over Bluetooth. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Incoming transfer'**
  String get titleIncomingTransfer;

  /// Body of the incoming-transfer dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A nearby device wants to send you contacts.'**
  String get descNearbyDeviceWantsToSend;

  /// Question at the bottom of the incoming-transfer dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Do you want to receive this transfer?'**
  String get descReceiveThisTransfer;

  /// Dialog button that refuses an incoming transfer. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get actionDecline;

  /// Dialog button that accepts an incoming transfer. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get actionAccept;

  /// Reason shown inside the phone's own fingerprint or screen-lock prompt. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to receive a Bluetooth transfer'**
  String get descAuthReasonBleReceive;

  /// Title of the dialog asking for the fingerprint or screen lock before a Bluetooth transfer is accepted. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Verify to receive'**
  String get titleAuthenticateToReceive;

  /// Shown in the authenticate dialog after a failed fingerprint or screen-lock attempt. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Try again or decline the transfer.'**
  String get errorAuthFailedBle;

  /// Body of the authenticate dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to accept this Bluetooth transfer.'**
  String get descVerifyIdentityBle;

  /// Button label while a fingerprint or PIN check is running. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get labelVerifying;

  /// Title of the dialog asking for the app PIN before a Bluetooth transfer is accepted. PIN stays in Latin letters. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN to receive'**
  String get titleEnterPinToReceive;

  /// Shown in the PIN dialog after a wrong PIN. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN — try again'**
  String get errorWrongPinTryAgain;

  /// Body of the PIN dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter your app PIN to accept this Bluetooth transfer.'**
  String get descEnterPinBle;

  /// Snackbar when the automatic call-back could not be scheduled. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule auto-retry'**
  String get errorCouldNotScheduleRetry;

  /// Snackbar after an automatic call-back was scheduled. {time} is a clock time already formatted for the locale; {name} is the contact's name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Auto-retry at {time} for {name}'**
  String msgAutoRetryAt(String time, String name);

  /// Snackbar action that opens the related screen. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get actionView;

  /// Title of the dialog explaining why the Alarms & reminders permission is needed. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms'**
  String get titleAllowAlarmsReminders;

  /// Body of the Alarms & reminders permission dialog. The quoted name is the Android permission; use the name the phone's own settings show in that language (Android has no Sanskrit UI, so the Sanskrit keeps the English name). Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Auto-Retry needs the \"Alarms & reminders\" permission so it can call back on schedule even if this app is closed. Enable it for SreerajP Contacts Sphere in the settings screen that opens next.'**
  String get descAlarmsPermission;

  /// Dialog button that opens the phone's system settings. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get actionOpenSettings;

  /// Snackbar when no SMS app could be opened. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not launch messaging app'**
  String get errorCouldNotLaunchMessaging;

  /// Heading of the sheet shown after an outgoing call was not answered. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Call Unanswered'**
  String get titleCallUnanswered;

  /// Section heading in the call-unanswered sheet. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'1. Auto-retry'**
  String get labelOptionAutoRetry;

  /// Section heading in the call-unanswered sheet. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'2. Reach-me message'**
  String get labelOptionReachMe;

  /// Button that schedules an automatic call-back after the chosen number of minutes. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Auto-Retry in {minutes} min'**
  String actionAutoRetryIn(int minutes);

  /// Tooltip on the icon button that lets the user edit the reach-me text. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get tooltipEditMessage;

  /// Hint inside the reach-me message field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Type your reach me message...'**
  String get hintReachMeMessage;

  /// Button that opens the SMS app with the reach-me text. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Send reach-me SMS'**
  String get actionSendReachMeSms;

  /// Button that closes the call-unanswered sheet without doing anything. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get actionDismiss;

  /// Chip label for a delay in minutes. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String labelMinutesShort(int minutes);

  /// Shown when no particular SIM was chosen. SIM stays in Latin letters in Sanskrit. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Default SIM'**
  String get labelDefaultSim;

  /// Row label before the SIM that the automatic call-back will use. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'SIM to dial:'**
  String get labelSimToDial;

  /// Heading of the SIM picker in the call-unanswered sheet. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'SIM for auto-retry'**
  String get titleSelectSimForRetry;

  /// Contact field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelFieldName;

  /// Contact field name: a phone number. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get labelFieldPhone;

  /// Contact field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelFieldEmail;

  /// Contact field name: job title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Designation'**
  String get labelFieldDesignation;

  /// Address field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get labelFieldCompany;

  /// Address field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get labelFieldStreet;

  /// Address field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get labelFieldCity;

  /// Address field name: the state or province. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get labelFieldState;

  /// Address field name. UI chrome — keep to one or two words.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get labelFieldPostalCode;

  /// Address field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get labelFieldCountry;

  /// Contact field name: a web or social link. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get labelFieldLink;

  /// Heading of the sheet that lists what the business-card scanner read. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Read from the card'**
  String get titleReadFromCard;

  /// Instructions under the heading of the business-card review sheet. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Untick anything that came out wrong. You can still edit everything on the next screen.'**
  String get descUntickWrongFields;

  /// Shown when the business-card scanner found nothing it could place. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No fields could be read from this card.'**
  String get emptyNoFieldsRead;

  /// Lists scanned lines that were not put into any contact field. {lines} is the raw scanned text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Not placed in a field: {lines}'**
  String descNotPlacedInField(String lines);

  /// Button that hides the full text the scanner read. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Hide scanned text'**
  String get actionHideScannedText;

  /// Button that shows the full text the scanner read. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Show scanned text'**
  String get actionShowScannedText;

  /// Shown in place of the scanned text when the scanner read nothing. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Nothing was recognized.'**
  String get emptyNothingRecognized;

  /// Button that goes back to take another photo of the business card. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get actionRetake;

  /// Text field label where the user types how two contacts are related. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Relationship label'**
  String get labelRelationshipLabel;

  /// Hint in the relationship label field, giving an example. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Father'**
  String get hintRelationshipExample;

  /// Heading of the relationship category list. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get titlePickCategory;

  /// Heading of the step where the user names a relationship. {name} is a contact's name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'How is {name} related?'**
  String titleHowIsRelated(String name);

  /// Heading of the sheet that picks a contact to link as a relative. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Link a contact'**
  String get titleLinkContact;

  /// Hint inside a contact search field. Shared across pickers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get hintSearchContacts;

  /// Empty state of the link-a-contact list. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts available'**
  String get emptyNoContactsAvailable;

  /// Heading of the step that picks a relationship category for the chosen contact. {name} is the contact's first name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Where does {name} belong?'**
  String titleWhereBelongs(String name);

  /// Shown when the animated QR stream could not be built. AirQR is a feature name and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not generate AirQR payload for this contact.'**
  String get errorAirQrPayload;

  /// Kind of animated-QR frame: a repair frame that lets the receiver fill gaps. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Fountain Parity'**
  String get labelFrameParity;

  /// Kind of animated-QR frame: a frame that carries the contact data itself. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Systematic Block'**
  String get labelFrameSystematic;

  /// Line above the animated QR code, with how many frames it cycles through. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Optical Air-Gap Stream ({count} frames)'**
  String descAirGapStream(int count);

  /// Shown in place of a QR frame that could not be drawn. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Frame rendering error'**
  String get errorFrameRender;

  /// Which animated-QR frame is showing. {type} is labelFrameParity or labelFrameSystematic. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Frame {current} / {total} • {type}'**
  String labelFrameProgress(int current, int total, String type);

  /// Tooltip on the button that pauses the animated QR code. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Pause stream'**
  String get tooltipPauseStream;

  /// Tooltip on the button that resumes the animated QR code. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Resume stream'**
  String get tooltipResumeStream;

  /// Snackbar when sharing the QR image failed. {error} is the technical reason and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not share QR: {error}'**
  String errorCouldNotShareQr(String error);

  /// Line above a contact's QR code. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Scan with any phone camera to add this contact.'**
  String get descScanToAddContact;

  /// Shown in place of the QR code when the contact is too large for one. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This contact has too much detail to fit in a QR code.'**
  String get errorContactTooBigForQr;

  /// Tooltip on the button that opens the animated QR stream carrying the whole contact. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Full-contact QR'**
  String get tooltipAirGapStream;

  /// Button that opens the system share sheet. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// Title of the preview dialog after a contact QR code was scanned and found safe. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Scanned Contact'**
  String get titleScannedContact;

  /// Title of the preview dialog after a scanned contact QR code raised a warning. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Security Check'**
  String get titleSecurityCheck;

  /// Heading above the list of scanned contacts, with how many there are. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'To import ({count}):'**
  String labelContactsToImport(int count);

  /// Shown in place of a contact name that is empty. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Contact'**
  String get labelUnnamedContact;

  /// Row in the scanned-contact preview. {numbers} is a comma-separated list. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Phones: {numbers}'**
  String labelPhonesList(String numbers);

  /// Row in the scanned-contact preview. {emails} is a comma-separated list. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Emails: {emails}'**
  String labelEmailsList(String emails);

  /// Row in the scanned-contact preview. {links} is a comma-separated list. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Web Links: {links}'**
  String labelWebLinksList(String links);

  /// Dialog button that imports the scanned contacts with the risky fields removed. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Import Safe Only'**
  String get actionImportSafeOnly;

  /// Dialog button that imports the scanned contact. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// Dialog button that imports the scanned contacts unchanged, warnings included. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Import All'**
  String get actionImportAll;

  /// Default heading of the single-contact picker. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Choose a contact'**
  String get titleChooseContact;

  /// Shown when the contact list could not be read. {error} is the technical reason and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not load contacts: {error}'**
  String errorCouldNotLoadContacts(String error);

  /// Tooltip on the button that empties a search field. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get tooltipClearSearch;

  /// Empty state of a contact picker that lists only contacts with a phone number. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts with a number yet.'**
  String get emptyNoContactsWithNumber;

  /// Empty state of a contact picker when the book is empty. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet.'**
  String get emptyNoContactsYet;

  /// Empty state of a contact search. {query} is what the user typed. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts match “{query}”.'**
  String emptyNoContactsMatch(String query);

  /// Shown in a list in place of a contact name that is empty. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'(No name)'**
  String get labelNoName;

  /// Empty state of the multi-contact picker search. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get emptyNoContactsFound;

  /// Button that adds the chosen items. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Section heading above suggested contacts in the multi-contact picker. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get labelSuggested;

  /// Section heading above the full list in the multi-contact picker. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'All contacts'**
  String get labelAllContacts;

  /// Subtitle on a contact that is already in the group or tag being edited. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Already added'**
  String get labelAlreadyAdded;

  /// Default tooltip on the microphone button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Voice search'**
  String get tooltipVoiceSearch;

  /// Snackbar when speech recognition could not start. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Voice input is not available — check the microphone permission.'**
  String get errorVoiceUnavailable;

  /// Tooltip on the microphone button while it is listening. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get tooltipStopListening;

  /// Title of the card that shows whether this app is the phone's default dialer. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Default phone app'**
  String get labelDefaultPhoneApp;

  /// Subtitle of the default-phone-app card when this app is the default. SreerajP Contacts Sphere is the app name and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'SreerajP Contacts Sphere handles your calls'**
  String get descHandlesYourCalls;

  /// Subtitle of the default-phone-app card when this app is not the default. SreerajP Contacts Sphere is the app name and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Set SreerajP Contacts Sphere as your default dialer'**
  String get descSetAsDefaultDialer;

  /// Snackbar when the phone-call permission was refused. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Call permission denied'**
  String get errorCallPermissionDenied;

  /// Snackbar when a call could not be started. {error} is the technical reason and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not place call: {error}'**
  String errorCouldNotPlaceCall(String error);

  /// Note under the SIM that would be used without asking, in the SIM chooser. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Usual SIM'**
  String get labelUsualSimForCall;

  /// Heading of the SIM chooser shown before a call. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Call with'**
  String get titleCallWith;

  /// Subheading of the SIM chooser. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Choose the SIM for this call'**
  String get descChooseSimForCall;

  /// Heading of the number chooser for a contact with several numbers. {name} is the contact's name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Call {name}'**
  String titleCallName(String name);

  /// Subheading of the number chooser. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Choose a number'**
  String get descChooseNumber;

  /// Confirmation dialog button. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// Confirmation dialog button. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// Tooltip on the gear icon that opens Settings. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltipSettings;

  /// Day heading in a date-grouped list. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get labelToday;

  /// Day heading in a date-grouped list. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get labelYesterday;

  /// Short call length under a minute, e.g. 42s. Abbreviated on purpose; it sits in a crowded row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String labelDurationSeconds(int seconds);

  /// Short call length in whole minutes, e.g. 3m. Abbreviated on purpose. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String labelDurationMinutes(int minutes);

  /// Short call length in minutes and seconds, e.g. 3m 5s. Abbreviated on purpose. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String labelDurationMinutesSeconds(int minutes, int seconds);

  /// Recents row status: an incoming call nobody answered. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get labelOutcomeMissed;

  /// Recents row status: an outgoing call nobody answered. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get labelOutcomeNoAnswer;

  /// Recents row status: the other line was busy. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get labelOutcomeBusy;

  /// Recents row status: the call was turned down. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get labelOutcomeDeclined;

  /// Recents row status: the caller hung up before an answer. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get labelOutcomeCancelled;

  /// Recents row status: the call could not be placed. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get labelOutcomeFailed;

  /// Recents row status: the call was rejected because the number is blocked. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get labelBlocked;

  /// Title of the dialog confirming that all call history will be removed. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Clear call history?'**
  String get titleClearCallHistory;

  /// Body of the clear-history dialog. SreerajP Contacts Sphere is the app name and stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This removes all logged calls from SreerajP Contacts Sphere.'**
  String get descClearCallHistory;

  /// Tooltip on the icon that clears all call history. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get tooltipClearHistory;

  /// Hint inside the Recents search field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Search calls'**
  String get hintSearchCalls;

  /// Empty state of Recents. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No calls yet. Calls you place show up here.'**
  String get emptyNoCallsYet;

  /// Empty state of a Recents search. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No calls match that search.'**
  String get emptyNoCallsMatch;

  /// Tooltip on the phone icon at the end of a Recents row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Call back'**
  String get tooltipCallBack;

  /// Menu item that blocks the row's phone number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Block number'**
  String get actionBlockNumber;

  /// Menu item that unblocks the row's phone number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Unblock number'**
  String get actionUnblockNumber;

  /// Menu item that flags the row's number as spam. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Mark as spam'**
  String get actionMarkAsSpam;

  /// Menu item that removes the spam flag from the row's number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Not spam'**
  String get actionNotSpam;

  /// Menu item that opens the Smart Redial & Reach Me sheet. Feature name. UI chrome. The English is 23 characters; it is a feature name and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Smart Redial & Reach Me'**
  String get actionSmartRedialReachMe;

  /// Menu item that copies the phone number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Copy number'**
  String get actionCopyNumber;

  /// Menu item that shares the phone number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Share number'**
  String get actionShareNumber;

  /// Menu item that deletes one Recents row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Remove from history'**
  String get actionRemoveFromHistory;

  /// Snackbar after a number was blocked. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{number} blocked — it can no longer ring you'**
  String msgNumberBlocked(String number);

  /// Snackbar after a number was flagged as spam. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{number} marked as spam'**
  String msgMarkedAsSpam(String number);

  /// Snackbar after the spam flag was removed. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{number} is no longer marked as spam'**
  String msgNoLongerSpam(String number);

  /// Snackbar after a number was copied. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Copied {number} to clipboard'**
  String msgCopiedNumber(String number);

  /// Snackbar after a speed-dial key was assigned. {slot} is the key digit; {name} is the contact. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Key {slot} now calls {name}'**
  String msgSpeedDialAssigned(String slot, String name);

  /// Snackbar while a call is being placed. {name} is the contact's name or the number. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}…'**
  String msgCallingName(String name);

  /// Button and tooltip that hides the in-call keypad. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Hide keypad'**
  String get actionHideKeypad;

  /// Tooltip on a back arrow. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tooltipBack;

  /// Title of the keypad shown during a call to send touch tones. DTMF stays in Latin letters. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Keypad (DTMF)'**
  String get titleKeypadDtmf;

  /// Title of the dialer when it is picking a second number to add to a live call. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add call'**
  String get titleAddCall;

  /// Tooltip on the three-dot overflow menu. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tooltipMore;

  /// Menu item and screen title for Settings. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// Hint in the dialer's number field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Start typing to find a contact'**
  String get hintStartTypingToFind;

  /// Tooltip on the dialer's microphone button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Voice dialing'**
  String get tooltipVoiceDialing;

  /// Heading above the contacts that match the typed number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match} other{{count} matches}}'**
  String labelMatchCount(int count);

  /// Shown under the typed number when no contact has it. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No saved contact for this number yet.'**
  String get emptyNoContactForNumber;

  /// Shown when a spoken name matched no contact. {query} is what was heard. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contact matches “{query}”.'**
  String emptyNoVoiceMatch(String query);

  /// Heading above contacts matching a spoken name. {query} is what was heard. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Heard “{query}”'**
  String labelHeardQuery(String query);

  /// Empty state of the dialer when there are no favorites or top contacts. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Star a contact to see it here'**
  String get emptyStarContact;

  /// Section heading for starred contacts. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get labelFavorites;

  /// Section heading for suggested contacts picked from relationships. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Family & friends'**
  String get labelFamilyFriends;

  /// Section heading for contacts most likely to pick up at this hour. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Likely to answer now'**
  String get labelLikelyToAnswer;

  /// Section heading for the most-called contacts. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Top contacts'**
  String get labelTopContacts;

  /// Card that saves the typed number as a contact. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add to contacts'**
  String get actionAddToContacts;

  /// Tooltip on a phone icon button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get tooltipCall;

  /// Tooltip on the dialer's delete key; it also tells the user that holding it keeps deleting. UI chrome. The English explains a gesture and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Backspace (hold to delete continuously)'**
  String get tooltipBackspace;

  /// Shown in place of a caller's name when there is neither a name nor a number. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get labelUnknownCaller;

  /// In-call status while the phone rings. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Incoming call'**
  String get labelIncomingCall;

  /// In-call status while an outgoing call connects. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Calling…'**
  String get labelCalling;

  /// In-call status while the call is on hold. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get labelOnHold;

  /// In-call status after hang-up. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Call ended'**
  String get labelCallEnded;

  /// In-call status in the moment before the call timer starts. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get labelConnected;

  /// Name shown for the other call on hold when its number is hidden. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Second call'**
  String get labelSecondCall;

  /// Tooltip on the held-call chip, which swaps the two calls. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Tap to switch call'**
  String get tooltipTapToSwitchCall;

  /// Chip for the other call on hold. {name} is its contact name or number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{name} — on hold'**
  String labelNameOnHold(String name);

  /// Heading of the caller-context card on an outgoing call. English is capitals by design; never use capitals in Malayalam or Sanskrit. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'ABOUT THIS CONTACT'**
  String get labelAboutThisContact;

  /// Heading of the caller-context card on an incoming call. English is capitals by design; never use capitals in Malayalam or Sanskrit. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'WHY THEY ARE CALLING'**
  String get labelWhyCalling;

  /// Warning chip when the network could not verify the caller's number. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Caller ID not verified'**
  String get labelCallerIdNotVerified;

  /// In-call button that declines with a text message. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get labelReply;

  /// In-call toggle for the microphone. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get labelMute;

  /// In-call toggle that puts the call on hold. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get labelHold;

  /// In-call toggle for the loudspeaker. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get labelSpeaker;

  /// In-call button that opens the touch-tone keypad. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Keypad'**
  String get labelKeypad;

  /// In-call button that joins two calls into a conference. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get labelMerge;

  /// In-call button that switches between two calls. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get labelSwap;

  /// In-call screen title (and call notification title) when two or more calls are merged into one conference. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Conference call'**
  String get labelConferenceCall;

  /// How many people are in the merged conference call, under its title. The =1 form is used instead of 'one' because intl has no plural rules for Sanskrit. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String labelConferencePeople(int count);

  /// In-call button that opens the list of people in a conference call. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get labelManage;

  /// Title of the sheet listing the people in a conference call. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'People on this call'**
  String get titlePeopleOnCall;

  /// Button in the conference list: talk to this one person alone while the others wait on hold. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get actionPrivate;

  /// Button in the conference list: remove this one person from the conference call. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get actionDrop;

  /// Tooltip for the Private button in the conference list. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Talk to them alone'**
  String get tooltipPrivateTalk;

  /// Tooltip for the Drop button in the conference list. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Remove from call'**
  String get tooltipDropFromCall;

  /// In-call button that opens the block-number dialog. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get labelBlock;

  /// Title of the dialog confirming an unblock. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Unblock this number?'**
  String get titleUnblockThisNumber;

  /// Title of the dialog confirming a block. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Block this number?'**
  String get titleBlockThisNumber;

  /// Body of the unblock dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Calls from {number} will ring normally again.'**
  String descUnblockNumber(String number);

  /// First sentence of the block dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Future calls from {number} will be rejected before your phone rings.'**
  String descBlockNumberFuture(String number);

  /// Added to the block dialog body when a call is in progress. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This call will be disconnected immediately.'**
  String get descCallWillDisconnect;

  /// Last paragraph of the block dialog. The path names the Settings screens; keep them the same as those screens' titles. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'You can manage blocked numbers in Settings → Contacts → Blocked numbers.'**
  String get descManageBlockedNumbers;

  /// Dialog button that removes a number from the blocked list. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get actionUnblock;

  /// Heading of the quick-reply sheet on an incoming call. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Reply with a message'**
  String get titleReplyWithMessage;

  /// Subheading of the quick-reply sheet. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Declines the call and texts the caller'**
  String get descDeclinesAndTexts;

  /// Row in the quick-reply sheet that opens a free-text box. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Write your own…'**
  String get actionWriteYourOwn;

  /// Title of the free-text reply dialog. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Reply with…'**
  String get titleReplyWith;

  /// Text field label for a message. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get labelMessage;

  /// Hint in the free-text reply field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Type a message to send'**
  String get hintTypeMessageToSend;

  /// Dialog button that sends. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get actionSend;

  /// Button that hides a panel. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get actionHide;

  /// Snackbar when the contact's ringtone file is gone. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This ringtone is no longer available — pick a new one in Edit.'**
  String get errorRingtoneMissing;

  /// Snackbar when a ringtone preview cannot be heard because ring volume is zero. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Ring volume is muted — turn it up to hear the preview.'**
  String get errorRingVolumeMuted;

  /// Share-sheet row. vCard and .vcf stay in Latin letters. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Share as vCard (.vcf)'**
  String get actionShareVcard;

  /// Subtitle of the vCard share row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Send the contact card to WhatsApp or any app'**
  String get descShareVcard;

  /// Share-sheet row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Share as Text'**
  String get actionShareAsText;

  /// Subtitle of the text share row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Send name & phone numbers as a text message'**
  String get descShareAsText;

  /// Share-sheet row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Copy Name & Phone'**
  String get actionCopyNamePhone;

  /// Subtitle of the copy row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Copy contact details to clipboard'**
  String get descCopyContactDetails;

  /// Share-sheet row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Share as QR code'**
  String get actionShareAsQr;

  /// Subtitle of the QR share row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Show a scannable code or send it as an image'**
  String get descShareAsQr;

  /// Share-sheet row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Share via Bluetooth'**
  String get actionShareViaBluetooth;

  /// Subtitle of the Bluetooth share row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Send directly to a nearby phone'**
  String get descSendToNearbyPhone;

  /// Snackbar when sharing a vCard failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not share contact: {error}'**
  String errorCouldNotShareContact(String error);

  /// Snackbar when sharing as text failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not share text: {error}'**
  String errorCouldNotShareText(String error);

  /// Snackbar after copying name and numbers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Contact details copied to clipboard'**
  String get msgContactDetailsCopied;

  /// Snackbar when copying failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not copy contact details: {error}'**
  String errorCouldNotCopyDetails(String error);

  /// Snackbar when copying a number failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not copy number: {error}'**
  String errorCouldNotCopyNumber(String error);

  /// Snackbar when the contact could not be read. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Failed to load contact: {error}'**
  String errorFailedToLoadContact(String error);

  /// Snackbar when a connected app's action could not be launched. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not open this app.'**
  String get errorCouldNotOpenApp;

  /// Snackbar when starring or unstarring failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorite: {error}'**
  String errorCouldNotUpdateFavorite(String error);

  /// Title of the dialog confirming a contact deletion. {name} is the contact's name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String titleDeleteContactConfirm(String name);

  /// Body of the delete dialog for a contact that is also in the phone's address book. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Removes this contact from the app and the device address book.'**
  String get descDeleteContactAndDevice;

  /// Body of the delete dialog for an app-only contact. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Removes this contact from the app.'**
  String get descDeleteContactApp;

  /// Snackbar when deleting failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String errorDeleteFailed(String error);

  /// App bar title while a contact's name is not known yet. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get labelContact;

  /// Tooltip on the empty star icon. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get tooltipAddToFavorites;

  /// Tooltip on the filled star icon. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get tooltipRemoveFromFavorites;

  /// Button or tooltip that opens the edit form. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Button or tooltip that removes an item. Shared across screens. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// Shown when the contact no longer exists. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Contact not found'**
  String get emptyContactNotFound;

  /// Contact field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get labelBirthday;

  /// Contact field name: wedding anniversary. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get labelAnniversary;

  /// Contact field name: the yearly date the user first met this person. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Meetiversary'**
  String get labelMeetiversary;

  /// Contact field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get labelGender;

  /// Contact field name: the full formal name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Formal name'**
  String get labelFormalName;

  /// Contact field name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get labelBloodGroup;

  /// Shown when a contact's ringtone has no name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Custom ringtone'**
  String get labelCustomRingtone;

  /// Contact field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get labelRingtone;

  /// Tooltip that stops playback. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get tooltipStop;

  /// Tooltip that plays a ringtone preview. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get tooltipPreview;

  /// Shown when the contact's preferred SIM has no name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Chosen SIM'**
  String get labelChosenSim;

  /// Subtitle under the contact's preferred SIM. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Calls go out on this SIM'**
  String get descCallsGoOutOnSim;

  /// Heading above the full-screen image shown while this contact calls. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Calling card'**
  String get labelCallingCard;

  /// Section heading. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get labelRelationships;

  /// Tooltip on the button that opens the relationship graph. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'View sphere'**
  String get tooltipViewSphere;

  /// Tooltip on the link button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add relationship'**
  String get tooltipAddRelationship;

  /// Empty state of the relationships section. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No relationships yet. Tap the link icon to connect a contact.'**
  String get emptyNoRelationships;

  /// Tooltip on the button that changes a relationship's type. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Edit type'**
  String get tooltipEditType;

  /// Heading of the card listing other apps that know this contact. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Connected apps'**
  String get labelConnectedApps;

  /// Line in the before-you-call card. Keep the cake emoji. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'🎂 Birthday coming up within a week'**
  String get descBirthdayComingUp;

  /// Line in the before-you-call card. {duration} is already formatted, e.g. 42s. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Last call: {duration}'**
  String descLastCall(String duration);

  /// Line in the before-you-call card with the clock time where the contact is. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Their time: {time}'**
  String descTheirTime(String time);

  /// Line in the before-you-call card. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recent interaction} other{{count} recent interactions}}'**
  String descRecentInteractions(int count);

  /// Heading of the before-you-call summary card. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Before you call'**
  String get labelBeforeYouCall;

  /// Banner line for a temporary contact that deletes itself after one call. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Auto-deletes after 1 call ({count}/1 calls logged)'**
  String descEphemeralAutoDelete(int count);

  /// Banner line for a temporary contact whose time has run out. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Expired — self-destructing soon...'**
  String get descEphemeralExpired;

  /// Banner countdown for a temporary contact. The three values arrive zero-padded. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Self-destructs in: {hours}h {minutes}m {seconds}s'**
  String descEphemeralCountdown(String hours, String minutes, String seconds);

  /// Banner title for a contact that deletes itself. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Ephemeral Contact'**
  String get labelEphemeralContact;

  /// Badge saying the temporary contact lives only in the encrypted local database. SQLCipher is a product name and stays in Latin letters. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'SQLCipher Local Only'**
  String get labelSqlcipherLocalOnly;

  /// Button that extends a temporary contact by a day. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'+24 Hours'**
  String get actionAdd24Hours;

  /// Button that turns a temporary contact into a normal one. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Keep Permanently'**
  String get actionKeepPermanently;

  /// Button that deletes a temporary contact right away. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Scrub Now'**
  String get actionScrubNow;

  /// Snackbar when the user cancels the fingerprint or PIN check for secret contacts. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authentication required to view secret contacts'**
  String get errorAuthRequiredSecret;

  /// Snackbar after one contact was deleted. {name} is the contact's name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String msgDeletedName(String name);

  /// Title of the dialog confirming a bulk delete. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 contact?} other{Delete {count} contacts?}}'**
  String titleDeleteContactsCount(int count);

  /// Body of the bulk delete dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Removes them from the app, and from the device address book where they are linked.'**
  String get descDeleteSelected;

  /// Snackbar after a bulk delete. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Deleted 1 contact} other{Deleted {count} contacts}}'**
  String msgDeletedCount(int count);

  /// Snackbar after a bulk delete where some rows could not be deleted. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Deleted {deleted} contacts, {failed} failed'**
  String msgDeletedCountFailed(int deleted, int failed);

  /// Snackbar when calling a contact with no number. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No phone number for {name}'**
  String errorNoPhoneFor(String name);

  /// Snackbar when emailing a contact with no email. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No email address for {name}'**
  String errorNoEmailFor(String name);

  /// Snackbar when no mail app is installed. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No email app available'**
  String get errorNoEmailApp;

  /// Snackbar when opening the mail app failed. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not open the email app'**
  String get errorCouldNotOpenEmail;

  /// Menu item and sheet title for importing and exporting contacts. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get titleImportExport;

  /// Sheet row. CSV stays in Latin letters. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get actionImportCsv;

  /// Sheet row. CSV stays in Latin letters. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get actionExportCsv;

  /// Sheet row. vCard and .vcf stay in Latin letters. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Import vCard (.vcf)'**
  String get actionImportVcf;

  /// Sheet row. vCard and .vcf stay in Latin letters. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Export vCard (.vcf)'**
  String get actionExportVcf;

  /// Menu item and sheet title for Bluetooth send and receive. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth transfer'**
  String get titleBluetoothTransfer;

  /// Sheet row that sends every contact over Bluetooth. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Send all via Bluetooth'**
  String get actionSendAllViaBluetooth;

  /// Snackbar after an import. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 contact} other{Imported {count} contacts}}'**
  String msgImportedCount(int count);

  /// Snackbar after an import that found nothing. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Nothing imported'**
  String get msgNothingImported;

  /// Snackbar when an import failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String errorImportFailed(String error);

  /// Snackbar when an export failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String errorExportFailed(String error);

  /// Snackbar when the book is empty. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts to send'**
  String get errorNoContactsToSend;

  /// Snackbar when the send-all dialog could not open. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not start Bluetooth sharing: {error}'**
  String errorCouldNotStartBleShareDetail(String error);

  /// Tooltip on the lock icon that shows or hides secret contacts. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Secret contacts'**
  String get tooltipSecretContacts;

  /// Tooltip on the heart icon that opens the relationship health screen. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Relation status'**
  String get tooltipRelationStatus;

  /// Tooltip on the groups icon. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get tooltipGroups;

  /// Menu item that opens the phone owner's own contact card. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get actionMyProfile;

  /// Menu item. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get actionScanQrCode;

  /// Menu item. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Scan business card'**
  String get actionScanBusinessCard;

  /// Menu item that opens the duplicate finder. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Find Duplicates'**
  String get actionFindDuplicates;

  /// Tooltip on the close icon in multi-select mode. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get tooltipCancelSelection;

  /// Header in multi-select mode. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String labelSelectedCount(int count);

  /// Tooltip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get tooltipSelectAll;

  /// Tooltip on the bulk delete icon. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get tooltipDeleteSelected;

  /// Filter chip that shows every contact. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get labelAll;

  /// Progress line while phone contacts are merged in. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Syncing contacts… {processed} of {total}'**
  String msgSyncingContacts(int processed, int total);

  /// Progress line while the phone's address book is read. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Reading device contacts…'**
  String get msgReadingDeviceContacts;

  /// Empty state of the Favorites filter. Keep the line break. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.\nStar a contact to see it here.'**
  String get emptyNoFavorites;

  /// Empty state of the contact list. Keep the + sign. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet. Tap + to add one.'**
  String get emptyNoContactsTapPlus;

  /// Badge on a temporary contact that deletes itself after one call. Keep the timer emoji. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'⏱️ 1-Call'**
  String get labelOneCallBadge;

  /// Badge on a temporary contact. Keep the timer emoji. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Ephemeral'**
  String get labelEphemeralBadge;

  /// Badge on the phone owner's own card. English is capitals by design; never use capitals in Malayalam or Sanskrit. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get labelYou;

  /// Quick action that opens a contact's page. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get labelProfile;

  /// Last-contact time, 2 to 6 days ago. Abbreviated in English on purpose. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String labelDaysAgo(int count);

  /// Last-contact time in weeks. Abbreviated in English on purpose. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String labelWeeksAgo(int count);

  /// Last-contact time in months. Abbreviated in English on purpose. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count}mo ago'**
  String labelMonthsAgo(int count);

  /// Last-contact time in years. Abbreviated in English on purpose. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count}y ago'**
  String labelYearsAgo(int count);

  /// Phone label preset. The saved value stays the English word; only the shown label is translated. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get labelTypeMobile;

  /// Phone or email label preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get labelTypeHome;

  /// Phone or email label preset: the work number or address. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get labelTypeWork;

  /// Phone label preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get labelTypeMain;

  /// Phone label preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Fax'**
  String get labelTypeFax;

  /// Phone or email label preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelTypeOther;

  /// Email label preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get labelTypePersonal;

  /// Email label preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get labelTypeSchool;

  /// Social link label preset. The saved value stays the English word; brand names such as LinkedIn are never translated. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get labelTypeWebsite;

  /// Gender preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get labelGenderMale;

  /// Gender preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get labelGenderFemale;

  /// Gender preset. The saved value stays the English word. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get labelGenderNonBinary;

  /// Gender preset. The saved value stays the English word. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get labelGenderPreferNotToSay;

  /// Heading of the home address section, and the label for a saved address of type 'personal'. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Personal address'**
  String get labelAddressPersonal;

  /// Heading of the work address section, and the label for a saved address of type 'official'. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Work address'**
  String get labelAddressOfficial;

  /// Snackbar when choosing a photo failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not pick image: {error}'**
  String errorCouldNotPickImage(String error);

  /// Snackbar when choosing the calling-card image failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not pick calling card: {error}'**
  String errorCouldNotPickCard(String error);

  /// Sheet row that opens the camera. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get actionTakePhoto;

  /// Sheet row that opens the photo gallery. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get actionChooseFromGallery;

  /// Snackbar when the camera permission was refused. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is needed to take a photo.'**
  String get errorCameraPermission;

  /// Snackbar when choosing a ringtone failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not pick ringtone: {error}'**
  String errorCouldNotPickRingtone(String error);

  /// Sheet row that opens the phone's ringtone list. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Phone ringtones'**
  String get titlePhoneRingtones;

  /// Subtitle of the phone ringtones row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Choose from the ringtones on this device'**
  String get descPhoneRingtones;

  /// Sheet row that opens a file picker for a ringtone. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Audio file'**
  String get titleAudioFile;

  /// Subtitle of the audio file row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Pick an audio file from your folders'**
  String get descAudioFile;

  /// Snackbar when the picked ringtone file is gone and the form falls back to the default tone. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This ringtone is no longer available — reverting to default.'**
  String get errorRingtoneRevert;

  /// Title of the dialog confirming a phone row removal. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Remove phone?'**
  String get titleRemovePhone;

  /// Body of the phone removal dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This phone will be removed from the contact.'**
  String get descRemovePhone;

  /// Title of the dialog confirming an email row removal. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Remove email?'**
  String get titleRemoveEmail;

  /// Body of the email removal dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This email will be removed from the contact.'**
  String get descRemoveEmail;

  /// Title of the dialog confirming a social link removal. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Remove social link?'**
  String get titleRemoveSocialLink;

  /// Body of the social link removal dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This social link will be removed from the contact.'**
  String get descRemoveSocialLink;

  /// Snackbar when saving without a first name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get errorFirstNameRequired;

  /// Snackbar when saving with a phone number that cannot be right. {reason} is one of the errorPhone… messages. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number: {number} ({reason})'**
  String errorInvalidPhoneNumber(String number, String reason);

  /// Phone validation message. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Empty number'**
  String get errorPhoneEmpty;

  /// Phone validation message. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Number is too short'**
  String get errorPhoneTooShort;

  /// Phone validation message. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Number is too long'**
  String get errorPhoneTooLong;

  /// Phone validation message. {code} is the country dialling code. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Invalid number format for +{code}'**
  String errorPhoneInvalidFormatFor(String code);

  /// Phone validation message. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Invalid number format'**
  String get errorPhoneInvalidFormat;

  /// Snackbar when saving failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String errorSaveFailed(String error);

  /// Form section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers'**
  String get labelPhoneNumbers;

  /// Button that adds another phone row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add phone'**
  String get actionAddPhone;

  /// Form section heading. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Emails'**
  String get labelEmails;

  /// Button that adds another email row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add email'**
  String get actionAddEmail;

  /// Form section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Social links'**
  String get labelSocialLinks;

  /// Hint inside a social link field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'URL or @handle'**
  String get hintUrlOrHandle;

  /// Button that adds another social link row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add social link'**
  String get actionAddSocialLink;

  /// Form title when editing the phone owner's own card. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Edit me'**
  String get titleEditMe;

  /// Form title when creating the phone owner's own card. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add me'**
  String get titleAddMe;

  /// Form title when editing a contact. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get titleEditContact;

  /// Form title when creating a contact. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get titleAddContact;

  /// Link under the avatar. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get actionChangePhoto;

  /// Link under the empty avatar. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get actionAddPhoto;

  /// Field label: Mr, Ms, Dr and so on. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Salutation'**
  String get labelSalutation;

  /// Hint in the salutation field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Mr / Ms / Dr'**
  String get hintSalutation;

  /// Field label; the star marks it as required. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'First name *'**
  String get labelFirstNameRequired;

  /// Hint in the first name field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get hintEnterFirstName;

  /// Field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Middle name'**
  String get labelMiddleName;

  /// Field label: the surname. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get labelLastName;

  /// Hint in an optional field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get hintOptional;

  /// Hint in the formal name field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'How the contact is formally addressed'**
  String get hintFormalName;

  /// Form section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get labelPersonalDetails;

  /// Field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get labelDateOfBirth;

  /// Field label for the yearly date the user first met this person. UI chrome. The English is 30 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Meetiversary · the day you met'**
  String get labelMeetiversaryDayYouMet;

  /// Form section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Preferred SIM'**
  String get labelPreferredSim;

  /// Explainer under the preferred SIM heading. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Which SIM to call this person on. Leave it on Default to use your usual SIM.'**
  String get descPreferredSim;

  /// Subtitle of the Default SIM option. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Use the SIM set in Settings'**
  String get descUseSimInSettings;

  /// Subtitle of a SIM option whose slot number is unknown. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'On this phone'**
  String get labelOnThisPhone;

  /// Shown when a ringtone is set but has no name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get labelSelected;

  /// Shown when no ringtone is set. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get labelNone;

  /// Placeholder that opens the calling-card image picker. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add calling card'**
  String get actionAddCallingCard;

  /// Explainer under the calling-card placeholder. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Photo shown full-screen during calls'**
  String get descCallingCardShown;

  /// Placeholder in a picker that has no value yet. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get labelSelect;

  /// Chip that clears the chosen value. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Hint in the free-text gender field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Describe'**
  String get hintDescribe;

  /// Hint in a free-text label field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get hintCustom;

  /// Chip that switches a label to free text. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'+ Custom'**
  String get actionCustomLabel;

  /// Field label in the tags section. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get labelAddTag;

  /// Hint in the add-tag field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Type and press enter'**
  String get hintTypeAndEnter;

  /// Suggested tag. Tags are the user's own text, so the suggestion is saved in the language it is shown in. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get labelTagSuggestVip;

  /// Suggested tag. Saved in the language it is shown in. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Mentor'**
  String get labelTagSuggestMentor;

  /// Suggested tag. Saved in the language it is shown in. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get labelTagSuggestClient;

  /// Suggested tag. Saved in the language it is shown in. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Investor'**
  String get labelTagSuggestInvestor;

  /// Suggested tag. Saved in the language it is shown in. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Neighbor'**
  String get labelTagSuggestNeighbor;

  /// Form section heading and field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add to group'**
  String get labelAddToGroup;

  /// Hint in the add-to-group field. Keep the * sign. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Type to search, * for all, or add new'**
  String get hintGroupSearch;

  /// Empty state of the relationships section in the form. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Link this contact to people they know.'**
  String get descLinkToPeople;

  /// Button that adds another address card. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get actionAddAddress;

  /// Heading of an address card. English is capitals by design; never use capitals in Malayalam or Sanskrit. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'ADDRESS {index}'**
  String labelAddressNumber(int index);

  /// Hint in the street field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'House no, street'**
  String get hintStreet;

  /// Address field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'City / Town'**
  String get labelCityTown;

  /// Work address field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get labelCompanyName;

  /// Hint in the company name field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Where they work'**
  String get hintWhereTheyWork;

  /// Work address field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Office / Street'**
  String get labelOfficeStreet;

  /// Hint in the office street field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Building, street'**
  String get hintBuildingStreet;

  /// Form section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Official details'**
  String get labelOfficialDetails;

  /// Hint in the designation field: the job title. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get hintJobTitle;

  /// Field label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get labelDepartment;

  /// Hint in the department field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get hintTeam;

  /// Switch label for a contact that deletes itself. Keep the timer emoji. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Ephemeral contact'**
  String get labelEphemeralToggle;

  /// Subtitle of the ephemeral switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Temporary entry. Self-destructs automatically.'**
  String get descEphemeralToggle;

  /// Heading above the expiry choices. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Expiry options'**
  String get labelExpiryOptions;

  /// Expiry choice. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'2 Hours'**
  String get labelExpiry2Hours;

  /// Expiry choice. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'24 Hours'**
  String get labelExpiry24Hours;

  /// Expiry choice. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get labelExpiry7Days;

  /// Expiry choice. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Auto-delete after 1 call'**
  String get labelExpiryAfterOneCall;

  /// Explainer under the expiry choices. SQLCipher and Google stay in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Stored exclusively in local SQLCipher DB. Never synced to Google or phone contacts.'**
  String get descEphemeralStorage;

  /// Switch label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Secret contact'**
  String get labelSecretContact;

  /// Subtitle of the secret contact switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Hidden behind authentication'**
  String get descHiddenBehindAuth;

  /// Title of the country code picker. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Select country code'**
  String get titleSelectCountryCode;

  /// Hint in the country search field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Search country or code'**
  String get hintSearchCountry;

  /// Empty state of the country search. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No countries match “{query}”'**
  String emptyNoCountriesMatch(String query);

  /// Settings row and screen title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get titleSecurity;

  /// Subtitle of the Security row in Settings. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'App lock, block screenshots and audit log'**
  String get descSecurityCard;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Speed Dial'**
  String get titleSpeedDial;

  /// Subtitle of the Speed Dial row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Hold a keypad key 1-9 to call a saved person'**
  String get descSpeedDialCard;

  /// Subtitle of the Contacts row in Settings. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Your profile and contact options'**
  String get descContactsCard;

  /// Settings row. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Sync to Another Device'**
  String get titleSyncToAnotherDevice;

  /// Subtitle of the device sync row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Send or receive contacts over Wi-Fi'**
  String get descSyncCard;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Online Provider Sync'**
  String get titleOnlineProviderSync;

  /// Subtitle of the online sync row. Brand names stay in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Direct 2-way sync with Google, Microsoft & CardDAV'**
  String get descOnlineSyncCard;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get titleBackupRestore;

  /// Subtitle of the backup row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Save all your data to a file, or restore it'**
  String get descBackupCard;

  /// Settings row and screen title. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Cloud Backup'**
  String get titleEncryptedCloudBackup;

  /// Subtitle of the cloud backup row. .csbak and service names stay in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Save .csbak backup to Google Drive, OneDrive or WebDAV'**
  String get descCloudBackupCard;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'SIM & calling'**
  String get titleSimCalling;

  /// Subtitle of the SIM row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Default SIM, caller identification and spam filtering'**
  String get descSimCard;

  /// Subtitle of the Ringtone row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Volume, vibration and per-SIM ringtones'**
  String get descRingtoneCard;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Emergency info'**
  String get titleEmergencyInfo;

  /// Subtitle of the Emergency info row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A card a helper can read on your lock screen'**
  String get descEmergencyCard;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Default country'**
  String get titleDefaultCountry;

  /// Subtitle of the Default country row. {country} is the country name and dialling code, e.g. India (+91). Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{country} · used to identify callers'**
  String descCountrySubtitle(String country);

  /// Settings row and screen title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get titleAppearance;

  /// Subtitle of the Appearance row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Theme mode and accent color'**
  String get descAppearanceCard;

  /// Settings row and screen title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get titleFeatures;

  /// Subtitle of the Features row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Explore all features of SreerajP Contacts Sphere'**
  String get descFeaturesCard;

  /// Settings row and screen title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get titlePermissions;

  /// Subtitle of the Permissions row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'What the app can access and why'**
  String get descPermissionsCard;

  /// Settings row and screen title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get titleHelp;

  /// Subtitle of the Help row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'How features like sync work'**
  String get descHelpCard;

  /// Settings row and screen title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get titleAbout;

  /// Subtitle of the About row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Version, author and build details'**
  String get descAboutCard;

  /// Reason shown in the phone's fingerprint or screen-lock prompt. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to sync your data'**
  String get descAuthReasonSync;

  /// Snackbar when the fingerprint or PIN check for sync was cancelled. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authentication required to sync your data'**
  String get errorAuthRequiredSync;

  /// Title of the warning dialog on a phone with no screen lock. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'No screen lock'**
  String get titleNoScreenLock;

  /// Body of the no-screen-lock warning before sync. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Your device has no screen lock, so synced data can\'t be protected by authentication. This may include secret contacts. Continue anyway?'**
  String get descNoLockSync;

  /// Reason shown in the phone's fingerprint or screen-lock prompt. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to back up or restore your data'**
  String get descAuthReasonBackup;

  /// Snackbar when the fingerprint or PIN check for backup was cancelled. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authentication required to back up or restore'**
  String get errorAuthRequiredBackup;

  /// Body of the no-screen-lock warning before backup. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Your device has no screen lock, so a backup can\'t be protected by authentication. A backup may include secret contacts. Continue anyway?'**
  String get descNoLockBackup;

  /// Settings row and chooser title for what the dialer shows before typing. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Dialer top contacts'**
  String get titleDialerTopContacts;

  /// Dialer top-contacts choice. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get labelMostRecent;

  /// Explains the Family & friends choice. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Contacts you’ve linked as relations'**
  String get descTopRelations;

  /// Explains the Likely to answer choice. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Ordered by who usually answers at this time of day'**
  String get descTopLikely;

  /// Explains the Most recent choice. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Most contacted, then most recent calls'**
  String get descTopRecent;

  /// Settings row and chooser title for the second script on the keypad keys. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Dialpad script layout'**
  String get titleDialpadScriptLayout;

  /// Keypad script choice that follows the phone's language. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Auto (Device locale)'**
  String get labelScriptAuto;

  /// Keypad script choice. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Malayalam (മലയാളം)'**
  String get labelScriptMalayalam;

  /// Keypad script choice. UI chrome. The English is 29 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Devanagari (Sanskrit / Hindi)'**
  String get labelScriptDevanagari;

  /// Keypad script choice. UI chrome. The English is 30 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Cyrillic (Russian / Ukrainian)'**
  String get labelScriptCyrillic;

  /// Keypad script choice. Keep the Arabic endonym. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Arabic (العربية)'**
  String get labelScriptArabic;

  /// Keypad script choice. Keep the Greek endonym. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Greek (Ελληνικά)'**
  String get labelScriptGreek;

  /// Keypad script choice with no second script. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'English only'**
  String get labelScriptNone;

  /// Explains the Auto keypad script choice. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Follows your device language / locale'**
  String get descScriptAuto;

  /// Explains the Malayalam keypad script choice. Keep the sample letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Dual English + Malayalam script layout (ക-ങ)'**
  String get descScriptMalayalam;

  /// Explains the Devanagari keypad script choice. Keep the sample letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Dual English + Devanagari script layout (क-ङ)'**
  String get descScriptDevanagari;

  /// Explains the Cyrillic keypad script choice. Keep the sample letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Dual English + Cyrillic script layout (АБВГ)'**
  String get descScriptCyrillic;

  /// Explains the Arabic keypad script choice. Keep the sample letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Dual English + Arabic script layout (ا ب ت ث)'**
  String get descScriptArabic;

  /// Explains the Greek keypad script choice. Keep the sample letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Dual English + Greek script layout (ΑΒΓ)'**
  String get descScriptGreek;

  /// Explains the English-only keypad choice. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Standard English letters only (A-Z)'**
  String get descScriptNone;

  /// Screen title for device contact and call-log sync. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get titleSync;

  /// Heading of the sheet that picks which phone account receives the app's contacts. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Save contacts to'**
  String get labelSaveContactsTo;

  /// Section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Call log'**
  String get labelCallLog;

  /// Snackbar when a sync action threw an error. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get errorSyncFailed;

  /// Card subtitle while its action runs. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get labelWorking;

  /// Snackbar when the contacts permission was refused. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Contacts permission is needed to sync'**
  String get errorContactsPermissionSync;

  /// Sync card title. UI chrome. The English is 26 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Add device contacts to app'**
  String get actionAddDeviceToApp;

  /// Sync card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Pull the phone\'s address book into the app'**
  String get descAddDeviceToApp;

  /// Snackbar after pulling phone contacts in. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Contacts synced — {count} added or updated'**
  String msgContactsSynced(int count);

  /// Snackbar when a sync changed nothing. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Contacts are already up to date'**
  String get msgContactsUpToDate;

  /// Sync card title. UI chrome. The English is 26 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Add app contacts to device'**
  String get actionAddAppToDevice;

  /// Sync card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Copy your app contacts into the phone\'s contacts'**
  String get descAddAppToDevice;

  /// Snackbar when every contact failed to save. {target} is the phone account name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not save to {target} — {failed} failed'**
  String errorCouldNotSaveTo(String target, int failed);

  /// Snackbar when there was nothing to copy. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts to sync to the device'**
  String get msgNoContactsToSyncToDevice;

  /// Snackbar after copying contacts to a phone account. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Saved to {target} — {total} added or updated'**
  String msgSavedTo(String target, int total);

  /// Snackbar after copying contacts where some failed. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Saved to {target} — {total} added or updated ({failed} failed)'**
  String msgSavedToWithFailed(String target, int total, int failed);

  /// Sync card title for the mirror that deletes app contacts missing from the phone. UI chrome. The English is 40 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Add device contacts to app (destructive)'**
  String get actionMirrorDeviceToApp;

  /// Sync card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Make the app match the phone — removes app contacts that are gone from the phone'**
  String get descMirrorDeviceToApp;

  /// Confirm dialog title. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Mirror device to app?'**
  String get titleMirrorDeviceToApp;

  /// Confirm dialog body. "Me" is the phone owner's own contact card. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This imports the phone\'s contacts, then deletes app contacts that came from the phone but are no longer on it.\n\nYour \"Me\" contact, secret contacts, and contacts you created only in the app are never deleted.'**
  String get descMirrorDeviceToAppConfirm;

  /// Confirm button of a mirror dialog. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get actionMirror;

  /// Snackbar after a device-to-app mirror. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Mirrored from device — {removed} removed'**
  String msgMirroredFromDevice(int removed);

  /// Snackbar after a device-to-app mirror that removed nothing. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Mirrored from device — nothing to remove'**
  String get msgMirroredFromDeviceNone;

  /// Sync card title for the mirror that deletes phone contacts missing from the app. UI chrome. The English is 40 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Add app contacts to device (destructive)'**
  String get actionMirrorAppToDevice;

  /// Sync card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Make the phone match the app — removes device contacts that are not in the app'**
  String get descMirrorAppToDevice;

  /// Confirm dialog title. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Mirror app to device?'**
  String get titleMirrorAppToDevice;

  /// Confirm dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This copies your app contacts to the phone, then deletes device contacts that are not in the app.\n\nDevice contacts that match your \"Me\" contact or a secret contact are never deleted.'**
  String get descMirrorAppToDeviceConfirm;

  /// Snackbar after an app-to-device mirror. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Mirrored to {target} — {removed} removed'**
  String msgMirroredTo(String target, int removed);

  /// Snackbar after an app-to-device mirror that removed nothing. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Mirrored to {target} — nothing to remove'**
  String msgMirroredToNone(String target);

  /// Sync card title. UI chrome. The English is 26 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Add device call log to app'**
  String get actionImportCallLog;

  /// Sync card subtitle. 'Recents' is the call history tab (navRecents). Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Import the phone\'s older call history into Recents'**
  String get descImportCallLog;

  /// Snackbar when the call log permission is missing. The quoted name is the Android permission as the phone shows it in that language; Android has no Sanskrit UI, so the Sanskrit keeps the English name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the phone\'s call log — allow the Call logs permission in Android settings'**
  String get errorCouldNotReadCallLog;

  /// Snackbar when a call-log import changed nothing. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Call log is already up to date'**
  String get msgCallLogUpToDate;

  /// Part of an import result, joined with labelCountUpdated. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count} added'**
  String labelCountAdded(int count);

  /// Part of an import result, joined with labelCountAdded. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count} updated'**
  String labelCountUpdated(int count);

  /// Snackbar after a call-log import. {parts} is labelCountAdded and/or labelCountUpdated joined with a comma. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Call log imported — {parts}'**
  String msgCallLogImported(String parts);

  /// Sync card title for replacing the app's call history. UI chrome. The English is 40 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Add device call log to app (destructive)'**
  String get actionReplaceCallLog;

  /// Sync card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Replace Recents with the phone\'s call history'**
  String get descReplaceCallLog;

  /// Confirm dialog title. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Replace call history?'**
  String get titleReplaceCallHistory;

  /// Confirm dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This clears the app\'s call history and rebuilds it from the phone\'s call log. Call notes and feedback saved in the app will be lost.'**
  String get descReplaceCallHistoryConfirm;

  /// Confirm button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get actionReplace;

  /// Snackbar after replacing the call history. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Call log replaced — {count} added'**
  String msgCallLogReplaced(int count);

  /// Settings row. UI chrome. The English is 29 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Contact counts & search index'**
  String get labelContactCountsIndex;

  /// Subtitle of the counts row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'View device/app contact counts and search index status'**
  String get descContactCountsIndex;

  /// Settings row for the phone owner's own contact card. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'My Profile (\"Add Me\")'**
  String get labelMyProfileAddMe;

  /// Subtitle of the My Profile row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Create or edit your own Self contact card'**
  String get descMyProfileAddMe;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Display & formatting'**
  String get labelDisplayFormatting;

  /// Subtitle of the display row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Sort order, name format, and display filters'**
  String get descDisplayFormatting;

  /// Settings row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Device & cloud sync'**
  String get labelDeviceCloudSync;

  /// Subtitle of the sync row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Configure device mirroring and cloud accounts'**
  String get descDeviceCloudSync;

  /// Settings row. UI chrome. The English is 26 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Custom relationship labels'**
  String get labelCustomRelationshipLabels;

  /// Subtitle of the relationship labels row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Manage custom relationship labels for contacts'**
  String get descCustomRelationshipLabels;

  /// Subtitle of the Blocked numbers row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'View and manage numbers blocked from ringing'**
  String get descBlockedNumbersCard;

  /// Settings row. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Secret contacts & export'**
  String get labelSecretContactsExport;

  /// Subtitle of the secret contacts row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Export options and secret contact export controls'**
  String get descSecretContactsExport;

  /// Snackbar after an online account synced. {name} is the account email or name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Synced successfully with {name}'**
  String msgSyncedWith(String name);

  /// Snackbar after a sync with problems. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get msgSyncCompleted;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add Online Account'**
  String get titleAddOnlineAccount;

  /// Field label: the online contacts service. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get labelProvider;

  /// Field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Account Email / Name'**
  String get labelAccountEmailName;

  /// Field label. URL stays in Latin letters. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get labelServerUrl;

  /// Field label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get labelUsername;

  /// Name given to an online account when the user leaves the name blank; it is saved as shown. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get labelAccount;

  /// Explainer at the top of the online sync screen. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Opt-in 2-way contact sync with Google, Microsoft & CardDAV. Zero telemetry, direct API requests only.'**
  String get descOnlineSyncIntro;

  /// Section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Configured Providers'**
  String get labelConfiguredProviders;

  /// Button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get actionAddAccount;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No cloud sync accounts configured.'**
  String get emptyNoCloudAccounts;

  /// Two-line subtitle of an online account row. Keep the line break. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Provider: {provider}\nLast Synced: {when}'**
  String descProviderLastSynced(String provider, String when);

  /// Shown when an account has never synced. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get labelNever;

  /// Tooltip on the sync icon of an account row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get tooltipSyncNow;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'SIM Cards & Accounts'**
  String get labelSimCardsAccounts;

  /// Subtitle of the SIM cards row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Default SIM, ask per call, and SIM colours'**
  String get descSimCardsAccounts;

  /// Settings row and screen title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get labelIdentification;

  /// Subtitle of the Identification row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Caller identification and spam filtering'**
  String get descIdentification;

  /// Settings row. UI chrome. The English is 26 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Spoken caller announcement'**
  String get labelSpokenAnnouncement;

  /// Subtitle of the spoken announcement row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Announce caller\'s name over ringtone'**
  String get descSpokenAnnouncement;

  /// Settings row. UI chrome. The English is 29 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Relationship-tier quiet hours'**
  String get labelTierQuietHours;

  /// Subtitle of the quiet hours row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Silence calls at night except for chosen relationship tiers'**
  String get descTierQuietHours;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Quick replies'**
  String get labelQuickReplies;

  /// Subtitle of the quick replies row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Messages offered when rejecting a call with a text'**
  String get descQuickReplies;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Post-call options'**
  String get labelPostCallOptions;

  /// Subtitle of the post-call row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Configure the post-call feedback sheet'**
  String get descPostCallOptions;

  /// Settings row and screen title for the Smart Redial & Reach Me feature. UI chrome. The English is 25 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Smart Redial & \"Reach Me\"'**
  String get titleSmartRedialReachMe;

  /// Subtitle of the Smart Redial row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Auto-retry and reach-me SMS when calls are unanswered'**
  String get descSmartRedialCard;

  /// Subtitle of the Smart Redial switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Offer 1-tap auto-retry and reach-me SMS when a call is unanswered'**
  String get descSmartRedialIntro;

  /// Settings row and dialog title: how long before an automatic call-back. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Default retry delay'**
  String get labelDefaultRetryDelay;

  /// Settings row and dialog title. UI chrome. The English is 23 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Preset Reach Me message'**
  String get labelPresetReachMe;

  /// Settings row. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Active scheduled redials'**
  String get labelActiveScheduledRedials;

  /// How many automatic call-backs are waiting. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String labelActiveCount(int count);

  /// A delay choice in minutes. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String labelMinutesLong(int count);

  /// Hint in the preset message field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter your preset reach-me message...'**
  String get hintPresetReachMe;

  /// Dialog title listing waiting automatic call-backs. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Active Auto-Redials'**
  String get titleActiveAutoRedials;

  /// Empty state of the waiting call-backs dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No active scheduled redials.'**
  String get emptyNoActiveRedials;

  /// Row in the waiting call-backs dialog. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{number} · in {minutes} min'**
  String labelRedialIn(String number, int minutes);

  /// Snackbar when uploading without a passphrase. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Please enter a backup passphrase'**
  String get errorEnterPassphrase;

  /// Snackbar after an upload. {file} is the backup file name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup uploaded successfully: {file}'**
  String msgBackupUploadedFile(String file);

  /// Snackbar after an upload with no file name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Backup uploaded'**
  String get msgBackupUploaded;

  /// Snackbar when an upload failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String errorUploadFailed(String error);

  /// Explainer at the top of the cloud backup screen. Technical names stay in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Backs up the full app payload (.csbak) encrypted end-to-end with your passphrase via PBKDF2 (300k iters) + AES-GCM-256 to your cloud storage.'**
  String get descCloudBackupIntro;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No cloud storage accounts configured.'**
  String get emptyNoCloudStorage;

  /// Button that opens the online sync screen. UI chrome. The English is 28 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Add Account in Provider Sync'**
  String get actionAddAccountInProviderSync;

  /// Field label: which account receives the backup. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Target Cloud Account'**
  String get labelTargetCloudAccount;

  /// Field label. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Encryption Passphrase'**
  String get labelEncryptionPassphrase;

  /// Hint in the passphrase field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter passphrase for .csbak encryption'**
  String get hintPassphrase;

  /// Button. UI chrome. The English is 27 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Upload Encrypted Backup Now'**
  String get actionUploadBackupNow;

  /// Section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Remote Cloud Backups'**
  String get labelRemoteCloudBackups;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No cloud backups found for this account.'**
  String get emptyNoCloudBackups;

  /// Subtitle of a cloud backup row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Size: {bytes} bytes | Date: {date}'**
  String descBackupSizeDate(int bytes, String date);

  /// Switch label. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Caller identification'**
  String get labelCallerIdentification;

  /// Subtitle of the caller identification switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Label callers who aren’t in your contacts — telemarketing and service numbers, numbers you marked as spam'**
  String get descCallerIdentification;

  /// Switch label. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Filter suspected spam'**
  String get labelFilterSuspectedSpam;

  /// Subtitle of the spam filter switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Suspected spam calls ring silently. They still appear in Recents and can be answered'**
  String get descFilterSpam;

  /// Expandable heading. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'How identification works'**
  String get labelHowIdentificationWorks;

  /// Explainer under How identification works. Keep the blank line between the two paragraphs. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Identification happens on your phone — nothing is sent anywhere. SreerajP Contacts Sphere recognises registered telemarketing (140…) and service (160…) number series, numbers you have marked as spam from Recents, and shows a warning when your network reports that a caller’s number could not be verified.\n\nMobile networks only deliver the caller’s number, not a name, so callers outside your contacts can’t be identified by name. Spam filtering needs SreerajP Contacts Sphere to be your default phone app.'**
  String get descHowIdentificationWorks;

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get titleAccentColor;

  /// Section heading. English is capitals by design; never use capitals in Malayalam or Sanskrit. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'LIVE PREVIEW'**
  String get labelLivePreview;

  /// Sample shown in the colour preview. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Sample text'**
  String get labelSampleText;

  /// Section heading. English is capitals by design. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'PRESETS'**
  String get labelPresets;

  /// Section heading. English is capitals by design. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM COLOR WHEEL'**
  String get labelCustomColorWheel;

  /// Button that resets the dark-theme accent colour. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Reset Dark to default'**
  String get actionResetDarkToDefault;

  /// Button that resets the light-theme accent colour. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Reset Light to default'**
  String get actionResetLightToDefault;

  /// Note under the colour picker. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Text contrast is adjusted automatically for readability.'**
  String get descContrastAuto;

  /// Settings row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Sort order'**
  String get labelSortOrder;

  /// Subtitle of Sort order. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'How contacts are ordered in lists'**
  String get descSortOrder;

  /// Sort choice: by first name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get labelFirstName;

  /// Switch label. UI chrome. The English is 35 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Hide contacts without phone numbers'**
  String get labelHideNoPhone;

  /// Subtitle of the hide switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Contacts with only emails or addresses won\'t show in the main list'**
  String get descHideNoPhone;

  /// Screen title and section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get titleThemeMode;

  /// Theme choice. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get labelLight;

  /// Theme choice. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get labelDark;

  /// Theme choice that follows the phone. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get labelSystem;

  /// Note under the theme choices. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'System mode automatically follows your device\'s system-wide dark mode setting.'**
  String get descSystemTheme;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Volume & vibration'**
  String get labelVolumeVibration;

  /// Subtitle of the volume row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Ringtone volume and incoming call vibration'**
  String get descVolumeVibration;

  /// Settings row and screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Per-SIM ringtones'**
  String get labelPerSimRingtones;

  /// Subtitle of the per-SIM row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Assign distinct ringtones for calls received on each SIM'**
  String get descPerSimRingtones;

  /// Screen title. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Typography & Text Size'**
  String get titleTypography;

  /// Section heading. English is capitals by design. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'FONT'**
  String get labelFont;

  /// Section heading. English is capitals by design. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'TEXT SIZE'**
  String get labelTextSize;

  /// Text size choice. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get labelScaleSmall;

  /// Text size choice. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get labelScaleDefault;

  /// Text size choice. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get labelScaleLarge;

  /// Text size choice. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get labelScaleLarger;

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Guard'**
  String get titleScreenshotGuard;

  /// Switch label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Block screenshots'**
  String get labelBlockScreenshots;

  /// Subtitle of the screenshot switch. 'Recents preview' is Android's recent-apps screen, not the app's Recents tab. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Keeps contact details and calls out of screenshots, screen recordings and the Recents preview'**
  String get descBlockScreenshots;

  /// Features screen: category heading. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Smart Dialer & Calling'**
  String get featureC0Name;

  /// Features screen: category subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Fast T9 search, dual-SIM controls, and intelligent calling tools'**
  String get featureC0Subtitle;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Multi-Script T9 Keypad Search'**
  String get featureC0F0Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Search contacts in milliseconds by typing numbers or letters on the dialpad. Fully supports English, Malayalam (including vowels & chillu letters), Devanagari, and more.'**
  String get featureC0F0Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'English & Malayalam'**
  String get featureC0F0H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Multi-script transliteration'**
  String get featureC0F0H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Matches names either way'**
  String get featureC0F0H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Speed Dial'**
  String get featureC0F1Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Save a person on keypad keys 1 to 9, then hold that key to call them. Holding works when the number box is empty; assigned keys carry a small dot. Secret contacts can never be put on a key.'**
  String get featureC0F1Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Keys 1-9'**
  String get featureC0F1H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Hold a key to call'**
  String get featureC0F1H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Assign from the keypad or Settings'**
  String get featureC0F1H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Voice Dial'**
  String get featureC0F2Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone on the dialpad and say a number or a name. Speech is turned into text on your phone, in English or Malayalam, and lead-in words like \"call\" are dropped automatically.'**
  String get featureC0F2Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Speak a number or a name'**
  String get featureC0F2H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'English & Malayalam'**
  String get featureC0F2H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'On-device speech'**
  String get featureC0F2H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Editable Dialer & Precision Editing'**
  String get featureC0F3Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Freely tap anywhere on the typed number to move your cursor, select digits, copy, or paste phone numbers with ease.'**
  String get featureC0F3Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Cursor positioning'**
  String get featureC0F3H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Paste numbers'**
  String get featureC0F3H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Backspace at the cursor'**
  String get featureC0F3H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Top Contacts Quick Access'**
  String get featureC0F4Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A row right above the dialpad for one-tap calling. Choose what fills it: your most contacted people, the family and friends you have linked, or whoever usually answers at this time of day.'**
  String get featureC0F4Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Favorites row'**
  String get featureC0F4H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Family & friends filter'**
  String get featureC0F4H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Likely to answer now'**
  String get featureC0F4H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Dual-SIM Calling Controls'**
  String get featureC0F5Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Choose between SIM 1 and SIM 2 for each call, or set a default SIM so you are not asked every time. A contact can also keep its own preferred SIM, which is used ahead of the default. Each SIM gets its own colour, and Recents shows which one a call used.'**
  String get featureC0F5Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'SIM 1 / SIM 2 picker'**
  String get featureC0F5H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Default SIM or ask each time'**
  String get featureC0F5H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Per-contact preferred SIM'**
  String get featureC0F5H2;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'SIM shown in Recents'**
  String get featureC0F5H3;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Smart Redial & \"Reach Me\" Mode'**
  String get featureC0F6Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'When a call goes unanswered or busy, schedule a redial after a delay you choose, or send a preset \"trying to reach you\" text in one tap.'**
  String get featureC0F6Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Redial after your delay'**
  String get featureC0F6H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'1-tap SMS prompt'**
  String get featureC0F6H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Cancel a waiting redial'**
  String get featureC0F6H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Spoken Caller Announcements'**
  String get featureC0F7Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Hear a saved caller\'s name spoken out loud when your phone rings, perfect when driving or wearing headphones. A Malayalam name is announced in Malayalam.'**
  String get featureC0F7Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Voice caller ID'**
  String get featureC0F7H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Malayalam announcements'**
  String get featureC0F7H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Quiet-hours exception'**
  String get featureC0F7H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Quick Reject SMS Replies'**
  String get featureC0F8Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Decline incoming calls politely with preset one-tap SMS messages like \"In a meeting, will call back soon.\"'**
  String get featureC0F8Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'1-tap decline SMS'**
  String get featureC0F8H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Custom quick templates'**
  String get featureC0F8H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Instant dispatch'**
  String get featureC0F8H2;

  /// Features screen: category heading. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'In-Call & Caller Intelligence'**
  String get featureC1Name;

  /// Features screen: category subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Know who is calling with rich context and seamless call controls'**
  String get featureC1Subtitle;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Modern In-Call Screen & Conference Calling'**
  String get featureC1F0Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A beautiful call screen with mute, loud speaker, call hold, numeric keypad, active call swapping, and merging multi-party conference calls.'**
  String get featureC1F0Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Speaker & mute'**
  String get featureC1F0H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Call hold & swap'**
  String get featureC1F0H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Conference merge'**
  String get featureC1F0H2;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Full-screen incoming alert'**
  String get featureC1F0H3;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Relationship Context Cards'**
  String get featureC1F1Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'See the caller\'s relationship badge, how long since you last spoke, personal notes, and upcoming birthdays right as the phone rings.'**
  String get featureC1F1Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Relationship badge'**
  String get featureC1F1H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Last spoken days'**
  String get featureC1F1H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Instant notes preview'**
  String get featureC1F1H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Pre-Call Summary'**
  String get featureC1F2Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Before you ring someone, see when you last spoke, how long that call lasted, what you noted, and the local time in their city if you saved an address.'**
  String get featureC1F2Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Catch-up reminders'**
  String get featureC1F2H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Their local time'**
  String get featureC1F2H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Interaction timeline'**
  String get featureC1F2H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Post-Call Notes & Voice Transcribing'**
  String get featureC1F3Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Quickly jot down what you discussed right after hanging up using your keyboard or speaking aloud with automatic voice-to-text.'**
  String get featureC1F3Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Voice-to-text input'**
  String get featureC1F3H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Post-call prompt'**
  String get featureC1F3H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Follow-up reminder'**
  String get featureC1F3H2;

  /// Features screen: category heading. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Contact Management & Relations'**
  String get featureC2Name;

  /// Features screen: category subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Organize your network into meaningful spheres and circles'**
  String get featureC2Subtitle;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Rich Contact Profiles'**
  String get featureC2F0Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Store multiple phone numbers, emails, home/work addresses, birthdays, anniversaries, social links, official details, and phonetic names.'**
  String get featureC2F0Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Multi-phone & email'**
  String get featureC2F0H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Birthday reminders'**
  String get featureC2F0H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Custom labels'**
  String get featureC2F0H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'7 Relationship Spheres'**
  String get featureC2F1Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Every link you save sits in one of seven categories: Immediate Family, Extended Family, Family by Marriage, Professional, Educational, Social, and Service. The label inside it — \"Father\", \"Manager\" — is whatever you type.'**
  String get featureC2F1Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Seven fixed categories'**
  String get featureC2F1H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Your own kinship labels'**
  String get featureC2F1H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Saved on both contacts'**
  String get featureC2F1H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Relationship Quiet Hours (DND Filter)'**
  String get featureC2F2Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Silence calls between the times you set, and list who should still get through — starred contacts, whole relationship categories, a tag, or named individuals. Everyone else stays quiet.'**
  String get featureC2F2Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Set your quiet window'**
  String get featureC2F2H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Allow list, not a block list'**
  String get featureC2F2H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'By category, tag or person'**
  String get featureC2F2H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Tags & Custom Groups'**
  String get featureC2F3Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tag contacts with short words of your own, and build groups (like \"Project Team\" or \"Book Club\") that can carry their own ringtone.'**
  String get featureC2F3Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Tag cloud explorer'**
  String get featureC2F3H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Custom groups'**
  String get featureC2F3H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Group ringtones'**
  String get featureC2F3H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Contact Finder & Smart Merge'**
  String get featureC2F4Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Find duplicates by phone number and by name — including names written in another script — then merge them cleanly without losing any detail.'**
  String get featureC2F4Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Name & number matching'**
  String get featureC2F4H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Safe data merge'**
  String get featureC2F4H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Review before merging'**
  String get featureC2F4H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Temporary (Ephemeral) Contacts'**
  String get featureC2F5Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Save a delivery driver or a one-off seller as a temporary contact and it deletes itself — after 2 hours, 24 hours, 7 days, or a single call.'**
  String get featureC2F5Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Self-deleting entry'**
  String get featureC2F5H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Countdown banner'**
  String get featureC2F5H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Keep it permanently'**
  String get featureC2F5H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Connected Messaging Apps'**
  String get featureC2F6Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A contact shows the messengers they can be reached on — WhatsApp, Telegram, Arattai and others — read from your phone\'s own address book. Tap one to open the chat there.'**
  String get featureC2F6Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Open chat directly'**
  String get featureC2F6H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Read from your phone'**
  String get featureC2F6H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'No account needed'**
  String get featureC2F6H2;

  /// Features screen: category heading. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Privacy, Security & Vault'**
  String get featureC3Name;

  /// Features screen: category subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Protect your sensitive contacts and private conversations'**
  String get featureC3Subtitle;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Secret Contacts Vault'**
  String get featureC3F0Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Hide sensitive personal or business contacts in a protected vault. They are completely invisible in the main list until unlocked.'**
  String get featureC3F0Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Biometric / PIN unlock'**
  String get featureC3F0H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Hidden from main list'**
  String get featureC3F0H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Encrypted database'**
  String get featureC3F0H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'App Lock: Off, Device Lock or App PIN'**
  String get featureC3F1Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Lock the whole app behind your phone\'s fingerprint and face, or behind a separate 4–6 digit App PIN with a one-time recovery code. Secret contacts, backups and sync ask again on top of it.'**
  String get featureC3F1Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint & Face unlock'**
  String get featureC3F1H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Separate App PIN'**
  String get featureC3F1H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'One-time recovery code'**
  String get featureC3F1H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Guard'**
  String get featureC3F2Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Blocks screenshots, screen recording, and the Recents preview while you are on a screen holding private data — contact details, a call in progress, the lock screen, secret contacts, and the audit log.'**
  String get featureC3F2Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Screenshot blocking'**
  String get featureC3F2H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Screen recording defense'**
  String get featureC3F2H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Recents preview hidden'**
  String get featureC3F2H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Contact Change Audit Log'**
  String get featureC3F3Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A private, tamper-evident history of every contact created, edited or deleted, with what it looked like before and after — so an accidental change can be undone.'**
  String get featureC3F3Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Before & after snapshots'**
  String get featureC3F3H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Undo a change'**
  String get featureC3F3H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Signed export'**
  String get featureC3F3H2;

  /// Features screen: category heading. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Instant Contact Sharing & Scanning'**
  String get featureC4Name;

  /// Features screen: category subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Exchange contact cards quickly without typing'**
  String get featureC4Subtitle;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'vCard QR Code Generator & Scanner'**
  String get featureC4F0Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Create a QR code of your contact card for others to scan in seconds, or use the camera to scan and save anyone\'s QR contact card.'**
  String get featureC4F0Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Instant QR vCard'**
  String get featureC4F0H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Built-in camera scanner'**
  String get featureC4F0H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'1-tap address book import'**
  String get featureC4F0H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'AirQR Animated Code Streaming'**
  String get featureC4F1Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A photo or a long contact card will not fit in one QR code. AirQR splits it across many frames and plays them as an animation for the other phone\'s camera to read — no Bluetooth, no network, no pairing.'**
  String get featureC4F1Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Sends photos & full cards'**
  String get featureC4F1H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Camera-only transfer'**
  String get featureC4F1H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Live progress while it streams'**
  String get featureC4F1H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'On-Device Business Card Scanner'**
  String get featureC4F2Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo of any physical business card to extract name, phone, email, and company details instantly—all processed 100% on your phone without cloud upload.'**
  String get featureC4F2Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'On-device AI OCR'**
  String get featureC4F2H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Zero cloud upload'**
  String get featureC4F2H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Selectable field import'**
  String get featureC4F2H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Offline Bluetooth LE Share'**
  String get featureC4F3Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Discover nearby ContactSphere devices and send contacts directly over Bluetooth Low Energy without needing internet or pairing codes.'**
  String get featureC4F3Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Zero internet required'**
  String get featureC4F3H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Auto device discovery'**
  String get featureC4F3H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Receiver must confirm'**
  String get featureC4F3H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'CSV & vCard Import / Export'**
  String get featureC4F4Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Bring contacts in from a CSV or vCard (.vcf) file, or write your address book out as one, then choose where it goes through the system share sheet.'**
  String get featureC4F4Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'CSV in and out'**
  String get featureC4F4H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'vCard (.vcf) in and out'**
  String get featureC4F4H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Secret contacts left out'**
  String get featureC4F4H2;

  /// Features screen: category heading. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Data Sync & Backup'**
  String get featureC5Name;

  /// Features screen: category subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Keep your contacts safe, synchronized, and recoverable anywhere'**
  String get featureC5Subtitle;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Device Contacts & Call Log Sync'**
  String get featureC5F0Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Copy contacts between the app and your phone\'s address book in whichever direction you choose — you run each one yourself. The phone\'s call log flows into Recents on its own.'**
  String get featureC5F0Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Either direction, on demand'**
  String get featureC5F0H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Adds and updates, never deletes'**
  String get featureC5F0H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Call log arrives automatically'**
  String get featureC5F0H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Local Wi-Fi Device-to-Device Sync'**
  String get featureC5F1Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Transfer contacts between two phones on the same Wi-Fi network, encrypted with a pairing code that never leaves the screen. Nothing is uploaded, and nothing on the receiving phone is deleted.'**
  String get featureC5F1Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Direct phone to phone'**
  String get featureC5F1H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Encrypted with a QR pairing code'**
  String get featureC5F1H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'No cloud needed'**
  String get featureC5F1H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Online Provider Sync & Encrypted Cloud Backup'**
  String get featureC5F2Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Optionally sync contacts with Google, Microsoft or a CardDAV server, and upload a password-encrypted backup file to Google Drive, OneDrive or your own WebDAV storage.'**
  String get featureC5F2Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Google, Microsoft & WebDAV'**
  String get featureC5F2H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Password-encrypted file'**
  String get featureC5F2H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Secret contacts never uploaded'**
  String get featureC5F2H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Offline Backup & Restore Files'**
  String get featureC5F3Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Save everything — contacts, call history, photos, settings and the emergency card — into one password-locked file, and restore it on any phone. The password is the only key; the app never stores it.'**
  String get featureC5F3Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Export to file'**
  String get featureC5F3H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Safe encrypted format'**
  String get featureC5F3H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Restore replaces everything'**
  String get featureC5F3H2;

  /// Features screen: category heading. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Call Defense & Spam Blocking'**
  String get featureC6Name;

  /// Features screen: category subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Shield yourself from spam calls and unwanted numbers'**
  String get featureC6Subtitle;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Automatic Call Screening'**
  String get featureC6F0Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A built-in screening service inspects every incoming number before your phone rings and turns away anything on your blocked list — checked entirely on this phone, against your own list.'**
  String get featureC6F0Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Rejected before it rings'**
  String get featureC6F0H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Nothing looked up online'**
  String get featureC6F0H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Default dialer integration'**
  String get featureC6F0H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Blocked Numbers Manager'**
  String get featureC6F1Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Block a number with a long-press in Recents, from the Block control during a call, or by typing it in yourself. Blocking during a live call hangs it up at once, and blocked calls still appear in Recents so you can see who tried.'**
  String get featureC6F1Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Block from Recents or in-call'**
  String get featureC6F1H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Blocklist manager'**
  String get featureC6F1H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Unblock anytime'**
  String get featureC6F1H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Block Unknown Callers'**
  String get featureC6F2Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Turn away calls that arrive with no number or a withheld one. They are rejected before ringing and still written into Recents as blocked.'**
  String get featureC6F2Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Hidden numbers rejected'**
  String get featureC6F2H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Still logged in Recents'**
  String get featureC6F2H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'One switch to turn on'**
  String get featureC6F2H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Caller Identification & Spam Filter'**
  String get featureC6F3Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Label callers who are not in your contacts using what can be worked out locally — telemarketing and service number series, numbers you marked as spam, and the network\'s verified-caller flag. Flagged callers can ring silently instead of loudly.'**
  String get featureC6F3Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Labels unknown callers'**
  String get featureC6F3H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Ring spam silently'**
  String get featureC6F3H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Mark a number as spam'**
  String get featureC6F3H2;

  /// Features screen: category heading. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Personalization & Accessibility'**
  String get featureC7Name;

  /// Features screen: category subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Customize the appearance, audio, and regional settings to your taste'**
  String get featureC7Subtitle;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Theme, Accent Color & Typography'**
  String get featureC7F0Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Switch between Light, Dark, or System mode, choose an accent colour, and set the font and text size. Three bundled fonts cover both Malayalam and English.'**
  String get featureC7F0Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Dark & Light mode'**
  String get featureC7F0H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Curated color palettes'**
  String get featureC7F0H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Font & text size'**
  String get featureC7F0H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Per-SIM, Group & Contact Ringtones'**
  String get featureC7F1Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Assign distinctive ringtones to SIM 1 vs SIM 2, to a group, or to a single contact. The most specific one wins: the contact\'s tone, then their group\'s, then the SIM\'s.'**
  String get featureC7F1Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Distinct ringtone per SIM'**
  String get featureC7F1H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Group ringtones'**
  String get featureC7F1H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Per-contact ringtones'**
  String get featureC7F1H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Emergency Info Lock-Screen Card'**
  String get featureC7F2Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Set vital medical info (blood group, allergies, emergency contacts) visible on your lock screen for first responders without unlocking.'**
  String get featureC7F2Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Lock-screen access'**
  String get featureC7F2H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Per-field privacy toggle'**
  String get featureC7F2H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Direct emergency dial'**
  String get featureC7F2H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Default Country Dialing Code'**
  String get featureC7F3Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tell the app which country your plain, un-prefixed numbers belong to. It is what lets a call from +91 98765 43210 be recognised as the 98765 43210 in your contacts, and it is used to match blocked numbers too.'**
  String get featureC7F3Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Auto country prefix'**
  String get featureC7F3H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'International format'**
  String get featureC7F3H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Matches callers to contacts'**
  String get featureC7F3H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Contact Counts & Search Index'**
  String get featureC7F4Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'See how many contacts sit on the phone and in the app, and check the health of the search index that makes T9 and name search fast. Rebuild it in seconds if a contact stops turning up.'**
  String get featureC7F4Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Device vs app counts'**
  String get featureC7F4H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Index health check'**
  String get featureC7F4H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'One-tap rebuild'**
  String get featureC7F4H2;

  /// Features screen: feature card title. A heading inside a card, so it may wrap; descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'In-App Help & Guides'**
  String get featureC7F5Title;

  /// Features screen: feature description. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Over twenty plain-English guides covering every feature here — calling, blocking, sync, backups, privacy, sharing and more — plus a FAQ and troubleshooting page. All offline, inside the app.'**
  String get featureC7F5Desc;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Guide for every feature'**
  String get featureC7F5H0;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'FAQ & troubleshooting'**
  String get featureC7F5H1;

  /// Features screen: a short highlight chip under a feature. Descriptive catalog text.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get featureC7F5H2;

  /// Heading of the Features screen header card. The app name stays untranslated. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'SreerajP Contacts Sphere Features'**
  String get titleFeaturesHeader;

  /// Subtitle of the Features screen header card. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Explore every intelligent tool, privacy safeguard, and calling feature designed for you.'**
  String get descFeaturesHeader;

  /// Snackbar after saving the emergency card while it is switched off. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Saved. The lock screen card is off.'**
  String get msgSavedCardOff;

  /// Snackbar after saving an emergency card with nothing visible. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Saved. Nothing is switched on to show yet.'**
  String get msgSavedNothingOn;

  /// Snackbar after saving the emergency card. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Saved. The card is on your lock screen.'**
  String get msgSavedCardOn;

  /// Snackbar when saving failed. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String errorCouldNotSave(String error);

  /// Dialog title when leaving with unsaved changes. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get titleLeaveWithoutSaving;

  /// Body of the leave-without-saving dialog. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Your changes to the emergency card are not saved.'**
  String get descUnsavedEmergency;

  /// Dialog button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get actionKeepEditing;

  /// Dialog button that throws away unsaved changes. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// Snackbar when sharing an empty emergency card. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the card is switched on to share.'**
  String get errorNothingToShare;

  /// Subtitle of the share-as-text row. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Send formatted details via messaging or email'**
  String get descShareFormatted;

  /// Share-sheet row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Share as Card Image'**
  String get actionShareAsCardImage;

  /// Subtitle of the share-as-image row. ICE (in case of emergency) and PNG stay in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Send visual ICE card image (PNG)'**
  String get descShareCardImage;

  /// Tooltip on the share icon. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Share ICE Card'**
  String get tooltipShareIceCard;

  /// Warning banner at the top of the emergency screen. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Anything you switch on here can be read by anyone holding your phone, without your PIN. That is the point of an emergency card — so switch on only what a stranger should see.'**
  String get descEmergencyWarning;

  /// Switch label, also used under each emergency field. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Show on lock screen'**
  String get labelShowOnLockScreen;

  /// Subtitle of the master lock-screen switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Adds a persistent notification with 1-tap emergency call action. Opens the card over the lock screen with a high-contrast emergency QR code.'**
  String get descShowOnLockScreen;

  /// Field label. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Name shown on the card'**
  String get labelNameOnCard;

  /// Toggle label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Show the name'**
  String get labelShowTheName;

  /// Warning under the lock-screen switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Notifications for this app are switched off, so the card cannot show anywhere.'**
  String get descNotificationsOff;

  /// Warning under the lock-screen switch. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This notification is set to silent. The lock screen hides silent notifications on many phones.'**
  String get descNotificationSilent;

  /// Button. UI chrome. The English is 26 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Open notification settings'**
  String get actionOpenNotificationSettings;

  /// Help button and dialog title. UI chrome. The English is 33 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Not seeing it on the lock screen?'**
  String get titleNotSeeingOnLock;

  /// Body of the lock-screen tips dialog. The Android menu path and option names are quoted as the phone shows them; they stay in English here because the phone's own language decides them. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'The phone decides which notifications the lock screen shows. Check this system setting:\n\nSettings → Notifications → Notifications on lock screen\n\nPick \"Show conversations, default and silent\". If it is set to \"Hide silent notifications\" or \"Don\'t show any notifications\", the emergency card cannot appear there — no app can override that.'**
  String get descLockScreenTips;

  /// Section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Medical details'**
  String get labelMedicalDetails;

  /// Field label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get labelAllergies;

  /// Field label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get labelMedicines;

  /// Field label: medical conditions. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get labelConditions;

  /// Field label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddressField;

  /// Hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Penicillin, peanuts'**
  String get hintAllergies;

  /// Hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Medicines you take regularly'**
  String get hintMedicines;

  /// Hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Diabetes, epilepsy'**
  String get hintConditions;

  /// Hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Home address'**
  String get hintHomeAddress;

  /// Hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Anything else a helper should know'**
  String get hintEmergencyNotes;

  /// Switch label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Organ donor'**
  String get labelOrganDonor;

  /// Toggle label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Show \"Organ donor\"'**
  String get labelShowOrganDonor;

  /// Section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'People to call'**
  String get labelPeopleToCall;

  /// Explainer under People to call. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Each one gets a Call button on the card. The call is placed straight from the lock screen.'**
  String get descPeopleToCall;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No one added yet.'**
  String get emptyNoOneAdded;

  /// Button that picks a person from contacts. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'From contacts'**
  String get actionFromContacts;

  /// Button that opens a dialog to type a number by hand. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Type a number'**
  String get actionTypeANumber;

  /// Tooltip on the visibility icon when on. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Shown on the card'**
  String get tooltipShownOnCard;

  /// Tooltip on the visibility icon when off. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get tooltipHidden;

  /// Section heading of the preview. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'What a stranger will see'**
  String get labelWhatStrangerSees;

  /// Preview when the card is off. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Nothing — the card is switched off.'**
  String get descCardSwitchedOff;

  /// Preview when nothing is visible. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet. Fill in a field and switch it on.'**
  String get descNothingYetFill;

  /// Note under the preview. The quoted word is the Save button (actionSave). Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tap Save to apply changes to the lock screen.'**
  String get descTapSaveToApply;

  /// Title of the contact picker. UI chrome. The English is 23 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Choose a person to call'**
  String get titleChoosePersonToCall;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add a person'**
  String get titleAddPerson;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get titleEditPerson;

  /// Field label: a phone number. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get labelNumber;

  /// Field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Relation (optional)'**
  String get labelRelationOptional;

  /// Hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Wife, Doctor'**
  String get hintRelationExample;

  /// Snackbar when a hand-typed person lacks a name or number. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A name and a number are both needed.'**
  String get errorNameAndNumberNeeded;

  /// Dropdown option for no value. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get labelNotSet;

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Failed to load groups: {error}'**
  String errorFailedLoadGroups(String error);

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not create group (name may already exist)'**
  String get errorCouldNotCreateGroup;

  /// Dialog title for a new group. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get titleGroupName;

  /// Hint in the group name field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Family'**
  String get hintGroupExample;

  /// Dialog confirm button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not save ringtone: {error}'**
  String errorCouldNotSaveRingtone(String error);

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not clear ringtone: {error}'**
  String errorCouldNotClearRingtone(String error);

  /// Snackbar when the book is empty. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts to add'**
  String get errorNoContactsToAdd;

  /// Title of the contact picker that adds people to a group. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add to \"{name}\"'**
  String titleAddToGroup(String name);

  /// Snackbar when the picker returned only existing members. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No new contacts added'**
  String get msgNoNewContactsAdded;

  /// Snackbar after adding people to a group. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 contact added to \"{name}\"} other{{count} contacts added to \"{name}\"}}'**
  String msgContactsAddedToGroup(int count, String name);

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not add contacts: {error}'**
  String errorCouldNotAddContacts(String error);

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String titleDeleteGroupConfirm(String name);

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'The group is removed; contacts in it are not deleted.'**
  String get descDeleteGroup;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get emptyNoGroups;

  /// Menu item. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add contacts…'**
  String get actionAddContactsEllipsis;

  /// Menu item that picks a group ringtone. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Ringtone…'**
  String get actionRingtoneEllipsis;

  /// Menu item. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Clear ringtone'**
  String get actionClearRingtone;

  /// Empty state of the tag cloud. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Add tags to a contact and they show up here.'**
  String get emptyNoTags;

  /// Hint above the tag cloud. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tap a tag to see its contacts. Long-press to rename, merge or delete.'**
  String get descTagCloudHint;

  /// Title of the contact picker that tags people. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add to #{tag}'**
  String titleAddToTag(String tag);

  /// Snackbar after tagging people. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 contact added to #{tag}} other{{count} contacts added to #{tag}}}'**
  String msgContactsAddedToTag(int count, String tag);

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Remove #{tag}?'**
  String titleRemoveTagConfirm(String tag);

  /// Dialog body. {name} is the contact's name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Removes the tag from {name}. The contact itself is not deleted.'**
  String descRemoveTagFrom(String name);

  /// Dialog body when the contact has no name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Removes the tag from this contact. The contact itself is not deleted.'**
  String get descRemoveTagFromThis;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Removed #{tag}'**
  String msgRemovedTag(String tag);

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Could not remove: {error}'**
  String errorCouldNotRemove(String error);

  /// Tooltip on the tag menu icon. UI chrome. The English is 27 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Rename, merge or delete tag'**
  String get tooltipRenameMergeDeleteTag;

  /// Button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add contacts'**
  String get actionAddContacts;

  /// Empty state of a tag's contact list. Keep the blank line. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No contacts have this tag.\n\nAdd some below, or delete the tag from the menu above.'**
  String get emptyTagNoContacts;

  /// Tooltip on the remove icon in a tag's contact list. UI chrome. The English is 32 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Remove this tag from the contact'**
  String get tooltipRemoveTagFromContact;

  /// Shown under a duplicate contact that has no phone number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get labelNoPhone;

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Failed to find duplicates: {error}'**
  String errorFailedFindDuplicates(String error);

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Merge this set?'**
  String get titleMergeThisSet;

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Keep the selected contact and merge 1 other into it. This cannot be undone.} other{Keep the selected contact and merge {count} others into it. This cannot be undone.}}'**
  String descMergeThisSet(int count);

  /// Snackbar after merging. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Merged 1 contact} other{Merged {count} contacts}}'**
  String msgMergedCount(int count);

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Merge failed: {error}'**
  String errorMergeFailed(String error);

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected to merge'**
  String get errorNothingSelectedToMerge;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Merge all sets?'**
  String get titleMergeAllSets;

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{sets, plural, =1{Resolve 1 set} other{Resolve {sets} sets}}, merging {total, plural, =1{1 contact} other{{total} contacts}} into their kept ones. This cannot be undone.'**
  String descMergeAllSets(int sets, int total);

  /// Button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get actionMerge;

  /// Status while looking for duplicates. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get labelScanning;

  /// Summary heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 duplicate set found} other{{count} duplicate sets found}}'**
  String labelDuplicateSetsFound(int count);

  /// Summary heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'No duplicates'**
  String get labelNoDuplicates;

  /// Hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tap a contact to choose which to keep; untick the rest.'**
  String get descTapToKeep;

  /// Heading when no duplicates remain. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'All cleaned up'**
  String get labelAllCleanedUp;

  /// Body when no duplicates remain. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No more duplicate contacts. Your address book is tidy.'**
  String get descNoMoreDuplicates;

  /// Shown for a contact with no name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get labelUnnamed;

  /// Badge on the contact that will be kept. English is capitals by design. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'KEEP'**
  String get labelKeep;

  /// Status line of a duplicate set. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Keeping 1 · merging {count}'**
  String labelKeepingMerging(int count);

  /// Status line of a duplicate set. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected'**
  String get labelNothingSelected;

  /// Caption under the total count of contacts to merge. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'to merge'**
  String get labelToMerge;

  /// Button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Merge all sets'**
  String get actionMergeAllSets;

  /// Snackbar after exporting the audit log. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Signed Audit Log exported successfully ({count} entries verified)'**
  String msgAuditExported(int count);

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Clear the audit log?'**
  String get titleClearAuditLog;

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Your contacts are not touched — only the record of how they changed. Anything not yet undone can no longer be undone.'**
  String get descClearAuditLog;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Audit log cleared'**
  String get msgAuditCleared;

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get titleAuditLog;

  /// Menu item and tooltip. UI chrome. The English is 23 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Export Signed Audit Log'**
  String get actionExportSignedAuditLog;

  /// Tooltip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Hide secret contacts'**
  String get tooltipHideSecret;

  /// Tooltip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Show secret contacts'**
  String get tooltipShowSecret;

  /// Menu item. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get actionClearLog;

  /// Explainer at the top of the audit log. SHA-256 stays in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Every contact added, edited or deleted is recorded here with SHA-256 cryptographic hash chaining for {days} days. Tap an entry to see changes, or tap 1-Click Export Signed Audit Log to export.'**
  String descAuditIntro(int days);

  /// Status line when the hash chain checks out. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tamper-Proof Chain Verified ({verified} / {total} entries linked)'**
  String descChainVerified(int verified, int total);

  /// Status line when the hash chain is broken. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Security Warning: Tamper detected at row #{row}!'**
  String descChainTampered(String row);

  /// Audit filter chip and action label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get labelAuditAdded;

  /// Audit filter chip and action label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get labelAuditEdited;

  /// Audit filter chip and action label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get labelAuditDeleted;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet. Changes to your contacts will show up here.'**
  String get emptyAuditNothing;

  /// Empty state for a filter. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded under this filter.'**
  String get emptyAuditFilter;

  /// Audit entry source: changed by hand in the app. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'In the app'**
  String get labelSourceManual;

  /// Audit entry source. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Phone contacts sync'**
  String get labelSourceDeviceSync;

  /// Audit entry source. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Merged duplicates'**
  String get labelSourceMerge;

  /// Audit entry source. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Backup restore'**
  String get labelSourceRestore;

  /// Audit entry source. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Sync from another device'**
  String get labelSourceP2pSync;

  /// Audit entry source. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'File import'**
  String get labelSourceImport;

  /// Audit entry source. UI chrome. The English is 23 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Undo from the audit log'**
  String get labelSourceUndo;

  /// Audit entry source. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get labelSourceUnknown;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Undo this change?'**
  String get titleUndoThisChange;

  /// Button and section heading. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// Snackbar after undoing an add. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Contact removed again'**
  String get msgContactRemovedAgain;

  /// Snackbar after undoing a change. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Change undone'**
  String get msgChangeUndone;

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Undo failed: {error}'**
  String errorUndoFailed(String error);

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Change details'**
  String get titleChangeDetails;

  /// Note when an edit changed no visible field. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No field visible in the log is different. The change was recorded because something was written to this contact.'**
  String get descNoVisibleChange;

  /// Section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'What changed'**
  String get labelWhatChanged;

  /// Caption over the old value. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get labelBefore;

  /// Caption over the new value. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get labelAfter;

  /// Undo card text after an undo. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This change has been undone. The undo itself is recorded as a new entry.'**
  String get descUndone;

  /// Undo card text when undo is impossible. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This entry cannot be undone — it has no saved copy of the earlier version.'**
  String get descCannotUndo;

  /// Button label after an undo. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Undone'**
  String get labelUndone;

  /// Button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Undo this change'**
  String get actionUndoThisChange;

  /// List row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Open this contact'**
  String get titleOpenThisContact;

  /// List row subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'See the contact as it is now'**
  String get descSeeContactNow;

  /// What undoing an add does. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Undo will delete this contact again.'**
  String get descUndoCreate;

  /// What undoing an edit does. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Undo will put the old details back.'**
  String get descUndoUpdate;

  /// What undoing a delete does. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Undo will create this contact again. It gets a new id, so old call history stays unlinked and only relationships whose other person still exists come back.'**
  String get descUndoDelete;

  /// Contact field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get labelPhoto;

  /// Contact field name: whether it is a secret contact. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get labelSecret;

  /// Contact field name: whether it is starred. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get labelFavourite;

  /// Contact field name: whether it is the phone owner's own card. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get labelSelf;

  /// Contact field name: the link to the phone's own address book. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Phone contacts link'**
  String get labelPhoneContactsLink;

  /// Contact field name. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get labelAddresses;

  /// Contact field name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Work details'**
  String get labelWorkDetails;

  /// Card title on Backup & Restore. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get actionBackUpNow;

  /// Card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Save all your contacts, photos and settings to one password-protected file.'**
  String get descBackUpNow;

  /// Card title on Backup & Restore. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Restore from a file'**
  String get actionRestoreFromFile;

  /// Card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Load a backup file. This replaces everything currently in the app.'**
  String get descRestoreFromFile;

  /// Info note on Backup & Restore. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'The backup is locked with your password. Keep it safe — without it the file cannot be opened, on this or any other phone. That same password is what lets you restore on a new phone.'**
  String get descBackupPasswordNote;

  /// Progress text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Creating backup…'**
  String get msgCreatingBackup;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Backup ready. Choose where to save it.'**
  String get msgBackupReady;

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String errorBackupFailed(String error);

  /// Progress text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get msgRestoring;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Restore complete.'**
  String get msgRestoreComplete;

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String errorRestoreFailed(String error);

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get titleReplaceAllData;

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Restoring will DELETE everything currently in the app — all contacts, call history, groups and settings — and replace it with the backup. This cannot be undone.'**
  String get descReplaceAllData;

  /// Password field error. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} characters.'**
  String errorPasswordTooShort(int count);

  /// Password field error. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get errorPasswordsDontMatch;

  /// Password field error. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter the backup password.'**
  String get errorEnterBackupPassword;

  /// Dialog title. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Set a backup password'**
  String get titleSetBackupPassword;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get titleBackupPassword;

  /// Text field label. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// Text field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get labelEnterPassword;

  /// Text field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get labelConfirmPassword;

  /// Dialog button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get actionBackUp;

  /// Dialog button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// Screen and card title. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Send to Another Device'**
  String get titleSendToDevice;

  /// Card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Share your contacts (and more) with another phone over Wi-Fi.'**
  String get descSendToDevice;

  /// Screen and card title. UI chrome. The English is 27 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Receive from Another Device'**
  String get titleReceiveFromDevice;

  /// Card subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Add another phone\'s contacts to this phone. Nothing already here is changed or removed.'**
  String get descReceiveFromDevice;

  /// Footer note. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Both phones must be on the same Wi-Fi network and running this app.'**
  String get descSyncFooter;

  /// Footer note. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Both phones must be on the same Wi-Fi network.'**
  String get descSameWifi;

  /// Progress text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get msgConnecting;

  /// Progress text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Connected — waiting for the sender to choose…'**
  String get msgWaitingForSender;

  /// Result title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get titleReceived;

  /// Result message after receiving. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Added {added} new contacts ({skipped} already on this phone were kept). Nothing was removed.'**
  String descReceivedSummary(int added, int skipped);

  /// Result title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Could not receive'**
  String get titleCouldNotReceive;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter the address, port and pairing code'**
  String get errorEnterAddressPortCode;

  /// Info note on the receive form. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This ADDS the other phone\'s contacts to this phone. Contacts you already have are kept as they are — nothing here is changed or removed.'**
  String get descReceiveAddsOnly;

  /// Button. UI chrome. The English is 25 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Scan the other phone\'s QR'**
  String get actionScanOtherPhoneQr;

  /// Divider text between the scan button and the manual fields. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'or enter by hand'**
  String get descOrEnterByHand;

  /// Text field label: the other phone's network address. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Other phone\'s address'**
  String get labelOtherPhoneAddress;

  /// Text field label: network port number. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get labelPort;

  /// Text field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Pairing code'**
  String get labelPairingCode;

  /// Text field hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'shown on the other phone'**
  String get hintShownOnOtherPhone;

  /// Button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get actionConnect;

  /// Snackbar after scanning a wrong QR. The app name stays in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Not a SreerajP Contacts Sphere pairing code'**
  String get errorNotPairingCode;

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Scan pairing code'**
  String get titleScanPairingCode;

  /// Result title. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get titleSent;

  /// Result message after sending. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Sent {contacts} contacts, {groups} groups and {callLogs} call-log entries to the other phone.'**
  String descSentSummary(int contacts, int groups, int callLogs);

  /// Result title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Could not send'**
  String get titleCouldNotSend;

  /// Intro on the send screen. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Share this phone\'s SreerajP Contacts Sphere data with another phone on the same Wi-Fi. Start below, then scan the QR (or type the code) on the other phone. After it connects, pick what to send.'**
  String get descSendIntro;

  /// Button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// Instruction above the pairing QR. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'On the other phone, choose Receive, then scan this code:'**
  String get descScanThisCode;

  /// Text above the manual pairing details. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'…or enter these by hand:'**
  String get descEnterTheseByHand;

  /// Label for this phone's network address. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'This phone\'s address'**
  String get labelThisPhoneAddress;

  /// Button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get actionCopyCode;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get msgAddressCopied;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get msgCodeCopied;

  /// Status text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the other phone…'**
  String get msgWaitingForOtherPhone;

  /// Status chip. UI chrome. The English is 21 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Other phone connected'**
  String get labelOtherPhoneConnected;

  /// Sync category. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Call history'**
  String get labelCallHistory;

  /// Sync category. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Blocked & spam numbers'**
  String get labelBlockedSpamNumbers;

  /// Sync category. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Emergency info card'**
  String get labelEmergencyInfoCard;

  /// Sync category. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get labelAppSettings;

  /// Section heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Choose what to share'**
  String get titleChooseWhatToShare;

  /// Info note. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'This never overrides anything already on the other phone. On a conflict, the other phone keeps its own data.'**
  String get descNeverOverrides;

  /// Button. UI chrome. The English is 33 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Full Sync (for a brand-new phone)'**
  String get actionFullSyncNewPhone;

  /// Caption above the category list. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Or send only:'**
  String get labelOrSendOnly;

  /// Subtitle for the Contacts row. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Always included'**
  String get labelAlwaysIncluded;

  /// Button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Send selected'**
  String get actionSendSelected;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Full Sync?'**
  String get titleFullSync;

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Send everything (contacts, groups, call history, relationships, blocked numbers and settings). Best for a brand-new phone. The other phone still keeps any data it already has.'**
  String get descFullSync;

  /// Dialog button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Send everything'**
  String get actionSendEverything;

  /// Row subtitle on Security. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Block screenshots, recordings, and Recents preview'**
  String get descScreenshotGuardRow;

  /// Row subtitle on Security. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'What changed on your contacts, and how to undo it'**
  String get descAuditLogRow;

  /// App lock status. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Off — the app opens without a lock'**
  String get descLockOff;

  /// App lock status. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'On — unlock with your device lock'**
  String get descLockDevice;

  /// App lock status. PIN stays in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'On — unlock with your app PIN'**
  String get descLockAppPin;

  /// Card and sheet title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get titleAppLock;

  /// Lock mode option: no lock. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get labelLockOff;

  /// Lock mode option subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No lock when opening the app'**
  String get descLockOffOption;

  /// Lock mode option. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Device lock'**
  String get labelDeviceLock;

  /// Lock mode option subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint, face or device PIN'**
  String get descDeviceLockOption;

  /// Lock mode option subtitle when the device has no screen lock. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Set a screen lock on your device to use this'**
  String get descDeviceLockUnavailable;

  /// Lock mode option. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get labelAppPin;

  /// Lock mode option subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A separate PIN just for this app'**
  String get descAppPinOption;

  /// Reason shown in the system fingerprint prompt. The app name stays in Latin letters. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Unlock SreerajP Contacts Sphere'**
  String get descUnlockReason;

  /// Lock screen heading. The app name stays in Latin letters. UI chrome; the English is over 20 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'SreerajP Contacts Sphere is locked'**
  String get titleAppLocked;

  /// Lock screen text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Unlock with your fingerprint, face or device PIN to continue'**
  String get descUnlockDevice;

  /// Button label while unlocking. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Unlocking…'**
  String get labelUnlocking;

  /// Button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get actionUnlock;

  /// PIN lock screen text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter your app PIN to continue'**
  String get descEnterAppPin;

  /// Text button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get actionForgotPin;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Enter recovery code'**
  String get titleEnterRecoveryCode;

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter the recovery code you saved when setting the PIN. This turns App lock off so you can set a new PIN.'**
  String get descEnterRecoveryCode;

  /// Text field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get labelRecoveryCode;

  /// Text field error. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get errorIncorrectCode;

  /// PIN setup heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Set an app PIN'**
  String get titleSetAppPin;

  /// PIN setup heading. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get titleConfirmPin;

  /// PIN setup heading. UI chrome. The English is 23 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Save your recovery code'**
  String get titleSaveRecoveryCode;

  /// PIN setup text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4 to 6 digit PIN to unlock the app'**
  String get descChoosePin;

  /// PIN setup text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter the same PIN again'**
  String get descEnterSamePin;

  /// PIN setup text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'If you forget your PIN, this code lets you back in. Write it down and keep it safe — it is shown only once.'**
  String get descRecoveryCodeInfo;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the PIN. Try again.'**
  String get errorCouldNotSavePin;

  /// PIN setup error. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'PINs didn\'t match — start again'**
  String get errorPinsDidntMatch;

  /// Button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Recovery code copied'**
  String get msgRecoveryCodeCopied;

  /// Button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// Button. UI chrome. The English is 32 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'I\'ve saved it — turn on App lock'**
  String get actionSavedTurnOnLock;

  /// Row subtitle on Appearance. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Choose between Light, Dark, or System mode'**
  String get descThemeModeRow;

  /// Row subtitle on Appearance. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'App font family and text scale preferences'**
  String get descTypographyRow;

  /// Row subtitle on Appearance. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Custom color palette, presets, and live preview'**
  String get descAccentColorRow;

  /// Title of the contact picker for one speed-dial key. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Speed dial {slot}'**
  String titleSpeedDialSlot(int slot);

  /// Info card on Speed dial. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Hold a keypad key on the dialer to call the person saved on it. Holding works only when the number box is empty. Secret contacts cannot be saved to a key.'**
  String get descSpeedDialIntro;

  /// Row subtitle for an empty key. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a contact'**
  String get descTapToChooseContact;

  /// Tooltip. UI chrome. The English can reach 17 characters.
  ///
  /// In en, this message translates to:
  /// **'Remove from key {slot}'**
  String tooltipRemoveFromKey(int slot);

  /// Subtitle on Default country. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Used to match incoming and dialed numbers to your contacts'**
  String get descDefaultCountryInfo;

  /// Tooltip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get tooltipOpenSystemSettings;

  /// Section header for permissions the user must allow. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Explicit'**
  String get labelExplicitPerms;

  /// Section subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Permissions and system roles requiring user interaction or runtime approval.'**
  String get descExplicitPerms;

  /// Section header for permissions granted at install. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Implicit'**
  String get labelImplicitPerms;

  /// Section subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Declared in the manifest; granted automatically by system at install.'**
  String get descImplicitPerms;

  /// Permission status chip. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get labelGranted;

  /// Permission status chip. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get labelDenied;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Default phone app'**
  String get labelPermDialer;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Become the system dialer so SreerajP Contacts Sphere shows its own in-call screen and call screening controls.'**
  String get descPermDialer;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get labelPermContacts;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Read and sync contacts from your device address book.'**
  String get descPermContacts;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Phone & Call Log'**
  String get labelPermPhone;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Place, answer and manage calls, and reconcile their real duration from the call log.'**
  String get descPermPhone;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get labelPermMicrophone;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Voice input / speech-to-text when adding notes.'**
  String get descPermMicrophone;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get labelPermLocation;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Tag contacts with places and support BLE scanning on older Android.'**
  String get descPermLocation;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get labelPermNotifications;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Show reminders for birthdays, follow-ups and missed calls.'**
  String get descPermNotifications;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Alarms & reminders'**
  String get labelPermAlarms;

  /// Why the app needs this permission. Smart Redial is a feature name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Lets Smart Redial call back on schedule even if the app is closed.'**
  String get descPermAlarms;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Photos & Media'**
  String get labelPermPhotos;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Pick a profile photo for a contact from your gallery.'**
  String get descPermPhotos;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get labelPermCamera;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo for a contact or scan QR codes.'**
  String get descPermCamera;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Scan'**
  String get labelPermBtScan;

  /// Why the app needs this permission. neverForLocation is an Android flag name; keep it. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Find a nearby phone sharing a contact over Bluetooth (declared with neverForLocation).'**
  String get descPermBtScan;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Connect'**
  String get labelPermBtConnect;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Connect to another phone to transfer contacts over Bluetooth.'**
  String get descPermBtConnect;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Advertise'**
  String get labelPermBtAdvertise;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Make this phone discoverable while sharing contacts over Bluetooth.'**
  String get descPermBtAdvertise;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get labelPermBiometrics;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Unlock secret contacts, and confirm before exporting or syncing them, with fingerprint or face.'**
  String get descPermBiometrics;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Screen off near ear'**
  String get labelPermProximity;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Turns the screen off while holding the phone to your ear during a call so your cheek cannot tap controls.'**
  String get descPermProximity;

  /// Permission name. UI chrome. The English is 33 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Foreground Call Service & Ringing'**
  String get labelPermCallService;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Runs active call services, full-screen incoming alerts, and vibration when calls arrive.'**
  String get descPermCallService;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth (legacy)'**
  String get labelPermBtLegacy;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth access on Android 11 and below.'**
  String get descPermBtLegacy;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Start after restart'**
  String get labelPermBoot;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Puts your emergency info card back on the lock screen after the phone reboots. Used for nothing else.'**
  String get descPermBoot;

  /// Permission name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Internet & Wi-Fi'**
  String get labelPermInternet;

  /// Why the app needs this permission. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Copies your data to another phone over your local Wi-Fi during P2P sync. No cloud server is contacted.'**
  String get descPermInternet;

  /// Tooltip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Refresh SIMs'**
  String get tooltipRefreshSims;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No SIMs detected. Multi-SIM options need phone permission and a device with at least one SIM. Grant the phone permission and tap refresh.'**
  String get emptyNoSims;

  /// Section subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Which SIM outgoing calls use unless you pick per call'**
  String get descDefaultSimInfo;

  /// Option subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Let Android choose'**
  String get descLetAndroidChoose;

  /// Switch title. UI chrome. The English is 30 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Ask which SIM before each call'**
  String get labelAskSimEachCall;

  /// Switch subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Show a SIM chooser each time you place a call'**
  String get descAskSimEachCall;

  /// Switch subtitle when only one SIM. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Needs more than one SIM'**
  String get descNeedsMoreThanOneSim;

  /// Section title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'SIM colours'**
  String get labelSimColours;

  /// Section subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'The SIM name appears in this colour on the calling screen'**
  String get descSimColoursInfo;

  /// Suffix on a SIM row with no custom colour. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Default colour'**
  String get labelDefaultColour;

  /// Sheet title. {name} is the SIM's name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Colour for {name}'**
  String titleColourFor(String name);

  /// Button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get actionUseDefault;

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Per-SIM Ringtones'**
  String get titlePerSimRingtones;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No SIMs detected. Per-SIM ringtones need phone permission and a device with at least one SIM. Grant the phone permission and tap refresh.'**
  String get emptyNoSimsRingtone;

  /// Section title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Per-SIM ringtone'**
  String get labelPerSimRingtone;

  /// Section subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A ringtone for calls received on each SIM'**
  String get descPerSimRingtone;

  /// Tooltip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Change ringtone'**
  String get tooltipChangeRingtone;

  /// Tooltip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Pick ringtone'**
  String get tooltipPickRingtone;

  /// Note under the SIM list. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'A ringtone set on an individual contact takes precedence over the per-SIM ringtone. Set one from a contact’s edit screen.'**
  String get descPerContactRingtoneNote;

  /// SIM row subtitle when no ringtone is set. {slot} is like 'SIM 1'. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{slot} · default ringtone'**
  String descSlotDefaultRingtone(String slot);

  /// SIM row subtitle showing the phone's default ringtone name. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{slot} · Default · {tone}'**
  String descSlotDefaultTone(String slot, String tone);

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Volume & Vibration'**
  String get titleVolumeVibration;

  /// Section title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Ringtone volume'**
  String get labelRingtoneVolume;

  /// Volume subtitle at 0%. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Muted — the ringtone won’t sound, but the phone still vibrates if vibration is on below'**
  String get descRingtoneMuted;

  /// Volume subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Plays incoming-call ringtones at {value}% of your phone’s ring volume'**
  String descRingtoneVolumePercent(int value);

  /// Switch title. UI chrome. The English is 25 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on incoming calls'**
  String get labelVibrateIncoming;

  /// Switch subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Your phone comes first: silent mode, Do Not Disturb and the phone’s own “Vibrate for calls” setting all override this'**
  String get descVibrateIncoming;

  /// Switch subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Silence calls at night except for chosen allowed contacts'**
  String get descQuietHoursSwitch;

  /// Row title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours range'**
  String get labelQuietHoursRange;

  /// Section title. UI chrome. The English is 31 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Allowed Contacts (Ring Through)'**
  String get labelAllowedRingThrough;

  /// Section subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Callers in allowed relationships, tags, or individual contacts ring loudly; all others are silenced.'**
  String get descAllowedRingThrough;

  /// Sub-section title. UI chrome. The English is 34 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Allowed Relationships & Categories'**
  String get labelAllowedRelationships;

  /// Chip. ICE = In Case of Emergency; keep it. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts (ICE)'**
  String get labelEmergencyContactsIce;

  /// Chip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Starred Contacts'**
  String get labelStarredContacts;

  /// Chip button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add Relationship'**
  String get actionAddRelationship;

  /// Sub-section title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Allowed Tags'**
  String get labelAllowedTags;

  /// Chip button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get actionAddTag;

  /// Sub-section title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Specific Contacts'**
  String get labelSpecificContacts;

  /// Fallback chip label for a contact whose name is not loaded. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Contact #{id}'**
  String labelContactNumber(int id);

  /// Chip button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get actionAddContact;

  /// Count line. UI chrome. The English is about 26 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Allowed active numbers: {count}'**
  String labelAllowedActiveNumbers(int count);

  /// Sheet title. UI chrome. The English is 28 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Select Allowed Relationships'**
  String get titleSelectAllowedRelationships;

  /// Sheet title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Select Allowed Tags'**
  String get titleSelectAllowedTags;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No tags found in contacts. Create tags on contacts first.'**
  String get emptyNoTagsInContacts;

  /// Sheet title. UI chrome. The English is 23 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Select Allowed Contacts'**
  String get titleSelectAllowedContacts;

  /// Time picker help text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'SELECT RELATIONSHIP QUIET HOURS START TIME'**
  String get hintQuietStartTime;

  /// Time picker help text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'SELECT RELATIONSHIP QUIET HOURS END TIME'**
  String get hintQuietEndTime;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'New quick reply'**
  String get titleNewQuickReply;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Edit quick reply'**
  String get titleEditQuickReply;

  /// Text field hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Can\'t talk now. Call you later.'**
  String get hintQuickReplyExample;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Reset quick replies?'**
  String get titleResetQuickReplies;

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Your custom messages will be replaced by the default ones.'**
  String get descResetQuickReplies;

  /// Button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// Tooltip. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get tooltipResetToDefaults;

  /// Info card. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Quick replies appear when you reject an incoming call with a message. The reply is sent to the caller as an SMS from the SIM the call came in on.'**
  String get descQuickRepliesInfo;

  /// Row title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add a reply'**
  String get actionAddReply;

  /// Row subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Write a message to offer when rejecting a call'**
  String get descAddReply;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No quick replies yet. Add one, or reset to the defaults from the top-right.'**
  String get emptyNoQuickReplies;

  /// Section title with count. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Replies ({count})'**
  String labelRepliesCount(int count);

  /// Relationship category name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Immediate Family'**
  String get labelCatImmediateFamily;

  /// Relationship category name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Extended Family'**
  String get labelCatExtendedFamily;

  /// Relationship category name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Family by Marriage'**
  String get labelCatFamilyByMarriage;

  /// Relationship category name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get labelCatProfessional;

  /// Relationship category name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get labelCatEducational;

  /// Relationship category name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get labelCatSocial;

  /// Relationship category name. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get labelCatService;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'New relationship'**
  String get titleNewRelationship;

  /// Dialog title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Edit relationship'**
  String get titleEditRelationship;

  /// Text field label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Relationship name'**
  String get labelRelationshipName;

  /// Validation error. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'That relationship already exists'**
  String get errorRelationshipExists;

  /// Dialog title. UI chrome. The English is 25 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Reset relationship names?'**
  String get titleResetRelationshipNames;

  /// Dialog body. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Your custom list will be replaced by the built-in relationship names.'**
  String get descResetRelationshipNames;

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Relationship names'**
  String get titleRelationshipNames;

  /// Info card. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'These labels appear as chips when you link two contacts, under whichever of the seven categories they belong to. You can still type any label you like. Editing them here does not change relationships you have already saved.'**
  String get descRelationshipNamesInfo;

  /// Row title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Add a relationship'**
  String get actionAddRelationshipName;

  /// Row subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Add a name to offer when linking contacts'**
  String get descAddRelationshipName;

  /// Empty state. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'No relationship names yet. Add one, or reset to the defaults from the top-right.'**
  String get emptyNoRelationshipNames;

  /// Section title with count. UI chrome. The English can reach 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Relationships ({count})'**
  String labelRelationshipsCount(int count);

  /// Card title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Contact counts'**
  String get labelContactCounts;

  /// Card subtitle when permission is missing. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Grant contacts permission to count device contacts'**
  String get descGrantContactsToCount;

  /// Counts line. {device} and {app} are numbers or a dash. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Device: {device}  ·  App: {app}'**
  String descDeviceAppCounts(String device, String app);

  /// Card title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Search index'**
  String get labelSearchIndex;

  /// Progress text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Checking search index...'**
  String get msgCheckingSearchIndex;

  /// Status text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Index healthy — all contacts are findable'**
  String get descIndexHealthy;

  /// Status text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 contact has stale search keys} other{{count} contacts have stale search keys}}'**
  String descIndexStale(int count);

  /// Button. UI chrome — keep to one word.
  ///
  /// In en, this message translates to:
  /// **'Rebuild'**
  String get actionRebuild;

  /// Reason in the system fingerprint prompt. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to export your secret contacts'**
  String get descAuthExportSecret;

  /// Snackbar. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Authentication required to export secret contacts'**
  String get errorAuthRequiredExportSecret;

  /// Snackbar. {path} is the saved file location. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Exported secret contacts to {path}'**
  String msgExportedSecretTo(String path);

  /// Snackbar. {error} is the technical reason. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Failed to export secret contacts: {error}'**
  String errorExportSecretFailed(String error);

  /// Screen title. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Secret Contacts & Export'**
  String get titleSecretContactsExport;

  /// Switch title. UI chrome. The English is 33 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Include secret contacts in export'**
  String get labelIncludeSecretInExport;

  /// Switch subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'When off, standard VCF exports skip contacts flagged as secret'**
  String get descIncludeSecretInExport;

  /// Row title. UI chrome. The English is 22 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Export secret contacts'**
  String get labelExportSecretContacts;

  /// Row subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Save a separate VCF file containing only secret contacts (gated by auth)'**
  String get descExportSecretContacts;

  /// Screen title. UI chrome. The English is 26 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Spoken Caller Announcement'**
  String get titleSpokenAnnouncement;

  /// Switch subtitle. The two quoted examples show the English and Malayalam voices; keep them as they are. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Announce caller\'s name over ringtone (\"Amma calling\" / \"അമ്മ വിളിക്കുന്നു\")'**
  String get descSpokenAnnouncementSwitch;

  /// Switch subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Suppress spoken announcements during quiet hours'**
  String get descSuppressDuringQuiet;

  /// Row title and dialog title. UI chrome. The English is 24 characters and is listed in label_length_test.dart's exceptions.
  ///
  /// In en, this message translates to:
  /// **'Test spoken announcement'**
  String get labelTestAnnouncement;

  /// Row subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Preview English or Malayalam voice announcement'**
  String get descTestAnnouncement;

  /// Time picker help text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'SELECT QUIET HOURS START TIME'**
  String get hintQuietStartTimeGeneric;

  /// Time picker help text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'SELECT QUIET HOURS END TIME'**
  String get hintQuietEndTimeGeneric;

  /// Dialog text. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Enter caller name to test:'**
  String get descEnterCallerNameToTest;

  /// Text field hint. Keep both sample names. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Amma or അമ്മ'**
  String get hintCallerNameExample;

  /// Button. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Play Test'**
  String get actionPlayTest;

  /// Screen title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Post-call Options'**
  String get titlePostCallOptions;

  /// Switch title. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Ask after calls'**
  String get labelAskAfterCalls;

  /// Switch subtitle. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Show the “How did it go?” sheet when a call ends'**
  String get descAskAfterCalls;

  /// Text field hint. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mentor'**
  String get hintRelationshipNameExample;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Help & User Guides'**
  String get helpHomeText1;

  /// Help: heading. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Calling & Dialer'**
  String get helpHomeHeading1;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'T9 Dialing & Malayalam'**
  String get helpHomeTitle1;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'How multi-script T9 search works and where Malayalam vowels (അ to അഃ) are mapped.'**
  String get helpHomeSub1;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Calling & In-Call Controls'**
  String get helpHomeTitle2;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Conference merge, hold and swap, dual-SIM options, smart redial, and spoken caller names.'**
  String get helpHomeSub2;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Call Screening & Blocking'**
  String get helpHomeTitle3;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Blocking a number before it rings, blocked unknown callers, and why the default dialer role is needed.'**
  String get helpHomeSub3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Caller ID & Spam Filter'**
  String get helpHomeTitle4;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Labelling unknown callers, ringing suspected spam silently, and marking a number as spam.'**
  String get helpHomeSub4;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Call Context & Notes'**
  String get helpHomeTitle5;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Pre-call summary, \"Likely to answer now\", and the notes you write after a call.'**
  String get helpHomeSub5;

  /// Help: heading. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Organization & Sharing'**
  String get helpHomeHeading2;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Relationship Spheres'**
  String get helpHomeTitle6;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The 7 categories from Immediate Family to Service, your own labels, and quiet hours.'**
  String get helpHomeSub6;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Groups & Tags'**
  String get helpHomeTitle7;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Building groups, group ringtones, the tag cloud, and selecting many contacts at once.'**
  String get helpHomeSub7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Contacts & Merge'**
  String get helpHomeTitle8;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'How identical names, phones, and emails are detected and merged without data loss.'**
  String get helpHomeSub8;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Sharing & Card Scanning'**
  String get helpHomeTitle9;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'QR contact codes, the on-device business card scanner, and sharing over Bluetooth.'**
  String get helpHomeSub9;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Import & Export Files'**
  String get helpHomeTitle10;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'CSV and vCard files in and out, and AirQR for sending more than one QR code can hold.'**
  String get helpHomeSub10;

  /// Help: heading. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Protection'**
  String get helpHomeHeading3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Privacy, Security & Vault'**
  String get helpHomeTitle11;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Secret contacts vault, biometric/PIN protection, screenshot guard, and security audit log.'**
  String get helpHomeSub11;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Biometric Lock Details'**
  String get helpHomeTitle12;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Every place the app asks for your fingerprint or face, and what happens without a screen lock.'**
  String get helpHomeSub12;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'App Lock & PIN'**
  String get helpHomeTitle13;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The three lock modes, setting an App PIN, and the recovery code if you forget it.'**
  String get helpHomeSub13;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Permissions Explained'**
  String get helpHomeTitle14;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'What each permission is for, which are optional, and what stops working if you say no.'**
  String get helpHomeSub14;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Emergency Info Card'**
  String get helpHomeTitle15;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Setting lock-screen medical details and emergency contacts for first responders.'**
  String get helpHomeSub15;

  /// Help: heading. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Sync & Backups'**
  String get helpHomeHeading4;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Local Wi-Fi P2P Device Sync'**
  String get helpHomeTitle16;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'How direct device-to-device Wi-Fi transfer works with end-to-end encryption and zero cloud.'**
  String get helpHomeSub16;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Phonebook & Call Log Sync'**
  String get helpHomeTitle17;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Merging or mirroring contacts and call history with Android system storage.'**
  String get helpHomeSub17;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync & Google Drive'**
  String get helpHomeTitle18;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Two-way online sync, encrypted cloud backups, WebDAV setup, and vault privacy.'**
  String get helpHomeSub18;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Offline Backup & Restore'**
  String get helpHomeTitle19;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Exporting encrypted backup files, password safety, and restoring on a new phone.'**
  String get helpHomeSub19;

  /// Help: heading. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Personalization & Tools'**
  String get helpHomeHeading5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Look, Sound & Region'**
  String get helpHomeTitle20;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Theme and accent colour, fonts and text size, ringtones and vibration, and the default country.'**
  String get helpHomeSub20;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contact Tools'**
  String get helpHomeTitle21;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Temporary self-deleting contacts, connected messaging apps, and the search index.'**
  String get helpHomeSub21;

  /// Help: heading. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpHomeHeading6;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'FAQs & Troubleshooting Guide'**
  String get helpHomeTitle22;

  /// Help: topic card subtitle. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Direct answers to top questions: permissions, default dialer, quiet hours, and search indexing.'**
  String get helpHomeSub22;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Help Center & Knowledge Base'**
  String get helpHomeText2;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Browse in-depth guides and solutions for all features of SreerajP Contacts Sphere.'**
  String get helpHomeText3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Groups & tags'**
  String get helpGroupsTagsTitle1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Groups and tags are two different ways to sort the same address book. A contact belongs to groups you build by hand, and carries tags you type as short labels. Both are yours — the app never creates one on its own.'**
  String get helpGroupsTagsIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get helpGroupsTagsTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Open the Contacts tab and tap the group icon in the top bar to see all your groups.'**
  String get helpGroupsTagsBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Create a group, give it a name, and add members. A contact can be in more than one group.'**
  String get helpGroupsTagsBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A group can carry its own ringtone. Pick one from the phone\'s ringtones or from an audio file in your folders.'**
  String get helpGroupsTagsBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The group ringtone is used for members who do not have their own ringtone set. A ringtone on the contact always wins.'**
  String get helpGroupsTagsBullet4;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get helpGroupsTagsTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A tag is a short word you attach to a contact while editing them — \"plumber\", \"school\", \"trek group\". There is no fixed list; type whatever fits.'**
  String get helpGroupsTagsBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The Tags tab at the bottom of the app shows every tag in use as a cloud. A tag used by more contacts is drawn larger.'**
  String get helpGroupsTagsBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tap a tag to see everyone who carries it. From there you can call, message, or open any of them.'**
  String get helpGroupsTagsBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tags also work as an exception list for quiet hours, so a whole tag can be allowed to ring through.'**
  String get helpGroupsTagsBullet8;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Working on many contacts at once'**
  String get helpGroupsTagsTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Long-press a contact in the list to start selecting. Tap more contacts to add them to the selection.'**
  String get helpGroupsTagsBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The top bar then offers \"Select all\" and \"Delete selected\", so you can clear out many contacts in one step.'**
  String get helpGroupsTagsBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tap the cross in the top bar to leave selection mode without changing anything.'**
  String get helpGroupsTagsBullet11;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: use a group when the set is fixed and you want one ringtone for it. Use a tag when you only want to find those people again later.'**
  String get helpGroupsTagsFooter;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'App lock & PIN'**
  String get helpAppLockTitle1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'App lock puts a screen in front of the whole app when you open it. You pick how it is unlocked under Settings → Security → App lock. There are three choices.'**
  String get helpAppLockIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'The three modes'**
  String get helpAppLockTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Off — the app opens straight away. Secret contacts still ask for an unlock separately.'**
  String get helpAppLockBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Device lock — uses your phone\'s own fingerprint, face, or screen-lock PIN. This choice is greyed out until you set a screen lock in Android settings.'**
  String get helpAppLockBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'App PIN — a separate PIN just for this app, typed on a keypad inside the app. Useful when other people know your phone PIN.'**
  String get helpAppLockBullet3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Setting up an App PIN'**
  String get helpAppLockTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Choose a PIN of 4 to 6 digits and confirm it.'**
  String get helpAppLockBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You are then shown a one-time recovery code. Write it down or copy it somewhere safe — it is shown once and never again.'**
  String get helpAppLockBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The PIN is not stored as you typed it, and nobody can read it back out of the app.'**
  String get helpAppLockBullet6;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'If you forget the App PIN'**
  String get helpAppLockTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Forgot PIN?\" on the lock screen and enter your recovery code.'**
  String get helpAppLockBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A correct code switches App lock off and lets you in. Set a new PIN afterwards if you still want the lock.'**
  String get helpAppLockBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Without the recovery code there is no way past the lock. That is deliberate — a back door for you would be a back door for anyone.'**
  String get helpAppLockBullet9;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'When you are asked again'**
  String get helpAppLockTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The lock screen returns when you come back to the app after leaving it, not on every screen inside it.'**
  String get helpAppLockBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The back gesture cannot dismiss it. Only a correct unlock, or the recovery code, lets you through.'**
  String get helpAppLockBullet11;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'App lock guards the door. Your secret contacts, backups, and sync have their own unlock on top of it — see the Biometric lock guide.'**
  String get helpAppLockFooter;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contact tools'**
  String get helpContactToolsTitle1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Three smaller tools that are easy to miss: contacts that delete themselves, the messaging apps a contact can be reached on, and the search index that makes the dialer find people fast.'**
  String get helpContactToolsIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Ephemeral (temporary) contacts'**
  String get helpContactToolsTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'While adding or editing a contact, switch on \"Ephemeral contact\". The entry then removes itself later, on its own.'**
  String get helpContactToolsBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Choose how long it lives: 2 hours, 24 hours, 7 days, or \"Auto-delete after 1 call\".'**
  String get helpContactToolsBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Good for a delivery driver, a cab, or a one-off seller — the number is there when you need it and gone afterwards.'**
  String get helpContactToolsBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Opening the contact shows a banner counting down to its removal. From there you can add another 24 hours, or tap to keep it for good.'**
  String get helpContactToolsBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The app checks about once a minute, so a contact disappears shortly after its time is up rather than at the exact second.'**
  String get helpContactToolsBullet5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Connected apps'**
  String get helpContactToolsTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If a messenger such as WhatsApp, Telegram or Arattai has synced itself against a contact on your phone, that contact shows a row of those apps.'**
  String get helpContactToolsBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tap one to open the chat or call in that app directly. Nothing is sent by this app — it simply opens the other one.'**
  String get helpContactToolsBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The row is read from your phone\'s own address book, so it appears only for contacts linked to a device contact, and only while contacts permission is granted.'**
  String get helpContactToolsBullet8;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contact counts & search index'**
  String get helpContactToolsTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Contacts → Contact counts & search index shows how many contacts are on the phone and how many are in the app — the quickest way to see whether a sync worked.'**
  String get helpContactToolsBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The search index is what makes T9 keypad search, transliterated search, and name search fast.'**
  String get helpContactToolsBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The screen tells you either \"Index healthy — all contacts are findable\" or how many contacts have stale search keys.'**
  String get helpContactToolsBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'When some are stale, a Rebuild button appears. Tap it and the keys are rebuilt for the whole address book.'**
  String get helpContactToolsBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Rebuild this if search stops finding a contact you know is saved, or after restoring an old backup.'**
  String get helpContactToolsBullet13;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: an ephemeral contact is deleted for real when its time is up. If you may want the number later, tap \"Keep permanently\" on the banner before it goes.'**
  String get helpContactToolsFooter;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Call context & notes'**
  String get helpCallerIntelligenceTitle1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The app reads your own call history to tell you a little about a person before you ring them, while they ring you, and after you hang up. All of it is worked out on this phone from data you already have.'**
  String get helpCallerIntelligenceIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Before you call'**
  String get helpCallerIntelligenceTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Open a contact and you see a short summary: when you last spoke, how long that call lasted, and what you noted about it.'**
  String get helpCallerIntelligenceBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If the contact has an address with a city, the summary also shows the local time there — useful before calling someone in another country.'**
  String get helpCallerIntelligenceBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'When there is enough history, it suggests the time of day this person usually answers.'**
  String get helpCallerIntelligenceBullet3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'\"Likely to answer now\"'**
  String get helpCallerIntelligenceTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The dialer shows a short row of contacts above the keypad. You choose what fills it in Settings → Dialer top contacts: Most recent, Family & friends, or Likely to answer now.'**
  String get helpCallerIntelligenceBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'\"Likely to answer now\" puts the people who usually pick up at this hour first. It is worked out from your own Recents — how often calls at this time of day were answered.'**
  String get helpCallerIntelligenceBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'This only changes the order of the row. The app never dials on its own here — every call is still a tap you make.'**
  String get helpCallerIntelligenceBullet6;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'While the phone is ringing'**
  String get helpCallerIntelligenceTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'For a saved contact, the call screen can show their relationship, how long it has been since you last spoke, and a birthday or anniversary coming up.'**
  String get helpCallerIntelligenceBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A pending reminder you set for that person is shown too, so you remember why you meant to speak.'**
  String get helpCallerIntelligenceBullet8;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'After the call'**
  String get helpCallerIntelligenceTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'When a call ends, a \"How did it go?\" sheet can appear. Note how the call went, write down what you discussed, and set a follow-up reminder.'**
  String get helpCallerIntelligenceBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You can dictate the note instead of typing it — tap the microphone and speak. Speech is turned into text on the phone.'**
  String get helpCallerIntelligenceBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Everything you save joins that contact\'s timeline, which is what the next pre-call summary reads.'**
  String get helpCallerIntelligenceBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If you would rather not be asked, turn the sheet off under Settings → SIM & calling → Post-call options.'**
  String get helpCallerIntelligenceBullet12;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Privacy: none of this leaves the phone. There is no lookup service behind it — the app only reads your own contacts, call log, and notes from its encrypted database.'**
  String get helpCallerIntelligenceFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Biometric lock'**
  String get helpBiometricsText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'SreerajP Contacts Sphere can ask for your fingerprint or face before it shows or moves your most private data. It uses your phone\'s own lock — the app never sees or stores your fingerprint or face.'**
  String get helpBiometricsIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Where you are asked'**
  String get helpBiometricsTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Viewing your secret contacts. These are hidden from the normal contact list until you unlock them.'**
  String get helpBiometricsBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Exporting secret contacts, so a private contact cannot be sent out of the app without your say-so.'**
  String get helpBiometricsBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Opening \"Sync to Another Device\", because a sync can include your secret contacts.'**
  String get helpBiometricsBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Opening \"Backup & Restore\", because a backup can include them too.'**
  String get helpBiometricsBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Opening the audit log, which holds a full before-and-after record of your contacts.'**
  String get helpBiometricsBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Accepting a contact someone sends you over Bluetooth.'**
  String get helpBiometricsBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Opening the app at all, if you set App lock to \"Device lock\" under Settings → Security.'**
  String get helpBiometricsBullet7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'What counts as \"you\"'**
  String get helpBiometricsTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Any fingerprint or face you have set up on the phone is accepted.'**
  String get helpBiometricsBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If you have not set up a fingerprint or face, the phone falls back to your screen-lock PIN, pattern, or password.'**
  String get helpBiometricsBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'App lock can instead use an App PIN, which is separate from the phone\'s lock. That one is checked by the app itself — see the \"App lock & PIN\" guide.'**
  String get helpBiometricsBullet10;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get helpBiometricsTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The check is handled by Android, not by SreerajP Contacts Sphere. The app only learns whether the unlock passed or failed.'**
  String get helpBiometricsBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'This works offline. Nothing about your fingerprint or face ever leaves the phone.'**
  String get helpBiometricsBullet12;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: set up a screen lock (fingerprint, face, or PIN) in Android settings. With no lock at all the check cannot run, so sync and backup warn you and then let you decide whether to go on.'**
  String get helpBiometricsFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get helpBackupText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A backup saves everything in the app into one file that you keep. You can use it to move to a new phone or to recover after a reset — even if the new app was installed from a different source.'**
  String get helpBackupIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'What the backup holds'**
  String get helpBackupTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'All contacts and their details, call history, groups, relationships, and blocked / spam numbers.'**
  String get helpBackupBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contact photos and calling-card images are included inside the file.'**
  String get helpBackupBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your app settings, such as theme and accent color.'**
  String get helpBackupBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your emergency info card, with its emergency contacts and the \"show on lock screen\" switches.'**
  String get helpBackupBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Custom ringtones are not included — they point at files on this phone that would not exist elsewhere.'**
  String get helpBackupBullet5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your password is the key'**
  String get helpBackupTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The backup file is locked with a password you choose. The app does not store it anywhere.'**
  String get helpBackupBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You need the same password to restore — on this phone or any other. Keep it somewhere safe.'**
  String get helpBackupBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If you lose the password, the file cannot be opened. There is no way to recover it — that is what keeps your data private.'**
  String get helpBackupBullet8;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Restoring replaces everything'**
  String get helpBackupTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Restoring DELETES what is currently in the app and rebuilds it as an exact copy of the backup.'**
  String get helpBackupBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'It is not a merge. If you want to combine two phones without losing data, use \"Sync to Another Device\" instead.'**
  String get helpBackupBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Restore a backup made with the same app version. A backup from a very different version may be refused.'**
  String get helpBackupBullet11;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: after making a backup, the app opens the share sheet so you can save the file to Files, Drive, or send it to yourself. Store it somewhere other than this phone.'**
  String get helpBackupFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'T9 Dialing & Malayalam'**
  String get helpT9DialingText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'SreerajP Contacts Sphere features a smart multi-script T9 dialpad. You can search your contacts seamlessly using English or regional script key presses (Malayalam, Devanagari, etc.).'**
  String get helpT9DialingIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Malayalam Vowels Mapping (അ to അഃ)'**
  String get helpT9DialingTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Key 2 (ക-ങ): Vowels അ, ആ + Matras ാ, ി, ീ'**
  String get helpT9DialingBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Key 3 (ച-ഞ): Vowels ഉ, ഊ, ഋ + Matras ു, ൂ, ൃ'**
  String get helpT9DialingBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Key 4 (ട-ണ): Vowels എ, ഏ, ഐ + Matras െ, േ, ൈ'**
  String get helpT9DialingBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Key 5 (ത-ന): Vowels ഒ, ഓ, ഔ + Matras ൊ, ോ, ൌ, ൗ'**
  String get helpT9DialingBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Key 9 (ള-റ): Anusvaram & Visargam (ം, ഃ) + Chillu letters (ൺ, ൻ, ർ, ൽ, ൾ, ൿ)'**
  String get helpT9DialingBullet5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Why Vowels Aren\'t Printed on Key Labels'**
  String get helpT9DialingTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Key legends display consonant group ranges (e.g. ക-ങ, ച-ഞ) to keep the dialpad clean and easy to read.'**
  String get helpT9DialingBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Even though vowels are not printed on the button face, all vowels (അ-ഔ), matras, and chillu letters are fully mapped and active in T9 search.'**
  String get helpT9DialingBullet7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Manglish & Transliteration Search'**
  String get helpT9DialingTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'English T9 key presses automatically match Malayalam names. For example, typing 2-6-4-5 (A-N-I-L) will match both \"Anil\" and \"അനിൽ\".'**
  String get helpT9DialingBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'To change the script shown on the keys, use the \"Dialpad script\" card on the main Settings page.'**
  String get helpT9DialingBullet9;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: the \"Dialpad script\" card offers Auto, Malayalam, Devanagari, Cyrillic, Arabic, Greek, or None. Auto follows the app language. Whichever you pick, search still matches every script — the setting only changes what is printed on the keys.'**
  String get helpT9DialingFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync & Backup'**
  String get helpCloudSyncText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'SreerajP Contacts Sphere connects with Google, Microsoft, and CardDAV/WebDAV servers. You can use a single provider or decouple them — syncing live contacts with one service while backing up your encrypted database to another.'**
  String get helpCloudSyncIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contact Sync vs Cloud Backup'**
  String get helpCloudSyncTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Online Contact Sync (Live 2-Way): synchronizes individual contact cards (names, phone numbers, emails) directly with Google People API, Microsoft Graph Contacts, or CardDAV address books. Synced contacts appear in your online address book.'**
  String get helpCloudSyncBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Cloud Backup: exports a full, password-encrypted .csbak file containing your complete database (all contacts, call history, call notes, tags, settings, and emergency info) to cloud file storage (Google Drive AppData, Microsoft OneDrive, or WebDAV).'**
  String get helpCloudSyncBullet2;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Mixing cloud providers'**
  String get helpCloudSyncTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You can use Google for live contact sync while storing encrypted cloud backups on Microsoft OneDrive or a self-hosted WebDAV server.'**
  String get helpCloudSyncBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'In Settings → Online Provider Sync, toggle \"Contact Sync: On\" and \"Cloud Backup: Off\" for your Google account.'**
  String get helpCloudSyncBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Add your Microsoft or WebDAV account separately and select it when uploading encrypted cloud backups in Settings → Encrypted Cloud Backup.'**
  String get helpCloudSyncBullet5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get helpCloudSyncTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Secret Vault Contacts: contacts saved as Secret in SreerajP Contacts Sphere are app-only and are NEVER uploaded or synced to online contact providers (Google Contacts, Outlook, or CardDAV).'**
  String get helpCloudSyncBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Payload: Cloud backup files (.csbak) are encrypted locally using PBKDF2 and AES-GCM with your personal passphrase before upload. The cloud provider cannot read your backup data.'**
  String get helpCloudSyncBullet7;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: You can manage all configured accounts under Settings → Online Provider Sync. Each account can have independent toggles for live contact sync and cloud backup.'**
  String get helpCloudSyncFooter;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Look, sound & region'**
  String get helpPersonalizationTitle1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Almost everything about how the app looks, what it sounds like, and how it reads phone numbers can be changed. Here is where each setting lives.'**
  String get helpPersonalizationIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Theme and colour'**
  String get helpPersonalizationTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Appearance → Theme Mode: Light, Dark, or System. System follows your phone\'s own dark-mode setting.'**
  String get helpPersonalizationBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Appearance → Accent Color: pick a preset or build your own colour. The preview updates as you choose.'**
  String get helpPersonalizationBullet2;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Font and text size'**
  String get helpPersonalizationTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Appearance → Typography & Text Size sets the font and how large text is drawn.'**
  String get helpPersonalizationBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Three Malayalam-capable fonts are built in — Manjari, Anek Malayalam, and Noto Sans Malayalam. Each covers Malayalam and English, so names in either script stay readable.'**
  String get helpPersonalizationBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The fonts ship inside the app. Nothing is downloaded, and this works with no internet.'**
  String get helpPersonalizationBullet5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'How the contact list reads'**
  String get helpPersonalizationTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Contacts → Display & formatting sets the sort order (by first name or last name).'**
  String get helpPersonalizationBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The same screen can hide contacts that have no phone number, which tidies a list imported from an email account.'**
  String get helpPersonalizationBullet7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Ringtones, volume and vibration'**
  String get helpPersonalizationTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Ringtone → Volume & vibration sets the ringtone volume and whether incoming calls vibrate.'**
  String get helpPersonalizationBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Ringtone → Per-SIM ringtones gives SIM 1 and SIM 2 different tones, so you know which line is ringing.'**
  String get helpPersonalizationBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A group can carry its own ringtone, and any contact can be given one while editing them.'**
  String get helpPersonalizationBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'When several apply, the most specific wins: the contact\'s own tone first, then their group\'s, then the SIM\'s.'**
  String get helpPersonalizationBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Ringtones are not included in backups or in a sync to another phone, because they point at a sound file on this phone.'**
  String get helpPersonalizationBullet12;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Default country'**
  String get helpPersonalizationTitle6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Default country tells the app which country your plain, un-prefixed numbers belong to.'**
  String get helpPersonalizationBullet13;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'It is what lets the app see that a call from +91 98765 43210 is the same person as the 98765 43210 saved in your contacts.'**
  String get helpPersonalizationBullet14;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Blocked numbers are matched the same way, so a number blocked in local form still blocks the international form.'**
  String get helpPersonalizationBullet15;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Getting this wrong is the usual reason a saved contact shows up as an unknown caller.'**
  String get helpPersonalizationBullet16;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: theme, accent colour, fonts and the default country travel to another phone on a sync. Ringtones and SIM choices stay behind, because they belong to this handset.'**
  String get helpPersonalizationFooter;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Caller ID & spam filter'**
  String get helpCallerIdSpamTitle1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'When a number that is not in your contacts calls, the app tries to say something useful about it, and can make a suspected spam call ring quietly instead of loudly. Both are switches you control, and both work entirely on this phone.'**
  String get helpCallerIdSpamIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Caller identification'**
  String get helpCallerIdSpamTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Turn it on under Settings → SIM & calling → Identification → \"Caller identification\".'**
  String get helpCallerIdSpamBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'An unknown caller gets a label built from what can be worked out locally: the telemarketing and service number series, numbers you yourself marked as spam, and the network\'s own verified-caller flag when it sends one.'**
  String get helpCallerIdSpamBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The badge appears on the call screen — red for suspected spam, a softer colour for a telemarketing or service number.'**
  String get helpCallerIdSpamBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'No number is ever looked up on the internet. There is no caller ID database behind this and nothing is uploaded.'**
  String get helpCallerIdSpamBullet4;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Filter suspected spam'**
  String get helpCallerIdSpamTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The second switch on the same screen, \"Filter suspected spam\", makes flagged callers ring silently instead of loudly.'**
  String get helpCallerIdSpamBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The call still comes through and still lands in Recents. You are simply not disturbed by it.'**
  String get helpCallerIdSpamBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Use this when you want to see who called but not be interrupted. Use blocking when you do not want the call at all.'**
  String get helpCallerIdSpamBullet7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Block unknown'**
  String get helpCallerIdSpamTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Contacts → Blocked numbers has a \"Block unknown\" switch for calls that arrive with no number or a hidden one.'**
  String get helpCallerIdSpamBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'With it on, those calls are rejected before your phone rings, and are still written into Recents as blocked so you can see that they happened.'**
  String get helpCallerIdSpamBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'It does not affect a number you simply have not saved — only calls with no caller number at all.'**
  String get helpCallerIdSpamBullet10;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Marking a number as spam'**
  String get helpCallerIdSpamTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Long-press a call in Recents and choose \"Mark as spam\". The same action reads \"Not spam\" afterwards, so you can take the mark off again.'**
  String get helpCallerIdSpamBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A spam mark is separate from blocking. The number can still ring you — it is now labelled, and the spam filter can silence it if that switch is on.'**
  String get helpCallerIdSpamBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your own marks feed the caller identification label, so the next call from that number is recognised.'**
  String get helpCallerIdSpamBullet13;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: identification and spam filtering both need the app to be your default phone app, because Android only lets the default dialer inspect a call before it rings.'**
  String get helpCallerIdSpamFooter;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Import & export files'**
  String get helpImportExportTitle1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You can move contacts in and out of the app as ordinary files — a spreadsheet-friendly CSV, or a vCard (.vcf) that any phone or computer address book understands.'**
  String get helpImportExportIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Where to find it'**
  String get helpImportExportTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Open the Contacts tab, tap the three-dot menu in the top bar, and choose \"Import / Export\".'**
  String get helpImportExportBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Four choices appear: Import CSV, Export CSV, Import vCard (.vcf), and Export vCard (.vcf).'**
  String get helpImportExportBullet2;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Importing'**
  String get helpImportExportTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You pick the file yourself through the system file picker. The app never browses your storage on its own.'**
  String get helpImportExportBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Imported contacts are added to the app. When the import finishes you are told how many came in.'**
  String get helpImportExportBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If the file brings in people you already have, run Contacts → menu → \"Find Duplicates\" afterwards to tidy up.'**
  String get helpImportExportBullet5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Exporting'**
  String get helpImportExportTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'An export writes a file and then opens the system share sheet, so you decide where it goes.'**
  String get helpImportExportBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'An export file is plain and not password-protected. Treat it like a copy of your address book and delete it when you are done.'**
  String get helpImportExportBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Secret contacts are left out of a normal export unless you turn on \"Include secret contacts in export\" under Settings → Contacts → Secret contacts & export.'**
  String get helpImportExportBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'That same screen has \"Export secret contacts\", which saves a separate file holding only the secret ones. It asks for your fingerprint, face, or PIN first.'**
  String get helpImportExportBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'For a full, password-locked copy of everything — call history, photos, settings and all — use Settings → Backup & Restore instead.'**
  String get helpImportExportBullet10;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'AirQR: sending more than one QR code can hold'**
  String get helpImportExportTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A single QR code cannot hold a photo or a long contact card. AirQR splits the data across many frames and plays them as an animated QR code.'**
  String get helpImportExportBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Open a contact, choose \"Share as QR code\", then tap the Air-Gap Stream button in that dialog to start the animation.'**
  String get helpImportExportBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'On the other phone, open Contacts → menu → \"Scan QR code\" and point the camera at the animation. It shows the progress while the frames come in and saves the contact once they are all there.'**
  String get helpImportExportBullet13;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent over Bluetooth, Wi-Fi or the internet — the only path is the camera looking at the screen. Keep both phones steady until it completes.'**
  String get helpImportExportBullet14;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: vCard (.vcf) is the safer choice for moving to another phone, because it keeps multiple numbers, emails and photos. CSV is best when you want to open the list in a spreadsheet.'**
  String get helpImportExportFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Privacy, Security & Vault'**
  String get helpPrivacySecurityText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'SreerajP Contacts Sphere is built from the ground up to guarantee uncompromising privacy, encrypted local storage, and granular security controls.'**
  String get helpPrivacySecurityIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Secret Contacts Vault'**
  String get helpPrivacySecurityTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'What is a Secret Contact? Any contact marked as \"Secret\" is completely hidden from the main contact list, T9 dialer searches, and general export files.'**
  String get helpPrivacySecurityBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Seeing them: tap the padlock icon in the top bar of the Contacts tab and unlock with your fingerprint, face, or device PIN. The list then shows the secret contacts alongside the rest.'**
  String get helpPrivacySecurityBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tap the padlock again to hide them. They also hide when you leave the contact list, so they are never left showing behind you.'**
  String get helpPrivacySecurityBullet3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Biometrics & App PIN Protection'**
  String get helpPrivacySecurityTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You can secure the entire app or sensitive sections using your device\'s biometric sensors (fingerprint / face unlock).'**
  String get helpPrivacySecurityBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If your phone has no biometric hardware, or you want a code separate from your phone PIN, set an App PIN under Settings → Security → App lock. See the \"App lock & PIN\" guide.'**
  String get helpPrivacySecurityBullet5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Guard'**
  String get helpPrivacySecurityTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Screenshot guard blocks screenshots, screen recording, and the preview Android shows in Recents, while you are on a screen holding private data.'**
  String get helpPrivacySecurityBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Turn it on or off under Settings → Security → Screenshot guard.'**
  String get helpPrivacySecurityBullet7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Security Audit Log'**
  String get helpPrivacySecurityTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The audit log records every change to a contact — created, edited, or deleted — with what it looked like before and after.'**
  String get helpPrivacySecurityBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Open an entry to see exactly what changed, and undo it if the change was a mistake.'**
  String get helpPrivacySecurityBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Entries are chained together with a cryptographic hash, so an entry cannot be quietly altered or removed without it showing.'**
  String get helpPrivacySecurityBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Security → Audit log, which asks for your unlock first. It can also export a signed copy of the log.'**
  String get helpPrivacySecurityBullet11;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Security principle: everything is stored on this phone in a database encrypted with a key held in the phone\'s hardware keystore. There is no tracking, no advertising, and no server of ours to talk to.'**
  String get helpPrivacySecurityFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Sharing & Card Scanning'**
  String get helpContactSharingText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Quickly exchange contact information using modern digital QR codes, on-device business card OCR camera scanning, and offline Bluetooth LE.'**
  String get helpContactSharingIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'QR Code Sharing & Scanner'**
  String get helpContactSharingTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Show a QR code: open a contact, tap Share, and choose \"Share as QR code\". A standard vCard QR appears on screen for someone else to scan.'**
  String get helpContactSharingBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code: open the Contacts tab, tap the three-dot menu, and choose \"Scan QR code\" to open the camera.'**
  String get helpContactSharingBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'What was scanned is shown to you first. You save it as a new contact only after looking at it.'**
  String get helpContactSharingBullet3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Business Card Scanner (On-Device AI)'**
  String get helpContactSharingTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Photograph any paper business card with your phone\'s camera.'**
  String get helpContactSharingBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'ContactSphere\'s optical character recognition (OCR) scans the image in seconds to extract names, phone numbers, emails, addresses, and company titles.'**
  String get helpContactSharingBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You can review, edit, or untick any field before saving to your address book.'**
  String get helpContactSharingBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'100% On-Device Privacy: The card photo is processed locally on your phone and is never uploaded to any cloud server.'**
  String get helpContactSharingBullet7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Offline Bluetooth LE Share'**
  String get helpContactSharingTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Share contacts directly with nearby Android devices running ContactSphere without internet or pairing codes.'**
  String get helpContactSharingBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The sender opens a contact, taps Share, and chooses \"Share via Bluetooth\". The receiver opens the Contacts tab, taps the three-dot menu, and chooses \"Bluetooth transfer\".'**
  String get helpContactSharingBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The receiving phone shows a challenge you must confirm, so a contact cannot be pushed onto your phone without you agreeing.'**
  String get helpContactSharingBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Devices automatically discover each other and transfer the contact securely over low-energy radio.'**
  String get helpContactSharingBullet11;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: every sharing method here uses the standard vCard format, which Android, iOS and desktop address books all understand. To send a whole address book as a file instead, see the Import & export guide.'**
  String get helpContactSharingFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Contacts & Merge'**
  String get helpDuplicateMergeText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Keep your address book clean and clutter-free with ContactSphere\'s intelligent duplicate detection and safe one-tap merging system.'**
  String get helpDuplicateMergeIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'How Duplicates are Detected'**
  String get helpDuplicateMergeTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Same phone number: two contacts share the same digits, or the same number once it is put into full international form.'**
  String get helpDuplicateMergeBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Same name: two contacts have the same full name, or the same name once it is transliterated — so \"Anil\" and \"അനിൽ\" are seen as one person.'**
  String get helpDuplicateMergeBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Matching spreads across a set: if A matches B and B matches C, all three are shown together as one set.'**
  String get helpDuplicateMergeBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Email addresses are deliberately not used, and neither are sound-alike name codes. Both produced wrong merges between unrelated people.'**
  String get helpDuplicateMergeBullet4;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Smart Merging Process'**
  String get helpDuplicateMergeTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Open the Contacts tab, tap the three-dot menu, and choose \"Find Duplicates\".'**
  String get helpDuplicateMergeBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Each set is shown as one card. The contact that will be kept is at the top; the others are ticked to be merged into it.'**
  String get helpDuplicateMergeBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Untick anyone who does not belong in the set, or tap a different row to keep that one instead.'**
  String get helpDuplicateMergeBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'All the different phone numbers, emails, addresses, birthdays and notes from the set are carried over into the contact you keep. Nothing is thrown away.'**
  String get helpDuplicateMergeBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Merge one set with its own Merge button, or use \"Merge all sets\" at the bottom to do the whole list at once.'**
  String get helpDuplicateMergeBullet9;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Safety & Reversibility'**
  String get helpDuplicateMergeTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Before merging everything at once, make a backup under Settings → Backup & Restore. A merge cannot be undone from the duplicates screen.'**
  String get helpDuplicateMergeBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If a merge was wrong, open the kept contact and edit it — the extra numbers and details are all still there, so you can move them back out into a new contact.'**
  String get helpDuplicateMergeBullet11;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: run \"Find Duplicates\" after a phonebook sync or a file import — that is when duplicates usually appear.'**
  String get helpDuplicateMergeFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contact Sync'**
  String get helpContactSyncText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Sync keeps the app and your phone in step. You control each direction yourself — nothing here runs automatically. Open it from Settings → Contacts → Device & cloud sync.'**
  String get helpContactSyncIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'The two normal actions'**
  String get helpContactSyncTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Add device contacts to app: copies the phone\'s address book into the app. It only adds or updates — it never deletes.'**
  String get helpContactSyncBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Add app contacts to device: copies your app contacts into the phone. It only adds or updates — it never deletes. Your \"Me\" contact and secret contacts are never sent to the phone.'**
  String get helpContactSyncBullet2;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Destructive sync'**
  String get helpContactSyncTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The two \"(destructive)\" actions make the target an exact copy of the source. As well as adding and updating, they delete extras — so use them with care. Each one asks you to confirm first.'**
  String get helpContactSyncBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Add device contacts to app (destructive): after importing, it deletes app contacts that came from the phone but are no longer on it. It never deletes your \"Me\" contact, your secret contacts, or any contact you created only in the app.'**
  String get helpContactSyncBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Add app contacts to device (destructive): after copying, it deletes device contacts that are not in the app. Device contacts that match your \"Me\" contact or a secret contact are never deleted, even though those are never copied to the phone.'**
  String get helpContactSyncBullet5;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Call log'**
  String get helpContactSyncTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The phone\'s call log syncs into Recents on its own — when the app starts, when you open Recents, and when a call ends. Calls made from another dialer, or while the app was closed, come in this way. You do not have to do anything.'**
  String get helpContactSyncBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Add device call log to app: brings in the phone\'s older call history in one go, further back than the automatic sync reaches. It skips calls the app already has, so running it again is safe.'**
  String get helpContactSyncBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Add device call log to app (destructive): clears Recents and rebuilds it from the phone\'s call log. Any call notes or feedback you saved in the app are lost.'**
  String get helpContactSyncBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'There is no \"app to device\" for the call log: Android owns the phone\'s call log and records calls on its own.'**
  String get helpContactSyncBullet9;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: a destructive sync cannot be undone. If you are unsure, make a backup first (Settings → Backup & Restore).'**
  String get helpContactSyncFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Call Screening & Blocking'**
  String get helpCallScreeningText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The app can turn a call away before your phone rings. Blocking is a list you build yourself, checked on this phone against the incoming number — nothing is looked up anywhere else.'**
  String get helpCallScreeningIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'How call screening works'**
  String get helpCallScreeningTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'When a call arrives, Android hands the number to the app\'s call screening service before the phone rings.'**
  String get helpCallScreeningBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If the number is on your blocked list, the call is rejected straight away — no ring, no vibration, no incoming screen.'**
  String get helpCallScreeningBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Numbers are matched after being put into full international form using your Default country, so a number blocked as 98765 43210 also blocks +91 98765 43210.'**
  String get helpCallScreeningBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A blocked call is still written into Recents with a \"Blocked\" mark, so you can see who tried.'**
  String get helpCallScreeningBullet4;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Blocking a number'**
  String get helpCallScreeningTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'From Recents: long-press the call and choose \"Block number\". The same action then reads \"Unblock number\".'**
  String get helpCallScreeningBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'During a call: tap Block on the call screen. This works while it is ringing and while you are talking.'**
  String get helpCallScreeningBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'By hand: Settings → Contacts → Blocked numbers, then add the number yourself.'**
  String get helpCallScreeningBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Blocking a number that is on a call right now hangs that call up immediately, wherever you blocked it from.'**
  String get helpCallScreeningBullet8;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Callers with no number'**
  String get helpCallScreeningTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Contacts → Blocked numbers also has a \"Block unknown\" switch, for calls that arrive with a hidden or withheld number.'**
  String get helpCallScreeningBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Those calls are rejected before ringing and still recorded in Recents as blocked.'**
  String get helpCallScreeningBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'It does not affect ordinary numbers you have not saved — only calls that carry no number at all.'**
  String get helpCallScreeningBullet11;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Silencing instead of blocking'**
  String get helpCallScreeningTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If you would rather see the call but not be disturbed, use \"Filter suspected spam\" under Settings → SIM & calling → Identification. Flagged callers then ring silently.'**
  String get helpCallScreeningBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'See the \"Caller ID & spam filter\" guide for how a caller gets flagged.'**
  String get helpCallScreeningBullet13;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Default phone app is required'**
  String get helpCallScreeningTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Android only lets the default phone app inspect a call before it rings. Without that role, blocking cannot happen early enough.'**
  String get helpCallScreeningBullet14;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Permissions shows whether the app already holds the role, and lets you ask for it.'**
  String get helpCallScreeningBullet15;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Privacy note: screening happens entirely on this phone, against your own list. No phone number is ever sent to a server, and there is no shared spam database behind it.'**
  String get helpCallScreeningFooter;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Permissions explained'**
  String get helpPermissionsTitle1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → Permissions lists everything the app can access, with a live status beside each one. This page explains what each is for, and what stops working if you say no.'**
  String get helpPermissionsIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Two kinds of permission'**
  String get helpPermissionsTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Explicit — Android asks you, and you can say no or change your mind later. These are the ones with Granted / Denied beside them.'**
  String get helpPermissionsBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Implicit — declared when the app is built and granted by the system at install. There is no prompt, because they cannot reach your personal data on their own.'**
  String get helpPermissionsBullet2;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'For calling'**
  String get helpPermissionsTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Default phone app — makes this the system dialer, so it can show its own in-call screen, full-screen incoming alerts, and screen calls before they ring. Without it, calling works but blocking and screening do not.'**
  String get helpPermissionsBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Phone & Call Log — place, answer and manage calls, and read back a call\'s real duration for Recents.'**
  String get helpPermissionsBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Foreground Call Service & Ringing — keeps a call alive and lets the app ring and show the incoming-call screen.'**
  String get helpPermissionsBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Screen off near ear — blanks the screen while the phone is against your ear so your cheek does not press buttons.'**
  String get helpPermissionsBullet6;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'For your contacts'**
  String get helpPermissionsTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contacts — read and sync your phone\'s address book. Without it, the app keeps its own contacts but cannot see or update the phone\'s.'**
  String get helpPermissionsBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Photos & Media — pick a profile photo from your gallery.'**
  String get helpPermissionsBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Camera — take a contact photo, scan a QR code, or scan a paper business card.'**
  String get helpPermissionsBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Microphone — dictate a call note instead of typing it.'**
  String get helpPermissionsBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Location — tag a contact with a place, and needed by Android for Bluetooth scanning on older versions.'**
  String get helpPermissionsBullet11;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'For reminders and the emergency card'**
  String get helpPermissionsTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Notifications — show reminders for birthdays, follow-ups and missed calls, and carry the emergency info card on your lock screen.'**
  String get helpPermissionsBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Alarms & reminders — lets Smart Redial call back at the time you set even when the app is closed.'**
  String get helpPermissionsBullet13;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Start after restart — puts your emergency info card back on the lock screen after the phone reboots.'**
  String get helpPermissionsBullet14;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'For sharing and sync'**
  String get helpPermissionsTitle6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Scan, Connect and Advertise — find a nearby phone, connect to it, and be findable while sharing a contact over Bluetooth.'**
  String get helpPermissionsBullet15;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Internet & Wi-Fi — used only to copy your data to another phone across your own local Wi-Fi during device sync. No cloud server is contacted unless you set up online sync or cloud backup yourself.'**
  String get helpPermissionsBullet16;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Biometrics — unlock secret contacts, and confirm before you export or sync data that may include them.'**
  String get helpPermissionsBullet17;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Saying no, and changing your mind'**
  String get helpPermissionsTitle7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Every permission is asked for only when you first use the feature that needs it. Nothing is requested at install.'**
  String get helpPermissionsBullet18;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Refusing one disables just that feature. The rest of the app keeps working.'**
  String get helpPermissionsBullet19;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A permission you denied twice shows as \"Blocked\". Android will not ask again — use the settings button in the top bar of the Permissions screen to change it by hand.'**
  String get helpPermissionsBullet20;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The app has no advertising or analytics code and contacts no server of ours. Anything that leaves the phone leaves because you set up a sync, a share, or a cloud backup.'**
  String get helpPermissionsFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Emergency info'**
  String get helpEmergencyInfoText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The emergency card holds a few facts that could help someone who finds you unwell — your blood group, your allergies, and who to call. It can be read on your lock screen without your PIN.'**
  String get helpEmergencyInfoIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'What \"without unlocking\" means'**
  String get helpEmergencyInfoTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'While the card is on, a notification called \"Emergency info\" sits on your lock screen. Tapping it opens the card straight away — no PIN, fingerprint, or face needed.'**
  String get helpEmergencyInfoBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The phone stays locked. Only the card opens; the rest of the app, and everything else on the phone, stays shut.'**
  String get helpEmergencyInfoBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Android keeps its own \"Emergency information\" page behind the lock screen Emergency button. That page belongs to the phone maker, and no app can write into it — which is why SreerajP Contacts Sphere uses its own notification instead.'**
  String get helpEmergencyInfoBullet3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'You choose every line'**
  String get helpEmergencyInfoTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The whole feature is off until you switch it on.'**
  String get helpEmergencyInfoBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Each field has its own \"Show on lock screen\" switch. A field you leave switched off never leaves the app.'**
  String get helpEmergencyInfoBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The preview at the bottom of the edit screen shows exactly what a stranger would see.'**
  String get helpEmergencyInfoBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Switching the card off removes the notification and wipes the copy the lock screen was reading. What you typed stays saved inside the app.'**
  String get helpEmergencyInfoBullet7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Calling for help'**
  String get helpEmergencyInfoTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Each person you add gets a Call button on the card. Tapping it dials them right away from the lock screen.'**
  String get helpEmergencyInfoBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'People picked from your contacts are copied onto the card as a name and one number. Editing that contact later does not change the card — open this screen and save again.'**
  String get helpEmergencyInfoBullet9;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'If the card is missing from the lock screen'**
  String get helpEmergencyInfoTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your phone decides which notifications the lock screen shows. Open Settings → Notifications → Notifications on lock screen and pick \"Show conversations, default and silent\".'**
  String get helpEmergencyInfoBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If that is set to \"Hide silent notifications\" or \"Don\'t show any notifications\", the card cannot appear there. No app can override that choice.'**
  String get helpEmergencyInfoBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Also check that notifications for SreerajP Contacts Sphere are on, and that the \"Emergency info\" notification is not turned down to silent. The edit screen warns you when either is the case, and the button there opens the right settings page.'**
  String get helpEmergencyInfoBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The card stays in the notification shade all the time on purpose — it is meant to be one tap away, and it cannot be swiped off by accident.'**
  String get helpEmergencyInfoBullet13;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'How it is stored'**
  String get helpEmergencyInfoTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your full record stays in the app\'s encrypted database, like the rest of your contacts.'**
  String get helpEmergencyInfoBullet14;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Only the lines you switched on are copied into a small, plain file that the lock-screen card can read while the phone is locked. That copy cannot be encrypted — a locked phone has no way to unlock it for a stranger.'**
  String get helpEmergencyInfoBullet15;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The copy stays inside the app\'s private storage. Other apps cannot read it, and it is left out of phone backups.'**
  String get helpEmergencyInfoBullet16;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The card is saved inside a password-protected SreerajP Contacts Sphere backup, so a restore on a new phone brings it back.'**
  String get helpEmergencyInfoBullet17;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'It also travels on a Full Sync to another phone, or when you tick \"Emergency info card\" while choosing what to share. The other phone only takes it if it has no card of its own — your card never replaces someone else\'s.'**
  String get helpEmergencyInfoBullet18;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: keep it short. Blood group, serious allergies, and one or two people to call are worth far more to a helper than a long medical history.'**
  String get helpEmergencyInfoFooter;

  /// What the Immediate Family relationship category covers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'The people you live with or grew up with.'**
  String get descCatImmediateFamily;

  /// What the Extended Family relationship category covers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Blood relatives outside your immediate family.'**
  String get descCatExtendedFamily;

  /// What the Family by Marriage relationship category covers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'In-laws and step relatives.'**
  String get descCatFamilyByMarriage;

  /// What the Professional relationship category covers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'People you work with or do business with.'**
  String get descCatProfessional;

  /// What the Educational relationship category covers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'People from school, college or training.'**
  String get descCatEducational;

  /// What the Social relationship category covers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'Friends, neighbours and other links.'**
  String get descCatSocial;

  /// What the Service relationship category covers. Descriptive text.
  ///
  /// In en, this message translates to:
  /// **'People whose services you use.'**
  String get descCatService;

  /// Help: one relationship category line. {description} is the category's description; {examples} is a comma-separated list of saved relationship names. Help prose.
  ///
  /// In en, this message translates to:
  /// **'{description} e.g. {examples}.'**
  String helpRelationshipCategoriesExample(String description, String examples);

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Calling & In-Call Controls'**
  String get helpCallManagementText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'SreerajP Contacts Sphere provides an intelligent calling experience with multi-party controls, dual-SIM management, automatic redial assistance, and spoken caller announcements.'**
  String get helpCallManagementIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'In-Call Controls & Conference Calling'**
  String get helpCallManagementTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Mute & Speaker: Tap Mute to silence your microphone, or Speaker for loud hands-free audio.'**
  String get helpCallManagementBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Hold & Keypad: Put active calls on hold or open the dialpad to enter IVR menu digits (like pressing 1 for English).'**
  String get helpCallManagementBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Add Call & Call Swap: Add a second participant while keeping the first call on hold. Tap Swap to switch between active callers.'**
  String get helpCallManagementBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Conference Merge: Tap Merge to combine both calls into one conference call. Merge only appears when your network supports conference calls. Tap Manage to see who is on the call, drop one person, or talk to one person in private.'**
  String get helpCallManagementBullet4;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Speed Dial'**
  String get helpCallManagementTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Keypad keys 1 to 9 can each hold one person. Hold a key on the dialer to call them.'**
  String get helpCallManagementBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Holding only works when the number box is empty, so a long press while you are typing never starts a call.'**
  String get helpCallManagementBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'To set a key: hold an empty key on the dialer and pick a contact, or go to Settings → Speed Dial. If the contact has more than one number you are asked which one to save.'**
  String get helpCallManagementBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A key that holds someone shows a small coloured dot above the digit.'**
  String get helpCallManagementBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Secret contacts cannot be put on a key, and a key is freed automatically if you delete its contact or make it secret.'**
  String get helpCallManagementBullet9;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Dual-SIM Calling & Preferences'**
  String get helpCallManagementTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'On dual-SIM phones, the dialer gives you SIM 1 and SIM 2 call buttons for immediate selection.'**
  String get helpCallManagementBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → SIM & calling → SIM Cards & Accounts sets the default SIM for outgoing calls, or switches on \"Ask before each call\" so you are asked every time.'**
  String get helpCallManagementBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'One person can have their own SIM: open the contact, tap Edit, and choose it under \"Preferred SIM\". Calls to them then use that SIM instead of the default one.'**
  String get helpCallManagementBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'With \"Ask before each call\" switched on you are still asked, but the SIM that call would have used is already ticked, so it is one tap.'**
  String get helpCallManagementBullet13;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'If that SIM is later removed from the phone, calls quietly fall back to your default SIM.'**
  String get helpCallManagementBullet14;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The same screen gives each SIM its own colour, so you can tell at a glance which line a call is on.'**
  String get helpCallManagementBullet15;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Recents shows which SIM was used for each incoming, outgoing, or missed call.'**
  String get helpCallManagementBullet16;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Smart Redial & \"Reach Me\" SMS'**
  String get helpCallManagementTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'When an outgoing call is busy or unanswered, the app offers to redial the number for you after a delay.'**
  String get helpCallManagementBullet17;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'You can instead send a preset \"Reach Me\" text in one tap, to say you tried to get through.'**
  String get helpCallManagementBullet18;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → SIM & calling → Smart Redial & \"Reach Me\" sets the default retry delay and the preset message, and lists the redials that are waiting to run.'**
  String get helpCallManagementBullet19;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A scheduled redial is the one place the app dials on its own, and only because you set the delay yourself. Cancel a waiting redial from that same list.'**
  String get helpCallManagementBullet20;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Spoken Caller Announcements'**
  String get helpCallManagementTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Turn it on under Settings → SIM & calling → Spoken caller announcement. The app then says the caller\'s name over the ringtone — \"Amma calling\".'**
  String get helpCallManagementBullet21;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A Malayalam name is announced in Malayalam. Use the Test button on that screen to hear how a name sounds before a real call arrives.'**
  String get helpCallManagementBullet22;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Switch on the quiet-hours exception, and set its time range, to stay silent at night while the phone still rings.'**
  String get helpCallManagementBullet23;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Quick SMS Decline Replies'**
  String get helpCallManagementTitle6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Cannot answer right now? Tap Reply on the incoming call screen to decline the call and send a preset text instead.'**
  String get helpCallManagementBullet24;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Write your own messages under Settings → SIM & calling → Quick replies.'**
  String get helpCallManagementBullet25;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: make this your Default Phone App — Settings → Permissions shows whether it already is. Without that role, Android does not hand over the in-call controls or the full-screen incoming alert.'**
  String get helpCallManagementFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Relationship categories'**
  String get helpRelationshipCategoriesText1;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Every relationship you save has two parts: a category and a label. The category is one of seven fixed buckets. The label is whatever you want to call it — \"Father\", \"Cousin Brother\", \"Manager\".'**
  String get helpRelationshipCategoriesIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Why categories exist'**
  String get helpRelationshipCategoriesTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The sphere used to draw one node for every different label. With twenty or more links it turned into a crowd.'**
  String get helpRelationshipCategoriesBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Now the sphere draws at most seven nodes — one per category. The number inside a node is how many contacts sit in it.'**
  String get helpRelationshipCategoriesBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tap a node to see everyone inside it, each with their own label. Nothing is hidden; it is only tidier.'**
  String get helpRelationshipCategoriesBullet3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Adding a relationship'**
  String get helpRelationshipCategoriesTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Pick the contact you want to link.'**
  String get helpRelationshipCategoriesBullet4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Pick one of the seven categories.'**
  String get helpRelationshipCategoriesBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Type the label, or tap one of the suggested chips. The chips are only shortcuts — any wording you like is accepted.'**
  String get helpRelationshipCategoriesBullet6;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'The seven categories'**
  String get helpRelationshipCategoriesTitle3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Both sides, one category'**
  String get helpRelationshipCategoriesTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A link is saved on both contacts. If you save someone as your Father, you show up on their side as their Son or Daughter.'**
  String get helpRelationshipCategoriesBullet7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The reverse side keeps the same category, so the pair always sits in the same bucket on both spheres.'**
  String get helpRelationshipCategoriesBullet8;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Relationships you saved earlier'**
  String get helpRelationshipCategoriesTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Old links had no category. On the first launch after this update, each one is sorted by its label — \"Father\" goes to Immediate Family, \"Colleague\" to Professional, and so on.'**
  String get helpRelationshipCategoriesBullet9;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A label the app does not recognise goes to Social. Nothing is deleted, and you can move any link to another category by tapping it and choosing \"Change\".'**
  String get helpRelationshipCategoriesBullet10;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours use these categories'**
  String get helpRelationshipCategoriesTitle6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Settings → SIM & calling → Relationship-tier quiet hours silences calls between the times you set.'**
  String get helpRelationshipCategoriesBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'It is an allow list, not a block list. Everyone is silenced except the people you add — starred contacts, whole categories such as Immediate Family, a tag, or named individuals.'**
  String get helpRelationshipCategoriesBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'This is why the category matters: allowing \"Immediate Family\" lets every contact in that bucket ring through, whatever label you gave each one.'**
  String get helpRelationshipCategoriesBullet13;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: if you are unsure where someone belongs, pick the category you would look under later. The label carries the detail.'**
  String get helpRelationshipCategoriesFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Sync to Another Device'**
  String get helpP2pSyncText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Copy your contacts (and more) from one phone to another over the same Wi-Fi network. There is no internet, cloud, or account involved — the two phones talk directly to each other. Both phones must be running this app.'**
  String get helpP2pSyncIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get helpP2pSyncTitle1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Put both phones on the same Wi-Fi network.'**
  String get helpP2pSyncBullet1;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Make sure both phones run the same version of this app. If the versions do not match, sync stops and asks you to update both phones.'**
  String get helpP2pSyncBullet2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'On both phones open Settings → Sync to Another Device. It asks for your fingerprint, face, or PIN first, because a sync can include secret contacts.'**
  String get helpP2pSyncBullet3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'On the phone that is sending, tap \"Send to Another Device\". On the phone that is receiving, tap \"Receive from Another Device\".'**
  String get helpP2pSyncBullet4;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'How the two phones connect'**
  String get helpP2pSyncTitle2;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The sending phone shows a pairing code and a QR code.'**
  String get helpP2pSyncBullet5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The receiving phone scans that QR code, or you type the pairing code in by hand.'**
  String get helpP2pSyncBullet6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The pairing code is only ever shown on screen — it is never sent over the network. The whole transfer is encrypted using that code, so if the wrong code is used the connection simply fails.'**
  String get helpP2pSyncBullet7;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Full Sync vs Selective Sync'**
  String get helpP2pSyncTitle3;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Full Sync sends everything below in one go. The sender\'s app settings replace the receiver\'s, and the sender\'s own profile (\"Self\") card is added to the receiver as a normal contact (it never replaces the receiver\'s own profile).'**
  String get helpP2pSyncBullet8;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Selective Sync sends only the groups of data you pick. Contacts are always included. Settings only fill in blanks (they never overwrite what the receiver already set), and the sender\'s \"Self\" card is not sent.'**
  String get helpP2pSyncBullet9;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'What gets synced'**
  String get helpP2pSyncTitle4;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contacts and their details: phone numbers, emails, addresses, official details, social links, and tags.'**
  String get helpP2pSyncBullet10;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Contact photos and calling-card photos.'**
  String get helpP2pSyncBullet11;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Call history: call logs, interactions, and reminders.'**
  String get helpP2pSyncBullet12;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Groups and who belongs to them.'**
  String get helpP2pSyncBullet13;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Relationships between contacts.'**
  String get helpP2pSyncBullet14;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Blocked numbers.'**
  String get helpP2pSyncBullet15;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your emergency info card — on a Full Sync, or when you tick it while choosing what to share. The receiving phone takes it only if it has no card of its own, so nobody\'s medical details get replaced.'**
  String get helpP2pSyncBullet16;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'App settings that are not tied to a specific phone — such as theme, accent color, default country, quick replies, and call-handling options.'**
  String get helpP2pSyncBullet17;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'What is never synced'**
  String get helpP2pSyncTitle5;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Ringtones. A ringtone points at a file on the sending phone, which would not exist on the other phone.'**
  String get helpP2pSyncBullet18;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'SIM-specific settings, such as the default SIM and per-SIM ringtones or colors. These refer to the physical SIM cards in the sending phone.'**
  String get helpP2pSyncBullet19;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the receiving phone is deleted'**
  String get helpP2pSyncTitle6;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Sync only adds. The receiving phone keeps all of its own data — nothing is erased or overwritten by the contacts that come in.'**
  String get helpP2pSyncBullet20;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A contact you already have (same name and at least one shared phone number) is skipped, not duplicated. Only brand-new contacts are added, and their details and call history come across with them.'**
  String get helpP2pSyncBullet21;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Because an existing contact is skipped, the sender\'s call history for that contact is not merged in — only new contacts bring their history.'**
  String get helpP2pSyncBullet22;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Your data stays private'**
  String get helpP2pSyncTitle7;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The transfer happens directly between the two phones on your local Wi-Fi. Nothing is uploaded to the internet or to any server.'**
  String get helpP2pSyncBullet23;

  /// Help: one bullet point in an article section. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Opening sync is protected by your device lock, because the data can include secret contacts.'**
  String get helpP2pSyncBullet24;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Tip: keep both phones awake and on the same Wi-Fi until the sync finishes.'**
  String get helpP2pSyncFooter;

  /// Help: text in an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'FAQs & Troubleshooting'**
  String get helpFaqTroubleshootingText;

  /// Help: lead paragraph of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Find quick answers to common questions about permissions, default dialer setup, privacy, sync options, and troubleshooting steps in ContactSphere.'**
  String get helpFaqTroubleshootingIntro;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'General & Permissions'**
  String get helpFaqTroubleshootingTitle1;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Why does ContactSphere need Default Phone App permission?'**
  String get helpFaqTroubleshootingQ1;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Android requires an app to be set as the Default Phone App to show incoming call alerts, enable conference merging/call swap, and automatically screen and block spam calls.'**
  String get helpFaqTroubleshootingA1;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Are my contacts uploaded to external servers?'**
  String get helpFaqTroubleshootingQ2;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'No. ContactSphere is built with an offline-first architecture. All contacts, call logs, notes, and photos reside in your encrypted local SQLite database. No data is sent to external servers unless you explicitly configure your personal Google Drive / WebDAV cloud backup.'**
  String get helpFaqTroubleshootingA2;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Why are some permissions optional?'**
  String get helpFaqTroubleshootingQ3;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Permissions such as Bluetooth (for nearby sharing), Camera (for QR and business-card scanning), and Microphone (for dictating call notes) are asked for only when you first use that feature. Refusing one disables just that feature. See the \"Permissions explained\" guide for the full list.'**
  String get helpFaqTroubleshootingA3;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Dialer & Calling'**
  String get helpFaqTroubleshootingTitle2;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'How do I search Malayalam or Devanagari names on T9?'**
  String get helpFaqTroubleshootingQ4;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Press the keys for the consonant group, or type the name as it sounds in English (typing 2-6-4-5 matches both \"Anil\" and \"അനിൽ\"). To change which script the keypad shows, use the \"Dialpad script\" card on the main Settings page.'**
  String get helpFaqTroubleshootingA4;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'How do I choose which SIM to call from?'**
  String get helpFaqTroubleshootingQ5;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'On dual-SIM phones the dialer gives you separate SIM 1 and SIM 2 call buttons. To stop choosing every time, set a default SIM under Settings → SIM & calling → SIM Cards & Accounts, or switch on \"Ask before each call\" there.'**
  String get helpFaqTroubleshootingA5;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Why didn\'t a call ring during quiet hours?'**
  String get helpFaqTroubleshootingQ6;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours silence everything except the people you allow. Open Settings → SIM & calling → Relationship-tier quiet hours and add whoever should still get through — starred contacts, whole relationship categories, a tag, or named individuals. Anyone not on that list is silenced until the quiet hours end.'**
  String get helpFaqTroubleshootingA6;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Sync, Cloud & Backups'**
  String get helpFaqTroubleshootingTitle3;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'What is the difference between Local Wi-Fi Sync and Cloud Sync?'**
  String get helpFaqTroubleshootingQ7;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Local Wi-Fi sync copies data straight from one phone to another on the same network, with no internet and no account. Online sync and cloud backup use accounts you add yourself — Google, Microsoft, or a CardDAV/WebDAV server — and are off until you set one up.'**
  String get helpFaqTroubleshootingA7;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'What happens if I forget my Backup password?'**
  String get helpFaqTroubleshootingQ8;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A backup file is encrypted with the password you chose, and the app never stores it. There is no server to ask, so a lost password means the file cannot be opened. Write it down somewhere safe before you need it.'**
  String get helpFaqTroubleshootingA8;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Will syncing with my phone contacts delete anything?'**
  String get helpFaqTroubleshootingQ9;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Standard sync merges new and updated contacts safely. Destructive / Mirror sync will warn you explicitly before replacing or removing any contacts.'**
  String get helpFaqTroubleshootingA9;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Secret Contacts'**
  String get helpFaqTroubleshootingTitle4;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'How do I restore access if biometric unlock fails?'**
  String get helpFaqTroubleshootingQ10;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'The phone\'s own unlock prompt falls back to your screen-lock PIN, pattern, or password. If you use an App PIN instead and have forgotten it, tap \"Forgot PIN?\" on the lock screen and enter the recovery code you were given when you set it up.'**
  String get helpFaqTroubleshootingA10;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Why does the screen go black when switching apps?'**
  String get helpFaqTroubleshootingQ11;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Guard protects sensitive views from being captured in Android\'s recent apps preview or by background recording tools.'**
  String get helpFaqTroubleshootingA11;

  /// Help: title (article title, topic card title or section heading). Help prose.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting & Maintenance'**
  String get helpFaqTroubleshootingTitle5;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Search is slow or not finding new contacts. How to fix?'**
  String get helpFaqTroubleshootingQ12;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Contacts → Contact counts & search index. If any contacts have stale search keys, a Rebuild button appears — tap it and the keys are rebuilt in a few seconds.'**
  String get helpFaqTroubleshootingA12;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A blocked number still shows in Recents. Is it ringing?'**
  String get helpFaqTroubleshootingQ13;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'No. A blocked call is rejected before your phone rings, but it is still written into Recents with a \"Blocked\" mark so you can see that someone tried. If you would rather see the call and just not be disturbed, use \"Filter suspected spam\" instead of blocking.'**
  String get helpFaqTroubleshootingA13;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'A contact vanished on its own. Why?'**
  String get helpFaqTroubleshootingQ14;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'It was probably saved as an ephemeral (temporary) contact, which deletes itself after 2 hours, 24 hours, 7 days, or one call. Opening such a contact shows a countdown banner with a \"Keep Permanently\" button.'**
  String get helpFaqTroubleshootingA14;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Where are groups and tags?'**
  String get helpFaqTroubleshootingQ15;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Groups are behind the group icon in the top bar of the Contacts tab. Tags have their own tab at the bottom of the app, drawn as a cloud where a tag used by more people appears larger.'**
  String get helpFaqTroubleshootingA15;

  /// Help: an FAQ question. Help prose.
  ///
  /// In en, this message translates to:
  /// **'How do I clean up duplicate contacts?'**
  String get helpFaqTroubleshootingQ16;

  /// Help: the answer to the FAQ question with the same number. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Open the Contacts tab, tap the three-dot menu, and choose \"Find Duplicates\". Matching is by phone number and by name (including transliterated names). Review each set, then merge it, or use \"Merge all sets\".'**
  String get helpFaqTroubleshootingA16;

  /// Help: closing tip of an article. Help prose.
  ///
  /// In en, this message translates to:
  /// **'Still stuck? Open the matching guide in Help, or check Settings → Permissions to see whether the feature is simply missing a permission.'**
  String get helpFaqTroubleshootingFooter;

  /// About screen row label for the app's author. UI chrome (label). Key name fixed by guideline §1.6.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get aboutDetailAuthor;

  /// About screen row label for the contact email. UI chrome (label). Key name fixed by guideline §1.6.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get aboutDetailEmail;

  /// About screen row label for the licence note. UI chrome (label). Key name fixed by guideline §1.6.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutDetailLicense;

  /// About screen row label for the AI tools used to build the app. UI chrome (label). Key name fixed by guideline §1.6.
  ///
  /// In en, this message translates to:
  /// **'AI used'**
  String get aboutDetailAiUsed;

  /// About screen row label for the code editor used. UI chrome (label). Key name fixed by guideline §1.6.
  ///
  /// In en, this message translates to:
  /// **'IDE used'**
  String get aboutDetailIdeUsed;

  /// About screen row label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get labelVersion;

  /// About screen row label. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'Build Date'**
  String get labelBuildDate;

  /// About screen version value. {version} is like 15.17.12; {build} is the build number. UI chrome.
  ///
  /// In en, this message translates to:
  /// **'{version} (build {build})'**
  String labelVersionBuild(String version, String build);

  /// Contact screen tab: the contact's saved details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get tabDetails;

  /// Tab listing the calls with one contact or number.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// Number screen tab: form to save an unknown number as a contact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get tabAddContact;

  /// Empty History tab on a contact's screen.
  ///
  /// In en, this message translates to:
  /// **'No calls with this contact yet.'**
  String get emptyNoCallsWithContact;

  /// Empty History tab on an unsaved number's screen.
  ///
  /// In en, this message translates to:
  /// **'No calls with this number yet.'**
  String get emptyNoCallsWithNumber;

  /// Tooltip on the refresh icon of the contact index health card. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get tooltipCheckAgain;

  /// Tooltip on the add button of the Groups screen. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get tooltipCreateGroup;

  /// Tooltip on the icon that re-centres the relationship sphere on this person. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Centre sphere here'**
  String get tooltipCentreSphere;

  /// Tooltip on the icon that opens this person's contact screen. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get tooltipOpenProfile;

  /// Tooltip on the icon that cancels a waiting Smart Redial. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Cancel redial'**
  String get tooltipCancelRedial;

  /// Tooltip on the refresh icon that searches again for nearby phones over Bluetooth. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get tooltipScanAgain;

  /// Tooltip on the eye icon that reveals the typed password. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get tooltipShowPassword;

  /// Tooltip on the eye icon that hides the typed password again. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get tooltipHidePassword;

  /// Tooltip on the delete icon of an online sync account row. UI chrome — keep short.
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get tooltipRemoveAccount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml', 'sa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
    case 'sa':
      return AppLocalizationsSa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
