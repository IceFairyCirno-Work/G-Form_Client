// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Form';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Sauvegarder';

  @override
  String get delete => 'Supprimer';

  @override
  String get discard => 'Jeter';

  @override
  String get continueAction => 'Continuer';

  @override
  String get done => 'Fait';

  @override
  String get remove => 'Retirer';

  @override
  String get add => 'Ajouter';

  @override
  String get settings => 'Paramètres';

  @override
  String get close => 'Fermer';

  @override
  String get untitled => 'Sans titre';

  @override
  String get open => 'Ouvrir';

  @override
  String get change => 'Changement';

  @override
  String get export => 'Exporter';

  @override
  String get publish => 'Publier';

  @override
  String get unlink => 'Dissocier';

  @override
  String get duplicate => 'Créer une copie';

  @override
  String get rename => 'Renommer';

  @override
  String get renameForm => 'Renommer';

  @override
  String get enterNewName => 'Entrez un nouveau nom';

  @override
  String get documentName => 'Nom du document';

  @override
  String get formRenamed => 'Renommé';

  @override
  String get failedToRename => 'Échec du renommage';

  @override
  String get required => 'Requis';

  @override
  String get optional => 'Facultatif';

  @override
  String get other => 'Autre';

  @override
  String get description => 'Description';

  @override
  String get question => 'Question';

  @override
  String get columns => 'Colonnes';

  @override
  String get rows => 'Lignes';

  @override
  String get image => 'Image';

  @override
  String get video => 'Vidéo';

  @override
  String get owner => 'Propriétaire';

  @override
  String get loginSubtitle => 'Créez et gérez des formulaires en déplacement';

  @override
  String get signInWithGoogle => 'Connectez-vous avec Google';

  @override
  String get signInFailed => 'Échec de la connexion. Veuillez réessayer.';

  @override
  String get tabMyForms => 'Mes formulaires';

  @override
  String get tabTemplates => 'Galerie de modèles';

  @override
  String get searchForms => 'Recherchez vos formulaires';

  @override
  String get searchTemplates => 'Modèles de recherche';

  @override
  String get recentForms => 'Formulaires récents';

  @override
  String get noRecentForms => 'Aucun élément récent';

  @override
  String noFormsMatching(String query) {
    return 'Aucun formulaire correspondant à \"$query\"';
  }

  @override
  String get tryDifferentSearch => 'Essayez un autre terme de recherche';

  @override
  String noTemplatesMatching(String query) {
    return 'Aucun modèle correspondant à \"$query\"';
  }

  @override
  String get tryDifferentSearchOrCategory =>
      'Essayez un autre terme de recherche ou une autre catégorie';

  @override
  String get thisIsTheEnd => '-C\'est la fin-';

  @override
  String get linkCopiedToClipboard => 'Lien copié dans le presse-papier';

  @override
  String get deleteFormTitle => 'Placer dans la corbeille ?';

  @override
  String get deleteFormContent => 'Ce formulaire sera placé dans la corbeille.';

  @override
  String get formMovedToTrash => 'Placé dans la corbeille';

  @override
  String get failedToDeleteForm => 'Échec de la suppression du formulaire';

  @override
  String get duplicatingForm => 'Création d\'une copie…';

  @override
  String get formDuplicated => 'Copie créée';

  @override
  String get failedToDuplicateForm => 'Impossible de créer une copie';

  @override
  String get templateComingSoon => 'Modèle à venir !';

  @override
  String get loadingTemplate => 'Chargement du modèle...';

  @override
  String get failedToLoadTemplate =>
      'Échec du chargement du modèle. Veuillez réessayer.';

  @override
  String get soon => 'Bientôt';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modèles',
      one: '1 modèle',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => 'Possédé par n\'importe qui';

  @override
  String get ownedByMe => 'Possédé par moi';

  @override
  String get notOwnedByMe => 'Ne m\'appartient pas';

  @override
  String get lastModified => 'Modifié';

  @override
  String get lastOpened => 'Dernière ouverture par moi';

  @override
  String get titleAZ => 'Nom';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get categoryAll => 'Tous';

  @override
  String get categoryWork => 'Travail';

  @override
  String get categoryEducation => 'Éducation';

  @override
  String get categoryCommunity => 'Communauté';

  @override
  String get categoryHealth => 'Santé et bien-être';

  @override
  String get tplPrayerRequestSafety =>
      'Demande de prière pour la sécurité et la protection';

  @override
  String get tplPrayerRequestSafetyDesc =>
      'Soumettez des demandes de prière pour la sécurité et la protection';

  @override
  String get tplWorkshopEvaluation => 'Évaluation de l\'atelier';

  @override
  String get tplWorkshopEvaluationDesc => 'Évaluer l’efficacité de l’atelier';

  @override
  String get tplSoccerTryoutEvaluation => 'Évaluation des essais de football';

  @override
  String get tplSoccerTryoutEvaluationDesc =>
      'Évaluer les performances aux essais de football';

  @override
  String get tplOralPresentationEvaluation =>
      'Formulaire d\'évaluation de la présentation orale';

  @override
  String get tplOralPresentationEvaluationDesc =>
      'Évaluer les compétences en présentation orale';

  @override
  String get tplPeerFeedback => 'Formulaire de commentaires des pairs';

  @override
  String get tplPeerFeedbackDesc => 'Fournir des commentaires aux pairs';

  @override
  String get tplPresentationFeedback => 'Commentaires sur la présentation';

  @override
  String get tplPresentationFeedbackDesc =>
      'Donner des commentaires sur les présentations';

  @override
  String get tplPatientFeedback => 'Formulaire de commentaires des patients';

  @override
  String get tplPatientFeedbackDesc =>
      'Recueillir les commentaires des patients sur les soins';

  @override
  String get tplChildcareRegistration =>
      'Formulaire d\'inscription pour la garde d\'enfants';

  @override
  String get tplChildcareRegistrationDesc =>
      'Inscrire les enfants aux services de garde';

  @override
  String get tplMedicationOrder => 'Formulaire de commande de médicaments';

  @override
  String get tplMedicationOrderDesc => 'Soumettre les commandes de médicaments';

  @override
  String get tplTeamworkCollaborationEvaluation =>
      'Évaluation du travail d\'équipe et de la collaboration';

  @override
  String get tplTeamworkCollaborationEvaluationDesc =>
      'Évaluer les compétences de collaboration en équipe';

  @override
  String get tplTrainingDevelopmentFeedback =>
      'Formulaire de commentaires sur la formation et le développement';

  @override
  String get tplTrainingDevelopmentFeedbackDesc =>
      'Fournir des commentaires sur les programmes de formation';

  @override
  String get tplAnnualEmployeePerformanceReview =>
      'Évaluation annuelle du rendement des employés';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc =>
      'Évaluer le rendement des employés chaque année';

  @override
  String get useThisTemplate => 'Utilisez ce modèle';

  @override
  String get failedToCopyTemplate =>
      'Échec de la copie du modèle. Veuillez réessayer.';

  @override
  String get untitledForm => 'Formulaire sans titre';

  @override
  String sectionTitleOf(int n, int total) {
    return 'Section $n de $total';
  }

  @override
  String get sectionTitle => 'Titre de la section';

  @override
  String get shortAnswerText => 'Texte de réponse court';

  @override
  String get longAnswerText => 'Texte de réponse long';

  @override
  String get imageTitleOptional => 'Titre de l\'image (facultatif)';

  @override
  String get videoTitle => 'Titre de la vidéo';

  @override
  String optionLabel(int n) {
    return 'Option $n';
  }

  @override
  String get youTubeVideo => 'Vidéo YouTube';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Compte Google';

  @override
  String get signOut => 'se déconnecter';

  @override
  String get signOutTitle => 'Se déconnecter?';

  @override
  String get signOutContent =>
      'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?';

  @override
  String get goPremium => 'Passez à la version premium';

  @override
  String get goPremiumDesc =>
      'Débloquez toutes les fonctionnalités et supprimez les publicités';

  @override
  String get about => 'À propos';

  @override
  String get privacyPolicy => 'politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get language => 'Langue';

  @override
  String get languageSystemDefault => 'Valeur par défaut du système';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => 'Modifier';

  @override
  String get tabPreview => 'Aperçu';

  @override
  String get tabResponses => 'Réponses';

  @override
  String get tabSettings => 'Paramètres';

  @override
  String get qTypeMultipleChoice => 'Choix multiple';

  @override
  String get qTypeCheckboxes => 'Cases à cocher';

  @override
  String get qTypeShortAnswer => 'Réponse courte';

  @override
  String get qTypeParagraph => 'Paragraphe';

  @override
  String get qTypeDropdown => 'Dérouler';

  @override
  String get qTypeImage => 'Image';

  @override
  String get qTypeVideo => 'Vidéo';

  @override
  String get qTypeLinearScale => 'Échelle linéaire';

  @override
  String get qTypeMultipleChoiceGrid => 'Grille à choix multiples';

  @override
  String get qTypeCheckboxGrid => 'Grille de cases à cocher';

  @override
  String get qTypeDate => 'Date';

  @override
  String get qTypeTime => 'Temps';

  @override
  String get qTypeInfo => 'Informations';

  @override
  String get qTypeSection => 'Section';

  @override
  String get qTypeTitleDescription => 'titre et une description';

  @override
  String get addQuestion => 'Ajouter une question';

  @override
  String get addImage => 'Ajouter une image';

  @override
  String get addVideo => 'Ajouter une vidéo';

  @override
  String get addInfo => 'Ajouter des informations';

  @override
  String get addSection => 'Ajouter une rubrique';

  @override
  String get addYouTubeVideo => 'Ajouter une vidéo YouTube';

  @override
  String get pasteYouTubeUrl => 'Collez l\'URL YouTube ici';

  @override
  String get clickToUploadImage => 'Cliquez pour télécharger l\'image';

  @override
  String get pasteYouTubeVideoUrl => 'Coller l\'URL de la vidéo YouTube';

  @override
  String get saving => 'Économie...';

  @override
  String get formSaved =>
      'Formulaire enregistré ! Lien copié dans le presse-papiers.';

  @override
  String formSavedWithWarnings(String warnings) {
    return 'Formulaire enregistré ! Lien copié. $warnings';
  }

  @override
  String get failedToSaveForm => 'Échec de l\'enregistrement du formulaire.';

  @override
  String get failedToLoadForm => 'Échec du chargement du formulaire.';

  @override
  String get saveToPreview => 'Enregistrer pour prévisualiser';

  @override
  String get saveForm => 'Enregistrer le formulaire';

  @override
  String get saveTheFormFirst =>
      'Enregistrez d\'abord le formulaire pour obtenir un lien';

  @override
  String get saveBeforePublishing =>
      'Veuillez enregistrer le formulaire avant de le publier.';

  @override
  String get unsavedChanges => 'Modifications non enregistrées';

  @override
  String get unsavedChangesBackDesc =>
      'Vous avez des modifications non enregistrées. Vous souhaitez économiser avant de partir ?';

  @override
  String get unsavedChangesPreviewDesc =>
      'Enregistrez votre formulaire pour voir le dernier aperçu de vos modifications.';

  @override
  String get dontSave => 'Ne sauvegardez pas';

  @override
  String get untitledQuestion => 'Question sans titre';

  @override
  String get formTitle => 'Titre du formulaire';

  @override
  String get formDescription => 'Description du formulaire';

  @override
  String get addOption => 'Ajouter une option';

  @override
  String columnN(int n) {
    return 'Colonne $n';
  }

  @override
  String rowN(int n) {
    return 'Ligne $n';
  }

  @override
  String get addColumn => 'Ajouter une colonne';

  @override
  String get addRow => 'Ajouter une ligne';

  @override
  String get minValue => 'Valeur minimale';

  @override
  String get maxValue => 'Valeur maximale';

  @override
  String get labelOptional => 'Étiquette (facultatif)';

  @override
  String get showDescription => 'Afficher la description';

  @override
  String get includeYear => 'Inclure l\'année';

  @override
  String get duration => 'Durée';

  @override
  String get tooltipDragToReorder =>
      'Faites glisser pour réorganiser la question';

  @override
  String get tooltipCopyLink => 'Copier le lien';

  @override
  String get tooltipPublished => 'Publié';

  @override
  String get tooltipPublish => 'Publier';

  @override
  String get tooltipSave => 'Sauvegarder';

  @override
  String get tooltipDuplicate => 'Créer une copie';

  @override
  String get tooltipDelete => 'Supprimer';

  @override
  String get tooltipMoreOptions => 'Plus d\'options';

  @override
  String get tooltipAddImageToQuestion => 'Ajouter une image à la question';

  @override
  String get tooltipExportXlsx => 'Exporter au format .xlsx';

  @override
  String get tooltipExportCsv => 'Exporter au format .csv';

  @override
  String get tooltipOpenLinkedSheet => 'Ouvrir la feuille Google liée';

  @override
  String get tooltipLinkToSheet => 'Lien vers la feuille Google';

  @override
  String get tooltipRemoveEditor => 'Supprimer l\'éditeur';

  @override
  String get noPreviewAvailable => 'Aucun aperçu disponible';

  @override
  String get noPreviewDesc =>
      'Enregistrez d’abord votre formulaire pour voir un aperçu en direct de son apparence pour les répondants.';

  @override
  String get saveYourFormFirst => 'Enregistrez d\'abord votre formulaire';

  @override
  String get needSaveForResponses =>
      'Vous devez enregistrer votre formulaire avant de pouvoir afficher les réponses.';

  @override
  String get noResponsesYet => 'Pas encore de réponses';

  @override
  String get noResponsesDesc =>
      'Les réponses apparaîtront ici une fois que les gens auront soumis votre formulaire.';

  @override
  String get shareThisForm => 'Partager ce formulaire';

  @override
  String get responseSubSummary => 'Résumé';

  @override
  String get responseSubQuestion => 'Question';

  @override
  String get responseSubIndividual => 'Individuel';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '1 réponse',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => 'Pas encore de réponses.';

  @override
  String get noGridData => 'Aucune donnée de grille.';

  @override
  String andNMore(int n) {
    return '... et $n plus';
  }

  @override
  String get noQuestionsFound => 'Aucune question trouvée.';

  @override
  String get questionLabel => 'Question:';

  @override
  String questionN(int n) {
    return 'Question $n';
  }

  @override
  String get noResponses => 'Aucune réponse.';

  @override
  String responseNOfTotal(int n, int total) {
    return '$n de $total';
  }

  @override
  String submittedTime(String time) {
    return 'Soumis : $time';
  }

  @override
  String responseN(int n) {
    return 'Réponse $n';
  }

  @override
  String get noAnswer => 'Pas de réponse';

  @override
  String get couldNotOpenYouTube => 'Impossible d\'ouvrir YouTube.';

  @override
  String exportAs(String format) {
    return 'Exporter sous $format';
  }

  @override
  String get enterFileName =>
      'Saisissez un nom de fichier pour l\'exportation :';

  @override
  String get fileName => 'Nom de fichier';

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get responseId => 'ID de réponse';

  @override
  String get createTime => 'Créer du temps';

  @override
  String get lastSubmittedTime => 'Heure de la dernière soumission';

  @override
  String get responsesSheet => 'Réponses';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => 'Lié à la feuille';

  @override
  String get responsesAutoSaved =>
      'Les réponses sont automatiquement enregistrées dans cette feuille de calcul :';

  @override
  String get linkedSpreadsheet => 'Feuille de calcul liée';

  @override
  String get tapToOpenInBrowser => 'Appuyez pour ouvrir dans le navigateur';

  @override
  String get openSheet => 'Feuille ouverte';

  @override
  String get linkToGoogleSheet => 'Lien vers la feuille Google';

  @override
  String get linkSheetDesc =>
      'Les réponses au formulaire seront automatiquement enregistrées dans cette feuille de calcul. Un nouvel onglet de feuille sera créé avec toutes les réponses.';

  @override
  String get createAndLink => 'Créer et lier';

  @override
  String get spreadsheetName => 'Nom de la feuille de calcul';

  @override
  String get unlinkSheetTitle => 'Dissocier la feuille ?';

  @override
  String get unlinkSheetDesc =>
      'Les nouvelles réponses au formulaire ne seront plus enregistrées dans cette feuille de calcul. Les réponses existantes dans la feuille ne seront pas supprimées.';

  @override
  String get sheetUnlinked => 'Feuille dissociée avec succès.';

  @override
  String get failedToCreateSheet =>
      'Échec de la création de la feuille de calcul. Veuillez réessayer.';

  @override
  String formLinkedToSheet(String name) {
    return 'Formulaire lié à \"$name\" avec succès !';
  }

  @override
  String failedToLink(String error) {
    return 'Échec de l\'association : $error';
  }

  @override
  String failedToUnlink(String error) {
    return 'Échec de la dissociation : $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get publishRequired => 'Publication obligatoire';

  @override
  String get publishRequiredDesc =>
      'Vous devez publier ce formulaire avant de pouvoir accepter les réponses. Souhaitez-vous le publier maintenant ?';

  @override
  String get formPublished =>
      'Formulaire publié et j\'accepte maintenant les réponses !';

  @override
  String failedToPublish(String error) {
    return 'Échec de la publication : $error';
  }

  @override
  String get formUnpublished => 'Formulaire inédit';

  @override
  String get formIsPublished => 'Le formulaire est publié';

  @override
  String get copyFormLink => 'Copier le lien du formulaire';

  @override
  String get unpublishForm => 'Formulaire de dépublication';

  @override
  String get unpublishFormDesc =>
      'Le formulaire cessera d\'accepter les réponses';

  @override
  String get settingsResponses => 'Réponses';

  @override
  String get settingsPresentation => 'Présentation';

  @override
  String get settingsEditors => 'Éditeurs';

  @override
  String get acceptResponses => 'Accepter les réponses';

  @override
  String get acceptResponsesEnabled =>
      'Les gens peuvent soumettre des réponses à ce formulaire';

  @override
  String get acceptResponsesDisabled =>
      'Ce formulaire n\'accepte pas de réponses';

  @override
  String get collectEmail => 'Collecter des adresses e-mail';

  @override
  String get collectEmailDesc =>
      'Choisissez comment collecter les e-mails des répondeurs';

  @override
  String get dontCollect => 'Ne collectez pas';

  @override
  String get verified => 'Vérifié';

  @override
  String get responderInput => 'Informations saisies par le participant';

  @override
  String get limitToOneResponse => 'Limité à 1 réponse';

  @override
  String get limitToOneResponseDesc =>
      'Nécessite que les intervenants se connectent';

  @override
  String get editAfterSubmit => 'Modifier après soumission';

  @override
  String get editAfterSubmitDesc =>
      'Autoriser les répondants à modifier leur réponse après l\'envoi';

  @override
  String get showProgressBar => 'Afficher la barre de progression';

  @override
  String get showProgressBarDesc =>
      'Affiche une barre de progression au bas du formulaire';

  @override
  String get shuffleQuestionOrder => 'Mélanger l\'ordre des questions';

  @override
  String get shuffleQuestionOrderDesc =>
      'Les questions apparaîtront dans un ordre différent pour chaque répondant';

  @override
  String get confirmationMessage => 'Message de confirmation';

  @override
  String get confirmationMessageDesc =>
      'Message affiché après la soumission du formulaire';

  @override
  String get enterConfirmationMessage => 'Entrez le message de confirmation';

  @override
  String get defaultConfirmationMessage => 'Votre réponse a été enregistrée.';

  @override
  String get addEditor => 'Ajouter un éditeur';

  @override
  String get gmailAddress => 'Adresse Gmail';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => 'Veuillez saisir une adresse Gmail.';

  @override
  String get enterValidEmail =>
      'S\'il vous plaît, mettez une adresse email valide.';

  @override
  String get removeEditorTitle => 'Supprimer l\'éditeur ?';

  @override
  String removeEditorDesc(String name) {
    return 'Supprimer $name de ce formulaire ? Ils ne pourront plus le modifier.';
  }

  @override
  String get alreadyOwner => 'Vous êtes déjà propriétaire de ce formulaire.';

  @override
  String get alreadyOwnerOther =>
      'Cet utilisateur est déjà propriétaire de ce formulaire.';

  @override
  String get alreadyEditor =>
      'Cet utilisateur est déjà éditeur sur ce formulaire.';

  @override
  String get failedToAddEditor => 'Échec de l\'ajout de l\'éditeur.';

  @override
  String addedEditor(String email) {
    return 'Ajout de $email en tant qu\'éditeur.';
  }

  @override
  String get cannotRemoveOwner => 'Le propriétaire ne peut pas être supprimé.';

  @override
  String get failedToRemoveEditor => 'Échec de la suppression de l\'éditeur.';

  @override
  String removedEditor(String name) {
    return '$name supprimé.';
  }

  @override
  String get noOwnerFound => 'Aucun collaborateur trouvé pour ce formulaire.';

  @override
  String get noEditorsYet =>
      'Aucun éditeur pour l\'instant. Appuyez sur +Ajouter pour inviter quelqu\'un via Gmail.';

  @override
  String get noEditorsOnForm => 'Aucun éditeur sur ce formulaire.';

  @override
  String get failedToLoadEditors => 'Échec du chargement des éditeurs.';

  @override
  String get saveChangesTitle => 'Enregistrer les modifications ?';

  @override
  String breakingChangesDesc(String desc) {
    return 'Ce changement affectera les réponses existantes : $desc.\n\nVoulez-vous continuer ?';
  }

  @override
  String get duplicateChoicesError =>
      'Vous ne pouvez pas avoir de choix en double dans une question à choix multiples.';

  @override
  String get invalidDataError =>
      'Données invalides. Veuillez vérifier votre formulaire et réessayer.';

  @override
  String get permissionDeniedError =>
      'Autorisation refusée. Veuillez vérifier l\'accès à votre compte Google.';

  @override
  String get addAtLeastOneQuestion =>
      'Veuillez ajouter au moins une question avant de sauvegarder.';

  @override
  String get failedToUpdateForm => 'Échec de la mise à jour du formulaire.';

  @override
  String get failedToLoadCurrentForm =>
      'Échec du chargement des données actuelles du formulaire. Veuillez réessayer.';

  @override
  String couldNotLoadSettings(String error) {
    return 'Impossible de charger les paramètres du formulaire : $error';
  }

  @override
  String get linkCopiedToClipboardExclaim =>
      'Lien copié dans le presse-papier !';

  @override
  String get userFallback => 'Utilisateur';

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
  String get noInternetConnection => 'Pas de connexion Internet';

  @override
  String get noInternetConnectionDesc =>
      'Veuillez vérifier vos paramètres réseau et réessayer.';

  @override
  String get noInternetSaveError =>
      'Pas de connexion Internet. Impossible d\'enregistrer le formulaire.';

  @override
  String get noInternetLoadError =>
      'Pas de connexion Internet. Impossible de charger le formulaire.';

  @override
  String get retry => 'Réessayer';

  @override
  String get formNoLongerExists =>
      'Ce formulaire n\'existe plus ou a été supprimé.';

  @override
  String get failedToPickImage =>
      'Impossible de sélectionner l\'image. Veuillez réessayer.';

  @override
  String get failedToShareFile => 'Impossible de partager le fichier.';
}
