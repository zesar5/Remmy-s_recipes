// ==========================================================================
//                      API_SERVICE - DEPRECATED / NO ACTIVO
// ==========================================================================
// 
// ESTADO: Este archivo NO se utiliza actualmente.
// 
// El proyecto usa HTTP (package:http) en lugar de Dio para todas las llamadas API.
// Ver recetas_service.dart y auth_service.dart para la implementación actual.
// 
// Si en el futuro se decide migrar a Dio:
// 1. Descomentar este archivo
// 2. Consolidar toda la lógica de recetas_service y auth_service aquí
// 3. Reemplazar todas las llamadas http.get/post con _dio.get/post
// 4. Eliminar duplicidad de clientes HTTP
// 
// DEPENDENCIAS REQUERIDAS si se activa:
// - dio: ^5.0.0 o superior
// - dio_logging_interceptor (opcional, para debug)
// 
/*import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import '../core/config/api_config.dart';
import '../core/config/env_config.dart';
import '../../core/logger/logger.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: int.parse(ApiConfig.timeout)),
        receiveTimeout: Duration(seconds: int.parse(ApiConfig.timeout)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status! < 500,
        // Asegurarse de que espera JSON
        responseType: ResponseType.json,
      ),
    );

    // Desactivar validación SSL en desarrollo
    if (Environment.isDevelopment && Environment.allowBadCertificates) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          AppLogger.warning(
            '⚠️ SSL certificate ignored for $host:$port (dev only)',
          );
          return true;
        };
        return client;
      };
    }

    // Interceptor para logging detallado
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final fullUrl = '${options.baseUrl}${options.path}';
          AppLogger.info('📤 REQUEST', {
            'method': options.method,
            'url': fullUrl,
            'headers': options.headers,
            'data': options.data,
          });
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info('📥 RESPONSE', {
            'url':
                '${response.requestOptions.baseUrl}${response.requestOptions.path}',
            'statusCode': response.statusCode,
            'dataType': response.data.runtimeType.toString(),
            'data': response.data,
          });
          return handler.next(response);
        },
        onError: (error, handler) {
          final fullUrl =
              '${error.requestOptions.baseUrl}${error.requestOptions.path}';
          AppLogger.error('❌ DIO ERROR', {
            'url': fullUrl,
            'type': error.type.name,
            'message': error.message,
            'statusCode': error.response?.statusCode,
            'responseData': error.response?.data,
            'responseType': error.response?.data.runtimeType.toString(),
          });
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> request(
    String path,
    String method, {
    Map<String, dynamic>? data,
    String? token,
  }) async {
    try {
      Options options = Options(
        method: method,
        responseType: ResponseType.json, // Forzar JSON
      );

      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }

      final response = await _dio.request(path, data: data, options: options);

      // Validar que la respuesta sea exitosa
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // Validar que response.data sea Map
        if (response.data is! Map<String, dynamic> &&
            response.data is! List<dynamic>) {
          AppLogger.error('Invalid response type', {
            'expected': 'Map<String, dynamic>',
            'received': response.data.runtimeType.toString(),
            'data': response.data,
          });
          throw Exception('Respuesta inválida del servidor');
        }
        return response;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.error('DioException capturada', e);

      // Mensajes específicos según el tipo de error
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          '⏱️ Tiempo de conexión agotado. Verifica que el servidor esté corriendo.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          '🔌 Error de conexión. Verifica:\n- El servidor está corriendo en https://localhost:3000\n- El certificado SSL está configurado\n- No hay firewall bloqueando',
        );
      } else if (e.type == DioExceptionType.badCertificate) {
        throw Exception(
          '🔒 Error de certificado SSL. Verifica la configuración de HTTPS.',
        );
      } else if (e.response != null) {
        // El servidor respondió con un error
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        AppLogger.error('Error del servidor', {
          'statusCode': statusCode,
          'errorData': errorData,
          'errorDataType': errorData.runtimeType.toString(),
        });

        if (errorData is Map && errorData.containsKey('error')) {
          throw Exception(errorData['error']);
        } else if (errorData is String) {
          throw Exception('Error del servidor: $errorData');
        } else {
          throw Exception('Error del servidor (${statusCode})');
        }
      }

      // Error desconocido
      throw Exception('Error de red: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('Error inesperado en request', e);
      AppLogger.error('StackTrace', stackTrace);
      rethrow;
    }
  }
}*/
