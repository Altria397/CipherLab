import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar } from 'cipher'

@Entry
@Component
struct VigenerePage {
  @State plaintext: string = 'HELLO'
  @State secretKey: string = 'KEY'
  @State currentStep: number = -1
  @State resultChars: string[] = []
  @State showResult: boolean = false
  @State expandedKey: string[] = []
  @State isEncrypting: boolean = true

  private alphabet: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  private getMaxSteps(): number {
    return this.plaintext.length + 1
  }

  private getStepButtonText(): string {
    if (this.currentStep < 0) return '开始演示'
    if (this.currentStep >= this.getMaxSteps()) return '已完成'
    return '下一步 →'
  }

  resetAnimation() {
    this.currentStep = -1
    this.showResult = false
    this.resultChars = []
    this.expandedKey = []
    let ki = 0
    for (let i = 0; i < this.plaintext.length; i++) {
      const code = this.plaintext.charCodeAt(i)
      if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
        this.expandedKey.push(this.secretKey.charAt(ki % this.secretKey.length).toUpperCase())
        ki++
      } else {
        this.expandedKey.push('-')
      }
      this.resultChars.push('')
    }
  }

  nextStep() {
    if (this.currentStep >= this.getMaxSteps()) return
    this.currentStep++
    if (this.currentStep === 0) {
      this.showResult = false
      this.resultChars = []
      this.expandedKey = []
      let ki = 0
      for (let i = 0; i < this.plaintext.length; i++) {
        const code = this.plaintext.charCodeAt(i)
        if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
          this.expandedKey.push(this.secretKey.charAt(ki % this.secretKey.length).toUpperCase())
          ki++
        } else {
          this.expandedKey.push('-')
        }
        this.resultChars.push('')
      }
    } else if (this.currentStep >= 1 && this.currentStep <= this.plaintext.length) {
      const idx = this.currentStep - 1
      const ch = this.plaintext.charAt(idx)
      const code = ch.charCodeAt(0)
      if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
        this.resultChars[idx] = this.isEncrypting
          ? CipherUtils.vigenereEncryptChar(ch, this.expandedKey[idx])
          : CipherUtils.vigenereDecryptChar(ch, this.expandedKey[idx])
      } else {
        this.resultChars[idx] = ch
      }
    } else {
      this.showResult = true
    }
  }

  private buildCurrentStepDescription(): string {
    const i = this.currentStep - 1
    const plainCh = this.plaintext.charAt(i)
    const keyCh = this.expandedKey[i]
    const cipherCh = this.resultChars[i]
    const shift = keyCh.charCodeAt(0) - 65
    return `${this.isEncrypting ? '明文' : '密文'} '${plainCh}' + 密钥 '${keyCh}'(${this.isEncrypting ? '位移' : '反向位移'}${shift}) → '${cipherCh}'`
  }

  build() {
    Column() {
      PageNavBar({
        title: '维吉尼亚密码',
        accentColor: AppColors.vigenere,
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
              .fontColor('#F5576C')
            Text('维吉尼亚密码使用一个关键词，对每个字母使用不同的位移量进行加密。关键词循环使用，每个字母对应的位移量由关键词中相应字母决定。解密时反向位移即可。')
              .fontSize(13)
              .fontColor('#636E72')
              .lineHeight(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF0F3')
          .borderRadius(12)

          Column({ space: 12 }) {
            Text('输入设置')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)

            TextInput({ text: this.plaintext, placeholder: '输入文本' })
              .width('100%')
              .height(44)
              .fontColor(AppColors.textPrimary)
              .backgroundColor('#F5F6FA')
              .borderRadius(10)
              .onChange((val: string) => {
                this.plaintext = val.toUpperCase()
                this.resetAnimation()
              })

            TextInput({ text: this.secretKey, placeholder: '输入密钥' })
              .width('100%')
              .height(44)
              .fontColor(AppColors.textPrimary)
              .backgroundColor('#F5F6FA')
              .borderRadius(10)
              .onChange((val: string) => {
                this.secretKey = val.toUpperCase()
                this.resetAnimation()
              })
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

            Text(this.isEncrypting ? '明文' : '密文')
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
                      .fontColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? '#F5576C' : '#2D3436')
                  }
                  .width(36)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? '#FFF0F3' : '#F5F6FA')
                  .borderRadius(8)
                  .border({
                    width: this.currentStep >= 1 && this.currentStep - 1 === idx ? 2 : 0,
                    color: '#F5576C'
                  })
                  .scale({
                    x: this.currentStep >= 1 && this.currentStep - 1 === idx ? 1.15 : 1,
                    y: this.currentStep >= 1 && this.currentStep - 1 === idx ? 1.15 : 1
                  })
                  .animation({ duration: 300 })
                })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)

            if (this.currentStep >= 0) {
              Text('密钥（展开）')
                .fontSize(12)
                .fontColor('#999')
                .alignSelf(ItemAlign.Start)
              Scroll() {
                Row({ space: 4 }) {
                  ForEach(this.expandedKey, (k: string, idx: number) => {
                    Column() {
                      Text(k)
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? '#FFFFFF' : '#764BA2')
                    }
                    .width(36)
                    .height(36)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? '#764BA2' : '#F3EEFF')
                    .borderRadius(8)
                    .animation({ duration: 300 })
                  })
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
            }

            if (this.currentStep >= 1) {
              Column({ space: 4 }) {
                Text('当前步骤')
                  .fontSize(12)
                  .fontColor('#999')
                  .alignSelf(ItemAlign.Start)
                if (this.currentStep - 1 < this.plaintext.length) {
                  Text(this.buildCurrentStepDescription())
                    .fontSize(14)
                    .fontColor('#F5576C')
                    .fontWeight(FontWeight.Medium)
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#FFF0F3')
              .borderRadius(8)
              .animation({ duration: 300 })
            }

            Text(this.isEncrypting ? '密文' : '明文')
              .fontSize(12)
              .fontColor('#999')
              .alignSelf(ItemAlign.Start)
            Scroll() {
              Row({ space: 4 }) {
                ForEach(this.plaintext.split(''), (_ch: string, idx: number) => {
                  Column() {
                    Text(this.resultChars.length > idx && this.resultChars[idx] !== '' ? this.resultChars[idx] : '?')
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.resultChars.length > idx && this.resultChars[idx] !== '' ? '#FFFFFF' : '#CCC')
                  }
                  .width(36)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.resultChars.length > idx && this.resultChars[idx] !== '' ? '#F5576C' : '#F0F0F0')
                  .borderRadius(8)
                  .animation({ duration: 300 })
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

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(`\u2713 ${this.isEncrypting ? '加密' : '解密'}完成`)
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
          .backgroundColor(this.currentStep >= this.getMaxSteps() ? '#00B894' : '#F5576C')
          .fontColor('#FFFFFF')
          .layoutWeight(2)
          .enabled(this.currentStep < this.getMaxSteps() && this.secretKey.length > 0)
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
