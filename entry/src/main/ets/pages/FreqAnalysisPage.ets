import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard } from 'cipher'

@Entry
@Component
struct FreqAnalysisPage {
  @State inputText: string = ''
  @State hasAnalyzed: boolean = false
  @State freqData: string[] = []
  @State freqValues: number[] = []
  @State totalLetters: number = 0
  @State icValue: string = ''

  private readonly ENGLISH_FREQ: number[] = [
    8.167, 1.492, 2.782, 4.253, 12.702, 2.228, 2.015, 6.094, 6.966, 0.153,
    0.772, 4.025, 2.406, 6.749, 7.507, 1.929, 0.095, 5.987, 6.327, 9.056,
    2.758, 0.978, 2.360, 0.150, 1.974, 0.074
  ]

  analyze() {
    const freq = CipherUtils.frequencyAnalysis(this.inputText)
    this.freqData = []
    this.freqValues = []
    this.totalLetters = 0
    for (let i = 0; i < 26; i++) {
      const ch = String.fromCharCode(65 + i)
      const count = freq.get(ch) || 0
      this.freqData.push(ch)
      this.freqValues.push(count)
      this.totalLetters += count
    }
    const ic = CipherUtils.indexOfCoincidence(this.inputText)
    this.icValue = ic.toFixed(4)
    this.hasAnalyzed = true
  }

  private getBarHeight(count: number): number {
    if (this.totalLetters === 0) return 0
    const pct = (count / this.totalLetters) * 100
    return Math.max(pct * 2, 2)
  }

  private getBarWidth(count: number): Length {
    if (this.totalLetters === 0) return 0
    return `${(count / this.totalLetters) * 100}%`
  }

  build() {
    Column() {
      PageNavBar({ title: '频率分析', accentColor: AppColors.primary, onBack: (): void => router.back() })

      Scroll() {
        Column({ space: 14 }) {
          PrincipleCard({
            accentColor: AppColors.primary,
            content: '频率分析是密码分析的基础工具。英文字母在文本中出现的频率有固定规律（E最高约12.7%，Z最低约0.07%）。通过对比密文字母频率与标准英语频率，可以推断替换密码的密钥。重合指数（IC）接近0.0667说明是单表替换，远低于此值可能是多表替换。'
          })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.primary).margin({ right: 8 })
              Text('输入密文').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }
            TextArea({ text: this.inputText, placeholder: '输入需要分析的密文文本...' })
              .width('100%').height(100).fontColor(AppColors.textPrimary)
              .backgroundColor('#F0F1F5').borderRadius(10)
              .onChange((v: string) => { this.inputText = v; this.hasAnalyzed = false })
            Button('开始分析').type(ButtonType.Capsule).height(44).width('100%')
              .backgroundColor(AppColors.primary).fontColor('#FFFFFF').fontSize(15)
              .enabled(this.inputText.length > 0)
              .onClick((): void => this.analyze())
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          if (this.hasAnalyzed) {
            Column({ space: 12 }) {
              Row() {
                Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.primary).margin({ right: 8 })
                Text('分析结果').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
              }

              Text(`总字母数：${this.totalLetters}　　重合指数 IC = ${this.icValue}`).fontSize(13).fontColor(AppColors.textSecondary)

              if (parseFloat(this.icValue) > 0.06 && parseFloat(this.icValue) < 0.08) {
                Text('IC 接近 0.0667 → 可能是单表替换密码（凯撒/仿射）').fontSize(12).fontColor(AppColors.warning)
              } else if (parseFloat(this.icValue) < 0.05) {
                Text('IC 远低于 0.0667 → 可能是多表替换密码（维吉尼亚）').fontSize(12).fontColor(AppColors.warning)
              } else {
                Text('IC 在中间范围 → 需要更多分析').fontSize(12).fontColor(AppColors.textHint)
              }

              Column({ space: 4 }) {
                ForEach(this.freqData, (ch: string, idx: number) => {
                  Row({ space: 8 }) {
                    Text(ch).width(20).fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.primary).textAlign(TextAlign.Center)
                    Row() {
                      Row().width(this.getBarWidth(this.freqValues[idx]))
                        .height(16).backgroundColor(AppColors.primary).borderRadius(4)
                    }.layoutWeight(1).height(16).backgroundColor('#F0F1F5').borderRadius(4)
                    Text(`${this.freqValues[idx]}`).width(30).fontSize(12).fontColor(AppColors.textSecondary).textAlign(TextAlign.End)
                    Text(`${this.totalLetters > 0 ? ((this.freqValues[idx] / this.totalLetters) * 100).toFixed(1) : '0.0'}%`)
                      .width(45).fontSize(12).fontColor(AppColors.textHint).textAlign(TextAlign.End)
                    Text(`英: ${this.ENGLISH_FREQ[idx].toFixed(1)}%`).width(60).fontSize(11).fontColor(AppColors.textHint).textAlign(TextAlign.End)
                  }.width('100%')
                })
              }
            }
            .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
            .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })
          }
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }
}