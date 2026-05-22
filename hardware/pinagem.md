# Pinagem Inicial - Inno Lock

## 1. Placa

Placa de desenvolvimento baseada em **ESP32-C3**.

## 2. Pinos do protótipo

| Função | GPIO | Observação |
|---|---:|---|
| LED de debug | GPIO8 | Usado para simular trava no teste BLE |
| Saída de comando da trava | GPIO4 | Aciona transistor BC547 como chave low-side |
| Entrada de status da trava | GPIO5 | Lê retorno/status físico da trava |
| GND | GND | Referência comum |
| Alimentação placa | 5V/VIN | Via módulo step-down |

## 3. Lógica da trava

A trava motorizada possui:

1. fio de comando;
2. fio de retorno/status.

### Fio de comando

Quando aterrado, recolhe/levanta o êmbolo da trava para destravar.

### Fio de retorno/status

Envia aterramento quando o êmbolo está recolhido/destravado.

## 4. Saída com BC547

Ligação conceitual:

```text
GPIO4 -> resistor de base -> base BC547
emissor BC547 -> GND
coletor BC547 -> fio de comando da trava
```

Quando GPIO4 está ativo, o transistor conduz e aterra o fio de comando.

## 5. Entrada de status

O fio de retorno/status deve ser ligado ao GPIO5 com proteção adequada.

Recomendação:

- usar resistor de pull-up;
- usar proteção contra tensão indevida;
- garantir que o GPIO nunca receba tensão acima de 3,3 V;
- avaliar optoacoplador ou transistor de interface em versão comercial.

## 6. LED de debug

Durante protótipo, o GPIO8 simula o acionamento da trava.

Em firmware de bancada:

```text
GPIO8 = LED de debug
GPIO4 = saída real
GPIO5 = status real
```
