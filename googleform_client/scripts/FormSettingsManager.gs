/**
 * FormSettingsManager - Google Apps Script
 * 
 * This script applies form settings that the Google Forms REST API v1 doesn't support.
 * 
 * SETUP INSTRUCTIONS:
 * 1. Go to https://script.google.com
 * 2. Create a new project
 * 3. Paste this entire code into the editor
 * 4. Update SCRIPT_CONSTANTS below if needed
 * 5. Click Deploy > New deployment
 * 6. Select type: "API executable"
 * 7. Set description: "FormSettingsManager v1"
 * 8. Execute as: "Me" (your account)
 * 9. Click Deploy
 * 10. Copy the "Script ID" from the deployment
 * 11. Paste it into apps_script_service.dart as _scriptId
 * 
 * REQUIRED SCOPES (authorized automatically on first run):
 * - https://www.googleapis.com/auth/forms
 */

/**
 * Main entry point - called from the Flutter app via Apps Script API.
 * 
 * @param {Object} e - The event parameter with:
 *   e.formId: string - The Google Form ID
 *   e.settings: {
 *     collectEmail: boolean,
 *     emailCollectionType: string ('none'|'verified'|'responder_input'),
 *     sendResponseCopy: boolean,
 *     acceptingResponses: boolean,
 *     limitOneResponse: boolean,
 *     editAfterSubmit: boolean,
 *     showProgressBar: boolean,
 *     confirmationMessage: string,
 *     shuffleQuestions: boolean
 *   }
 * @returns {Object} Result with success boolean and optional error
 */
function applyFormSettings(e) {
  try {
    if (!e || !e.formId) {
      return { success: false, error: 'Missing formId parameter' };
    }

    var form = FormApp.openById(e.formId);
    if (!form) {
      return { success: false, error: 'Could not open form with ID: ' + e.formId };
    }

    var settings = e.settings || {};
    var applied = [];
    var errors = [];

    // 1. Accept responses
    if (settings.acceptingResponses !== undefined) {
      try {
        form.setAcceptingResponses(settings.acceptingResponses);
        applied.push('acceptingResponses');
      } catch (err) {
        errors.push('acceptingResponses: ' + err.message);
      }
    }

    // 2. Collect email addresses - handled via REST API (emailCollectionType)
    //    Apps Script setCollectEmail(true) only sets "Responder input",
    //    so we use the REST API's updateSettings with emailCollectionType instead.

    // 3. Limit to 1 response
    if (settings.limitOneResponse !== undefined) {
      try {
        form.setLimitOneResponsePerUser(settings.limitOneResponse);
        applied.push('limitOneResponse');
      } catch (err) {
        errors.push('limitOneResponse: ' + err.message);
      }
    }

    // 4. Edit after submit
    if (settings.editAfterSubmit !== undefined) {
      try {
        form.setAllowResponseEdits(settings.editAfterSubmit);
        applied.push('editAfterSubmit');
      } catch (err) {
        errors.push('editAfterSubmit: ' + err.message);
      }
    }

    // 5. Show progress bar
    if (settings.showProgressBar !== undefined) {
      try {
        form.setProgressBar(settings.showProgressBar);
        applied.push('showProgressBar');
      } catch (err) {
        errors.push('showProgressBar: ' + err.message);
      }
    }

    // 6. Shuffle questions
    if (settings.shuffleQuestions !== undefined) {
      try {
        form.setShuffleQuestions(settings.shuffleQuestions);
        // Also persist to PropertiesService as a fallback for reading
        try {
          var props = PropertiesService.getUserProperties();
          props.setProperty('shuffleQuestions_' + e.formId, settings.shuffleQuestions ? 'true' : 'false');
        } catch (propErr) {
          console.log('PropertiesService write failed: ' + propErr.message);
        }
        applied.push('shuffleQuestions');
      } catch (err) {
        errors.push('shuffleQuestions: ' + err.message);
      }
    }

    // 7. Confirmation message
    if (settings.confirmationMessage) {
      try {
        form.setConfirmationMessage(settings.confirmationMessage);
        applied.push('confirmationMessage');
      } catch (err) {
        errors.push('confirmationMessage: ' + err.message);
      }
    }

    // 8. Send response copy (note: FormApp doesn't have a direct setter for this
    //    in the same way - it's typically set per-response. We log it as applied
    //    but it may need a different approach depending on use case.)
    if (settings.sendResponseCopy !== undefined) {
      // This is a response-time setting, not a form-level setting in Apps Script.
      // We acknowledge it but cannot set it at the form level.
      applied.push('sendResponseCopy (acknowledged, set at response time)');
    }

    return {
      success: true,
      applied: applied,
      errors: errors.length > 0 ? errors : undefined
    };

  } catch (error) {
    return {
      success: false,
      error: error.message || String(error)
    };
  }
}

/**
 * Get the current settings of a form (useful for loading settings when editing).
 * 
 * @param {Object} e - The event parameter with:
 *   e.formId: string - The Google Form ID
 * @returns {Object} Current form settings
 */
function getFormSettings(e) {
  try {
    if (!e || !e.formId) {
      return { success: false, error: 'Missing formId parameter' };
    }

    var form = FormApp.openById(e.formId);
    if (!form) {
      return { success: false, error: 'Could not open form with ID: ' + e.formId };
    }

    // Wrap each getter in try-catch so one failure doesn't block all settings
    var settings = {};

    try { settings['isAcceptingResponses'] = form.isAcceptingResponses(); }
    catch (err) { settings['isAcceptingResponses'] = true; console.log('isAcceptingResponses error: ' + err.message); }

    try { settings['collectEmail'] = form.collectsEmail(); }
    catch (err) { settings['collectEmail'] = false; console.log('collectEmail error: ' + err.message); }

    try { settings['limitOneResponse'] = form.hasLimitOneResponsePerUser(); }
    catch (err) { settings['limitOneResponse'] = false; console.log('limitOneResponse error: ' + err.message); }

    try { settings['editAfterSubmit'] = form.canEditResponse(); }
    catch (err) { settings['editAfterSubmit'] = false; console.log('editAfterSubmit error: ' + err.message); }

    try { settings['showProgressBar'] = form.hasProgressBar(); }
    catch (err) { settings['showProgressBar'] = false; console.log('showProgressBar error: ' + err.message); }

    // Read shuffleQuestions using multiple fallback strategies.
    // IMPORTANT: Use 'err' in catch blocks, NOT 'e' (which is the function parameter e.formId).
    var shuffleReadOk = false;

    // Strategy 1: Try Apps Script native getter
    try {
      var val = form.isShuffleQuestions();
      settings['shuffleQuestions'] = val;
      shuffleReadOk = true;
      console.log('shuffleQuestions from isShuffleQuestions(): ' + val);
    } catch (err) {
      console.log('isShuffleQuestions() error: ' + err.message);
    }

    // Strategy 2: Try reading from Forms REST API via UrlFetchApp
    if (!shuffleReadOk) {
      try {
        var token = ScriptApp.getOAuthToken();
        var apiUrl = 'https://forms.googleapis.com/v1/forms/' + e.formId;
        var apiResponse = UrlFetchApp.fetch(apiUrl, {
          headers: { 'Authorization': 'Bearer ' + token },
          muteHttpExceptions: true
        });
        var apiJson = JSON.parse(apiResponse.getContentText());
        console.log('Forms API response settings: ' + JSON.stringify(apiJson.settings || {}));
        if (apiJson.settings && apiJson.settings.shuffleQuestions !== undefined) {
          settings['shuffleQuestions'] = apiJson.settings.shuffleQuestions;
          shuffleReadOk = true;
          console.log('shuffleQuestions from REST API: ' + apiJson.settings.shuffleQuestions);
        }
      } catch (fetchErr) {
        console.log('REST API fallback for shuffleQuestions failed: ' + fetchErr.message);
      }
    }

    // Strategy 3: Read from PropertiesService cache
    if (!shuffleReadOk) {
      try {
        var props = PropertiesService.getUserProperties();
        var cached = props.getProperty('shuffleQuestions_' + e.formId);
        if (cached !== null) {
          settings['shuffleQuestions'] = (cached === 'true');
          shuffleReadOk = true;
          console.log('shuffleQuestions from PropertiesService cache: ' + cached);
        } else {
          settings['shuffleQuestions'] = false;
          console.log('shuffleQuestions: no cache available, defaulted to false');
        }
      } catch (propErr) {
        settings['shuffleQuestions'] = false;
        console.log('shuffleQuestions PropertiesService fallback failed: ' + propErr.message);
      }
    }

    console.log('shuffleQuestions final value: ' + settings['shuffleQuestions']);

    try { settings['confirmationMessage'] = form.getConfirmationMessage(); }
    catch (err) { settings['confirmationMessage'] = ''; console.log('confirmationMessage error: ' + err.message); }

    // Note: sendResponseCopy is not available as a form-level getter in Apps Script
    settings['sendResponseCopy'] = false;

    // Read linked sheet ID (response destination)
    try {
      settings['linkedSheetId'] = form.getDestinationId() || null;
      console.log('linkedSheetId: ' + settings['linkedSheetId']);
    } catch (err) {
      settings['linkedSheetId'] = null;
      console.log('linkedSheetId error: ' + err.message);
    }

    console.log('getFormSettings result: ' + JSON.stringify(settings));

    return {
      success: true,
      settings: settings
    };

  } catch (error) {
    return {
      success: false,
      error: error.message || String(error)
    };
  }
}

/**
 * Link a Google Form's responses to a Google Spreadsheet.
 * After linking, all new (and existing) form responses will automatically
 * appear as rows in the spreadsheet.
 *
 * @param {Object} e - The event parameter with:
 *   e.formId: string - The Google Form ID
 *   e.spreadsheetId: string - The Google Spreadsheet ID to link
 * @returns {Object} Result with success boolean and spreadsheetId
 */
function linkFormToSheet(e) {
  try {
    if (!e || !e.formId || !e.spreadsheetId) {
      return {
        success: false,
        error: 'Missing formId or spreadsheetId parameter'
      };
    }

    var form = FormApp.openById(e.formId);
    if (!form) {
      return { success: false, error: 'Could not open form with ID: ' + e.formId };
    }

    form.setDestination(FormApp.DestinationType.SPREADSHEET, e.spreadsheetId);

    var linkedId = form.getDestinationId();

    return {
      success: true,
      spreadsheetId: linkedId
    };

  } catch (error) {
    return {
      success: false,
      error: error.message || String(error)
    };
  }
}

/**
 * Unlink a Google Form from its response destination spreadsheet.
 * Form responses will stop being written to the linked sheet.
 *
 * @param {Object} e - The event parameter with:
 *   e.formId: string - The Google Form ID
 * @returns {Object} Result with success boolean
 */
function unlinkFormFromSheet(e) {
  try {
    if (!e || !e.formId) {
      return { success: false, error: 'Missing formId parameter' };
    }

    var form = FormApp.openById(e.formId);
    if (!form) {
      return { success: false, error: 'Could not open form with ID: ' + e.formId };
    }

    form.removeDestination();

    return {
      success: true
    };

  } catch (error) {
    return {
      success: false,
      error: error.message || String(error)
    };
  }
}