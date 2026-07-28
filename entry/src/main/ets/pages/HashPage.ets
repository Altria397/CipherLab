import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard } from 'cipher'

@Entry
@Component
struct HashPage {
  @State input1: string = 'Hello'
  @State input2: string = 'Hello'
  @State hashResult1: string = ''
  @State hashResult2: string = ''
  @State hasComputed: boolean = false
  @State showAvalanche: boolean = false
  @State avalancheInput1: string = 'Hello'
  @State avalancheInput2: string = 'Hellp'
  @State avalancheHash1: string = ''
  @State avalancheHash2: string = ''
  @State currentTab: number = 0

  build() {
    Column() {
      PageNavBar({ title: '哈希函数', accentColor: AppColors.hash, onBack: (): void => router.back() })

      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() { this.hashDemoContent() }
          .tabBar('哈希计算')
        TabContent() { this.avalancheContent() }
          .tabBar('雪崩效应')
      }
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => { this.currentTab = index })
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }

  @Builder
  hashDemoContent() {
    Scroll() {
      Column({ space: 14 }) {
        PrincipleCard({
          accentColor: AppColors.hash,
          content: '哈希函数将任意长度的输入映射为固定长度的输出（摘要）。它具有单向性（无法从摘要反推原文）和抗碰撞性（难以找到两个不同输入产生相同摘要）。常用于数据完整性校验和密码存储。'
        })

        Column({ space: 12 }) {
          Row() {
            Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.hash).margin({ right: 8 })
            Text('输入文本').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
          }
          TextInput({ text: this.input1, placeholder: '输入文本' })
            .width('100%').height(44).fontColor(AppColors.textPrimary)
            .backgroundColor(AppColors.bgSurfaceRaised).borderRadius(10)
            .onChange((v: string) => { this.input1 = v; this.hasComputed = false })
          Button('计算哈希').type(ButtonType.Capsule).height(44).width('100%')
            .backgroundColor(AppColors.hash).fontColor(AppColors.bgBase).fontSize(15)
            .onClick((): void => {
              this.hashResult1 = CipherUtils.simpleHash(this.input1, 'sha-like')
              this.hasComputed = true
            })
        }
        .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
        .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

        if (this.hasComputed) {
          Column({ space: 8 }) {
            Text('哈希结果').fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            Text(this.hashResult1).fontSize(14).fontColor(AppColors.hash).fontWeight(FontWeight.Medium)
              .fontFamily('monospace').copyOption(CopyOptions.LocalDevice)
              .wordBreak(WordBreak.BREAK_ALL)
          }.width('100%').padding(16).backgroundColor(AppColors.bgSurface).borderRadius(12).animation({ duration: 400 })
        }

        Column({ space: 12 }) {
          Row() {
            Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.hash).margin({ right: 8 })
            Text('对比验证').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
          }
          TextInput({ text: this.input2, placeholder: '输入另一个文本对比' })
            .width('100%').height(44).fontColor(AppColors.textPrimary)
            .backgroundColor(AppColors.bgSurfaceRaised).borderRadius(10)
            .onChange((v: string) => { this.input2 = v })
          Button('计算并对比').type(ButtonType.Capsule).height(44).width('100%')
            .backgroundColor(AppColors.hash).fontColor(AppColors.bgBase).fontSize(15)
            .onClick((): void => {
              this.hashResult2 = CipherUtils.simpleHash(this.input2, 'sha-like')
            })
          if (this.hashResult2.length > 0) {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text('文本1').fontSize(12).fontColor(AppColors.textHint)
                Text(this.hashResult1).fontSize(12).fontColor(AppColors.hash).fontFamily('monospace')
                  .wordBreak(WordBreak.BREAK_ALL)
              }.layoutWeight(1).padding(10).backgroundColor(AppColors.bgSurface).borderRadius(8)
              Column({ space: 4 }) {
                Text('文本2').fontSize(12).fontColor(AppColors.textHint)
                Text(this.hashResult2).fontSize(12).fontColor(AppColors.hash).fontFamily('monospace')
                  .wordBreak(WordBreak.BREAK_ALL)
              }.layoutWeight(1).padding(10).backgroundColor(AppColors.bgSurface).borderRadius(8)
            }
            if (this.input1 === this.input2) {
              Text('相同输入 \u2192 相同哈希 \u2713').fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.success)
            } else {
              Text('不同输入 \u2192 完全不同的哈希').fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.hash)
            }
          }
        }
        .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
        .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      }.padding(16)
    }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  avalancheContent() {
    Scroll() {
      Column({ space: 14 }) {
        PrincipleCard({
          accentColor: AppColors.hash,
          content: '雪崩效应是哈希函数的重要特性：输入的微小变化（哪怕只改1个字符）会导致输出发生巨大变化。这是哈希函数安全性的基础，使得攻击者无法通过输入的微小变化来预测输出的变化。'
        })

        Column({ space: 12 }) {
          Row() {
            Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.hash).margin({ right: 8 })
            Text('雪崩效应演示').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
          }
          Row({ space: 12 }) {
            Column({ space: 4 }) {
              Text('输入 A').fontSize(12).fontColor(AppColors.textHint)
              TextInput({ text: this.avalancheInput1 }).width('100%').height(40).fontColor(AppColors.textPrimary)
                .backgroundColor(AppColors.bgSurfaceRaised).borderRadius(8)
                .onChange((v: string) => { this.avalancheInput1 = v; this.showAvalanche = false })
            }.layoutWeight(1)
            Column({ space: 4 }) {
              Text('输入 B').fontSize(12).fontColor(AppColors.textHint)
              TextInput({ text: this.avalancheInput2 }).width('100%').height(40).fontColor(AppColors.textPrimary)
                .backgroundColor(AppColors.bgSurfaceRaised).borderRadius(8)
                .onChange((v: string) => { this.avalancheInput2 = v; this.showAvalanche = false })
            }.layoutWeight(1)
          }

          Button('对比哈希').type(ButtonType.Capsule).height(44).width('100%')
            .backgroundColor(AppColors.hash).fontColor(AppColors.bgBase).fontSize(15)
            .onClick((): void => {
              this.avalancheHash1 = CipherUtils.simpleHash(this.avalancheInput1, 'sha-like')
              this.avalancheHash2 = CipherUtils.simpleHash(this.avalancheInput2, 'sha-like')
              this.showAvalanche = true
            })

          if (this.showAvalanche) {
            Column({ space: 8 }) {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(`"${this.avalancheInput1}"`).fontSize(13).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                  Text(this.avalancheHash1).fontSize(12).fontColor(AppColors.hash).fontFamily('monospace')
                    .wordBreak(WordBreak.BREAK_ALL)
                }.layoutWeight(1).padding(10).backgroundColor(AppColors.bgSurface).borderRadius(8)
                Column({ space: 4 }) {
                  Text(`"${this.avalancheInput2}"`).fontSize(13).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                  Text(this.avalancheHash2).fontSize(12).fontColor(AppColors.hash).fontFamily('monospace')
                    .wordBreak(WordBreak.BREAK_ALL)
                }.layoutWeight(1).padding(10).backgroundColor(AppColors.bgSurface).borderRadius(8)
              }

              Text(`仅改变了输入的微小差异，哈希值有 ${this.countHexDiff(this.avalancheHash1, this.avalancheHash2)}/${Math.max(this.avalancheHash1.length, this.avalancheHash2.length)} 个字符不同（${Math.max(this.avalancheHash1.length, this.avalancheHash2.length) > 0 ? Math.round(this.countHexDiff(this.avalancheHash1, this.avalancheHash2) / Math.max(this.avalancheHash1.length, this.avalancheHash2.length) * 100) : 0}% 差异）`)
                .fontSize(13).fontColor(AppColors.textSecondary).textAlign(TextAlign.Center).lineHeight(20)
            }.width('100%').padding(14).backgroundColor(AppColors.bgSurfaceRaised).borderRadius(12).animation({ duration: 400 })
          }
        }
        .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
        .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      }.padding(16)
    }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
  }

  private countHexDiff(h1: string, h2: string): number {
    let count = 0
    const len = Math.min(h1.length, h2.length)
    for (let i = 0; i < len; i++) {
      if (h1.charAt(i) !== h2.charAt(i)) count++
    }
    return count + Math.abs(h1.length - h2.length)
  }
}