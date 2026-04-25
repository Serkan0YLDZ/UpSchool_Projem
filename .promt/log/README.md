# .promt/log — Çalışma Logları

Bu klasör, her master prompt çalıştırıldığında otomatik olarak oluşturulan log dosyalarını içerir. 

## Amaç

Log dosyaları üç kritik amaca hizmet eder:

1. **Süreklilik:** Bir LLM'nin yarım bıraktığı yerden başka bir LLM devam edebilir.
2. **İzlenebilirlik:** Hangi dosyaların ne zaman yazıldığı, hangi testlerin eklendiği, hangi bug'ların neden düzeltildiği görülebilir.
3. **Bağlam:** Yeni bir oturumda projenin mevcut durumunu hızlıca anlamak için okunur.

## Dosya İsimlendirme Kuralları

| Prompt | Format |
|---|---|
| 01-sprint-coder | `sprint-{N}-coder-{YYYY-MM-DD}.md` |
| 02-code-reviewer | `sprint-{N}-review-{YYYY-MM-DD}.md` veya `file-review-{dosya}-{YYYY-MM-DD}.md` |
| 03-bug-fixer | `bugfix-{kısa-açıklama}-{YYYY-MM-DD}.md` |

## Mevcut Loglar

*(Henüz log yok — ilk prompt çalıştırıldığında burada listelenecek)*
