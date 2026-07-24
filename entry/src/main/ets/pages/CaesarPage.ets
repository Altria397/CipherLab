import { router } from '@kit.ArkUI'
import { CipherUtils } from 'cipher'

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
    return '下一步 →'
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
    if (this.currentStep >= 1 && this.currentStep - 1 === idx) return '#667EEA'
    if (this.currentStep >= 1 && idx < this.currentStep - 1) return '#00B894'
    return '#2D3436'
  }

  getCharBg(idx: number): string {
    if (this.currentStep >= 1 && this.currentStep - 1 === idx) return '#667EEA15'
    if (this.currentStep >= 1 && idx < this.currentStep - 1) return '#E8FFF5'
    return '#F5F6FA'
  }

  build() {
    Column() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#667EEA')
          .onClick(() => router.back())
          .padding(12)
        Text('凯撒密码')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2D3436')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text(this.isEncrypting ? '加密' : '解密')
          .fontSize(14)
          .fontColor('#667EEA')
          .padding(12)
          .onClick(() => {
            this.isEncrypting = !this.isEncrypting
            this.resetAnimation()
          })
      }
      .width('100%')
      .padding({ top: 12 })

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('原理说明')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#667EEA')
            Text('凯撒密码通过将字母表中的每个字母移动固定位数来加密。例如位移3时，A→D, B→E, C→F。解密时反向位移即可还原。')
              .fontSize(13)
              .fontColor('#636E72')
              .lineHeight(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F0F3FF')
          .borderRadius(12)

          Column({ space: 12 }) {
            Text('输入设置')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)

            TextInput({ text: this.plaintext, placeholder: '输入文本（英文字母）' })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F6FA')
              .borderRadius(10)
              .onChange((val: string) => {
                this.plaintext = val.toUpperCase()
                this.resetAnimation()
              })

            Row() {
              Text('位移量：')
                .fontSize(14)
                .fontColor('#2D3436')
              Text(`${this.shift}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#667EEA')
                .width(40)
                .textAlign(TextAlign.Center)
              Slider({ value: this.shift, min: 1, max: 25, step: 1 })
                .layoutWeight(1)
                .selectedColor('#667EEA')
                .onChange((value: number) => {
                  this.shift = Math.round(value)
                  this.resetAnimation()
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Text('字母表映射')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)

            Scroll() {
              Row({ space: 2 }) {
                ForEach(this.alphabet.split(''), (ch: string, idx: number) => {
                  Column({ space: 2 }) {
                    Text(ch)
                      .fontSize(11)
                      .fontColor('#636E72')
                      .fontWeight(FontWeight.Medium)
                    Text('↓')
                      .fontSize(8)
                      .fontColor('#B2BEC3')
                    Text(this.alphabet[(idx + this.shift) % 26])
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#667EEA')
                  }
                  .width(28)
                  .height(52)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.isCurrentMapHighlighted(idx) ? '#667EEA20' : '#F5F6FA')
                  .borderRadius(6)
                  .border({
                    width: this.isCurrentMapHighlighted(idx) ? 1.5 : 0,
                    color: '#667EEA'
                  })
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

          Column({ space: 12 }) {
            Text(this.isEncrypting ? '加密过程演示' : '解密过程演示')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)

            Text('原文字符')
              .fontSize(12)
              .fontColor('#999')
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
                .border({ width: this.currentStep >= 1 && this.currentStep - 1 === idx ? 2 : 0, color: '#667EEA' })
                .scale({
                  x: this.currentStep >= 1 && this.currentStep - 1 === idx ? 1.15 : 1,
                  y: this.currentStep >= 1 && this.currentStep - 1 === idx ? 1.15 : 1
                })
                .animation({ duration: 300, curve: Curve.EaseOut })
              })
            }

            if (this.currentStep >= 1) {
              Text(`${this.isEncrypting ? '↓ 位移' : '↓ 反向位移'} ${this.shift}`)
                .fontSize(14)
                .fontColor('#667EEA')
                .fontWeight(FontWeight.Bold)
                .margin({ top: 4, bottom: 4 })
                .animation({ duration: 300 })
            }

            Text(this.isEncrypting ? '密文字符' : '明文字符')
              .fontSize(12)
              .fontColor('#999')
              .alignSelf(ItemAlign.Start)
            Row({ space: 6 }) {
              ForEach(this.plaintext.split(''), (_ch: string, idx: number) => {
                Column() {
                  Text(this.resultChars.length > idx ? this.resultChars[idx] : '?')
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.resultChars.length > idx && this.resultChars[idx] !== '' ? '#FFFFFF' : '#CCCCCC')
                }
                .width(40)
                .height(40)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.resultChars.length > idx && this.resultChars[idx] !== '' ? '#667EEA' : '#F0F0F0')
                .borderRadius(8)
                .opacity(this.resultChars.length > idx && this.resultChars[idx] !== '' ? 1 : 0.4)
                .animation({ duration: 400, curve: Curve.EaseOut })
              })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(`✅ ${this.isEncrypting ? '加密' : '解密'}完成`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#00B894')
              Text(`结果：${this.resultChars.join('')}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2D3436')
                .copyOption(CopyOptions.LocalDevice)
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#E8FFF5')
            .borderRadius(12)
            .animation({ duration: 400 })
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
          .backgroundColor(this.currentStep >= this.getMaxSteps() ? '#00B894' : '#667EEA')
          .fontColor('#FFFFFF')
          .layoutWeight(2)
          .enabled(this.currentStep < this.getMaxSteps())
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
