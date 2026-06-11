// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Form';

  @override
  String get cancel => 'Stornieren';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get discard => 'Verwerfen';

  @override
  String get continueAction => 'Weitermachen';

  @override
  String get done => 'Erledigt';

  @override
  String get remove => 'Entfernen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get close => 'Schließen';

  @override
  String get untitled => 'Ohne Titel';

  @override
  String get open => 'Offen';

  @override
  String get change => 'Ändern';

  @override
  String get export => 'Export';

  @override
  String get publish => 'Veröffentlichen';

  @override
  String get unlink => 'Verknüpfung aufheben';

  @override
  String get duplicate => 'Kopie erstellen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renameForm => 'Umbenennen';

  @override
  String get enterNewName => 'Geben Sie einen neuen Namen ein';

  @override
  String get documentName => 'Dokumentname';

  @override
  String get formRenamed => 'Umbenannt';

  @override
  String get failedToRename => 'Umbenennen fehlgeschlagen';

  @override
  String get required => 'Pflichtfrage';

  @override
  String get optional => 'Optional';

  @override
  String get other => 'Andere';

  @override
  String get description => 'Beschreibung';

  @override
  String get question => 'Frage';

  @override
  String get columns => 'Spalten';

  @override
  String get rows => 'Reihen';

  @override
  String get image => 'Bild';

  @override
  String get video => 'Video';

  @override
  String get owner => 'Eigentümer';

  @override
  String get loginSubtitle => 'Erstellen und verwalten Sie Formulare unterwegs';

  @override
  String get signInWithGoogle => 'Melden Sie sich mit Google an';

  @override
  String get signInFailed =>
      'Die Anmeldung ist fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get tabMyForms => 'Meine Formulare';

  @override
  String get tabTemplates => 'Vorlagengalerie';

  @override
  String get searchForms => 'Durchsuchen Sie Ihre Formulare';

  @override
  String get searchTemplates => 'Suchvorlagen';

  @override
  String get recentForms => 'Zuletzt verwendete Formulare';

  @override
  String get noRecentForms => 'Keine zuletzt verwendeten Elemente';

  @override
  String noFormsMatching(String query) {
    return 'Keine Formulare, die mit „$query“ übereinstimmen';
  }

  @override
  String get tryDifferentSearch =>
      'Versuchen Sie es mit einem anderen Suchbegriff';

  @override
  String noTemplatesMatching(String query) {
    return 'Keine Vorlagen, die mit „$query“ übereinstimmen';
  }

  @override
  String get tryDifferentSearchOrCategory =>
      'Versuchen Sie es mit einem anderen Suchbegriff oder einer anderen Kategorie';

  @override
  String get thisIsTheEnd => '-Das ist das Ende-';

  @override
  String get linkCopiedToClipboard => 'Link in die Zwischenablage kopiert';

  @override
  String get deleteFormTitle => 'In den Papierkorb verschieben?';

  @override
  String get deleteFormContent =>
      'Dieses Formular wird in den Papierkorb verschoben.';

  @override
  String get formMovedToTrash => 'In den Papierkorb verschoben';

  @override
  String get failedToDeleteForm => 'Formular konnte nicht gelöscht werden';

  @override
  String get duplicatingForm => 'Kopie wird erstellt…';

  @override
  String get formDuplicated => 'Kopie erstellt';

  @override
  String get failedToDuplicateForm => 'Kopie konnte nicht erstellt werden';

  @override
  String get templateComingSoon => 'Vorlage folgt bald!';

  @override
  String get loadingTemplate => 'Vorlage wird geladen...';

  @override
  String get failedToLoadTemplate =>
      'Vorlage konnte nicht geladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get soon => 'Bald';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Vorlagen',
      one: '1 Vorlage',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => 'Im Besitz von irgendjemandem';

  @override
  String get ownedByMe => 'Von mir';

  @override
  String get notOwnedByMe => 'Nicht von mir';

  @override
  String get lastModified => 'Geändert';

  @override
  String get lastOpened => 'Zuletzt von mir geöffnet';

  @override
  String get titleAZ => 'Name';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get categoryAll => 'Alle';

  @override
  String get categoryWork => 'Arbeiten';

  @override
  String get categoryEducation => 'Ausbildung';

  @override
  String get categoryCommunity => 'Gemeinschaft';

  @override
  String get categoryHealth => 'Gesundheit und Wohlbefinden';

  @override
  String get tplPrayerRequestSafety =>
      'Gebetsanliegen für Sicherheit und Schutz';

  @override
  String get tplPrayerRequestSafetyDesc =>
      'Senden Sie Gebetsanliegen für Sicherheit und Schutz';

  @override
  String get tplWorkshopEvaluation => 'Werkstattbewertung';

  @override
  String get tplWorkshopEvaluationDesc =>
      'Bewerten Sie die Wirksamkeit des Workshops';

  @override
  String get tplSoccerTryoutEvaluation => 'Bewertung des Fußball-Tryouts';

  @override
  String get tplSoccerTryoutEvaluationDesc =>
      'Bewerten Sie die Leistung beim Fußball-Probetraining';

  @override
  String get tplOralPresentationEvaluation =>
      'Bewertungsformular für mündliche Präsentationen';

  @override
  String get tplOralPresentationEvaluationDesc =>
      'Bewerten Sie mündliche Präsentationsfähigkeiten';

  @override
  String get tplPeerFeedback => 'Peer-Feedback-Formular';

  @override
  String get tplPeerFeedbackDesc => 'Geben Sie Kollegen Feedback';

  @override
  String get tplPresentationFeedback => 'Feedback zur Präsentation';

  @override
  String get tplPresentationFeedbackDesc =>
      'Geben Sie Feedback zu Präsentationen';

  @override
  String get tplPatientFeedback => 'Patienten-Feedback-Formular';

  @override
  String get tplPatientFeedbackDesc =>
      'Sammeln Sie Patientenfeedback zur Pflege';

  @override
  String get tplChildcareRegistration =>
      'Anmeldeformular für die Kinderbetreuung';

  @override
  String get tplChildcareRegistrationDesc =>
      'Melden Sie Kinder für die Kinderbetreuung an';

  @override
  String get tplMedicationOrder => 'Bestellformular für Medikamente';

  @override
  String get tplMedicationOrderDesc => 'Medikamentenbestellungen aufgeben';

  @override
  String get tplTeamworkCollaborationEvaluation =>
      'Bewertung von Teamarbeit und Zusammenarbeit';

  @override
  String get tplTeamworkCollaborationEvaluationDesc =>
      'Bewerten Sie die Fähigkeiten zur Teamzusammenarbeit';

  @override
  String get tplTrainingDevelopmentFeedback =>
      'Feedback-Formular für Schulung und Entwicklung';

  @override
  String get tplTrainingDevelopmentFeedbackDesc =>
      'Geben Sie Feedback zu Schulungsprogrammen';

  @override
  String get tplAnnualEmployeePerformanceReview =>
      'Jährliche Leistungsbeurteilung der Mitarbeiter';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc =>
      'Überprüfen Sie die Leistung Ihrer Mitarbeiter jährlich';

  @override
  String get useThisTemplate => 'Verwenden Sie diese Vorlage';

  @override
  String get failedToCopyTemplate =>
      'Vorlage konnte nicht kopiert werden. Bitte versuchen Sie es erneut.';

  @override
  String get untitledForm => 'Formular ohne Titel';

  @override
  String sectionTitleOf(int n, int total) {
    return 'Abschnitt $n von $total';
  }

  @override
  String get sectionTitle => 'Abschnittstitel';

  @override
  String get shortAnswerText => 'Kurzer Antworttext';

  @override
  String get longAnswerText => 'Langer Antworttext';

  @override
  String get imageTitleOptional => 'Bildtitel (optional)';

  @override
  String get videoTitle => 'Videotitel';

  @override
  String optionLabel(int n) {
    return 'Option $n';
  }

  @override
  String get youTubeVideo => 'YouTube-Video';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Google-Konto';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutTitle => 'Abmelden?';

  @override
  String get signOutContent =>
      'Möchten Sie sich wirklich von Ihrem Konto abmelden?';

  @override
  String get goPremium => 'Gehen Sie Premium';

  @override
  String get goPremiumDesc =>
      'Schalten Sie alle Funktionen frei und entfernen Sie Werbung';

  @override
  String get about => 'Um';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => 'Bearbeiten';

  @override
  String get tabPreview => 'Vorschau';

  @override
  String get tabResponses => 'Antworten';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get qTypeMultipleChoice => 'Multiple Choice';

  @override
  String get qTypeCheckboxes => 'Kontrollkästchen';

  @override
  String get qTypeShortAnswer => 'Kurze Antwort';

  @override
  String get qTypeParagraph => 'Absatz';

  @override
  String get qTypeDropdown => 'Drop-down';

  @override
  String get qTypeImage => 'Bild';

  @override
  String get qTypeVideo => 'Video';

  @override
  String get qTypeLinearScale => 'Lineare Skala';

  @override
  String get qTypeMultipleChoiceGrid => 'Multiple-Choice-Raster';

  @override
  String get qTypeCheckboxGrid => 'Kontrollkästchen-Raster';

  @override
  String get qTypeDate => 'Datum';

  @override
  String get qTypeTime => 'Zeit';

  @override
  String get qTypeInfo => 'Info';

  @override
  String get qTypeSection => 'Abschnitt';

  @override
  String get qTypeTitleDescription => 'Titel und Beschreibung';

  @override
  String get addQuestion => 'Frage hinzufügen';

  @override
  String get addImage => 'Bild hinzufügen';

  @override
  String get addVideo => 'Video hinzufügen';

  @override
  String get addInfo => 'Informationen hinzufügen';

  @override
  String get addSection => 'Abschnitt hinzufügen';

  @override
  String get addYouTubeVideo => 'YouTube-Video hinzufügen';

  @override
  String get pasteYouTubeUrl => 'Fügen Sie hier die YouTube-URL ein';

  @override
  String get clickToUploadImage => 'Klicken Sie, um das Bild hochzuladen';

  @override
  String get pasteYouTubeVideoUrl => 'YouTube-Video-URL einfügen';

  @override
  String get saving => 'Sparen...';

  @override
  String get formSaved =>
      'Formular gespeichert! Link in die Zwischenablage kopiert.';

  @override
  String formSavedWithWarnings(String warnings) {
    return 'Formular gespeichert! Link kopiert. $warnings';
  }

  @override
  String get failedToSaveForm => 'Formular konnte nicht gespeichert werden.';

  @override
  String get failedToLoadForm => 'Formular konnte nicht geladen werden.';

  @override
  String get saveToPreview => 'Zur Vorschau speichern';

  @override
  String get saveForm => 'Formular speichern';

  @override
  String get saveTheFormFirst =>
      'Speichern Sie das Formular zunächst, um einen Link zu erhalten';

  @override
  String get saveBeforePublishing =>
      'Bitte speichern Sie das Formular vor der Veröffentlichung.';

  @override
  String get unsavedChanges => 'Nicht gespeicherte Änderungen';

  @override
  String get unsavedChangesBackDesc =>
      'Sie haben nicht gespeicherte Änderungen. Möchten Sie vor Ihrer Abreise sparen?';

  @override
  String get unsavedChangesPreviewDesc =>
      'Speichern Sie Ihr Formular, um die neueste Vorschau Ihrer Änderungen anzuzeigen.';

  @override
  String get dontSave => 'Sparen Sie nicht';

  @override
  String get untitledQuestion => 'Frage ohne Titel';

  @override
  String get formTitle => 'Formulartitel';

  @override
  String get formDescription => 'Formularbeschreibung';

  @override
  String get addOption => 'Option hinzufügen';

  @override
  String columnN(int n) {
    return 'Spalte $n';
  }

  @override
  String rowN(int n) {
    return 'Zeile $n';
  }

  @override
  String get addColumn => 'Spalte hinzufügen';

  @override
  String get addRow => 'Zeile hinzufügen';

  @override
  String get minValue => 'Mindestwert';

  @override
  String get maxValue => 'Maximaler Wert';

  @override
  String get labelOptional => 'Etikett (optional)';

  @override
  String get showDescription => 'Beschreibung anzeigen';

  @override
  String get includeYear => 'Jahr einschließen';

  @override
  String get duration => 'Dauer';

  @override
  String get tooltipDragToReorder => 'Ziehen Sie, um die Frage neu anzuordnen';

  @override
  String get tooltipCopyLink => 'Link kopieren';

  @override
  String get tooltipPublished => 'Veröffentlicht';

  @override
  String get tooltipPublish => 'Veröffentlichen';

  @override
  String get tooltipSave => 'Speichern';

  @override
  String get tooltipDuplicate => 'Kopie erstellen';

  @override
  String get tooltipDelete => 'Löschen';

  @override
  String get tooltipMoreOptions => 'Weitere Optionen';

  @override
  String get tooltipAddImageToQuestion => 'Bild zur Frage hinzufügen';

  @override
  String get tooltipExportXlsx => 'Als .xlsx exportieren';

  @override
  String get tooltipExportCsv => 'Als .csv exportieren';

  @override
  String get tooltipOpenLinkedSheet => 'Öffnen Sie das verknüpfte Google Sheet';

  @override
  String get tooltipLinkToSheet => 'Link zu Google Sheet';

  @override
  String get tooltipRemoveEditor => 'Editor entfernen';

  @override
  String get noPreviewAvailable => 'Keine Vorschau verfügbar';

  @override
  String get noPreviewDesc =>
      'Speichern Sie Ihr Formular zunächst, um eine Live-Vorschau zu sehen, wie es für die Befragten aussieht.';

  @override
  String get saveYourFormFirst => 'Speichern Sie zunächst Ihr Formular';

  @override
  String get needSaveForResponses =>
      'Sie müssen Ihr Formular speichern, bevor Sie Antworten anzeigen können.';

  @override
  String get noResponsesYet => 'Noch keine Antworten';

  @override
  String get noResponsesDesc =>
      'Antworten werden hier angezeigt, sobald Personen Ihr Formular absenden.';

  @override
  String get shareThisForm => 'Freigeben';

  @override
  String get responseSubSummary => 'Zusammenfassung';

  @override
  String get responseSubQuestion => 'Frage';

  @override
  String get responseSubIndividual => 'Person';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Antworten',
      one: '1 Antwort',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => 'Noch keine Antworten.';

  @override
  String get noGridData => 'Keine Rasterdaten.';

  @override
  String andNMore(int n) {
    return '... und $n mehr';
  }

  @override
  String get noQuestionsFound => 'Keine Fragen gefunden.';

  @override
  String get questionLabel => 'Frage:';

  @override
  String questionN(int n) {
    return 'Frage $n';
  }

  @override
  String get noResponses => 'Keine Antworten.';

  @override
  String responseNOfTotal(int n, int total) {
    return '$n von $total';
  }

  @override
  String submittedTime(String time) {
    return 'Eingereicht: $time';
  }

  @override
  String responseN(int n) {
    return 'Antwort $n';
  }

  @override
  String get noAnswer => 'Keine Antwort';

  @override
  String get couldNotOpenYouTube => 'YouTube konnte nicht geöffnet werden.';

  @override
  String exportAs(String format) {
    return 'Als $format exportieren';
  }

  @override
  String get enterFileName => 'Geben Sie einen Dateinamen für den Export ein:';

  @override
  String get fileName => 'Dateiname';

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get responseId => 'Antwort-ID';

  @override
  String get createTime => 'Zeit schaffen';

  @override
  String get lastSubmittedTime => 'Zeitpunkt der letzten Übermittlung';

  @override
  String get responsesSheet => 'Antworten';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => 'Mit Blatt verknüpft';

  @override
  String get responsesAutoSaved =>
      'Antworten werden automatisch in dieser Tabelle gespeichert:';

  @override
  String get linkedSpreadsheet => 'Verlinkte Tabelle';

  @override
  String get tapToOpenInBrowser => 'Zum Öffnen im Browser antippen';

  @override
  String get openSheet => 'In Google Sheets ansehen';

  @override
  String get linkToGoogleSheet => 'Link zu Google Sheet';

  @override
  String get linkSheetDesc =>
      'Formularantworten werden automatisch in dieser Tabelle gespeichert. Es wird eine neue Tabellenregisterkarte mit allen Antworten erstellt.';

  @override
  String get createAndLink => 'Verknüpfung erstellen';

  @override
  String get spreadsheetName => 'Tabellenname';

  @override
  String get unlinkSheetTitle => 'Verknüpfung zum Blatt aufheben?';

  @override
  String get unlinkSheetDesc =>
      'Neue Formularantworten werden nicht mehr in dieser Tabelle gespeichert. Vorhandene Antworten im Blatt werden nicht gelöscht.';

  @override
  String get sheetUnlinked =>
      'Die Verknüpfung des Blatts wurde erfolgreich aufgehoben.';

  @override
  String get failedToCreateSheet =>
      'Die Tabellenkalkulation konnte nicht erstellt werden. Bitte versuchen Sie es erneut.';

  @override
  String formLinkedToSheet(String name) {
    return 'Formular erfolgreich mit „$name“ verknüpft!';
  }

  @override
  String failedToLink(String error) {
    return 'Verknüpfung fehlgeschlagen: $error';
  }

  @override
  String failedToUnlink(String error) {
    return 'Verknüpfung konnte nicht aufgehoben werden: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String get publishRequired => 'Veröffentlichung erforderlich';

  @override
  String get publishRequiredDesc =>
      'Sie müssen dieses Formular veröffentlichen, bevor es Antworten akzeptieren kann. Möchten Sie es jetzt veröffentlichen?';

  @override
  String get formPublished =>
      'Formular veröffentlicht und jetzt Antworten entgegennehmend!';

  @override
  String failedToPublish(String error) {
    return 'Veröffentlichung fehlgeschlagen: $error';
  }

  @override
  String get formUnpublished => 'Formular unveröffentlicht';

  @override
  String get formIsPublished => 'Formular wird veröffentlicht';

  @override
  String get copyFormLink => 'Teilnehmerlink kopieren';

  @override
  String get unpublishForm => 'Veröffentlichungsformular aufheben';

  @override
  String get unpublishFormDesc =>
      'Das Formular akzeptiert keine Antworten mehr';

  @override
  String get settingsResponses => 'Antworten';

  @override
  String get settingsPresentation => 'Präsentation';

  @override
  String get settingsEditors => 'Herausgeber';

  @override
  String get acceptResponses => 'Antworten möglich';

  @override
  String get acceptResponsesEnabled =>
      'Über dieses Formular können Personen Antworten einreichen';

  @override
  String get acceptResponsesDisabled =>
      'Dieses Formular akzeptiert keine Antworten';

  @override
  String get collectEmail => 'Sammeln Sie E-Mail-Adressen';

  @override
  String get collectEmailDesc =>
      'Wählen Sie aus, wie Antwort-E-Mails erfasst werden sollen';

  @override
  String get dontCollect => 'Nicht sammeln';

  @override
  String get verified => 'Verifiziert';

  @override
  String get responderInput => 'Responder-Eingabe';

  @override
  String get limitToOneResponse => 'Beschränken Sie sich auf 1 Antwort';

  @override
  String get limitToOneResponseDesc =>
      'Erfordert, dass sich die Antwortenden anmelden';

  @override
  String get editAfterSubmit => 'Nach dem Absenden bearbeiten';

  @override
  String get editAfterSubmitDesc =>
      'Ermöglichen Sie den Antwortenden, ihre Antwort nach der Übermittlung zu bearbeiten';

  @override
  String get showProgressBar => 'Fortschrittsbalken anzeigen';

  @override
  String get showProgressBarDesc =>
      'Zeigt einen Fortschrittsbalken am unteren Rand des Formulars an';

  @override
  String get shuffleQuestionOrder => 'Reihenfolge der Fragen mischen';

  @override
  String get shuffleQuestionOrderDesc =>
      'Die Fragen werden für jeden Antwortenden in einer anderen Reihenfolge angezeigt';

  @override
  String get confirmationMessage => 'Bestätigungsnachricht';

  @override
  String get confirmationMessageDesc =>
      'Nach dem Absenden des Formulars angezeigte Nachricht';

  @override
  String get enterConfirmationMessage =>
      'Geben Sie eine Bestätigungsnachricht ein';

  @override
  String get defaultConfirmationMessage => 'Ihre Antwort wurde gespeichert.';

  @override
  String get addEditor => 'Editor hinzufügen';

  @override
  String get gmailAddress => 'Gmail-Adresse';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => 'Bitte geben Sie eine Gmail-Adresse ein.';

  @override
  String get enterValidEmail =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String get removeEditorTitle => 'Editor entfernen?';

  @override
  String removeEditorDesc(String name) {
    return '$name aus diesem Formular entfernen? Sie können es nicht mehr bearbeiten.';
  }

  @override
  String get alreadyOwner => 'Sie sind bereits Eigentümer dieses Formulars.';

  @override
  String get alreadyOwnerOther =>
      'Dieser Benutzer ist bereits Eigentümer dieses Formulars.';

  @override
  String get alreadyEditor =>
      'Dieser Benutzer ist bereits Bearbeiter dieses Formulars.';

  @override
  String get failedToAddEditor => 'Editor konnte nicht hinzugefügt werden.';

  @override
  String addedEditor(String email) {
    return '$email als Editor hinzugefügt.';
  }

  @override
  String get cannotRemoveOwner => 'Der Besitzer kann nicht entfernt werden.';

  @override
  String get failedToRemoveEditor => 'Der Editor konnte nicht entfernt werden.';

  @override
  String removedEditor(String name) {
    return '$name entfernt.';
  }

  @override
  String get noOwnerFound =>
      'Für dieses Formular wurden keine Mitarbeiter gefunden.';

  @override
  String get noEditorsYet =>
      'Noch keine Redakteure. Tippen Sie auf +Hinzufügen, um jemanden per Gmail einzuladen.';

  @override
  String get noEditorsOnForm => 'Keine Redakteure auf diesem Formular.';

  @override
  String get failedToLoadEditors =>
      'Die Editoren konnten nicht geladen werden.';

  @override
  String get saveChangesTitle => 'Änderungen speichern?';

  @override
  String breakingChangesDesc(String desc) {
    return 'Diese Änderung wirkt sich auf vorhandene Antworten aus: $desc.\n\nMöchten Sie fortfahren?';
  }

  @override
  String get duplicateChoicesError =>
      'In einer Multiple-Choice-Frage dürfen keine doppelten Auswahlmöglichkeiten vorhanden sein.';

  @override
  String get invalidDataError =>
      'Ungültige Daten. Bitte überprüfen Sie Ihr Formular und versuchen Sie es erneut.';

  @override
  String get permissionDeniedError =>
      'Zugriff verweigert. Bitte überprüfen Sie den Zugriff auf Ihr Google-Konto.';

  @override
  String get addAtLeastOneQuestion =>
      'Bitte fügen Sie vor dem Speichern mindestens eine Frage hinzu.';

  @override
  String get failedToUpdateForm => 'Formular konnte nicht aktualisiert werden.';

  @override
  String get failedToLoadCurrentForm =>
      'Die aktuellen Formulardaten konnten nicht geladen werden. Bitte versuchen Sie es erneut.';

  @override
  String couldNotLoadSettings(String error) {
    return 'Formulareinstellungen konnten nicht geladen werden: $error';
  }

  @override
  String get linkCopiedToClipboardExclaim =>
      'Link in die Zwischenablage kopiert!';

  @override
  String get userFallback => 'Benutzer';

  @override
  String get languagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Français';

  @override
  String get noInternetConnection => 'Keine Internetverbindung';

  @override
  String get noInternetConnectionDesc =>
      'Bitte überprüfen Sie Ihre Netzwerkeinstellungen und versuchen Sie es erneut.';

  @override
  String get noInternetSaveError =>
      'Keine Internetverbindung. Formular kann nicht gespeichert werden.';

  @override
  String get noInternetLoadError =>
      'Keine Internetverbindung. Formular kann nicht geladen werden.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get formNoLongerExists =>
      'Dieses Formular existiert nicht mehr oder wurde gelöscht.';

  @override
  String get failedToPickImage =>
      'Bild konnte nicht ausgewählt werden. Bitte versuchen Sie es erneut.';

  @override
  String get failedToShareFile => 'Datei konnte nicht geteilt werden.';
}
