import { Text, type TextProps, type TextStyle } from 'react-native';

import { colors } from '../theme/tokens';
import { fonts, typography, type TypographyName } from '../theme/typography';

export interface AppTextProps extends TextProps {
  variant?: TypographyName;
  weight?: keyof typeof fonts;
  color?: string;
  align?: TextStyle['textAlign'];
}

/** Inter text with a single typographic scale from the design spec. */
export function AppText({
  variant = 'body',
  weight,
  color = colors.ink,
  align,
  style,
  children,
  ...rest
}: AppTextProps): React.JSX.Element {
  const base = typography[variant];
  const weighted = weight ? { fontFamily: fonts[weight] } : null;

  return (
    <Text
      {...rest}
      style={[base, weighted, { color, textAlign: align }, style]}
    >
      {children}
    </Text>
  );
}
