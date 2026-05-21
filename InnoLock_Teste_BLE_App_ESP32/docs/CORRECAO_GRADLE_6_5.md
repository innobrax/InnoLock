# Correção para erro de Gradle 6.5

Erro observado:

```text
Minimum supported Gradle version is 6.7.1. Current version is 6.5.
```

Causa:

- O projeto anterior usava Android Gradle Plugin 4.2.2.
- O Android Gradle Plugin 4.2.2 exige Gradle 6.7.1 ou superior.
- O ambiente local está usando Gradle 6.5.

Correção aplicada nesta versão:

- `android-app/build.gradle` alterado para `com.android.tools.build:gradle:4.1.3`.
- `settings.gradle` simplificado para formato legado.
- `gradle.properties` simplificado.
- Adicionado `gradle/wrapper/gradle-wrapper.properties` apontando para Gradle 6.5.

Se o Android Studio solicitar SDK 33, aceite a instalação. O app precisa compilar com SDK 33 por causa das permissões BLE do Android 12/13.
