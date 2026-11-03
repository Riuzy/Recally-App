import { useState } from 'react';
import { StyleSheet, TextInput, View, type TextInputProps } from 'react-native';

import { colors, radius, sizes, space } from '../theme/tokens';
import { fonts } from '../theme/typography';
import { AppText } from './AppText';

export interface AppTextFieldProps extends Omit<TextInputProps, 'style'> {
  label: string;
  hint?: string;
  errorText?: string;
  helperText?: string;
  inputRef?: React.RefObject<React.ComponentRef<typeof TextInput> | null>;
  multilineRows?: number;
}

/**
 * Input with a label above the field. Focus uses an orange border and a soft
 * ring, never a heavy shadow.
 */
export function AppTextField({
  label,
  hint,
  errorText,
  helperText,
  inputRef,
  multiline,
  multilineRows = 3,
  onFocus,
  onBlur,
  editable = true,
  ...rest
}: AppTextFieldProps): React.JSX.Element {
  const [focused, setFocused] = useState(false);
  const showRing = focused && editable;

  return (
    <View style={styles.wrapper}>
      <AppText variant="label" color={colors.inkSoft}>
        {label}
      </AppText>
      <View
        style={[
          styles.fieldShell,
          {
            borderColor: errorText
              ? colors.danger
              : focused
                ? colors.accent
                : colors.border,
            borderWidth: focused ? 1.5 : 1,
            backgroundColor: editable ? colors.surface : colors.surface2,
            // RN 0.76+ supports boxShadow cross-platform.
            boxShadow: showRing
              ? '0 0 0 3px rgba(224, 122, 31, 0.16)'
              : undefined,
          },
        ]}
      >
        <TextInput
          ref={inputRef}
          {...rest}
          editable={editable}
          multiline={multiline}
          placeholder={hint}
          placeholderTextColor={colors.muted}
          onFocus={(event) => {
            setFocused(true);
            onFocus?.(event);
          }}
          onBlur={(event) => {
            setFocused(false);
            onBlur?.(event);
          }}
          style={[
            styles.input,
            multiline
              ? { minHeight: 48 + (multilineRows - 1) * 20, textAlignVertical: 'top' }
              : null,
            { color: editable ? colors.ink : colors.muted },
          ]}
        />
      </View>
      {errorText ? (
        <AppText variant="caption" color={colors.danger} style={styles.helper}>
          {errorText}
        </AppText>
      ) : helperText ? (
        <AppText variant="caption" color={colors.muted} style={styles.helper}>
          {helperText}
        </AppText>
      ) : null}
    </View>
  );
}

export const appTextInputStyle = {
  fontFamily: fonts.regular,
  fontSize: 14,
  lineHeight: 20,
  color: colors.ink,
} as const;

const styles = StyleSheet.create({
  wrapper: {
    alignSelf: 'stretch',
  },
  fieldShell: {
    marginTop: space.sm,
    borderRadius: radius.control,
    overflow: 'hidden',
    backgroundColor: colors.surface,
  },
  input: {
    minHeight: sizes.input,
    paddingHorizontal: space.lg,
    paddingVertical: space.md,
    fontFamily: fonts.regular,
    fontSize: 14,
    lineHeight: 20,
    color: colors.ink,
  },
  helper: {
    marginTop: space.sm,
  },
});
