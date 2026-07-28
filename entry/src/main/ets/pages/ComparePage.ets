import { router } from '@kit.ArkUI'
import { AppColors, PageNavBar } from 'cipher'

interface AlgoCompare {
  name: string
  type: string
  keySpace: string
  security: string
  speed: string
  useCase: string
  color: string
}

@Entry
@Component
struct ComparePage {
  private algorithms: AlgoCompare[] = [
    { name: '凯撒密码', type: '单表替换', keySpace: '25', security: '极低', speed: '极快', useCase: '教学演示', color: AppColors.caesar },
    { name: '维吉尼亚密码', type: '多表替换', keySpace: '26^n', security: '低-中', speed: '快', useCase: '历史密码', color: AppColors.vigenere },
    { name: 'Hill密码', type: '矩阵替换', keySpace: '可变', security: '低', speed: '中等', useCase: '线性代数教学', color: AppColors.hill },
    { name: 'XOR加密', type: '流密码', keySpace: '2^n', security: '低(密钥复用)', speed: '极快', useCase: '基础位运算', color: AppColors.xor },
    { name: '一次性密码本', type: '流密码', keySpace: '无限', security: '完美保密', speed: '极快', useCase: '理论极限', color: AppColors.otp },
    { name: 'Enigma', type: '转子替换', keySpace: '~10^16', security: '中(已被破)', speed: '慢', useCase: '二战通信', color: AppColors.enigma },
    { name: 'RSA', type: '非对称', keySpace: '2^2048+', security: '高', speed: '慢', useCase: '密钥交换/签名', color: AppColors.rsa },
    { name: 'Diffie-Hellman', type: '密钥交换', keySpace: '2^2048+', security: '高', speed: '慢', useCase: '协商共享密钥', color: AppColors.dh },
    { name: '哈希函数', type: '单向函数', keySpace: 'N/A', security: '高(抗碰撞)', speed: '快', useCase: '完整性校验', color: AppColors.hash },
    { name: 'Base64', type: '编码', keySpace: 'N/A', security: '无(非加密)', speed: '极快', useCase: '数据传输', color: AppColors.base64 }
  ]

  private getSecurityColor(security: string): string {
    if (security.startsWith('高') || security.startsWith('完美')) return AppColors.success
    if (security.startsWith('中')) return AppColors.warning
    if (security.startsWith('低')) return AppColors.danger
    return AppColors.textHint
  }

  build() {
    Column() {
      PageNavBar({ title: '算法对比', accentColor: AppColors.primary, onBack: (): void => router.back() })

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 8 }) {
            Text('加密算法对比总览').fontSize(18).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            Text('从安全性、速度、密钥空间等维度对比各算法特点').fontSize(13).fontColor(AppColors.textSecondary)
          }.width('100%').padding({ top: 16, bottom: 8 })

          ForEach(this.algorithms, (algo: AlgoCompare) => {
            Column({ space: 8 }) {
              Row({ space: 8 }) {
                Column().width(4).height(20).borderRadius(2).backgroundColor(algo.color)
                Text(algo.name).fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                Text(algo.type).fontSize(11).fontColor(AppColors.textPrimary)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor(algo.color).borderRadius(4)
              }

              Row({ space: 16 }) {
                Column({ space: 2 }) {
                  Text('安全性').fontSize(11).fontColor(AppColors.textHint)
                  Text(algo.security).fontSize(13).fontWeight(FontWeight.Bold)
                    .fontColor(this.getSecurityColor(algo.security))
                }.layoutWeight(1)

                Column({ space: 2 }) {
                  Text('速度').fontSize(11).fontColor(AppColors.textHint)
                  Text(algo.speed).fontSize(13).fontColor(AppColors.textPrimary)
                }.layoutWeight(1)

                Column({ space: 2 }) {
                  Text('密钥空间').fontSize(11).fontColor(AppColors.textHint)
                  Text(algo.keySpace).fontSize(13).fontColor(AppColors.textPrimary)
                }.layoutWeight(1)
              }

              Row({ space: 4 }) {
                Text('应用：').fontSize(12).fontColor(AppColors.textHint)
                Text(algo.useCase).fontSize(12).fontColor(AppColors.textSecondary)
              }
            }
            .width('100%').padding(14).backgroundColor(AppColors.bgCard).borderRadius(12)
            .border({ width: 1, color: AppColors.borderHairline })
          })
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }
}