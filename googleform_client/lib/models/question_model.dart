import 'dart:core';

enum QuestionType {
  multipleChoice,
  checkbox,
  shortAnswer,
  paragraph,
  dropdown,
  image,
  video,
  linearScale,
  multipleChoiceGrid,
  checkboxGrid,
  date,
  time,
  info,
  section,
}

class QuestionItem {
  String itemId; // Google Forms API item ID for response matching
  String questionText;
  QuestionType type;
  List<String> options;
  bool isRequired;
  String? mediaUrl; // For image file path or YouTube video URL
  String? embeddedImageUrl; // Image embedded within a question (non-image/video types)

  // Linear Scale fields
  int scaleLow;
  int scaleHigh;
  String? scaleLowLabel;
  String? scaleHighLabel;

  // Grid fields (for multipleChoiceGrid and checkboxGrid)
  List<String> gridRows;
  List<String> gridColumns;
  List<String> gridRowQuestionIds; // API question IDs for each grid row

  // Date fields
  bool dateIncludeYear;
  bool dateIncludeTime;

  // Time fields
  bool timeDuration;

  // "Other" option for choice questions (not applicable for dropdown)
  bool isOther;

  // Description (for Date/Time questions)
  String? description;
  bool showDescription;

  QuestionItem({
    this.itemId = '',
    this.questionText = '',
    this.type = QuestionType.multipleChoice,
    List<String>? options,
    this.isRequired = false,
    this.mediaUrl,
    this.embeddedImageUrl,
    this.scaleLow = 1,
    this.scaleHigh = 5,
    this.scaleLowLabel,
    this.scaleHighLabel,
    List<String>? gridRows,
    List<String>? gridColumns,
    List<String>? gridRowQuestionIds,
    this.dateIncludeYear = true,
    this.dateIncludeTime = false,
    this.timeDuration = false,
    this.isOther = false,
    this.description,
    this.showDescription = false,
  })  : options = options ?? [''],
        gridRows = gridRows ?? [''],
        gridColumns = gridColumns ?? ['', ''],
        gridRowQuestionIds = gridRowQuestionIds ?? [];

  /// Normalizes any YouTube URL to the format the Google Forms API requires:
  /// `https://www.youtube.com/watch?v=VIDEO_ID`
  /// Handles: youtu.be/ID, youtube.com/watch?v=ID, youtube.com/embed/ID, etc.
  static String _normalizeYouTubeUrl(String url) {
    String? videoId;

    // youtube.com/watch?v=ID (may have extra params like &t=123, &si=..., etc.)
    final watchMatch = RegExp(r'youtube\.com/watch\?.*v=([a-zA-Z0-9_-]{11})')
        .firstMatch(url);
    if (watchMatch != null) {
      videoId = watchMatch.group(1);
    }

    // youtu.be/ID (may have tracking params like ?si=...)
    if (videoId == null) {
      final shortMatch =
          RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})').firstMatch(url);
      if (shortMatch != null) {
        videoId = shortMatch.group(1);
      }
    }

    // youtube.com/embed/ID
    if (videoId == null) {
      final embedMatch =
          RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})').firstMatch(url);
      if (embedMatch != null) {
        videoId = embedMatch.group(1);
      }
    }

    // youtube.com/v/ID
    if (videoId == null) {
      final vMatch =
          RegExp(r'youtube\.com/v/([a-zA-Z0-9_-]{11})').firstMatch(url);
      if (vMatch != null) {
        videoId = vMatch.group(1);
      }
    }

    if (videoId != null) {
      return 'https://www.youtube.com/watch?v=$videoId';
    }

    // Could not extract video ID — return original URL as fallback
    return url;
  }

  /// Whether this type uses options (choice-based)
  bool get isChoiceType =>
      type == QuestionType.multipleChoice ||
      type == QuestionType.checkbox ||
      type == QuestionType.dropdown;

  /// Whether this type has no special content (just text input preview)
  bool get isTextOnlyType =>
      type == QuestionType.shortAnswer ||
      type == QuestionType.paragraph;

  /// Build the item body (shared between createItem and updateItem).
  /// Returns the "item" object without createItem/updateItem wrapper.
  Map<String, dynamic> _buildItemBody() {
    // Image items
    if (type == QuestionType.image) {
      final imageItem = <String, dynamic>{
        'title': questionText.isEmpty ? 'Image' : questionText,
        'imageItem': {
          'image': {
            'sourceUri': mediaUrl ?? '',
            'properties': {
              'alignment': 'LEFT',
            },
          },
        },
      };
      if (description != null && description!.isNotEmpty) {
        imageItem['description'] = description;
      }
      return imageItem;
    }

    // Video items
    if (type == QuestionType.video) {
      final normalizedUrl =
          (mediaUrl != null && mediaUrl!.isNotEmpty)
              ? _normalizeYouTubeUrl(mediaUrl!)
              : '';
      final videoItem = <String, dynamic>{
        'title': questionText.isEmpty ? 'Video' : questionText,
        'videoItem': {
          'video': {
            'youtubeUri': normalizedUrl,
          },
        },
      };
      if (description != null && description!.isNotEmpty) {
        videoItem['description'] = description;
      }
      return videoItem;
    }

    // Info items
    if (type == QuestionType.info) {
      final infoItem = <String, dynamic>{
        'title': questionText.isEmpty ? 'Info' : questionText,
        'textItem': {},
      };
      if (showDescription && description != null && description!.isNotEmpty) {
        infoItem['description'] = description;
      }
      return infoItem;
    }

    // Section items
    if (type == QuestionType.section) {
      final sectionItem = <String, dynamic>{
        'title': questionText.isEmpty ? 'Section' : questionText,
        'pageBreakItem': {},
      };
      if (description != null && description!.isNotEmpty) {
        sectionItem['description'] = description;
      }
      return sectionItem;
    }

    final isTextType = type == QuestionType.shortAnswer || type == QuestionType.paragraph;

    Map<String, dynamic> questionDef;
    if (isTextType) {
      questionDef = {
        'required': isRequired,
        'textQuestion': {
          'paragraph': type == QuestionType.paragraph,
        },
      };
    } else if (type == QuestionType.linearScale) {
      final low = scaleLow.clamp(0, scaleHigh - 1);
      final high = scaleHigh.clamp(low + 1, 10);
      final scaleMap = <String, dynamic>{
        'required': isRequired,
        'scaleQuestion': {
          'low': low,
          'high': high,
        },
      };
      if (scaleLowLabel != null && scaleLowLabel!.isNotEmpty) {
        (scaleMap['scaleQuestion'] as Map<String, dynamic>)['lowLabel'] = scaleLowLabel;
      }
      if (scaleHighLabel != null && scaleHighLabel!.isNotEmpty) {
        (scaleMap['scaleQuestion'] as Map<String, dynamic>)['highLabel'] = scaleHighLabel;
      }
      questionDef = scaleMap;
    } else if (type == QuestionType.multipleChoiceGrid || type == QuestionType.checkboxGrid) {
      final apiGridType = type == QuestionType.multipleChoiceGrid ? 'RADIO' : 'CHECKBOX';
      final nonEmptyRows = gridRows.where((r) => r.isNotEmpty).toList();
      final nonEmptyCols = gridColumns.where((c) => c.isNotEmpty).toList();
      if (nonEmptyRows.isEmpty) nonEmptyRows.add('Row 1');
      if (nonEmptyCols.isEmpty) nonEmptyCols.add('Column 1');

      final gridItem = <String, dynamic>{
        'title': questionText.isEmpty ? 'Untitled Question' : questionText,
        'questionGroupItem': {
          'grid': {
            'columns': {
              'type': apiGridType,
              'options': nonEmptyCols.map((c) => {'value': c}).toList(),
            },
          },
          'questions': nonEmptyRows.map((r) {
            return {'rowQuestion': {'title': r}};
          }).toList(),
        },
      };
      if (description != null && description!.isNotEmpty) {
        gridItem['description'] = description;
      }
      if (embeddedImageUrl != null && embeddedImageUrl!.isNotEmpty) {
        (gridItem['questionGroupItem'] as Map<String, dynamic>)['image'] = {
          'sourceUri': embeddedImageUrl,
          'properties': {'alignment': 'LEFT'},
        };
      }
      return gridItem;
    } else if (type == QuestionType.date) {
      questionDef = {
        'required': isRequired,
        'dateQuestion': {
          'includeYear': dateIncludeYear,
        },
      };
    } else if (type == QuestionType.time) {
      questionDef = {
        'required': isRequired,
        'timeQuestion': {
          'duration': timeDuration,
        },
      };
    } else {
      // Choice questions
      String apiType;
      switch (type) {
        case QuestionType.multipleChoice:
          apiType = 'RADIO';
          break;
        case QuestionType.checkbox:
          apiType = 'CHECKBOX';
          break;
        case QuestionType.dropdown:
          apiType = 'DROP_DOWN';
          break;
        default:
          apiType = 'RADIO';
      }
      final nonEmptyOptions = options.where((o) => o.isNotEmpty).toList();
      if (nonEmptyOptions.isEmpty) {
        nonEmptyOptions.add('Option 1');
      }
      final optionsList = nonEmptyOptions.map((o) => <String, dynamic>{'value': o}).toList();
      if (isOther && type != QuestionType.dropdown) {
        optionsList.add({'isOther': true});
      }
      final choiceQ = <String, dynamic>{
        'type': apiType,
        'options': optionsList,
      };
      questionDef = {
        'required': isRequired,
        'choiceQuestion': choiceQ,
      };
    }

    final questionItemMap = <String, dynamic>{
      'question': questionDef,
    };
    if (embeddedImageUrl != null && embeddedImageUrl!.isNotEmpty) {
      questionItemMap['image'] = {
        'sourceUri': embeddedImageUrl,
        'properties': {'alignment': 'LEFT'},
      };
    }

    final item = <String, dynamic>{
      'title': questionText.isEmpty ? 'Untitled Question' : questionText,
      'questionItem': questionItemMap,
    };
    if (showDescription && description != null && description!.isNotEmpty) {
      item['description'] = description;
    }
    return item;
  }

  /// Generate a createItem request for this question.
  Map<String, dynamic> toApiJson(int locationIndex) {
    return {
      'createItem': {
        'item': _buildItemBody(),
        'location': {'index': locationIndex},
      },
    };
  }

  /// Generate an updateItem request for this question.
  /// [locationIndex] is the current index of the item in the form.
  /// [updateMask] is a comma-separated list of fields to update (e.g. "title,description,questionItem").
  Map<String, dynamic> toUpdateItemApiJson(int locationIndex, String updateMask) {
    final body = _buildItemBody();
    if (itemId.isNotEmpty) {
      body['itemId'] = itemId;
    }
    return {
      'updateItem': {
        'item': body,
        'location': {'index': locationIndex},
        'updateMask': updateMask,
      },
    };
  }

  /// Compute the update mask by comparing this item with [other].
  /// Returns a comma-separated field mask string for use with updateItem.
  String computeUpdateMask(QuestionItem other) {
    final fields = <String>[];

    if (questionText != other.questionText) {
      fields.add('title');
    }
    if (description != other.description || showDescription != other.showDescription) {
      fields.add('description');
    }
    if (isRequired != other.isRequired) {
      fields.add('questionItem.question.required');
    }

    // Type change means we need to update the whole question structure
    if (type != other.type) {
      fields.add('questionItem.question');
      // No need to check further — full question update
      return fields.join(',');
    }

    // Check type-specific fields
    switch (type) {
      case QuestionType.multipleChoice:
      case QuestionType.checkbox:
      case QuestionType.dropdown:
        if (!_listEquals(options, other.options) || isOther != other.isOther) {
          fields.add('questionItem.question.choiceQuestion');
        }
        break;
      case QuestionType.shortAnswer:
      case QuestionType.paragraph:
        if (type != other.type) {
          fields.add('questionItem.question.textQuestion');
        }
        break;
      case QuestionType.linearScale:
        if (scaleLow != other.scaleLow ||
            scaleHigh != other.scaleHigh ||
            scaleLowLabel != other.scaleLowLabel ||
            scaleHighLabel != other.scaleHighLabel) {
          fields.add('questionItem.question.scaleQuestion');
        }
        break;
      case QuestionType.multipleChoiceGrid:
      case QuestionType.checkboxGrid:
        if (!_listEquals(gridRows, other.gridRows) ||
            !_listEquals(gridColumns, other.gridColumns)) {
          fields.add('questionGroupItem');
        }
        break;
      case QuestionType.date:
        if (dateIncludeYear != other.dateIncludeYear) {
          fields.add('questionItem.question.dateQuestion');
        }
        break;
      case QuestionType.time:
        if (timeDuration != other.timeDuration) {
          fields.add('questionItem.question.timeQuestion');
        }
        break;
      case QuestionType.image:
        if (mediaUrl != other.mediaUrl) {
          fields.add('imageItem');
        }
        break;
      case QuestionType.video:
        if (mediaUrl != other.mediaUrl) {
          fields.add('videoItem');
        }
        break;
      case QuestionType.info:
        // Info only has title and description, already covered above
        break;
      case QuestionType.section:
        // Section only has title and description, already covered above
        break;
    }

    // Check embedded image changes
    if (embeddedImageUrl != other.embeddedImageUrl) {
      if (type == QuestionType.multipleChoiceGrid ||
          type == QuestionType.checkboxGrid) {
        fields.add('questionGroupItem.image');
      } else if (type != QuestionType.image && type != QuestionType.video) {
        fields.add('questionItem.image');
      }
    }

    // If nothing specific changed but the item body is different, use wildcard
    if (fields.isEmpty && !equalsDeep(other)) {
      return '*';
    }

    return fields.isEmpty ? '' : fields.join(',');
  }

  /// Deep equality check for all fields
  bool equalsDeep(QuestionItem other) {
    return questionText == other.questionText &&
        type == other.type &&
        _listEquals(options, other.options) &&
        isRequired == other.isRequired &&
        mediaUrl == other.mediaUrl &&
        embeddedImageUrl == other.embeddedImageUrl &&
        scaleLow == other.scaleLow &&
        scaleHigh == other.scaleHigh &&
        scaleLowLabel == other.scaleLowLabel &&
        scaleHighLabel == other.scaleHighLabel &&
        _listEquals(gridRows, other.gridRows) &&
        _listEquals(gridColumns, other.gridColumns) &&
        dateIncludeYear == other.dateIncludeYear &&
        timeDuration == other.timeDuration &&
        isOther == other.isOther &&
        description == other.description &&
        showDescription == other.showDescription;
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  factory QuestionItem.fromApiJson(Map<String, dynamic> json) {
    final itemId = json['itemId'] as String? ?? '';
    final title = json['title'] as String? ?? '';
    final description = json['description'] as String? ?? '';

    // Check for videoItem
    if (json.containsKey('videoItem')) {
      final videoItem = json['videoItem'] as Map<String, dynamic>;
      final video = videoItem['video'] as Map<String, dynamic>?;
      final youtubeUri = video?['youtubeUri'] as String? ?? '';
      return QuestionItem(
        itemId: itemId,
        questionText: title,
        type: QuestionType.video,
        options: [],
        isRequired: false,
        mediaUrl: youtubeUri,
        description: description.isNotEmpty ? description : null,
        showDescription: description.isNotEmpty,
      );
    }

    // Check for imageItem (real Google Forms image with contentUri)
    if (json.containsKey('imageItem')) {
      final imageItem = json['imageItem'] as Map<String, dynamic>;
      final image = imageItem['image'] as Map<String, dynamic>?;
      final contentUri = image?['contentUri'] as String? ?? '';
      String? mediaUrl;
      if (contentUri.isNotEmpty) {
        mediaUrl = contentUri;
      } else if (description.startsWith('Image: ') && description.length > 7) {
        mediaUrl = description.substring(7);
      }
      return QuestionItem(
        itemId: itemId,
        questionText: title,
        type: QuestionType.image,
        options: [],
        isRequired: false,
        mediaUrl: mediaUrl,
      );
    }

    // Check for pageBreakItem — section break
    if (json.containsKey('pageBreakItem')) {
      return QuestionItem(
        itemId: itemId,
        questionText: title,
        type: QuestionType.section,
        options: [],
        isRequired: false,
        description: description.isNotEmpty ? description : null,
        showDescription: description.isNotEmpty,
      );
    }

    // Check for textItem — could be an image (legacy "Image: " prefix) or an info item
    if (json.containsKey('textItem') ||
        (description.startsWith('Image: ') && description.length > 7 && !json.containsKey('questionItem'))) {
      String? mediaUrl;
      bool isImage = false;
      if (description.startsWith('Image: ') && description.length > 7) {
        mediaUrl = description.substring(7);
        isImage = true;
      }
      return QuestionItem(
        itemId: itemId,
        questionText: title,
        type: isImage ? QuestionType.image : QuestionType.info,
        options: [],
        isRequired: false,
        mediaUrl: mediaUrl,
        description: isImage ? null : (description.isNotEmpty ? description : null),
        showDescription: !isImage && description.isNotEmpty,
      );
    }

    // Check for questionGroupItem (grid questions: multiple choice grid, checkbox grid)
    if (json.containsKey('questionGroupItem')) {
      final groupItem = json['questionGroupItem'] as Map<String, dynamic>;
      final grid = groupItem['grid'] as Map<String, dynamic>?;
      final questions = groupItem['questions'] as List<dynamic>? ?? [];

      if (grid != null) {
        // grid.columns is a single ChoiceQuestion object with type + options
        final columnsObj = grid['columns'] as Map<String, dynamic>? ?? {};
        final apiGridType = columnsObj['type'] as String? ?? 'RADIO';
        final type = apiGridType == 'CHECKBOX'
            ? QuestionType.checkboxGrid
            : QuestionType.multipleChoiceGrid;

        // Column values come from grid.columns.options[].value
        final colOpts = columnsObj['options'] as List<dynamic>? ?? [];
        final gridColumns = colOpts.map((c) => (c['value'] as String?) ?? '').toList();

        // Rows come from questions[].rowQuestion.title
        // Also extract questionIds for response matching
        final gridRows = <String>[];
        final gridRowQuestionIds = <String>[];
        for (final q in questions) {
          final rowQ = q['rowQuestion'] as Map<String, dynamic>?;
          gridRows.add(rowQ?['title'] as String? ?? '');
          // Each question in the group has a questionId
          gridRowQuestionIds.add(q['questionId'] as String? ?? '');
        }

        // Parse embedded image from questionGroupItem
        String? embeddedImageUrl;
        final groupImage = groupItem['image'] as Map<String, dynamic>?;
        if (groupImage != null) {
          embeddedImageUrl = groupImage['sourceUri'] as String? ?? groupImage['contentUri'] as String?;
        }

        return QuestionItem(
          itemId: itemId,
          questionText: title,
          type: type,
          options: [],
          isRequired: false,
          gridRows: gridRows.isNotEmpty ? gridRows : [''],
          gridColumns: gridColumns.isNotEmpty ? gridColumns : ['', ''],
          gridRowQuestionIds: gridRowQuestionIds,
          description: description.isNotEmpty ? description : null,
          showDescription: description.isNotEmpty,
          embeddedImageUrl: embeddedImageUrl,
        );
      }
    }

    final questionItem = json['questionItem'] as Map<String, dynamic>?;
    // Get the questionId from questionItem for answer matching
    final questionId = questionItem?['question']?['questionId'] as String? ?? '';
    // Use questionId for answer matching (API responses key answers by questionId, not itemId)
    final effectiveItemId = questionId.isNotEmpty ? questionId : itemId;
    final question = questionItem?['question'] as Map<String, dynamic>?;

    QuestionType type = QuestionType.multipleChoice;
    List<String> options = [];
    bool isRequired = question?['required'] as bool? ?? false;

    // Additional fields for new question types
    int scaleLow = 1;
    int scaleHigh = 5;
    String? scaleLowLabel;
    String? scaleHighLabel;
    List<String> gridRows = [''];
    List<String> gridColumns = ['', ''];
    bool dateIncludeYear = true;
    bool timeDuration = false;
    bool isOther = false;

    if (question?.containsKey('choiceQuestion') ?? false) {
      final choiceQ = question!['choiceQuestion'] as Map<String, dynamic>;
      final apiType = choiceQ['type'] as String? ?? 'RADIO';
      switch (apiType) {
        case 'RADIO':
          type = QuestionType.multipleChoice;
          break;
        case 'CHECKBOX':
          type = QuestionType.checkbox;
          break;
        case 'DROP_DOWN':
          type = QuestionType.dropdown;
          break;
      }
      final optsRaw = choiceQ['options'] as List<dynamic>? ?? [];
      final optionsList = optsRaw.cast<Map<String, dynamic>>().toList();
      // Only parse isOther for multiple choice and checkbox (not dropdown)
      if (type != QuestionType.dropdown) {
        isOther = optionsList.any((o) => o['isOther'] == true);
        if (isOther) {
          optionsList.removeWhere((o) => o['isOther'] == true);
        }
      }
      options = optionsList.map((o) => (o['value'] as String?) ?? '').toList();
    } else if (question?.containsKey('textQuestion') ?? false) {
      final textQ = question!['textQuestion'] as Map<String, dynamic>;
      final paragraph = textQ['paragraph'] as bool? ?? false;
      type = paragraph ? QuestionType.paragraph : QuestionType.shortAnswer;
    } else if (question?.containsKey('scaleQuestion') ?? false) {
      // Linear Scale
      type = QuestionType.linearScale;
      final scaleQ = question!['scaleQuestion'] as Map<String, dynamic>;
      scaleLow = scaleQ['low'] as int? ?? 1;
      scaleHigh = scaleQ['high'] as int? ?? 5;
      scaleLowLabel = scaleQ['lowLabel'] as String?;
      scaleHighLabel = scaleQ['highLabel'] as String?;
      options = [];
    } else if (question?.containsKey('gridQuestion') ?? false) {
      // Grid question
      final gridQ = question!['gridQuestion'] as Map<String, dynamic>;
      final apiGridType = gridQ['type'] as String? ?? 'RADIO';
      type = apiGridType == 'CHECKBOX'
          ? QuestionType.checkboxGrid
          : QuestionType.multipleChoiceGrid;
      final rows = gridQ['rows'] as List<dynamic>? ?? [];
      final cols = gridQ['columns'] as List<dynamic>? ?? [];
      gridRows = rows.map((r) => (r['value'] as String?) ?? '').toList();
      gridColumns = cols.map((c) => (c['value'] as String?) ?? '').toList();
      options = [];
    } else if (question?.containsKey('dateQuestion') ?? false) {
      // Date question
      type = QuestionType.date;
      final dateQ = question!['dateQuestion'] as Map<String, dynamic>;
      dateIncludeYear = dateQ['includeYear'] as bool? ?? true;
      options = [];
    } else if (question?.containsKey('timeQuestion') ?? false) {
      // Time question
      type = QuestionType.time;
      final timeQ = question!['timeQuestion'] as Map<String, dynamic>;
      timeDuration = timeQ['duration'] as bool? ?? false;
      options = [];
    }

    // Parse embedded image from questionItem
    String? embeddedImageUrl;
    final qImage = questionItem?['image'] as Map<String, dynamic>?;
    if (qImage != null) {
      embeddedImageUrl = qImage['sourceUri'] as String? ?? qImage['contentUri'] as String?;
    }

    return QuestionItem(
      itemId: effectiveItemId,
      questionText: title,
      type: type,
      options: options.isNotEmpty ? options : [''],
      isRequired: isRequired,
      scaleLow: scaleLow,
      scaleHigh: scaleHigh,
      scaleLowLabel: scaleLowLabel,
      scaleHighLabel: scaleHighLabel,
      gridRows: gridRows.isNotEmpty ? gridRows : [''],
      gridColumns: gridColumns.isNotEmpty ? gridColumns : ['', ''],
      dateIncludeYear: dateIncludeYear,
      timeDuration: timeDuration,
      isOther: isOther,
      description: description.isNotEmpty ? description : null,
      showDescription: description.isNotEmpty,
      embeddedImageUrl: embeddedImageUrl,
    );
  }

  QuestionItem copyWith({
    String? itemId,
    String? questionText,
    QuestionType? type,
    List<String>? options,
    bool? isRequired,
    String? mediaUrl,
    String? embeddedImageUrl,
    int? scaleLow,
    int? scaleHigh,
    String? scaleLowLabel,
    String? scaleHighLabel,
    List<String>? gridRows,
    List<String>? gridColumns,
    bool? dateIncludeYear,
    bool? dateIncludeTime,
    bool? timeDuration,
    bool? isOther,
    String? description,
    bool? showDescription,
  }) {
    return QuestionItem(
      itemId: itemId ?? this.itemId,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      options: options ?? List<String>.from(this.options),
      isRequired: isRequired ?? this.isRequired,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      embeddedImageUrl: embeddedImageUrl ?? this.embeddedImageUrl,
      scaleLow: scaleLow ?? this.scaleLow,
      scaleHigh: scaleHigh ?? this.scaleHigh,
      scaleLowLabel: scaleLowLabel ?? this.scaleLowLabel,
      scaleHighLabel: scaleHighLabel ?? this.scaleHighLabel,
      gridRows: gridRows ?? List<String>.from(this.gridRows),
      gridColumns: gridColumns ?? List<String>.from(this.gridColumns),
      dateIncludeYear: dateIncludeYear ?? this.dateIncludeYear,
      dateIncludeTime: dateIncludeTime ?? this.dateIncludeTime,
      isOther: isOther ?? this.isOther,
      timeDuration: timeDuration ?? this.timeDuration,
      description: description ?? this.description,
      showDescription: showDescription ?? this.showDescription,
    );
  }
}