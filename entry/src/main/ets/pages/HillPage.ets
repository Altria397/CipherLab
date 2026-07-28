import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard, StepButtonBar } from 'cipher'

@Entry
@Component
struct HillPage {
  @State plaintext: string = 'HELP'
  @State currentStep: number = -1
  @State showResult: boolean = false
  @State resultChars: string[] = []
  @State isEncrypting: boolean = true
  @State k00: number = 3
  @State k01: number = 5
  @State k10: number = 6
  @State k11: number = 7
  @State completedPairs: number[] = []

  private getMaxSteps(): number {
    return this.getProcessedText().length / 2 + 1
  }

  private getStepButtonText(): string {
    if (this.currentStep < 0) return '开始演示'
    if (this.currentStep >= this.getMaxSteps()) return '已完成'
    return '下一步 \u2192'
  }

  private getKeyMatrix(): number[][] {
    return [[this.k00, this.k01], [this.k10, this.k11]]
  }

  private getProcessedText(): string {
    let upper = this.plaintext.toUpperCase().replace(/[^A-Z]/g, '')
    while (upper.length % 2 !== 0) upper += 'X'
    return upper
  }

  resetAnimation() {
    this.currentStep = -1
    this.showResult = false
    this.resultChars = []
    this.completedPairs = []
  }

  nextStep() {
    if (this.currentStep >= this.getMaxSteps()) return
    this.currentStep++
    if (this.currentStep === 0) {
      this.showResult = false
      this.resultChars = []
      this.completedPairs = []
      const processed = this.getProcessedText()
      for (let i = 0; i < processed.length; i++) {
        this.resultChars.push('')
      }
    } else if (this.currentStep >= 1 && this.currentStep <= this.getProcessedText().length / 2) {
      const pairIdx = this.currentStep - 1
      const processed = this.getProcessedText()
      const c0 = processed.charCodeAt(pairIdx * 2) - 65
      const c1 = processed.charCodeAt(pairIdx * 2 + 1) - 65
      const matrix = this.getKeyMatrix()
      const r0 = ((matrix[0][0] * c0 + matrix[0][1] * c1) % 26 + 26) % 26
      const r1 = ((matrix[1][0] * c0 + matrix[1][1] * c1) % 26 + 26) % 26
      this.resultChars[pairIdx * 2] = String.fromCharCode(r0 + 65)
      this.resultChars[pairIdx * 2 + 1] = String.fromCharCode(r1 + 65)
      this.completedPairs.push(pairIdx)
    } else {
      this.showResult = true
    }
  }

  build() {
    Column() {
      PageNavBar({
        title: 'Hill 密码',
        accentColor: AppColors.hill,
        onBack: (): void => router.back(),
        rightText: this.isEncrypting ? '加密' : '解密',
        onRightClick: (): void => {
          this.isEncrypting = !this.isEncrypting
          this.resetAnimation()
        }
      })

      Scroll() {
        Column({ space: 14 }) {
          PrincipleCard({
            accentColor: AppColors.hill,
            content: 'Hill密码是线性代数与密码学的结合。将明文分成n个字母一组，与一个n\u00D7n密钥矩阵相乘，结果对26取模得到密文。解密需要计算密钥矩阵在模26下的逆矩阵。密钥矩阵的行列式必须与26互质。'
          })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.hill).margin({ right: 8 })
              Text('密钥矩阵 (2\u00D72)').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }

            Column({ space: 8 }) {
              Row({ space: 8 }) {
                Column() { Text('a').fontSize(11).fontColor(AppColors.textHint) }
                TextInput({ text: `${this.k00}` }).width(60).height(40).fontColor(AppColors.textPrimary)
                  .backgroundColor('#F0F1F5').borderRadius(8).type(InputType.Number)
                  .onChange((v: string) => { this.k00 = parseInt(v) || 0; this.resetAnimation() })
                Column() { Text('b').fontSize(11).fontColor(AppColors.textHint) }
                TextInput({ text: `${this.k01}` }).width(60).height(40).fontColor(AppColors.textPrimary)
                  .backgroundColor('#F0F1F5').borderRadius(8).type(InputType.Number)
                  .onChange((v: string) => { this.k01 = parseInt(v) || 0; this.resetAnimation() })
              }
              Row({ space: 8 }) {
                Column() { Text('c').fontSize(11).fontColor(AppColors.textHint) }
                TextInput({ text: `${this.k10}` }).width(60).height(40).fontColor(AppColors.textPrimary)
                  .backgroundColor('#F0F1F5').borderRadius(8).type(InputType.Number)
                  .onChange((v: string) => { this.k10 = parseInt(v) || 0; this.resetAnimation() })
                Column() { Text('d').fontSize(11).fontColor(AppColors.textHint) }
                TextInput({ text: `${this.k11}` }).width(60).height(40).fontColor(AppColors.textPrimary)
                  .backgroundColor('#F0F1F5').borderRadius(8).type(InputType.Number)
                  .onChange((v: string) => { this.k11 = parseInt(v) || 0; this.resetAnimation() })
              }

              if (CipherUtils.isValidHillKey(this.getKeyMatrix())) {
                Text('矩阵行列式与26互质 \u2713').fontSize(12).fontColor(AppColors.success)
              } else {
                Text('矩阵行列式须与26互质（ad-bc 不能被2或13整除）').fontSize(12).fontColor(AppColors.danger)
              }
            }
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.hill).margin({ right: 8 })
              Text('输入设置').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }
            TextInput({ text: this.plaintext, placeholder: '输入明文（英文字母）' })
              .width('100%').height(44).fontColor(AppColors.textPrimary)
              .backgroundColor('#F0F1F5').borderRadius(10)
              .onChange((v: string) => { this.plaintext = v; this.resetAnimation() })
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.hill).margin({ right: 8 })
              Text(this.isEncrypting ? '加密过程演示' : '解密过程演示')
                .fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }

            Text('明文分组').fontSize(12).fontColor(AppColors.textHint).alignSelf(ItemAlign.Start)
            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.getProcessedText().split(''), (ch: string, idx: number) => {
                  Column() {
                    Text(ch).fontSize(18).fontWeight(FontWeight.Bold)
                      .fontColor(this.completedPairs.indexOf(Math.floor(idx / 2)) >= 0 ? AppColors.hill : AppColors.textPrimary)
                  }.width(36).height(36).justifyContent(FlexAlign.Center)
                  .backgroundColor(this.completedPairs.indexOf(Math.floor(idx / 2)) >= 0 ? '#E8FFF5' : '#F0F1F5')
                  .borderRadius(8)
                  .border({ width: idx % 2 === 0 && idx < this.getProcessedText().length - 1 ? 1 : 0, color: '#E5E7EB' })
                })
              }
            }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)

            if (this.completedPairs.length > 0) {
              Column({ space: 6 }) {
                ForEach(this.completedPairs, (pairIdx: number) => {
                  Row({ space: 8 }) {
                    Text(`[${this.getProcessedText().charAt(pairIdx * 2)}, ${this.getProcessedText().charAt(pairIdx * 2 + 1)}]`)
                      .fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                    Text('\u00D7').fontSize(14).fontColor(AppColors.textHint)
                    Text(`[${this.getKeyMatrix()[0][0]}, ${this.getKeyMatrix()[0][1]}; ${this.getKeyMatrix()[1][0]}, ${this.getKeyMatrix()[1][1]}]`)
                      .fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.hill)
                    Text('\u2192').fontSize(14).fontColor(AppColors.textHint)
                    if (this.resultChars.length > pairIdx * 2 + 1 && this.resultChars[pairIdx * 2] !== '') {
                      Text(`[${this.resultChars[pairIdx * 2]}, ${this.resultChars[pairIdx * 2 + 1]}]`)
                        .fontSize(14).fontWeight(FontWeight.Bold).fontColor(AppColors.success)
                    }
                  }
                  .width('100%').padding(8).backgroundColor('#F8F9FA').borderRadius(8)
                })
              }
            }
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: '#1A1D2E08', offsetX: 0, offsetY: 2 })

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(`\u2713 ${this.isEncrypting ? '加密' : '解密'}完成`)
                .fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppColors.success)
              Text(`结果：${this.resultChars.join('')}`)
                .fontSize(18).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
                .copyOption(CopyOptions.LocalDevice)
            }.width('100%').padding(20).backgroundColor('#E8FFF5').borderRadius(12).animation({ duration: 400 })
          }
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

      StepButtonBar({
        stepText: this.getStepButtonText(),
        accentColor: AppColors.hill,
        isCompleted: this.currentStep >= this.getMaxSteps(),
        isEnabled: this.currentStep < this.getMaxSteps() && CipherUtils.isValidHillKey(this.getKeyMatrix()),
        onReset: (): void => this.resetAnimation(),
        onStep: (): void => this.nextStep()
      })
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }
}