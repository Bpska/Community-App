import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static ApiService? _instance;
  late Dio _dio;
  final StorageService _storageService;

  ApiService._(this._storageService) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to headers
        final token = _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        // Handle errors globally
        print('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  static Future<ApiService> getInstance() async {
    if (_instance == null) {
      final storageService = await StorageService.getInstance();
      _instance = ApiService._(storageService);
    }
    return _instance!;
  }

  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Upload file
  Future<Response> uploadFile(String path, String filePath, String fieldName) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(path, data: formData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Upload multiple files
  Future<Response> uploadFiles(String path, Map<String, String> files) async {
    try {
      Map<String, dynamic> formDataMap = {};
      for (var entry in files.entries) {
        formDataMap[entry.key] = await MultipartFile.fromFile(entry.value);
      }
      FormData formData = FormData.fromMap(formDataMap);
      final response = await _dio.post(path, data: formData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST multipart with both text fields and files
  Future<Response> postMultipart(
    String path, {
    Map<String, dynamic>? fields,
    Map<String, String>? files,
  }) async {
    try {
      Map<String, dynamic> formDataMap = {};
      
      // Add text fields
      if (fields != null) {
        formDataMap.addAll(fields);
      }
      
      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          formDataMap[entry.key] = await MultipartFile.fromFile(entry.value);
        }
      }
      
      FormData formData = FormData.fromMap(formDataMap);
      final response = await _dio.post(path, data: formData);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
