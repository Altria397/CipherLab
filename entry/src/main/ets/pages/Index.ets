import { router } from '@kit.ArkUI'

interface AlgoCard {
  name: string
  desc: string
  icon: string
  route: string
  color1: string
  color2: string
}

@Entry
@Component
struct Index {
  @State currentTab: number = 0
  @State cardScales: number[] = [1, 1, 1, 1, 1, 1]

  private algorithms: AlgoCard[] = [
    { name: '凯撒密码', desc: '经典字母位移加密', icon: '🏛️', route: 'pages/CaesarPage', color1: '#667EEA', color2: '#764BA2' },
    { name: '维吉尼亚密码', desc: '多表替换加密', icon: '📜', route: 'pages/VigenerePage', color1: '#F093FB', color2: '#F5576C' },
    { name: 'Enigma 密码机', desc: '二战转子加密机', icon: '⚙️', route: 'pages/EnigmaPage', color1: '#8B5A2B', color2: '#D4A574' },
    { name: 'XOR 加密', desc: '异或位运算加密', icon: '⚡', route: 'pages/XorPage', color1: '#4FACFE', color2: '#00F2FE' },
    { name: 'Base64 编码', desc: '二进制到文本编码', icon: '🔤', route: 'pages/Base64Page', color1: '#43E97B', color2: '#38F9D7' },
    { name: 'RSA 加密', desc: '非对称加密原理', icon: '🔐', route: 'pages/RsaPage', color1: '#FA709A', color2: '#FEE140' }
  ]

  @Builder
  tabBarBuilder(title: string, icon: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(22)
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTab === index ? '#667EEA' : '#999999')
        .margin({ top: 2 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          this.labContent()
        }
        .tabBar(this.tabBarBuilder('算法实验室', '🔬', 0))

        TabContent() {
          this.customContent()
        }
        .tabBar(this.tabBarBuilder('自定义加密', '✏️', 1))
      }
      .barHeight(60)
      .onChange((index: number) => {
        this.currentTab = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

  @Builder
  labContent() {
    Scroll() {
      Column() {
        Column() {
          Text('🔬 CipherLab')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('加密算法实验室')
            .fontSize(16)
            .fontColor('#FFFFFFCC')
            .margin({ top: 4 })
          Text('交互式动画演示，逐步理解加密原理')
            .fontSize(13)
            .fontColor('#FFFFFF99')
            .margin({ top: 8 })
          Text('所有数据仅存储在本地，不会上传云端')
            .fontSize(11)
            .fontColor('#FFFFFF66')
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ top: 50, bottom: 30, left: 24, right: 24 })
        .linearGradient({
          angle: 135,
          colors: [['#667EEA', 0], ['#764BA2', 1]]
        })
        .borderRadius({ bottomLeft: 24, bottomRight: 24 })

        Column({ space: 14 }) {
          ForEach(this.algorithms, (algo: AlgoCard, index: number) => {
            Row() {
              Column() {
                Text(algo.icon)
                  .fontSize(36)
              }
              .width(70)
              .height(70)
              .justifyContent(FlexAlign.Center)
              .borderRadius(18)
              .linearGradient({
                angle: 135,
                colors: [[algo.color1, 0], [algo.color2, 1]]
              })

              Column() {
                Text(algo.name)
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#2D3436')
                Text(algo.desc)
                  .fontSize(13)
                  .fontColor('#636E72')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16 })
              .layoutWeight(1)

              Text('→')
                .fontSize(20)
                .fontColor('#B2BEC3')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({ radius: 8, color: '#0000000A', offsetX: 0, offsetY: 2 })
            .scale({ x: this.cardScales[index], y: this.cardScales[index] })
            .onClick(() => {
              animateTo({ duration: 100 }, () => {
                this.cardScales[index] = 0.96
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
        .padding({ left: 16, right: 16, top: 20, bottom: 30 })
      }
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  customContent() {
    Column() {
      Column() {
        Text('✏️ 自定义加密')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('创建和管理你的加密方法')
          .fontSize(14)
          .fontColor('#FFFFFFCC')
          .margin({ top: 4 })
        Text('支持加密链组合，数据仅本地存储')
          .fontSize(11)
          .fontColor('#FFFFFF66')
          .margin({ top: 6 })
      }
      .width('100%')
      .padding({ top: 50, bottom: 30, left: 24, right: 24 })
      .linearGradient({
        angle: 135,
        colors: [['#F093FB', 0], ['#F5576C', 1]]
      })
      .borderRadius({ bottomLeft: 24, bottomRight: 24 })

      Column() {
        Button('管理自定义加密方法')
          .type(ButtonType.Capsule)
          .width('80%')
          .height(48)
          .fontSize(16)
          .backgroundColor('#667EEA')
          .margin({ top: 30 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/CustomCipherPage' })
          })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .padding({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }
}
