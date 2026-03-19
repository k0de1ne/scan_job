# Coverage Analyzer

Инструмент для анализа покрытия кода тестами во Flutter/Dart проектах.

## Использование

### Вариант 1: Python
```bash
cd tools/coverage_analyzer
python run_analysis.py
```

### Вариант 2: Batch (Windows)
```bash
run_analysis.bat
```

## Что показывает

- **Line Coverage** - процент строк кода, покрытых тестами
- **Branch Coverage** - процент ветвлений (if/else/switch), покрытых тестами
- **Uncovered Code** - конкретные непокрытые строки с кодом

## Цветовые обозначения

| Status | Значение |
|--------|----------|
| `[OK]`   | >= 80% покрытия |
| `[WARN]` | 50-79% покрытия |
| `[LOW]`  | < 50% покрытия |

## Пример вывода

```
================================================================================
                               COVERAGE REPORT                                  
================================================================================

                           OVERALL COVERAGE                                   
--------------------------------------------------------------------------------
  Line Coverage:     76.7%  (1013/1320 lines)
  Branch Coverage:   60.9%  (254/417 branches)

================================================================================
                           UNCOVERED CODE DETAILS                              
================================================================================

FILE: hh_tool.dart
  Line coverage: 13.7% (29/211)
  Branch coverage: 7.9% (6/76)
  Uncovered lines: 182
      15: class HhTool extends BaseTool {
      22:   HhTool({required this.apiClient});
      25:   @override
      26:   String get name => 'hh';
      ...
```

## Требования

- Flutter SDK
- Python 3.6+
