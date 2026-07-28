import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard, StepButtonBar } from 'cipher'

@Entry
@Component
struct CaesarPage {
  @State plaintext: string = 'HELLO'
  @State shift: number = 3
  @State currentStep: number = -1
  @State resultChars: string[] = []
  @State isEncrypting: boolean = true
  @State showResult: boolean = false

  private alphabet: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  private getMaxSteps(): number {
    return this.getLetterCount() + 1
  }

  private getStepButtonText(): string {
    if (this.currentStep < 0) return '开始演示'
    if (this.currentStep >= this.getMaxSteps()) return '已完成'
    return '下一步 \u2192'
  }

  getLetterCount(): number {
    let count = 0
    for (let i = 0; i < this.plaintext.length; i++) {
      const c = this.plaintext.charCodeAt(i)
      if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) count++
    }
    return count
  }

  resetAnimation() {
    this.currentStep = -1
    this.showResult = false
    this.resultChars = []
    for (let i = 0; i < this.plaintext.length; i++) {
      this.resultChars.push('')
    }
  }

  nextStep() {
    if (this.currentStep >= this.getMaxSteps()) return
    this.currentStep++
    if (this.currentStep === 0) {
      this.showResult = false
      this.resultChars = []
      for (let i = 0; i < this.plaintext.length; i++) {
        this.resultChars.push('')
      }
    } else if (this.currentStep >= 1 && this.currentStep <= this.getLetterCount()) {
      const charIdx = this.currentStep - 1
      const ch = this.plaintext.charAt(charIdx)
      const effectiveShift = this.isEncrypting ? this.shift : -this.shift
      this.resultChars[charIdx] = CipherUtils.caesarEncryptChar(ch, effectiveShift)
    } else if (this.currentStep === this.getMaxSteps()) {
      this.showResult = true
    }
  }

  isCurrentMapHighlighted(idx: number): boolean {
    if (this.currentStep < 1) return false
    const charIdx = this.currentStep - 1
    if (charIdx >= this.plaintext.length) return false
    const code = this.plaintext.charCodeAt(charIdx)
    if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
      return (this.plaintext.charAt(charIdx).toUpperCase().charCodeAt(0) - 65) === idx
    }
    return false
  }

  getCharColor(idx: number): string {
    if (this.currentStep >= 1 && this.currentStep - 1 === idx) return AppColors.caesar
    if (this.currentStep >= 1 && idx < this.currentStep - 1) return AppColors.success
    return AppColors.textPrimary
  }

  getCharBg(idx: number): string {
    if (this.currentStep >= 1 && this.currentStep - 1 === idx) return AppColors.caesar + '15'
    if (this.currentStep >= 1 && idx < this.currentStep - 1) return AppColors.bgSurface
    return AppColors.bgInput
  }

  build() {
    Column() {
      PageNavBar({
        title: '凯撒密码',
        accentColor: AppColors.caesar,
        onBack: (): void => router.back(),
        rightText: this.isEncrypting ? '加密' : '解密',
        onRightClick: () => {
          this.isEncrypting = !this.isEncrypting
          this.resetAnimation()
        }
      })

      Scroll() {
        Column({ space: 14 }) {
          PrincipleCard({
            accentColor: AppColors.caesar,
            content: '凯撒密码通过将字母表中的每个字母移动固定位数来加密。例如位移3时，A\u2192D, B\u2192E, C\u2192F。解密时反向位移即可还原。'
          })

          Column({ space: 12 }) {
            Row() {
              Column()
                .width(3)
                .height(14)
                .borderRadius(1.5)
                .backgroundColor(AppColors.caesar)
                .margin({ right: 8 })
              Text('输入设置')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.textPrimary)
            }

            TextInput({ text: this.plaintext, placeholder: '输入文本（英文字母）' })
              .width('100%')
              .height(44)
              .fontColor(AppColors.textPrimary)
              .backgroundColor(AppColors.bgInput)
              .borderRadius(10)
              .onChange((val: string) => {
                this.plaintext = val.toUpperCase()
                this.resetAnimation()
              })

            Row() {
              Text('位移量：')
                .fontSize(14)
                .fontColor(AppColors.textSecondary)
              Text(`${this.shift}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.caesar)
                .width(40)
                .textAlign(TextAlign.Center)
              Slider({ value: this.shift, min: 1, max: 25, step: 1 })
                .layoutWeight(1)
                .selectedColor(AppColors.caesar)
                .onChange((value: number) => {
                  this.shift = Math.round(value)
                  this.resetAnimation()
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.bgCard)
          .borderRadius(12)
          .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Row() {
              Column()
                .width(3)
                .height(14)
                .borderRadius(1.5)
                .backgroundColor(AppColors.caesar)
                .margin({ right: 8 })
              Text('字母表映射')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.textPrimary)
            }

            Scroll() {
              Row({ space: 2 }) {
                ForEach(this.alphabet.split(''), (ch: string, idx: number) => {
                  Column({ space: 2 }) {
                    Text(ch)
                      .fontSize(11)
                      .fontColor(AppColors.textSecondary)
                      .fontWeight(FontWeight.Medium)
                    Text('\u2193')
                      .fontSize(8)
                      .fontColor(AppColors.textHint)
                    Text(this.alphabet[(idx + this.shift) % 26])
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(AppColors.caesar)
                  }
                  .width(28)
                  .height(52)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.isCurrentMapHighlighted(idx) ? AppColors.caesar + '20' : AppColors.bgInput)
                  .borderRadius(6)
                  .border({
                    width: this.isCurrentMapHighlighted(idx) ? 1.5 : 0,
                    color: AppColors.caesar
                  })
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.bgCard)
          .borderRadius(12)
          .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Row() {
              Column()
                .width(3)
                .height(14)
                .borderRadius(1.5)
                .backgroundColor(AppColors.caesar)
                .margin({ right: 8 })
              Text(this.isEncrypting ? '加密过程演示' : '解密过程演示')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.textPrimary)
            }

            Text('原文字符')
              .fontSize(12)
              .fontColor(AppColors.textHint)
              .alignSelf(ItemAlign.Start)
            Row({ space: 6 }) {
              ForEach(this.plaintext.split(''), (ch: string, idx: number) => {
                Column() {
                  Text(ch)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.getCharColor(idx))
                }
                .width(40)
                .height(40)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.getCharBg(idx))
                .borderRadius(8)
                .border({ width: this.currentStep >= 1 && this.currentStep - 1 === idx ? 2 : 0, color: AppColors.caesar })
                .scale({
                  x: this.currentStep >= 1 && this.currentStep - 1 === idx ? 1.12 : 1,
                  y: this.currentStep >= 1 && this.currentStep - 1 === idx ? 1.12 : 1
                })
                .animation({ duration: 300, curve: Curve.EaseOut })
              })
            }

            if (this.currentStep >= 1) {
              Text(`${this.isEncrypting ? '\u2193 位移' : '\u2193 反向位移'} ${this.shift}`)
                .fontSize(14)
                .fontColor(AppColors.caesar)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 4, bottom: 4 })
                .animation({ duration: 300 })
            }

            Text(this.isEncrypting ? '密文字符' : '明文字符')
              .fontSize(12)
              .fontColor(AppColors.textHint)
              .alignSelf(ItemAlign.Start)
            Row({ space: 6 }) {
              ForEach(this.plaintext.split(''), (_ch: string, idx: number) => {
                Column() {
                  Text(this.resultChars.length > idx ? this.resultChars[idx] : '?')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.resultChars.length > idx && this.resultChars[idx] !== '' ? AppColors.textPrimary : AppColors.textHint)
                }
                .width(40)
                .height(40)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.resultChars.length > idx && this.resultChars[idx] !== '' ? AppColors.caesar : '#F0F0F0')
                .borderRadius(8)
                .opacity(this.resultChars.length > idx && this.resultChars[idx] !== '' ? 1 : 0.4)
                .animation({ duration: 400, curve: Curve.EaseOut })
              })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.bgCard)
          .borderRadius(12)
          .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(`\u2713 ${this.isEncrypting ? '加密' : '解密'}完成`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.success)
              Text(`结果：${this.resultChars.join('')}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.textPrimary)
                .copyOption(CopyOptions.LocalDevice)
            }
            .width('100%')
            .padding(20)
            .backgroundColor(AppColors.bgSurface)
            .borderRadius(12)
            .animation({ duration: 400 })
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      StepButtonBar({
        stepText: this.getStepButtonText(),
        accentColor: AppColors.caesar,
        isCompleted: this.currentStep >= this.getMaxSteps(),
        isEnabled: this.currentStep < this.getMaxSteps(),
        onReset: (): void => this.resetAnimation(),
        onStep: (): void => this.nextStep()
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgPage)
  }
}
