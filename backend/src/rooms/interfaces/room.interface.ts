export interface Room {
  readonly id: string;
  readonly name: string;
  readonly email: string;
  readonly floor: string;
  readonly capacity: number;
  readonly busy?: {
    end?: string | null;
    start?: string | null;
  }[];
}