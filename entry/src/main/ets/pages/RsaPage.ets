import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar } from 'cipher'

@Component
struct RsaStepCard {
  @Prop step: number = 0
  @Prop title: string = ''
  @Prop stepContent: string = ''
  @Prop formula: string = ''
  @Prop highlight: boolean = false
  @Prop currentStep: number = -1

  build() {
    Column({ space: 6 }) {
      Row({ space: 8 }) {
        Text(`${this.step + 1}`)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .width(24)
          .height(24)
          .textAlign(TextAlign.Center)
          .backgroundColor(this.currentStep > this.step ? AppColors.accentSuccess : AppColors.rsa)
          .borderRadius(12)
        Text(this.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
      }
      if (this.formula.length > 0) {
        Text(this.formula)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.rsa)
          .margin({ top: 4 })
      }
      if (this.stepContent.length > 0) {
        Text(this.stepContent)
          .fontSize(13)
          .fontColor(AppColors.textSecondary)
          .margin({ top: 2 })
      }
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppColors.bgSurface)
    .borderRadius(12)
    .border({ width: this.highlight ? 1.5 : 0, color: AppColors.rsa })
    .animation({ duration: 400 })
  }
}

@Entry
@Component
struct RsaPage {
  @State p: number = 7
  @State q: number = 11
  @State message: number = 42
  @State currentStep: number = -1
  @State showResult: boolean = false
  @State n: number = 0
  @State phi: number = 0
  @State e: number = 0
  @State d: number = 0
  @State encrypted: number = 0
  @State decrypted: number = 0

  private primes: number[] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

  private getPrimeIndex(val: number): number {
    for (let i = 0; i < this.primes.length; i++) {
      if (this.primes[i] === val) return i
    }
    return 0
  }

  private stepDescriptions: string[] = [
    '选择两个质数 p 和 q',
    '计算 n = p × q',
    '计算欧拉函数 φ(n) = (p-1)(q-1)',
    '选择公钥指数 e（与φ(n)互质）',
    '计算私钥指数 d（e的模逆元）',
    '展示密钥对',
    '加密：c = m^e mod n',
    '解密：m = c^d mod n',
  ]

  private getMaxSteps(): number {
    return 8
  }

  private getStepButtonText(): string {
    if (this.currentStep < 0) {
      return '开始演示'
    }
    if (this.currentStep >= this.getMaxSteps()) {
      return '已完成'
    }
    return '下一步 →'
  }

  findE(phi: number): number {
    const candidates: number[] = [3, 5, 7, 11, 13, 17, 19, 23]
    for (let i = 0; i < candidates.length; i++) {
      if (candidates[i] < phi && CipherUtils.gcd(candidates[i], phi) === 1) {
        return candidates[i]
      }
    }
    return 3
  }

  resetAnimation() {
    this.currentStep = -1
    this.showResult = false
    this.n = 0
    this.phi = 0
    this.e = 0
    this.d = 0
    this.encrypted = 0
    this.decrypted = 0
  }

  nextStep() {
    if (this.currentStep >= this.getMaxSteps()) {
      return
    }
    this.currentStep++
    switch (this.currentStep) {
      case 1:
        this.n = this.p * this.q
        break
      case 2:
        this.phi = (this.p - 1) * (this.q - 1)
        break
      case 3:
        this.e = this.findE(this.phi)
        break
      case 4:
        this.d = CipherUtils.modInverse(this.e, this.phi)
        break
      case 6:
        this.encrypted = CipherUtils.modPow(this.message, this.e, this.n)
        break
      case 7:
        this.decrypted = CipherUtils.modPow(this.encrypted, this.d, this.n)
        this.showResult = true
        break
    }
  }


  build() {
    Column() {
      PageNavBar({ title: 'RSA 加密原理', accentColor: AppColors.rsa, onBack: (): void => router.back() })

      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('原理说明')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.rsa)
            Text('RSA是一种非对称加密算法。它利用大质数乘积难以分解的数学特性，生成一对密钥：公钥用于加密，私钥用于解密。这里使用小数字演示其原理。')
              .fontSize(13)
              .fontColor(AppColors.textSecondary)
              .lineHeight(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.bgSurface)
          .borderRadius(12)

          Column({ space: 12 }) {
            Text('参数设置')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.textPrimary)
              .alignSelf(ItemAlign.Start)

            Column({ space: 6 }) {
              Row() {
                Text('质数 p：')
                  .fontSize(14)
                  .fontColor(AppColors.textPrimary)
                Text(`${this.p}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.rsa)
              }
              .width('100%')

              Scroll() {
                Row({ space: 6 }) {
                  ForEach(this.primes, (prime: number) => {
                    Text(`${prime}`)
                      .fontSize(14)
                      .fontWeight(this.p === prime ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(this.p === prime ? AppColors.textPrimary : AppColors.rsa)
                      .width(38)
                      .height(34)
                      .textAlign(TextAlign.Center)
                      .backgroundColor(this.p === prime ? AppColors.rsa : AppColors.bgSurface)
                      .borderRadius(8)
                      .border({ width: 1, color: AppColors.rsa })
                      .onClick(() => {
                        this.p = prime
                        if (this.message >= this.p * this.q) {
                          this.message = this.p * this.q - 1
                        }
                        this.resetAnimation()
                      })
                  })
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
            }
            .width('100%')

            Column({ space: 6 }) {
              Row() {
                Text('质数 q：')
                  .fontSize(14)
                  .fontColor(AppColors.textPrimary)
                Text(`${this.q}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#764BA2')
              }
              .width('100%')

              Scroll() {
                Row({ space: 6 }) {
                  ForEach(this.primes, (prime: number) => {
                    Text(`${prime}`)
                      .fontSize(14)
                      .fontWeight(this.q === prime ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(this.q === prime ? AppColors.textPrimary : '#764BA2')
                      .width(38)
                      .height(34)
                      .textAlign(TextAlign.Center)
                      .backgroundColor(this.q === prime ? '#764BA2' : AppColors.bgSurface)
                      .borderRadius(8)
                      .border({ width: 1, color: '#764BA2' })
                      .onClick(() => {
                        this.q = prime
                        if (this.message >= this.p * this.q) {
                          this.message = this.p * this.q - 1
                        }
                        this.resetAnimation()
                      })
                  })
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
            }
            .width('100%')

            if (this.p === this.q) {
              Text('提示：建议 p 和 q 选择不同的质数')
                .fontSize(12)
                .fontColor('#E17055')
            }

            Column({ space: 6 }) {
              Row() {
                Text('消息 m：')
                  .fontSize(14)
                  .fontColor(AppColors.textPrimary)
                Text(`${this.message}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.rsa)
                  .width(40)
                  .textAlign(TextAlign.Center)
                Text(`(< n = ${this.p * this.q})`)
                  .fontSize(12)
                  .fontColor(AppColors.textTertiary)
              }
              .width('100%')

              Slider({ value: this.message, min: 2, max: Math.max(this.p * this.q - 1, 3), step: 1 })
                .width('100%')
                .selectedColor(AppColors.rsa)
                .onChange((value: number) => {
                  this.message = Math.round(value)
                  this.resetAnimation()
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.bgSurface)
          .borderRadius(12)
          .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

          Column({ space: 10 }) {
            Text('RSA 算法步骤')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.textPrimary)
              .alignSelf(ItemAlign.Start)

            if (this.currentStep >= 0) {
              RsaStepCard({ step: 0, title: '选择质数', stepContent: `p = ${this.p}, q = ${this.q}`, formula: '', highlight: this.currentStep === 0, currentStep: this.currentStep })
            }
            if (this.currentStep >= 1) {
              RsaStepCard({ step: 1, title: '计算 n', stepContent: `n = p × q = ${this.p} × ${this.q}`, formula: `n = ${this.n}`, highlight: this.currentStep === 1, currentStep: this.currentStep })
            }
            if (this.currentStep >= 2) {
              RsaStepCard({ step: 2, title: '计算欧拉函数', stepContent: `φ(n) = (p-1)(q-1) = ${this.p - 1} × ${this.q - 1}`, formula: `φ(n) = ${this.phi}`, highlight: this.currentStep === 2, currentStep: this.currentStep })
            }
            if (this.currentStep >= 3) {
              RsaStepCard({ step: 3, title: '选择公钥指数 e', stepContent: `e 与 φ(n)=${this.phi} 互质`, formula: `e = ${this.e}`, highlight: this.currentStep === 3, currentStep: this.currentStep })
            }
            if (this.currentStep >= 4) {
              RsaStepCard({ step: 4, title: '计算私钥指数 d', stepContent: `d × e ≡ 1 (mod φ(n))`, formula: `d = ${this.d}`, highlight: this.currentStep === 4, currentStep: this.currentStep })
            }
            if (this.currentStep >= 5) {
              Column({ space: 8 }) {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text('公钥')
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(AppColors.rsa)
                    Text(`(e=${this.e}, n=${this.n})`)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(AppColors.textPrimary)
                  }
                  .padding(12)
                  .backgroundColor(AppColors.bgSurface)
                  .borderRadius(10)
                  .layoutWeight(1)

                  Column({ space: 4 }) {
                    Text('私钥')
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#764BA2')
                    Text(`(d=${this.d}, n=${this.n})`)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(AppColors.textPrimary)
                  }
                  .padding(12)
                  .backgroundColor(AppColors.bgSurface)
                  .borderRadius(10)
                  .layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor(AppColors.bgSurface)
              .borderRadius(12)
              .animation({ duration: 400 })
            }
            if (this.currentStep >= 6) {
              RsaStepCard({ step: 6, title: '加密', stepContent: `c = m^e mod n = ${this.message}^${this.e} mod ${this.n}`, formula: `密文 c = ${this.encrypted}`, highlight: this.currentStep === 6, currentStep: this.currentStep })
            }
            if (this.currentStep >= 7) {
              RsaStepCard({ step: 7, title: '解密', stepContent: `m = c^d mod n = ${this.encrypted}^${this.d} mod ${this.n}`, formula: `明文 m = ${this.decrypted}`, highlight: this.currentStep === 7, currentStep: this.currentStep })
            }

          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.bgSurface)
          .borderRadius(12)
          .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(this.decrypted === this.message ? '\u2713 解密成功！' : '\u26A0 参数有误')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.decrypted === this.message ? AppColors.accentSuccess : '#E17055')
              Text(this.decrypted === this.message
                ? `原始消息 ${this.message} → 加密为 ${this.encrypted} → 解密还原为 ${this.decrypted}`
                : '请确保 p, q 为质数且 m < n')
                .fontSize(14)
                .fontColor(AppColors.textSecondary)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding(20)
            .backgroundColor(this.decrypted === this.message ? AppColors.bgSurface : '#FFF5F0')
            .borderRadius(12)
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Row({ space: 12 }) {
        Button('重置')
          .type(ButtonType.Capsule)
          .height(44)
          .backgroundColor(AppColors.bgSurfaceRaised)
          .fontColor(AppColors.textSecondary)
          .layoutWeight(1)
          .onClick(() => this.resetAnimation())
        Button(this.getStepButtonText())
          .type(ButtonType.Capsule)
          .height(44)
          .backgroundColor(this.currentStep >= this.getMaxSteps() ? AppColors.accentSuccess : AppColors.rsa)
          .fontColor(AppColors.bgBase)
          .layoutWeight(2)
          .enabled(this.currentStep < this.getMaxSteps())
          .onClick(() => this.nextStep())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      .backgroundColor(AppColors.bgSurfaceRaised)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.bgSurfaceRaised)
  }
}
