import { router } from '@kit.ArkUI'
import { CipherUtils, ShareUtils, AppColors, PageNavBar, PrincipleCard } from 'cipher'

@Entry
@Component
struct SharePage {
  @State algorithm: string = 'caesar'
  @State inputText: string = ''
  @State keyParam: string = '3'
  @State resultText: string = ''
  @State shareCode: string = ''
  @State importCode: string = ''
  @State importedAlgo: string = ''
  @State importedResult: string = ''
  @State hasImported: boolean = false

  private algoNames: string[] = ['caesar', 'vigenere', 'xor', 'base64', 'hill', 'otp']
  private algoLabels: string[] = ['凯撒密码', '维吉尼亚密码', 'XOR加密', 'Base64编码', 'Hill密码', '一次性密码本']

  encrypt() {
    let result = ''
    if (this.algorithm === 'caesar') {
      result = CipherUtils.caesarEncrypt(this.inputText, parseInt(this.keyParam) || 3)
    } else if (this.algorithm === 'vigenere') {
      result = CipherUtils.vigenereEncrypt(this.inputText, this.keyParam)
    } else if (this.algorithm === 'xor') {
      result = CipherUtils.xorEncrypt(this.inputText, this.keyParam)
    } else if (this.algorithm === 'base64') {
      result = CipherUtils.base64Encode(this.inputText)
    } else if (this.algorithm === 'hill') {
      const k = parseInt(this.keyParam) || 3
      result = CipherUtils.hillEncrypt(this.inputText, [[k, 5], [6, 7]])
    } else if (this.algorithm === 'otp') {
      result = CipherUtils.otpEncrypt(this.inputText, this.keyParam)
    }
    this.resultText = result
    this.shareCode = ShareUtils.encodeShareMessage(this.algorithm, this.keyParam, result)
  }

  importMessage() {
    const parts = ShareUtils.decodeShareMessage(this.importCode.trim())
    if (parts === null) {
      this.hasImported = false
      return
    }
    this.importedAlgo = parts[0]
    this.importedResult = parts[2]
    this.hasImported = true
  }

  private getAlgoIndex(): number {
    const idx = this.algoNames.indexOf(this.algorithm)
    return idx >= 0 ? idx : 0
  }

  build() {
    Column() {
      PageNavBar({ title: '加密分享', accentColor: AppColors.primary, onBack: (): void => router.back() })

      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() { this.shareContent() }
          .tabBar('生成分享码')
        TabContent() { this.importContent() }
          .tabBar('导入消息')
      }
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }

  @Builder
  shareContent() {
    Scroll() {
      Column({ space: 14 }) {
        PrincipleCard({
          accentColor: AppColors.primary,
          content: '将加密结果编码为分享码，发送给朋友后可在本应用中导入查看。分享码格式：CIPHERLAB:Base64编码数据。所有数据纯本地处理，不会上传到任何服务器。'
        })

        Column({ space: 12 }) {
          Row() {
            Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.primary).margin({ right: 8 })
            Text('加密设置').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
          }

          Row({ space: 8 }) {
            ForEach(this.algoNames, (name: string, idx: number) => {
              Text(this.algoLabels[idx]).fontSize(12)
                .fontWeight(this.algorithm === name ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.algorithm === name ? AppColors.textPrimary : AppColors.primary)
                .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                .backgroundColor(this.algorithm === name ? AppColors.primary : AppColors.bgSurface)
                .borderRadius(6)
                .onClick((): void => { this.algorithm = name })
            })
          }

          TextInput({ text: this.inputText, placeholder: '输入明文' })
            .width('100%').height(44).fontColor(AppColors.textPrimary)
            .backgroundColor(AppColors.bgSurfaceRaised).borderRadius(10)
            .onChange((v: string) => { this.inputText = v })

          if (this.algorithm !== 'base64') {
            TextInput({ text: this.keyParam, placeholder: '输入密钥' })
              .width('100%').height(44).fontColor(AppColors.textPrimary)
              .backgroundColor(AppColors.bgSurfaceRaised).borderRadius(10)
              .onChange((v: string) => { this.keyParam = v })
          }

          Button('加密并生成分享码').type(ButtonType.Capsule).height(44).width('100%')
            .backgroundColor(AppColors.primary).fontColor(AppColors.bgBase).fontSize(15)
            .enabled(this.inputText.length > 0)
            .onClick((): void => this.encrypt())
        }
        .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
        .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

        if (this.shareCode.length > 0) {
          Column({ space: 8 }) {
            Text('分享码').fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            Text(this.shareCode).fontSize(13).fontColor(AppColors.primary).fontFamily('monospace')
              .copyOption(CopyOptions.LocalDevice).wordBreak(WordBreak.BREAK_ALL)
            Text('长按或点击可复制分享码，发送给朋友即可导入').fontSize(11).fontColor(AppColors.textHint)
          }.width('100%').padding(16).backgroundColor(AppColors.bgSurface).borderRadius(12).animation({ duration: 400 })
        }
      }.padding(16)
    }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  importContent() {
    Scroll() {
      Column({ space: 14 }) {
        Column({ space: 12 }) {
          Row() {
            Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.primary).margin({ right: 8 })
            Text('导入分享码').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
          }

          TextArea({ text: this.importCode, placeholder: '粘贴 CIPHERLAB:... 分享码' })
            .width('100%').height(80).fontColor(AppColors.textPrimary)
            .backgroundColor(AppColors.bgSurfaceRaised).borderRadius(10)
            .onChange((v: string) => { this.importCode = v; this.hasImported = false })

          Button('导入').type(ButtonType.Capsule).height(44).width('100%')
            .backgroundColor(AppColors.primary).fontColor(AppColors.bgBase).fontSize(15)
            .enabled(this.importCode.length > 0)
            .onClick((): void => this.importMessage())
        }
        .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
        .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

        if (this.hasImported) {
          Column({ space: 8 }) {
            Text('\u2713 导入成功').fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppColors.success)
            Text(`算法：${this.importedAlgo}`).fontSize(14).fontColor(AppColors.textPrimary)
            Text(`加密结果：${this.importedResult}`).fontSize(14).fontColor(AppColors.primary)
              .copyOption(CopyOptions.LocalDevice)
          }.width('100%').padding(20).backgroundColor(AppColors.bgSurface).borderRadius(12).animation({ duration: 400 })
        } else if (this.importCode.length > 0 && !this.hasImported && this.importCode.startsWith('CIPHERLAB:')) {
          Text('分享码格式无效，请检查后重试').fontSize(13).fontColor(AppColors.danger)
        }
      }.padding(16)
    }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
  }
}