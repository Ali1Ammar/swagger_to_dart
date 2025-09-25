/// Removes unsupported content types from OpenAPI JSON data to prevent parsing errors.
/// This function filters out content types that are not defined in the OpenApiContentType enum
/// before the data is parsed into OpenAPI classes.
///
/// [data] - The JSON map data to filter
/// Returns the filtered map with only supported content types
Map<String, dynamic> removeUnSupportedContent(Map<String, dynamic> data) {
  // Define the supported content types based on OpenApiContentType enum
  const supportedContentTypes = {
    'application/json',
    'application/x-www-form-urlencoded',
    'multipart/form-data',
    'text/plain',
    'text/json',
    'application/json-patch+json',
    'application/*+json',
  };

  // Create a deep copy of the data to avoid modifying the original
  final filteredData = Map<String, dynamic>.from(data);

  // Recursively filter content in paths
  if (filteredData.containsKey('paths')) {
    final paths = filteredData['paths'] as Map<String, dynamic>?;
    if (paths != null) {
      filteredData['paths'] = _filterPathsContent(paths, supportedContentTypes);
    }
  }

  // Filter content in components if present
  if (filteredData.containsKey('components')) {
    final components = filteredData['components'] as Map<String, dynamic>?;
    if (components != null) {
      filteredData['components'] = _filterComponentsContent(components, supportedContentTypes);
    }
  }

  return filteredData;
}

/// Filters content types in the paths section
Map<String, dynamic> _filterPathsContent(
  Map<String, dynamic> paths,
  Set<String> supportedContentTypes,
) {
  final filteredPaths = <String, dynamic>{};

  for (final pathEntry in paths.entries) {
    final pathKey = pathEntry.key;
    final pathValue = pathEntry.value as Map<String, dynamic>?;

    if (pathValue != null) {
      final filteredPathValue = <String, dynamic>{};

      for (final methodEntry in pathValue.entries) {
        final methodKey = methodEntry.key;
        final methodValue = methodEntry.value as Map<String, dynamic>?;

        if (methodValue != null) {
          final filteredMethodValue = Map<String, dynamic>.from(methodValue);

          // Filter request body content
          if (filteredMethodValue.containsKey('requestBody')) {
            final requestBody = filteredMethodValue['requestBody'] as Map<String, dynamic>?;
            if (requestBody != null) {
              filteredMethodValue['requestBody'] = _filterRequestBodyContent(requestBody, supportedContentTypes);
            }
          }

          // Filter response content
          if (filteredMethodValue.containsKey('responses')) {
            final responses = filteredMethodValue['responses'] as Map<String, dynamic>?;
            if (responses != null) {
              filteredMethodValue['responses'] = _filterResponsesContent(responses, supportedContentTypes);
            }
          }

          filteredPathValue[methodKey] = filteredMethodValue;
        }
      }

      filteredPaths[pathKey] = filteredPathValue;
    }
  }

  return filteredPaths;
}

/// Filters content types in request body
Map<String, dynamic> _filterRequestBodyContent(
  Map<String, dynamic> requestBody,
  Set<String> supportedContentTypes,
) {
  final filteredRequestBody = Map<String, dynamic>.from(requestBody);

  if (filteredRequestBody.containsKey('content')) {
    final content = filteredRequestBody['content'] as Map<String, dynamic>?;
    if (content != null) {
      filteredRequestBody['content'] = _filterContentMap(content, supportedContentTypes);
    }
  }

  return filteredRequestBody;
}

/// Filters content types in responses
Map<String, dynamic> _filterResponsesContent(
  Map<String, dynamic> responses,
  Set<String> supportedContentTypes,
) {
  final filteredResponses = <String, dynamic>{};

  for (final responseEntry in responses.entries) {
    final responseKey = responseEntry.key;
    final responseValue = responseEntry.value as Map<String, dynamic>?;

    if (responseValue != null) {
      final filteredResponseValue = Map<String, dynamic>.from(responseValue);

      if (filteredResponseValue.containsKey('content')) {
        final content = filteredResponseValue['content'] as Map<String, dynamic>?;
        if (content != null) {
          filteredResponseValue['content'] = _filterContentMap(content, supportedContentTypes);
        }
      }

      filteredResponses[responseKey] = filteredResponseValue;
    }
  }

  return filteredResponses;
}

/// Filters content types in components section
Map<String, dynamic> _filterComponentsContent(
  Map<String, dynamic> components,
  Set<String> supportedContentTypes,
) {
  final filteredComponents = Map<String, dynamic>.from(components);

  // Filter content in requestBodies if present
  if (filteredComponents.containsKey('requestBodies')) {
    final requestBodies = filteredComponents['requestBodies'] as Map<String, dynamic>?;
    if (requestBodies != null) {
      final filteredRequestBodies = <String, dynamic>{};
      for (final entry in requestBodies.entries) {
        final requestBody = entry.value as Map<String, dynamic>?;
        if (requestBody != null) {
          filteredRequestBodies[entry.key] = _filterRequestBodyContent(requestBody, supportedContentTypes);
        }
      }
      filteredComponents['requestBodies'] = filteredRequestBodies;
    }
  }

  // Filter content in responses if present
  if (filteredComponents.containsKey('responses')) {
    final responses = filteredComponents['responses'] as Map<String, dynamic>?;
    if (responses != null) {
      final filteredResponses = <String, dynamic>{};
      for (final entry in responses.entries) {
        final response = entry.value as Map<String, dynamic>?;
        if (response != null) {
          final filteredResponse = Map<String, dynamic>.from(response);
          if (filteredResponse.containsKey('content')) {
            final content = filteredResponse['content'] as Map<String, dynamic>?;
            if (content != null) {
              filteredResponse['content'] = _filterContentMap(content, supportedContentTypes);
            }
          }
          filteredResponses[entry.key] = filteredResponse;
        }
      }
      filteredComponents['responses'] = filteredResponses;
    }
  }

  return filteredComponents;
}

/// Filters a content map to only include supported content types
Map<String, dynamic> _filterContentMap(
  Map<String, dynamic> content,
  Set<String> supportedContentTypes,
) {
  final filteredContent = <String, dynamic>{};

  for (final contentEntry in content.entries) {
    final contentType = contentEntry.key;
    if (supportedContentTypes.contains(contentType)) {
      filteredContent[contentType] = contentEntry.value;
    }
    // Silently skip unsupported content types to prevent errors
  }

  return filteredContent;
}