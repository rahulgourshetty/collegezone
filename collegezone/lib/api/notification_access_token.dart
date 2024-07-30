import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async => _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final client = await clientViaServiceAccount(
        // To get Admin Json File: Go to Firebase > Project Settings > Service Accounts
        // > Click on 'Generate new private key' Btn & Json file will be downloaded

        // Paste Your Generated Json File Content
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "miniproject-a3032",
          "private_key_id": "05a3d53f9aaa53729d325d02912f915c3dcbba17",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCxtDFbBM41sXB5\n4fU1WgimCrLLpqEVwHH8sdtaUnoLdKVe5S2lFkXGmvr5AF72zqTiFHO7lSN8kpMu\ngwTClwnn5JGs6D2qAEM2BEsp8wudVM1mjRmIwHJUkUN2+xEqlPza9gZWpcsgWXqk\nid+Iy/1RFoaeuWcwkMBJUkfmx5KWVBBFUQxmgCj+/ThvjhFoIGhisOcRTy3TMYVz\nOcz8IVZX+oXbAmi9Qv3TAEuh543m9L7gN7tG0NAG8JpT8SuPd5f10Hwh8jHmI51M\nBwcIvznsoWnYXcjIODdXKn+PhxVdq49UVQY8Rez/B07/n4xtKldUpaMaqeK7p4+l\ngsDOgXg9AgMBAAECggEABFAJtJpIwN/WCXc04r8VH6Z50VxxY1xAx++vEaGXyahi\njQuF0JBaUCgZuCpMo7O/J6d0aZSEgHT0MnhGiMxulpyi9m3KdVI9T1XKVzHJUd+p\nfnglKv70p13BI+WS9JQaENxQqhCq/dV+Fvkrnh/JPYsM6FQ6j2Cr8fuXuB+WzKQi\nQV6HAxste00EaBDrWSB7CQCINgMilNXO/hcfYUoDWVitKKm3Yy54KA22jLucMTrc\nWqxwQFB1MfrQsYJDPFky2MOlF/wZD/QhY35X19e2ud1pG2iXRAAP50rut2aO5bAy\nozqsIq3HBb0975yWmB3FvwC9+kZ+jpE+DfYRyUbo1wKBgQDluL+FLBmSw19vBbui\nqcaMPFyP/6R/Sh2fyYNsId0Fwx2VM/OoPLh94bi/OXLRikFDD0lki98q9rEn1GtE\nEIDuZ0l50OLwQtKPEhsD12DOBi9PVogAMm1cQ1Dpf5iYetEKdkQikR4BlP34MY+/\nbXPFwHZbtLH2A/THXOiJDREEtwKBgQDGCCMNHysuGRdvljF9n+CiXpKYfYgkR4GJ\nITQW6F4gPKe+TJ7hMUsb/D7XGaR4oCIL8kg+oG7d5BBXAMcNTXrvvUlOL7X/t+NP\nJuRQGYnJuYRgZBtea5G7ZIPgNY0PzIvCXUBknjaIvuXmj9k0I3d/Bk3dFZNauIkT\nQZS0mfk+qwKBgFg+ctueSCiXglZsllpy60E9grUSF8eJ2f1idGiaTYQEIp4I+eU7\nhgddKRHT6KZTfKRc/+1uyYiAgSbys03PJSfvZ0szEaoHkUjCRLxiBN6/g3bvn4ir\n1lSlyzQW/rA8JYbmTWAV7Lfg2vp3V2fKjLl/KDgsHlyJwoK+ztiuu0XbAoGAUBbw\nXhkx9HXPZaC/qUfkqKZI8YUrb0jAGb6k+3LExpLhYHRKeVbfQpU0sPe87dANlPlK\nwJFP5UucVCOLXVTtmFHceNOQ7rfnJZbcFY0OjdgKspUqAHjOupP/RclCoJYgG95s\n8YSPF6TlA+c/d/e0F1psWTKlorYpMfF++7+d7vsCgYEA1OP8QxFs3Qe4cPcbHXNG\noCGoyCtzwrTuP56ciJhAVA8QTJRlX8AhlmN7Pqh7t8M4ZiJaldSCfCE6bNWHfIOz\nUpu8b+P9ILWU+T1kgVkZCNVHLAA/EGVLt9aYkaGQfnZA77/huzJebdFWqOf7TqIw\n0wASRVqsA+vLO7a73r6XMLA=\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-z7lek@miniproject-a3032.iam.gserviceaccount.com",
          "client_id": "101525319390307776594",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-z7lek%40miniproject-a3032.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
