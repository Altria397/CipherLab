const B64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

export class CipherUtils {
  static caesarEncryptChar(ch: string, shift: number): string {
    const code = ch.charCodeAt(0)
    if (code >= 65 && code <= 90) {
      return String.fromCharCode(((code - 65 + shift % 26) + 26) % 26 + 65)
    }
    if (code >= 97 && code <= 122) {
      return String.fromCharCode(((code - 97 + shift % 26) + 26) % 26 + 97)
    }
    return ch
  }

  static caesarEncrypt(text: string, shift: number): string {
    let result = ''
    for (let i = 0; i < text.length; i++) {
      result += CipherUtils.caesarEncryptChar(text.charAt(i), shift)
    }
    return result
  }

  static caesarDecrypt(text: string, shift: number): string {
    return CipherUtils.caesarEncrypt(text, -shift)
  }

  static vigenereEncryptChar(ch: string, keyChar: string): string {
    const shift = keyChar.toUpperCase().charCodeAt(0) - 65
    return CipherUtils.caesarEncryptChar(ch, shift)
  }

  static vigenereDecryptChar(ch: string, keyChar: string): string {
    const shift = keyChar.toUpperCase().charCodeAt(0) - 65
    return CipherUtils.caesarEncryptChar(ch, -shift)
  }

  static vigenereEncrypt(text: string, key: string): string {
    if (key.length === 0) return text
    let result = ''
    let ki = 0
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
        result += CipherUtils.vigenereEncryptChar(text.charAt(i), key.charAt(ki % key.length))
        ki++
      } else {
        result += text.charAt(i)
      }
    }
    return result
  }

  static vigenereDecrypt(text: string, key: string): string {
    if (key.length === 0) return text
    let result = ''
    let ki = 0
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
        result += CipherUtils.vigenereDecryptChar(text.charAt(i), key.charAt(ki % key.length))
        ki++
      } else {
        result += text.charAt(i)
      }
    }
    return result
  }

  static xorEncrypt(text: string, key: string): string {
    if (key.length === 0) return text
    let result = ''
    for (let i = 0; i < text.length; i++) {
      const xored = text.charCodeAt(i) ^ key.charCodeAt(i % key.length)
      result += xored.toString(16).padStart(2, '0')
    }
    return result
  }

  static xorDecrypt(hexText: string, key: string): string {
    if (key.length === 0) return hexText
    if (hexText.length % 2 !== 0) return ''
    let result = ''
    for (let i = 0; i < hexText.length; i += 2) {
      const byte = parseInt(hexText.substring(i, i + 2), 16)
      if (isNaN(byte)) return ''
      const keyByte = key.charCodeAt((i / 2) % key.length)
      result += String.fromCharCode(byte ^ keyByte)
    }
    return result
  }

  static toBinary(num: number, bits: number): string {
    let s = ''
    for (let i = bits - 1; i >= 0; i--) {
      s += ((num >> i) & 1).toString()
    }
    return s
  }

  static base64Encode(text: string): string {
    let result = ''
    let bits = ''
    for (let i = 0; i < text.length; i++) {
      bits += CipherUtils.toBinary(text.charCodeAt(i), 8)
    }
    while (bits.length % 6 !== 0) {
      bits += '0'
    }
    for (let i = 0; i < bits.length; i += 6) {
      const chunk = bits.substring(i, i + 6)
      let val = 0
      for (let j = 0; j < chunk.length; j++) {
        val = val * 2 + (chunk.charAt(j) === '1' ? 1 : 0)
      }
      result += B64_CHARS.charAt(val)
    }
    while (result.length % 4 !== 0) {
      result += '='
    }
    return result
  }

  static base64Decode(encoded: string): string {
    let bits = ''
    let paddingCount = 0
    for (let i = 0; i < encoded.length; i++) {
      const ch = encoded.charAt(i)
      if (ch === '=') {
        paddingCount++
        continue
      }
      const idx = B64_CHARS.indexOf(ch)
      if (idx === -1) continue
      bits += CipherUtils.toBinary(idx, 6)
    }
    bits = bits.substring(0, bits.length - paddingCount * 2)
    let result = ''
    for (let i = 0; i + 8 <= bits.length; i += 8) {
      const chunk = bits.substring(i, i + 8)
      let val = 0
      for (let j = 0; j < chunk.length; j++) {
        val = val * 2 + (chunk.charAt(j) === '1' ? 1 : 0)
      }
      result += String.fromCharCode(val)
    }
    return result
  }

  static modPow(base: number, exp: number, mod: number): number {
    let result = 1
    base = ((base % mod) + mod) % mod
    while (exp > 0) {
      if (exp % 2 === 1) {
        result = (result * base) % mod
      }
      exp = Math.floor(exp / 2)
      base = (base * base) % mod
    }
    return result
  }

  static gcd(a: number, b: number): number {
    a = Math.abs(a)
    b = Math.abs(b)
    while (b !== 0) {
      const t = b
      b = a % b
      a = t
    }
    return a
  }

  static modInverse(e: number, phi: number): number {
    let oldR = phi, r = e
    let oldS = 0, s = 1
    while (r !== 0) {
      const q = Math.floor(oldR / r)
      const tempR = r
      r = oldR - q * r
      oldR = tempR
      const tempS = s
      s = oldS - q * s
      oldS = tempS
    }
    if (oldR > 1) return -1
    if (oldS < 0) oldS += phi
    return oldS
  }

  static isValidAffineA(a: number): boolean {
    return CipherUtils.gcd(a, 26) === 1
  }

  static keywordEncrypt(text: string, keyword: string): string {
    const alphabet = CipherUtils.buildKeywordAlphabet(keyword)
    let result = ''
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if (code >= 65 && code <= 90) {
        result += alphabet.charAt(code - 65)
      } else if (code >= 97 && code <= 122) {
        result += alphabet.charAt(code - 97).toLowerCase()
      } else {
        result += text.charAt(i)
      }
    }
    return result
  }

  static keywordDecrypt(text: string, keyword: string): string {
    const alphabet = CipherUtils.buildKeywordAlphabet(keyword)
    let result = ''
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if (code >= 65 && code <= 90) {
        const idx = alphabet.indexOf(text.charAt(i))
        result += idx >= 0 ? String.fromCharCode(idx + 65) : text.charAt(i)
      } else if (code >= 97 && code <= 122) {
        const idx = alphabet.indexOf(text.charAt(i).toUpperCase())
        result += idx >= 0 ? String.fromCharCode(idx + 97) : text.charAt(i)
      } else {
        result += text.charAt(i)
      }
    }
    return result
  }

  private static buildKeywordAlphabet(keyword: string): string {
    const upperKey = keyword.toUpperCase()
    let seen = ''
    let alphabet = ''
    for (let i = 0; i < upperKey.length; i++) {
      const c = upperKey.charAt(i)
      if (c >= 'A' && c <= 'Z' && !seen.includes(c)) {
        alphabet += c
        seen += c
      }
    }
    for (let i = 0; i < 26; i++) {
      const c = String.fromCharCode(65 + i)
      if (!seen.includes(c)) {
        alphabet += c
      }
    }
    return alphabet
  }

  static affineEncrypt(text: string, a: number, b: number): string {
    if (!CipherUtils.isValidAffineA(a)) return text
    let result = ''
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if (code >= 65 && code <= 90) {
        result += String.fromCharCode(((a * (code - 65) + b) % 26 + 26) % 26 + 65)
      } else if (code >= 97 && code <= 122) {
        result += String.fromCharCode(((a * (code - 97) + b) % 26 + 26) % 26 + 97)
      } else {
        result += text.charAt(i)
      }
    }
    return result
  }

  static affineDecrypt(text: string, a: number, b: number): string {
    if (!CipherUtils.isValidAffineA(a)) return text
    const aInv = CipherUtils.modInverse(a, 26)
    if (aInv < 0) return text
    let result = ''
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if (code >= 65 && code <= 90) {
        result += String.fromCharCode(((aInv * ((code - 65 - b) % 26 + 26)) % 26 + 26) % 26 + 65)
      } else if (code >= 97 && code <= 122) {
        result += String.fromCharCode(((aInv * ((code - 97 - b) % 26 + 26)) % 26 + 26) % 26 + 97)
      } else {
        result += text.charAt(i)
      }
    }
    return result
  }

  static railFenceEncrypt(text: string, rails: number): string {
    if (rails <= 1 || rails >= text.length) return text
    const fence: string[][] = []
    for (let i = 0; i < rails; i++) {
      fence.push([])
    }
    let rail = 0
    let dir = 1
    for (let i = 0; i < text.length; i++) {
      fence[rail].push(text.charAt(i))
      if (rail === 0) dir = 1
      if (rail === rails - 1) dir = -1
      rail += dir
    }
    let result = ''
    for (let i = 0; i < rails; i++) {
      result += fence[i].join('')
    }
    return result
  }

  static railFenceDecrypt(text: string, rails: number): string {
    if (rails <= 1 || rails >= text.length) return text
    const n = text.length
    const pattern: number[] = []
    let rail = 0
    let dir = 1
    for (let i = 0; i < n; i++) {
      pattern.push(rail)
      if (rail === 0) dir = 1
      if (rail === rails - 1) dir = -1
      rail += dir
    }
    const railLengths: number[] = []
    for (let i = 0; i < rails; i++) {
      railLengths.push(0)
    }
    for (let i = 0; i < n; i++) {
      railLengths[pattern[i]]++
    }
    const railStrings: string[] = []
    let pos = 0
    for (let r = 0; r < rails; r++) {
      railStrings.push(text.substring(pos, pos + railLengths[r]))
      pos += railLengths[r]
    }
    const railIndices: number[] = []
    for (let i = 0; i < rails; i++) {
      railIndices.push(0)
    }
    let result = ''
    for (let i = 0; i < n; i++) {
      const r = pattern[i]
      result += railStrings[r].charAt(railIndices[r])
      railIndices[r]++
    }
    return result
  }

  static encryptWithCustom(text: string, cipher: CustomCipherParam): string {
    switch (cipher.type) {
      case 'shift':
        return CipherUtils.caesarEncrypt(text, cipher.shiftAmount)
      case 'keyword':
        return CipherUtils.keywordEncrypt(text, cipher.keyword)
      case 'affine':
        return CipherUtils.affineEncrypt(text, cipher.affineA, cipher.affineB)
      case 'railFence':
        return CipherUtils.railFenceEncrypt(text, cipher.railCount)
      default:
        return text
    }
  }

  static decryptWithCustom(text: string, cipher: CustomCipherParam): string {
    switch (cipher.type) {
      case 'shift':
        return CipherUtils.caesarDecrypt(text, cipher.shiftAmount)
      case 'keyword':
        return CipherUtils.keywordDecrypt(text, cipher.keyword)
      case 'affine':
        return CipherUtils.affineDecrypt(text, cipher.affineA, cipher.affineB)
      case 'railFence':
        return CipherUtils.railFenceDecrypt(text, cipher.railCount)
      default:
        return text
    }
  }

  static encryptChain(text: string, ciphers: CustomCipherParam[]): string {
    let result = text
    for (let i = 0; i < ciphers.length; i++) {
      result = CipherUtils.encryptWithCustom(result, ciphers[i])
    }
    return result
  }

  static decryptChain(text: string, ciphers: CustomCipherParam[]): string {
    let result = text
    for (let i = ciphers.length - 1; i >= 0; i--) {
      result = CipherUtils.decryptWithCustom(result, ciphers[i])
    }
    return result
  }

  static hillEncrypt(text: string, keyMatrix: number[][]): string {
    const n = keyMatrix.length
    const upper = text.toUpperCase().replace(/[^A-Z]/g, '')
    let padded = upper
    while (padded.length % n !== 0) {
      padded += 'X'
    }
    let result = ''
    for (let i = 0; i < padded.length; i += n) {
      const vec: number[] = []
      for (let j = 0; j < n; j++) {
        vec.push(padded.charCodeAt(i + j) - 65)
      }
      const out = CipherUtils.matrixVecMul(keyMatrix, vec)
      for (let j = 0; j < n; j++) {
        result += String.fromCharCode(((out[j] % 26) + 26) % 26 + 65)
      }
    }
    return result
  }

  static hillDecrypt(text: string, keyMatrix: number[][]): string {
    const invMatrix = CipherUtils.matrixModInverse(keyMatrix, 26)
    if (invMatrix === null) return text
    return CipherUtils.hillEncrypt(text, invMatrix)
  }

  static isValidHillKey(keyMatrix: number[][]): boolean {
    const det = CipherUtils.matrixDet(keyMatrix)
    const detMod = ((det % 26) + 26) % 26
    return CipherUtils.gcd(detMod, 26) === 1
  }

  static matrixVecMul(mat: number[][], vec: number[]): number[] {
    const n = mat.length
    const result: number[] = []
    for (let i = 0; i < n; i++) {
      let sum = 0
      for (let j = 0; j < n; j++) {
        sum += mat[i][j] * vec[j]
      }
      result.push(sum)
    }
    return result
  }

  static matrixDet(mat: number[][]): number {
    const n = mat.length
    if (n === 1) return mat[0][0]
    if (n === 2) return mat[0][0] * mat[1][1] - mat[0][1] * mat[1][0]
    let det = 0
    for (let j = 0; j < n; j++) {
      const minor = CipherUtils.matrixMinor(mat, 0, j)
      det += ((j % 2 === 0 ? 1 : -1) * mat[0][j] * CipherUtils.matrixDet(minor))
    }
    return det
  }

  static matrixMinor(mat: number[][], row: number, col: number): number[][] {
    const result: number[][] = []
    for (let i = 0; i < mat.length; i++) {
      if (i === row) continue
      const r: number[] = []
      for (let j = 0; j < mat[0].length; j++) {
        if (j === col) continue
        r.push(mat[i][j])
      }
      result.push(r)
    }
    return result
  }

  static matrixModInverse(mat: number[][], mod: number): number[][] | null {
    const n = mat.length
    const det = CipherUtils.matrixDet(mat)
    const detMod = ((det % mod) + mod) % mod
    const detInv = CipherUtils.modInverse(detMod, mod)
    if (detInv < 0) return null

    if (n === 2) {
      const inv: number[][] = [
        [mat[1][1], -mat[0][1]],
        [-mat[1][0], mat[0][0]]
      ]
      for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
          inv[i][j] = (((inv[i][j] * detInv) % mod) + mod) % mod
        }
      }
      return inv
    }

    const cofactors: number[][] = []
    for (let i = 0; i < n; i++) {
      const row: number[] = []
      for (let j = 0; j < n; j++) {
        const minor = CipherUtils.matrixMinor(mat, i, j)
        const sign = ((i + j) % 2 === 0) ? 1 : -1
        row.push((((sign * CipherUtils.matrixDet(minor) * detInv) % mod) + mod) % mod)
      }
      cofactors.push(row)
    }

    const inv: number[][] = []
    for (let i = 0; i < n; i++) {
      const row: number[] = []
      for (let j = 0; j < n; j++) {
        row.push(cofactors[j][i])
      }
      inv.push(row)
    }
    return inv
  }

  static otpEncrypt(text: string, key: string): string {
    if (key.length < text.length) return ''
    let result = ''
    for (let i = 0; i < text.length; i++) {
      result += String.fromCharCode(text.charCodeAt(i) ^ key.charCodeAt(i))
    }
    return result
  }

  static otpDecrypt(cipherText: string, key: string): string {
    return CipherUtils.otpEncrypt(cipherText, key)
  }

  static simpleHash(text: string, algorithm: string): string {
    let hash: number
    if (algorithm === 'md5-like') {
      hash = CipherUtils.fletcher32(text)
    } else {
      hash = CipherUtils.fletcher32(text)
    }
    let hex = ''
    const bytes: number[] = [
      (hash >> 24) & 0xFF,
      (hash >> 16) & 0xFF,
      (hash >> 8) & 0xFF,
      hash & 0xFF,
      ((hash * 31) >> 24) & 0xFF,
      ((hash * 31) >> 16) & 0xFF,
      ((hash * 31) >> 8) & 0xFF,
      (hash * 31) & 0xFF,
      ((hash * 37) >> 24) & 0xFF,
      ((hash * 37) >> 16) & 0xFF,
      ((hash * 37) >> 8) & 0xFF,
      (hash * 37) & 0xFF,
      ((hash * 41) >> 24) & 0xFF,
      ((hash * 41) >> 16) & 0xFF,
      ((hash * 41) >> 8) & 0xFF,
      (hash * 41) & 0xFF,
    ]
    for (let i = 0; i < bytes.length; i++) {
      hex += bytes[i].toString(16).padStart(2, '0')
    }
    return hex
  }

  static fletcher32(data: string): number {
    let sum1 = 0xFFFF
    let sum2 = 0xFFFF
    const len = data.length
    let i = 0
    while (i < len) {
      let tLen = Math.min(360, len - i)
      for (let j = 0; j < tLen; j++) {
        sum1 += data.charCodeAt(i + j)
        sum2 += sum1
      }
      sum1 = (sum1 & 0xFFFF) + (sum1 >> 16)
      sum2 = (sum2 & 0xFFFF) + (sum2 >> 16)
      i += tLen
    }
    sum1 = (sum1 & 0xFFFF) + (sum1 >> 16)
    sum2 = (sum2 & 0xFFFF) + (sum2 >> 16)
    return (sum2 << 16) | sum1
  }

  static diffieHellmanGeneratePrivate(p: number): number {
    return Math.floor(Math.random() * (p - 2)) + 2
  }

  static diffieHellmanComputePublic(base: number, privateExp: number, p: number): number {
    return CipherUtils.modPow(base, privateExp, p)
  }

  static diffieHellmanComputeShared(publicOther: number, privateExp: number, p: number): number {
    return CipherUtils.modPow(publicOther, privateExp, p)
  }

  static isPrime(n: number): boolean {
    if (n < 2) return false
    if (n < 4) return true
    if (n % 2 === 0 || n % 3 === 0) return false
    for (let i = 5; i * i <= n; i += 6) {
      if (n % i === 0 || n % (i + 2) === 0) return false
    }
    return true
  }

  static findPrimitiveRoot(p: number): number {
    if (p === 2) return 1
    const phi = p - 1
    const factors: number[] = []
    let n = phi
    for (let i = 2; i * i <= n; i++) {
      if (n % i === 0) {
        factors.push(i)
        while (n % i === 0) n = Math.floor(n / i)
      }
    }
    if (n > 1) factors.push(n)
    for (let g = 2; g < p; g++) {
      let isRoot = true
      for (let i = 0; i < factors.length; i++) {
        if (CipherUtils.modPow(g, Math.floor(phi / factors[i]), p) === 1) {
          isRoot = false
          break
        }
      }
      if (isRoot) return g
    }
    return 2
  }

  static frequencyAnalysis(text: string): Map<string, number> {
    const freq = new Map<string, number>()
    const upper = text.toUpperCase().replace(/[^A-Z]/g, '')
    for (let i = 0; i < upper.length; i++) {
      const ch = upper.charAt(i)
      freq.set(ch, (freq.get(ch) || 0) + 1)
    }
    return freq
  }

  static caesarBruteForce(ciphertext: string): string[] {
    const results: string[] = []
    for (let shift = 0; shift < 26; shift++) {
      results.push(CipherUtils.caesarDecrypt(ciphertext, shift))
    }
    return results
  }

  static kasiskiExamination(text: string): number[] {
    const upper = text.toUpperCase().replace(/[^A-Z]/g, '')
    const distances: number[] = []
    for (let len = 3; len <= 5; len++) {
      for (let i = 0; i <= upper.length - len; i++) {
        const seq = upper.substring(i, i + len)
        const nextPos = upper.indexOf(seq, i + len)
        if (nextPos > 0) {
          distances.push(nextPos - i)
        }
      }
    }
    if (distances.length === 0) return []
    const factorCounts = new Map<number, number>()
    for (let i = 0; i < distances.length; i++) {
      for (let f = 2; f <= distances[i]; f++) {
        if (distances[i] % f === 0) {
          factorCounts.set(f, (factorCounts.get(f) || 0) + 1)
        }
      }
    }
    const sorted: number[] = []
    factorCounts.forEach((count: number, factor: number) => {
      sorted.push(factor)
    })
    sorted.sort((a: number, b: number): number => {
      return (factorCounts.get(b) || 0) - (factorCounts.get(a) || 0)
    })
    return sorted.slice(0, 10)
  }

  static indexOfCoincidence(text: string): number {
    const upper = text.toUpperCase().replace(/[^A-Z]/g, '')
    const n = upper.length
    if (n <= 1) return 0
    const freq = new Map<string, number>()
    for (let i = 0; i < n; i++) {
      const ch = upper.charAt(i)
      freq.set(ch, (freq.get(ch) || 0) + 1)
    }
    let sum = 0
    freq.forEach((count: number) => {
      sum += count * (count - 1)
    })
    return sum / (n * (n - 1))
  }
}

export class CustomCipherParam {
  type: string = 'shift'
  shiftAmount: number = 3
  keyword: string = ''
  affineA: number = 5
  affineB: number = 8
  railCount: number = 3
}

export class ShareUtils {
  static encodeShareMessage(algorithm: string, params: string, result: string): string {
    const payload = `${algorithm}|${params}|${result}`
    return `CIPHERLAB:${CipherUtils.base64Encode(payload)}`
  }

  static decodeShareMessage(shared: string): string[] | null {
    if (!shared.startsWith('CIPHERLAB:')) return null
    const encoded = shared.substring(10)
    const decoded = CipherUtils.base64Decode(encoded)
    const parts = decoded.split('|')
    if (parts.length < 3) return null
    return parts
  }
}
