import { describe, beforeAll, it, expect } from '@ohos/hypium';
import { CipherUtils, CustomCipherParam } from 'cipher';

export default function cipherUtilsTest() {
  describe('CaesarCipher', () => {
    it('encrypt_basic', 0, () => {
      expect(CipherUtils.caesarEncrypt('HELLO', 3)).assertEqual('KHOOR')
    })
    it('encrypt_wrapAround', 0, () => {
      expect(CipherUtils.caesarEncrypt('XYZ', 3)).assertEqual('ABC')
    })
    it('encrypt_lowercase', 0, () => {
      expect(CipherUtils.caesarEncrypt('hello', 3)).assertEqual('khoor')
    })
    it('encrypt_nonAlpha', 0, () => {
      expect(CipherUtils.caesarEncrypt('HI!', 3)).assertEqual('KL!')
    })
    it('decrypt_basic', 0, () => {
      expect(CipherUtils.caesarDecrypt('KHOOR', 3)).assertEqual('HELLO')
    })
    it('encrypt_decrypt_roundtrip', 0, () => {
      const plain = 'CIPHERLAB'
      expect(CipherUtils.caesarDecrypt(CipherUtils.caesarEncrypt(plain, 7), 7)).assertEqual(plain)
    })
    it('encrypt_shift25', 0, () => {
      expect(CipherUtils.caesarEncrypt('A', 25)).assertEqual('Z')
    })
    it('encrypt_shift0', 0, () => {
      expect(CipherUtils.caesarEncrypt('ABC', 0)).assertEqual('ABC')
    })
  })

  describe('VigenereCipher', () => {
    it('encrypt_basic', 0, () => {
      expect(CipherUtils.vigenereEncrypt('HELLO', 'KEY')).assertEqual('RIJVS')
    })
    it('encrypt_emptyKey', 0, () => {
      expect(CipherUtils.vigenereEncrypt('HELLO', '')).assertEqual('HELLO')
    })
    it('encrypt_nonAlphaPreserved', 0, () => {
      const result = CipherUtils.vigenereEncrypt('HI!', 'AB')
      expect(result.charAt(0)).assertEqual('I')
      expect(result.charAt(2)).assertEqual('!')
    })
    it('decrypt_basic', 0, () => {
      expect(CipherUtils.vigenereDecrypt('RIJVS', 'KEY')).assertEqual('HELLO')
    })
    it('encrypt_decrypt_roundtrip', 0, () => {
      const plain = 'CIPHERLAB'
      expect(CipherUtils.vigenereDecrypt(CipherUtils.vigenereEncrypt(plain, 'SECRET'), 'SECRET')).assertEqual(plain)
    })
  })

  describe('XorCipher', () => {
    it('encrypt_basic', 0, () => {
      const result = CipherUtils.xorEncrypt('A', 'B')
      expect(result.length > 0).assertTrue()
    })
    it('encrypt_emptyKey', 0, () => {
      expect(CipherUtils.xorEncrypt('HELLO', '')).assertEqual('HELLO')
    })
    it('decrypt_basic', 0, () => {
      const encrypted = CipherUtils.xorEncrypt('Hello', 'K')
      const decrypted = CipherUtils.xorDecrypt(encrypted, 'K')
      expect(decrypted).assertEqual('Hello')
    })
    it('encrypt_decrypt_roundtrip', 0, () => {
      const plain = 'Test123'
      const key = 'KEY'
      expect(CipherUtils.xorDecrypt(CipherUtils.xorEncrypt(plain, key), key)).assertEqual(plain)
    })
  })

  describe('Base64', () => {
    it('encode_basic', 0, () => {
      expect(CipherUtils.base64Encode('Hi')).assertEqual('SGk=')
    })
    it('encode_threeBytes', 0, () => {
      expect(CipherUtils.base64Encode('Hi!')).assertEqual('SGkh')
    })
    it('decode_basic', 0, () => {
      expect(CipherUtils.base64Decode('SGk=')).assertEqual('Hi')
    })
    it('decode_noPadding', 0, () => {
      expect(CipherUtils.base64Decode('SGkh')).assertEqual('Hi!')
    })
    it('encode_decode_roundtrip', 0, () => {
      const texts = ['Hello', 'Test123', 'A', 'AB', 'ABC', 'ABCD']
      for (let i = 0; i < texts.length; i++) {
        expect(CipherUtils.base64Decode(CipherUtils.base64Encode(texts[i]))).assertEqual(texts[i])
      }
    })
  })

  describe('MathUtils', () => {
    it('modPow_basic', 0, () => {
      expect(CipherUtils.modPow(42, 7, 77)).assertEqual(42)
    })
    it('modPow_largeExp', 0, () => {
      expect(CipherUtils.modPow(2, 10, 1000)).assertEqual(1024)
    })
    it('gcd_basic', 0, () => {
      expect(CipherUtils.gcd(12, 8)).assertEqual(4)
    })
    it('gcd_coprime', 0, () => {
      expect(CipherUtils.gcd(7, 11)).assertEqual(1)
    })
    it('modInverse_basic', 0, () => {
      const result = CipherUtils.modInverse(7, 60)
      expect((result * 7) % 60).assertEqual(1)
    })
    it('modInverse_noInverse', 0, () => {
      expect(CipherUtils.modInverse(2, 4)).assertEqual(-1)
    })
    it('isValidAffineA_valid', 0, () => {
      expect(CipherUtils.isValidAffineA(5)).assertTrue()
      expect(CipherUtils.isValidAffineA(7)).assertTrue()
      expect(CipherUtils.isValidAffineA(1)).assertTrue()
    })
    it('isValidAffineA_invalid', 0, () => {
      expect(CipherUtils.isValidAffineA(2)).assertFalse()
      expect(CipherUtils.isValidAffineA(4)).assertFalse()
      expect(CipherUtils.isValidAffineA(13)).assertFalse()
    })
  })

  describe('KeywordCipher', () => {
    it('encrypt_basic', 0, () => {
      const result = CipherUtils.keywordEncrypt('HELLO', 'KEY')
      expect(result.length).assertEqual(5)
    })
    it('encrypt_decrypt_roundtrip', 0, () => {
      const plain = 'HELLO'
      expect(CipherUtils.keywordDecrypt(CipherUtils.keywordEncrypt(plain, 'SECRET'), 'SECRET')).assertEqual(plain)
    })
  })

  describe('AffineCipher', () => {
    it('encrypt_basic', 0, () => {
      const result = CipherUtils.affineEncrypt('HELLO', 5, 8)
      expect(result.length).assertEqual(5)
    })
    it('encrypt_invalidA', 0, () => {
      expect(CipherUtils.affineEncrypt('HELLO', 2, 3)).assertEqual('HELLO')
    })
    it('decrypt_basic', 0, () => {
      const encrypted = CipherUtils.affineEncrypt('HELLO', 5, 8)
      expect(CipherUtils.affineDecrypt(encrypted, 5, 8)).assertEqual('HELLO')
    })
    it('encrypt_decrypt_roundtrip', 0, () => {
      const plain = 'CIPHERLAB'
      expect(CipherUtils.affineDecrypt(CipherUtils.affineEncrypt(plain, 7, 3), 7, 3)).assertEqual(plain)
    })
  })

  describe('RailFenceCipher', () => {
    it('encrypt_basic', 0, () => {
      const result = CipherUtils.railFenceEncrypt('HELLO', 3)
      expect(result.length).assertEqual(5)
    })
    it('encrypt_singleRail', 0, () => {
      expect(CipherUtils.railFenceEncrypt('HELLO', 1)).assertEqual('HELLO')
    })
    it('decrypt_basic', 0, () => {
      const encrypted = CipherUtils.railFenceEncrypt('HELLO', 3)
      expect(CipherUtils.railFenceDecrypt(encrypted, 3)).assertEqual('HELLO')
    })
    it('encrypt_decrypt_roundtrip', 0, () => {
      const plain = 'CIPHERLABTEST'
      expect(CipherUtils.railFenceDecrypt(CipherUtils.railFenceEncrypt(plain, 4), 4)).assertEqual(plain)
    })
  })

  describe('CustomCipher', () => {
    it('encryptWithCustom_shift', 0, () => {
      const param = new CustomCipherParam()
      param.type = 'shift'
      param.shiftAmount = 3
      expect(CipherUtils.encryptWithCustom('HELLO', param)).assertEqual('KHOOR')
    })
    it('decryptWithCustom_shift', 0, () => {
      const param = new CustomCipherParam()
      param.type = 'shift'
      param.shiftAmount = 3
      expect(CipherUtils.decryptWithCustom('KHOOR', param)).assertEqual('HELLO')
    })
    it('encryptChain_basic', 0, () => {
      const p1 = new CustomCipherParam()
      p1.type = 'shift'
      p1.shiftAmount = 3
      const p2 = new CustomCipherParam()
      p2.type = 'shift'
      p2.shiftAmount = 5
      const encrypted = CipherUtils.encryptChain('ABC', [p1, p2])
      expect(CipherUtils.decryptChain(encrypted, [p1, p2])).assertEqual('ABC')
    })
  })

  describe('ToBinary', () => {
    it('basic', 0, () => {
      expect(CipherUtils.toBinary(65, 8)).assertEqual('01000001')
    })
    it('zero', 0, () => {
      expect(CipherUtils.toBinary(0, 8)).assertEqual('00000000')
    })
    it('255', 0, () => {
      expect(CipherUtils.toBinary(255, 8)).assertEqual('11111111')
    })
  })
}