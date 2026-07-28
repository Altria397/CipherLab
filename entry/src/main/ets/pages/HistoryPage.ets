import { router } from '@kit.ArkUI'
import { AppColors, PageNavBar } from 'cipher'

interface HistoryStory {
  title: string
  era: string
  color: string
  content: string
  lesson: string
}

@Entry
@Component
struct HistoryPage {
  private stories: HistoryStory[] = [
    {
      title: '凯撒密码与古罗马',
      era: '公元前50年',
      color: AppColors.caesar,
      content: '凯撒密码是最早的加密方法之一。尤利乌斯·凯撒在军事通信中使用字母位移3位的方法加密信息。虽然以今天的眼光看极其简单，但在当时足以防范不识字的拦截者。苏埃托尼乌斯在《凯撒传》中记录了这一方法。',
      lesson: '安全性取决于攻击者的能力——对古人有效的加密，对现代人可能形同虚设。'
    },
    {
      title: '维吉尼亚密码的兴衰',
      era: '16-19世纪',
      color: AppColors.vigenere,
      content: '维吉尼亚密码由16世纪的吉奥万·巴蒂斯塔·贝拉索首次描述，后因法国外交官布莱斯·维吉尼亚的推广而得名。它使用多个凯撒密码表交替加密，曾被称为"不可破译的密码"。直到1863年弗里德里希·卡西斯基发表了系统的破译方法（Kasiski测试），这一神话才被打破。',
      lesson: '没有绝对安全的密码——今天的"不可破译"可能只是尚未找到破绽。'
    },
    {
      title: 'Enigma与二战密码战',
      era: '1939-1945',
      color: AppColors.enigma,
      content: 'Enigma是纳粹德国使用的转子加密机，每天更换密钥设置，理论上有约1.58万亿种可能。波兰数学家马里安·雷杰夫斯基率先取得突破，后由英国布莱切利园的阿兰·图灵团队进一步破解。据估计，Enigma的破译使二战缩短了至少两年，拯救了数百万生命。',
      lesson: '密码学不仅是数学问题，更关乎人类命运。图灵的贡献改变了历史进程。'
    },
    {
      title: 'RSA与公钥密码革命',
      era: '1977年至今',
      color: AppColors.rsa,
      content: '1977年，MIT的Ron Rivest、Adi Shamir和Leonard Adleman发表了RSA算法，开创了公钥密码学时代。在此之前，通信双方必须事先共享密钥。RSA利用大数分解的计算困难性，让任何人都可以加密信息，但只有持有私钥的人才能解密——这彻底改变了数字通信的安全格局。',
      lesson: '好的密码系统基于数学难题，而非算法的保密。"公开算法，保密密钥"是现代密码学的核心原则。'
    },
    {
      title: 'Diffie-Hellman与密钥交换',
      era: '1976年至今',
      color: AppColors.dh,
      content: '1976年，Whitfield Diffie和Martin Hellman发表了"密码学新方向"论文，提出了公钥密码学的概念和Diffie-Hellman密钥交换协议。这是密码学史上最具影响力的论文之一，让互不相识的双方能在不安全信道上协商出共享密钥，为后来的SSL/TLS等安全协议奠定了基础。',
      lesson: '创新往往来自打破思维定式——谁说必须先共享密钥才能安全通信？'
    },
    {
      title: '量子密码学的未来',
      era: '21世纪',
      color: AppColors.otp,
      content: '量子计算威胁着RSA等传统公钥密码——Shor算法能在多项式时间内分解大数。同时，量子密钥分发（QKD）利用量子力学原理实现理论上不可窃听的密钥交换。NIST已于2022年选定了首批后量子密码标准，密码学正在经历又一次范式转变。',
      lesson: '密码学永无止境——每次技术进步都既是威胁也是机遇。后量子密码学是下一个前沿。'
    }
  ]

  build() {
    Column() {
      PageNavBar({ title: '密码史话', accentColor: AppColors.warning, onBack: (): void => router.back() })

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('密码学简史').fontSize(22).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            Text('从古罗马到量子时代，密码学如何改变世界').fontSize(13).fontColor(AppColors.textSecondary)
          }.width('100%').padding({ top: 16, bottom: 8 })

          ForEach(this.stories, (story: HistoryStory) => {
            Column({ space: 10 }) {
              Row({ space: 8 }) {
                Column().width(4).height(24).borderRadius(2).backgroundColor(story.color)
                Column({ space: 2 }) {
                  Text(story.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                  Text(story.era).fontSize(12).fontColor(story.color)
                }
              }

              Text(story.content).fontSize(13).fontColor(AppColors.textSecondary).lineHeight(22)

              Row({ space: 6 }) {
                Text('启示：').fontSize(12).fontWeight(FontWeight.Bold).fontColor(story.color)
                Text(story.lesson).fontSize(12).fontColor(AppColors.textPrimary).layoutWeight(1).lineHeight(18)
              }.padding(10).backgroundColor(story.color + '10').borderRadius(8).width('100%')
            }
            .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
            .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })
          })
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }
}