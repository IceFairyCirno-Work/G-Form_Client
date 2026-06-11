// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Form';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get discard => 'Descartar';

  @override
  String get continueAction => 'Continuar';

  @override
  String get done => 'Feito';

  @override
  String get remove => 'Remover';

  @override
  String get add => 'Adicionar';

  @override
  String get settings => 'Configurações';

  @override
  String get close => 'Fechar';

  @override
  String get untitled => 'Sem título';

  @override
  String get open => 'Abrir';

  @override
  String get change => 'Mudar';

  @override
  String get export => 'Exportar';

  @override
  String get publish => 'Publicar';

  @override
  String get unlink => 'Desvincular';

  @override
  String get duplicate => 'Fazer uma cópia';

  @override
  String get rename => 'Renomear';

  @override
  String get renameForm => 'Renomear';

  @override
  String get enterNewName => 'Digite o novo nome';

  @override
  String get documentName => 'Nome do documento';

  @override
  String get formRenamed => 'Renomeado';

  @override
  String get failedToRename => 'Falha ao renomear';

  @override
  String get required => 'Obrigatório';

  @override
  String get optional => 'Opcional';

  @override
  String get other => 'Outro';

  @override
  String get description => 'Descrição';

  @override
  String get question => 'Pergunta';

  @override
  String get columns => 'Colunas';

  @override
  String get rows => 'Linhas';

  @override
  String get image => 'Imagem';

  @override
  String get video => 'Vídeo';

  @override
  String get owner => 'Proprietário';

  @override
  String get loginSubtitle => 'Crie e gerencie formulários em qualquer lugar';

  @override
  String get signInWithGoogle => 'Faça login com o Google';

  @override
  String get signInFailed => 'Falha no login. Por favor, tente novamente.';

  @override
  String get tabMyForms => 'Meus formulários';

  @override
  String get tabTemplates => 'Galeria de modelos';

  @override
  String get searchForms => 'Pesquise seus formulários';

  @override
  String get searchTemplates => 'Modelos de pesquisa';

  @override
  String get recentForms => 'Formulários recentes';

  @override
  String get noRecentForms => 'Nenhum item recente';

  @override
  String noFormsMatching(String query) {
    return 'Nenhum formulário correspondente a \"$query\"';
  }

  @override
  String get tryDifferentSearch => 'Experimente um termo de pesquisa diferente';

  @override
  String noTemplatesMatching(String query) {
    return 'Nenhum modelo correspondente a \"$query\"';
  }

  @override
  String get tryDifferentSearchOrCategory =>
      'Experimente um termo de pesquisa ou categoria diferente';

  @override
  String get thisIsTheEnd => '-Este é o fim-';

  @override
  String get linkCopiedToClipboard =>
      'Link copiado para a área de transferência';

  @override
  String get deleteFormTitle => 'Mover para a lixeira?';

  @override
  String get deleteFormContent => 'Este formulário será movido para a lixeira.';

  @override
  String get formMovedToTrash => 'Movido para a lixeira';

  @override
  String get failedToDeleteForm => 'Falha ao excluir o formulário';

  @override
  String get duplicatingForm => 'Criando uma cópia…';

  @override
  String get formDuplicated => 'Cópia criada';

  @override
  String get failedToDuplicateForm => 'Falha ao criar uma cópia';

  @override
  String get templateComingSoon => 'Modelo em breve!';

  @override
  String get loadingTemplate => 'Carregando modelo...';

  @override
  String get failedToLoadTemplate =>
      'Falha ao carregar o modelo. Por favor, tente novamente.';

  @override
  String get soon => 'Breve';

  @override
  String templateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modelos',
      one: '1 modelo',
    );
    return '$_temp0';
  }

  @override
  String get ownedByAnyone => 'Propriedade de qualquer pessoa';

  @override
  String get ownedByMe => 'De minha propriedade';

  @override
  String get notOwnedByMe => 'Não é de minha propriedade';

  @override
  String get lastModified => 'Modificado';

  @override
  String get lastOpened => 'Aberto por mim';

  @override
  String get titleAZ => 'Nome';

  @override
  String get copyLink => 'Copiar link';

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryWork => 'Trabalhar';

  @override
  String get categoryEducation => 'Educação';

  @override
  String get categoryCommunity => 'Comunidade';

  @override
  String get categoryHealth => 'Saúde e bem-estar';

  @override
  String get tplPrayerRequestSafety =>
      'Pedido de Oração por Segurança e Proteção';

  @override
  String get tplPrayerRequestSafetyDesc =>
      'Envie pedidos de oração por segurança e proteção';

  @override
  String get tplWorkshopEvaluation => 'Avaliação da Oficina';

  @override
  String get tplWorkshopEvaluationDesc => 'Avalie a eficácia do workshop';

  @override
  String get tplSoccerTryoutEvaluation => 'Avaliação de teste de futebol';

  @override
  String get tplSoccerTryoutEvaluationDesc =>
      'Avalie o desempenho nos testes de futebol';

  @override
  String get tplOralPresentationEvaluation =>
      'Formulário de Avaliação de Apresentação Oral';

  @override
  String get tplOralPresentationEvaluationDesc =>
      'Avalie habilidades de apresentação oral';

  @override
  String get tplPeerFeedback => 'Formulário de feedback de colegas';

  @override
  String get tplPeerFeedbackDesc => 'Fornecer feedback aos colegas';

  @override
  String get tplPresentationFeedback => 'Feedback da apresentação';

  @override
  String get tplPresentationFeedbackDesc => 'Dê feedback sobre apresentações';

  @override
  String get tplPatientFeedback => 'Formulário de Feedback do Paciente';

  @override
  String get tplPatientFeedbackDesc =>
      'Colete feedback do paciente sobre o atendimento';

  @override
  String get tplChildcareRegistration => 'Formulário de registro de creche';

  @override
  String get tplChildcareRegistrationDesc =>
      'Cadastrar crianças em serviços de cuidado infantil';

  @override
  String get tplMedicationOrder => 'Formulário de pedido de medicamentos';

  @override
  String get tplMedicationOrderDesc => 'Enviar pedidos de medicamentos';

  @override
  String get tplTeamworkCollaborationEvaluation =>
      'Avaliação de trabalho em equipe e colaboração';

  @override
  String get tplTeamworkCollaborationEvaluationDesc =>
      'Avalie as habilidades de colaboração da equipe';

  @override
  String get tplTrainingDevelopmentFeedback =>
      'Formulário de feedback sobre treinamento e desenvolvimento';

  @override
  String get tplTrainingDevelopmentFeedbackDesc =>
      'Fornecer feedback sobre programas de treinamento';

  @override
  String get tplAnnualEmployeePerformanceReview =>
      'Revisão Anual de Desempenho dos Funcionários';

  @override
  String get tplAnnualEmployeePerformanceReviewDesc =>
      'Revise o desempenho dos funcionários anualmente';

  @override
  String get useThisTemplate => 'Use este modelo';

  @override
  String get failedToCopyTemplate =>
      'Falha ao copiar o modelo. Por favor, tente novamente.';

  @override
  String get untitledForm => 'Formulário sem título';

  @override
  String sectionTitleOf(int n, int total) {
    return 'Seção $n de $total';
  }

  @override
  String get sectionTitle => 'Título da seção';

  @override
  String get shortAnswerText => 'Texto de resposta curta';

  @override
  String get longAnswerText => 'Texto de resposta longo';

  @override
  String get imageTitleOptional => 'Título da imagem (opcional)';

  @override
  String get videoTitle => 'Título do vídeo';

  @override
  String optionLabel(int n) {
    return 'Opção $n';
  }

  @override
  String get youTubeVideo => 'Vídeo do YouTube';

  @override
  String get dateFormatWithYear => 'MM/DD/YYYY';

  @override
  String get dateFormatNoYear => 'MM/DD';

  @override
  String get timeFormatDuration => 'HH:MM:SS';

  @override
  String get timeFormatStandard => 'HH:MM';

  @override
  String get googleAccount => 'Conta do Google';

  @override
  String get signOut => 'sair';

  @override
  String get signOutTitle => 'Sair?';

  @override
  String get signOutContent => 'Tem certeza de que deseja sair da sua conta?';

  @override
  String get goPremium => 'Torne-se Premium';

  @override
  String get goPremiumDesc => 'Desbloqueie todos os recursos e remova anúncios';

  @override
  String get about => 'Sobre';

  @override
  String get privacyPolicy => 'política de Privacidade';

  @override
  String get termsOfUse => 'Termos de Uso';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get language => 'Linguagem';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get tabEdit => 'Editar';

  @override
  String get tabPreview => 'Visualização';

  @override
  String get tabResponses => 'Respostas';

  @override
  String get tabSettings => 'Configurações';

  @override
  String get qTypeMultipleChoice => 'Múltipla escolha';

  @override
  String get qTypeCheckboxes => 'Caixas de seleção';

  @override
  String get qTypeShortAnswer => 'Resposta curta';

  @override
  String get qTypeParagraph => 'Parágrafo';

  @override
  String get qTypeDropdown => 'Suspenso';

  @override
  String get qTypeImage => 'Imagem';

  @override
  String get qTypeVideo => 'Vídeo';

  @override
  String get qTypeLinearScale => 'Escala linear';

  @override
  String get qTypeMultipleChoiceGrid => 'Grade de múltipla escolha';

  @override
  String get qTypeCheckboxGrid => 'Grade de caixa de seleção';

  @override
  String get qTypeDate => 'Data';

  @override
  String get qTypeTime => 'Horário';

  @override
  String get qTypeInfo => 'Informações';

  @override
  String get qTypeSection => 'Seção';

  @override
  String get qTypeTitleDescription => 'Título e descrição';

  @override
  String get addQuestion => 'Adicionar pergunta';

  @override
  String get addImage => 'Adicionar imagem';

  @override
  String get addVideo => 'Adicionar vídeo';

  @override
  String get addInfo => 'Adicionar informações';

  @override
  String get addSection => 'Adicionar seção';

  @override
  String get addYouTubeVideo => 'Adicionar vídeo do YouTube';

  @override
  String get pasteYouTubeUrl => 'Cole o URL do YouTube aqui';

  @override
  String get clickToUploadImage => 'Clique para fazer upload da imagem';

  @override
  String get pasteYouTubeVideoUrl => 'Cole o URL do vídeo do YouTube';

  @override
  String get saving => 'Salvando...';

  @override
  String get formSaved =>
      'Formulário salvo! Link copiado para a área de transferência.';

  @override
  String formSavedWithWarnings(String warnings) {
    return 'Formulário salvo! Link copiado. $warnings';
  }

  @override
  String get failedToSaveForm => 'Falha ao salvar o formulário.';

  @override
  String get failedToLoadForm => 'Falha ao carregar o formulário.';

  @override
  String get saveToPreview => 'Salvar para visualizar';

  @override
  String get saveForm => 'Salvar formulário';

  @override
  String get saveTheFormFirst =>
      'Salve o formulário primeiro para obter um link';

  @override
  String get saveBeforePublishing => 'Salve o formulário antes de publicar.';

  @override
  String get unsavedChanges => 'Alterações não salvas';

  @override
  String get unsavedChangesBackDesc =>
      'Você tem alterações não salvas. Quer economizar antes de sair?';

  @override
  String get unsavedChangesPreviewDesc =>
      'Salve seu formulário para ver a visualização mais recente de suas alterações.';

  @override
  String get dontSave => 'Não salve';

  @override
  String get untitledQuestion => 'Pergunta sem título';

  @override
  String get formTitle => 'Título do formulário';

  @override
  String get formDescription => 'Descrição do formulário';

  @override
  String get addOption => 'Adicionar opção';

  @override
  String columnN(int n) {
    return 'Coluna $n';
  }

  @override
  String rowN(int n) {
    return 'Linha $n';
  }

  @override
  String get addColumn => 'Adicionar coluna';

  @override
  String get addRow => 'Adicionar linha';

  @override
  String get minValue => 'Valor mínimo';

  @override
  String get maxValue => 'Valor máximo';

  @override
  String get labelOptional => 'Etiqueta (opcional)';

  @override
  String get showDescription => 'Mostrar descrição';

  @override
  String get includeYear => 'Incluir ano';

  @override
  String get duration => 'Duração';

  @override
  String get tooltipDragToReorder => 'Arraste para reordenar a pergunta';

  @override
  String get tooltipCopyLink => 'Copiar link';

  @override
  String get tooltipPublished => 'Publicado';

  @override
  String get tooltipPublish => 'Publicar';

  @override
  String get tooltipSave => 'Salvar';

  @override
  String get tooltipDuplicate => 'Fazer uma cópia';

  @override
  String get tooltipDelete => 'Excluir';

  @override
  String get tooltipMoreOptions => 'Mais opções';

  @override
  String get tooltipAddImageToQuestion => 'Adicionar imagem à pergunta';

  @override
  String get tooltipExportXlsx => 'Exportar como .xlsx';

  @override
  String get tooltipExportCsv => 'Baixar respostas (.csv)';

  @override
  String get tooltipOpenLinkedSheet => 'Abrir planilha do Google vinculada';

  @override
  String get tooltipLinkToSheet => 'Link para planilha do Google';

  @override
  String get tooltipRemoveEditor => 'Remover editor';

  @override
  String get noPreviewAvailable => 'Nenhuma visualização disponível';

  @override
  String get noPreviewDesc =>
      'Salve seu formulário primeiro para ver uma visualização ao vivo de sua aparência para os respondentes.';

  @override
  String get saveYourFormFirst => 'Salve seu formulário primeiro';

  @override
  String get needSaveForResponses =>
      'Você precisa salvar seu formulário antes de poder visualizar as respostas.';

  @override
  String get noResponsesYet => 'Ainda não há respostas';

  @override
  String get noResponsesDesc =>
      'As respostas aparecerão aqui assim que as pessoas enviarem seu formulário.';

  @override
  String get shareThisForm => 'Compartilhe este formulário';

  @override
  String get responseSubSummary => 'Resumo';

  @override
  String get responseSubQuestion => 'Pergunta';

  @override
  String get responseSubIndividual => 'Individual';

  @override
  String nResponses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respostas',
      one: '1 resposta',
    );
    return '$_temp0';
  }

  @override
  String get noAnswersYet => 'Ainda não há respostas.';

  @override
  String get noGridData => 'Sem dados de grade.';

  @override
  String andNMore(int n) {
    return '... e $n mais';
  }

  @override
  String get noQuestionsFound => 'Nenhuma pergunta encontrada.';

  @override
  String get questionLabel => 'Pergunta:';

  @override
  String questionN(int n) {
    return 'Pergunta $n';
  }

  @override
  String get noResponses => 'Sem respostas.';

  @override
  String responseNOfTotal(int n, int total) {
    return '$n de $total';
  }

  @override
  String submittedTime(String time) {
    return 'Enviado: $time';
  }

  @override
  String responseN(int n) {
    return 'Resposta $n';
  }

  @override
  String get noAnswer => 'Sem resposta';

  @override
  String get couldNotOpenYouTube => 'Não foi possível abrir o YouTube.';

  @override
  String exportAs(String format) {
    return 'Exportar como $format';
  }

  @override
  String get enterFileName => 'Insira um nome de arquivo para a exportação:';

  @override
  String get fileName => 'Nome do arquivo';

  @override
  String exportFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String get responseId => 'ID da resposta';

  @override
  String get createTime => 'Criar tempo';

  @override
  String get lastSubmittedTime => 'Hora do último envio';

  @override
  String get responsesSheet => 'Respostas';

  @override
  String get exportXlsx => 'XLSX';

  @override
  String get exportCsv => 'CSV';

  @override
  String get sheets => 'Sheets';

  @override
  String get linkedToSheet => 'Vinculado à planilha';

  @override
  String get responsesAutoSaved =>
      'As respostas são salvas automaticamente nesta planilha:';

  @override
  String get linkedSpreadsheet => 'Planilha vinculada';

  @override
  String get tapToOpenInBrowser => 'Toque para abrir no navegador';

  @override
  String get openSheet => 'Ver no app Planilhas';

  @override
  String get linkToGoogleSheet => 'Link para planilha do Google';

  @override
  String get linkSheetDesc =>
      'As respostas do formulário serão salvas automaticamente nesta planilha. Uma nova guia de planilha será criada com todas as respostas.';

  @override
  String get createAndLink => 'Criar e vincular';

  @override
  String get spreadsheetName => 'Nome da planilha';

  @override
  String get unlinkSheetTitle => 'Desvincular planilha?';

  @override
  String get unlinkSheetDesc =>
      'As novas respostas do formulário não serão mais salvas nesta planilha. As respostas existentes na planilha não serão excluídas.';

  @override
  String get sheetUnlinked => 'Planilha desvinculada com sucesso.';

  @override
  String get failedToCreateSheet =>
      'Falha ao criar planilha. Por favor, tente novamente.';

  @override
  String formLinkedToSheet(String name) {
    return 'Formulário vinculado a \"$name\" com sucesso!';
  }

  @override
  String failedToLink(String error) {
    return 'Falha ao vincular: $error';
  }

  @override
  String failedToUnlink(String error) {
    return 'Falha ao desvincular: $error';
  }

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get publishRequired => 'Publicação obrigatória';

  @override
  String get publishRequiredDesc =>
      'Você precisa publicar este formulário antes que ele possa aceitar respostas. Você gostaria de publicá-lo agora?';

  @override
  String get formPublished => 'Formulário publicado e já aceitando respostas!';

  @override
  String failedToPublish(String error) {
    return 'Falha ao publicar: $error';
  }

  @override
  String get formUnpublished => 'Formulário não publicado';

  @override
  String get formIsPublished => 'O formulário foi publicado';

  @override
  String get copyFormLink => 'Copiar link do participante';

  @override
  String get unpublishForm => 'Cancelar publicação do formulário';

  @override
  String get unpublishFormDesc => 'O formulário deixará de aceitar respostas';

  @override
  String get settingsResponses => 'Respostas';

  @override
  String get settingsPresentation => 'Apresentação';

  @override
  String get settingsEditors => 'Editores';

  @override
  String get acceptResponses => 'Aceitar respostas';

  @override
  String get acceptResponsesEnabled =>
      'As pessoas podem enviar respostas a este formulário';

  @override
  String get acceptResponsesDisabled =>
      'Este formulário não está aceitando respostas';

  @override
  String get collectEmail => 'Colete endereços de e-mail';

  @override
  String get collectEmailDesc => 'Escolha como coletar e-mails de resposta';

  @override
  String get dontCollect => 'Não colete';

  @override
  String get verified => 'Verificado';

  @override
  String get responderInput => 'Entrada do respondente';

  @override
  String get limitToOneResponse => 'Limite a 1 resposta';

  @override
  String get limitToOneResponseDesc => 'Exige que os respondentes façam login';

  @override
  String get editAfterSubmit => 'Editar após enviar';

  @override
  String get editAfterSubmitDesc =>
      'Permitir que os respondentes editem suas respostas após o envio';

  @override
  String get showProgressBar => 'Mostrar barra de progresso';

  @override
  String get showProgressBarDesc =>
      'Mostra uma barra de progresso na parte inferior do formulário';

  @override
  String get shuffleQuestionOrder => 'Ordem aleatória das perguntas';

  @override
  String get shuffleQuestionOrderDesc =>
      'As perguntas aparecerão em uma ordem diferente para cada respondente';

  @override
  String get confirmationMessage => 'Mensagem de confirmação';

  @override
  String get confirmationMessageDesc =>
      'Mensagem mostrada após o envio do formulário';

  @override
  String get enterConfirmationMessage => 'Digite a mensagem de confirmação';

  @override
  String get defaultConfirmationMessage => 'Sua resposta foi registrada.';

  @override
  String get addEditor => 'Adicionar editor';

  @override
  String get gmailAddress => 'Endereço do Gmail';

  @override
  String get gmailHint => 'name@gmail.com';

  @override
  String get enterGmail => 'Insira um endereço do Gmail.';

  @override
  String get enterValidEmail => 'Insira um endereço de e-mail válido.';

  @override
  String get removeEditorTitle => 'Remover editor?';

  @override
  String removeEditorDesc(String name) {
    return 'Remover $name deste formulário? Eles não poderão mais editá-lo.';
  }

  @override
  String get alreadyOwner => 'Você já é o proprietário deste formulário.';

  @override
  String get alreadyOwnerOther =>
      'Este usuário já é o proprietário deste formulário.';

  @override
  String get alreadyEditor => 'Este usuário já é editor deste formulário.';

  @override
  String get failedToAddEditor => 'Falha ao adicionar editor.';

  @override
  String addedEditor(String email) {
    return 'Adicionado $email como editor.';
  }

  @override
  String get cannotRemoveOwner => 'O proprietário não pode ser removido.';

  @override
  String get failedToRemoveEditor => 'Falha ao remover o editor.';

  @override
  String removedEditor(String name) {
    return 'Removido $name.';
  }

  @override
  String get noOwnerFound =>
      'Nenhum colaborador encontrado para este formulário.';

  @override
  String get noEditorsYet =>
      'Ainda não há editores. Toque em +Adicionar para convidar alguém pelo Gmail.';

  @override
  String get noEditorsOnForm => 'Não há editores neste formulário.';

  @override
  String get failedToLoadEditors => 'Falha ao carregar editores.';

  @override
  String get saveChangesTitle => 'Salvar alterações?';

  @override
  String breakingChangesDesc(String desc) {
    return 'Esta alteração afetará as respostas existentes: $desc.\n\nVocê quer continuar?';
  }

  @override
  String get duplicateChoicesError =>
      'Você não pode ter escolhas duplicadas em uma questão de múltipla escolha.';

  @override
  String get invalidDataError =>
      'Dados inválidos. Verifique seu formulário e tente novamente.';

  @override
  String get permissionDeniedError =>
      'Permissão negada. Verifique o acesso à sua conta do Google.';

  @override
  String get addAtLeastOneQuestion =>
      'Adicione pelo menos uma pergunta antes de salvar.';

  @override
  String get failedToUpdateForm => 'Falha ao atualizar o formulário.';

  @override
  String get failedToLoadCurrentForm =>
      'Falha ao carregar os dados do formulário atual. Por favor, tente novamente.';

  @override
  String couldNotLoadSettings(String error) {
    return 'Não foi possível carregar as configurações do formulário: $error';
  }

  @override
  String get linkCopiedToClipboardExclaim =>
      'Link copiado para a área de transferência!';

  @override
  String get userFallback => 'Usuário';

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
  String get noInternetConnection => 'Sem conexão com a internet';

  @override
  String get noInternetConnectionDesc =>
      'Verifique suas configurações de rede e tente novamente.';

  @override
  String get noInternetSaveError =>
      'Sem conexão com a internet. Não é possível salvar o formulário.';

  @override
  String get noInternetLoadError =>
      'Sem conexão com a internet. Não é possível carregar o formulário.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get formNoLongerExists =>
      'Este formulário não existe mais ou foi excluído.';

  @override
  String get failedToPickImage =>
      'Não foi possível selecionar a imagem. Tente novamente.';

  @override
  String get failedToShareFile => 'Não foi possível compartilhar o arquivo.';
}
