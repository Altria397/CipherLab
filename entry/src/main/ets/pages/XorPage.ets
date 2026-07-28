import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar } from 'cipher'

@Entry
@Component
struct XorPage {
  @State plaintext: string = 'Hi'
  @State secretKey: string = 'K'
  @State currentStep: number = -1
  @State showResult: boolean = false
  @State processedBits: boolean[][] = []
  @State resultHex: string[] = []
  @State isEncrypting: boolean = true

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
    this.processedBits = []
    this.resultHex = []
    for (let i = 0; i < this.plaintext.length; i++) {
      this.processedBits.push([false, false, false, false, false, false, false, false])
      this.resultHex.push('')
    }
  }

  nextStep() {
    if (this.currentStep >= this.getMaxSteps()) return
    this.currentStep++
    if (this.currentStep === 0) {
      this.showResult = false
      this.processedBits = []
      this.resultHex = []
      for (let i = 0; i < this.plaintext.length; i++) {
        this.processedBits.push([false, false, false, false, false, false, false, false])
        this.resultHex.push('')
      }
    } else if (this.currentStep >= 1 && this.currentStep <= this.plaintext.length) {
      const idx = this.currentStep - 1
      const charCode = this.plaintext.charCodeAt(idx)
      const keyCode = this.secretKey.charCodeAt(idx % this.secretKey.length)
      const xored = charCode ^ keyCode
      this.resultHex[idx] = xored.toString(16).padStart(2, '0').toUpperCase()
      for (let b = 0; b < 8; b++) {
        this.processedBits[idx][b] = true
      }
    } else {
      this.showResult = true
    }
  }

  getBinary(ch: string): string {
    return CipherUtils.toBinary(ch.charCodeAt(0), 8)
  }

  getXorResult(idx: number): string {
    const charCode = this.plaintext.charCodeAt(idx)
    const keyCode = this.secretKey.charCodeAt(idx % this.secretKey.length)
    return CipherUtils.toBinary(charCode ^ keyCode, 8)
  }

  build() {
    Column() {
      PageNavBar({
        title: 'XOR 加密',
        accentColor: AppColors.xor,
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
              .fontColor('#4FACFE')
            Text('XOR（异或）加密将明文的每个字节与密钥的对应字节进行异或运算。相同位为0，不同位为1。XOR加密的特性：对密文再次XOR同一密钥即可解密，因此加密和解密操作完全相同。')
              .fontSize(13)
              .fontColor('#636E72')
              .lineHeight(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F0F8FF')
          .borderRadius(12)

          Column({ space: 12 }) {
            Text('输入设置')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)
            TextInput({ text: this.plaintext, placeholder: this.isEncrypting ? '输入明文' : '输入HEX密文（如4869）' })
              .width('100%')
              .height(44)
              .fontColor(AppColors.textPrimary)
              .backgroundColor('#F5F6FA')
              .borderRadius(10)
              .onChange((val: string) => {
                this.plaintext = val
                this.resetAnimation()
              })
            TextInput({ text: this.secretKey, placeholder: '输入密钥' })
              .width('100%')
              .height(44)
              .fontColor(AppColors.textPrimary)
              .backgroundColor('#F5F6FA')
              .borderRadius(10)
              .onChange((val: string) => {
                this.secretKey = val
                this.resetAnimation()
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

          Column({ space: 16 }) {
            Text('逐字节 XOR 演示')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
              .alignSelf(ItemAlign.Start)

            ForEach(this.plaintext.split(''), (ch: string, idx: number) => {
              if (this.currentStep >= 1 && idx < this.currentStep) {
                Column({ space: 6 }) {
                  Row() {
                    Text(`字符 '${ch}'`)
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#4FACFE')
                    Text(`(ASCII: ${ch.charCodeAt(0)})`)
                      .fontSize(11)
                      .fontColor('#999')
                      .margin({ left: 8 })
                  }

                  Row({ space: 2 }) {
                    Text('明文:')
                      .fontSize(11)
                      .fontColor('#999')
                      .width(40)
                    ForEach(this.getBinary(ch).split(''), (bit: string) => {
                      Text(bit)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#2D3436')
                        .width(24)
                        .height(24)
                        .textAlign(TextAlign.Center)
                        .backgroundColor('#F5F6FA')
                        .borderRadius(4)
                    })
                  }

                  Row({ space: 2 }) {
                    Text('密钥:')
                      .fontSize(11)
                      .fontColor('#999')
                      .width(40)
                    ForEach(this.getBinary(this.secretKey.charAt(idx % this.secretKey.length)).split(''), (bit: string) => {
                      Text(bit)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#E17055')
                        .width(24)
                        .height(24)
                        .textAlign(TextAlign.Center)
                        .backgroundColor('#FFF3F0')
                        .borderRadius(4)
                    })
                  }

                  Row({ space: 2 }) {
                    Text('XOR:')
                      .fontSize(11)
                      .fontColor('#999')
                      .width(40)
                    ForEach(this.getXorResult(idx).split(''), (bit: string, bIdx: number) => {
                      Text(bit)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                        .width(24)
                        .height(24)
                        .textAlign(TextAlign.Center)
                        .backgroundColor(this.processedBits.length > idx && this.processedBits[idx][bIdx] ? '#4FACFE' : '#DDD')
                        .borderRadius(4)
                        .animation({ duration: 200, delay: bIdx * 50 })
                    })
                  }

                  Text(`结果: 0x${this.resultHex[idx]}`)
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#00B894')
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FAFBFF')
                .borderRadius(10)
                .border({
                  width: this.currentStep - 1 === idx ? 1.5 : 0,
                  color: '#4FACFE'
                })
                .animation({ duration: 400 })
              }
            })

            if (this.currentStep === 0) {
              Text('点击"下一步"开始逐字节异或运算')
                .fontSize(13)
                .fontColor('#999')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(20)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(`\u2713 XOR ${this.isEncrypting ? '加密' : '解密'}完成`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#00B894')
              Text(`密文 (HEX): ${this.resultHex.join(' ')}`)
                .fontSize(16)
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
          .backgroundColor(this.currentStep >= this.getMaxSteps() ? '#00B894' : '#4FACFE')
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
