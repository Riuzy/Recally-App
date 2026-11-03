/**
 * RECALLY design tokens — v4.0 cream / navy / orange.
 * Single light theme. Orange is reserved for primary actions; text on orange
 * is always navy.
 */

export const colors = {
  canvas: '#F4F1EC',
  surface: '#FFFFFF',
  surface2: '#FAF7F2',
  surface3: '#EDE7DE',
  ink: '#1B2A41',
  inkSoft: '#3F4E61',
  muted: '#5C6B7A',
  border: '#C9CED6',
  borderStrong: '#AEB6C2',
  overlay: 'rgba(27, 42, 65, 0.42)',
  accent: '#E07A1F',
  accentStrong: '#B85A10',
  accentPressed: '#C96A16',
  accentSoft: '#FBE9D7',
  success: '#2F6B4A',
  successSoft: '#C8EBD7',
  warning: '#7A5A00',
  warningSoft: '#FCE8A6',
  danger: '#B3261E',
  dangerSoft: '#F4C7C3',
  info: '#4B6078',
  infoSoft: '#E8EDF2',
} as const;

export const space = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  huge: 40,
  giant: 48,
} as const;

export const radius = {
  card: 12,
  control: 12,
  chip: 999,
  pill: 999,
  sheet: 24,
} as const;

export const sizes = {
  screenMargin: 20,
  button: 52,
  textButton: 44,
  input: 48,
  touch: 44,
  icon: 20,
  nav: 72,
  topBar: 48,
  progress: 6,
  chart: 4,
  emptyIcon: 72,
} as const;

export const motion = {
  fast: 180,
  screen: 200,
  slow: 240,
} as const;

export const gradeTones = {
  lupa: { background: colors.dangerSoft, foreground: colors.danger },
  ragu: { background: colors.warningSoft, foreground: colors.warning },
  ingat: { background: colors.successSoft, foreground: colors.success },
} as const;

export type ColorName = keyof typeof colors;
