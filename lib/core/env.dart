class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
   // defaultValue: 'http://10.0.2.2:8080',

   defaultValue: 'http://localhost:8080',
     // defaultValue: 'http://127.0.0.1:8080',
      // defaultValue:  'http://172.28.19.209:8080'
     // defaultValue:  'http://192.168.1.81:8080'
  );
}

