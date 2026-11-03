import {
  CalendarBlankIcon,
  CaretDownIcon,
  CaretLeftIcon,
  CaretRightIcon,
  CardsIcon,
  ChartLineIcon,
  CheckCircleIcon,
  CheckIcon,
  ClipboardTextIcon,
  ClockCountdownIcon,
  ClockIcon,
  CloudArrowUpIcon,
  DotsThreeVerticalIcon,
  FlameIcon,
  GearIcon,
  InfoIcon,
  PlayIcon,
  PlusIcon,
  QuestionIcon,
  StackIcon,
  WarningCircleIcon,
  WarningIcon,
  XCircleIcon,
  XIcon,
  type IconWeight,
} from 'phosphor-react-native';

const iconMap = {
  calendarBlank: CalendarBlankIcon,
  caretDown: CaretDownIcon,
  caretLeft: CaretLeftIcon,
  caretRight: CaretRightIcon,
  cards: CardsIcon,
  chartLine: ChartLineIcon,
  check: CheckIcon,
  checkCircle: CheckCircleIcon,
  clipboardText: ClipboardTextIcon,
  clock: ClockIcon,
  clockCountdown: ClockCountdownIcon,
  cloudArrowUp: CloudArrowUpIcon,
  dotsThreeVertical: DotsThreeVerticalIcon,
  flame: FlameIcon,
  gear: GearIcon,
  info: InfoIcon,
  play: PlayIcon,
  plus: PlusIcon,
  question: QuestionIcon,
  stack: StackIcon,
  warning: WarningIcon,
  warningCircle: WarningCircleIcon,
  x: XIcon,
  xCircle: XCircleIcon,
} as const;

export type IconName = keyof typeof iconMap;

export function AppIcon({
  name,
  size = 20,
  color,
  weight = 'regular',
}: {
  name: IconName;
  size?: number;
  color: string;
  weight?: IconWeight;
}): React.JSX.Element {
  const Glyph = iconMap[name];
  return <Glyph size={size} color={color} weight={weight} />;
}
