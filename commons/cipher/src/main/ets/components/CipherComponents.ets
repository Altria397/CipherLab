import { AppColors, AppSizes } from './AppTheme'

interface IconDef {
  symbol: string
  color: string
}

const ALGO_ICONS: Record<string, IconDef> = {
  'caesar': { symbol: 'C', color: AppColors.caesar },
  'vigenere': { symbol: 'V', color: AppColors.vigenere },
  'enigma': { symbol: 'E', color: AppColors.enigma },
  'xor': { symbol: 'X', color: AppColors.xor },
  'base64': { symbol: 'B', color: AppColors.base64 },
  'rsa': { symbol: 'R', color: AppColors.rsa },
  'hill': { symbol: 'H', color: AppColors.hill },
  'otp': { symbol: 'O', color: AppColors.otp },
  'dh': { symbol: 'D', color: AppColors.dh },
  'hash': { symbol: '#', color: AppColors.hash },
  'analysis': { symbol: 'F', color: AppColors.analysis },
  'bruteForce': { symbol: 'B', color: AppColors.bruteForce },
  'kasiski': { symbol: 'K', color: AppColors.kasiski },
  'challenge': { symbol: '!', color: AppColors.challenge },
  'compare': { symbol: '=', color: AppColors.compare },
  'history': { symbol: 'T', color: AppColors.history },
}

const TYPE_ICONS: Record<string, IconDef> = {
  'shift': { symbol: 'S', color: AppColors.primary },
  'keyword': { symbol: 'K', color: AppColors.vigenere },
  'affine': { symbol: 'A', color: AppColors.enigma },
  'railFence': { symbol: 'F', color: AppColors.xor },
}

@Component
export struct AlgoIcon {
  @Prop algorithm: string = ''
  @Prop iconSize: number = 48

  build() {
    Column() {
      Text(this.getSymbol())
        .fontSize(this.iconSize * 0.45)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width(this.iconSize)
    .height(this.iconSize)
    .justifyContent(FlexAlign.Center)
    .borderRadius(this.iconSize * 0.3)
    .backgroundColor(this.getColor())
  }

  private getSymbol(): string {
    const def = ALGO_ICONS[this.algorithm]
    return def ? def.symbol : '?'
  }

  private getColor(): string {
    const def = ALGO_ICONS[this.algorithm]
    return def ? def.color : AppColors.textHint
  }
}

@Component
export struct CipherTypeIcon {
  @Prop cipherType: string = 'shift'
  @Prop iconSize: number = 36

  build() {
    Column() {
      Text(this.getSymbol())
        .fontSize(this.iconSize * 0.45)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width(this.iconSize)
    .height(this.iconSize)
    .justifyContent(FlexAlign.Center)
    .borderRadius(this.iconSize * 0.3)
    .backgroundColor(this.getColor())
  }

  private getSymbol(): string {
    const def = TYPE_ICONS[this.cipherType]
    return def ? def.symbol : '?'
  }

  private getColor(): string {
    const def = TYPE_ICONS[this.cipherType]
    return def ? def.color : AppColors.textHint
  }
}

@Component
export struct SectionHeader {
  @Prop title: string = ''
  @Prop accentColor: string = AppColors.primary

  build() {
    Row() {
      Column()
        .width(3)
        .height(16)
        .borderRadius(1.5)
        .backgroundColor(this.accentColor)
        .margin({ right: 8 })
      Text(this.title)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.textPrimary)
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
  }
}

@Component
export struct PageNavBar {
  @Prop title: string = ''
  @Prop accentColor: string = AppColors.primary
  private onBack: () => void = () => {}
  @Prop rightText: string = ''
  private onRightClick: () => void = () => {}

  build() {
    Row() {
      Text('\u2190')
        .fontSize(22)
        .fontColor(this.accentColor)
        .onClick(() => this.onBack())
        .padding(12)
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.textPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      if (this.rightText.length > 0) {
        Text(this.rightText)
          .fontSize(14)
          .fontColor(this.accentColor)
          .fontWeight(FontWeight.Medium)
          .padding(12)
          .onClick(() => this.onRightClick())
      } else {
        Blank().width(48)
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 4 })
    .backgroundColor(AppColors.bgCard)
  }
}

@Component
export struct StepButtonBar {
  @Prop resetText: string = '重置'
  @Prop stepText: string = '开始演示'
  @Prop accentColor: string = AppColors.primary
  @Prop isCompleted: boolean = false
  @Prop isEnabled: boolean = true
  private onReset: () => void = () => {}
  private onStep: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Button(this.resetText)
        .type(ButtonType.Capsule)
        .height(44)
        .backgroundColor(AppColors.bgInput)
        .fontColor(AppColors.textSecondary)
        .layoutWeight(1)
        .onClick(() => this.onReset())
      Button(this.stepText)
        .type(ButtonType.Capsule)
        .height(44)
        .backgroundColor(this.isCompleted ? AppColors.success : this.accentColor)
        .fontColor('#FFFFFF')
        .layoutWeight(2)
        .enabled(this.isEnabled)
        .onClick(() => this.onStep())
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 16 })
    .backgroundColor(AppColors.bgPage)
  }
}

@Component
export struct PrincipleCard {
  @Prop accentColor: string = AppColors.primary
  @Prop content: string = ''

  build() {
    Column({ space: 8 }) {
      Row() {
        Column()
          .width(3)
          .height(14)
          .borderRadius(1.5)
          .backgroundColor(this.accentColor)
          .margin({ right: 8 })
        Text('原理说明')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.accentColor)
      }
      Text(this.content)
        .fontSize(13)
        .fontColor(AppColors.textSecondary)
        .lineHeight(20)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.accentColor + '10')
    .borderRadius(AppSizes.radiusMedium)
  }
}

