import { router } from '@kit.ArkUI'
import { AppColors, PageNavBar } from 'cipher'

const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'


@Component
struct RotorDisplay {
  @Prop rotorName: string = ''
  @Prop rotorPosition: number = 0
  @Prop accentColor: string = '#000000'
  @Prop highlight: boolean = false

  build() {
    Column({ space: 6 }) {
      Text(this.rotorName)
        .fontSize(12)
        .fontColor(this.highlight ? this.accentColor : '#636E72')
        .fontWeight(this.highlight ? FontWeight.Bold : FontWeight.Normal)
      Stack() {
        Column() {
          Text(ALPHABET.charAt(this.rotorPosition))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.highlight ? '#FFFFFF' : this.accentColor)
        }
        .width(52)
        .height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.highlight ? this.accentColor : '#F5F6FA')
        .borderRadius(12)
        .border({ width: 2, color: this.accentColor })
      }
      Text(`位置: ${this.rotorPosition}`)
        .fontSize(11)
        .fontColor('#999')
    }
  }
}

const ROTOR_I:   string = 'EKMFLGDQVZNTOWYHXUSPAIBRCJ'
const ROTOR_II:  string = 'AJDKSIRUXBLHWTMCQGZNPYFVOE'
const ROTOR_III: string = 'BDFHJLCPRTXVZNYEIWGAKMUSQO'
const REFLECTOR: string = 'YRUHQSLDPXNGOKMIEBFZCWVJAT'

class SignalStep {
  label: string = ''
  inputChar: string = ''
  outputChar: string = ''
  component: string = ''
}

class LetterResult {
  inputChar: string = ''
  outputChar: string = ''
  steps: SignalStep[] = []
}

@Entry
@Component
struct EnigmaPage {
  @State plaintext: string = 'HELLO'
  @State currentStep: number = -1
  @State currentSubStep: number = -1
  @State showResult: boolean = false
  @State resultChars: string[] = []
  @State currentLetterSteps: SignalStep[] = []
  @State rotorPositions: number[] = [0, 0, 0]
  @State signalHighlight: string = ''
  @State isEncrypting: boolean = true

  private savedPositions: number[] = [0, 0, 0]

  private getMaxSteps(): number {
    return this.plaintext.length + 1
  }

  private getStepButtonText(): string {
    if (this.currentStep < 0) {
      return '开始演示'
    }
    if (this.currentStep >= this.getMaxSteps()) {
      return '已完成'
    }
    if (this.currentSubStep >= 0 && this.currentSubStep < this.currentLetterSteps.length - 1) {
      return '信号下一步'
    }
    return '下一个字母 →'
  }

  private charToIndex(ch: string): number {
    return ch.charCodeAt(0) - 65
  }

  private indexToChar(idx: number): string {
    return ALPHABET.charAt(((idx % 26) + 26) % 26)
  }

  private rotorForward(input: number, rotor: string, position: number): number {
    const shifted = (input + position) % 26
    const mapped = this.charToIndex(rotor.charAt(shifted))
    return ((mapped - position) % 26 + 26) % 26
  }

  private rotorBackward(input: number, rotor: string, position: number): number {
    const shifted = (input + position) % 26
    const target = ALPHABET.charAt(shifted)
    let found = 0
    for (let i = 0; i < 26; i++) {
      if (rotor.charAt(i) === target) {
        found = i
        break
      }
    }
    return ((found - position) % 26 + 26) % 26
  }

  private reflectorMap(input: number): number {
    return this.charToIndex(REFLECTOR.charAt(input))
  }

  private advanceRotors(): void {
    this.rotorPositions[2] = (this.rotorPositions[2] + 1) % 26
    if (this.rotorPositions[2] === 0) {
      this.rotorPositions[1] = (this.rotorPositions[1] + 1) % 26
      if (this.rotorPositions[1] === 0) {
        this.rotorPositions[0] = (this.rotorPositions[0] + 1) % 26
      }
    }
    this.rotorPositions = [...this.rotorPositions]
  }

  private encryptLetter(ch: string): LetterResult {
    const result = new LetterResult()
    result.inputChar = ch
    result.steps = []

    let val = this.charToIndex(ch)
    const inputChar = ch

    const s0 = new SignalStep()
    s0.label = '输入'
    s0.inputChar = inputChar
    s0.outputChar = inputChar
    s0.component = 'input'
    result.steps.push(s0)

    this.advanceRotors()

    let out = this.rotorForward(val, ROTOR_III, this.rotorPositions[2])
    const s1 = new SignalStep()
    s1.label = '转子 III →'
    s1.inputChar = this.indexToChar(val)
    s1.outputChar = this.indexToChar(out)
    s1.component = 'rotor3'
    result.steps.push(s1)
    val = out

    out = this.rotorForward(val, ROTOR_II, this.rotorPositions[1])
    const s2 = new SignalStep()
    s2.label = '转子 II →'
    s2.inputChar = this.indexToChar(val)
    s2.outputChar = this.indexToChar(out)
    s2.component = 'rotor2'
    result.steps.push(s2)
    val = out

    out = this.rotorForward(val, ROTOR_I, this.rotorPositions[0])
    const s3 = new SignalStep()
    s3.label = '转子 I →'
    s3.inputChar = this.indexToChar(val)
    s3.outputChar = this.indexToChar(out)
    s3.component = 'rotor1'
    result.steps.push(s3)
    val = out

    out = this.reflectorMap(val)
    const s4 = new SignalStep()
    s4.label = '反射器'
    s4.inputChar = this.indexToChar(val)
    s4.outputChar = this.indexToChar(out)
    s4.component = 'reflector'
    result.steps.push(s4)
    val = out

    out = this.rotorBackward(val, ROTOR_I, this.rotorPositions[0])
    const s5 = new SignalStep()
    s5.label = '← 转子 I'
    s5.inputChar = this.indexToChar(val)
    s5.outputChar = this.indexToChar(out)
    s5.component = 'rotor1'
    result.steps.push(s5)
    val = out

    out = this.rotorBackward(val, ROTOR_II, this.rotorPositions[1])
    const s6 = new SignalStep()
    s6.label = '← 转子 II'
    s6.inputChar = this.indexToChar(val)
    s6.outputChar = this.indexToChar(out)
    s6.component = 'rotor2'
    result.steps.push(s6)
    val = out

    out = this.rotorBackward(val, ROTOR_III, this.rotorPositions[2])
    const s7 = new SignalStep()
    s7.label = '← 转子 III'
    s7.inputChar = this.indexToChar(val)
    s7.outputChar = this.indexToChar(out)
    s7.component = 'rotor3'
    result.steps.push(s7)
    val = out

    const outputChar = this.indexToChar(val)
    const s8 = new SignalStep()
    s8.label = '输出'
    s8.inputChar = this.indexToChar(val)
    s8.outputChar = outputChar
    s8.component = 'output'
    result.steps.push(s8)

    result.outputChar = outputChar
    return result
  }

  resetAnimation() {
    this.currentStep = -1
    this.currentSubStep = -1
    this.showResult = false
    this.resultChars = []
    this.currentLetterSteps = []
    this.rotorPositions = [0, 0, 0]
    this.savedPositions = [0, 0, 0]
    this.signalHighlight = ''
  }

  nextStep() {
    if (this.currentStep >= this.getMaxSteps()) {
      return
    }

    if (this.currentSubStep >= 0 && this.currentSubStep < this.currentLetterSteps.length - 1) {
      this.currentSubStep++
      this.signalHighlight = this.currentLetterSteps[this.currentSubStep].component
      return
    }

    this.currentStep++
    this.currentSubStep = -1
    this.currentLetterSteps = []
    this.signalHighlight = ''

    if (this.currentStep === 0) {
      this.showResult = false
      this.resultChars = []
      this.rotorPositions = [0, 0, 0]
      this.savedPositions = [0, 0, 0]
      for (let i = 0; i < this.plaintext.length; i++) {
        this.resultChars.push('')
      }
    } else if (this.currentStep >= 1 && this.currentStep <= this.plaintext.length) {
      const idx = this.currentStep - 1
      const ch = this.plaintext.charAt(idx)
      const code = ch.charCodeAt(0)
      if (code >= 65 && code <= 90) {
        this.savedPositions = [...this.rotorPositions]
        const letterResult = this.encryptLetter(ch)
        this.resultChars[idx] = letterResult.outputChar
        this.currentLetterSteps = letterResult.steps
        this.currentSubStep = 0
        this.signalHighlight = this.currentLetterSteps[0].component
      } else {
        this.resultChars[idx] = ch
      }
    } else {
      this.showResult = true
    }
  }

  private getComponentColor(component: string): string {
    switch (component) {
      case 'input': return '#636E72'
      case 'rotor3': return '#0984E3'
      case 'rotor2': return '#6C5CE7'
      case 'rotor1': return '#E17055'
      case 'reflector': return '#00B894'
      case 'output': return '#D63031'
      default: return '#636E72'
    }
  }

  private getComponentBgColor(component: string): string {
    switch (component) {
      case 'input': return '#F5F6FA'
      case 'rotor3': return '#E3F2FD'
      case 'rotor2': return '#EDE7F6'
      case 'rotor1': return '#FBE9E7'
      case 'reflector': return '#E8FFF5'
      case 'output': return '#FFEBEE'
      default: return '#F5F6FA'
    }
  }

  build() {
    Column() {
      PageNavBar({
        title: 'Enigma 密码机',
        accentColor: AppColors.enigma,
        onBack: (): void => router.back(),
        rightText: this.isEncrypting ? '加密' : '解密',
        onRightClick: (): void => {
          this.isEncrypting = !this.isEncrypting
          this.resetAnimation()
        }
      })

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('原理说明')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8B5A2B')
            Text('Enigma 是二战时期德军使用的电机转子加密机。信号从键盘输入，依次经过3个转子（III→II→I）到达反射器，再反向经过3个转子（I→II→III）输出。每按一个键，最右转子转动一格，形成不断变化的替换表。Enigma是对称加密：用相同转子设置再次输入密文即可解密。')
              .fontSize(13)
              .fontColor('#636E72')
              .lineHeight(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF8F0')
          .borderRadius(12)

          Column({ space: 12 }) {
            Text('输入设置')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)
            TextInput({ text: this.plaintext, placeholder: '输入明文（大写英文字母）' })
              .width('100%')
              .height(44)
              .fontColor(AppColors.textPrimary)
              .backgroundColor('#F5F6FA')
              .borderRadius(10)
              .onChange((val: string) => {
                this.plaintext = val.toUpperCase()
                this.resetAnimation()
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Text('转子状态')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)

            Row({ space: 12 }) {
              RotorDisplay({ rotorName: '转子 I', rotorPosition: this.rotorPositions[0], accentColor: '#E17055',
                highlight: this.signalHighlight === 'rotor1' })
              RotorDisplay({ rotorName: '转子 II', rotorPosition: this.rotorPositions[1], accentColor: '#6C5CE7',
                highlight: this.signalHighlight === 'rotor2' })
              RotorDisplay({ rotorName: '转子 III', rotorPosition: this.rotorPositions[2], accentColor: '#0984E3',
                highlight: this.signalHighlight === 'rotor3' })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Text('加密过程')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)

            Text('明文')
              .fontSize(12)
              .fontColor('#999')
              .alignSelf(ItemAlign.Start)
            Scroll() {
              Row({ space: 4 }) {
                ForEach(this.plaintext.split(''), (ch: string, idx: number) => {
                  Column() {
                    Text(ch)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? '#8B5A2B' : '#2D3436')
                  }
                  .width(36)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? '#FFF0DB' : '#F5F6FA')
                  .borderRadius(8)
                  .border({
                    width: this.currentStep >= 1 && this.currentStep - 1 === idx ? 2 : 0,
                    color: '#8B5A2B'
                  })
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)

            Text('密文')
              .fontSize(12)
              .fontColor('#999')
              .alignSelf(ItemAlign.Start)
            Scroll() {
              Row({ space: 4 }) {
                ForEach(this.plaintext.split(''), (_ch: string, idx: number) => {
                  Column() {
                    Text(this.resultChars.length > idx && this.resultChars[idx] !== ''
                      ? this.resultChars[idx] : '?')
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.resultChars.length > idx && this.resultChars[idx] !== ''
                        ? '#FFFFFF' : '#CCC')
                  }
                  .width(36)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.resultChars.length > idx && this.resultChars[idx] !== ''
                    ? '#8B5A2B' : '#F0F0F0')
                  .borderRadius(8)
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

          if (this.currentLetterSteps.length > 0) {
            Column({ space: 10 }) {
              Row() {
                Text(`信号路径：字母 '${this.plaintext.charAt(this.currentStep - 1)}'`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2D3436')
                Blank()
                Text(`${this.currentSubStep + 1}/${this.currentLetterSteps.length}`)
                  .fontSize(12)
                  .fontColor('#999')
              }
              .width('100%')

              Row() {
                ForEach(['入', 'III', 'II', 'I', '反射', 'I', 'II', 'III', '出'], (label: string, idx: number) => {
                  Column() {
                    Text(label)
                      .fontSize(9)
                      .fontColor(this.currentSubStep >= idx ? '#FFFFFF' : '#B2BEC3')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width(30)
                  .height(28)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.currentSubStep >= idx
                    ? (this.currentSubStep === idx ? '#8B5A2B' : '#C8956C')
                    : '#F0F0F0')
                  .borderRadius(6)
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              ForEach(this.currentLetterSteps, (step: SignalStep, sIdx: number) => {
                if (sIdx <= this.currentSubStep) {
                  Row({ space: 10 }) {
                    Text(`${sIdx + 1}`)
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                      .width(22)
                      .height(22)
                      .textAlign(TextAlign.Center)
                      .backgroundColor(this.getComponentColor(step.component))
                      .borderRadius(11)
                    Text(step.label)
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.getComponentColor(step.component))
                      .width(80)
                    Row({ space: 6 }) {
                      Text(step.inputChar)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#2D3436')
                        .width(28)
                        .height(28)
                        .textAlign(TextAlign.Center)
                        .backgroundColor('#F5F6FA')
                        .borderRadius(6)
                      Text('→')
                        .fontSize(14)
                        .fontColor('#B2BEC3')
                      Text(step.outputChar)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                        .width(28)
                        .height(28)
                        .textAlign(TextAlign.Center)
                        .backgroundColor(this.getComponentColor(step.component))
                        .borderRadius(6)
                    }
                  }
                  .width('100%')
                  .padding({ top: 6, bottom: 6, left: 8, right: 8 })
                  .backgroundColor(sIdx === this.currentSubStep
                    ? this.getComponentBgColor(step.component) : '#FAFBFF')
                  .borderRadius(8)
                  .border({
                    width: sIdx === this.currentSubStep ? 1 : 0,
                    color: this.getComponentColor(step.component)
                  })
                }
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })
          }

          if (this.currentStep === 0) {
            Column({ space: 8 }) {
              Text('Enigma 加密机结构示意')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2D3436')
                .alignSelf(ItemAlign.Start)
              Text('键盘 → 转子III → 转子II → 转子I → 反射器')
                .fontSize(13)
                .fontColor('#0984E3')
                .fontWeight(FontWeight.Medium)
              Text('反射器 → 转子I → 转子II → 转子III → 灯板')
                .fontSize(13)
                .fontColor('#E17055')
                .fontWeight(FontWeight.Medium)
              Text('点击"下一个字母"开始逐字母加密')
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 4 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })
          }

          if (this.showResult) {
            Column({ space: 8 }) {
              Text('\u2713 加密完成')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#00B894')
              Text(`密文：${this.resultChars.join('')}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2D3436')
                .copyOption(CopyOptions.LocalDevice)
              Text('Enigma 的特性：同一字母在不同位置会加密为不同结果，且一个字母永远不会加密为自身。用相同转子设置输入密文即可还原明文。')
                .fontSize(12)
                .fontColor('#636E72')
                .lineHeight(18)
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#E8FFF5')
            .borderRadius(12)
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Row({ space: 12 }) {
        Button('重置')
          .type(ButtonType.Capsule)
          .height(44)
          .backgroundColor('#F5F6FA')
          .fontColor('#636E72')
          .layoutWeight(1)
          .onClick(() => this.resetAnimation())
        Button(this.getStepButtonText())
          .type(ButtonType.Capsule)
          .height(44)
          .backgroundColor(this.currentStep >= this.getMaxSteps() ? '#00B894' : '#8B5A2B')
          .fontColor('#FFFFFF')
          .layoutWeight(2)
          .enabled(this.currentStep < this.getMaxSteps() && this.plaintext.length > 0)
          .onClick(() => this.nextStep())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      .backgroundColor('#F5F6FA')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

}
