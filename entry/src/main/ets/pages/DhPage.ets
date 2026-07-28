import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard } from 'cipher'

@Component
struct DhStepCard {
  @Prop step: number = 0
  @Prop title: string = ''
  @Prop stepContent: string = ''
  @Prop accentColor: string = '#000000'
  @Prop currentStep: number = -1

  build() {
    Row({ space: 8 }) {
      Text(`${this.step}`).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .width(24).height(24).textAlign(TextAlign.Center)
        .backgroundColor(this.currentStep > this.step ? AppColors.success : this.accentColor).borderRadius(12)
      Column({ space: 2 }) {
        Text(this.title).fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
        Text(this.stepContent).fontSize(13).fontColor(AppColors.textSecondary)
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
    }.width('100%').padding(12).backgroundColor('#F8F9FA').borderRadius(10)
    .border({ width: this.currentStep === this.step ? 1.5 : 0, color: this.accentColor }).animation({ duration: 400 })
  }
}

@Entry
@Component
struct DhPage {
  @State primeP: number = 23
  @State baseG: number = 5
  @State privateA: number = 6
  @State privateB: number = 15
  @State currentStep: number = -1
  @State showResult: boolean = false
  @State publicA: number = 0
  @State publicB: number = 0
  @State sharedA: number = 0
  @State sharedB: number = 0

  private primes: number[] = [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

  private getMaxSteps(): number { return 6 }

  private getStepButtonText(): string {
    if (this.currentStep < 0) return '开始演示'
    if (this.currentStep >= this.getMaxSteps()) return '已完成'
    return '下一步 \u2192'
  }

  resetAnimation() {
    this.currentStep = -1
    this.showResult = false
    this.publicA = 0; this.publicB = 0
    this.sharedA = 0; this.sharedB = 0
  }

  nextStep() {
    if (this.currentStep >= this.getMaxSteps()) return
    this.currentStep++
    switch (this.currentStep) {
      case 1: break
      case 2: this.publicA = CipherUtils.diffieHellmanComputePublic(this.baseG, this.privateA, this.primeP); break
      case 3: this.publicB = CipherUtils.diffieHellmanComputePublic(this.baseG, this.privateB, this.primeP); break
      case 4: break
      case 5:
        this.sharedA = CipherUtils.diffieHellmanComputeShared(this.publicB, this.privateA, this.primeP)
        this.sharedB = CipherUtils.diffieHellmanComputeShared(this.publicA, this.privateB, this.primeP)
        break
      case 6: this.showResult = true; break
    }
  }

  build() {
    Column() {
      PageNavBar({ title: 'Diffie-Hellman', accentColor: AppColors.dh, onBack: (): void => router.back() })

      Scroll() {
        Column({ space: 14 }) {
          PrincipleCard({
            accentColor: AppColors.dh,
            content: 'Diffie-Hellman密钥交换让双方在不安全信道上协商出共享密钥。双方各自生成私钥，计算公钥后交换，再用自己的私钥和对方的公钥计算出相同的共享密钥。窃听者只能看到公钥，无法推算出共享密钥。'
          })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.dh).margin({ right: 8 })
              Text('参数设置').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }
            Row() {
              Text('质数 p：').fontSize(14).fontColor(AppColors.textSecondary)
              Scroll() {
                Row({ space: 6 }) {
                  ForEach(this.primes, (p: number) => {
                    Text(`${p}`).fontSize(14)
                      .fontWeight(this.primeP === p ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(this.primeP === p ? '#FFFFFF' : AppColors.dh)
                      .width(38).height(34).textAlign(TextAlign.Center)
                      .backgroundColor(this.primeP === p ? AppColors.dh : '#F0F5FF')
                      .borderRadius(8).border({ width: 1, color: AppColors.dh })
                      .onClick((): void => { this.primeP = p; this.baseG = CipherUtils.findPrimitiveRoot(p); this.resetAnimation() })
                  })
                }
              }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
            }.width('100%')

            Row() {
              Text(`生成元 g：${this.baseG}`).fontSize(14).fontColor(AppColors.dh).fontWeight(FontWeight.Bold)
            }.width('100%')

            Row({ space: 20 }) {
              Column({ space: 4 }) {
                Text('Alice 私钥').fontSize(12).fontColor(AppColors.textHint)
                TextInput({ text: `${this.privateA}` }).width(80).height(40).fontColor(AppColors.textPrimary)
                  .backgroundColor('#F0F1F5').borderRadius(8).type(InputType.Number)
                  .onChange((v: string) => { this.privateA = parseInt(v) || 1; this.resetAnimation() })
              }
              Column({ space: 4 }) {
                Text('Bob 私钥').fontSize(12).fontColor(AppColors.textHint)
                TextInput({ text: `${this.privateB}` }).width(80).height(40).fontColor(AppColors.textPrimary)
                  .backgroundColor('#F0F1F5').borderRadius(8).type(InputType.Number)
                  .onChange((v: string) => { this.privateB = parseInt(v) || 1; this.resetAnimation() })
              }
            }
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          Column({ space: 10 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.dh).margin({ right: 8 })
              Text('密钥交换步骤').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }

            if (this.currentStep >= 1) {
              DhStepCard({ step: 1, title: '公开参数', stepContent: `p = ${this.primeP}, g = ${this.baseG}`, accentColor: AppColors.dh, currentStep: this.currentStep })
            }
            if (this.currentStep >= 2) {
              DhStepCard({ step: 2, title: 'Alice 计算公钥', stepContent: `A = g^a mod p = ${this.baseG}^${this.privateA} mod ${this.primeP} = ${this.publicA}`, accentColor: '#E74C3C', currentStep: this.currentStep })
            }
            if (this.currentStep >= 3) {
              DhStepCard({ step: 3, title: 'Bob 计算公钥', stepContent: `B = g^b mod p = ${this.baseG}^${this.privateB} mod ${this.primeP} = ${this.publicB}`, accentColor: '#3498DB', currentStep: this.currentStep })
            }
            if (this.currentStep >= 4) {
              DhStepCard({ step: 4, title: '交换公钥', stepContent: `Alice 发送 A=${this.publicA} 给 Bob，Bob 发送 B=${this.publicB} 给 Alice`, accentColor: AppColors.textSecondary, currentStep: this.currentStep })
            }
            if (this.currentStep >= 5) {
              Column({ space: 8 }) {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text('Alice 计算共享密钥').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#E74C3C')
                    Text(`B^a mod p = ${this.publicB}^${this.privateA} mod ${this.primeP} = ${this.sharedA}`)
                      .fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                  }.padding(12).backgroundColor('#FFF5F5').borderRadius(10).layoutWeight(1)
                  Column({ space: 4 }) {
                    Text('Bob 计算共享密钥').fontSize(13).fontWeight(FontWeight.Bold).fontColor('#3498DB')
                    Text(`A^b mod p = ${this.publicA}^${this.privateB} mod ${this.primeP} = ${this.sharedB}`)
                      .fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                  }.padding(12).backgroundColor('#F0F5FF').borderRadius(10).layoutWeight(1)
                }
              }.width('100%').padding(14).backgroundColor('#F8F9FA').borderRadius(12).animation({ duration: 400 })
            }
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(this.sharedA === this.sharedB ? '\u2713 密钥交换成功！' : '\u26A0 计算有误')
                .fontSize(16).fontWeight(FontWeight.Bold)
                .fontColor(this.sharedA === this.sharedB ? AppColors.success : AppColors.danger)
              if (this.sharedA === this.sharedB) {
                Text(`双方共享密钥：${this.sharedA}`).fontSize(18).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
              }
            }.width('100%').padding(20).backgroundColor('#E8FFF5').borderRadius(12).animation({ duration: 400 })
          }
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

      Row({ space: 12 }) {
        Button('重置').type(ButtonType.Capsule).height(44)
          .backgroundColor('#F0F1F5').fontColor(AppColors.textSecondary).layoutWeight(1)
          .onClick((): void => this.resetAnimation())
        Button(this.getStepButtonText()).type(ButtonType.Capsule).height(44)
          .backgroundColor(this.currentStep >= this.getMaxSteps() ? AppColors.success : AppColors.dh)
          .fontColor('#FFFFFF').layoutWeight(2).enabled(this.currentStep < this.getMaxSteps())
          .onClick((): void => this.nextStep())
      }.width('100%').padding({ left: 16, right: 16, top: 8, bottom: 16 }).backgroundColor(AppColors.bgPage)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }

}