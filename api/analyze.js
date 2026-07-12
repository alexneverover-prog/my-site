const MAX_IMAGE_BYTES = 3 * 1024 * 1024;
const WINDOW_MS = 10 * 60 * 1000;
const MAX_REQUESTS_PER_WINDOW = 6;
const requestLog = new Map();

const auditSchema = {
  type: 'object',
  additionalProperties: false,
  required: ['summary', 'issues'],
  properties: {
    summary: {
      type: 'string',
      description: 'Краткий вывод о качестве и назначении интерфейса на русском языке.',
    },
    issues: {
      type: 'array',
      maxItems: 5,
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['id', 'title', 'description', 'evidence', 'recommendation', 'severity', 'confidence', 'box_2d'],
        properties: {
          id: { type: 'string' },
          title: { type: 'string' },
          description: { type: 'string' },
          evidence: { type: 'string' },
          recommendation: { type: 'string' },
          severity: { type: 'string', enum: ['critical', 'warning', 'review'] },
          confidence: { type: 'number', minimum: 0, maximum: 1 },
          box_2d: {
            type: 'array',
            description: 'Область проблемы [ymin, xmin, ymax, xmax] в координатах от 0 до 1000.',
            minItems: 4,
            maxItems: 4,
            items: { type: 'integer', minimum: 0, maximum: 1000 },
          },
        },
      },
    },
  },
};

function allowedOrigins() {
  return new Set([
    'https://alexneverover-prog.github.io',
    'https://my-site-omega-ruby.vercel.app',
    'null',
    'http://127.0.0.1:8765',
    'http://localhost:8765',
    ...(process.env.ALLOWED_ORIGINS || '').split(',').map((origin) => origin.trim()).filter(Boolean),
  ]);
}

function setCors(req, res) {
  const origin = req.headers.origin;
  if (origin && allowedOrigins().has(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  }
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}

function clientAddress(req) {
  return String(req.headers['x-forwarded-for'] || req.socket?.remoteAddress || 'unknown').split(',')[0].trim();
}

function isRateLimited(req) {
  const now = Date.now();
  const key = clientAddress(req);
  const recent = (requestLog.get(key) || []).filter((timestamp) => now - timestamp < WINDOW_MS);
  recent.push(now);
  requestLog.set(key, recent);
  return recent.length > MAX_REQUESTS_PER_WINDOW;
}

function imageByteLength(dataUrl) {
  const base64 = dataUrl.split(',')[1] || '';
  return Math.ceil(base64.length * 0.75);
}

function extractOutputText(response) {
  if (typeof response.output_text === 'string') return response.output_text;
  for (const step of [...(response.steps || [])].reverse()) {
    if (step.type !== 'model_output') continue;
    for (const content of step.content || []) {
      if (content.type === 'text' && typeof content.text === 'string') return content.text;
    }
  }
  return '';
}

function normalizeIssue(issue, index) {
  const [rawYMin, rawXMin, rawYMax, rawXMax] = issue.box_2d;
  const x = Math.max(0, Math.min(0.98, rawXMin / 1000));
  const y = Math.max(0, Math.min(0.98, rawYMin / 1000));
  const xMax = Math.max(x + 0.02, Math.min(1, rawXMax / 1000));
  const yMax = Math.max(y + 0.02, Math.min(1, rawYMax / 1000));
  return {
    id: issue.id || `issue-${index + 1}`,
    title: issue.title,
    description: issue.description,
    evidence: issue.evidence,
    recommendation: issue.recommendation,
    severity: issue.severity,
    confidence: issue.confidence,
    x,
    y,
    width: Math.max(0.02, xMax - x),
    height: Math.max(0.02, yMax - y),
  };
}

export default async function handler(req, res) {
  setCors(req, res);

  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Метод не поддерживается.' });
  if (!process.env.GEMINI_API_KEY) return res.status(503).json({ error: 'Бесплатный AI-анализ пока не настроен.' });
  if (isRateLimited(req)) return res.status(429).json({ error: 'Слишком много проверок. Попробуйте снова через несколько минут.' });

  const { image, fileName = 'interface.png' } = req.body || {};
  if (typeof image !== 'string' || !/^data:image\/(png|jpe?g|webp);base64,/.test(image)) {
    return res.status(400).json({ error: 'Передайте изображение PNG, JPG или WebP.' });
  }
  if (imageByteLength(image) > MAX_IMAGE_BYTES) {
    return res.status(413).json({ error: 'Изображение слишком большое. Максимальный размер после подготовки — 3 МБ.' });
  }

  const instructions = `Ты ведущий продуктовый дизайнер и UX-исследователь. Анализируй только то, что действительно видно на скриншоте интерфейса.

Правила:
- Не придумывай назначение экрана, пользовательский сценарий, CTA, сетку, контраст или ошибки, если на изображении нет прямого визуального подтверждения.
- Не создавай проблему только ради заполнения списка. Если уверенных проблем нет, верни пустой массив issues.
- Отмечай максимум 5 наиболее существенных проблем, без дублей и общих фраз.
- Каждую проблему связывай с одной конкретной видимой областью и указывай box_2d как [ymin, xmin, ymax, xmax] в координатах от 0 до 1000.
- В evidence называй конкретные видимые элементы, тексты, цвета или взаимное расположение, которые подтверждают вывод.
- severity critical используй только для явно заблокированного основного сценария, недоступного текста или ошибочного состояния; warning — для заметной UX-проблемы; review — для гипотезы, которую нужно проверить.
- Пиши по-русски, коротко и профессионально. Рекомендация должна быть конкретным действием.
- Не оценивай качество фотографии, статус-бары устройства и системные элементы, если они не относятся к интерфейсу продукта.`;

  try {
    const [, mimeType, base64Data] = image.match(/^data:(image\/(?:png|jpe?g|webp));base64,(.+)$/);
    const geminiResponse = await fetch('https://generativelanguage.googleapis.com/v1beta/interactions', {
      method: 'POST',
      headers: {
        'x-goog-api-key': process.env.GEMINI_API_KEY,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: process.env.GEMINI_MODEL || 'gemini-3.5-flash',
        system_instruction: instructions,
        input: [
          { type: 'text', text: `Проведи доказательный UI/UX-разбор файла «${String(fileName).slice(0, 120)}».` },
          { type: 'image', data: base64Data, mime_type: mimeType },
        ],
        response_format: {
          type: 'text',
          mime_type: 'application/json',
          schema: auditSchema,
        },
      }),
    });

    const payload = await geminiResponse.json();
    if (!geminiResponse.ok) {
      console.error('Gemini API error', geminiResponse.status, payload?.error?.status || 'unknown');
      return res.status(502).json({ error: 'Модель не смогла выполнить анализ. Попробуйте ещё раз.' });
    }

    const outputText = extractOutputText(payload);
    if (!outputText) return res.status(502).json({ error: 'Модель вернула пустой результат.' });

    const audit = JSON.parse(outputText);
    const issues = audit.issues
      .filter((issue) => issue.confidence >= 0.68)
      .map(normalizeIssue);

    return res.status(200).json({ summary: audit.summary, issues });
  } catch (error) {
    console.error('Analysis request failed', error instanceof Error ? error.message : 'unknown');
    return res.status(500).json({ error: 'Не удалось завершить анализ. Попробуйте ещё раз.' });
  }
}
