import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard } from 'cipher'

@Entry
@Component
struct KasiskiPage {
  @State inputText: string = ''
  @State hasAnalyzed: boolean = false
  @State likelyLengths: number[] = []
  @State icValue: string = ''
  @State selectedLength: number = 0
  @State columnICs: string[] = []

  analyze() {
    this.likelyLengths = CipherUtils.kasiskiExamination(this.inputText)
    const ic = CipherUtils.indexOfCoincidence(this.inputText)
    this.icValue = ic.toFixed(4)
    this.selectedLength = 0
    this.columnICs = []
    this.hasAnalyzed = true
  }

  analyzeColumns(keyLen: number) {
    this.selectedLength = keyLen
    this.columnICs = []
    const upper = this.inputText.toUpperCase().replace(/[^A-Z]/g, '')
    for (let col = 0; col < keyLen; col++) {
      let columnText = ''
      for (let i = col; i < upper.length; i += keyLen) {
        columnText += upper.charAt(i)
      }
      const ic = CipherUtils.indexOfCoincidence(columnText)
      this.columnICs.push(ic.toFixed(4))
    }
  }

  private getICBarWidth(icStr: string): Length {
    return `${Math.min(parseFloat(icStr) / 0.1 * 100, 100)}%`
  }

  build() {
    Column() {
      PageNavBar({ title: 'Kasiski 测试', accentColor: AppColors.vigenere, onBack: (): void => router.back() })

      Scroll() {
        Column({ space: 14 }) {
          PrincipleCard({
            accentColor: AppColors.vigenere,
            content: 'Kasiski测试用于破解维吉尼亚密码。它通过查找密文中重复的子串（长度3-5），计算重复间距的公因子来推测密钥长度。确定密钥长度后，将密文分成若干组，每组的重合指数应接近英语的0.0667，从而验证推测的密钥长度是否正确。'
          })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.vigenere).margin({ right: 8 })
              Text('输入密文').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }
            TextArea({ text: this.inputText, placeholder: '输入维吉尼亚加密的密文（建议50字符以上）...' })
              .width('100%').height(100).fontColor(AppColors.textPrimary)
              .backgroundColor('#F0F1F5').borderRadius(10)
              .onChange((v: string) => { this.inputText = v; this.hasAnalyzed = false })
            Button('Kasiski 分析').type(ButtonType.Capsule).height(44).width('100%')
              .backgroundColor(AppColors.vigenere).fontColor('#FFFFFF').fontSize(15)
              .enabled(this.inputText.length > 0)
              .onClick((): void => this.analyze())
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          if (this.hasAnalyzed) {
            Column({ space: 12 }) {
              Row() {
                Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.vigenere).margin({ right: 8 })
                Text('Kasiski 分析结果').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
              }

              Text(`整体重合指数 IC = ${this.icValue}`).fontSize(13).fontColor(AppColors.textSecondary)

              if (this.likelyLengths.length === 0) {
                Text('未找到足够的重复子串，请输入更长的密文').fontSize(13).fontColor(AppColors.warning)
              } else {
                Text('可能的密钥长度（按可能性排序）：').fontSize(13).fontColor(AppColors.textSecondary)

                Row({ space: 8 }) {
                  ForEach(this.likelyLengths, (len: number) => {
                    Text(`${len}`).fontSize(14).fontWeight(this.selectedLength === len ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(this.selectedLength === len ? '#FFFFFF' : AppColors.vigenere)
                      .width(40).height(34).textAlign(TextAlign.Center)
                      .backgroundColor(this.selectedLength === len ? AppColors.vigenere : '#F3EEFF')
                      .borderRadius(8).border({ width: 1, color: AppColors.vigenere })
                      .onClick((): void => this.analyzeColumns(len))
                  })
                }
              }
            }
            .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
            .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

            if (this.selectedLength > 0 && this.columnICs.length > 0) {
              Column({ space: 12 }) {
                Row() {
                  Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.vigenere).margin({ right: 8 })
                  Text(`密钥长度 ${this.selectedLength} 的分组 IC`).fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                }

                Text('每列IC接近0.0667说明该密钥长度可能是正确的').fontSize(12).fontColor(AppColors.textHint)

                ForEach(this.columnICs, (icStr: string, idx: number) => {
                  Row({ space: 8 }) {
                    Text(`第${idx + 1}列`).width(45).fontSize(13).fontColor(AppColors.textSecondary)
                    Row() {
                      Row().width(this.getICBarWidth(icStr))
                        .height(16).backgroundColor(parseFloat(icStr) > 0.06 ? AppColors.success : AppColors.vigenere)
                        .borderRadius(4)
                    }.layoutWeight(1).height(16).backgroundColor('#F0F1F5').borderRadius(4)
                    Text(icStr).width(50).fontSize(12).fontColor(AppColors.textSecondary).textAlign(TextAlign.End)
                    if (parseFloat(icStr) > 0.06 && parseFloat(icStr) < 0.08) {
                      Text('\u2713').fontSize(14).fontColor(AppColors.success)
                    }
                  }.width('100%')
                })
              }
              .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
              .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })
            }
          }
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }
}