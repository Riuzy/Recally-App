import type { TextStyle } from 'react-native';

/**
 * Inter is bundled locally. Each weight is a separate family name so text does
 * not rely on synthetic bolding.
 */
export const fonts = {
  regular: 'Inter_400Regular',
  medium: 'Inter_500Medium',
  semibold: 'Inter_600SemiBold',
  bold: 'Inter_700Bold',
} as const;

export const typography = {
  display: {
    fontFamily: fonts.bold,
    fontSize: 32,
    lineHeight: 38,
    letterSpacing: -0.6,
  },
  h1: {
    fontFamily: fonts.bold,
    fontSize: 20,
    lineHeight: 26,
    letterSpacing: -0.2,
  },
  h2: {
    fontFamily: fonts.semibold,
    fontSize: 20,
    lineHeight: 26,
    letterSpacing: -0.2,
  },
  h3: {
    fontFamily: fonts.semibold,
    fontSize: 16,
    lineHeight: 22,
  },
  bodyLarge: {
    fontFamily: fonts.regular,
    fontSize: 16,
    lineHeight: 24,
  },
  body: {
    fontFamily: fonts.regular,
    fontSize: 14,
    lineHeight: 20,
  },
  label: {
    fontFamily: fonts.semibold,
    fontSize: 11,
    lineHeight: 16,
    letterSpacing: 0.2,
  },
  caption: {
    fontFamily: fonts.regular,
    fontSize: 11,
    lineHeight: 16,
  },
  overline: {
    fontFamily: fonts.semibold,
    fontSize: 11,
    lineHeight: 16,
    letterSpacing: 0.8,
  },
} satisfies Record<string, TextStyle>;

export type TypographyName = keyof typeof typography;
