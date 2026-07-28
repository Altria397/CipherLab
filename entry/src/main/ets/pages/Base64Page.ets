import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar } from 'cipher'

@Entry
@Component
struct Base64Page {
  @State plaintext: string = 'Hi!'
  @State currentStep: number = -1
  @State showResult: boolean = false
  @State binaryString: string = ''
  @State sixBitGroups: string[] = []
  @State base64Chars: string[] = []
  @State base64Indices: number[] = []
  @State isEncrypting: boolean = true
  @State decodedChars: string[] = []
  @State decodeStep: number = -1

  private b64Table: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  private stepTitles: string[] = [
    '显示 ASCII 值',
    '转换为 8位 二进制',
    '重新分组为 6位',
    '映射到 Base64 字符',
    '添加填充并完成'
  ]
  private decodeStepTitles: string[] = [
    '移除填充字符',
    'Base64字符 → 6位索引',
    '6位索引 → 二进制拼接',
    '重新分组为 8位',
    '8位二进制 → ASCII字符'
  ]

  private getMaxSteps(): number {
    return this.isEncrypting ? 5 : 5
  }

  private getStepButtonText(): string {
    if (this.currentStep < 0) return '开始演示'
    if (this.currentStep >= this.getMaxSteps()) return '已完成'
    return '下一步 →'
  }

  resetAnimation() {
    this.currentStep = -1
    this.showResult = false
    this.binaryString = ''
    this.sixBitGroups = []
    this.base64Chars = []
    this.base64Indices = []
    this.decodedChars = []
    this.decodeStep = -1
  }

  computeBase64() {
    this.binaryString = ''
    for (let i = 0; i < this.plaintext.length; i++) {
      this.binaryString += CipherUtils.toBinary(this.plaintext.charCodeAt(i), 8)
    }
    let padded = this.binaryString
    while (padded.length % 6 !== 0) {
      padded += '0'
    }
    this.sixBitGroups = []
    this.base64Indices = []
    this.base64Chars = []
    for (let i = 0; i < padded.length; i += 6) {
      const group = padded.substring(i, i + 6)
      this.sixBitGroups.push(group)
      let val = 0
      for (let j = 0; j < group.length; j++) {
        val = val * 2 + (group.charAt(j) === '1' ? 1 : 0)
      }
      this.base64Indices.push(val)
      this.base64Chars.push(this.b64Table.charAt(val))
    }
    while (this.base64Chars.length % 4 !== 0) {
      this.base64Chars.push('=')
      this.base64Indices.push(-1)
      this.sixBitGroups.push('padding')
    }
  }

  nextStep() {
    if (this.currentStep >= this.getMaxSteps()) return
    this.currentStep++
    if (this.currentStep === 0) {
      this.showResult = false
      this.binaryString = ''
      this.sixBitGroups = []
      this.base64Chars = []
      this.base64Indices = []
      this.decodedChars = []
      if (this.isEncrypting) {
        this.computeBase64()
      }
    } else if (this.currentStep === this.getMaxSteps()) {
      this.showResult = true
    }
  }

  build() {
    Column() {
      PageNavBar({
        title: 'Base64 编码',
        accentColor: AppColors.base64,
        onBack: (): void => router.back(),
        rightText: this.isEncrypting ? '编码' : '解码',
        onRightClick: (): void => {
          this.isEncrypting = !this.isEncrypting
          this.resetAnimation()
        }
      })


      Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('原理说明')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.accentSuccess)
            Text('Base64将二进制数据编码为可打印ASCII字符。将输入的每3个字节（24位）重新分组为4个6位块，每个6位块对应Base64字符表中的一个字符（共64个）。不足3字节时用"="填充。解码为逆向过程。')
              .fontSize(13)
              .fontColor(AppColors.textSecondary)
              .lineHeight(20)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F0FFF4')
          .borderRadius(12)

          Column({ space: 12 }) {
            Text('输入设置')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.textPrimary)
              .alignSelf(ItemAlign.Start)
            TextInput({ text: this.plaintext, placeholder: this.isEncrypting ? '输入文本' : '输入Base64字符串' })
              .width('100%')
              .height(44)
              .fontColor(AppColors.textPrimary)
              .backgroundColor(AppColors.bgSurfaceRaised)
              .borderRadius(10)
              .onChange((val: string) => {
                this.plaintext = val
                this.resetAnimation()
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(AppColors.bgSurface)
          .borderRadius(12)
          .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

          if (this.isEncrypting) {
            this.buildEncodeSteps()
          } else {
            this.buildDecodeSteps()
          }

          if (this.showResult) {
            Column({ space: 8 }) {
              Text(`\u2713 ${this.isEncrypting ? '编码' : '解码'}完成`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.accentSuccess)
              Text(`结果：${this.isEncrypting ? this.base64Chars.join('') : CipherUtils.base64Decode(this.plaintext)}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.textPrimary)
                .copyOption(CopyOptions.LocalDevice)
            }
            .width('100%')
            .padding(20)
            .backgroundColor(AppColors.bgSurface)
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
          .backgroundColor(this.currentStep >= this.getMaxSteps() ? AppColors.accentSuccess : '#43E97B')
          .fontColor(AppColors.bgBase)
          .layoutWeight(2)
          .enabled(this.currentStep < this.getMaxSteps() && this.plaintext.length > 0)
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

  @Builder
  buildEncodeSteps() {
    if (this.currentStep >= 0) {
      Column({ space: 4 }) {
        ForEach(this.stepTitles, (title: string, idx: number) => {
          Row() {
            Text(`${idx + 1}`)
              .fontSize(12)
              .fontColor(this.currentStep > idx ? AppColors.textPrimary : this.currentStep === idx ? AppColors.accentSuccess : '#B2BEC3')
              .fontWeight(FontWeight.Bold)
              .width(24)
              .height(24)
              .textAlign(TextAlign.Center)
              .backgroundColor(this.currentStep > idx ? AppColors.accentSuccess : '#00000000')
              .borderRadius(12)
              .border({ width: 1.5, color: this.currentStep >= idx ? AppColors.accentSuccess : '#DFE6E9' })
            Text(title)
              .fontSize(13)
              .fontColor(this.currentStep >= idx ? AppColors.textPrimary : '#B2BEC3')
              .fontWeight(this.currentStep === idx ? FontWeight.Bold : FontWeight.Normal)
              .margin({ left: 10 })
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
    }

    if (this.currentStep >= 1) {
      Column({ space: 12 }) {
        Text('步骤 1：ASCII 值')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .alignSelf(ItemAlign.Start)
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.plaintext.split(''), (ch: string) => {
              Column({ space: 4 }) {
                Text(`'${ch}'`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.textPrimary)
                Text(`${ch.charCodeAt(0)}`)
                  .fontSize(12)
                  .fontColor(AppColors.accentSuccess)
                  .fontWeight(FontWeight.Medium)
              }
              .padding(10)
              .backgroundColor('#F0FFF4')
              .borderRadius(8)
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      .animation({ duration: 400 })
    }

    if (this.currentStep >= 2) {
      Column({ space: 12 }) {
        Text('步骤 2：8位二进制')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .alignSelf(ItemAlign.Start)
        Scroll() {
          Row({ space: 6 }) {
            ForEach(this.plaintext.split(''), (ch: string) => {
              Column({ space: 2 }) {
                Text(`'${ch}'`)
                  .fontSize(11)
                  .fontColor(AppColors.textTertiary)
                Row({ space: 1 }) {
                  ForEach(CipherUtils.toBinary(ch.charCodeAt(0), 8).split(''), (bit: string) => {
                    Text(bit)
                      .fontSize(12)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(bit === '1' ? AppColors.accentSuccess : AppColors.textSecondary)
                      .width(16)
                      .height(20)
                      .textAlign(TextAlign.Center)
                      .backgroundColor(bit === '1' ? AppColors.bgSurface : AppColors.bgSurfaceRaised)
                      .borderRadius(3)
                  })
                }
              }
              .padding(6)
              .backgroundColor(AppColors.bgSurface)
              .borderRadius(8)
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      .animation({ duration: 400 })
    }

    if (this.currentStep >= 3) {
      Column({ space: 12 }) {
        Text('步骤 3：重组为 6位 分组')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .alignSelf(ItemAlign.Start)
        Scroll() {
          Row({ space: 6 }) {
            ForEach(this.sixBitGroups, (group: string, gIdx: number) => {
              Column({ space: 4 }) {
                if (group !== 'padding') {
                  Row({ space: 1 }) {
                    ForEach(group.split(''), (bit: string) => {
                      Text(bit)
                        .fontSize(12)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(AppColors.textPrimary)
                        .width(16)
                        .height(20)
                        .textAlign(TextAlign.Center)
                        .backgroundColor('#43E97B')
                        .borderRadius(3)
                    })
                  }
                  Text(`${this.base64Indices[gIdx]}`)
                    .fontSize(11)
                    .fontColor(AppColors.textSecondary)
                } else {
                  Text('PAD')
                    .fontSize(12)
                    .fontColor('#B2BEC3')
                }
              }
              .padding(8)
              .backgroundColor('#F0FFF4')
              .borderRadius(8)
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      .animation({ duration: 400 })
    }

    if (this.currentStep >= 4) {
      Column({ space: 12 }) {
        Text('步骤 4：映射到 Base64 字符')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .alignSelf(ItemAlign.Start)
        Row({ space: 6 }) {
          ForEach(this.base64Chars, (ch: string) => {
            Column() {
              Text(ch)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(ch === '=' ? '#B2BEC3' : AppColors.textPrimary)
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ch === '=' ? '#F0F0F0' : AppColors.accentSuccess)
            .borderRadius(10)
            .animation({ duration: 300 })
          })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      .animation({ duration: 400 })
    }
  }

  @Builder
  buildDecodeSteps() {
    if (this.currentStep >= 0) {
      Column({ space: 4 }) {
        ForEach(this.decodeStepTitles, (title: string, idx: number) => {
          Row() {
            Text(`${idx + 1}`)
              .fontSize(12)
              .fontColor(this.currentStep > idx ? AppColors.textPrimary : this.currentStep === idx ? AppColors.accentSuccess : '#B2BEC3')
              .fontWeight(FontWeight.Bold)
              .width(24)
              .height(24)
              .textAlign(TextAlign.Center)
              .backgroundColor(this.currentStep > idx ? AppColors.accentSuccess : '#00000000')
              .borderRadius(12)
              .border({ width: 1.5, color: this.currentStep >= idx ? AppColors.accentSuccess : '#DFE6E9' })
            Text(title)
              .fontSize(13)
              .fontColor(this.currentStep >= idx ? AppColors.textPrimary : '#B2BEC3')
              .fontWeight(this.currentStep === idx ? FontWeight.Bold : FontWeight.Normal)
              .margin({ left: 10 })
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
    }

    if (this.currentStep >= 1) {
      Column({ space: 12 }) {
        Text('步骤 1：移除填充字符')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .alignSelf(ItemAlign.Start)
        Row({ space: 6 }) {
          ForEach(this.plaintext.split(''), (ch: string) => {
            Column() {
              Text(ch)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(ch === '=' ? '#B2BEC3' : AppColors.textPrimary)
            }
            .width(36)
            .height(36)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ch === '=' ? '#F0F0F0' : '#F0FFF4')
            .borderRadius(8)
          })
        }
        if (this.plaintext.includes('=')) {
          Text(`移除 ${this.plaintext.split('').filter(c => c === '=').length} 个填充字符"="`)
            .fontSize(12)
            .fontColor(AppColors.textSecondary)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      .animation({ duration: 400 })
    }

    if (this.currentStep >= 2) {
      Column({ space: 12 }) {
        Text('步骤 2：Base64字符 → 6位索引')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .alignSelf(ItemAlign.Start)
        Row({ space: 6 }) {
          ForEach(this.plaintext.replace(/=/g, '').split(''), (ch: string) => {
            Column({ space: 2 }) {
              Text(ch)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.textPrimary)
              Text(`${this.b64Table.indexOf(ch)}`)
                .fontSize(12)
                .fontColor(AppColors.accentSuccess)
                .fontWeight(FontWeight.Medium)
            }
            .padding(8)
            .backgroundColor('#F0FFF4')
            .borderRadius(8)
          })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      .animation({ duration: 400 })
    }

    if (this.currentStep >= 3) {
      Column({ space: 12 }) {
        Text('步骤 3：6位索引 → 二进制拼接')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .alignSelf(ItemAlign.Start)
        Scroll() {
          Row({ space: 6 }) {
            ForEach(this.plaintext.replace(/=/g, '').split(''), (ch: string) => {
              Column({ space: 2 }) {
                Text(ch)
                  .fontSize(11)
                  .fontColor(AppColors.textTertiary)
                Row({ space: 1 }) {
                  ForEach(CipherUtils.toBinary(this.b64Table.indexOf(ch), 6).split(''), (bit: string) => {
                    Text(bit)
                      .fontSize(12)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(AppColors.textPrimary)
                      .width(14)
                      .height(18)
                      .textAlign(TextAlign.Center)
                      .backgroundColor('#43E97B')
                      .borderRadius(3)
                  })
                }
              }
              .padding(6)
              .backgroundColor(AppColors.bgSurface)
              .borderRadius(8)
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      .animation({ duration: 400 })
    }

    if (this.currentStep >= 4) {
      Column({ space: 12 }) {
        Text('步骤 4：重组为 8位 → ASCII字符')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.textPrimary)
          .alignSelf(ItemAlign.Start)
        Text(`解码结果：${CipherUtils.base64Decode(this.plaintext)}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.accentSuccess)
          .copyOption(CopyOptions.LocalDevice)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(AppColors.bgSurface)
      .borderRadius(12)
      .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
      .animation({ duration: 400 })
    }
  }
}
