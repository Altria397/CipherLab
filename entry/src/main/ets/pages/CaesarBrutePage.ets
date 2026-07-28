import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard } from 'cipher'

@Entry
@Component
struct CaesarBrutePage {
  @State inputText: string = ''
  @State hasBruted: boolean = false
  @State results: string[] = []
  @State highlightedShift: number = -1

  bruteForce() {
    this.results = CipherUtils.caesarBruteForce(this.inputText)
    this.hasBruted = true
    this.highlightedShift = -1
  }

  build() {
    Column() {
      PageNavBar({ title: '凯撒暴力破解', accentColor: AppColors.caesar, onBack: (): void => router.back() })

      Scroll() {
        Column({ space: 14 }) {
          PrincipleCard({
            accentColor: AppColors.caesar,
            content: '凯撒密码只有26种可能的密钥（位移0-25），因此可以穷举所有可能并逐一展示。通过人工识别有意义的明文，即可确定正确的密钥。这是最基础的已知明文攻击方法。'
          })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.caesar).margin({ right: 8 })
              Text('输入密文').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }
            TextArea({ text: this.inputText, placeholder: '输入凯撒加密的密文...' })
              .width('100%').height(80).fontColor(AppColors.textPrimary)
              .backgroundColor('#F0F1F5').borderRadius(10)
              .onChange((v: string) => { this.inputText = v; this.hasBruted = false })
            Button('暴力破解').type(ButtonType.Capsule).height(44).width('100%')
              .backgroundColor(AppColors.caesar).fontColor('#FFFFFF').fontSize(15)
              .enabled(this.inputText.length > 0)
              .onClick((): void => this.bruteForce())
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          if (this.hasBruted) {
            Column({ space: 12 }) {
              Row() {
                Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.caesar).margin({ right: 8 })
                Text('破解结果（26种位移）').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
              }

              ForEach(this.results, (result: string, idx: number) => {
                Row({ space: 10 }) {
                  Text(`${idx}`).width(28).fontSize(13).fontWeight(FontWeight.Bold)
                    .fontColor(this.highlightedShift === idx ? '#FFFFFF' : AppColors.caesar)
                    .textAlign(TextAlign.Center)
                  Text(result).fontSize(13).fontColor(AppColors.textPrimary)
                    .layoutWeight(1).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                  if (this.highlightedShift !== idx) {
                    Text('选择').fontSize(12).fontColor(AppColors.caesar)
                      .onClick((): void => { this.highlightedShift = idx })
                  }
                }.width('100%').padding(10).borderRadius(8)
                .backgroundColor(this.highlightedShift === idx ? AppColors.caesar : '#F8F9FA')
                .animation({ duration: 200 })
              })
            }
            .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
            .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

            if (this.highlightedShift >= 0) {
              Column({ space: 8 }) {
                Text(`\u2713 选定位移量：${this.highlightedShift}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppColors.success)
                Text(`明文：${this.results[this.highlightedShift]}`).fontSize(15).fontColor(AppColors.textPrimary)
                  .copyOption(CopyOptions.LocalDevice)
              }.width('100%').padding(20).backgroundColor('#E8FFF5').borderRadius(12).animation({ duration: 400 })
            }
          }
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }
}