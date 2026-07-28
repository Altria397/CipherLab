import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard } from 'cipher'

@Entry
@Component
struct OtpPage {
  @State plaintext: string = 'HELLO'
  @State secretKey: string = 'XMCKL'
  @State currentStep: number = -1
  @State showResult: boolean = false
  @State resultChars: string[] = []
  @State isEncrypting: boolean = true

  private getMaxSteps(): number {
    return this.plaintext.length + 1
  }

  private getStepButtonText(): string {
    if (this.currentStep < 0) return '开始演示'
    if (this.currentStep >= this.getMaxSteps()) return '已完成'
    return '下一步 \u2192'
  }

  resetAnimation() {
    this.currentStep = -1
    this.showResult = false
    this.resultChars = []

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
    } else if (this.currentStep >= 1 && this.currentStep <= this.plaintext.length) {
      const idx = this.currentStep - 1
      const pChar = this.plaintext.charCodeAt(idx)
      const kChar = this.secretKey.charCodeAt(idx % this.secretKey.length)
      const result = String.fromCharCode(pChar ^ kChar)
      this.resultChars[idx] = result
    } else {
      this.showResult = true
    }
  }

  private isKeyValid(): boolean {
    return this.secretKey.length >= this.plaintext.length && this.secretKey.length > 0
  }

  build() {
    Column() {
      PageNavBar({
        title: '一次性密码本',
        accentColor: AppColors.otp,
        onBack: (): void => router.back(),
        rightText: this.isEncrypting ? '加密' : '解密',
        onRightClick: (): void => {
          this.isEncrypting = !this.isEncrypting
          this.resetAnimation()
        }
      })

      Scroll() {
        Column({ space: 14 }) {
          PrincipleCard({
            accentColor: AppColors.otp,
            content: '一次性密码本（OTP）是唯一被数学证明为"完美保密"的加密方法。密钥必须与明文等长、完全随机、且只用一次。加密和解密都使用XOR运算：明文\u2295密钥=密文，密文\u2295密钥=明文。密钥泄露则安全性归零。'
          })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.otp).margin({ right: 8 })
              Text('输入设置').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }
            TextInput({ text: this.plaintext, placeholder: '输入文本' })
              .width('100%').height(44).fontColor(AppColors.textPrimary)
              .backgroundColor('#F0F1F5').borderRadius(10)
              .onChange((v: string) => { this.plaintext = v; this.resetAnimation() })
            TextInput({ text: this.secretKey, placeholder: '输入密钥（须与文本等长）' })
              .width('100%').height(44).fontColor(AppColors.textPrimary)
              .backgroundColor('#F0F1F5').borderRadius(10)
              .onChange((v: string) => { this.secretKey = v; this.resetAnimation() })
            if (!this.isKeyValid() && this.secretKey.length > 0) {
              Text(`密钥长度须 \u2265 文本长度（当前密钥${this.secretKey.length}，文本${this.plaintext.length}）`)
                .fontSize(12).fontColor(AppColors.danger)
            }
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.otp).margin({ right: 8 })
              Text('逐字符 XOR 演示').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }

            Text('明文字符').fontSize(12).fontColor(AppColors.textHint).alignSelf(ItemAlign.Start)
            Scroll() {
              Row({ space: 4 }) {
                ForEach(this.plaintext.split(''), (ch: string, idx: number) => {
                  Column() {
                    Text(ch).fontSize(18).fontWeight(FontWeight.Bold)
                      .fontColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? AppColors.otp : AppColors.textPrimary)
                  }.width(36).height(36).justifyContent(FlexAlign.Center)
                  .backgroundColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? '#F3EEFF' : '#F0F1F5')
                  .borderRadius(8)
                  .border({ width: this.currentStep >= 1 && this.currentStep - 1 === idx ? 2 : 0, color: AppColors.otp })
                })
              }
            }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

            if (this.currentStep >= 0) {
              Text('密钥字符').fontSize(12).fontColor(AppColors.textHint).alignSelf(ItemAlign.Start)
              Scroll() {
                Row({ space: 4 }) {
                  ForEach(this.plaintext.split(''), (_ch: string, idx: number) => {
                    Column() {
                      Text(idx < this.secretKey.length ? this.secretKey.charAt(idx) : '-')
                        .fontSize(18).fontWeight(FontWeight.Bold)
                        .fontColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? '#FFFFFF' : AppColors.otp)
                    }.width(36).height(36).justifyContent(FlexAlign.Center)
                    .backgroundColor(this.currentStep >= 1 && this.currentStep - 1 === idx ? AppColors.otp : '#F3EEFF')
                    .borderRadius(8).animation({ duration: 300 })
                  })
                }
              }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
            }

            if (this.currentStep >= 1) {
              Text('XOR 结果').fontSize(12).fontColor(AppColors.textHint).alignSelf(ItemAlign.Start)
              Scroll() {
                Row({ space: 4 }) {
                  ForEach(this.resultChars, (ch: string, idx: number) => {
                    Column() {
                      Text(ch !== '' ? (ch.charCodeAt(0) >= 32 && ch.charCodeAt(0) < 127 ? ch : `\\x${ch.charCodeAt(0).toString(16).padStart(2, '0')}`) : '?')
                        .fontSize(16).fontWeight(FontWeight.Bold)
                        .fontColor(ch !== '' ? '#FFFFFF' : AppColors.textHint)
                    }.width(36).height(36).justifyContent(FlexAlign.Center)
                    .backgroundColor(ch !== '' ? AppColors.otp : '#F0F0F0')
                    .borderRadius(8).animation({ duration: 300 })
                  })
                }
              }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
            }
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(`\u2713 ${this.isEncrypting ? '加密' : '解密'}完成`)
                .fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppColors.success)
              Text('OTP特性：只要密钥真正随机且只用一次，即使攻击者有无限算力也无法破解')
                .fontSize(12).fontColor(AppColors.textSecondary).lineHeight(18)
            }.width('100%').padding(20).backgroundColor('#E8FFF5').borderRadius(12).animation({ duration: 400 })
          }
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

      Row({ space: 12 }) {
        Button('重置').type(ButtonType.Capsule).height(44)
          .backgroundColor('#F0F1F5').fontColor(AppColors.textSecondary).layoutWeight(1)
          .onClick((): void => this.resetAnimation())
        Button(this.getStepButtonText()).type(ButtonType.Capsule).height(44)
          .backgroundColor(this.currentStep >= this.getMaxSteps() ? AppColors.success : AppColors.otp)
          .fontColor('#FFFFFF').layoutWeight(2)
          .enabled(this.currentStep < this.getMaxSteps() && this.isKeyValid())
          .onClick((): void => this.nextStep())
      }.width('100%').padding({ left: 16, right: 16, top: 8, bottom: 16 }).backgroundColor(AppColors.bgPage)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }
}