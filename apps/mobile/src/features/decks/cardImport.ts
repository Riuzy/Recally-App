export interface ParsedCard {
  front: string;
  back: string;
}

export interface ParsedCards {
  cards: ParsedCard[];
  /** 1-based line numbers that cannot be used, for the error message. */
  invalidLines: number[];
  hasInvalid: boolean;
}

/**
 * Splits pasted text into cards. One line per card, separated at the first
 * `;`. Blank lines are skipped. Lines without a separator, or with an empty
 * side, are reported as invalid and skipped.
 */
export function parseCardLines(input: string): ParsedCards {
  const cards: ParsedCard[] = [];
  const invalidLines: number[] = [];
  const lines = input.split(/\r?\n/);

  lines.forEach((raw, index) => {
    const line = raw.trim();
    if (line.length === 0) return;

    const separator = line.indexOf(';');
    if (separator <= 0) {
      invalidLines.push(index + 1);
      return;
    }

    const front = line.slice(0, separator).trim();
    const back = line.slice(separator + 1).trim();
    if (front.length === 0 || back.length === 0) {
      invalidLines.push(index + 1);
      return;
    }

    cards.push({ front, back });
  });

  return { cards, invalidLines, hasInvalid: invalidLines.length > 0 };
}
