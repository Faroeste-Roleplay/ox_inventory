export type Slot = {
  slot: number;
  name?: string;
  count?: number;
  weight?: number;
  throwable?: boolean;
  metadata?: {
    [key: string]: any;
  };
  degradation?: number;
  durability?: number;
};

export type SlotWithItem = Slot & {
  name: string;
  count: number;
  weight: number;
  durability?: number;
  degradation?: number;
  price?: number;
  currency?: string;
  ingredients?: { [key: string]: number };
  duration?: number;
  image?: string;
  grade?: number | number[];
};
