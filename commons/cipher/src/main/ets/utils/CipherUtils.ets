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
}

export class CustomCipherParam {
  type: string = 'shift'
  shiftAmount: number = 3
  keyword: string = ''
  affineA: number = 5
  affineB: number = 8
  railCount: number = 3
}
