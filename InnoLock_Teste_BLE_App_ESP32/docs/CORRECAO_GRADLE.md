# Correção do erro dependencyResolutionManagement()

Erro original:

```text
Could not find method dependencyResolutionManagement() ... on settings 'android-app'
```

Causa:

O projeto anterior estava no padrão novo do Gradle/Android Gradle Plugin. Em ambientes com Gradle mais antigo, o método `dependencyResolutionManagement()` não existe e o Android Studio interrompe a abertura/sincronização do projeto.

Correção aplicada nesta versão:

- `settings.gradle` foi convertido para formato compatível.
- `build.gradle` raiz passou a usar `buildscript {}` e `allprojects {}`.
- `app/build.gradle` passou a usar `apply plugin: 'com.android.application'`.
- Removido `namespace`, que é exigência de versões novas do Android Gradle Plugin, mas quebra em versões antigas.
- Adicionado `package="br.com.innobrax.innolockteste"` no `AndroidManifest.xml`.
- Ajustado para `compileSdkVersion 33` e `targetSdkVersion 33`, suficiente para permissões BLE do Android 12+.

Abra a pasta `android-app` no Android Studio e execute:

```text
Build > Build Bundle(s) / APK(s) > Build APK(s)
```

Se o Android Studio solicitar instalação do Android SDK 33, aceite a instalação.
