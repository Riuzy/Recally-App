export interface Deck {
  id: string;
  title: string;
  icon?: string;
}

export interface Card {
  id: string;
  deckId: string;
  front: string;
  back: string;
  dueAt: string;
}
