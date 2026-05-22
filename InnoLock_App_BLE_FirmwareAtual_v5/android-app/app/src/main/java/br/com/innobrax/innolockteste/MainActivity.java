package br.com.innobrax.innolockteste;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanRecord;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.method.ScrollingMovementMethod;
import android.view.Gravity;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ScrollView;
import android.widget.TextView;

import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

public class MainActivity extends Activity {
    // Nordic UART Service (NUS)
    private static final UUID SERVICE_UUID = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
    private static final UUID RX_UUID = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e"); // App -> ESP32
    private static final UUID TX_UUID = UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e"); // ESP32 -> App
    private static final UUID CCCD_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    private static final int REQ_PERMISSIONS = 1001;
    private static final long SCAN_TIME_MS = 10_000;

    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeScanner bleScanner;
    private BluetoothGatt bluetoothGatt;
    private BluetoothGattCharacteristic rxCharacteristic;

    private boolean scanning = false;
    private BluetoothDevice selectedDevice;

    private final Map<String, BluetoothDevice> devicesByAddress = new LinkedHashMap<>();
    private final Map<String, String> labelsByAddress = new LinkedHashMap<>();
    private ArrayAdapter<String> deviceListAdapter;

    private TextView statusTextView;
    private TextView deviceIdTextView;
    private TextView selectedTextView;
    private TextView logTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupBluetooth();
        buildUi();
        checkInitialState();
    }

    private void setupBluetooth() {
        BluetoothManager manager = (BluetoothManager) getSystemService(Context.BLUETOOTH_SERVICE);
        if (manager != null) {
            bluetoothAdapter = manager.getAdapter();
        }
    }

    private void buildUi() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setPadding(dp(16), dp(18), dp(16), dp(16));
        root.setBackgroundColor(0xFFF7F9FC);

        TextView title = new TextView(this);
        title.setText("Inno Lock - Teste BLE ESP32-C3");
        title.setTextSize(22);
        title.setTypeface(Typeface.DEFAULT_BOLD);
        title.setTextColor(0xFF16202A);
        root.addView(title);

        TextView subtitle = new TextView(this);
        subtitle.setText("Escaneie o ESP32-C3 por Bluetooth BLE, conecte e envie comandos simples de acionamento.");
        subtitle.setTextSize(14);
        subtitle.setTextColor(0xFF54616F);
        subtitle.setPadding(0, dp(6), 0, dp(12));
        root.addView(subtitle);

        statusTextView = makeInfoText("Status: inicializando...");
        root.addView(statusTextView);

        deviceIdTextView = makeInfoText("Device ID MAC: ainda não lido");
        root.addView(deviceIdTextView);

        selectedTextView = makeInfoText("Dispositivo selecionado: nenhum");
        selectedTextView.setPadding(0, dp(4), 0, dp(8));
        root.addView(selectedTextView);

        LinearLayout rowScan = new LinearLayout(this);
        rowScan.setOrientation(LinearLayout.HORIZONTAL);
        rowScan.setPadding(0, dp(4), 0, dp(8));

        Button permissionsButton = makeButton("Permissões BLE", 0xFF455A64);
        permissionsButton.setOnClickListener(v -> requestNeededPermissions());
        rowScan.addView(permissionsButton, new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));

        Button scanButton = makeButton("Escanear", 0xFF1565C0);
        scanButton.setOnClickListener(v -> startScan());
        LinearLayout.LayoutParams scanParams = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1);
        scanParams.setMargins(dp(8), 0, 0, 0);
        rowScan.addView(scanButton, scanParams);

        root.addView(rowScan);

        deviceListAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, new ArrayList<>());
        ListView listView = new ListView(this);
        listView.setAdapter(deviceListAdapter);
        listView.setBackgroundColor(0xFFFFFFFF);
        listView.setOnItemClickListener((parent, view, position, id) -> selectDeviceByLabel(deviceListAdapter.getItem(position)));
        root.addView(listView, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                dp(130)
        ));

        LinearLayout rowConnect = new LinearLayout(this);
        rowConnect.setOrientation(LinearLayout.HORIZONTAL);
        rowConnect.setPadding(0, dp(8), 0, dp(8));

        Button connectButton = makeButton("Conectar", 0xFF2E7D32);
        connectButton.setOnClickListener(v -> connectSelectedDevice());
        rowConnect.addView(connectButton, new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));

        Button disconnectButton = makeButton("Desconectar", 0xFFC62828);
        disconnectButton.setOnClickListener(v -> disconnectGatt());
        LinearLayout.LayoutParams discParams = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1);
        discParams.setMargins(dp(8), 0, 0, 0);
        rowConnect.addView(disconnectButton, discParams);

        root.addView(rowConnect);

        Button pulseButton = makeButton("ACIONAR TRAVA - PULSO 1,2s", 0xFF1565C0);
        pulseButton.setOnClickListener(v -> sendCommand("PULSE:1200"));
        root.addView(pulseButton);

        Button statusButton = makeButton("LER STATUS", 0xFF455A64);
        statusButton.setOnClickListener(v -> sendCommand("STATUS"));
        root.addView(statusButton);

        LinearLayout rowCmd = new LinearLayout(this);
        rowCmd.setOrientation(LinearLayout.HORIZONTAL);
        rowCmd.setPadding(0, dp(8), 0, 0);

        Button onButton = makeButton("LIGAR", 0xFF2E7D32);
        onButton.setOnClickListener(v -> sendCommand("ON"));
        rowCmd.addView(onButton, new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1));

        Button offButton = makeButton("DESLIGAR", 0xFFC62828);
        offButton.setOnClickListener(v -> sendCommand("OFF"));
        LinearLayout.LayoutParams offParams = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1);
        offParams.setMargins(dp(8), 0, 0, 0);
        rowCmd.addView(offButton, offParams);

        root.addView(rowCmd);

        ScrollView scrollView = new ScrollView(this);
        logTextView = new TextView(this);
        logTextView.setTextSize(13);
        logTextView.setTextColor(0xFF263238);
        logTextView.setPadding(dp(12), dp(12), dp(12), dp(12));
        logTextView.setBackgroundColor(0xFFFFFFFF);
        logTextView.setMovementMethod(new ScrollingMovementMethod());
        logTextView.setText("Log BLE:\n");
        scrollView.addView(logTextView);
        LinearLayout.LayoutParams logParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                0,
                1
        );
        logParams.setMargins(0, dp(12), 0, 0);
        root.addView(scrollView, logParams);

        setContentView(root);
    }

    private TextView makeInfoText(String text) {
        TextView view = new TextView(this);
        view.setText(text);
        view.setTextSize(14);
        view.setTextColor(0xFF263238);
        view.setTypeface(Typeface.DEFAULT_BOLD);
        return view;
    }

    private Button makeButton(String text, int color) {
        Button button = new Button(this);
        button.setText(text);
        button.setTextSize(14);
        button.setTextColor(0xFFFFFFFF);
        button.setAllCaps(false);
        button.setGravity(Gravity.CENTER);
        button.setBackgroundColor(color);
        button.setPadding(dp(10), dp(10), dp(10), dp(10));
        return button;
    }

    private void checkInitialState() {
        if (bluetoothAdapter == null) {
            setStatus("Status: este aparelho não possui Bluetooth BLE disponível.");
            appendLog("BluetoothAdapter indisponível.");
            return;
        }
        if (!bluetoothAdapter.isEnabled()) {
            setStatus("Status: ative o Bluetooth do celular.");
            appendLog("Bluetooth do celular está desligado.");
            return;
        }
        if (!hasNeededPermissions()) {
            setStatus("Status: conceda as permissões BLE antes de escanear.");
            appendLog("Toque em 'Permissões BLE'.");
            return;
        }
        setStatus("Status: pronto para escanear dispositivos InnoLock_.");
    }

    private String[] neededPermissions() {
        List<String> permissions = new ArrayList<>();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions.add(Manifest.permission.BLUETOOTH_SCAN);
            permissions.add(Manifest.permission.BLUETOOTH_CONNECT);
        } else {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION);
        }
        return permissions.toArray(new String[0]);
    }

    private boolean hasNeededPermissions() {
        for (String permission : neededPermissions()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return true;
    }

    private void requestNeededPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(neededPermissions(), REQ_PERMISSIONS);
        } else {
            checkInitialState();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQ_PERMISSIONS) {
            checkInitialState();
        }
    }

    @SuppressLint("MissingPermission")
    private void startScan() {
        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            checkInitialState();
            return;
        }
        if (!hasNeededPermissions()) {
            requestNeededPermissions();
            return;
        }
        if (scanning) {
            stopScan();
        }

        bleScanner = bluetoothAdapter.getBluetoothLeScanner();
        if (bleScanner == null) {
            setStatus("Status: scanner BLE indisponível.");
            appendLog("Falha ao obter BluetoothLeScanner.");
            return;
        }

        devicesByAddress.clear();
        labelsByAddress.clear();
        refreshDeviceList();

        ScanSettings settings = new ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .build();

        scanning = true;
        setStatus("Status: escaneando por 10 segundos...");
        appendLog("Iniciando scan BLE sem filtro de UUID. Procurando nomes InnoLock_.");

        // IMPORTANTE PARA O FIRMWARE ATUAL:
        // o ESP32-C3 anuncia apenas o nome InnoLock_<MAC>, sem Service UUID no advertising.
        // Por isso o scan precisa ser aberto, e o filtro é feito por nome dentro do callback.
        bleScanner.startScan(null, settings, scanCallback);
        mainHandler.postDelayed(this::stopScan, SCAN_TIME_MS);
    }

    @SuppressLint("MissingPermission")
    private void stopScan() {
        if (!scanning) return;
        scanning = false;
        if (bleScanner != null && hasNeededPermissions()) {
            try {
                bleScanner.stopScan(scanCallback);
            } catch (Exception ignored) {
            }
        }
        setStatus("Status: scan finalizado. Selecione o ESP32-C3 encontrado.");
        appendLog("Scan finalizado. Dispositivos encontrados: " + devicesByAddress.size());
    }

    private final ScanCallback scanCallback = new ScanCallback() {
        @SuppressLint("MissingPermission")
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            BluetoothDevice device = result.getDevice();
            if (device == null) return;

            ScanRecord record = result.getScanRecord();
            String name = record != null ? record.getDeviceName() : null;
            if (name == null && hasNeededPermissions()) {
                try {
                    name = device.getName();
                } catch (Exception ignored) {
                }
            }
            if (name == null || name.trim().isEmpty()) {
                name = "Sem nome";
            }

            boolean nameLooksValid = name.startsWith("InnoLock_");

            // Firmware atual: advertising simples com nome InnoLock_<MAC>.
            // Não exige Service UUID no pacote de advertising.
            if (!nameLooksValid) {
                return;
            }

            String address = device.getAddress();
            devicesByAddress.put(address, device);
            labelsByAddress.put(address, name + "  |  " + address + "  |  RSSI " + result.getRssi());
            mainHandler.post(() -> {
                refreshDeviceList();
                setStatus("Status: ESP32-C3 encontrado. Selecione e conecte.");
            });
        }

        @Override
        public void onScanFailed(int errorCode) {
            mainHandler.post(() -> {
                scanning = false;
                setStatus("Status: falha no scan BLE.");
                appendLog("Erro no scan BLE: " + errorCode);
            });
        }
    };

    private void refreshDeviceList() {
        deviceListAdapter.clear();
        for (String label : labelsByAddress.values()) {
            deviceListAdapter.add(label);
        }
        deviceListAdapter.notifyDataSetChanged();
    }

    private void selectDeviceByLabel(String label) {
        if (label == null) return;
        for (Map.Entry<String, String> entry : labelsByAddress.entrySet()) {
            if (label.equals(entry.getValue())) {
                selectedDevice = devicesByAddress.get(entry.getKey());
                selectedTextView.setText("Dispositivo selecionado: " + label);
                appendLog("Selecionado: " + label);
                return;
            }
        }
    }

    @SuppressLint("MissingPermission")
    private void connectSelectedDevice() {
        if (!hasNeededPermissions()) {
            requestNeededPermissions();
            return;
        }
        if (selectedDevice == null) {
            setStatus("Status: selecione um dispositivo antes de conectar.");
            appendLog("Nenhum ESP32-C3 selecionado.");
            return;
        }
        stopScan();
        disconnectGatt();
        setStatus("Status: conectando...");
        appendLog("Conectando em: " + selectedDevice.getAddress());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            bluetoothGatt = selectedDevice.connectGatt(this, false, gattCallback, BluetoothDevice.TRANSPORT_LE);
        } else {
            bluetoothGatt = selectedDevice.connectGatt(this, false, gattCallback);
        }
    }

    @SuppressLint("MissingPermission")
    private void disconnectGatt() {
        if (bluetoothGatt != null && hasNeededPermissions()) {
            try {
                bluetoothGatt.disconnect();
                bluetoothGatt.close();
            } catch (Exception ignored) {
            }
        }
        bluetoothGatt = null;
        rxCharacteristic = null;
    }

    private final BluetoothGattCallback gattCallback = new BluetoothGattCallback() {
        @SuppressLint("MissingPermission")
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                mainHandler.post(() -> {
                    setStatus("Status: conectado. Descobrindo serviços...");
                    appendLog("BLE conectado. Status GATT: " + status);
                });
                gatt.discoverServices();
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                mainHandler.post(() -> {
                    setStatus("Status: desconectado.");
                    appendLog("BLE desconectado. Status GATT: " + status);
                });
                rxCharacteristic = null;
            }
        }

        @SuppressLint("MissingPermission")
        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {
            BluetoothGattService service = gatt.getService(SERVICE_UUID);
            if (service == null) {
                mainHandler.post(() -> {
                    setStatus("Status: serviço NUS não encontrado.");
                    appendLog("Serviço não encontrado: " + SERVICE_UUID);
                });
                return;
            }

            rxCharacteristic = service.getCharacteristic(RX_UUID);
            BluetoothGattCharacteristic txCharacteristic = service.getCharacteristic(TX_UUID);

            if (rxCharacteristic == null || txCharacteristic == null) {
                mainHandler.post(() -> {
                    setStatus("Status: características RX/TX não encontradas.");
                    appendLog("RX ou TX ausente no serviço NUS.");
                });
                return;
            }

            gatt.setCharacteristicNotification(txCharacteristic, true);
            BluetoothGattDescriptor descriptor = txCharacteristic.getDescriptor(CCCD_UUID);
            if (descriptor != null) {
                if (Build.VERSION.SDK_INT >= 33) {
                    gatt.writeDescriptor(descriptor, BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                } else {
                    descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);
                    gatt.writeDescriptor(descriptor);
                }
            }

            mainHandler.postDelayed(() -> sendCommand("STATUS"), 700);
            mainHandler.post(() -> {
                setStatus("Status: conectado ao Inno Lock BLE.");
                appendLog("Serviço NUS encontrado. RX/TX prontos.");
            });
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {
            handleIncomingBle(characteristic.getValue());
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, byte[] value) {
            handleIncomingBle(value);
        }
    };

    @SuppressLint("MissingPermission")
    private void sendCommand(String command) {
        if (!hasNeededPermissions()) {
            requestNeededPermissions();
            return;
        }
        if (bluetoothGatt == null || rxCharacteristic == null) {
            setStatus("Status: conecte ao ESP32-C3 antes de enviar comandos.");
            appendLog("Comando não enviado, BLE ainda não conectado: " + command);
            return;
        }

        byte[] data = command.getBytes(StandardCharsets.UTF_8);
        boolean ok;
        rxCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
        if (Build.VERSION.SDK_INT >= 33) {
            int result = bluetoothGatt.writeCharacteristic(
                    rxCharacteristic,
                    data,
                    BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            );
            ok = result == BluetoothGatt.GATT_SUCCESS;
        } else {
            rxCharacteristic.setValue(data);
            ok = bluetoothGatt.writeCharacteristic(rxCharacteristic);
        }

        appendLog("→ " + command + " | enviado=" + ok);
        setStatus(ok ? "Status: comando enviado." : "Status: falha ao enviar comando.");
    }

    private void handleIncomingBle(byte[] value) {
        if (value == null) return;
        String message = new String(value, StandardCharsets.UTF_8);
        mainHandler.post(() -> {
            appendLog("← " + message);
            String id = extractDeviceId(message);
            if (id != null && !id.isEmpty()) {
                deviceIdTextView.setText("Device ID MAC: " + id);
            }
        });
    }

    private String extractDeviceId(String message) {
        if (message == null) return null;
        if (message.startsWith("ID:")) {
            return message.substring(3).trim();
        }
        String key = "\"id\":\"";
        int start = message.indexOf(key);
        if (start >= 0) {
            int valueStart = start + key.length();
            int end = message.indexOf("\"", valueStart);
            if (end > valueStart) {
                return message.substring(valueStart, end);
            }
        }
        return null;
    }

    private void setStatus(String text) {
        statusTextView.setText(text);
    }

    private void appendLog(String text) {
        String time = new SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(new Date());
        logTextView.append("\n[" + time + "] " + text);
    }

    private int dp(int value) {
        return (int) (value * getResources().getDisplayMetrics().density + 0.5f);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopScan();
        disconnectGatt();
    }
}
