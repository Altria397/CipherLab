import { router } from '@kit.ArkUI'
import { AppColors, AlgoIcon } from 'cipher'

interface AlgoCard {
  name: string
  desc: string
  algoKey: string
  route: string
  color: string
}

interface TabBarParam {
  title: string
  index: number
}

@Entry
@Component
struct Index {
  @State currentTab: number = 0
  @State cardScales: number[] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

  private algorithms: AlgoCard[] = [
    { name: '凯撒密码', desc: '经典字母位移加密', algoKey: 'caesar', route: 'pages/CaesarPage', color: AppColors.caesar },
    { name: '维吉尼亚密码', desc: '多表替换加密', algoKey: 'vigenere', route: 'pages/VigenerePage', color: AppColors.vigenere },
    { name: 'Enigma 密码机', desc: '二战转子加密机', algoKey: 'enigma', route: 'pages/EnigmaPage', color: AppColors.enigma },
    { name: 'Hill 密码', desc: '矩阵替换加密', algoKey: 'hill', route: 'pages/HillPage', color: AppColors.hill },
    { name: 'XOR 加密', desc: '异或位运算加密', algoKey: 'xor', route: 'pages/XorPage', color: AppColors.xor },
    { name: '一次性密码本', desc: '信息论完美保密', algoKey: 'otp', route: 'pages/OtpPage', color: AppColors.otp },
    { name: 'Base64 编码', desc: '二进制到文本编码', algoKey: 'base64', route: 'pages/Base64Page', color: AppColors.base64 },
    { name: 'RSA 加密', desc: '非对称加密原理', algoKey: 'rsa', route: 'pages/RsaPage', color: AppColors.rsa },
    { name: 'Diffie-Hellman', desc: '密钥交换协议', algoKey: 'dh', route: 'pages/DhPage', color: AppColors.dh },
    { name: '哈希函数', desc: '雪崩效应演示', algoKey: 'hash', route: 'pages/HashPage', color: AppColors.hash }
  ]

  private analysisTools: AlgoCard[] = [
    { name: '频率分析', desc: '字母频率统计与IC计算', algoKey: 'analysis', route: 'pages/FreqAnalysisPage', color: AppColors.analysis },
    { name: '凯撒暴力破解', desc: '26种位移穷举', algoKey: 'bruteForce', route: 'pages/CaesarBrutePage', color: AppColors.bruteForce },
    { name: 'Kasiski 测试', desc: '维吉尼亚密钥长度推测', algoKey: 'kasiski', route: 'pages/KasiskiPage', color: AppColors.kasiski }
  ]

  private eduTools: AlgoCard[] = [
    { name: '加密挑战', desc: '8道计算题检验你的理解', algoKey: 'challenge', route: 'pages/ChallengePage', color: AppColors.challenge },
    { name: '算法对比', desc: '多维度对比各算法特点', algoKey: 'compare', route: 'pages/ComparePage', color: AppColors.compare },
    { name: '密码史话', desc: '从古罗马到量子时代', algoKey: 'history', route: 'pages/HistoryPage', color: AppColors.history }
  ]

  private tab0: TabBarParam = { title: '算法', index: 0 }
  private tab1: TabBarParam = { title: '分析', index: 1 }
  private tab2: TabBarParam = { title: '学习', index: 2 }
  private tab3: TabBarParam = { title: '自定义', index: 3 }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          this.labContent()
        }
        .tabBar(this.tabBarBuilder(this.tab0))

        TabContent() {
          this.analysisContent()
        }
        .tabBar(this.tabBarBuilder(this.tab1))

        TabContent() {
          this.eduContent()
        }
        .tabBar(this.tabBarBuilder(this.tab2))

        TabContent() {
          this.customContent()
        }
        .tabBar(this.tabBarBuilder(this.tab3))
      }
      .barHeight(56)
      .barBackgroundColor(AppColors.bgCard)
      .onChange((index: number) => {
        this.currentTab = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgPage)
  }

  @Builder
  tabBarBuilder($$: TabBarParam) {
    Column() {
      Text($$.title)
        .fontSize(13)
        .fontWeight(this.currentTab === $$.index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTab === $$.index ? AppColors.primary : AppColors.textHint)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  labContent() {
    Column() {
      Row() {
        Blank().width(48)
        Text('CipherLab')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(48)
      }
      .width('100%')
      .padding({ top: 12, bottom: 8 })
      .backgroundColor(AppColors.bgCard)

      Scroll() {
        Column() {
          Column() {
            Text('加密算法实验室')
              .fontSize(15)
              .fontColor('#FFFFFFCC')
            Text('交互式动画演示 · 逐步理解加密原理 · 纯本地运行')
              .fontSize(12)
              .fontColor('#FFFFFF88')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ top: 20, bottom: 20, left: 24, right: 24 })
          .linearGradient({
            angle: 135,
            colors: [[AppColors.primary, 0], [AppColors.primaryDark, 1]]
          })
          .borderRadius({ bottomLeft: 24, bottomRight: 24 })

        Column({ space: 12 }) {
          ForEach(this.algorithms, (algo: AlgoCard, index: number) => {
            Row() {
              AlgoIcon({ algorithm: algo.algoKey, iconSize: 48 })

              Column() {
                Text(algo.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.textPrimary)
                Text(algo.desc)
                  .fontSize(13)
                  .fontColor(AppColors.textSecondary)
                  .margin({ top: 3 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 14 })
              .layoutWeight(1)

              Text('\u2192')
                .fontSize(18)
                .fontColor(AppColors.textHint)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 14, bottom: 14 })
            .backgroundColor(AppColors.bgCard)
            .borderRadius(14)
            .shadow({ radius: 6, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })
            .scale({ x: this.cardScales[index], y: this.cardScales[index] })
            .onClick(() => {
              animateTo({ duration: 100 }, () => {
                this.cardScales[index] = 0.97
              })
              setTimeout(() => {
                animateTo({ duration: 100 }, () => {
                  this.cardScales[index] = 1
                })
                router.pushUrl({ url: algo.route })
              }, 100)
            })
          })
        }
        .padding({ left: 16, right: 16, top: 18, bottom: 30 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  analysisContent() {
    Column() {
      Row() {
        Blank().width(48)
        Text('密码分析')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(48)
      }
      .width('100%')
      .padding({ top: 12, bottom: 8 })
      .backgroundColor(AppColors.bgCard)

      Scroll() {
        Column() {
          Column() {
            Text('破解加密的工具箱')
              .fontSize(15)
              .fontColor('#FFFFFFCC')
            Text('频率分析 · 暴力破解 · Kasiski测试')
              .fontSize(12)
              .fontColor('#FFFFFF88')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ top: 20, bottom: 20, left: 24, right: 24 })
          .linearGradient({
            angle: 135,
            colors: [[AppColors.analysis, 0], ['#0E6655', 1]]
          })
          .borderRadius({ bottomLeft: 24, bottomRight: 24 })

          Column({ space: 12 }) {
            ForEach(this.analysisTools, (tool: AlgoCard) => {
              Row() {
                AlgoIcon({ algorithm: tool.algoKey, iconSize: 48 })

                Column() {
                  Text(tool.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(AppColors.textPrimary)
                  Text(tool.desc)
                    .fontSize(13)
                    .fontColor(AppColors.textSecondary)
                    .margin({ top: 3 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 14 })
                .layoutWeight(1)

                Text('\u2192')
                  .fontSize(18)
                  .fontColor(AppColors.textHint)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 14, bottom: 14 })
              .backgroundColor(AppColors.bgCard)
              .borderRadius(14)
              .shadow({ radius: 6, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.pushUrl({ url: tool.route })
              })
            })
          }
          .padding({ left: 16, right: 16, top: 18, bottom: 30 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  eduContent() {
    Column() {
      Row() {
        Blank().width(48)
        Text('学习中心')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(48)
      }
      .width('100%')
      .padding({ top: 12, bottom: 8 })
      .backgroundColor(AppColors.bgCard)

      Scroll() {
        Column() {
          Column() {
            Text('挑战 · 对比 · 历史')
              .fontSize(15)
              .fontColor('#FFFFFFCC')
            Text('在实践中掌握密码学 · 了解密码学如何改变世界')
              .fontSize(12)
              .fontColor('#FFFFFF88')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ top: 20, bottom: 20, left: 24, right: 24 })
          .linearGradient({
            angle: 135,
            colors: [[AppColors.challenge, 0], ['#C0392B', 1]]
          })
          .borderRadius({ bottomLeft: 24, bottomRight: 24 })

          Column({ space: 12 }) {
            ForEach(this.eduTools, (tool: AlgoCard) => {
              Row() {
                AlgoIcon({ algorithm: tool.algoKey, iconSize: 48 })

                Column() {
                  Text(tool.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(AppColors.textPrimary)
                  Text(tool.desc)
                    .fontSize(13)
                    .fontColor(AppColors.textSecondary)
                    .margin({ top: 3 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 14 })
                .layoutWeight(1)

                Text('\u2192')
                  .fontSize(18)
                  .fontColor(AppColors.textHint)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 14, bottom: 14 })
              .backgroundColor(AppColors.bgCard)
              .borderRadius(14)
              .shadow({ radius: 6, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })
              .onClick(() => {
                router.pushUrl({ url: tool.route })
              })
            })
          }
          .padding({ left: 16, right: 16, top: 18, bottom: 30 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }

  @Builder
  customContent() {
    Column() {
      Row() {
        Blank().width(48)
        Text('自定义加密')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(48)
      }
      .width('100%')
      .padding({ top: 12, bottom: 8 })
      .backgroundColor(AppColors.bgCard)

      Scroll() {
        Column() {
          Column() {
            Text('创建和管理你的加密方法')
              .fontSize(15)
              .fontColor('#FFFFFFCC')
            Text('支持加密链组合 · 数据仅本地存储')
              .fontSize(12)
              .fontColor('#FFFFFF88')
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ top: 20, bottom: 20, left: 24, right: 24 })
          .linearGradient({
            angle: 135,
            colors: [['#9B59B6', 0], ['#8E44AD', 1]]
          })
          .borderRadius({ bottomLeft: 24, bottomRight: 24 })

          Column({ space: 12 }) {
            Button('管理自定义加密方法')
              .type(ButtonType.Capsule)
              .width('80%')
              .height(48)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(AppColors.primary)
              .margin({ top: 30 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/CustomCipherPage' })
              })

            Button('加密消息分享')
              .type(ButtonType.Capsule)
              .width('80%')
              .height(48)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#9B59B6')
              .margin({ top: 8 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/SharePage' })
              })
          }
          .padding({ top: 20 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgPage)
  }
}
