import { router } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { CipherUtils, CustomCipherParam, AppColors, CipherTypeIcon, PageNavBar } from 'cipher'

const MAX_CIPHERS = 10
const PREFS_NAME = 'cipher_lab_prefs'
const CIPHERS_KEY = 'custom_ciphers'

class CipherItem {
  id: string = ''
  name: string = ''
  type: string = 'shift'
  shiftAmount: number = 3
  keyword: string = 'SECRET'
  affineA: number = 5
  affineB: number = 8
  railCount: number = 3
  createTime: number = 0
}

@Entry
@Component
struct CustomCipherPage {
  @State ciphers: CipherItem[] = []
  @State showEditor: boolean = false
  @State editIndex: number = -1
  @State editName: string = ''
  @State editType: string = 'shift'
  @State editShift: number = 3
  @State editKeyword: string = 'SECRET'
  @State editAffineA: number = 5
  @State editAffineB: number = 8
  @State editRailCount: number = 3
  @State testInput: string = ''
  @State testOutput: string = ''
  @State isTestEncrypt: boolean = true
  @State testingIndex: number = -1
  @State showDeleteConfirm: boolean = false
  @State deleteIndex: number = -1
  @State currentTab: number = 0

  private typeNames: string[] = ['位移加密', '关键字替换', '仿射加密', '栅栏加密']
  private typeKeys: string[] = ['shift', 'keyword', 'affine', 'railFence']

  aboutToAppear() {
    this.loadCiphers()
  }

  async loadCiphers() {
    try {
      const ctx = getContext(this)
      const store = preferences.getPreferencesSync(ctx, { name: PREFS_NAME })
      const data = store.getSync(CIPHERS_KEY, '[]') as string
      const arr: object[] = JSON.parse(data) as object[]
      const items: CipherItem[] = []
      for (let i = 0; i < arr.length; i++) {
        const obj = arr[i] as Record<string, string | number>
        const item = new CipherItem()
        item.id = (obj['id'] ?? '') as string
        item.name = (obj['name'] ?? '') as string
        item.type = (obj['type'] ?? 'shift') as string
        item.shiftAmount = (obj['shiftAmount'] ?? 3) as number
        item.keyword = (obj['keyword'] ?? 'SECRET') as string
        item.affineA = (obj['affineA'] ?? 5) as number
        item.affineB = (obj['affineB'] ?? 8) as number
        item.railCount = (obj['railCount'] ?? 3) as number
        item.createTime = (obj['createTime'] ?? 0) as number
        items.push(item)
      }
      this.ciphers = items
    } catch (e) {
      this.ciphers = []
    }
  }

  async saveCiphers() {
    try {
      const ctx = getContext(this)
      const store = preferences.getPreferencesSync(ctx, { name: PREFS_NAME })
      const arr: object[] = []
      for (let i = 0; i < this.ciphers.length; i++) {
        const c = this.ciphers[i]
        const obj: Record<string, string | number> = {
          'id': c.id,
          'name': c.name,
          'type': c.type,
          'shiftAmount': c.shiftAmount,
          'keyword': c.keyword,
          'affineA': c.affineA,
          'affineB': c.affineB,
          'railCount': c.railCount,
          'createTime': c.createTime
        }
        arr.push(obj)
      }
      store.putSync(CIPHERS_KEY, JSON.stringify(arr))
      await store.flush()
    } catch (e) {
    }
  }

  openEditor(index: number) {
    if (index >= 0 && index < this.ciphers.length) {
      const c = this.ciphers[index]
      this.editName = c.name
      this.editType = c.type
      this.editShift = c.shiftAmount
      this.editKeyword = c.keyword
      this.editAffineA = c.affineA
      this.editAffineB = c.affineB
      this.editRailCount = c.railCount
    } else {
      this.editName = ''
      this.editType = 'shift'
      this.editShift = 3
      this.editKeyword = 'SECRET'
      this.editAffineA = 5
      this.editAffineB = 8
      this.editRailCount = 3
    }
    this.editIndex = index
    this.showEditor = true
  }

  saveEditing() {
    if (this.editName.trim().length === 0) return
    if (this.editType === 'affine' && !CipherUtils.isValidAffineA(this.editAffineA)) return
    const item = new CipherItem()
    item.name = this.editName.trim()
    item.type = this.editType
    item.shiftAmount = this.editShift
    item.keyword = this.editKeyword
    item.affineA = this.editAffineA
    item.affineB = this.editAffineB
    item.railCount = this.editRailCount

    if (this.editIndex >= 0 && this.editIndex < this.ciphers.length) {
      item.id = this.ciphers[this.editIndex].id
      item.createTime = this.ciphers[this.editIndex].createTime
      this.ciphers[this.editIndex] = item
    } else {
      item.id = Date.now().toString()
      item.createTime = Date.now()
      this.ciphers.push(item)
    }
    this.ciphers = [...this.ciphers]
    this.saveCiphers()
    this.showEditor = false
  }

  deleteCipher(index: number) {
    if (index >= 0 && index < this.ciphers.length) {
      this.ciphers.splice(index, 1)
      this.ciphers = [...this.ciphers]
      this.saveCiphers()
    }
    this.showDeleteConfirm = false
    this.deleteIndex = -1
  }

  doTestEncrypt(index: number) {
    const c = this.ciphers[index]
    const param = new CustomCipherParam()
    param.type = c.type
    param.shiftAmount = c.shiftAmount
    param.keyword = c.keyword
    param.affineA = c.affineA
    param.affineB = c.affineB
    param.railCount = c.railCount
    this.testOutput = this.isTestEncrypt
      ? CipherUtils.encryptWithCustom(this.testInput, param)
      : CipherUtils.decryptWithCustom(this.testInput, param)
  }

  getTypeDisplayName(type: string): string {
    const idx = this.typeKeys.indexOf(type)
    return idx >= 0 ? this.typeNames[idx] : type
  }

  getTypeIcon(type: string): string {
    switch (type) {
      case 'shift': return 'S'
      case 'keyword': return 'K'
      case 'affine': return 'A'
      case 'railFence': return 'F'
      default: return '?'
    }
  }

  getParamDesc(c: CipherItem): string {
    switch (c.type) {
      case 'shift': return `位移量: ${c.shiftAmount}`
      case 'keyword': return `关键字: ${c.keyword}`
      case 'affine': return `a=${c.affineA}, b=${c.affineB}`
      case 'railFence': return `栏数: ${c.railCount}`
      default: return ''
    }
  }

  build() {
    Column() {
      PageNavBar({
        title: '自定义加密方法',
        accentColor: AppColors.vigenere,
        onBack: (): void => router.back(),
        rightText: `${this.ciphers.length}/${MAX_CIPHERS}`
      })


      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          this.cipherListContent()
        }
        .tabBar('我的加密方法')

        TabContent() {
          this.chainContent()
        }
        .tabBar('加密链组合')
      }
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTab = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6FA')
  }

  @Builder
  cipherListContent() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          if (this.ciphers.length === 0) {
            Column({ space: 16 }) {
              Text('\u2713')
                .fontSize(60)
              Text('还没有自定义加密方法')
                .fontSize(16)
                .fontColor('#B2BEC3')
              Text('点击下方按钮创建你的第一个加密方法')
                .fontSize(13)
                .fontColor('#DFE6E9')
            }
            .width('100%')
            .padding({ top: 80, bottom: 40 })
            .justifyContent(FlexAlign.Center)
          }

          ForEach(this.ciphers, (cipher: CipherItem, idx: number) => {
            Column({ space: 10 }) {
              Row() {
                CipherTypeIcon({ cipherType: cipher.type, iconSize: 36 })
                Column() {
                  Text(cipher.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#2D3436')
                  Row({ space: 8 }) {
                    Text(this.getTypeDisplayName(cipher.type))
                      .fontSize(11)
                      .fontColor('#FFFFFF')
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .backgroundColor('#667EEA')
                      .borderRadius(4)
                    Text(this.getParamDesc(cipher))
                      .fontSize(12)
                      .fontColor('#636E72')
                  }
                  .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                .layoutWeight(1)

                Row({ space: 4 }) {
                  Text('\u270E')
                    .fontSize(16)
                    .fontColor(AppColors.textSecondary)
                    .padding(6)
                    .onClick(() => this.openEditor(idx))
                  Text('\u2716')
                    .fontSize(14)
                    .fontColor(AppColors.danger)
                    .padding(6)
                    .onClick(() => {
                      this.deleteIndex = idx
                      this.showDeleteConfirm = true
                    })
                }
              }

              if (this.testingIndex === idx) {
                Column({ space: 8 }) {
                  Divider().color('#F0F0F0')

                  Row({ space: 8 }) {
                    Text(this.isTestEncrypt ? '加密' : '解密')
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isTestEncrypt ? '#667EEA' : '#00B894')
                    Row() {
                      Text('加密')
                        .fontSize(12)
                        .fontColor(this.isTestEncrypt ? '#FFFFFF' : '#636E72')
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .backgroundColor(this.isTestEncrypt ? '#667EEA' : '#F5F6FA')
                        .borderRadius(6)
                        .onClick(() => { this.isTestEncrypt = true; this.testOutput = '' })
                      Text('解密')
                        .fontSize(12)
                        .fontColor(!this.isTestEncrypt ? '#FFFFFF' : '#636E72')
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .backgroundColor(!this.isTestEncrypt ? '#00B894' : '#F5F6FA')
                        .borderRadius(6)
                        .onClick(() => { this.isTestEncrypt = false; this.testOutput = '' })
                    }
                  }

                  TextInput({ text: this.testInput, placeholder: '输入文本' })
                    .width('100%')
                    .height(40)
                    .fontColor(AppColors.textPrimary)
                    .backgroundColor('#F5F6FA')
                    .borderRadius(8)
                    .onChange((val: string) => {
                      this.testInput = val
                    })
                  Button(this.isTestEncrypt ? '加密测试' : '解密测试')
                    .type(ButtonType.Capsule)
                    .height(36)
                    .fontSize(13)
                    .backgroundColor(this.isTestEncrypt ? '#667EEA' : '#00B894')
                    .width('100%')
                    .onClick(() => this.doTestEncrypt(idx))
                  if (this.testOutput.length > 0) {
                    Column({ space: 4 }) {
                      Text(`${this.isTestEncrypt ? '加密' : '解密'}结果：`)
                        .fontSize(12)
                        .fontColor('#999')
                      Text(this.testOutput)
                        .fontSize(15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#00B894')
                        .copyOption(CopyOptions.LocalDevice)
                    }
                    .width('100%')
                    .padding(10)
                    .backgroundColor('#E8FFF5')
                    .borderRadius(8)
                  }
                }
              }

              Button(this.testingIndex === idx ? '收起测试' : '测试')
                .type(ButtonType.Capsule)
                .height(32)
                .fontSize(12)
                .backgroundColor('#F5F6FA')
                .fontColor('#667EEA')
                .width('100%')
                .onClick(() => {
                  if (this.testingIndex === idx) {
                    this.testingIndex = -1
                    this.testOutput = ''
                  } else {
                    this.testingIndex = idx
                    this.testInput = ''
                    this.testOutput = ''
                  }
                })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(14)
            .shadow({ radius: 4, color: '#0000000A', offsetX: 0, offsetY: 2 })
          })

          if (this.ciphers.length < MAX_CIPHERS) {
            Button('+ 新建加密方法')
              .type(ButtonType.Capsule)
              .width('100%')
              .height(48)
              .fontSize(16)
              .backgroundColor('#667EEA')
              .fontColor('#FFFFFF')
              .onClick(() => this.openEditor(-1))
          } else {
            Text(`已达到最大数量 (${MAX_CIPHERS}个)`)
              .fontSize(13)
              .fontColor('#E17055')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(12)
          }
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 30 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.showEditor) {
        Column() {
          Blank()
            .width('100%')
            .layoutWeight(1)
            .backgroundColor('#00000066')
            .onClick(() => {
              this.showEditor = false
            })

          Column({ space: 14 }) {
            Row() {
              Text(this.editIndex >= 0 ? '编辑加密方法' : '新建加密方法')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2D3436')
              Blank()
              Text('\u2716')
                .fontSize(20)
                .fontColor('#B2BEC3')
                .onClick(() => {
                  this.showEditor = false
                })
            }
            .width('100%')

            TextInput({ text: this.editName, placeholder: '加密方法名称' })
              .width('100%')
              .height(44)
              .fontColor(AppColors.textPrimary)
              .backgroundColor('#F5F6FA')
              .borderRadius(10)
              .onChange((val: string) => {
                this.editName = val
              })

            Text('加密类型')
              .fontSize(13)
              .fontColor('#999')
              .alignSelf(ItemAlign.Start)
            Row({ space: 8 }) {
              ForEach(this.typeKeys, (key: string, ki: number) => {
                Column() {
                  Text(this.typeNames[ki])
                    .fontSize(12)
                    .fontColor(this.editType === key ? '#FFFFFF' : '#636E72')
                }
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(this.editType === key ? '#667EEA' : '#F5F6FA')
                .borderRadius(8)
                .onClick(() => {
                  this.editType = key
                })
              })
            }
            .width('100%')

            if (this.editType === 'shift') {
              Row() {
                Text('位移量：')
                  .fontSize(14)
                  .fontColor('#2D3436')
                Text(`${this.editShift}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#667EEA')
                  .width(36)
                  .textAlign(TextAlign.Center)
                Slider({ value: this.editShift, min: 1, max: 25, step: 1 })
                  .layoutWeight(1)
                  .selectedColor('#667EEA')
                  .onChange((value: number) => {
                    this.editShift = Math.round(value)
                  })
              }
              .width('100%')
            }

            if (this.editType === 'keyword') {
              TextInput({ text: this.editKeyword, placeholder: '输入关键字（英文）' })
                .width('100%')
                .height(44)
                .fontColor(AppColors.textPrimary)
                .backgroundColor('#F5F6FA')
                .borderRadius(10)
                .onChange((val: string) => {
                  this.editKeyword = val.toUpperCase()
                })
            }

            if (this.editType === 'affine') {
              Row({ space: 12 }) {
                Column() {
                  Text('参数 a')
                    .fontSize(12)
                    .fontColor('#999')
                  TextInput({ text: `${this.editAffineA}` })
                    .width('100%')
                    .height(40)
                    .fontColor(AppColors.textPrimary)
                    .backgroundColor('#F5F6FA')
                    .borderRadius(8)
                    .type(InputType.Number)
                    .onChange((val: string) => {
                      this.editAffineA = parseInt(val) || 5
                    })
                }
                .layoutWeight(1)
                Column() {
                  Text('参数 b')
                    .fontSize(12)
                    .fontColor('#999')
                  TextInput({ text: `${this.editAffineB}` })
                    .width('100%')
                    .height(40)
                    .fontColor(AppColors.textPrimary)
                    .backgroundColor('#F5F6FA')
                    .borderRadius(8)
                    .type(InputType.Number)
                    .onChange((val: string) => {
                      this.editAffineB = parseInt(val) || 8
                    })
                }
                .layoutWeight(1)
              }
              .width('100%')
              if (!CipherUtils.isValidAffineA(this.editAffineA)) {
                Text('参数 a 须与26互质（如 1,3,5,7,9,11,15,17,19,21,23,25）')
                  .fontSize(11)
                  .fontColor('#E17055')
              } else {
                Text('参数 a 与26互质 ✓')
                  .fontSize(11)
                  .fontColor('#00B894')
              }
            }

            if (this.editType === 'railFence') {
              Row() {
                Text('栏数：')
                  .fontSize(14)
                  .fontColor('#2D3436')
                Text(`${this.editRailCount}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#667EEA')
                  .width(36)
                  .textAlign(TextAlign.Center)
                Slider({ value: this.editRailCount, min: 2, max: 10, step: 1 })
                  .layoutWeight(1)
                  .selectedColor('#667EEA')
                  .onChange((value: number) => {
                    this.editRailCount = Math.round(value)
                  })
              }
              .width('100%')
            }

            Row({ space: 12 }) {
              Button('取消')
                .type(ButtonType.Capsule)
                .height(44)
                .backgroundColor('#F5F6FA')
                .fontColor('#636E72')
                .layoutWeight(1)
                .onClick(() => {
                  this.showEditor = false
                })
              Button('保存')
                .type(ButtonType.Capsule)
                .height(44)
                .backgroundColor('#667EEA')
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .enabled(this.editName.trim().length > 0 && !(this.editType === 'affine' && !CipherUtils.isValidAffineA(this.editAffineA)))
                .onClick(() => this.saveEditing())
            }
            .width('100%')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 24, topRight: 24 })
        }
        .width('100%')
        .height('100%')
      }

      if (this.showDeleteConfirm) {
        Column() {
          Blank()
            .layoutWeight(1)
            .onClick(() => {
              this.showDeleteConfirm = false
            })

          Column({ space: 16 }) {
            Text('确认删除')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
            Text(this.deleteIndex >= 0 && this.deleteIndex < this.ciphers.length
              ? `确定要删除 "${this.ciphers[this.deleteIndex].name}" 吗？`
              : '')
              .fontSize(14)
              .fontColor('#636E72')
              .textAlign(TextAlign.Center)
            Row({ space: 12 }) {
              Button('取消')
                .type(ButtonType.Capsule)
                .height(44)
                .backgroundColor('#F5F6FA')
                .fontColor('#636E72')
                .layoutWeight(1)
                .onClick(() => {
                  this.showDeleteConfirm = false
                })
              Button('删除')
                .type(ButtonType.Capsule)
                .height(44)
                .backgroundColor('#E17055')
                .fontColor('#FFFFFF')
                .layoutWeight(1)
                .onClick(() => this.deleteCipher(this.deleteIndex))
            }
            .width('100%')
          }
          .width('100%')
          .padding(24)
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 24, topRight: 24 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000066')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  chainContent() {
    Column({ space: 16 }) {
      Column({ space: 8 }) {
        Text('加密链组合')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#667EEA')
        Text('将多个加密方法串联组合，文本依次经过每个加密方法处理。解密时按相反顺序依次解密。')
          .fontSize(13)
          .fontColor('#636E72')
          .lineHeight(20)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F0F3FF')
      .borderRadius(12)

      if (this.ciphers.length === 0) {
        Column({ space: 12 }) {
          Text('\u2713')
            .fontSize(48)
          Text('请先创建加密方法')
            .fontSize(14)
            .fontColor('#B2BEC3')
        }
        .width('100%')
        .padding({ top: 60 })
        .justifyContent(FlexAlign.Center)
      } else {
        this.chainTestContent()
      }
    }
    .padding(16)
    .width('100%')
    .height('100%')
  }

  @State chainInput: string = ''
  @State chainOutput: string = ''
  @State isChainEncrypt: boolean = true
  @State selectedChainIndices: number[] = []

  @Builder
  chainTestContent() {
    Column({ space: 14 }) {
      Text('选择加密方法（按顺序）')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D3436')
        .alignSelf(ItemAlign.Start)

      ForEach(this.ciphers, (cipher: CipherItem, idx: number) => {
        Row() {
          Text(this.selectedChainIndices.indexOf(idx) >= 0 ? '✓' : '○')
            .fontSize(18)
            .fontColor(this.selectedChainIndices.indexOf(idx) >= 0 ? '#667EEA' : '#B2BEC3')
            .margin({ right: 12 })
          Text(this.getTypeIcon(cipher.type))
            .fontSize(24)
          Column() {
            Text(cipher.name)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#2D3436')
            Text(this.getParamDesc(cipher))
              .fontSize(12)
              .fontColor('#636E72')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 10 })
          .layoutWeight(1)
          if (this.selectedChainIndices.indexOf(idx) >= 0) {
            Text(`#${this.selectedChainIndices.indexOf(idx) + 1}`)
              .fontSize(12)
              .fontColor('#667EEA')
              .fontWeight(FontWeight.Bold)
          }
        }
        .width('100%')
        .padding(12)
        .backgroundColor(this.selectedChainIndices.indexOf(idx) >= 0 ? '#F0F3FF' : '#FFFFFF')
        .borderRadius(10)
        .border({
          width: this.selectedChainIndices.indexOf(idx) >= 0 ? 1.5 : 0,
          color: '#667EEA'
        })
        .onClick(() => {
          const pos = this.selectedChainIndices.indexOf(idx)
          if (pos >= 0) {
            this.selectedChainIndices.splice(pos, 1)
          } else {
            this.selectedChainIndices.push(idx)
          }
          this.selectedChainIndices = [...this.selectedChainIndices]
          this.chainOutput = ''
        })
      })

      if (this.selectedChainIndices.length > 0) {
        Row() {
          Text('执行顺序：')
            .fontSize(13)
            .fontColor('#636E72')
          ForEach(this.selectedChainIndices, (cIdx: number, order: number) => {
            Text(this.ciphers[cIdx].name + (order < this.selectedChainIndices.length - 1 ? ' → ' : ''))
              .fontSize(13)
              .fontColor('#667EEA')
              .fontWeight(FontWeight.Medium)
          })
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F5F6FA')
        .borderRadius(8)
      }

      Row({ space: 8 }) {
        Text(this.isChainEncrypt ? '加密模式' : '解密模式')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isChainEncrypt ? '#667EEA' : '#00B894')
        Row() {
          Text('加密')
            .fontSize(12)
            .fontColor(this.isChainEncrypt ? '#FFFFFF' : '#636E72')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.isChainEncrypt ? '#667EEA' : '#F5F6FA')
            .borderRadius(6)
            .onClick(() => { this.isChainEncrypt = true; this.chainOutput = '' })
          Text('解密')
            .fontSize(12)
            .fontColor(!this.isChainEncrypt ? '#FFFFFF' : '#636E72')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(!this.isChainEncrypt ? '#00B894' : '#F5F6FA')
            .borderRadius(6)
            .onClick(() => { this.isChainEncrypt = false; this.chainOutput = '' })
        }
      }
      .width('100%')

      TextInput({ text: this.chainInput, placeholder: '输入文本' })
        .width('100%')
        .height(44)
        .fontColor(AppColors.textPrimary)
        .backgroundColor('#F5F6FA')
        .borderRadius(10)
        .onChange((val: string) => {
          this.chainInput = val
          this.chainOutput = ''
        })

      Button(this.isChainEncrypt ? '加密' : '解密')
        .type(ButtonType.Capsule)
        .height(44)
        .fontSize(16)
        .backgroundColor(this.isChainEncrypt ? '#667EEA' : '#00B894')
        .fontColor('#FFFFFF')
        .width('100%')
        .enabled(this.selectedChainIndices.length > 0 && this.chainInput.length > 0)
        .onClick(() => {
          const params: CustomCipherParam[] = []
          for (let i = 0; i < this.selectedChainIndices.length; i++) {
            const c = this.ciphers[this.selectedChainIndices[i]]
            const param = new CustomCipherParam()
            param.type = c.type
            param.shiftAmount = c.shiftAmount
            param.keyword = c.keyword
            param.affineA = c.affineA
            param.affineB = c.affineB
            param.railCount = c.railCount
            params.push(param)
          }
          this.chainOutput = this.isChainEncrypt
            ? CipherUtils.encryptChain(this.chainInput, params)
            : CipherUtils.decryptChain(this.chainInput, params)
        })

      if (this.chainOutput.length > 0) {
        Column({ space: 4 }) {
          Text(`${this.isChainEncrypt ? '加密' : '解密'}结果：`)
            .fontSize(12)
            .fontColor('#999')
          Text(this.chainOutput)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#00B894')
            .copyOption(CopyOptions.LocalDevice)
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#E8FFF5')
        .borderRadius(10)
      }
    }
    .width('100%')
  }
}
