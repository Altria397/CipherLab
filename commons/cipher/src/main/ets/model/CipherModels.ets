export class CustomCipher {
  id: string = ''
  name: string = ''
  type: string = 'shift'
  shiftAmount: number = 3
  keyword: string = ''
  affineA: number = 5
  affineB: number = 8
  railCount: number = 3
  createTime: number = 0
}

export class AlgorithmInfo {
  name: string = ''
  description: string = ''
  icon: string = ''
  route: string = ''
  color: string = ''
  gradient: string = ''
}

export class StepData {
  title: string = ''
  description: string = ''
  highlights: number[] = []
}