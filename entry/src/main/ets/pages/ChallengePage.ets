import { router } from '@kit.ArkUI'
import { CipherUtils, AppColors, PageNavBar, PrincipleCard } from 'cipher'

interface Challenge {
  question: string
  hint: string
  cipherType: string
  answer: string
}

@Entry
@Component
struct ChallengePage {
  @State currentLevel: number = 0
  @State userAnswer: string = ''
  @State showHint: boolean = false
  @State isCorrect: boolean = false
  @State hasChecked: boolean = false
  @State score: number = 0
  @State completedLevels: number[] = []

  private challenges: Challenge[] = [
    { question: '用凯撒密码（位移3）加密 "HELLO"', hint: '每个字母向后移动3位：H→K, E→H, L→O, L→O, O→R', cipherType: '凯撒密码', answer: 'KHOOR' },
    { question: '用凯撒密码（位移-3）解密 "KHOOR"', hint: '每个字母向前移动3位：K→H, H→E, O→L, O→L, R→O', cipherType: '凯撒密码', answer: 'HELLO' },
    { question: '维吉尼亚密钥为"KEY"，加密"ABC"', hint: 'K(10)偏移A→K, E(4)偏移B→F, Y(24)偏移C→A', cipherType: '维吉尼亚密码', answer: 'KFA' },
    { question: 'XOR加密：0x41 ^ 0x0F = ?', hint: '01000001 ^ 00001111 = 01001110 = 0x4E', cipherType: 'XOR加密', answer: '0x4E' },
    { question: 'Base64编码 "AB" 的结果？', hint: 'A=01000001, B=01000010 → 0100000101000010 → 000100 000101 000010 → Q=16, F=5, I=8 → QFI=', cipherType: 'Base64编码', answer: 'QUI=' },
    { question: 'Hill密码密钥[[3,5],[6,7]]，加密"HE"', hint: 'H=7,E=4 → [3×7+5×4, 6×7+7×4] = [41,70] → [41%26, 70%26] = [15,18] → P,S', cipherType: 'Hill密码', answer: 'PS' },
    { question: '仿射加密(a=5,b=8)，加密字母"A"', hint: 'E(x) = (5x+8) mod 26, A=0 → (5×0+8) mod 26 = 8 → I', cipherType: '仿射加密', answer: 'I' },
    { question: 'RSA中 p=3,q=11, 求 n=?', hint: 'n = p × q = 3 × 11 = 33', cipherType: 'RSA加密', answer: '33' }
  ]

  checkAnswer() {
    this.hasChecked = true
    const expected = this.challenges[this.currentLevel].answer.toUpperCase()
    this.isCorrect = this.userAnswer.toUpperCase() === expected
    if (this.isCorrect && this.completedLevels.indexOf(this.currentLevel) < 0) {
      this.completedLevels.push(this.currentLevel)
      this.score += 10
    }
  }

  nextChallenge() {
    this.userAnswer = ''
    this.showHint = false
    this.hasChecked = false
    this.isCorrect = false
    if (this.currentLevel < this.challenges.length - 1) {
      this.currentLevel++
    }
  }

  build() {
    Column() {
      PageNavBar({ title: '加密挑战', accentColor: AppColors.accent, onBack: (): void => router.back() })

      Scroll() {
        Column({ space: 14 }) {
          PrincipleCard({
            accentColor: AppColors.accent,
            content: '通过解题来检验你对加密算法的理解！每道题需要你手动计算并输入答案。答对一题得10分，共8题满分80分。'
          })

          Row({ space: 12 }) {
            Text(`得分：${this.score}`).fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppColors.accent)
            Text(`进度：${this.completedLevels.length}/${this.challenges.length}`).fontSize(14).fontColor(AppColors.textSecondary)
          }.width('100%').padding(12).backgroundColor(AppColors.bgSurface).borderRadius(10)

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.accent).margin({ right: 8 })
              Text(`第 ${this.currentLevel + 1} 题 · ${this.challenges[this.currentLevel].cipherType}`)
                .fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }

            Text(this.challenges[this.currentLevel].question)
              .fontSize(16).fontWeight(FontWeight.Medium).fontColor(AppColors.textPrimary).lineHeight(24)

            if (this.showHint) {
              Text(this.challenges[this.currentLevel].hint)
                .fontSize(13).fontColor(AppColors.textSecondary).lineHeight(20)
                .padding(10).backgroundColor('#FFF8E1').borderRadius(8).width('100%')
            } else {
              Text('查看提示').fontSize(13).fontColor(AppColors.accent)
                .onClick((): void => { this.showHint = true })
            }

            TextInput({ text: this.userAnswer, placeholder: '输入你的答案' })
              .width('100%').height(44).fontColor(AppColors.textPrimary)
              .backgroundColor(AppColors.bgSurfaceRaised).borderRadius(10)
              .onChange((v: string) => { this.userAnswer = v; this.hasChecked = false })

            Row({ space: 12 }) {
              Button('提交答案').type(ButtonType.Capsule).height(44)
                .backgroundColor(AppColors.accent).fontColor(AppColors.bgBase).layoutWeight(1)
                .enabled(this.userAnswer.length > 0)
                .onClick((): void => this.checkAnswer())
              if (this.currentLevel < this.challenges.length - 1) {
                Button('下一题 \u2192').type(ButtonType.Capsule).height(44)
                  .backgroundColor(AppColors.bgInput).fontColor(AppColors.textSecondary).layoutWeight(1)
                  .onClick((): void => this.nextChallenge())
              }
            }

            if (this.hasChecked) {
              if (this.isCorrect) {
                Row({ space: 8 }) {
                  Text('\u2713').fontSize(20).fontColor(AppColors.success)
                  Text('回答正确！').fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppColors.success)
                }.padding(16).backgroundColor(AppColors.bgSurface).borderRadius(12).width('100%').animation({ duration: 300 })
              } else {
                Column({ space: 8 }) {
                  Row({ space: 8 }) {
                    Text('\u2717').fontSize(20).fontColor(AppColors.danger)
                    Text('回答错误').fontSize(16).fontWeight(FontWeight.Bold).fontColor(AppColors.danger)
                  }
                  Text(`正确答案：${this.challenges[this.currentLevel].answer}`)
                    .fontSize(14).fontColor(AppColors.textSecondary)
                }.padding(16).backgroundColor(AppColors.bgSurface).borderRadius(12).width('100%').animation({ duration: 300 })
              }
            }
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })

          Column({ space: 12 }) {
            Row() {
              Column().width(3).height(14).borderRadius(1.5).backgroundColor(AppColors.accent).margin({ right: 8 })
              Text('题目列表').fontSize(15).fontWeight(FontWeight.Bold).fontColor(AppColors.textPrimary)
            }

            ForEach(this.challenges, (challenge: Challenge, idx: number) => {
              Row({ space: 10 }) {
                Text(this.completedLevels.indexOf(idx) >= 0 ? '\u2713' : `${idx + 1}`)
                  .fontSize(14).fontWeight(FontWeight.Bold)
                  .fontColor(this.completedLevels.indexOf(idx) >= 0 ? AppColors.success : AppColors.textHint)
                  .width(28).height(28).textAlign(TextAlign.Center)
                  .backgroundColor(this.completedLevels.indexOf(idx) >= 0 ? AppColors.bgSurface : AppColors.bgSurfaceRaised)
                  .borderRadius(14)
                Text(`${challenge.cipherType}：${challenge.question}`)
                  .fontSize(13).fontColor(AppColors.textPrimary).layoutWeight(1).maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }.width('100%').padding(8).borderRadius(8)
              .backgroundColor(this.currentLevel === idx ? AppColors.bgSurface : AppColors.bgSurfaceRaised)
              .onClick((): void => {
                this.currentLevel = idx
                this.userAnswer = ''
                this.showHint = false
                this.hasChecked = false
                this.isCorrect = false
              })
            })
          }
          .width('100%').padding(16).backgroundColor(AppColors.bgCard).borderRadius(12)
          .shadow({ radius: 4, color: AppColors.borderHairline, offsetX: 0, offsetY: 2 })
        }.padding(16)
      }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
    }.width('100%').height('100%').backgroundColor(AppColors.bgPage)
  }
}