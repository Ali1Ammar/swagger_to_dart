import 'package:swagger_to_dart/src/utils/filter_content.dart';
import 'package:test/test.dart';

void main() {
  group('removeUnSupportedContent', () {
    test('filters unsupported content types from paths', () {
      final input = {
        'paths': {
          '/test': {
            'post': {
              'requestBody': {
                'content': {
                  'application/json': {
                    'schema': {'type': 'object'}
                  },
                  'application/xml': {
                    'schema': {'type': 'object'}
                  },
                  'unsupported/type': {
                    'schema': {'type': 'object'}
                  }
                }
              },
              'responses': {
                '200': {
                  'content': {
                    'application/json': {
                      'schema': {'type': 'object'}
                    },
                    'application/xml': {
                      'schema': {'type': 'object'}
                    }
                  }
                }
              }
            }
          }
        }
      };

      final result = removeUnSupportedContent(input);

      // Check that supported content types are preserved
      final requestContent = result['paths']['/test']['post']['requestBody']['content'];
      expect(requestContent.containsKey('application/json'), isTrue);
      
      // Check that unsupported content types are removed
      expect(requestContent.containsKey('application/xml'), isFalse);
      expect(requestContent.containsKey('unsupported/type'), isFalse);

      // Check responses
      final responseContent = result['paths']['/test']['post']['responses']['200']['content'];
      expect(responseContent.containsKey('application/json'), isTrue);
      expect(responseContent.containsKey('application/xml'), isFalse);
    });

    test('filters unsupported content types from components', () {
      final input = {
        'components': {
          'requestBodies': {
            'TestBody': {
              'content': {
                'application/json': {
                  'schema': {'type': 'object'}
                },
                'application/xml': {
                  'schema': {'type': 'object'}
                }
              }
            }
          },
          'responses': {
            'TestResponse': {
              'content': {
                'application/json': {
                  'schema': {'type': 'object'}
                },
                'text/xml': {
                  'schema': {'type': 'object'}
                }
              }
            }
          }
        }
      };

      final result = removeUnSupportedContent(input);

      // Check request bodies
      final requestBodyContent = result['components']['requestBodies']['TestBody']['content'];
      expect(requestBodyContent.containsKey('application/json'), isTrue);
      expect(requestBodyContent.containsKey('application/xml'), isFalse);

      // Check responses
      final responseContent = result['components']['responses']['TestResponse']['content'];
      expect(responseContent.containsKey('application/json'), isTrue);
      expect(responseContent.containsKey('text/xml'), isFalse);
    });

    test('preserves data when no unsupported content types are present', () {
      final input = {
        'paths': {
          '/test': {
            'get': {
              'responses': {
                '200': {
                  'content': {
                    'application/json': {
                      'schema': {'type': 'object'}
                    }
                  }
                }
              }
            }
          }
        }
      };

      final result = removeUnSupportedContent(input);

      expect(result, equals(input));
    });

    test('handles empty or missing content gracefully', () {
      final input = {
        'paths': {
          '/test': {
            'get': {
              'responses': {
                '204': {
                  'description': 'No content'
                }
              }
            }
          }
        }
      };

      final result = removeUnSupportedContent(input);

      expect(result, equals(input));
    });
  });
}