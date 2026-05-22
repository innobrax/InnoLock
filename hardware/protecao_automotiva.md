# Proteção Automotiva - Entrada de Alimentação

## 1. Objetivo

Definir a proteção básica da alimentação do Inno Lock em ambiente automotivo 12 V / 24 V.

## 2. Cenário

O dispositivo será instalado em veículos e deverá alimentar uma placa ESP32-C3 por meio de módulo step-down.

Entrada esperada:

```text
12 V ou 24 V automotivo
```

Saída para placa:

```text
5 V no pino VIN/5V da placa de desenvolvimento
```

## 3. Sequência sugerida

```text
+V veículo
  ↓
fusível ou PTC
  ↓
proteção contra inversão de polaridade
  ↓
TVS automotivo
  ↓
capacitor/filtro
  ↓
step-down 5 V
  ↓
ESP32-C3
```

## 4. Fusível

Para protótipo, pode ser usado fusível convencional ou fusível rearmável PTC.

Para produto comercial automotivo, avaliar:

- corrente nominal real do circuito;
- corrente da trava;
- corrente do step-down;
- temperatura ambiente;
- proteção contra curto.

## 5. Proteção contra inversão

Opções:

1. diodo em série;
2. Schottky em série;
3. MOSFET como diodo ideal.

Para produto final, MOSFET é mais eficiente por reduzir queda de tensão e aquecimento.

## 6. TVS

Para aplicação bivolt 12/24 V, o TVS deve ser escolhido com cuidado para não conduzir durante operação normal em 24 V, mas ainda proteger contra surtos.

A escolha final deve considerar:

- tensão máxima real da linha 24 V;
- transientes automotivos;
- especificação do step-down;
- ambiente de instalação.

## 7. Capacitores

Adicionar capacitores próximos ao step-down:

```text
eletrolítico ou polímero na entrada
cerâmico próximo ao módulo
```

Valores iniciais para bancada:

```text
100 uF a 470 uF
100 nF cerâmico
```

## 8. Observação

Este documento é uma referência inicial. A versão comercial deve ser validada eletricamente com medições de ruído, surtos e condições reais do veículo.
